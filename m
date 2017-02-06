From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 01/12] bnxt_en: Refactor rx SKB function.
Date: Mon,  6 Feb 2017 16:55:32 -0500
Message-ID: <1486418143-8958-2-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36193 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdBFV4B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:01 -0500
Received: by mail-pg0-f45.google.com with SMTP id v184so31801295pgv.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:00 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor refactoring of bnxt_rx_skb() so that it can easily be replaced by
a new function that handles packets in a single page.  Also, use a
function pointer bp->rx_skb_func() to switch to a new function when
we add the new mode in the next patch.

Add a new field data_ptr that points to the packet data in the
bnxt_sw_rx_bd structure.  The original data field is changed to void
pointer so that it can either hold the kmalloc'ed data or a page
pointer.

The last parameter of bnxt_rx_skb() which was the length parameter is
changed to include the payload offset of the packet in the upper 16 bit.
The offset is needed to support the rx page mode and is not used in
this existing function.

v3: Added a new data_ptr parameter to bp->rx_skb_func().  The caller
has the option to modify the starting address of the packet.  This
will be needed when XDP with headroom support is added.

v2: Changed the name of the last parameter to offset_and_len to make the
code more clear.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 49 ++++++++++++++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 11 +++++--
 2 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index aff3dc1..94f3d78 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -607,6 +607,7 @@ static inline int bnxt_alloc_rx_data(struct bnxt *bp,
 		return -ENOMEM;
 
 	rx_buf->data = data;
+	rx_buf->data_ptr = data + BNXT_RX_OFFSET;
 	dma_unmap_addr_set(rx_buf, mapping, mapping);
 
 	rxbd->rx_bd_haddr = cpu_to_le64(mapping);
@@ -615,7 +616,7 @@ static inline int bnxt_alloc_rx_data(struct bnxt *bp,
 }
 
 static void bnxt_reuse_rx_data(struct bnxt_rx_ring_info *rxr, u16 cons,
-			       u8 *data)
+			       void *data)
 {
 	u16 prod = rxr->rx_prod;
 	struct bnxt_sw_rx_bd *cons_rx_buf, *prod_rx_buf;
@@ -625,6 +626,7 @@ static void bnxt_reuse_rx_data(struct bnxt_rx_ring_info *rxr, u16 cons,
 	cons_rx_buf = &rxr->rx_buf_ring[cons];
 
 	prod_rx_buf->data = data;
+	prod_rx_buf->data_ptr = cons_rx_buf->data_ptr;
 
 	dma_unmap_addr_set(prod_rx_buf, mapping,
 			   dma_unmap_addr(cons_rx_buf, mapping));
@@ -755,11 +757,13 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 
 static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
 				   struct bnxt_rx_ring_info *rxr, u16 cons,
-				   u16 prod, u8 *data, dma_addr_t dma_addr,
-				   unsigned int len)
+				   void *data, u8 *data_ptr,
+				   dma_addr_t dma_addr,
+				   unsigned int offset_and_len)
 {
-	int err;
+	u16 prod = rxr->rx_prod;
 	struct sk_buff *skb;
+	int err;
 
 	err = bnxt_alloc_rx_data(bp, rxr, prod, GFP_ATOMIC);
 	if (unlikely(err)) {
@@ -776,7 +780,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
 	}
 
 	skb_reserve(skb, BNXT_RX_OFFSET);
-	skb_put(skb, len);
+	skb_put(skb, offset_and_len & 0xffff);
 	return skb;
 }
 
@@ -878,7 +882,8 @@ static inline struct sk_buff *bnxt_copy_skb(struct bnxt_napi *bnapi, u8 *data,
 	dma_sync_single_for_cpu(&pdev->dev, mapping,
 				bp->rx_copy_thresh, PCI_DMA_FROMDEVICE);
 
-	memcpy(skb->data - BNXT_RX_OFFSET, data, len + BNXT_RX_OFFSET);
+	memcpy(skb->data - NET_IP_ALIGN, data - NET_IP_ALIGN,
+	       len + NET_IP_ALIGN);
 
 	dma_sync_single_for_device(&pdev->dev, mapping,
 				   bp->rx_copy_thresh,
@@ -951,6 +956,7 @@ static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 	}
 
 	prod_rx_buf->data = tpa_info->data;
+	prod_rx_buf->data_ptr = tpa_info->data_ptr;
 
 	mapping = tpa_info->mapping;
 	dma_unmap_addr_set(prod_rx_buf, mapping, mapping);
@@ -960,6 +966,7 @@ static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 	prod_bd->rx_bd_haddr = cpu_to_le64(mapping);
 
 	tpa_info->data = cons_rx_buf->data;
+	tpa_info->data_ptr = cons_rx_buf->data_ptr;
 	cons_rx_buf->data = NULL;
 	tpa_info->mapping = dma_unmap_addr(cons_rx_buf, mapping);
 
@@ -1192,12 +1199,13 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
 	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 	u8 agg_id = TPA_END_AGG_ID(tpa_end);
-	u8 *data, agg_bufs;
+	u8 *data_ptr, agg_bufs;
 	u16 cp_cons = RING_CMP(*raw_cons);
 	unsigned int len;
 	struct bnxt_tpa_info *tpa_info;
 	dma_addr_t mapping;
 	struct sk_buff *skb;
+	void *data;
 
 	if (unlikely(bnapi->in_reset)) {
 		int rc = bnxt_discard_rx(bp, bnapi, raw_cons, tpa_end);
@@ -1209,7 +1217,8 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 
 	tpa_info = &rxr->rx_tpa[agg_id];
 	data = tpa_info->data;
-	prefetch(data);
+	data_ptr = tpa_info->data_ptr;
+	prefetch(data_ptr);
 	len = tpa_info->len;
 	mapping = tpa_info->mapping;
 
@@ -1232,7 +1241,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 	}
 
 	if (len <= bp->rx_copy_thresh) {
-		skb = bnxt_copy_skb(bnapi, data, len, mapping);
+		skb = bnxt_copy_skb(bnapi, data_ptr, len, mapping);
 		if (!skb) {
 			bnxt_abort_tpa(bp, bnapi, cp_cons, agg_bufs);
 			return NULL;
@@ -1248,6 +1257,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 		}
 
 		tpa_info->data = new_data;
+		tpa_info->data_ptr = new_data + BNXT_RX_OFFSET;
 		tpa_info->mapping = new_mapping;
 
 		skb = build_skb(data, 0);
@@ -1316,9 +1326,10 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	u16 cons, prod, cp_cons = RING_CMP(tmp_raw_cons);
 	struct bnxt_sw_rx_bd *rx_buf;
 	unsigned int len;
-	u8 *data, agg_bufs, cmp_type;
+	u8 *data_ptr, agg_bufs, cmp_type;
 	dma_addr_t dma_addr;
 	struct sk_buff *skb;
+	void *data;
 	int rc = 0;
 
 	rxcmp = (struct rx_cmp *)
@@ -1363,13 +1374,14 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	cons = rxcmp->rx_cmp_opaque;
 	rx_buf = &rxr->rx_buf_ring[cons];
 	data = rx_buf->data;
+	data_ptr = rx_buf->data_ptr;
 	if (unlikely(cons != rxr->rx_next_cons)) {
 		int rc1 = bnxt_discard_rx(bp, bnapi, raw_cons, rxcmp);
 
 		bnxt_sched_reset(bp, rxr);
 		return rc1;
 	}
-	prefetch(data);
+	prefetch(data_ptr);
 
 	agg_bufs = (le32_to_cpu(rxcmp->rx_cmp_misc_v1) & RX_CMP_AGG_BUFS) >>
 				RX_CMP_AGG_BUFS_SHIFT;
@@ -1396,14 +1408,15 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	dma_addr = dma_unmap_addr(rx_buf, mapping);
 
 	if (len <= bp->rx_copy_thresh) {
-		skb = bnxt_copy_skb(bnapi, data, len, dma_addr);
+		skb = bnxt_copy_skb(bnapi, data_ptr, len, dma_addr);
 		bnxt_reuse_rx_data(rxr, cons, data);
 		if (!skb) {
 			rc = -ENOMEM;
 			goto next_rx;
 		}
 	} else {
-		skb = bnxt_rx_skb(bp, rxr, cons, prod, data, dma_addr, len);
+		skb = bp->rx_skb_func(bp, rxr, cons, data, data_ptr, dma_addr,
+				      len);
 		if (!skb) {
 			rc = -ENOMEM;
 			goto next_rx;
@@ -1880,7 +1893,7 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 		for (j = 0; j < max_idx; j++) {
 			struct bnxt_sw_rx_bd *rx_buf = &rxr->rx_buf_ring[j];
-			u8 *data = rx_buf->data;
+			void *data = rx_buf->data;
 
 			if (!data)
 				continue;
@@ -2326,6 +2339,7 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 					return -ENOMEM;
 
 				rxr->rx_tpa[i].data = data;
+				rxr->rx_tpa[i].data_ptr = data + BNXT_RX_OFFSET;
 				rxr->rx_tpa[i].mapping = mapping;
 			}
 		} else {
@@ -2550,6 +2564,12 @@ void bnxt_set_ring_params(struct bnxt *bp)
 	bp->cp_ring_mask = bp->cp_bit - 1;
 }
 
+static int bnxt_set_rx_skb_mode(struct bnxt *bp)
+{
+	bp->rx_skb_func = bnxt_rx_skb;
+	return 0;
+}
+
 static void bnxt_free_vnic_attributes(struct bnxt *bp)
 {
 	int i;
@@ -7299,6 +7319,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_hwrm_func_qcfg(bp);
 	bnxt_hwrm_port_led_qcaps(bp);
 
+	bnxt_set_rx_skb_mode(bp);
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
 	bnxt_set_max_func_irqs(bp, max_irqs);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 52a1cc0..11b5a4a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -516,7 +516,8 @@ struct bnxt_sw_tx_bd {
 };
 
 struct bnxt_sw_rx_bd {
-	u8			*data;
+	void			*data;
+	u8			*data_ptr;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
@@ -576,7 +577,8 @@ struct bnxt_tx_ring_info {
 };
 
 struct bnxt_tpa_info {
-	u8			*data;
+	void			*data;
+	u8			*data_ptr;
 	dma_addr_t		mapping;
 	u16			len;
 	unsigned short		gso_type;
@@ -988,6 +990,11 @@ struct bnxt {
 	struct sk_buff *	(*gro_func)(struct bnxt_tpa_info *, int, int,
 					    struct sk_buff *);
 
+	struct sk_buff *	(*rx_skb_func)(struct bnxt *,
+					       struct bnxt_rx_ring_info *,
+					       u16, void *, u8 *, dma_addr_t,
+					       unsigned int);
+
 	u32			rx_buf_size;
 	u32			rx_buf_use_size;	/* useable size */
 	u32			rx_ring_size;
-- 
1.8.3.1
