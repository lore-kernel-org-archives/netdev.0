From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/10] bnxt_en: Add RX page mode support.
Date: Mon, 30 Jan 2017 20:49:28 -0500
Message-ID: <1485827375-20421-4-git-send-email-michael.chan@broadcom.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Michael Chan <michael.chan@broadocm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35361 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbdAaBur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:50:47 -0500
Received: by mail-pf0-f173.google.com with SMTP id f144so96523856pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:49:58 -0800 (PST)
In-Reply-To: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This mode is to support XDP.  In this mode, each rx ring is configured with
page sized buffers for linear placement of each packet.  MTU will be
restricted to what the page sized buffers can support.

Signed-off-by: Michael Chan <michael.chan@broadocm.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 121 ++++++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |   7 ++
 2 files changed, 115 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c343ade..c63570d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -573,6 +573,24 @@ static void bnxt_tx_int(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
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
+	return page;
+}
+
 static inline u8 *__bnxt_alloc_rx_data(struct bnxt *bp, dma_addr_t *mapping,
 				       gfp_t gfp)
 {
@@ -599,15 +617,25 @@ static inline int bnxt_alloc_rx_data(struct bnxt *bp,
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
-	rx_buf->data_ptr = data + BNXT_RX_OFFSET;
+		if (!page)
+			return -ENOMEM;
+
+		rx_buf->data = page;
+		rx_buf->data_ptr = page_address(page) + NET_IP_ALIGN;
+	} else {
+		u8 *data = __bnxt_alloc_rx_data(bp, &mapping, gfp);
+
+		if (!data)
+			return -ENOMEM;
+
+		rx_buf->data = data;
+		rx_buf->data_ptr = data + BNXT_RX_OFFSET;
+	}
 	dma_unmap_addr_set(rx_buf, mapping, mapping);
 
 	rxbd->rx_bd_haddr = cpu_to_le64(mapping);
@@ -755,6 +783,51 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 	rxr->rx_sw_agg_prod = sw_prod;
 }
 
+static struct sk_buff *bnxt_rx_page_skb(struct bnxt *bp,
+					struct bnxt_rx_ring_info *rxr,
+					u16 cons, u16 prod,
+					void *data, dma_addr_t dma_addr,
+					unsigned int len)
+{
+	struct bnxt_sw_rx_bd *cons_rx_buf = &rxr->rx_buf_ring[cons];
+	unsigned int payload = len >> 16;
+	struct skb_frag_struct *frag;
+	struct page *page = data;
+	struct sk_buff *skb;
+	char *data_ptr;
+	int err;
+
+	len &= 0xffff;
+	err = bnxt_alloc_rx_data(bp, rxr, prod, GFP_ATOMIC);
+	if (unlikely(err)) {
+		bnxt_reuse_rx_data(rxr, cons, data);
+		return NULL;
+	}
+	dma_unmap_page(&bp->pdev->dev, dma_addr, PAGE_SIZE, bp->rx_dir);
+
+	data_ptr = cons_rx_buf->data_ptr;
+	if (unlikely(!payload))
+		payload = eth_get_headlen(data_ptr, len);
+
+	skb = napi_alloc_skb(&rxr->bnapi->napi, payload);
+	if (!skb) {
+		__free_page(page);
+		return NULL;
+	}
+
+	skb_add_rx_frag(skb, 0, page, NET_IP_ALIGN, len, PAGE_SIZE);
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
 				   u16 prod, void *data, dma_addr_t dma_addr,
@@ -1412,7 +1485,12 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 			goto next_rx;
 		}
 	} else {
-		skb = bp->rx_skb_func(bp, rxr, cons, prod, data, dma_addr, len);
+		unsigned int payload_len;
+
+		payload_len = (le32_to_cpu(rxcmp->rx_cmp_misc_v1) &
+			       RX_CMP_PAYLOAD_OFFSET) | len;
+		skb = bp->rx_skb_func(bp, rxr, cons, prod, data, dma_addr,
+				      payload_len);
 		if (!skb) {
 			rc = -ENOMEM;
 			goto next_rx;
@@ -1899,7 +1977,10 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 			rx_buf->data = NULL;
 
-			kfree(data);
+			if (BNXT_RX_PAGE_MODE(bp))
+				__free_page(data);
+			else
+				kfree(data);
 		}
 
 		for (j = 0; j < max_agg_idx; j++) {
@@ -2558,10 +2639,24 @@ void bnxt_set_ring_params(struct bnxt *bp)
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
 
@@ -7273,7 +7368,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* MTU range: 60 - 9500 */
 	dev->min_mtu = ETH_ZLEN;
-	dev->max_mtu = 9500;
+	dev->max_mtu = BNXT_MAX_MTU;
 
 	bnxt_dcb_init(bp);
 
@@ -7314,7 +7409,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_hwrm_func_qcfg(bp);
 	bnxt_hwrm_port_led_qcaps(bp);
 
-	bnxt_set_rx_skb_mode(bp);
+	bnxt_set_rx_skb_mode(bp, false);
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
 	bnxt_set_max_func_irqs(bp, max_irqs);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index b0da02d..b55a9c1 100644
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
@@ -1168,6 +1174,7 @@ struct bnxt {
 #define BNXT_MAX_PHY_I2C_RESP_SIZE		64
 
 void bnxt_set_ring_params(struct bnxt *);
+int bnxt_set_rx_skb_mode(struct bnxt *bp, bool page_mode);
 void bnxt_hwrm_cmd_hdr_init(struct bnxt *, void *, u16, u16, u16);
 int _hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message(struct bnxt *, void *, u32, int);
-- 
1.8.3.1
