From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: MTU for FCoE L2 ring
Date: Sun, 6 Feb 2011 14:49:22 +0200
Message-ID: <1296996562.16759.9.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4182 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304Ab1BFMta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Feb 2011 07:49:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always configure an FCoE L2 ring with a mini-jumbo MTU size (2500).
To do that we had to move the rx_buf_size parameter from per
function level to a per ring level.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |    7 ++++-
 drivers/net/bnx2x/bnx2x_cmn.c     |   53 +++++++++++++++++++++++++++----------
 drivers/net/bnx2x/bnx2x_cmn.h     |    6 ++--
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 drivers/net/bnx2x/bnx2x_main.c    |   10 +++++-
 5 files changed, 57 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index ff87ec3..c29b37e 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -341,6 +341,8 @@ struct bnx2x_fastpath {
 	/* chip independed shortcut into rx_prods_offset memory */
 	u32			ustorm_rx_prods_offset;

+	u32			rx_buf_size;
+
 	dma_addr_t		status_blk_mapping;

 	struct sw_tx_bd		*tx_buf_ring;
@@ -428,6 +430,10 @@ struct bnx2x_fastpath {
 };

 #define bnx2x_fp(bp, nr, var)		(bp->fp[nr].var)
+
+/* Use 2500 as a mini-jumbo MTU for FCoE */
+#define BNX2X_FCOE_MINI_JUMBO_MTU	2500
+
 #ifdef BCM_CNIC
 /* FCoE L2 `fastpath' is right after the eth entries */
 #define FCOE_IDX			BNX2X_NUM_ETH_QUEUES(bp)
@@ -911,7 +917,6 @@ struct bnx2x {
 	int			tx_ring_size;

 	u32			rx_csum;
-	u32			rx_buf_size;
 /* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
 #define ETH_OVREHEAD		(ETH_HLEN + 8 + 8)
 #define ETH_MIN_PACKET_SIZE		60
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 710ce5d..844afce 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -232,7 +232,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 	/* move empty skb from pool to prod and map it */
 	prod_rx_buf->skb = fp->tpa_pool[queue].skb;
 	mapping = dma_map_single(&bp->pdev->dev, fp->tpa_pool[queue].skb->data,
-				 bp->rx_buf_size, DMA_FROM_DEVICE);
+				 fp->rx_buf_size, DMA_FROM_DEVICE);
 	dma_unmap_addr_set(prod_rx_buf, mapping, mapping);

 	/* move partial skb from cons to pool (don't unmap yet) */
@@ -333,13 +333,13 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	struct sw_rx_bd *rx_buf = &fp->tpa_pool[queue];
 	struct sk_buff *skb = rx_buf->skb;
 	/* alloc new skb */
-	struct sk_buff *new_skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	struct sk_buff *new_skb = netdev_alloc_skb(bp->dev, fp->rx_buf_size);

 	/* Unmap skb in the pool anyway, as we are going to change
 	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
 	   fails. */
 	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
-			 bp->rx_buf_size, DMA_FROM_DEVICE);
+			 fp->rx_buf_size, DMA_FROM_DEVICE);

 	if (likely(new_skb)) {
 		/* fix ip xsum and give it to the stack */
@@ -349,10 +349,10 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		prefetch(((char *)(skb)) + L1_CACHE_BYTES);

 #ifdef BNX2X_STOP_ON_ERROR
-		if (pad + len > bp->rx_buf_size) {
+		if (pad + len > fp->rx_buf_size) {
 			BNX2X_ERR("skb_put is about to fail...  "
 				  "pad %d  len %d  rx_buf_size %d\n",
-				  pad, len, bp->rx_buf_size);
+				  pad, len, fp->rx_buf_size);
 			bnx2x_panic();
 			return;
 		}
@@ -582,7 +582,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
 				dma_unmap_single(&bp->pdev->dev,
 					dma_unmap_addr(rx_buf, mapping),
-						 bp->rx_buf_size,
+						 fp->rx_buf_size,
 						 DMA_FROM_DEVICE);
 				skb_reserve(skb, pad);
 				skb_put(skb, len);
@@ -821,19 +821,16 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 	u16 ring_prod;
 	int i, j;

-	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN +
-		IP_HEADER_ALIGNMENT_PADDING;
-
-	DP(NETIF_MSG_IFUP,
-	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
-
 	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];

+		DP(NETIF_MSG_IFUP,
+		   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, fp->rx_buf_size);
+
 		if (!fp->disable_tpa) {
 			for (i = 0; i < max_agg_queues; i++) {
 				fp->tpa_pool[i].skb =
-				   netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+				   netdev_alloc_skb(bp->dev, fp->rx_buf_size);
 				if (!fp->tpa_pool[i].skb) {
 					BNX2X_ERR("Failed to allocate TPA "
 						  "skb pool for queue[%d] - "
@@ -941,7 +938,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)

 			dma_unmap_single(&bp->pdev->dev,
 					 dma_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size, DMA_FROM_DEVICE);
+					 fp->rx_buf_size, DMA_FROM_DEVICE);

 			rx_buf->skb = NULL;
 			dev_kfree_skb(skb);
@@ -1249,6 +1246,31 @@ static inline int bnx2x_set_real_num_queues(struct bnx2x *bp)
 	return rc;
 }

+static inline void bnx2x_set_rx_buf_size(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		/* Always use a mini-jumbo MTU for the FCoE L2 ring */
+		if (IS_FCOE_IDX(i))
+			/*
+			 * Although there are no IP frames expected to arrive to
+			 * this ring we still want to add an
+			 * IP_HEADER_ALIGNMENT_PADDING to prevent a buffer
+			 * overrun attack.
+			 */
+			fp->rx_buf_size =
+				BNX2X_FCOE_MINI_JUMBO_MTU + ETH_OVREHEAD +
+				BNX2X_RX_ALIGN + IP_HEADER_ALIGNMENT_PADDING;
+		else
+			fp->rx_buf_size =
+				bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN +
+				IP_HEADER_ALIGNMENT_PADDING;
+	}
+}
+
 /* must be called with rtnl_lock */
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
@@ -1272,6 +1294,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* must be called before memory allocation and HW init */
 	bnx2x_ilt_set_info(bp);

+	/* Set the receive queues buffer size */
+	bnx2x_set_rx_buf_size(bp);
+
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;

diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 03eb4d6..f062d5d 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -822,11 +822,11 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 	struct eth_rx_bd *rx_bd = &fp->rx_desc_ring[index];
 	dma_addr_t mapping;

-	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	skb = netdev_alloc_skb(bp->dev, fp->rx_buf_size);
 	if (unlikely(skb == NULL))
 		return -ENOMEM;

-	mapping = dma_map_single(&bp->pdev->dev, skb->data, bp->rx_buf_size,
+	mapping = dma_map_single(&bp->pdev->dev, skb->data, fp->rx_buf_size,
 				 DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
 		dev_kfree_skb(skb);
@@ -892,7 +892,7 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 		if (fp->tpa_state[i] == BNX2X_TPA_START)
 			dma_unmap_single(&bp->pdev->dev,
 					 dma_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size, DMA_FROM_DEVICE);
+					 fp->rx_buf_size, DMA_FROM_DEVICE);

 		dev_kfree_skb(skb);
 		rx_buf->skb = NULL;
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 5b44a8b..816fef6 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1618,7 +1618,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	/* prepare the loopback packet */
 	pkt_size = (((bp->dev->mtu < ETH_MAX_PACKET_SIZE) ?
 		     bp->dev->mtu : ETH_MAX_PACKET_SIZE) + ETH_HLEN);
-	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	skb = netdev_alloc_skb(bp->dev, fp_rx->rx_buf_size);
 	if (!skb) {
 		rc = -ENOMEM;
 		goto test_loopback_exit;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index ae8d20a..4b2cc1f 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2478,8 +2478,14 @@ static void bnx2x_pf_rx_cl_prep(struct bnx2x *bp,
 	rxq_init->sge_map = fp->rx_sge_mapping;
 	rxq_init->rcq_map = fp->rx_comp_mapping;
 	rxq_init->rcq_np_map = fp->rx_comp_mapping + BCM_PAGE_SIZE;
-	rxq_init->mtu = bp->dev->mtu;
-	rxq_init->buf_sz = bp->rx_buf_size;
+
+	/* Always use mini-jumbo MTU for FCoE L2 ring */
+	if (IS_FCOE_FP(fp))
+		rxq_init->mtu = BNX2X_FCOE_MINI_JUMBO_MTU;
+	else
+		rxq_init->mtu = bp->dev->mtu;
+
+	rxq_init->buf_sz = fp->rx_buf_size;
 	rxq_init->cl_qzone_id = fp->cl_qzone_id;
 	rxq_init->cl_id = fp->cl_id;
 	rxq_init->spcl_id = fp->cl_id;
--
1.7.0.4




