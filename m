From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ixgbe: Replace LRO with GRO
Date: Wed, 14 Jan 2009 19:44:12 +1100
Message-ID: <20090114084412.GA17393@gondor.apana.org.au>
References: <20090113092625.GA28015@gondor.apana.org.au> <20090113092828.GA28052@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34214 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752218AbZANIoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 03:44:20 -0500
Content-Disposition: inline
In-Reply-To: <20090113092828.GA28052@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

Another day, another driver.

This one's pretty simple, there is some netpoll bogosity around
with the switch to netif_rx but at least it's harmless.

ixgbe: Replace LRO with GRO

This patch makes igb invoke the GRO hooks instead of LRO.  As
GRO has a compatible external interface to LRO this is a very
straightforward replacement.

As GRO uses the napi structure to track the held packets, I've
modified the code paths involved to pass that along.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index e112008..6ac361a 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -31,7 +31,6 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
-#include <linux/inet_lro.h>
 #include <linux/aer.h>
 
 #include "ixgbe_type.h"
@@ -88,9 +87,6 @@
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK   0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
-#define IXGBE_MAX_LRO_DESCRIPTORS       8
-#define IXGBE_MAX_LRO_AGGREGATE         32
-
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
@@ -142,8 +138,6 @@ struct ixgbe_ring {
 	/* cpu for tx queue */
 	int cpu;
 #endif
-	struct net_lro_mgr lro_mgr;
-	bool lro_used;
 	struct ixgbe_queue_stats stats;
 	u16 v_idx; /* maps directly to the index for this ring in the hardware
 	           * vector array, can also be used for finding the bit in EICR
@@ -301,9 +295,6 @@ struct ixgbe_adapter {
 
 	unsigned long state;
 	u64 tx_busy;
-	u64 lro_aggregated;
-	u64 lro_flushed;
-	u64 lro_no_desc;
 	unsigned int tx_ring_count;
 	unsigned int rx_ring_count;
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 67f87a7..4f6b5df 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -89,8 +89,6 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
-	{"lro_aggregated", IXGBE_STAT(lro_aggregated)},
-	{"lro_flushed", IXGBE_STAT(lro_flushed)},
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
@@ -808,15 +806,6 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	int stat_count = sizeof(struct ixgbe_queue_stats) / sizeof(u64);
 	int j, k;
 	int i;
-	u64 aggregated = 0, flushed = 0, no_desc = 0;
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		aggregated += adapter->rx_ring[i].lro_mgr.stats.aggregated;
-		flushed += adapter->rx_ring[i].lro_mgr.stats.flushed;
-		no_desc += adapter->rx_ring[i].lro_mgr.stats.no_desc;
-	}
-	adapter->lro_aggregated = aggregated;
-	adapter->lro_flushed = flushed;
-	adapter->lro_no_desc = no_desc;
 
 	ixgbe_update_stats(adapter);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index acef3c6..23f25fe 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -400,23 +400,20 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
  * @rx_ring: rx descriptor ring (for a specific queue) to setup
  * @rx_desc: rx descriptor
  **/
-static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
+static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
                               struct sk_buff *skb, u8 status,
-                              struct ixgbe_ring *ring,
                               union ixgbe_adv_rx_desc *rx_desc)
 {
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct napi_struct *napi = &q_vector->napi;
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	if (adapter->netdev->features & NETIF_F_LRO &&
-	    skb->ip_summed == CHECKSUM_UNNECESSARY) {
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (adapter->vlgrp && is_vlan && (tag != 0))
-			lro_vlan_hwaccel_receive_skb(&ring->lro_mgr, skb,
-			                             adapter->vlgrp, tag,
-			                             rx_desc);
+			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
 		else
-			lro_receive_skb(&ring->lro_mgr, skb, rx_desc);
-		ring->lro_used = true;
+			napi_gro_receive(napi, skb);
 	} else {
 		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 			if (adapter->vlgrp && is_vlan && (tag != 0))
@@ -571,10 +568,11 @@ static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
 	return rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
 }
 
-static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
+static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
                                struct ixgbe_ring *rx_ring,
                                int *work_done, int work_to_do)
 {
+	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
@@ -675,7 +673,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 		total_rx_packets++;
 
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
-		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc);
+		ixgbe_receive_skb(q_vector, skb, staterr, rx_desc);
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
@@ -693,11 +691,6 @@ next_desc:
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
-	if (rx_ring->lro_used) {
-		lro_flush_all(&rx_ring->lro_mgr);
-		rx_ring->lro_used = false;
-	}
-
 	rx_ring->next_to_clean = i;
 	cleaned_count = IXGBE_DESC_UNUSED(rx_ring);
 
@@ -1049,7 +1042,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 		ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
 
-	ixgbe_clean_rx_irq(adapter, rx_ring, &work_done, budget);
+	ixgbe_clean_rx_irq(q_vector, rx_ring, &work_done, budget);
 
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
@@ -1092,7 +1085,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
-		ixgbe_clean_rx_irq(adapter, rx_ring, &work_done, budget);
+		ixgbe_clean_rx_irq(q_vector, rx_ring, &work_done, budget);
 		enable_mask |= rx_ring->v_idx;
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
 		                      r_idx + 1);
@@ -1565,33 +1558,6 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }
 
-/**
- * ixgbe_get_skb_hdr - helper function for LRO header processing
- * @skb: pointer to sk_buff to be added to LRO packet
- * @iphdr: pointer to ip header structure
- * @tcph: pointer to tcp header structure
- * @hdr_flags: pointer to header flags
- * @priv: private data
- **/
-static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
-                             u64 *hdr_flags, void *priv)
-{
-	union ixgbe_adv_rx_desc *rx_desc = priv;
-
-	/* Verify that this is a valid IPv4 TCP packet */
-	if (!((ixgbe_get_pkt_info(rx_desc) & IXGBE_RXDADV_PKTTYPE_IPV4) &&
-	     (ixgbe_get_pkt_info(rx_desc) & IXGBE_RXDADV_PKTTYPE_TCP)))
-		return -1;
-
-	/* Set network headers */
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, ip_hdrlen(skb));
-	*iphdr = ip_hdr(skb);
-	*tcph = tcp_hdr(skb);
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-	return 0;
-}
-
 #define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
                            (((S) & (PAGE_SIZE - 1)) ? 1 : 0))
 
@@ -1663,16 +1629,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].head = IXGBE_RDH(j);
 		adapter->rx_ring[i].tail = IXGBE_RDT(j);
 		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
-		/* Intitial LRO Settings */
-		adapter->rx_ring[i].lro_mgr.max_aggr = IXGBE_MAX_LRO_AGGREGATE;
-		adapter->rx_ring[i].lro_mgr.max_desc = IXGBE_MAX_LRO_DESCRIPTORS;
-		adapter->rx_ring[i].lro_mgr.get_skb_header = ixgbe_get_skb_hdr;
-		adapter->rx_ring[i].lro_mgr.features = LRO_F_EXTRACT_VLAN_ID;
-		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-			adapter->rx_ring[i].lro_mgr.features |= LRO_F_NAPI;
-		adapter->rx_ring[i].lro_mgr.dev = adapter->netdev;
-		adapter->rx_ring[i].lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
-		adapter->rx_ring[i].lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 
 		ixgbe_configure_srrctl(adapter, j);
 	}
@@ -2303,7 +2259,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 #endif
 
 	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
-	ixgbe_clean_rx_irq(adapter, adapter->rx_ring, &work_done, budget);
+	ixgbe_clean_rx_irq(q_vector, adapter->rx_ring, &work_done, budget);
 
 	if (tx_cleaned)
 		work_done = budget;
@@ -2919,12 +2875,6 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
-	size = sizeof(struct net_lro_desc) * IXGBE_MAX_LRO_DESCRIPTORS;
-	rx_ring->lro_mgr.lro_arr = vmalloc(size);
-	if (!rx_ring->lro_mgr.lro_arr)
-		return -ENOMEM;
-	memset(rx_ring->lro_mgr.lro_arr, 0, size);
-
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
 	rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info) {
@@ -2953,8 +2903,6 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	return 0;
 
 alloc_failed:
-	vfree(rx_ring->lro_mgr.lro_arr);
-	rx_ring->lro_mgr.lro_arr = NULL;
 	return -ENOMEM;
 }
 
@@ -3032,9 +2980,6 @@ void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
 {
 	struct pci_dev *pdev = adapter->pdev;
 
-	vfree(rx_ring->lro_mgr.lro_arr);
-	rx_ring->lro_mgr.lro_arr = NULL;
-
 	ixgbe_clean_rx_ring(adapter, rx_ring);
 
 	vfree(rx_ring->rx_buffer_info);
@@ -4136,7 +4081,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
-	netdev->features |= NETIF_F_LRO;
+	netdev->features |= NETIF_F_GRO;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
