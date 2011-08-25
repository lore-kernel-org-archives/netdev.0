From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next 1/1] af_packet: Prefixed tpacket_v3 structs to avoid name space collision
Date: Thu, 25 Aug 2011 16:43:30 -0400
Message-ID: <1314305010-1154-1-git-send-email-loke.chetan@gmail.com>
Cc: Chetan Loke <loke.chetan@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56002 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1HYUnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 16:43:50 -0400
Received: by qyk38 with SMTP id 38so3718794qyk.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 13:43:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

structs introduced in tpacket_v3 implementation are prefixed with 'tpacket'
to avoid namespace collision.

Compile tested.

Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
---
 include/linux/if_packet.h |   18 ++++----
 net/packet/af_packet.c    |  117 ++++++++++++++++++++++++---------------------
 2 files changed, 71 insertions(+), 64 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 5926d59..5e76988 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -126,7 +126,7 @@ struct tpacket2_hdr {
 	__u16		tp_padding;
 };
 
-struct hdr_variant1 {
+struct tpacket_hdr_variant1 {
 	__u32	tp_rxhash;
 	__u32	tp_vlan_tci;
 };
@@ -142,11 +142,11 @@ struct tpacket3_hdr {
 	__u16		tp_net;
 	/* pkt_hdr variants */
 	union {
-		struct hdr_variant1 hv1;
+		struct tpacket_hdr_variant1 hv1;
 	};
 };
 
-struct bd_ts {
+struct tpacket_bd_ts {
 	unsigned int ts_sec;
 	union {
 		unsigned int ts_usec;
@@ -154,7 +154,7 @@ struct bd_ts {
 	};
 };
 
-struct hdr_v1 {
+struct tpacket_hdr_v1 {
 	__u32	block_status;
 	__u32	num_pkts;
 	__u32	offset_to_first_pkt;
@@ -200,17 +200,17 @@ struct hdr_v1 {
 	 *			Use the ts of the first packet in the block.
 	 *
 	 */
-	struct bd_ts	ts_first_pkt, ts_last_pkt;
+	struct tpacket_bd_ts	ts_first_pkt, ts_last_pkt;
 };
 
-union bd_header_u {
-	struct hdr_v1 bh1;
+union tpacket_bd_header_u {
+	struct tpacket_hdr_v1 bh1;
 };
 
-struct block_desc {
+struct tpacket_block_desc {
 	__u32 version;
 	__u32 offset_to_priv;
-	union bd_header_u hdr;
+	union tpacket_bd_header_u hdr;
 };
 
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4371e3a..2ea3d63 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -171,13 +171,13 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 
 #define V3_ALIGNMENT	(8)
 
-#define BLK_HDR_LEN	(ALIGN(sizeof(struct block_desc), V3_ALIGNMENT))
+#define BLK_HDR_LEN	(ALIGN(sizeof(struct tpacket_block_desc), V3_ALIGNMENT))
 
 #define BLK_PLUS_PRIV(sz_of_priv) \
 	(BLK_HDR_LEN + ALIGN((sz_of_priv), V3_ALIGNMENT))
 
 /* kbdq - kernel block descriptor queue */
-struct kbdq_core {
+struct tpacket_kbdq_core {
 	struct pgv	*pkbdq;
 	unsigned int	feature_req_word;
 	unsigned int	hdrlen;
@@ -230,7 +230,7 @@ struct packet_ring_buffer {
 	unsigned int		pg_vec_pages;
 	unsigned int		pg_vec_len;
 
-	struct kbdq_core	prb_bdqc;
+	struct tpacket_kbdq_core	prb_bdqc;
 	atomic_t		pending;
 };
 
@@ -249,21 +249,25 @@ static void *packet_previous_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status);
 static void packet_increment_head(struct packet_ring_buffer *buff);
-static int prb_curr_blk_in_use(struct kbdq_core *,
-			struct block_desc *);
-static void *prb_dispatch_next_block(struct kbdq_core *,
+static int prb_curr_blk_in_use(struct tpacket_kbdq_core *,
+			struct tpacket_block_desc *);
+static void *prb_dispatch_next_block(struct tpacket_kbdq_core *,
 			struct packet_sock *);
-static void prb_retire_current_block(struct kbdq_core *,
+static void prb_retire_current_block(struct tpacket_kbdq_core *,
 		struct packet_sock *, unsigned int status);
-static int prb_queue_frozen(struct kbdq_core *);
-static void prb_open_block(struct kbdq_core *, struct block_desc *);
+static int prb_queue_frozen(struct tpacket_kbdq_core *);
+static void prb_open_block(struct tpacket_kbdq_core *,
+		struct tpacket_block_desc *);
 static void prb_retire_rx_blk_timer_expired(unsigned long);
-static void _prb_refresh_rx_retire_blk_timer(struct kbdq_core *);
-static void prb_init_blk_timer(struct packet_sock *, struct kbdq_core *,
-				void (*func) (unsigned long));
-static void prb_fill_rxhash(struct kbdq_core *, struct tpacket3_hdr *);
-static void prb_clear_rxhash(struct kbdq_core *, struct tpacket3_hdr *);
-static void prb_fill_vlan_info(struct kbdq_core *, struct tpacket3_hdr *);
+static void _prb_refresh_rx_retire_blk_timer(struct tpacket_kbdq_core *);
+static void prb_init_blk_timer(struct packet_sock *,
+		struct tpacket_kbdq_core *,
+		void (*func) (unsigned long));
+static void prb_fill_rxhash(struct tpacket_kbdq_core *, struct tpacket3_hdr *);
+static void prb_clear_rxhash(struct tpacket_kbdq_core *,
+		struct tpacket3_hdr *);
+static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
+		struct tpacket3_hdr *);
 static void packet_flush_mclist(struct sock *sk);
 
 struct packet_fanout;
@@ -322,11 +326,11 @@ struct packet_skb_cb {
 
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
 
-#define GET_PBDQC_FROM_RB(x)	((struct kbdq_core *)(&(x)->prb_bdqc))
+#define GET_PBDQC_FROM_RB(x)	((struct tpacket_kbdq_core *)(&(x)->prb_bdqc))
 #define GET_PBLOCK_DESC(x, bid)	\
-	((struct block_desc *)((x)->pkbdq[(bid)].buffer))
+	((struct tpacket_block_desc *)((x)->pkbdq[(bid)].buffer))
 #define GET_CURR_PBLOCK_DESC_FROM_CORE(x)	\
-	((struct block_desc *)((x)->pkbdq[(x)->kactive_blk_num].buffer))
+	((struct tpacket_block_desc *)((x)->pkbdq[(x)->kactive_blk_num].buffer))
 #define GET_NEXT_PRB_BLK_NUM(x) \
 	(((x)->kactive_blk_num < ((x)->knum_blocks-1)) ? \
 	((x)->kactive_blk_num+1) : 0)
@@ -480,7 +484,7 @@ static inline void *packet_current_frame(struct packet_sock *po,
 	return packet_lookup_frame(po, rb, rb->head, status);
 }
 
-static void prb_del_retire_blk_timer(struct kbdq_core *pkc)
+static void prb_del_retire_blk_timer(struct tpacket_kbdq_core *pkc)
 {
 	del_timer_sync(&pkc->retire_blk_timer);
 }
@@ -489,7 +493,7 @@ static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
 		int tx_ring,
 		struct sk_buff_head *rb_queue)
 {
-	struct kbdq_core *pkc;
+	struct tpacket_kbdq_core *pkc;
 
 	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
 
@@ -501,7 +505,7 @@ static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
 }
 
 static void prb_init_blk_timer(struct packet_sock *po,
-		struct kbdq_core *pkc,
+		struct tpacket_kbdq_core *pkc,
 		void (*func) (unsigned long))
 {
 	init_timer(&pkc->retire_blk_timer);
@@ -512,7 +516,7 @@ static void prb_init_blk_timer(struct packet_sock *po,
 
 static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
 {
-	struct kbdq_core *pkc;
+	struct tpacket_kbdq_core *pkc;
 
 	if (tx_ring)
 		BUG();
@@ -568,7 +572,7 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 	return tmo;
 }
 
-static void prb_init_ft_ops(struct kbdq_core *p1,
+static void prb_init_ft_ops(struct tpacket_kbdq_core *p1,
 			union tpacket_req_u *req_u)
 {
 	p1->feature_req_word = req_u->req3.tp_feature_req_word;
@@ -579,14 +583,14 @@ static void init_prb_bdqc(struct packet_sock *po,
 			struct pgv *pg_vec,
 			union tpacket_req_u *req_u, int tx_ring)
 {
-	struct kbdq_core *p1 = &rb->prb_bdqc;
-	struct block_desc *pbd;
+	struct tpacket_kbdq_core *p1 = &rb->prb_bdqc;
+	struct tpacket_block_desc *pbd;
 
 	memset(p1, 0x0, sizeof(*p1));
 
 	p1->knxt_seq_num = 1;
 	p1->pkbdq = pg_vec;
-	pbd = (struct block_desc *)pg_vec[0].buffer;
+	pbd = (struct tpacket_block_desc *)pg_vec[0].buffer;
 	p1->pkblk_start	= (char *)pg_vec[0].buffer;
 	p1->kblk_size = req_u->req3.tp_block_size;
 	p1->knum_blocks	= req_u->req3.tp_block_nr;
@@ -610,7 +614,7 @@ static void init_prb_bdqc(struct packet_sock *po,
 /*  Do NOT update the last_blk_num first.
  *  Assumes sk_buff_head lock is held.
  */
-static void _prb_refresh_rx_retire_blk_timer(struct kbdq_core *pkc)
+static void _prb_refresh_rx_retire_blk_timer(struct tpacket_kbdq_core *pkc)
 {
 	mod_timer(&pkc->retire_blk_timer,
 			jiffies + pkc->tov_in_jiffies);
@@ -643,9 +647,9 @@ static void _prb_refresh_rx_retire_blk_timer(struct kbdq_core *pkc)
 static void prb_retire_rx_blk_timer_expired(unsigned long data)
 {
 	struct packet_sock *po = (struct packet_sock *)data;
-	struct kbdq_core *pkc = &po->rx_ring.prb_bdqc;
+	struct tpacket_kbdq_core *pkc = &po->rx_ring.prb_bdqc;
 	unsigned int frozen;
-	struct block_desc *pbd;
+	struct tpacket_block_desc *pbd;
 
 	spin_lock(&po->sk.sk_receive_queue.lock);
 
@@ -709,8 +713,8 @@ out:
 	spin_unlock(&po->sk.sk_receive_queue.lock);
 }
 
-static inline void prb_flush_block(struct kbdq_core *pkc1,
-		struct block_desc *pbd1, __u32 status)
+static inline void prb_flush_block(struct tpacket_kbdq_core *pkc1,
+		struct tpacket_block_desc *pbd1, __u32 status)
 {
 	/* Flush everything minus the block header */
 
@@ -752,13 +756,14 @@ static inline void prb_flush_block(struct kbdq_core *pkc1,
  * Note:We DONT refresh the timer on purpose.
  *	Because almost always the next block will be opened.
  */
-static void prb_close_block(struct kbdq_core *pkc1, struct block_desc *pbd1,
+static void prb_close_block(struct tpacket_kbdq_core *pkc1,
+		struct tpacket_block_desc *pbd1,
 		struct packet_sock *po, unsigned int stat)
 {
 	__u32 status = TP_STATUS_USER | stat;
 
 	struct tpacket3_hdr *last_pkt;
-	struct hdr_v1 *h1 = &pbd1->hdr.bh1;
+	struct tpacket_hdr_v1 *h1 = &pbd1->hdr.bh1;
 
 	if (po->stats.tp_drops)
 		status |= TP_STATUS_LOSING;
@@ -786,7 +791,7 @@ static void prb_close_block(struct kbdq_core *pkc1, struct block_desc *pbd1,
 	pkc1->kactive_blk_num = GET_NEXT_PRB_BLK_NUM(pkc1);
 }
 
-static inline void prb_thaw_queue(struct kbdq_core *pkc)
+static inline void prb_thaw_queue(struct tpacket_kbdq_core *pkc)
 {
 	pkc->reset_pending_on_curr_blk = 0;
 }
@@ -798,10 +803,11 @@ static inline void prb_thaw_queue(struct kbdq_core *pkc)
  * 2) retire_blk_timer is refreshed.
  *
  */
-static void prb_open_block(struct kbdq_core *pkc1, struct block_desc *pbd1)
+static void prb_open_block(struct tpacket_kbdq_core *pkc1,
+	struct tpacket_block_desc *pbd1)
 {
 	struct timespec ts;
-	struct hdr_v1 *h1 = &pbd1->hdr.bh1;
+	struct tpacket_hdr_v1 *h1 = &pbd1->hdr.bh1;
 
 	smp_rmb();
 
@@ -861,7 +867,7 @@ static void prb_open_block(struct kbdq_core *pkc1, struct block_desc *pbd1)
  *         case and __packet_lookup_frame_in_block will check if block-0
  *         is free and can now be re-used.
  */
-static inline void prb_freeze_queue(struct kbdq_core *pkc,
+static inline void prb_freeze_queue(struct tpacket_kbdq_core *pkc,
 				  struct packet_sock *po)
 {
 	pkc->reset_pending_on_curr_blk = 1;
@@ -876,10 +882,10 @@ static inline void prb_freeze_queue(struct kbdq_core *pkc,
  * Else, we will freeze the queue.
  * So, caller must check the return value.
  */
-static void *prb_dispatch_next_block(struct kbdq_core *pkc,
+static void *prb_dispatch_next_block(struct tpacket_kbdq_core *pkc,
 		struct packet_sock *po)
 {
-	struct block_desc *pbd;
+	struct tpacket_block_desc *pbd;
 
 	smp_rmb();
 
@@ -901,10 +907,10 @@ static void *prb_dispatch_next_block(struct kbdq_core *pkc,
 	return (void *)pkc->nxt_offset;
 }
 
-static void prb_retire_current_block(struct kbdq_core *pkc,
+static void prb_retire_current_block(struct tpacket_kbdq_core *pkc,
 		struct packet_sock *po, unsigned int status)
 {
-	struct block_desc *pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+	struct tpacket_block_desc *pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
 
 	/* retire/close the current block */
 	if (likely(TP_STATUS_KERNEL == BLOCK_STATUS(pbd))) {
@@ -932,36 +938,36 @@ static void prb_retire_current_block(struct kbdq_core *pkc,
 	BUG();
 }
 
-static inline int prb_curr_blk_in_use(struct kbdq_core *pkc,
-				      struct block_desc *pbd)
+static inline int prb_curr_blk_in_use(struct tpacket_kbdq_core *pkc,
+				      struct tpacket_block_desc *pbd)
 {
 	return TP_STATUS_USER & BLOCK_STATUS(pbd);
 }
 
-static inline int prb_queue_frozen(struct kbdq_core *pkc)
+static inline int prb_queue_frozen(struct tpacket_kbdq_core *pkc)
 {
 	return pkc->reset_pending_on_curr_blk;
 }
 
 static inline void prb_clear_blk_fill_status(struct packet_ring_buffer *rb)
 {
-	struct kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
+	struct tpacket_kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
 	atomic_dec(&pkc->blk_fill_in_prog);
 }
 
-static inline void prb_fill_rxhash(struct kbdq_core *pkc,
+static inline void prb_fill_rxhash(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
 	ppd->hv1.tp_rxhash = skb_get_rxhash(pkc->skb);
 }
 
-static inline void prb_clear_rxhash(struct kbdq_core *pkc,
+static inline void prb_clear_rxhash(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
 	ppd->hv1.tp_rxhash = 0;
 }
 
-static inline void prb_fill_vlan_info(struct kbdq_core *pkc,
+static inline void prb_fill_vlan_info(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
 	if (vlan_tx_tag_present(pkc->skb)) {
@@ -972,7 +978,7 @@ static inline void prb_fill_vlan_info(struct kbdq_core *pkc,
 	}
 }
 
-static void prb_run_all_ft_ops(struct kbdq_core *pkc,
+static void prb_run_all_ft_ops(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
 	prb_fill_vlan_info(pkc, ppd);
@@ -983,8 +989,9 @@ static void prb_run_all_ft_ops(struct kbdq_core *pkc,
 		prb_clear_rxhash(pkc, ppd);
 }
 
-static inline void prb_fill_curr_block(char *curr, struct kbdq_core *pkc,
-				struct block_desc *pbd,
+static inline void prb_fill_curr_block(char *curr,
+				struct tpacket_kbdq_core *pkc,
+				struct tpacket_block_desc *pbd,
 				unsigned int len)
 {
 	struct tpacket3_hdr *ppd;
@@ -1006,8 +1013,8 @@ static void *__packet_lookup_frame_in_block(struct packet_sock *po,
 					    unsigned int len
 					    )
 {
-	struct kbdq_core *pkc;
-	struct block_desc *pbd;
+	struct tpacket_kbdq_core *pkc;
+	struct tpacket_block_desc *pbd;
 	char *curr, *end;
 
 	pkc = GET_PBDQC_FROM_RB(((struct packet_ring_buffer *)&po->rx_ring));
@@ -1087,8 +1094,8 @@ static inline void *prb_lookup_block(struct packet_sock *po,
 				     unsigned int previous,
 				     int status)
 {
-	struct kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
-	struct block_desc *pbd = GET_PBLOCK_DESC(pkc, previous);
+	struct tpacket_kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
+	struct tpacket_block_desc *pbd = GET_PBLOCK_DESC(pkc, previous);
 
 	if (status != BLOCK_STATUS(pbd))
 		return NULL;
-- 
1.7.5.2
