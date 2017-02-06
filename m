From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 05/12] bnxt_en: Add RX page mode support.
Date: Mon,  6 Feb 2017 16:55:36 -0500
Message-ID: <1486418143-8958-6-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35763 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752091AbdBFV4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:10 -0500
Received: by mail-pf0-f173.google.com with SMTP id f144so26939140pfa.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:04 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This mode is to support XDP.  In this mode, each rx ring is configured
with page sized buffers for linear placement of each packet.  MTU will be
restricted to what the page sized buffers can support.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 135 ++++++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |   7 ++
 2 files changed, 124 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c0f2167..0bcd465 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -573,6 +573,25 @@ static void bnxt_tx_int(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 	}
 }
 
+static struct page *__bnxt_alloc_rx_page(struct bnxt *bp, dma_addr_t *mapping,
+					 gfp_t gfp)
+{
+	struct device *dev = &bp->pdev->dev;
+	struct page *page;
+
+	page = alloc_page(gfp);
+	if (!page)
+		return NULL;
+
+	*mapping = dma_map_page(dev, page, 0, PAGE_SIZE, bp->rx_dir);
+	if (dma_mapping_error(dev, *mapping)) {
+		__free_page(page);
+		return NULL;
+	}
+	*mapping += bp->rx_dma_offset;
+	return page;
+}
+
 static inline u8 *__bnxt_alloc_rx_data(struct bnxt *bp, dma_addr_t *mapping,
 				       gfp_t gfp)
 {
@@ -599,19 +618,28 @@ static inline int bnxt_alloc_rx_data(struct bnxt *bp,
 {
 	struct rx_bd *rxbd = &rxr->rx_desc_ring[RX_RING(prod)][RX_IDX(prod)];
 	struct bnxt_sw_rx_bd *rx_buf = &rxr->rx_buf_ring[prod];
-	u8 *data;
 	dma_addr_t mapping;
 
-	data = __bnxt_alloc_rx_data(bp, &mapping, gfp);
-	if (!data)
-		return -ENOMEM;
+	if (BNXT_RX_PAGE_MODE(bp)) {
+		struct page *page = __bnxt_alloc_rx_page(bp, &mapping, gfp);
 
-	rx_buf->data = data;
-	rx_buf->data_ptr = data + bp->rx_offset;
+		if (!page)
+			return -ENOMEM;
+
+		rx_buf->data = page;
+		rx_buf->data_ptr = page_address(page) + bp->rx_offset;
+	} else {
+		u8 *data = __bnxt_alloc_rx_data(bp, &mapping, gfp);
+
+		if (!data)
+			return -ENOMEM;
+
+		rx_buf->data = data;
+		rx_buf->data_ptr = data + bp->rx_offset;
+	}
 	rx_buf->mapping = mapping;
 
 	rxbd->rx_bd_haddr = cpu_to_le64(mapping);
-
 	return 0;
 }
 
@@ -754,6 +782,51 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 	rxr->rx_sw_agg_prod = sw_prod;
 }
 
+static struct sk_buff *bnxt_rx_page_skb(struct bnxt *bp,
+					struct bnxt_rx_ring_info *rxr,
+					u16 cons, void *data, u8 *data_ptr,
+					dma_addr_t dma_addr,
+					unsigned int offset_and_len)
+{
+	unsigned int payload = offset_and_len >> 16;
+	unsigned int len = offset_and_len & 0xffff;
+	struct skb_frag_struct *frag;
+	struct page *page = data;
+	u16 prod = rxr->rx_prod;
+	struct sk_buff *skb;
+	int off, err;
+
+	err = bnxt_alloc_rx_data(bp, rxr, prod, GFP_ATOMIC);
+	if (unlikely(err)) {
+		bnxt_reuse_rx_data(rxr, cons, data);
+		return NULL;
+	}
+	dma_addr -= bp->rx_dma_offset;
+	dma_unmap_page(&bp->pdev->dev, dma_addr, PAGE_SIZE, bp->rx_dir);
+
+	if (unlikely(!payload))
+		payload = eth_get_headlen(data_ptr, len);
+
+	skb = napi_alloc_skb(&rxr->bnapi->napi, payload);
+	if (!skb) {
+		__free_page(page);
+		return NULL;
+	}
+
+	off = (void *)data_ptr - page_address(page);
+	skb_add_rx_frag(skb, 0, page, off, len, PAGE_SIZE);
+	memcpy(skb->data - NET_IP_ALIGN, data_ptr - NET_IP_ALIGN,
+	       payload + NET_IP_ALIGN);
+
+	frag = &skb_shinfo(skb)->frags[0];
+	skb_frag_size_sub(frag, payload);
+	frag->page_offset += payload;
+	skb->data_len -= payload;
+	skb->tail += payload;
+
+	return skb;
+}
+
 static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
 				   struct bnxt_rx_ring_info *rxr, u16 cons,
 				   void *data, u8 *data_ptr,
@@ -1329,6 +1402,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	struct sk_buff *skb;
 	void *data;
 	int rc = 0;
+	u32 misc;
 
 	rxcmp = (struct rx_cmp *)
 			&cpr->cp_desc_ring[CP_RING(cp_cons)][CP_IDX(cp_cons)];
@@ -1381,8 +1455,8 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	}
 	prefetch(data_ptr);
 
-	agg_bufs = (le32_to_cpu(rxcmp->rx_cmp_misc_v1) & RX_CMP_AGG_BUFS) >>
-				RX_CMP_AGG_BUFS_SHIFT;
+	misc = le32_to_cpu(rxcmp->rx_cmp_misc_v1);
+	agg_bufs = (misc & RX_CMP_AGG_BUFS) >> RX_CMP_AGG_BUFS_SHIFT;
 
 	if (agg_bufs) {
 		if (!bnxt_agg_bufs_valid(bp, cpr, agg_bufs, &tmp_raw_cons))
@@ -1413,8 +1487,11 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 			goto next_rx;
 		}
 	} else {
+		u32 payload;
+
+		payload = misc & RX_CMP_PAYLOAD_OFFSET;
 		skb = bp->rx_skb_func(bp, rxr, cons, data, data_ptr, dma_addr,
-				      len);
+				      payload | len);
 		if (!skb) {
 			rc = -ENOMEM;
 			goto next_rx;
@@ -1899,7 +1976,10 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 			rx_buf->data = NULL;
 
-			kfree(data);
+			if (BNXT_RX_PAGE_MODE(bp))
+				__free_page(data);
+			else
+				kfree(data);
 		}
 
 		for (j = 0; j < max_agg_idx; j++) {
@@ -2348,8 +2428,13 @@ static int bnxt_init_rx_rings(struct bnxt *bp)
 {
 	int i, rc = 0;
 
-	bp->rx_offset = BNXT_RX_OFFSET;
-	bp->rx_dma_offset = BNXT_RX_DMA_OFFSET;
+	if (BNXT_RX_PAGE_MODE(bp)) {
+		bp->rx_offset = NET_IP_ALIGN;
+		bp->rx_dma_offset = 0;
+	} else {
+		bp->rx_offset = BNXT_RX_OFFSET;
+		bp->rx_dma_offset = BNXT_RX_DMA_OFFSET;
+	}
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
 		rc = bnxt_init_one_rx_ring(bp, i);
@@ -2560,10 +2645,24 @@ void bnxt_set_ring_params(struct bnxt *bp)
 	bp->cp_ring_mask = bp->cp_bit - 1;
 }
 
-static int bnxt_set_rx_skb_mode(struct bnxt *bp)
+int bnxt_set_rx_skb_mode(struct bnxt *bp, bool page_mode)
 {
-	bp->rx_dir = DMA_FROM_DEVICE;
-	bp->rx_skb_func = bnxt_rx_skb;
+	if (page_mode) {
+		if (bp->dev->mtu > BNXT_MAX_PAGE_MODE_MTU)
+			return -EOPNOTSUPP;
+		bp->dev->max_mtu = BNXT_MAX_PAGE_MODE_MTU;
+		bp->flags &= ~BNXT_FLAG_AGG_RINGS;
+		bp->flags |= BNXT_FLAG_NO_AGG_RINGS | BNXT_FLAG_RX_PAGE_MODE;
+		bp->dev->hw_features &= ~NETIF_F_LRO;
+		bp->dev->features &= ~NETIF_F_LRO;
+		bp->rx_dir = DMA_BIDIRECTIONAL;
+		bp->rx_skb_func = bnxt_rx_page_skb;
+	} else {
+		bp->dev->max_mtu = BNXT_MAX_MTU;
+		bp->flags &= ~BNXT_FLAG_RX_PAGE_MODE;
+		bp->rx_dir = DMA_FROM_DEVICE;
+		bp->rx_skb_func = bnxt_rx_skb;
+	}
 	return 0;
 }
 
@@ -7275,7 +7374,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* MTU range: 60 - 9500 */
 	dev->min_mtu = ETH_ZLEN;
-	dev->max_mtu = 9500;
+	dev->max_mtu = BNXT_MAX_MTU;
 
 	bnxt_dcb_init(bp);
 
@@ -7316,7 +7415,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_hwrm_func_qcfg(bp);
 	bnxt_hwrm_port_led_qcaps(bp);
 
-	bnxt_set_rx_skb_mode(bp);
+	bnxt_set_rx_skb_mode(bp, false);
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
 	bnxt_set_max_func_irqs(bp, max_irqs);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index d8fc871..2144a0e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -416,6 +416,10 @@ struct rx_tpa_end_cmp_ext {
 
 #define BNXT_RX_PAGE_SIZE (1 << BNXT_RX_PAGE_SHIFT)
 
+#define BNXT_MAX_MTU		9500
+#define BNXT_MAX_PAGE_MODE_MTU	\
+	((unsigned int)PAGE_SIZE - VLAN_ETH_HLEN - NET_IP_ALIGN)
+
 #define BNXT_MIN_PKT_SIZE	52
 
 #define BNXT_NUM_TESTS(bp)	0
@@ -967,6 +971,7 @@ struct bnxt {
 	#define BNXT_FLAG_ROCE_CAP	(BNXT_FLAG_ROCEV1_CAP |	\
 					 BNXT_FLAG_ROCEV2_CAP)
 	#define BNXT_FLAG_NO_AGG_RINGS	0x20000
+	#define BNXT_FLAG_RX_PAGE_MODE	0x40000
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
@@ -978,6 +983,7 @@ struct bnxt {
 #define BNXT_NPAR(bp)		((bp)->port_partition_type)
 #define BNXT_SINGLE_PF(bp)	(BNXT_PF(bp) && !BNXT_NPAR(bp))
 #define BNXT_CHIP_TYPE_NITRO_A0(bp) ((bp)->flags & BNXT_FLAG_CHIP_NITRO_A0)
+#define BNXT_RX_PAGE_MODE(bp)	((bp)->flags & BNXT_FLAG_RX_PAGE_MODE)
 
 	struct bnxt_en_dev	*edev;
 	struct bnxt_en_dev *	(*ulp_probe)(struct net_device *);
@@ -1170,6 +1176,7 @@ struct bnxt {
 #define BNXT_MAX_PHY_I2C_RESP_SIZE		64
 
 void bnxt_set_ring_params(struct bnxt *);
+int bnxt_set_rx_skb_mode(struct bnxt *bp, bool page_mode);
 void bnxt_hwrm_cmd_hdr_init(struct bnxt *, void *, u16, u16, u16);
 int _hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message(struct bnxt *, void *, u32, int);
-- 
1.8.3.1
