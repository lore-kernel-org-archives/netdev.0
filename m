From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 2/2] bnx2x: replace mechanism to check for
 next available packet
Date: Wed, 19 Jun 2013 01:36:05 +0300
Message-ID: <1371594965-12546-3-git-send-email-dmitry@broadcom.com>
References: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4733 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932706Ab3FRWgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 18:36:23 -0400
In-Reply-To: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check next packet availability by validating that HW has finished CQE
placement. This saves latency of another dma transaction performed to update
SB indexes.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 49 ++++++++++--------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  | 26 +++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |  3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  1 -
 4 files changed, 42 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 20eefa6..ca7f2bb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -804,40 +804,32 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 {
 	struct bnx2x *bp = fp->bp;
 	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
-	u16 hw_comp_cons, sw_comp_cons, sw_comp_prod;
+	u16 sw_comp_cons, sw_comp_prod;
 	int rx_pkt = 0;
+	union eth_rx_cqe *cqe;
+	struct eth_fast_path_rx_cqe *cqe_fp;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return 0;
 #endif
 
-	/* CQ "next element" is of the size of the regular element,
-	   that's why it's ok here */
-	hw_comp_cons = le16_to_cpu(*fp->rx_cons_sb);
-	if ((hw_comp_cons & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		hw_comp_cons++;
-
 	bd_cons = fp->rx_bd_cons;
 	bd_prod = fp->rx_bd_prod;
 	bd_prod_fw = bd_prod;
 	sw_comp_cons = fp->rx_comp_cons;
 	sw_comp_prod = fp->rx_comp_prod;
 
-	/* Memory barrier necessary as speculative reads of the rx
-	 * buffer can be ahead of the index in the status block
-	 */
-	rmb();
+	comp_ring_cons = RCQ_BD(sw_comp_cons);
+	cqe = &fp->rx_comp_ring[comp_ring_cons];
+	cqe_fp = &cqe->fast_path_cqe;
 
 	DP(NETIF_MSG_RX_STATUS,
-	   "queue[%d]:  hw_comp_cons %u  sw_comp_cons %u\n",
-	   fp->index, hw_comp_cons, sw_comp_cons);
+	   "queue[%d]: sw_comp_cons %u\n", fp->index, sw_comp_cons);
 
-	while (sw_comp_cons != hw_comp_cons) {
+	while (BNX2X_IS_CQE_COMPLETED(cqe_fp)) {
 		struct sw_rx_bd *rx_buf = NULL;
 		struct sk_buff *skb;
-		union eth_rx_cqe *cqe;
-		struct eth_fast_path_rx_cqe *cqe_fp;
 		u8 cqe_fp_flags;
 		enum eth_rx_cqe_type cqe_fp_type;
 		u16 len, pad, queue;
@@ -849,12 +841,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			return 0;
 #endif
 
-		comp_ring_cons = RCQ_BD(sw_comp_cons);
 		bd_prod = RX_BD(bd_prod);
 		bd_cons = RX_BD(bd_cons);
 
-		cqe = &fp->rx_comp_ring[comp_ring_cons];
-		cqe_fp = &cqe->fast_path_cqe;
 		cqe_fp_flags = cqe_fp->type_error_flags;
 		cqe_fp_type = cqe_fp_flags & ETH_FAST_PATH_RX_CQE_TYPE;
 
@@ -1018,8 +1007,15 @@ next_cqe:
 		sw_comp_prod = NEXT_RCQ_IDX(sw_comp_prod);
 		sw_comp_cons = NEXT_RCQ_IDX(sw_comp_cons);
 
+		/* mark CQE as free */
+		BNX2X_SEED_CQE(cqe_fp);
+
 		if (rx_pkt == budget)
 			break;
+
+		comp_ring_cons = RCQ_BD(sw_comp_cons);
+		cqe = &fp->rx_comp_ring[comp_ring_cons];
+		cqe_fp = &cqe->fast_path_cqe;
 	} /* while */
 
 	fp->rx_bd_cons = bd_cons;
@@ -1055,8 +1051,6 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 #endif
 
 	/* Handle Rx and Tx according to MSI-X vector */
-	prefetch(fp->rx_cons_sb);
-
 	for_each_cos_in_tx_queue(fp, cos)
 		prefetch(fp->txdata_ptr[cos]->tx_cons_sb);
 
@@ -3137,10 +3131,8 @@ int bnx2x_low_latency_recv(struct napi_struct *napi)
 	if (!bnx2x_fp_lock_poll(fp))
 		return LL_FLUSH_BUSY;
 
-	if (bnx2x_has_rx_work(fp)) {
-		bnx2x_update_fpsb_idx(fp);
+	if (bnx2x_has_rx_work(fp))
 		found = bnx2x_rx_int(fp, 4);
-	}
 
 	bnx2x_fp_unlock_poll(fp);
 
@@ -4339,10 +4331,11 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 				&bnx2x_fp(bp, index, rx_desc_mapping),
 				sizeof(struct eth_rx_bd) * NUM_RX_BD);
 
-		BNX2X_PCI_ALLOC(bnx2x_fp(bp, index, rx_comp_ring),
-				&bnx2x_fp(bp, index, rx_comp_mapping),
-				sizeof(struct eth_fast_path_rx_cqe) *
-				NUM_RCQ_BD);
+		/* Seed all CQEs by 1s */
+		BNX2X_PCI_FALLOC(bnx2x_fp(bp, index, rx_comp_ring),
+				 &bnx2x_fp(bp, index, rx_comp_mapping),
+				 sizeof(struct eth_fast_path_rx_cqe) *
+				 NUM_RCQ_BD);
 
 		/* SGE ring */
 		BNX2X_ALLOC(bnx2x_fp(bp, index, rx_page_ring),
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index a1a5cdc..c07a6d0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -59,6 +59,16 @@ extern int int_mode;
 		   (unsigned long long)(*y), x); \
 	} while (0)
 
+#define BNX2X_PCI_FALLOC(x, y, size) \
+	do { \
+		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
+		if (x == NULL) \
+			goto alloc_mem_err; \
+		memset((void *)x, 0xFFFFFFFF, size); \
+		DP(NETIF_MSG_HW, "BNX2X_PCI_FALLOC: Physical %Lx Virtual %p\n",\
+		   (unsigned long long)(*y), x); \
+	} while (0)
+
 #define BNX2X_ALLOC(x, size) \
 	do { \
 		x = kzalloc(size, GFP_KERNEL); \
@@ -805,16 +815,18 @@ static inline bool bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
 	return false;
 }
 
+#define BNX2X_IS_CQE_COMPLETED(cqe_fp) (cqe_fp->marker == 0x0)
+#define BNX2X_SEED_CQE(cqe_fp) (cqe_fp->marker = 0xFFFFFFFF)
 static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
 {
-	u16 rx_cons_sb;
+	u16 cons;
+	union eth_rx_cqe *cqe;
+	struct eth_fast_path_rx_cqe *cqe_fp;
 
-	/* Tell compiler that status block fields can change */
-	barrier();
-	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
-	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		rx_cons_sb++;
-	return (fp->rx_comp_cons != rx_cons_sb);
+	cons = RCQ_BD(fp->rx_comp_cons);
+	cqe = &fp->rx_comp_ring[cons];
+	cqe_fp = &cqe->fast_path_cqe;
+	return BNX2X_IS_CQE_COMPLETED(cqe_fp);
 }
 
 /**
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 5ef3f96..5018e52 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -3818,7 +3818,8 @@ struct eth_fast_path_rx_cqe {
 	__le16 len_on_bd;
 	struct parsing_flags pars_flags;
 	union eth_sgl_or_raw_data sgl_or_raw_data;
-	__le32 reserved1[8];
+	__le32 reserved1[7];
+	u32 marker;
 };
 
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e2e8705..f0d21fa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1866,7 +1866,6 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		mask = 0x2 << (fp->index + CNIC_SUPPORT(bp));
 		if (status & mask) {
 			/* Handle Rx or Tx according to SB id */
-			prefetch(fp->rx_cons_sb);
 			for_each_cos_in_tx_queue(fp, cos)
 				prefetch(fp->txdata_ptr[cos]->tx_cons_sb);
 			prefetch(&fp->sb_running_index[SM_RX_ID]);
-- 
1.8.1.4
