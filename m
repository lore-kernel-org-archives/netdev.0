From: sunil.kovvuri@gmail.com
Subject: [PATCH net 2/2] net: thunderx: Fix for issues with multiple CQEs posted for a TSO packet
Date: Tue, 30 Aug 2016 11:36:27 +0530
Message-ID: <1472537187-21951-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1472537187-21951-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472537187-21951-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

On ThunderX 88xx pass 2.x chips when TSO is offloaded to HW,
HW posts a CQE for every TSO segment transmitted. Current code
does handles this, but is prone to issues when segment sizes are
small resulting in SW processing too many CQEs and also at times
frees a SKB which is not yet transmitted.

This patch handles the errata in a different way and eliminates issues
with earlier approach, TSO packet is submitted to HW with post_cqe=0,
so that no CQE is posted upon completion of transmission of TSO packet
but a additional HDR + IMMEDIATE descriptors are added to SQ due to
which a CQE is posted and will have required info to be used while
cleanup in napi. This way only one CQE is posted for a TSO packet.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |  1 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 20 +++++--
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 64 +++++++++++++++++++---
 3 files changed, 73 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 83025bb..e29815d 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -279,6 +279,7 @@ struct nicvf {
 	u8			sqs_id;
 	bool                    sqs_mode;
 	bool			hw_tso;
+	bool			t88;
 
 	/* Receive buffer alloc */
 	u32			rb_page_offset;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index a19e73f..3240349 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -513,6 +513,7 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 	struct nicvf *nic = netdev_priv(netdev);
 	struct snd_queue *sq;
 	struct sq_hdr_subdesc *hdr;
+	struct sq_hdr_subdesc *tso_sqe;
 
 	sq = &nic->qs->sq[cqe_tx->sq_idx];
 
@@ -527,17 +528,21 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 
 	nicvf_check_cqe_tx_errs(nic, cq, cqe_tx);
 	skb = (struct sk_buff *)sq->skbuff[cqe_tx->sqe_ptr];
-	/* For TSO offloaded packets only one SQE will have a valid SKB */
 	if (skb) {
+		/* Check for dummy descriptor used for HW TSO offload on 88xx */
+		if (hdr->dont_send) {
+			/* Get actual TSO descriptors and free them */
+			tso_sqe =
+			 (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, hdr->rsvd2);
+			nicvf_put_sq_desc(sq, tso_sqe->subdesc_cnt + 1);
+		}
 		nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
 		prefetch(skb);
 		dev_consume_skb_any(skb);
 		sq->skbuff[cqe_tx->sqe_ptr] = (u64)NULL;
 	} else {
-		/* In case of HW TSO, HW sends a CQE for each segment of a TSO
-		 * packet instead of a single CQE for the whole TSO packet
-		 * transmitted. Each of this CQE points to the same SQE, so
-		 * avoid freeing same SQE multiple times.
+		/* In case of SW TSO on 88xx, only last segment will have
+		 * a SKB attached, so just free SQEs here.
 		 */
 		if (!nic->hw_tso)
 			nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
@@ -1502,6 +1507,7 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct net_device *netdev;
 	struct nicvf *nic;
 	int    err, qcount;
+	u16    sdevid;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -1575,6 +1581,10 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!pass1_silicon(nic->pdev))
 		nic->hw_tso = true;
 
+	pci_read_config_word(nic->pdev, PCI_SUBSYSTEM_ID, &sdevid);
+	if (sdevid == 0xA134)
+		nic->t88 = true;
+
 	/* Check if this VF is in QS only mode */
 	if (nic->sqs_mode)
 		return 0;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 0ff8e60..dda3ea3 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -938,6 +938,8 @@ static int nicvf_tso_count_subdescs(struct sk_buff *skb)
 	return num_edescs + sh->gso_segs;
 }
 
+#define POST_CQE_DESC_COUNT 2
+
 /* Get the number of SQ descriptors needed to xmit this skb */
 static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
 {
@@ -948,6 +950,10 @@ static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
 		return subdesc_cnt;
 	}
 
+	/* Dummy descriptors to get TSO pkt completion notification */
+	if (nic->t88 && nic->hw_tso && skb_shinfo(skb)->gso_size)
+		subdesc_cnt += POST_CQE_DESC_COUNT;
+
 	if (skb_shinfo(skb)->nr_frags)
 		subdesc_cnt += skb_shinfo(skb)->nr_frags;
 
@@ -965,14 +971,21 @@ nicvf_sq_add_hdr_subdesc(struct nicvf *nic, struct snd_queue *sq, int qentry,
 	struct sq_hdr_subdesc *hdr;
 
 	hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, qentry);
-	sq->skbuff[qentry] = (u64)skb;
-
 	memset(hdr, 0, SND_QUEUE_DESC_SIZE);
 	hdr->subdesc_type = SQ_DESC_TYPE_HEADER;
-	/* Enable notification via CQE after processing SQE */
-	hdr->post_cqe = 1;
-	/* No of subdescriptors following this */
-	hdr->subdesc_cnt = subdesc_cnt;
+
+	if (nic->t88 && nic->hw_tso && skb_shinfo(skb)->gso_size) {
+		/* post_cqe = 0, to avoid HW posting a CQE for every TSO
+		 * segment transmitted on 88xx.
+		 */
+		hdr->subdesc_cnt = subdesc_cnt - POST_CQE_DESC_COUNT;
+	} else {
+		sq->skbuff[qentry] = (u64)skb;
+		/* Enable notification via CQE after processing SQE */
+		hdr->post_cqe = 1;
+		/* No of subdescriptors following this */
+		hdr->subdesc_cnt = subdesc_cnt;
+	}
 	hdr->tot_len = len;
 
 	/* Offload checksum calculation to HW */
@@ -1023,6 +1036,37 @@ static inline void nicvf_sq_add_gather_subdesc(struct snd_queue *sq, int qentry,
 	gather->addr = data;
 }
 
+/* Add HDR + IMMEDIATE subdescriptors right after descriptors of a TSO
+ * packet so that a CQE is posted as a notifation for transmission of
+ * TSO packet.
+ */
+static inline void nicvf_sq_add_cqe_subdesc(struct snd_queue *sq, int qentry,
+					    int tso_sqe, struct sk_buff *skb)
+{
+	struct sq_imm_subdesc *imm;
+	struct sq_hdr_subdesc *hdr;
+
+	sq->skbuff[qentry] = (u64)skb;
+
+	hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, qentry);
+	memset(hdr, 0, SND_QUEUE_DESC_SIZE);
+	hdr->subdesc_type = SQ_DESC_TYPE_HEADER;
+	/* Enable notification via CQE after processing SQE */
+	hdr->post_cqe = 1;
+	/* There is no packet to transmit here */
+	hdr->dont_send = 1;
+	hdr->subdesc_cnt = POST_CQE_DESC_COUNT - 1;
+	hdr->tot_len = 1;
+	/* Actual TSO header SQE index, needed for cleanup */
+	hdr->rsvd2 = tso_sqe;
+
+	qentry = nicvf_get_nxt_sqentry(sq, qentry);
+	imm = (struct sq_imm_subdesc *)GET_SQ_DESC(sq, qentry);
+	memset(imm, 0, SND_QUEUE_DESC_SIZE);
+	imm->subdesc_type = SQ_DESC_TYPE_IMMEDIATE;
+	imm->len = 1;
+}
+
 /* Segment a TSO packet into 'gso_size' segments and append
  * them to SQ for transfer
  */
@@ -1096,7 +1140,7 @@ static int nicvf_sq_append_tso(struct nicvf *nic, struct snd_queue *sq,
 int nicvf_sq_append_skb(struct nicvf *nic, struct sk_buff *skb)
 {
 	int i, size;
-	int subdesc_cnt;
+	int subdesc_cnt, tso_sqe = 0;
 	int sq_num, qentry;
 	struct queue_set *qs;
 	struct snd_queue *sq;
@@ -1131,6 +1175,7 @@ int nicvf_sq_append_skb(struct nicvf *nic, struct sk_buff *skb)
 	/* Add SQ header subdesc */
 	nicvf_sq_add_hdr_subdesc(nic, sq, qentry, subdesc_cnt - 1,
 				 skb, skb->len);
+	tso_sqe = qentry;
 
 	/* Add SQ gather subdescs */
 	qentry = nicvf_get_nxt_sqentry(sq, qentry);
@@ -1154,6 +1199,11 @@ int nicvf_sq_append_skb(struct nicvf *nic, struct sk_buff *skb)
 	}
 
 doorbell:
+	if (nic->t88 && skb_shinfo(skb)->gso_size) {
+		qentry = nicvf_get_nxt_sqentry(sq, qentry);
+		nicvf_sq_add_cqe_subdesc(sq, qentry, tso_sqe, skb);
+	}
+
 	/* make sure all memory stores are done before ringing doorbell */
 	smp_wmb();
 
-- 
2.7.4
