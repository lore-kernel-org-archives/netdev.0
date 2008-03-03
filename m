From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/5] ixgbe: Introduce Multiqueue TX
Date: Mon, 03 Mar 2008 15:03:52 -0800
Message-ID: <20080303230352.25151.16296.stgit@localhost.localdomain>
References: <20080303230345.25151.48298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080303230345.25151.48298.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

Now that the irq vector code is in place, we can add the conditional
multiqueue TX code in the driver. This requires the optional
CONFIG_NETDEVICES_MULTIQUEUE=y and will not be enabled without
it.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Acked-by: Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   15 +++++++++-
 drivers/net/ixgbe/ixgbe_main.c    |   56 ++++++++++++++++++++++++++++++++++---
 2 files changed, 66 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index a119cbd..85b7d15 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -246,13 +246,26 @@ static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
 
 static int ixgbe_set_tso(struct net_device *netdev, u32 data)
 {
-
 	if (data) {
 		netdev->features |= NETIF_F_TSO;
 		netdev->features |= NETIF_F_TSO6;
 	} else {
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		struct ixgbe_adapter *adapter = netdev_priv(netdev);
+		int i;
+#endif
+		netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			netif_stop_subqueue(netdev, i);
+#endif
 		netdev->features &= ~NETIF_F_TSO;
 		netdev->features &= ~NETIF_F_TSO6;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			netif_start_subqueue(netdev, i);
+#endif
+		netif_start_queue(netdev);
 	}
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fecc8ea..fc1c226 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -256,16 +256,28 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
+		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
+			netif_wake_subqueue(netdev, tx_ring->queue_index);
+			adapter->restart_queue++;
+		}
+#else
 		if (netif_queue_stopped(netdev) &&
 		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
 			netif_wake_queue(netdev);
 			adapter->restart_queue++;
 		}
+#endif
 	}
 
 	if (adapter->detect_tx_hung)
 		if (ixgbe_check_tx_hang(adapter, tx_ring, eop, eop_desc))
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			netif_stop_subqueue(netdev, tx_ring->queue_index);
+#else
 			netif_stop_queue(netdev);
+#endif
 
 	if (total_tx_packets >= tx_ring->work_limit)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
@@ -1812,7 +1824,11 @@ static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 		case (IXGBE_FLAG_RSS_ENABLED):
 			rss_m = 0xF;
 			nrq = rss_i;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			ntq = rss_i;
+#else
 			ntq = 1;
+#endif
 			break;
 		case 0:
 		default:
@@ -1986,6 +2002,10 @@ try_msi:
 	}
 
 out:
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	/* Notify the stack of the (possibly) reduced Tx Queue count. */
+	adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
+#endif
 
 	return err;
 }
@@ -2504,6 +2524,9 @@ static void ixgbe_watchdog(unsigned long data)
 	struct net_device *netdev = adapter->netdev;
 	bool link_up;
 	u32 link_speed = 0;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	int i;
+#endif
 
 	adapter->hw.mac.ops.check_link(&adapter->hw, &(link_speed), &link_up);
 
@@ -2525,6 +2548,10 @@ static void ixgbe_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				netif_wake_subqueue(netdev, i);
+#endif
 		} else {
 			/* Force detection of hung controller */
 			adapter->detect_tx_hung = true;
@@ -2568,7 +2595,6 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	u32 vlan_macip_lens = 0, type_tucmd_mlhl = 0;
 	u32 mss_l4len_idx = 0, l4len;
-	*hdr_len = 0;
 
 	if (skb_is_gso(skb)) {
 		if (skb_header_cloned(skb)) {
@@ -2852,7 +2878,11 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netif_stop_subqueue(netdev, tx_ring->queue_index);
+#else
 	netif_stop_queue(netdev);
+#endif
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -2864,7 +2894,11 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netif_wake_subqueue(netdev, tx_ring->queue_index);
+#else
 	netif_wake_queue(netdev);
+#endif
 	++adapter->restart_queue;
 	return 0;
 }
@@ -2885,15 +2919,18 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int len = skb->len;
 	unsigned int first;
 	unsigned int tx_flags = 0;
-	u8 hdr_len;
-	int tso;
+	u8 hdr_len = 0;
+	int r_idx = 0, tso;
 	unsigned int mss = 0;
 	int count = 0;
 	unsigned int f;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	len -= skb->data_len;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	r_idx = (adapter->num_tx_queues - 1) & skb->queue_mapping;
+#endif
+	tx_ring = &adapter->tx_ring[r_idx];
 
-	tx_ring = adapter->tx_ring;
 
 	if (skb->len <= 0) {
 		dev_kfree_skb(skb);
@@ -3078,7 +3115,11 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_QUEUES);
+#else
 	netdev = alloc_etherdev(sizeof(struct ixgbe_adapter));
+#endif
 	if (!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
@@ -3164,6 +3205,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netdev->features |= NETIF_F_MULTI_QUEUE;
+#endif
 
 	/* make sure the EEPROM is good */
 	if (ixgbe_validate_eeprom_checksum(hw, NULL) < 0) {
@@ -3231,6 +3275,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		netif_stop_subqueue(netdev, i);
+#endif
 
 	ixgbe_napi_add_all(adapter);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
