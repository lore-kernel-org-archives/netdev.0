From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 16/18] igb: add support for in kernel
	LRO
Date: Fri, 27 Jun 2008 11:01:55 -0700
Message-ID: <20080627180152.22428.61187.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
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

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for the use of the inet_lro module to provide
software LRO support.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig           |    9 +++
 drivers/net/igb/e1000_82575.h |    2 +
 drivers/net/igb/igb.h         |   16 ++++++
 drivers/net/igb/igb_ethtool.c |   17 ++++++
 drivers/net/igb/igb_main.c    |  115 +++++++++++++++++++++++++++++++++++++----
 5 files changed, 149 insertions(+), 10 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 287d087..d782b28 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2059,6 +2059,15 @@ config IGB
          To compile this driver as a module, choose M here. The module
          will be called igb.
 
+config IGB_LRO 
+	bool "Use software LRO"
+	depends on IGB && INET
+	select INET_LRO
+	---help---
+	  Say Y here if you want to use large receive offload. 
+
+	  If in doubt, say N.
+
 source "drivers/net/ixp2000/Kconfig"
 
 config MYRI_SBUS
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index d273236..2f848e5 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -99,6 +99,8 @@ union e1000_adv_rx_desc {
 /* RSS Hash results */
 
 /* RSS Packet Types as indicated in the receive descriptor */
+#define E1000_RXDADV_PKTTYPE_IPV4        0x00000010 /* IPV4 hdr present */
+#define E1000_RXDADV_PKTTYPE_TCP         0x00000100 /* TCP hdr present */
 
 /* Transmit Descriptor - Advanced */
 union e1000_adv_tx_desc {
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index da7bbaf..270650f 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -36,6 +36,12 @@
 
 struct igb_adapter;
 
+#ifdef CONFIG_IGB_LRO
+#include <linux/inet_lro.h>
+#define MAX_LRO_AGGR                      32
+#define MAX_LRO_DESCRIPTORS                8
+#endif
+
 /* Interrupt defines */
 #define IGB_MAX_TX_CLEAN 72
 
@@ -167,6 +173,10 @@ struct igb_ring {
 			int no_itr_adjust;
 			struct igb_queue_stats rx_stats;
 			struct napi_struct napi;
+#ifdef CONFIG_IGB_LRO
+			struct net_lro_mgr lro_mgr;
+			bool lro_used;
+#endif
 		};
 	};
 
@@ -273,6 +283,12 @@ struct igb_adapter {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
 #endif /* CONFIG_NETDEVICES_MULTIQUEUE */
+#ifdef CONFIG_IGB_LRO
+	unsigned int lro_max_aggr;
+	unsigned int lro_aggregated;
+	unsigned int lro_flushed;
+	unsigned int lro_no_desc;
+#endif
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index ef209b5..7db1830 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -93,6 +93,11 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	{ "tx_smbus", IGB_STAT(stats.mgptc) },
 	{ "rx_smbus", IGB_STAT(stats.mgprc) },
 	{ "dropped_smbus", IGB_STAT(stats.mgpdc) },
+#ifdef CONFIG_IGB_LRO
+	{ "lro_aggregated", IGB_STAT(lro_aggregated) },
+	{ "lro_flushed", IGB_STAT(lro_flushed) },
+	{ "lro_no_desc", IGB_STAT(lro_no_desc) },
+#endif
 };
 
 #define IGB_QUEUE_STATS_LEN \
@@ -1917,6 +1922,18 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 	int stat_count = sizeof(struct igb_queue_stats) / sizeof(u64);
 	int j;
 	int i;
+#ifdef CONFIG_IGB_LRO
+	int aggregated = 0, flushed = 0, no_desc = 0;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		aggregated += adapter->rx_ring[i].lro_mgr.stats.aggregated;
+		flushed += adapter->rx_ring[i].lro_mgr.stats.flushed;
+		no_desc += adapter->rx_ring[i].lro_mgr.stats.no_desc;
+	}
+	adapter->lro_aggregated = aggregated;
+	adapter->lro_flushed = flushed;
+	adapter->lro_no_desc = no_desc;
+#endif
 
 	igb_update_stats(adapter);
 	for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2b5dbc7..c43f287 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -116,6 +116,9 @@ static bool igb_clean_tx_irq(struct igb_ring *);
 static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
 static void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
+#ifdef CONFIG_IGB_LRO
+static int igb_get_skb_hdr(struct sk_buff *skb, void **, void **, u64 *, void *);
+#endif
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
@@ -1107,6 +1110,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 
+#ifdef CONFIG_IGB_LRO
+	netdev->features |= NETIF_F_LRO;
+#endif
+
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
@@ -1678,6 +1685,14 @@ int igb_setup_rx_resources(struct igb_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	int size, desc_len;
 
+#ifdef CONFIG_IGB_LRO
+	size = sizeof(struct net_lro_desc) * MAX_LRO_DESCRIPTORS;
+	rx_ring->lro_mgr.lro_arr = vmalloc(size);
+	if (!rx_ring->lro_mgr.lro_arr)
+		goto err;
+	memset(rx_ring->lro_mgr.lro_arr, 0, size);
+#endif
+
 	size = sizeof(struct igb_buffer) * rx_ring->count;
 	rx_ring->buffer_info = vmalloc(size);
 	if (!rx_ring->buffer_info)
@@ -1704,6 +1719,10 @@ int igb_setup_rx_resources(struct igb_adapter *adapter,
 	return 0;
 
 err:
+#ifdef CONFIG_IGB_LRO
+	vfree(rx_ring->lro_mgr.lro_arr);
+	rx_ring->lro_mgr.lro_arr = NULL;
+#endif
 	vfree(rx_ring->buffer_info);
 	dev_err(&adapter->pdev->dev, "Unable to allocate memory for "
 		"the receive descriptor ring\n");
@@ -1867,6 +1886,16 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 		rxdctl |= IGB_RX_HTHRESH << 8;
 		rxdctl |= IGB_RX_WTHRESH << 16;
 		wr32(E1000_RXDCTL(i), rxdctl);
+#ifdef CONFIG_IGB_LRO
+		/* Intitial LRO Settings */
+		ring->lro_mgr.max_aggr = MAX_LRO_AGGR;
+		ring->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;
+		ring->lro_mgr.get_skb_header = igb_get_skb_hdr;
+		ring->lro_mgr.features = LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
+		ring->lro_mgr.dev = adapter->netdev;
+		ring->lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
+		ring->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+#endif
 	}
 
 	if (adapter->num_rx_queues > 1) {
@@ -2058,6 +2087,11 @@ static void igb_free_rx_resources(struct igb_ring *rx_ring)
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
+#ifdef CONFIG_IGB_LRO
+	vfree(rx_ring->lro_mgr.lro_arr);
+	rx_ring->lro_mgr.lro_arr = NULL;
+#endif 
+
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
 
 	rx_ring->desc = NULL;
@@ -3708,23 +3742,77 @@ done_cleaning:
 	return retval;
 }
 
+#ifdef CONFIG_IGB_LRO
+ /**
+ * igb_get_skb_hdr - helper function for LRO header processing
+ * @skb: pointer to sk_buff to be added to LRO packet
+ * @iphdr: pointer to ip header structure
+ * @tcph: pointer to tcp header structure
+ * @hdr_flags: pointer to header flags
+ * @priv: pointer to the receive descriptor for the current sk_buff
+ **/
+static int igb_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
+                           u64 *hdr_flags, void *priv)
+{
+	union e1000_adv_rx_desc *rx_desc = priv;
+	u16 pkt_type = rx_desc->wb.lower.lo_dword.pkt_info &
+	               (E1000_RXDADV_PKTTYPE_IPV4 | E1000_RXDADV_PKTTYPE_TCP);
+
+	/* Verify that this is a valid IPv4 TCP packet */
+	if (pkt_type != (E1000_RXDADV_PKTTYPE_IPV4 |
+	                  E1000_RXDADV_PKTTYPE_TCP))
+		return -1;
+
+	/* Set network headers */
+	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, ip_hdrlen(skb));
+	*iphdr = ip_hdr(skb);
+	*tcph = tcp_hdr(skb);
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+
+	return 0;
+
+}
+#endif /* CONFIG_IGB_LRO */
 
 /**
  * igb_receive_skb - helper function to handle rx indications
- * @adapter: board private structure
+ * @ring: pointer to receive ring receving this packet 
  * @status: descriptor status field as written by hardware
  * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
  * @skb: pointer to sk_buff to be indicated to stack
  **/
-static void igb_receive_skb(struct igb_adapter *adapter, u8 status, __le16 vlan,
-			    struct sk_buff *skb)
+static void igb_receive_skb(struct igb_ring *ring, u8 status,
+                            union e1000_adv_rx_desc * rx_desc,
+                            struct sk_buff *skb)
 {
-	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
-		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-					 le16_to_cpu(vlan) &
-					 E1000_RXD_SPC_VLAN_MASK);
-	else
-		netif_receive_skb(skb);
+	struct igb_adapter * adapter = ring->adapter;
+	bool vlan_extracted = (adapter->vlgrp && (status & E1000_RXD_STAT_VP));
+
+#ifdef CONFIG_IGB_LRO
+	if (adapter->netdev->features & NETIF_F_LRO &&
+	    skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		if (vlan_extracted)
+			lro_vlan_hwaccel_receive_skb(&ring->lro_mgr, skb,
+			                             adapter->vlgrp,
+			                             le16_to_cpu(rx_desc->wb.upper.vlan) &
+			                             E1000_RXD_SPC_VLAN_MASK,
+			                             rx_desc);
+		else
+			lro_receive_skb(&ring->lro_mgr,skb, rx_desc);
+		ring->lro_used = 1;
+	} else {
+#endif
+		if (vlan_extracted)
+			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
+			                         le16_to_cpu(rx_desc->wb.upper.vlan) &
+			                         E1000_RXD_SPC_VLAN_MASK);
+		else
+
+			netif_receive_skb(skb);
+#ifdef CONFIG_IGB_LRO
+	}
+#endif
 }
 
 
@@ -3857,7 +3945,7 @@ send_up:
 
 		skb->protocol = eth_type_trans(skb, netdev);
 
-		igb_receive_skb(adapter, staterr, rx_desc->wb.upper.vlan, skb);
+		igb_receive_skb(rx_ring, staterr, rx_desc, skb);
 
 		netdev->last_rx = jiffies;
 
@@ -3880,6 +3968,13 @@ next_desc:
 	rx_ring->next_to_clean = i;
 	cleaned_count = IGB_DESC_UNUSED(rx_ring);
 
+#ifdef CONFIG_IGB_LRO
+	if (rx_ring->lro_used) {
+		lro_flush_all(&rx_ring->lro_mgr);
+		rx_ring->lro_used = 0;
+	}
+#endif
+
 	if (cleaned_count)
 		igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
