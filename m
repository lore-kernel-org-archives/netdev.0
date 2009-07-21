From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [net-next-2.6 PATCH][be2net] Add GRO support to the be2net driver.
	LRO is not supported anymore.
Date: Tue, 21 Jul 2009 17:37:11 +0530
Message-ID: <20090721120701.GA7570@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:19309 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754380AbZGUMHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 08:07:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch removes support for INET_LRO and switches over to GRO.
Please accept.

-Ajit

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/Kconfig      |    1 -
 drivers/net/benet/be.h         |   11 +----
 drivers/net/benet/be_ethtool.c |    9 +---
 drivers/net/benet/be_main.c    |  104 +++++++++++-----------------------------
 4 files changed, 31 insertions(+), 94 deletions(-)

diff --git a/drivers/net/benet/Kconfig b/drivers/net/benet/Kconfig
index c6934f1..fdb6e81 100644
--- a/drivers/net/benet/Kconfig
+++ b/drivers/net/benet/Kconfig
@@ -1,7 +1,6 @@
 config BE2NET
 	tristate "ServerEngines' 10Gbps NIC - BladeEngine 2"
 	depends on PCI && INET
-	select INET_LRO
 	help
 	This driver implements the NIC functionality for ServerEngines'
 	10Gbps network adapter - BladeEngine 2.
diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 5b4bf3d..41cddbe 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -28,11 +28,10 @@
 #include <linux/if_vlan.h>
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
-#include <linux/inet_lro.h>
 
 #include "be_hw.h"
 
-#define DRV_VER			"2.0.348"
+#define DRV_VER			"2.0.400"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define OC_NAME			"Emulex OneConnect 10Gbps NIC"
@@ -72,9 +71,6 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MAX_RX_POST 		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
 
-#define BE_MAX_LRO_DESCRIPTORS  16
-#define BE_MAX_FRAGS_PER_FRAME  (min((u32) 16, (u32) MAX_SKB_FRAGS))
-
 struct be_dma_mem {
 	void *va;
 	dma_addr_t dma;
@@ -189,8 +185,6 @@ struct be_drvr_stats {
 	u32 be_polls;		/* number of times NAPI called poll function */
 	u32 be_rx_events;	/* number of ucast rx completion events  */
 	u32 be_rx_compl;	/* number of rx completion entries processed */
-	u32 be_lro_hgram_data[8];	/* histogram of LRO data packets */
-	u32 be_lro_hgram_ack[8];	/* histogram of LRO ACKs */
 	ulong be_rx_jiffies;
 	u64 be_rx_bytes;
 	u64 be_rx_bytes_prev;
@@ -233,8 +227,6 @@ struct be_rx_obj {
 	struct be_queue_info q;
 	struct be_queue_info cq;
 	struct be_rx_page_info page_info_tbl[RX_Q_LEN];
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[BE_MAX_LRO_DESCRIPTORS];
 };
 
 #define BE_NUM_MSIX_VECTORS		2	/* 1 each for Tx and Rx */
@@ -271,7 +263,6 @@ struct be_adapter {
 
 	/* Ethtool knobs and info */
 	bool rx_csum; 		/* BE card must perform rx-checksumming */
-	u32 max_rx_coal;
 	char fw_ver[FW_VER_LEN];
 	u32 if_handle;		/* Used to configure filtering */
 	u32 pmac_id;		/* MAC addr handle used by BE card */
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index cccc541..f3f0f91 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -127,8 +127,6 @@ be_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 	struct be_eq_obj *rx_eq = &adapter->rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 
-	coalesce->rx_max_coalesced_frames = adapter->max_rx_coal;
-
 	coalesce->rx_coalesce_usecs = rx_eq->cur_eqd;
 	coalesce->rx_coalesce_usecs_high = rx_eq->max_eqd;
 	coalesce->rx_coalesce_usecs_low = rx_eq->min_eqd;
@@ -144,8 +142,7 @@ be_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 }
 
 /*
- * This routine is used to set interrup coalescing delay *as well as*
- * the number of pkts to coalesce for LRO.
+ * This routine is used to set interrup coalescing delay
  */
 static int
 be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
@@ -161,10 +158,6 @@ be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 	if (coalesce->use_adaptive_tx_coalesce == 1)
 		return -EINVAL;
 
-	adapter->max_rx_coal = coalesce->rx_max_coalesced_frames;
-	if (adapter->max_rx_coal > BE_MAX_FRAGS_PER_FRAME)
-		adapter->max_rx_coal = BE_MAX_FRAGS_PER_FRAME;
-
 	/* if AIC is being turned on now, start with an EQD of 0 */
 	if (rx_eq->enable_aic == 0 &&
 		coalesce->use_adaptive_rx_coalesce == 1) {
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c43f6a1..45df8e2 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -742,7 +742,7 @@ done:
 	return;
 }
 
-/* Process the RX completion indicated by rxcp when LRO is disabled */
+/* Process the RX completion indicated by rxcp when GRO is disabled */
 static void be_rx_compl_process(struct be_adapter *adapter,
 			struct be_eth_rx_compl *rxcp)
 {
@@ -789,13 +789,14 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	return;
 }
 
-/* Process the RX completion indicated by rxcp when LRO is enabled */
-static void be_rx_compl_process_lro(struct be_adapter *adapter,
+/* Process the RX completion indicated by rxcp when GRO is enabled */
+static void be_rx_compl_process_gro(struct be_adapter *adapter,
 			struct be_eth_rx_compl *rxcp)
 {
 	struct be_rx_page_info *page_info;
-	struct skb_frag_struct rx_frags[BE_MAX_FRAGS_PER_FRAME];
+	struct sk_buff *skb = NULL;
 	struct be_queue_info *rxq = &adapter->rx_obj.q;
+	struct be_eq_obj *eq_obj =  &adapter->rx_eq;
 	u32 num_rcvd, pkt_size, remaining, vlanf, curr_frag_len;
 	u16 i, rxq_idx = 0, vid, j;
 
@@ -804,6 +805,12 @@ static void be_rx_compl_process_lro(struct be_adapter *adapter,
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
 
+	skb = napi_get_frags(&eq_obj->napi);
+	if (!skb) {
+		be_rx_compl_discard(adapter, rxcp);
+		return;
+	}
+
 	remaining = pkt_size;
 	for (i = 0, j = -1; i < num_rcvd; i++) {
 		page_info = get_rx_page_info(adapter, rxq_idx);
@@ -814,13 +821,14 @@ static void be_rx_compl_process_lro(struct be_adapter *adapter,
 		if (i == 0 || page_info->page_offset == 0) {
 			/* First frag or Fresh page */
 			j++;
-			rx_frags[j].page = page_info->page;
-			rx_frags[j].page_offset = page_info->page_offset;
-			rx_frags[j].size = 0;
+			skb_shinfo(skb)->frags[j].page = page_info->page;
+			skb_shinfo(skb)->frags[j].page_offset =
+							page_info->page_offset;
+			skb_shinfo(skb)->frags[j].size = 0;
 		} else {
 			put_page(page_info->page);
 		}
-		rx_frags[j].size += curr_frag_len;
+		skb_shinfo(skb)->frags[j].size += curr_frag_len;
 
 		remaining -= curr_frag_len;
 		index_inc(&rxq_idx, rxq->len);
@@ -828,9 +836,14 @@ static void be_rx_compl_process_lro(struct be_adapter *adapter,
 	}
 	BUG_ON(j > MAX_SKB_FRAGS);
 
+	skb_shinfo(skb)->nr_frags = j + 1;
+	skb->len = pkt_size;
+	skb->data_len = pkt_size;
+	skb->truesize += pkt_size;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
 	if (likely(!vlanf)) {
-		lro_receive_frags(&adapter->rx_obj.lro_mgr, rx_frags, pkt_size,
-				pkt_size, NULL, 0);
+		napi_gro_frags(&eq_obj->napi);
 	} else {
 		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
 		vid = be16_to_cpu(vid);
@@ -838,9 +851,7 @@ static void be_rx_compl_process_lro(struct be_adapter *adapter,
 		if (!adapter->vlan_grp || adapter->num_vlans == 0)
 			return;
 
-		lro_vlan_hwaccel_receive_frags(&adapter->rx_obj.lro_mgr,
-			rx_frags, pkt_size, pkt_size, adapter->vlan_grp,
-			vid, NULL, 0);
+		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, vid);
 	}
 
 	be_rx_stats_update(adapter, pkt_size, num_rcvd);
@@ -1183,7 +1194,6 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 	struct be_queue_info *eq, *q, *cq;
 	int rc;
 
-	adapter->max_rx_coal = BE_MAX_FRAGS_PER_FRAME;
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
 	adapter->rx_eq.max_eqd = BE_MAX_EQD;
 	adapter->rx_eq.min_eqd = 0;
@@ -1305,7 +1315,7 @@ static irqreturn_t be_msix_tx_mcc(int irq, void *dev)
 	return IRQ_HANDLED;
 }
 
-static inline bool do_lro(struct be_adapter *adapter,
+static inline bool do_gro(struct be_adapter *adapter,
 			struct be_eth_rx_compl *rxcp)
 {
 	int err = AMAP_GET_BITS(struct amap_eth_rx_compl, err, rxcp);
@@ -1314,8 +1324,7 @@ static inline bool do_lro(struct be_adapter *adapter,
 	if (err)
 		drvr_stats(adapter)->be_rxcp_err++;
 
-	return (!tcp_frame || err || (adapter->max_rx_coal <= 1)) ?
-		false : true;
+	return (tcp_frame && !err) ? true : false;
 }
 
 int be_poll_rx(struct napi_struct *napi, int budget)
@@ -1332,16 +1341,14 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 		if (!rxcp)
 			break;
 
-		if (do_lro(adapter, rxcp))
-			be_rx_compl_process_lro(adapter, rxcp);
+		if (do_gro(adapter, rxcp))
+			be_rx_compl_process_gro(adapter, rxcp);
 		else
 			be_rx_compl_process(adapter, rxcp);
 
 		be_rx_compl_reset(rxcp);
 	}
 
-	lro_flush_all(&adapter->rx_obj.lro_mgr);
-
 	/* Refill the queue */
 	if (atomic_read(&adapter->rx_obj.q.used) < RX_FRAGS_REFILL_WM)
 		be_post_rx_frags(adapter);
@@ -1656,57 +1663,6 @@ static int be_close(struct net_device *netdev)
 	return 0;
 }
 
-static int be_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
-				void **ip_hdr, void **tcpudp_hdr,
-				u64 *hdr_flags, void *priv)
-{
-	struct ethhdr *eh;
-	struct vlan_ethhdr *veh;
-	struct iphdr *iph;
-	u8 *va = page_address(frag->page) + frag->page_offset;
-	unsigned long ll_hlen;
-
-	prefetch(va);
-	eh = (struct ethhdr *)va;
-	*mac_hdr = eh;
-	ll_hlen = ETH_HLEN;
-	if (eh->h_proto != htons(ETH_P_IP)) {
-		if (eh->h_proto == htons(ETH_P_8021Q)) {
-			veh = (struct vlan_ethhdr *)va;
-			if (veh->h_vlan_encapsulated_proto != htons(ETH_P_IP))
-				return -1;
-
-			ll_hlen += VLAN_HLEN;
-		} else {
-			return -1;
-		}
-	}
-	*hdr_flags = LRO_IPV4;
-	iph = (struct iphdr *)(va + ll_hlen);
-	*ip_hdr = iph;
-	if (iph->protocol != IPPROTO_TCP)
-		return -1;
-	*hdr_flags |= LRO_TCP;
-	*tcpudp_hdr = (u8 *) (*ip_hdr) + (iph->ihl << 2);
-
-	return 0;
-}
-
-static void be_lro_init(struct be_adapter *adapter, struct net_device *netdev)
-{
-	struct net_lro_mgr *lro_mgr;
-
-	lro_mgr = &adapter->rx_obj.lro_mgr;
-	lro_mgr->dev = netdev;
-	lro_mgr->features = LRO_F_NAPI;
-	lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
-	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	lro_mgr->max_desc = BE_MAX_LRO_DESCRIPTORS;
-	lro_mgr->lro_arr = adapter->rx_obj.lro_desc;
-	lro_mgr->get_frag_header = be_get_frag_header;
-	lro_mgr->max_aggr = BE_MAX_FRAGS_PER_FRAME;
-}
-
 static struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
@@ -1727,7 +1683,7 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->features |= NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
 		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM;
+		NETIF_F_IPV6_CSUM | NETIF_F_GRO;
 
 	netdev->flags |= IFF_MULTICAST;
 
@@ -1737,8 +1693,6 @@ static void be_netdev_init(struct net_device *netdev)
 
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
 
-	be_lro_init(adapter, netdev);
-
 	netif_napi_add(netdev, &adapter->rx_eq.napi, be_poll_rx,
 		BE_NAPI_WEIGHT);
 	netif_napi_add(netdev, &adapter->tx_eq.napi, be_poll_tx_mcc,
-- 
1.6.0.4

