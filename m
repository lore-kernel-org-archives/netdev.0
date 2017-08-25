From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 2/2] drivers: net: xgene: Clean up all outstanding tx descriptors
Date: Fri, 25 Aug 2017 15:23:30 -0700
Message-ID: <1503699810-12803-3-git-send-email-isubramanian@apm.com>
References: <1503699810-12803-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, dnelson@redhat.com,
        qnguyen@apm.com, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:32969 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933777AbdHYWXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 18:23:52 -0400
Received: by mail-pg0-f41.google.com with SMTP id t3so5784955pgt.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 15:23:51 -0700 (PDT)
In-Reply-To: <1503699810-12803-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xgene_enet is rmmod'd and there are still outstanding tx descriptors
that have been setup but have not completed, it is possible on the next
modprobe of the driver to receive the oldest of such tx descriptors. This
results in a kernel NULL pointer dereference.

This patch attempts to clean up (by tearing down) all outstanding tx
descriptors when the xgene_enet driver is being rmmod'd.

Given that, on the next modprobe it should be safe to ignore any such tx
descriptors received that map to a NULL skb pointer.

Additionally this patch removes redundant call to dev_kfree_skb_any() from
xgene_enet_setup_tx_desc(). The only caller of xgene_enet_setup_tx_desc()
will call dev_kfree_skb_any() upon return of an error. Nothing is gained by
calling it twice in a row.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Dean Nelson <dnelson@redhat.com>
Tested-by: Quan Nguyen <qnguyen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 120 +++++++++++++++++------
 1 file changed, 89 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 6e253d9..76e2903 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -237,22 +237,24 @@ static irqreturn_t xgene_enet_rx_irq(const int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
-				    struct xgene_enet_raw_desc *raw_desc)
+static dma_addr_t *xgene_get_frag_dma_array(struct xgene_enet_desc_ring *ring,
+					    u16 skb_index)
 {
-	struct xgene_enet_pdata *pdata = netdev_priv(cp_ring->ndev);
-	struct sk_buff *skb;
+	return &ring->frag_dma_addr[skb_index * MAX_SKB_FRAGS];
+}
+
+static void xgene_enet_teardown_tx_desc(struct xgene_enet_desc_ring *cp_ring,
+					struct xgene_enet_raw_desc *raw_desc,
+					struct xgene_enet_raw_desc *exp_desc,
+					struct sk_buff *skb,
+					u16 skb_index)
+{
+	dma_addr_t dma_addr, *frag_dma_addr;
 	struct device *dev;
 	skb_frag_t *frag;
-	dma_addr_t *frag_dma_addr;
-	u16 skb_index;
-	u8 mss_index;
-	u8 status;
 	int i;
 
-	skb_index = GET_VAL(USERINFO, le64_to_cpu(raw_desc->m0));
-	skb = cp_ring->cp_skb[skb_index];
-	frag_dma_addr = &cp_ring->frag_dma_addr[skb_index * MAX_SKB_FRAGS];
+	frag_dma_addr = xgene_get_frag_dma_array(cp_ring, skb_index);
 
 	dev = ndev_to_dev(cp_ring->ndev);
 	dma_unmap_single(dev, GET_VAL(DATAADDR, le64_to_cpu(raw_desc->m1)),
@@ -265,6 +267,36 @@ static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
 			       DMA_TO_DEVICE);
 	}
 
+	if (exp_desc && GET_VAL(LL_BYTES_LSB, le64_to_cpu(raw_desc->m2))) {
+		dma_addr = GET_VAL(DATAADDR, le64_to_cpu(exp_desc->m2));
+		dma_unmap_single(dev, dma_addr, sizeof(u64) * MAX_EXP_BUFFS,
+				 DMA_TO_DEVICE);
+	}
+
+	dev_kfree_skb_any(skb);
+}
+
+static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
+				    struct xgene_enet_raw_desc *raw_desc,
+				    struct xgene_enet_raw_desc *exp_desc)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(cp_ring->ndev);
+	struct sk_buff *skb;
+	u16 skb_index;
+	u8 status;
+	u8 mss_index;
+
+	skb_index = GET_VAL(USERINFO, le64_to_cpu(raw_desc->m0));
+	skb = cp_ring->cp_skb[skb_index];
+	if (unlikely(!skb)) {
+		netdev_err(cp_ring->ndev, "completion skb is NULL\n");
+		return -EIO;
+	}
+	cp_ring->cp_skb[skb_index] = NULL;
+
+	xgene_enet_teardown_tx_desc(cp_ring, raw_desc, exp_desc, skb,
+				    skb_index);
+
 	if (GET_BIT(ET, le64_to_cpu(raw_desc->m3))) {
 		mss_index = GET_VAL(MSS, le64_to_cpu(raw_desc->m3));
 		spin_lock(&pdata->mss_lock);
@@ -279,12 +311,6 @@ static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
 		cp_ring->tx_errors++;
 	}
 
-	if (likely(skb)) {
-		dev_kfree_skb_any(skb);
-	} else {
-		netdev_err(cp_ring->ndev, "completion skb is NULL\n");
-	}
-
 	return 0;
 }
 
@@ -412,11 +438,6 @@ static __le64 *xgene_enet_get_exp_bufs(struct xgene_enet_desc_ring *ring)
 	return exp_bufs;
 }
 
-static dma_addr_t *xgene_get_frag_dma_array(struct xgene_enet_desc_ring *ring)
-{
-	return &ring->cp_ring->frag_dma_addr[ring->tail * MAX_SKB_FRAGS];
-}
-
 static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 				    struct sk_buff *skb)
 {
@@ -473,7 +494,8 @@ static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 	for (i = nr_frags; i < 4 ; i++)
 		exp_desc[i ^ 1] = cpu_to_le64(LAST_BUFFER);
 
-	frag_dma_addr = xgene_get_frag_dma_array(tx_ring);
+	frag_dma_addr = xgene_get_frag_dma_array(tx_ring->cp_ring,
+						 tx_ring->tail);
 
 	for (i = 0, fidx = 0; split || (fidx < nr_frags); i++) {
 		if (!split) {
@@ -484,7 +506,7 @@ static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 			pbuf_addr = skb_frag_dma_map(dev, frag, 0, size,
 						     DMA_TO_DEVICE);
 			if (dma_mapping_error(dev, pbuf_addr))
-				return -EINVAL;
+				goto err;
 
 			frag_dma_addr[fidx] = pbuf_addr;
 			fidx++;
@@ -539,10 +561,9 @@ static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 		dma_addr = dma_map_single(dev, exp_bufs,
 					  sizeof(u64) * MAX_EXP_BUFFS,
 					  DMA_TO_DEVICE);
-		if (dma_mapping_error(dev, dma_addr)) {
-			dev_kfree_skb_any(skb);
-			return -EINVAL;
-		}
+		if (dma_mapping_error(dev, dma_addr))
+			goto err;
+
 		i = ell_bytes >> LL_BYTES_LSB_LEN;
 		exp_desc[2] = cpu_to_le64(SET_VAL(DATAADDR, dma_addr) |
 					  SET_VAL(LL_BYTES_MSB, i) |
@@ -558,6 +579,19 @@ static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 	tx_ring->tail = tail;
 
 	return count;
+
+err:
+	dma_unmap_single(dev, GET_VAL(DATAADDR, le64_to_cpu(raw_desc->m1)),
+			 skb_headlen(skb),
+			 DMA_TO_DEVICE);
+
+	for (i = 0; i < fidx; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		dma_unmap_page(dev, frag_dma_addr[i], skb_frag_size(frag),
+			       DMA_TO_DEVICE);
+	}
+
+	return -EINVAL;
 }
 
 static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
@@ -828,7 +862,8 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 		if (is_rx_desc(raw_desc)) {
 			ret = xgene_enet_rx_frame(ring, raw_desc, exp_desc);
 		} else {
-			ret = xgene_enet_tx_completion(ring, raw_desc);
+			ret = xgene_enet_tx_completion(ring, raw_desc,
+						       exp_desc);
 			is_completion = true;
 		}
 		xgene_enet_mark_desc_slot_empty(raw_desc);
@@ -1071,18 +1106,41 @@ static void xgene_enet_delete_desc_rings(struct xgene_enet_pdata *pdata)
 {
 	struct xgene_enet_desc_ring *buf_pool, *page_pool;
 	struct xgene_enet_desc_ring *ring;
-	int i;
+	struct xgene_enet_raw_desc *raw_desc, *exp_desc;
+	struct sk_buff *skb;
+	int i, j, k;
 
 	for (i = 0; i < pdata->txq_cnt; i++) {
 		ring = pdata->tx_ring[i];
 		if (ring) {
+			/*
+			 * Find any tx descriptors that were setup but never
+			 * completed, and teardown the setup.
+			 */
+			for (j = 0; j < ring->slots; j++) {
+				skb = ring->cp_ring->cp_skb[j];
+				if (likely(!skb))
+					continue;
+
+				raw_desc = &ring->raw_desc[j];
+				exp_desc = NULL;
+				if (GET_BIT(NV, le64_to_cpu(raw_desc->m0))) {
+					k = (j + 1) & (ring->slots - 1);
+					exp_desc = &ring->raw_desc[k];
+				}
+
+				xgene_enet_teardown_tx_desc(ring->cp_ring,
+							    raw_desc, exp_desc,
+							    skb, j);
+			}
+
 			xgene_enet_delete_ring(ring);
 			pdata->port_ops->clear(pdata, ring);
+
 			if (pdata->cq_cnt)
 				xgene_enet_delete_ring(ring->cp_ring);
 			pdata->tx_ring[i] = NULL;
 		}
-
 	}
 
 	for (i = 0; i < pdata->rxq_cnt; i++) {
-- 
2.7.4
