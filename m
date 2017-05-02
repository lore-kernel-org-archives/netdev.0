From: sunil.kovvuri@gmail.com
Subject: [PATCH 7/9] net: thunderx: Add support for XDP_TX
Date: Tue,  2 May 2017 18:36:56 +0530
Message-ID: <1493730418-24606-8-git-send-email-sunil.kovvuri@gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Adds support for XDP_TX i.e transmits packet out of
the XDP TX queue mapped to the corresponding Rx queue
on which packet is received.

Since SQ for XDP TX will be used only on a single cpu i.e
SQ description creation and freeing, using atomic free count
is not necessary and will become a bottleneck. Hence added
a separate 'xdp_free_cnt' used for SQs designated for XDP
to track descriptor free count.

Changes also include
- A new entry 'xdp_page' is added to save transmitted packet's
  page pointer for later cleanup.
- XDP Tx SQ's doorbell is ringed once per NAPI instance.
- Retrieving designated SQ for packets being sent out by stack
  via 'nicvf_xmit'.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  63 ++++++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 117 ++++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   7 ++
 3 files changed, 160 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index a58cc1e..bb13dee 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -501,9 +501,8 @@ static int nicvf_init_resources(struct nicvf *nic)
 	return 0;
 }
 
-static inline bool nicvf_xdp_rx(struct nicvf *nic,
-				struct bpf_prog *prog,
-				struct cqe_rx_t *cqe_rx)
+static inline bool nicvf_xdp_rx(struct nicvf *nic, struct bpf_prog *prog,
+				struct cqe_rx_t *cqe_rx, struct snd_queue *sq)
 {
 	struct xdp_buff xdp;
 	struct page *page;
@@ -528,9 +527,11 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic,
 
 	switch (action) {
 	case XDP_PASS:
-	case XDP_TX:
-		/* Pass on all packets to network stack */
+		/* Pass on packet to network stack */
 		return false;
+	case XDP_TX:
+		nicvf_xdp_sq_append_pkt(nic, sq, (u64)xdp.data, dma_addr, len);
+		return true;
 	default:
 		bpf_warn_invalid_xdp_action(action);
 	case XDP_ABORTED:
@@ -560,6 +561,7 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 				  unsigned int *tx_pkts, unsigned int *tx_bytes)
 {
 	struct sk_buff *skb = NULL;
+	struct page *page;
 	struct nicvf *nic = netdev_priv(netdev);
 	struct snd_queue *sq;
 	struct sq_hdr_subdesc *hdr;
@@ -575,6 +577,22 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 	if (cqe_tx->send_status)
 		nicvf_check_cqe_tx_errs(nic->pnicvf, cqe_tx);
 
+	/* Is this a XDP designated Tx queue */
+	if (sq->is_xdp) {
+		page = (struct page *)sq->xdp_page[cqe_tx->sqe_ptr];
+		/* Check if it's recycled page or else unmap DMA mapping */
+		if (page && (page_ref_count(page) == 1))
+			nicvf_unmap_sndq_buffers(nic, sq, cqe_tx->sqe_ptr,
+						 hdr->subdesc_cnt);
+
+		/* Release page reference for recycling */
+		if (page)
+			put_page(page);
+		sq->xdp_page[cqe_tx->sqe_ptr] = (u64)NULL;
+		*subdesc_cnt += hdr->subdesc_cnt + 1;
+		return;
+	}
+
 	skb = (struct sk_buff *)sq->skbuff[cqe_tx->sqe_ptr];
 	if (skb) {
 		/* Check for dummy descriptor used for HW TSO offload on 88xx */
@@ -634,7 +652,7 @@ static inline void nicvf_set_rxhash(struct net_device *netdev,
 
 static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 				  struct napi_struct *napi,
-				  struct cqe_rx_t *cqe_rx)
+				  struct cqe_rx_t *cqe_rx, struct snd_queue *sq)
 {
 	struct sk_buff *skb;
 	struct nicvf *nic = netdev_priv(netdev);
@@ -659,7 +677,7 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 
 	/* For XDP, ignore pkts spanning multiple pages */
 	if (nic->xdp_prog && (cqe_rx->rb_cnt == 1))
-		if (nicvf_xdp_rx(snic, nic->xdp_prog, cqe_rx))
+		if (nicvf_xdp_rx(snic, nic->xdp_prog, cqe_rx, sq))
 			return;
 
 	skb = nicvf_get_rcv_skb(snic, cqe_rx, nic->xdp_prog ? true : false);
@@ -715,8 +733,8 @@ static int nicvf_cq_intr_handler(struct net_device *netdev, u8 cq_idx,
 	struct cmp_queue *cq = &qs->cq[cq_idx];
 	struct cqe_rx_t *cq_desc;
 	struct netdev_queue *txq;
-	struct snd_queue *sq;
-	unsigned int tx_pkts = 0, tx_bytes = 0;
+	struct snd_queue *sq = &qs->sq[cq_idx];
+	unsigned int tx_pkts = 0, tx_bytes = 0, txq_idx;
 
 	spin_lock_bh(&cq->lock);
 loop:
@@ -746,7 +764,7 @@ static int nicvf_cq_intr_handler(struct net_device *netdev, u8 cq_idx,
 
 		switch (cq_desc->cqe_type) {
 		case CQE_TYPE_RX:
-			nicvf_rcv_pkt_handler(netdev, napi, cq_desc);
+			nicvf_rcv_pkt_handler(netdev, napi, cq_desc, sq);
 			work_done++;
 		break;
 		case CQE_TYPE_SEND:
@@ -773,17 +791,26 @@ static int nicvf_cq_intr_handler(struct net_device *netdev, u8 cq_idx,
 		goto loop;
 
 done:
-	sq = &nic->qs->sq[cq_idx];
 	/* Update SQ's descriptor free count */
 	if (subdesc_cnt)
 		nicvf_put_sq_desc(sq, subdesc_cnt);
 
+	txq_idx = nicvf_netdev_qidx(nic, cq_idx);
+	/* Handle XDP TX queues */
+	if (nic->pnicvf->xdp_prog) {
+		if (txq_idx < nic->pnicvf->xdp_tx_queues) {
+			nicvf_xdp_sq_doorbell(nic, sq, cq_idx);
+			goto out;
+		}
+		nic = nic->pnicvf;
+		txq_idx -= nic->pnicvf->xdp_tx_queues;
+	}
+
 	/* Wakeup TXQ if its stopped earlier due to SQ full */
 	if (tx_done ||
 	    (atomic_read(&sq->free_cnt) >= MIN_SQ_DESC_PER_PKT_XMIT)) {
 		netdev = nic->pnicvf->netdev;
-		txq = netdev_get_tx_queue(netdev,
-					  nicvf_netdev_qidx(nic, cq_idx));
+		txq = netdev_get_tx_queue(netdev, txq_idx);
 		if (tx_pkts)
 			netdev_tx_completed_queue(txq, tx_pkts, tx_bytes);
 
@@ -796,10 +823,11 @@ static int nicvf_cq_intr_handler(struct net_device *netdev, u8 cq_idx,
 			if (netif_msg_tx_err(nic))
 				netdev_warn(netdev,
 					    "%s: Transmit queue wakeup SQ%d\n",
-					    netdev->name, cq_idx);
+					    netdev->name, txq_idx);
 		}
 	}
 
+out:
 	spin_unlock_bh(&cq->lock);
 	return work_done;
 }
@@ -1115,6 +1143,13 @@ static netdev_tx_t nicvf_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
+	/* In XDP case, initial HW tx queues are used for XDP,
+	 * but stack's queue mapping starts at '0', so skip the
+	 * Tx queues attached to Rx queues for XDP.
+	 */
+	if (nic->xdp_prog)
+		qid += nic->xdp_tx_queues;
+
 	snic = nic;
 	/* Get secondary Qset's SQ structure */
 	if (qid >= MAX_SND_QUEUES_PER_QS) {
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 5009f49..ec234b6 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -19,6 +19,8 @@
 #include "q_struct.h"
 #include "nicvf_queues.h"
 
+static inline void nicvf_sq_add_gather_subdesc(struct snd_queue *sq, int qentry,
+					       int size, u64 data);
 static void nicvf_get_page(struct nicvf *nic)
 {
 	if (!nic->rb_pageref || !nic->rb_page)
@@ -456,7 +458,7 @@ static void nicvf_free_cmp_queue(struct nicvf *nic, struct cmp_queue *cq)
 
 /* Initialize transmit queue */
 static int nicvf_init_snd_queue(struct nicvf *nic,
-				struct snd_queue *sq, int q_len)
+				struct snd_queue *sq, int q_len, int qidx)
 {
 	int err;
 
@@ -469,17 +471,38 @@ static int nicvf_init_snd_queue(struct nicvf *nic,
 	sq->skbuff = kcalloc(q_len, sizeof(u64), GFP_KERNEL);
 	if (!sq->skbuff)
 		return -ENOMEM;
+
 	sq->head = 0;
 	sq->tail = 0;
-	atomic_set(&sq->free_cnt, q_len - 1);
 	sq->thresh = SND_QUEUE_THRESH;
 
-	/* Preallocate memory for TSO segment's header */
-	sq->tso_hdrs = dma_alloc_coherent(&nic->pdev->dev,
-					  q_len * TSO_HEADER_SIZE,
-					  &sq->tso_hdrs_phys, GFP_KERNEL);
-	if (!sq->tso_hdrs)
-		return -ENOMEM;
+	/* Check if this SQ is a XDP TX queue */
+	if (nic->sqs_mode)
+		qidx += ((nic->sqs_id + 1) * MAX_SND_QUEUES_PER_QS);
+	if (qidx < nic->pnicvf->xdp_tx_queues) {
+		/* Alloc memory to save page pointers for XDP_TX */
+		sq->xdp_page = kcalloc(q_len, sizeof(u64), GFP_KERNEL);
+		if (!sq->xdp_page)
+			return -ENOMEM;
+		sq->xdp_desc_cnt = 0;
+		sq->xdp_free_cnt = q_len - 1;
+		sq->is_xdp = true;
+	} else {
+		sq->xdp_page = NULL;
+		sq->xdp_desc_cnt = 0;
+		sq->xdp_free_cnt = 0;
+		sq->is_xdp = false;
+
+		atomic_set(&sq->free_cnt, q_len - 1);
+
+		/* Preallocate memory for TSO segment's header */
+		sq->tso_hdrs = dma_alloc_coherent(&nic->pdev->dev,
+						  q_len * TSO_HEADER_SIZE,
+						  &sq->tso_hdrs_phys,
+						  GFP_KERNEL);
+		if (!sq->tso_hdrs)
+			return -ENOMEM;
+	}
 
 	return 0;
 }
@@ -505,6 +528,7 @@ void nicvf_unmap_sndq_buffers(struct nicvf *nic, struct snd_queue *sq,
 static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 {
 	struct sk_buff *skb;
+	struct page *page;
 	struct sq_hdr_subdesc *hdr;
 	struct sq_hdr_subdesc *tso_sqe;
 
@@ -522,8 +546,15 @@ static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 	smp_rmb();
 	while (sq->head != sq->tail) {
 		skb = (struct sk_buff *)sq->skbuff[sq->head];
-		if (!skb)
+		if (!skb || !sq->xdp_page)
+			goto next;
+
+		page = (struct page *)sq->xdp_page[sq->head];
+		if (!page)
 			goto next;
+		else
+			put_page(page);
+
 		hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, sq->head);
 		/* Check for dummy descriptor used for HW TSO offload on 88xx */
 		if (hdr->dont_send) {
@@ -536,12 +567,14 @@ static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 			nicvf_unmap_sndq_buffers(nic, sq, sq->head,
 						 hdr->subdesc_cnt);
 		}
-		dev_kfree_skb_any(skb);
+		if (skb)
+			dev_kfree_skb_any(skb);
 next:
 		sq->head++;
 		sq->head &= (sq->dmem.q_len - 1);
 	}
 	kfree(sq->skbuff);
+	kfree(sq->xdp_page);
 	nicvf_free_q_desc_mem(nic, &sq->dmem);
 }
 
@@ -932,7 +965,7 @@ static int nicvf_alloc_resources(struct nicvf *nic)
 
 	/* Alloc send queue */
 	for (qidx = 0; qidx < qs->sq_cnt; qidx++) {
-		if (nicvf_init_snd_queue(nic, &qs->sq[qidx], qs->sq_len))
+		if (nicvf_init_snd_queue(nic, &qs->sq[qidx], qs->sq_len, qidx))
 			goto alloc_fail;
 	}
 
@@ -1035,7 +1068,10 @@ static inline int nicvf_get_sq_desc(struct snd_queue *sq, int desc_cnt)
 	int qentry;
 
 	qentry = sq->tail;
-	atomic_sub(desc_cnt, &sq->free_cnt);
+	if (!sq->is_xdp)
+		atomic_sub(desc_cnt, &sq->free_cnt);
+	else
+		sq->xdp_free_cnt -= desc_cnt;
 	sq->tail += desc_cnt;
 	sq->tail &= (sq->dmem.q_len - 1);
 
@@ -1053,7 +1089,10 @@ static inline void nicvf_rollback_sq_desc(struct snd_queue *sq,
 /* Free descriptor back to SQ for future use */
 void nicvf_put_sq_desc(struct snd_queue *sq, int desc_cnt)
 {
-	atomic_add(desc_cnt, &sq->free_cnt);
+	if (!sq->is_xdp)
+		atomic_add(desc_cnt, &sq->free_cnt);
+	else
+		sq->xdp_free_cnt += desc_cnt;
 	sq->head += desc_cnt;
 	sq->head &= (sq->dmem.q_len - 1);
 }
@@ -1111,6 +1150,58 @@ void nicvf_sq_free_used_descs(struct net_device *netdev, struct snd_queue *sq,
 	}
 }
 
+/* XDP Transmit APIs */
+void nicvf_xdp_sq_doorbell(struct nicvf *nic,
+			   struct snd_queue *sq, int sq_num)
+{
+	if (!sq->xdp_desc_cnt)
+		return;
+
+	/* make sure all memory stores are done before ringing doorbell */
+	wmb();
+
+	/* Inform HW to xmit all TSO segments */
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_DOOR,
+			      sq_num, sq->xdp_desc_cnt);
+	sq->xdp_desc_cnt = 0;
+}
+
+static inline void
+nicvf_xdp_sq_add_hdr_subdesc(struct snd_queue *sq, int qentry,
+			     int subdesc_cnt, u64 data, int len)
+{
+	struct sq_hdr_subdesc *hdr;
+
+	hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, qentry);
+	memset(hdr, 0, SND_QUEUE_DESC_SIZE);
+	hdr->subdesc_type = SQ_DESC_TYPE_HEADER;
+	hdr->subdesc_cnt = subdesc_cnt;
+	hdr->tot_len = len;
+	hdr->post_cqe = 1;
+	sq->xdp_page[qentry] = (u64)virt_to_page((void *)data);
+}
+
+int nicvf_xdp_sq_append_pkt(struct nicvf *nic, struct snd_queue *sq,
+			    u64 bufaddr, u64 dma_addr, u16 len)
+{
+	int subdesc_cnt = MIN_SQ_DESC_PER_PKT_XMIT;
+	int qentry;
+
+	if (subdesc_cnt > sq->xdp_free_cnt)
+		return 0;
+
+	qentry = nicvf_get_sq_desc(sq, subdesc_cnt);
+
+	nicvf_xdp_sq_add_hdr_subdesc(sq, qentry, subdesc_cnt - 1, bufaddr, len);
+
+	qentry = nicvf_get_nxt_sqentry(sq, qentry);
+	nicvf_sq_add_gather_subdesc(sq, qentry, len, dma_addr);
+
+	sq->xdp_desc_cnt += subdesc_cnt;
+
+	return 1;
+}
+
 /* Calculate no of SQ subdescriptors needed to transmit all
  * segments of this TSO packet.
  * Taken from 'Tilera network driver' with a minor modification.
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index db04c0e..a07d5b4 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -271,6 +271,10 @@ struct snd_queue {
 	u32		tail;
 	u64		*skbuff;
 	void		*desc;
+	u64		*xdp_page;
+	u16		xdp_desc_cnt;
+	u16		xdp_free_cnt;
+	bool		is_xdp;
 
 #define	TSO_HEADER_SIZE	128
 	/* For TSO segment's header */
@@ -339,6 +343,9 @@ void nicvf_sq_free_used_descs(struct net_device *netdev,
 			      struct snd_queue *sq, int qidx);
 int nicvf_sq_append_skb(struct nicvf *nic, struct snd_queue *sq,
 			struct sk_buff *skb, u8 sq_num);
+int nicvf_xdp_sq_append_pkt(struct nicvf *nic, struct snd_queue *sq,
+			    u64 bufaddr, u64 dma_addr, u16 len);
+void nicvf_xdp_sq_doorbell(struct nicvf *nic, struct snd_queue *sq, int sq_num);
 
 struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic,
 				  struct cqe_rx_t *cqe_rx, bool xdp);
-- 
2.7.4
