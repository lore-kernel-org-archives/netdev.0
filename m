From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/17] tg3: Create a new prodring_set structure
Date: Fri, 28 Aug 2009 17:00:25 -0700
Message-ID: <1251585285.29684@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2429 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbZH2Wev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch migrates most of the rx producer ring variables to a new
tg3_rx_prodring_set structure and modifies the code accordingly.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |  163 +++++++++++++++++++++++++++-------------------------
 drivers/net/tg3.h |   27 +++++----
 2 files changed, 100 insertions(+), 90 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5d0a1e6..053d4e8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4352,24 +4352,25 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
 	struct sk_buff *skb;
 	dma_addr_t mapping;
 	int skb_size, dest_idx;
+	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
 	src_map = NULL;
 	switch (opaque_key) {
 	case RXD_OPAQUE_RING_STD:
 		dest_idx = dest_idx_unmasked % TG3_RX_RING_SIZE;
-		desc = &tp->rx_std[dest_idx];
-		map = &tp->rx_std_buffers[dest_idx];
+		desc = &tpr->rx_std[dest_idx];
+		map = &tpr->rx_std_buffers[dest_idx];
 		if (src_idx >= 0)
-			src_map = &tp->rx_std_buffers[src_idx];
+			src_map = &tpr->rx_std_buffers[src_idx];
 		skb_size = tp->rx_pkt_map_sz;
 		break;
 
 	case RXD_OPAQUE_RING_JUMBO:
 		dest_idx = dest_idx_unmasked % TG3_RX_JUMBO_RING_SIZE;
-		desc = &tp->rx_jumbo[dest_idx];
-		map = &tp->rx_jumbo_buffers[dest_idx];
+		desc = &tpr->rx_jmb[dest_idx];
+		map = &tpr->rx_jmb_buffers[dest_idx];
 		if (src_idx >= 0)
-			src_map = &tp->rx_jumbo_buffers[src_idx];
+			src_map = &tpr->rx_jmb_buffers[src_idx];
 		skb_size = TG3_RX_JMB_MAP_SZ;
 		break;
 
@@ -4414,22 +4415,23 @@ static void tg3_recycle_rx(struct tg3 *tp, u32 opaque_key,
 	struct tg3_rx_buffer_desc *src_desc, *dest_desc;
 	struct ring_info *src_map, *dest_map;
 	int dest_idx;
+	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
 	switch (opaque_key) {
 	case RXD_OPAQUE_RING_STD:
 		dest_idx = dest_idx_unmasked % TG3_RX_RING_SIZE;
-		dest_desc = &tp->rx_std[dest_idx];
-		dest_map = &tp->rx_std_buffers[dest_idx];
-		src_desc = &tp->rx_std[src_idx];
-		src_map = &tp->rx_std_buffers[src_idx];
+		dest_desc = &tpr->rx_std[dest_idx];
+		dest_map = &tpr->rx_std_buffers[dest_idx];
+		src_desc = &tpr->rx_std[src_idx];
+		src_map = &tpr->rx_std_buffers[src_idx];
 		break;
 
 	case RXD_OPAQUE_RING_JUMBO:
 		dest_idx = dest_idx_unmasked % TG3_RX_JUMBO_RING_SIZE;
-		dest_desc = &tp->rx_jumbo[dest_idx];
-		dest_map = &tp->rx_jumbo_buffers[dest_idx];
-		src_desc = &tp->rx_jumbo[src_idx];
-		src_map = &tp->rx_jumbo_buffers[src_idx];
+		dest_desc = &tpr->rx_jmb[dest_idx];
+		dest_map = &tpr->rx_jmb_buffers[dest_idx];
+		src_desc = &tpr->rx_jmb[src_idx];
+		src_map = &tpr->rx_jmb_buffers[src_idx];
 		break;
 
 	default:
@@ -4482,6 +4484,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
 	u32 sw_idx = tp->rx_rcb_ptr;
 	u16 hw_idx;
 	int received;
+	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
 	hw_idx = tp->hw_status->idx[0].rx_producer;
 	/*
@@ -4501,20 +4504,18 @@ static int tg3_rx(struct tg3 *tp, int budget)
 		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
 		if (opaque_key == RXD_OPAQUE_RING_STD) {
-			dma_addr = pci_unmap_addr(&tp->rx_std_buffers[desc_idx],
-						  mapping);
-			skb = tp->rx_std_buffers[desc_idx].skb;
-			post_ptr = &tp->rx_std_ptr;
+			struct ring_info *ri = &tpr->rx_std_buffers[desc_idx];
+			dma_addr = pci_unmap_addr(ri, mapping);
+			skb = ri->skb;
+			post_ptr = &tpr->rx_std_ptr;
 			rx_std_posted++;
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
-			dma_addr = pci_unmap_addr(&tp->rx_jumbo_buffers[desc_idx],
-						  mapping);
-			skb = tp->rx_jumbo_buffers[desc_idx].skb;
-			post_ptr = &tp->rx_jumbo_ptr;
-		}
-		else {
+			struct ring_info *ri = &tpr->rx_jmb_buffers[desc_idx];
+			dma_addr = pci_unmap_addr(ri, mapping);
+			skb = ri->skb;
+			post_ptr = &tpr->rx_jmb_ptr;
+		} else
 			goto next_pkt_nopost;
-		}
 
 		work_mask |= opaque_key;
 
@@ -4627,12 +4628,12 @@ next_pkt_nopost:
 
 	/* Refill RX ring(s). */
 	if (work_mask & RXD_OPAQUE_RING_STD) {
-		sw_idx = tp->rx_std_ptr % TG3_RX_RING_SIZE;
+		sw_idx = tpr->rx_std_ptr % TG3_RX_RING_SIZE;
 		tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
 			     sw_idx);
 	}
 	if (work_mask & RXD_OPAQUE_RING_JUMBO) {
-		sw_idx = tp->rx_jumbo_ptr % TG3_RX_JUMBO_RING_SIZE;
+		sw_idx = tpr->rx_jmb_ptr % TG3_RX_JUMBO_RING_SIZE;
 		tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
 			     sw_idx);
 	}
@@ -5517,13 +5518,14 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 	return err;
 }
 
-static void tg3_rx_prodring_free(struct tg3 *tp)
+static void tg3_rx_prodring_free(struct tg3 *tp,
+				 struct tg3_rx_prodring_set *tpr)
 {
 	struct ring_info *rxp;
 	int i;
 
 	for (i = 0; i < TG3_RX_RING_SIZE; i++) {
-		rxp = &tp->rx_std_buffers[i];
+		rxp = &tpr->rx_std_buffers[i];
 
 		if (rxp->skb == NULL)
 			continue;
@@ -5538,7 +5540,7 @@ static void tg3_rx_prodring_free(struct tg3 *tp)
 
 	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
 		for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
-			rxp = &tp->rx_jumbo_buffers[i];
+			rxp = &tpr->rx_jmb_buffers[i];
 
 			if (rxp->skb == NULL)
 				continue;
@@ -5560,12 +5562,13 @@ static void tg3_rx_prodring_free(struct tg3 *tp)
  * end up in the driver.  tp->{tx,}lock are held and thus
  * we may not sleep.
  */
-static int tg3_rx_prodring_alloc(struct tg3 *tp)
+static int tg3_rx_prodring_alloc(struct tg3 *tp,
+				 struct tg3_rx_prodring_set *tpr)
 {
 	u32 i, rx_pkt_dma_sz;
 
 	/* Zero out all descriptors. */
-	memset(tp->rx_std, 0, TG3_RX_RING_BYTES);
+	memset(tpr->rx_std, 0, TG3_RX_RING_BYTES);
 
 	rx_pkt_dma_sz = TG3_RX_STD_DMA_SZ;
 	if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) &&
@@ -5580,7 +5583,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp)
 	for (i = 0; i < TG3_RX_RING_SIZE; i++) {
 		struct tg3_rx_buffer_desc *rxd;
 
-		rxd = &tp->rx_std[i];
+		rxd = &tpr->rx_std[i];
 		rxd->idx_len = rx_pkt_dma_sz << RXD_LEN_SHIFT;
 		rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT);
 		rxd->opaque = (RXD_OPAQUE_RING_STD |
@@ -5605,13 +5608,13 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp)
 	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE))
 		goto done;
 
-	memset(tp->rx_jumbo, 0, TG3_RX_JUMBO_RING_BYTES);
+	memset(tpr->rx_jmb, 0, TG3_RX_JUMBO_RING_BYTES);
 
 	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
 		for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
 			struct tg3_rx_buffer_desc *rxd;
 
-			rxd = &tp->rx_jumbo[i];
+			rxd = &tpr->rx_jmb[i];
 			rxd->idx_len = TG3_RX_JMB_DMA_SZ << RXD_LEN_SHIFT;
 			rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT) |
 				RXD_FLAG_JUMBO;
@@ -5639,58 +5642,60 @@ done:
 	return 0;
 
 initfail:
-	tg3_rx_prodring_free(tp);
+	tg3_rx_prodring_free(tp, tpr);
 	return -ENOMEM;
 }
 
-static void tg3_rx_prodring_fini(struct tg3 *tp)
+static void tg3_rx_prodring_fini(struct tg3 *tp,
+				 struct tg3_rx_prodring_set *tpr)
 {
-	kfree(tp->rx_std_buffers);
-	tp->rx_std_buffers = NULL;
-	kfree(tp->rx_jumbo_buffers);
-	tp->rx_jumbo_buffers = NULL;
-	if (tp->rx_std) {
+	kfree(tpr->rx_std_buffers);
+	tpr->rx_std_buffers = NULL;
+	kfree(tpr->rx_jmb_buffers);
+	tpr->rx_jmb_buffers = NULL;
+	if (tpr->rx_std) {
 		pci_free_consistent(tp->pdev, TG3_RX_RING_BYTES,
-				    tp->rx_std, tp->rx_std_mapping);
-		tp->rx_std = NULL;
+				    tpr->rx_std, tpr->rx_std_mapping);
+		tpr->rx_std = NULL;
 	}
-	if (tp->rx_jumbo) {
+	if (tpr->rx_jmb) {
 		pci_free_consistent(tp->pdev, TG3_RX_JUMBO_RING_BYTES,
-				    tp->rx_jumbo, tp->rx_jumbo_mapping);
-		tp->rx_jumbo = NULL;
+				    tpr->rx_jmb, tpr->rx_jmb_mapping);
+		tpr->rx_jmb = NULL;
 	}
 }
 
-static int tg3_rx_prodring_init(struct tg3 *tp)
+static int tg3_rx_prodring_init(struct tg3 *tp,
+				struct tg3_rx_prodring_set *tpr)
 {
-	tp->rx_std_buffers = kzalloc(sizeof(struct ring_info) *
-				     TG3_RX_RING_SIZE, GFP_KERNEL);
-	if (!tp->rx_std_buffers)
+	tpr->rx_std_buffers = kzalloc(sizeof(struct ring_info) *
+				      TG3_RX_RING_SIZE, GFP_KERNEL);
+	if (!tpr->rx_std_buffers)
 		return -ENOMEM;
 
-	tp->rx_std = pci_alloc_consistent(tp->pdev, TG3_RX_RING_BYTES,
-					  &tp->rx_std_mapping);
-	if (!tp->rx_std)
+	tpr->rx_std = pci_alloc_consistent(tp->pdev, TG3_RX_RING_BYTES,
+					   &tpr->rx_std_mapping);
+	if (!tpr->rx_std)
 		goto err_out;
 
 	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
-		tp->rx_jumbo_buffers = kzalloc(sizeof(struct ring_info) *
-					       TG3_RX_JUMBO_RING_SIZE,
-					       GFP_KERNEL);
-		if (!tp->rx_jumbo_buffers)
+		tpr->rx_jmb_buffers = kzalloc(sizeof(struct ring_info) *
+					      TG3_RX_JUMBO_RING_SIZE,
+					      GFP_KERNEL);
+		if (!tpr->rx_jmb_buffers)
 			goto err_out;
 
-		tp->rx_jumbo = pci_alloc_consistent(tp->pdev,
-						    TG3_RX_JUMBO_RING_BYTES,
-						    &tp->rx_jumbo_mapping);
-		if (!tp->rx_jumbo)
+		tpr->rx_jmb = pci_alloc_consistent(tp->pdev,
+						   TG3_RX_JUMBO_RING_BYTES,
+						   &tpr->rx_jmb_mapping);
+		if (!tpr->rx_jmb)
 			goto err_out;
 	}
 
 	return 0;
 
 err_out:
-	tg3_rx_prodring_fini(tp);
+	tg3_rx_prodring_fini(tp, tpr);
 	return -ENOMEM;
 }
 
@@ -5726,7 +5731,7 @@ static void tg3_free_rings(struct tg3 *tp)
 		dev_kfree_skb_any(skb);
 	}
 
-	tg3_rx_prodring_free(tp);
+	tg3_rx_prodring_free(tp, &tp->prodring[0]);
 }
 
 /* Initialize tx/rx rings for packet processing.
@@ -5745,7 +5750,7 @@ static int tg3_init_rings(struct tg3 *tp)
 	memset(tp->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 	memset(tp->tx_ring, 0, TG3_TX_RING_BYTES);
 
-	return tg3_rx_prodring_alloc(tp);
+	return tg3_rx_prodring_alloc(tp, &tp->prodring[0]);
 }
 
 /*
@@ -5776,7 +5781,7 @@ static void tg3_free_consistent(struct tg3 *tp)
 				    tp->hw_stats, tp->stats_mapping);
 		tp->hw_stats = NULL;
 	}
-	tg3_rx_prodring_fini(tp);
+	tg3_rx_prodring_fini(tp, &tp->prodring[0]);
 }
 
 /*
@@ -5785,7 +5790,7 @@ static void tg3_free_consistent(struct tg3 *tp)
  */
 static int tg3_alloc_consistent(struct tg3 *tp)
 {
-	if (tg3_rx_prodring_init(tp))
+	if (tg3_rx_prodring_init(tp, &tp->prodring[0]))
 		return -ENOMEM;
 
 	tp->tx_buffers = kzalloc(sizeof(struct tx_ring_info) *
@@ -6794,6 +6799,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 {
 	u32 val, rdmac_mode;
 	int i, err, limit;
+	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
 	tg3_disable_ints(tp);
 
@@ -7022,9 +7028,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	 * configurable.
 	 */
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH,
-	     ((u64) tp->rx_std_mapping >> 32));
+	     ((u64) tpr->rx_std_mapping >> 32));
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
-	     ((u64) tp->rx_std_mapping & 0xffffffff));
+	     ((u64) tpr->rx_std_mapping & 0xffffffff));
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
 	     NIC_SRAM_RX_BUFFER_DESC);
 
@@ -7043,9 +7049,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 		if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH,
-			     ((u64) tp->rx_jumbo_mapping >> 32));
+			     ((u64) tpr->rx_jmb_mapping >> 32));
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
-			     ((u64) tp->rx_jumbo_mapping & 0xffffffff));
+			     ((u64) tpr->rx_jmb_mapping & 0xffffffff));
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
 			     RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT);
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
@@ -7102,14 +7108,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			BDINFO_FLAGS_MAXLEN_SHIFT),
 		       0);
 
-	tp->rx_std_ptr = tp->rx_pending;
+	tpr->rx_std_ptr = tp->rx_pending;
 	tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
-		     tp->rx_std_ptr);
+		     tpr->rx_std_ptr);
 
-	tp->rx_jumbo_ptr = (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) ?
-						tp->rx_jumbo_pending : 0;
+	tpr->rx_jmb_ptr = (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) ?
+			  tp->rx_jumbo_pending : 0;
 	tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
-		     tp->rx_jumbo_ptr);
+		     tpr->rx_jmb_ptr);
 
 	/* Initialize MAC address and backoff seed. */
 	__tg3_set_mac_addr(tp, 0);
@@ -9815,6 +9821,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	dma_addr_t map;
 	int num_pkts, tx_len, rx_len, i, err;
 	struct tg3_rx_buffer_desc *desc;
+	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
 	if (loopback_mode == TG3_MAC_LOOPBACK) {
 		/* HW errata - mac loopback fails in some cases on 5780.
@@ -9949,9 +9956,9 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	if (rx_len != tx_len)
 		goto out;
 
-	rx_skb = tp->rx_std_buffers[desc_idx].skb;
+	rx_skb = tpr->rx_std_buffers[desc_idx].skb;
 
-	map = pci_unmap_addr(&tp->rx_std_buffers[desc_idx], mapping);
+	map = pci_unmap_addr(&tpr->rx_std_buffers[desc_idx], mapping);
 	pci_dma_sync_single_for_cpu(tp->pdev, map, rx_len, PCI_DMA_FROMDEVICE);
 
 	for (i = 14; i < tx_len; i++) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d029b4b..7a27cff 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2476,6 +2476,17 @@ struct tg3_ethtool_stats {
 	u64		nic_tx_threshold_hit;
 };
 
+struct tg3_rx_prodring_set {
+	u32				rx_std_ptr;
+	u32				rx_jmb_ptr;
+	struct tg3_rx_buffer_desc	*rx_std;
+	struct tg3_rx_buffer_desc	*rx_jmb;
+	struct ring_info		*rx_std_buffers;
+	struct ring_info		*rx_jmb_buffers;
+	dma_addr_t			rx_std_mapping;
+	dma_addr_t			rx_jmb_mapping;
+};
+
 struct tg3 {
 	/* begin "general, frequently-used members" cacheline section */
 
@@ -2551,27 +2562,19 @@ struct tg3 {
 	void				(*write32_rx_mbox) (struct tg3 *, u32,
 							    u32);
 	u32				rx_rcb_ptr;
-	u32				rx_std_ptr;
-	u32				rx_jumbo_ptr;
 	u32				rx_pending;
 	u32				rx_jumbo_pending;
+	u32				rx_std_max_post;
+	u32				rx_pkt_map_sz;
 #if TG3_VLAN_TAG_USED
 	struct vlan_group		*vlgrp;
 #endif
 
-	struct tg3_rx_buffer_desc	*rx_std;
-	struct ring_info		*rx_std_buffers;
-	dma_addr_t			rx_std_mapping;
-	u32				rx_std_max_post;
-
-	struct tg3_rx_buffer_desc	*rx_jumbo;
-	struct ring_info		*rx_jumbo_buffers;
-	dma_addr_t			rx_jumbo_mapping;
-
 	struct tg3_rx_buffer_desc	*rx_rcb;
 	dma_addr_t			rx_rcb_mapping;
 
-	u32				rx_pkt_map_sz;
+	struct tg3_rx_prodring_set	prodring[1];
+
 
 	/* begin "everything else" cacheline(s) section */
 	struct net_device_stats		net_stats;
-- 
1.6.3.3


