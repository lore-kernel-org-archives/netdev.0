From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 2/2] igb: skb recycling
Date: Tue, 21 Oct 2008 12:11:37 -0700
Message-ID: <20081021121137.5c67d338@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeffery.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This driver is multiqueue, so implement a small skb recycling queue per
cpu. It doesn't make sense to have a global queue since then a lock would
be required. Not sure if this is going to work; compile tested only, needs more evaluation

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/igb/igb.h	2008-10-21 09:37:39.000000000 -0700
+++ b/drivers/net/igb/igb.h	2008-10-21 09:39:15.000000000 -0700
@@ -232,6 +232,7 @@ struct igb_adapter {
 
 	/* TX */
 	struct igb_ring *tx_ring;      /* One per active queue */
+	struct sk_buff_head *rx_recycle; /* One per cpu */
 	unsigned int restart_queue;
 	unsigned long tx_queue_len;
 	u32 txd_cmd;
--- a/drivers/net/igb/igb_main.c	2008-10-21 09:39:25.000000000 -0700
+++ b/drivers/net/igb/igb_main.c	2008-10-21 10:13:42.000000000 -0700
@@ -824,6 +824,11 @@ void igb_down(struct igb_adapter *adapte
 		igb_reset(adapter);
 	igb_clean_all_tx_rings(adapter);
 	igb_clean_all_rx_rings(adapter);
+
+	for_each_possible_cpu(i) {
+		struct sk_buff_head *rx_recycle = per_cpu_ptr(adapter->rx_recycle,i);
+		__skb_queue_purge(rx_recycle);
+	}
 }
 
 void igb_reinit_locked(struct igb_adapter *adapter)
@@ -1022,6 +1027,11 @@ static int __devinit igb_probe(struct pc
 	adapter = netdev_priv(netdev);
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
+
+	adapter->rx_recycle = percpu_alloc(sizeof(struct sk_buff_head), GFP_KERNEL);
+	if (!adapter->rx_recycle)
+		goto err_alloc_recycle;
+
 	hw = &adapter->hw;
 	hw->back = adapter;
 	adapter->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE;
@@ -1289,6 +1299,8 @@ err_sw_init:
 err_hw_init:
 	iounmap(hw->hw_addr);
 err_ioremap:
+	percpu_free(adapter->rx_recycle);
+err_alloc_recycle:
 	free_netdev(netdev);
 err_alloc_etherdev:
 	pci_release_selected_regions(pdev, bars);
@@ -1352,6 +1364,8 @@ static void __devexit igb_remove(struct 
 		iounmap(adapter->hw.flash_address);
 	pci_release_selected_regions(pdev, adapter->bars);
 
+	percpu_free(adapter->rx_recycle);
+
 	free_netdev(netdev);
 
 	pci_disable_device(pdev);
@@ -1989,6 +2003,11 @@ static void igb_free_all_tx_resources(st
 		igb_free_tx_resources(&adapter->tx_ring[i]);
 }
 
+static inline unsigned int igb_rx_bufsize(const struct igb_adapter *adapter)
+{
+	return (adapter->rx_ps_hdr_size ? : adapter->rx_buffer_len) + NET_IP_ALIGN;
+}
+
 static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
 					   struct igb_buffer *buffer_info)
 {
@@ -2000,7 +2019,15 @@ static void igb_unmap_and_free_tx_resour
 		buffer_info->dma = 0;
 	}
 	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
+		struct sk_buff_head *rx_recycle
+			= per_cpu_ptr(adapter->rx_recycle, smp_processor_id());
+
+		if (skb_queue_len(rx_recycle) < 16 &&
+		    skb_recycle_check(buffer_info->skb, igb_rx_bufsize(adapter)))
+			__skb_queue_head(rx_recycle, buffer_info->skb);
+		else
+		    dev_kfree_skb_any(buffer_info->skb);
+
 		buffer_info->skb = NULL;
 	}
 	buffer_info->time_stamp = 0;
@@ -4014,18 +4041,18 @@ static void igb_alloc_rx_buffers_adv(str
 		}
 
 		if (!buffer_info->skb) {
-			int bufsz;
-
-			if (adapter->rx_ps_hdr_size)
-				bufsz = adapter->rx_ps_hdr_size;
-			else
-				bufsz = adapter->rx_buffer_len;
-			bufsz += NET_IP_ALIGN;
-			skb = netdev_alloc_skb(netdev, bufsz);
+			unsigned int bufsz = igb_rx_bufsize(adapter);
+			struct sk_buff_head *rx_recycle
+				= per_cpu_ptr(adapter->rx_recycle,
+					      smp_processor_id());
 
+			skb = __skb_dequeue(rx_recycle);
 			if (!skb) {
-				adapter->alloc_rx_buff_failed++;
-				goto no_buffers;
+				skb = netdev_alloc_skb(netdev, bufsz);
+				if (!skb) {
+					adapter->alloc_rx_buff_failed++;
+					goto no_buffers;
+				}
 			}
 
 			/* Make buffer alignment 2 beyond a 16 byte boundary

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
