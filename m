From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next v3 af-packet 2/2] Enhance af-packet to provide (near zero)lossless packet capture functionality.
Date: Sun, 17 Jul 2011 23:26:50 -0400
Message-ID: <1310959610-1688-3-git-send-email-loke.chetan@gmail.com>
References: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
Cc: Chetan Loke <loke.chetan@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:48847 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684Ab1GRD1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 23:27:51 -0400
Received: by qwk3 with SMTP id 3so1311015qwk.19
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 20:27:50 -0700 (PDT)
In-Reply-To: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Blocks can now be configured with non-static frame format.
   Non-static frame format provides following benefits:
   1.1) Increases packet density by a factor of 2x.
   1.2) Ability to capture entire packet.
   1.3) Captures 99% 64-byte traffic as seen by the kernel.
2) Read/poll is now at a block-level rather than at packet level.
3) Added user-configurable timeout knob for timing out blocks on slow/bursty links.
4) Block level processing now allows monitoring multiple links as a single
   logical pipe.

Changes:
C1) tpacket_rcv()
    C1.1) packet_current_frame() is replaced by packet_current_rx_frame()
          The bulk of the processing is then moved in the following chain:
          packet_current_rx_frame()
            __packet_lookup_frame_in_block
              fill_curr_block()
              or
                retire_current_block
                dispatch_next_block
              or
              return NULL(queue is plugged/paused)

Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
---
 net/packet/af_packet.c |  920 +++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 874 insertions(+), 46 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c698cec..a6df380 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -40,6 +40,10 @@
  *					byte arrays at the end of sockaddr_ll
  *					and packet_mreq.
  *		Johann Baudy	:	Added TX RING.
+ *		Chetan Loke	:	Implemented TPACKET_V3 block abstraction
+ *					layer.
+ *					Copyright (C) 2011, <lokec@ccs.neu.edu>
+ *
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -161,9 +165,62 @@ struct packet_mreq_max {
 	unsigned char	mr_address[MAX_ADDR_LEN];
 };
 
-static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
+static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		int closing, int tx_ring);
 
+
+#define V3_ALIGNMENT	(8)
+#define ALIGN_V3(x)	(((x)+V3_ALIGNMENT-1)&~(V3_ALIGNMENT-1))
+
+#define BLK_HDR_LEN	(ALIGN_V3(sizeof(struct block_desc)))
+
+#define BLK_PLUS_PRIV(sz_of_priv) \
+	(BLK_HDR_LEN + ALIGN_V3((sz_of_priv)))
+
+struct kbdq_ft_ops {
+	int num_ops;
+	int (*fn_ptrs[1])(void *, void *);
+};
+
+/* kbdq - kernel block descriptor queue */
+struct kbdq_core {
+	struct pgv	*pkbdq;
+	unsigned int	hdrlen;
+	unsigned char	reset_pending_on_curr_blk;
+	unsigned char   delete_blk_timer;
+	unsigned short	kactive_blk_num;
+	unsigned short	blk_sizeof_priv;
+
+	/* last_kactive_blk_num:
+	 * trick to see if user-space has caught up
+	 * in order to avoid refreshing timer when every single pkt arrives.
+	 */
+	unsigned short	last_kactive_blk_num;
+
+	char		*pkblk_start;
+	char		*pkblk_end;
+	int		kblk_size;
+	unsigned int	knum_blocks;
+	uint64_t	knxt_seq_num;
+	char		*prev;
+	char		*nxt_offset;
+	struct sk_buff	*skb;
+	struct kbdq_ft_ops kfops;
+
+	atomic_t	blk_fill_in_prog;
+
+	/* Default is set to 8ms */
+#define DEFAULT_PRB_RETIRE_TOV	(8)
+
+	unsigned short  retire_blk_tov;
+	unsigned short  version;
+	unsigned long	tov_in_jiffies;
+
+	/* timer to retire an outstanding block */
+	struct timer_list retire_blk_timer;
+};
+
+#define PGV_FROM_VMALLOC 1
 struct pgv {
 	char *buffer;
 };
@@ -179,12 +236,31 @@ struct packet_ring_buffer {
 	unsigned int		pg_vec_pages;
 	unsigned int		pg_vec_len;
 
+	struct kbdq_core	prb_bdqc;
 	atomic_t		pending;
 };
 
 struct packet_sock;
 static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
 
+static void *packet_previous_frame(struct packet_sock *po,
+		struct packet_ring_buffer *rb,
+		int status);
+static void packet_increment_head(struct packet_ring_buffer *buff);
+static int prb_curr_blk_in_use(struct kbdq_core *,
+			struct block_desc *);
+static void *prb_dispatch_next_block(struct kbdq_core *,
+			struct packet_sock *);
+static void prb_retire_current_block(struct kbdq_core *,
+		struct packet_sock *, unsigned int status);
+static int prb_queue_frozen(struct kbdq_core *);
+static void prb_open_block(struct kbdq_core *, struct block_desc *);
+static void prb_retire_rx_blk_timer_expired(unsigned long);
+static void _prb_refresh_rx_retire_blk_timer(struct kbdq_core *);
+static void prb_init_blk_timer(struct packet_sock *, struct kbdq_core *,
+				void (*func) (unsigned long));
+static void prb_fill_rxhash(struct kbdq_core *,
+			struct tpacket3_hdr *);
 static void packet_flush_mclist(struct sock *sk);
 
 struct packet_fanout;
@@ -193,6 +269,7 @@ struct packet_sock {
 	struct sock		sk;
 	struct packet_fanout	*fanout;
 	struct tpacket_stats	stats;
+	union  tpacket_stats_u	stats_u;
 	struct packet_ring_buffer	rx_ring;
 	struct packet_ring_buffer	tx_ring;
 	int			copy_thresh;
@@ -242,6 +319,15 @@ struct packet_skb_cb {
 
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
 
+#define GET_PBDQC_FROM_RB(x)	((struct kbdq_core *)(&(x)->prb_bdqc))
+#define GET_PBLOCK_DESC(x, bid)	\
+	((struct block_desc *)((x)->pkbdq[(bid)].buffer))
+#define GET_CURR_PBLOCK_DESC_FROM_CORE(x)	\
+	((struct block_desc *)((x)->pkbdq[(x)->kactive_blk_num].buffer))
+#define GET_NEXT_PRB_BLK_NUM(x) \
+	(((x)->kactive_blk_num < ((x)->knum_blocks-1)) ? \
+	((x)->kactive_blk_num+1) : 0)
+
 static inline struct packet_sock *pkt_sk(struct sock *sk)
 {
 	return (struct packet_sock *)sk;
@@ -325,8 +411,9 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
 		h.h2->tp_status = status;
 		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		break;
+	case TPACKET_V3:
 	default:
-		pr_err("TPACKET version not supported\n");
+		WARN(1, "TPACKET version not supported.\n");
 		BUG();
 	}
 
@@ -351,8 +438,9 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
 	case TPACKET_V2:
 		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		return h.h2->tp_status;
+	case TPACKET_V3:
 	default:
-		pr_err("TPACKET version not supported\n");
+		WARN(1, "TPACKET version not supported.\n");
 		BUG();
 		return 0;
 	}
@@ -389,6 +477,644 @@ static inline void *packet_current_frame(struct packet_sock *po,
 	return packet_lookup_frame(po, rb, rb->head, status);
 }
 
+static void prb_del_retire_blk_timer(struct kbdq_core *pkc)
+{
+	del_timer_sync(&pkc->retire_blk_timer);
+}
+
+static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
+		int tx_ring,
+		struct sk_buff_head *rb_queue)
+{
+	struct kbdq_core *pkc;
+
+	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
+
+	spin_lock(&rb_queue->lock);
+	pkc->delete_blk_timer = 1;
+	spin_unlock(&rb_queue->lock);
+
+	prb_del_retire_blk_timer(pkc);
+}
+
+static void prb_init_blk_timer(struct packet_sock *po,
+		struct kbdq_core *pkc,
+		void (*func) (unsigned long))
+{
+	init_timer(&pkc->retire_blk_timer);
+	pkc->retire_blk_timer.data = (long)po;
+	pkc->retire_blk_timer.function = func;
+	pkc->retire_blk_timer.expires = jiffies;
+}
+
+static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
+{
+	struct kbdq_core *pkc;
+
+	if (tx_ring)
+		BUG();
+
+	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
+	prb_init_blk_timer(po, pkc, prb_retire_rx_blk_timer_expired);
+}
+
+static int prb_calc_retire_blk_tmo(struct packet_sock *po,
+				int blk_size_in_bytes)
+{
+	struct net_device *dev;
+	unsigned int mbits = 0, msec = 0, div = 0, tmo = 0;
+
+	dev = dev_get_by_index(sock_net(&po->sk), po->ifindex);
+	if (unlikely(dev == NULL))
+		return DEFAULT_PRB_RETIRE_TOV;
+
+	if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
+		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET, };
+
+		if (!dev->ethtool_ops->get_settings(dev, &ecmd)) {
+			switch (ecmd.speed) {
+			case SPEED_10000:
+				msec = 1;
+				div = 10000/1000;
+				break;
+			case SPEED_1000:
+				msec = 1;
+				div = 1000/1000;
+				break;
+			/*
+			 * If the link speed is so slow you don't really
+			 * need to worry about perf anyways
+			 */
+			case SPEED_100:
+			case SPEED_10:
+			default:
+				return DEFAULT_PRB_RETIRE_TOV;
+			}
+		}
+	}
+
+	mbits = (blk_size_in_bytes * 8) / (1024 * 1024);
+
+	if (div)
+		mbits /= div;
+
+	tmo = mbits * msec;
+
+	if (div)
+		return tmo+1;
+	return tmo;
+}
+
+static void init_prb_bdqc(struct packet_sock *po,
+			struct packet_ring_buffer *rb,
+			struct pgv *pg_vec,
+			union tpacket_req_u *req_u, int tx_ring)
+{
+	struct kbdq_core *p1 = &rb->prb_bdqc;
+	struct block_desc *pbd;
+
+	memset(p1, 0x0, sizeof(*p1));
+
+	if (req_u->req3.tp_feature_req_word) {
+		if (req_u->req3.tp_feature_req_word & TP_FT_REQ_FILL_RXHASH) {
+			p1->kfops.fn_ptrs[p1->kfops.num_ops] = prb_fill_rxhash;
+			p1->kfops.num_ops += 1;
+		}
+	}
+
+	p1->knxt_seq_num = 1;
+	p1->pkbdq = pg_vec;
+	pbd = (struct block_desc *)pg_vec[0].buffer;
+	p1->pkblk_start	= (char *)pg_vec[0].buffer;
+	p1->kblk_size = req_u->req3.tp_block_size;
+	p1->knum_blocks	= req_u->req3.tp_block_nr;
+	p1->hdrlen = po->tp_hdrlen;
+	p1->version = po->tp_version;
+	p1->last_kactive_blk_num = 0;
+	po->stats_u.stats3.tp_freeze_q_cnt = 0;
+	if (req_u->req3.tp_retire_blk_tov)
+		p1->retire_blk_tov = req_u->req3.tp_retire_blk_tov;
+	else
+		p1->retire_blk_tov = prb_calc_retire_blk_tmo(po,
+						req_u->req3.tp_block_size);
+	p1->tov_in_jiffies = msecs_to_jiffies(p1->retire_blk_tov);
+	p1->blk_sizeof_priv = req_u->req3.tp_sizeof_priv;
+	prb_setup_retire_blk_timer(po, tx_ring);
+	prb_open_block(p1, pbd);
+}
+
+/*  Do NOT update the last_blk_num first.
+ *  Assumes sk_buff_head lock is held.
+ */
+static void _prb_refresh_rx_retire_blk_timer(struct kbdq_core *pkc)
+{
+	mod_timer(&pkc->retire_blk_timer,
+			jiffies + pkc->tov_in_jiffies);
+	pkc->last_kactive_blk_num = pkc->kactive_blk_num;
+}
+
+/*
+ * Timer logic:
+ * 1) We refresh the timer only when we open a block.
+ *    By doing this we don't waste cycles refreshing the timer
+ *	  on packet-by-packet basis.
+ *
+ * With a 1MB block-size, on a 1Gbps line, it will take
+ * i) ~8 ms to fill a block + ii) memcpy etc.
+ * In this cut we are not accounting for the memcpy time.
+ *
+ * So, if the user sets the 'tmo' to 10ms then the timer
+ * will never fire while the block is still getting filled
+ * (which is what we want). However, the user could choose
+ * to close a block early and that's fine.
+ *
+ * But when the timer does fire, we check whether or not to refresh it.
+ * Since the tmo granularity is in msecs, it is not too expensive
+ * to refresh the timer, lets say every '8' msecs.
+ * Either the user can set the 'tmo' or we can derive it based on
+ * a) line-speed and b) block-size.
+ * prb_calc_retire_blk_tmo() calculates the tmo.
+ *
+ */
+static void prb_retire_rx_blk_timer_expired(unsigned long data)
+{
+	struct packet_sock *po = (struct packet_sock *)data;
+	struct kbdq_core *pkc = &po->rx_ring.prb_bdqc;
+	unsigned int frozen;
+	struct block_desc *pbd;
+
+	spin_lock(&po->sk.sk_receive_queue.lock);
+
+	frozen = prb_queue_frozen(pkc);
+	pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+
+	if (unlikely(pkc->delete_blk_timer))
+		goto out;
+
+	/* We only need to plug the race when the block is partially filled.
+	 * tpacket_rcv:
+	 *		lock(); increment BLOCK_NUM_PKTS; unlock()
+	 *		copy_bits() is in progress ...
+	 *		timer fires on other cpu:
+	 *		we can't retire the current block because copy_bits
+	 *		is in progress.
+	 *
+	 */
+	if (BLOCK_NUM_PKTS(pbd)) {
+		while (atomic_read(&pkc->blk_fill_in_prog)) {
+			/* Waiting for skb_copy_bits to finish... */
+			cpu_relax();
+		}
+	}
+
+	if (pkc->last_kactive_blk_num == pkc->kactive_blk_num) {
+		if (!frozen) {
+			prb_retire_current_block(pkc, po, TP_STATUS_BLK_TMO);
+			if (!prb_dispatch_next_block(pkc, po))
+				goto refresh_timer;
+			else
+				goto out;
+		} else {
+			/* Case 1. Queue was frozen because user-space was
+			 *	   lagging behind.
+			 */
+			if (prb_curr_blk_in_use(pkc, pbd)) {
+				/*
+				 * Ok, user-space is still behind.
+				 * So just refresh the timer.
+				 */
+				goto refresh_timer;
+			} else {
+			       /* Case 2. queue was frozen,user-space caught up,
+				* now the link went idle && the timer fired.
+				* We don't have a block to close.So we open this
+				* block and restart the timer.
+				* opening a block thaws the queue,restarts timer
+				* Thawing/timer-refresh is a side effect.
+				*/
+				prb_open_block(pkc, pbd);
+				goto out;
+			}
+		}
+	}
+
+refresh_timer:
+	_prb_refresh_rx_retire_blk_timer(pkc);
+
+out:
+	spin_unlock(&po->sk.sk_receive_queue.lock);
+}
+
+static inline void prb_flush_block(struct kbdq_core *pkc1,
+		struct block_desc *pbd1, __u32 status)
+{
+	/* Flush everything minus the block header */
+
+#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
+	u8 *start, *end;
+
+	start = (u8 *)pbd1;
+
+	/* Skip the block header(we know header WILL fit in 4K) */
+	start += PAGE_SIZE;
+
+	end = (u8 *)PAGE_ALIGN((unsigned long)pkc1->pkblk_end);
+	for (; start < end; start += PAGE_SIZE)
+		flush_dcache_page(pgv_to_page(start));
+
+	smp_wmb();
+#endif
+
+	/* Now update the block status. */
+
+	BLOCK_STATUS(pbd1) = status;
+
+	/* Flush the block header */
+
+#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
+	start = (u8 *)pbd1;
+	flush_dcache_page(pgv_to_page(start));
+
+	smp_wmb();
+#endif
+}
+
+/*
+ * Side effect:
+ *
+ * 1) flush the block
+ * 2) Increment active_blk_num
+ *
+ * Note:We DONT refresh the timer on purpose.
+ *	Because almost always the next block will be opened.
+ */
+static void prb_close_block(struct kbdq_core *pkc1, struct block_desc *pbd1,
+		struct packet_sock *po, unsigned int stat)
+{
+	__u32 status = TP_STATUS_USER | stat;
+
+	struct tpacket3_hdr *last_pkt;
+	struct hdr_v1 *h1 = &pbd1->hdr.h1;
+
+	if (po->stats.tp_drops)
+		status |= TP_STATUS_LOSING;
+
+	last_pkt = (struct tpacket3_hdr *)pkc1->prev;
+	last_pkt->tp_next_offset = 0;
+
+	/* Get the ts of the last pkt */
+	if (BLOCK_NUM_PKTS(pbd1)) {
+		h1->ts_last_pkt.ts_sec = last_pkt->tp_sec;
+		h1->ts_last_pkt.ts_nsec	= last_pkt->tp_nsec;
+	} else {
+		/* Ok, we tmo'd - so get the current time */
+		struct timespec ts;
+		getnstimeofday(&ts);
+		h1->ts_last_pkt.ts_sec = ts.tv_sec;
+		h1->ts_last_pkt.ts_nsec	= ts.tv_nsec;
+	}
+
+	smp_wmb();
+
+	/* Flush the block */
+	prb_flush_block(pkc1, pbd1, status);
+
+	pkc1->kactive_blk_num = GET_NEXT_PRB_BLK_NUM(pkc1);
+}
+
+static inline void prb_thaw_queue(struct kbdq_core *pkc)
+{
+	pkc->reset_pending_on_curr_blk = 0;
+}
+
+/*
+ * Side effect of opening a block:
+ *
+ * 1) prb_queue is thawed.
+ * 2) retire_blk_timer is refreshed.
+ *
+ */
+static void prb_open_block(struct kbdq_core *pkc1, struct block_desc *pbd1)
+{
+	struct timespec ts;
+	struct hdr_v1 *h1 = &pbd1->hdr.h1;
+
+	smp_rmb();
+
+	if (likely(TP_STATUS_KERNEL == BLOCK_STATUS(pbd1))) {
+
+		/* We could have just memset this but we will lose the
+		 * flexibility of making the priv area sticky
+		 */
+		BLOCK_SNUM(pbd1) = pkc1->knxt_seq_num++;
+		BLOCK_NUM_PKTS(pbd1) = 0;
+		BLOCK_LEN(pbd1) = BLK_PLUS_PRIV(pkc1->blk_sizeof_priv);
+		getnstimeofday(&ts);
+		h1->ts_first_pkt.ts_sec = ts.tv_sec;
+		h1->ts_first_pkt.ts_nsec = ts.tv_nsec;
+		pkc1->pkblk_start = (char *)pbd1;
+		pkc1->nxt_offset = (char *)(pkc1->pkblk_start +
+		BLK_PLUS_PRIV(pkc1->blk_sizeof_priv));
+		BLOCK_O2FP(pbd1) = (__u32)BLK_PLUS_PRIV(pkc1->blk_sizeof_priv);
+		BLOCK_O2PRIV(pbd1) = (__u16)BLK_HDR_LEN;
+		pbd1->version = pkc1->version;
+		pkc1->prev = pkc1->nxt_offset;
+		pkc1->pkblk_end = pkc1->pkblk_start + pkc1->kblk_size;
+		prb_thaw_queue(pkc1);
+		_prb_refresh_rx_retire_blk_timer(pkc1);
+
+		smp_wmb();
+
+		return;
+	}
+
+	WARN(1, "ERROR block:%p is NOT FREE status:%d kactive_blk_num:%d\n",
+		pbd1, BLOCK_STATUS(pbd1), pkc1->kactive_blk_num);
+	dump_stack();
+	BUG();
+}
+
+/*
+ * Queue freeze logic:
+ * 1) Assume tp_block_nr = 8 blocks.
+ * 2) At time 't0', user opens Rx ring.
+ * 3) Some time past 't0', kernel starts filling blocks starting from 0 .. 7
+ * 4) user-space is either sleeping or processing block '0'.
+ * 5) tpacket_rcv is currently filling block '7', since there is no space left,
+ *    it will close block-7,loop around and try to fill block '0'.
+ *    call-flow:
+ *    __packet_lookup_frame_in_block
+ *      prb_retire_current_block()
+ *      prb_dispatch_next_block()
+ *        |->(BLOCK_STATUS == USER) evaluates to true
+ *    5.1) Since block-0 is currently in-use, we just freeze the queue.
+ * 6) Now there are two cases:
+ *    6.1) Link goes idle right after the queue is frozen.
+ *         But remember, the last open_block() refreshed the timer.
+ *         When this timer expires,it will refresh itself so that we can
+ *         re-open block-0 in near future.
+ *    6.2) Link is busy and keeps on receiving packets. This is a simple
+ *         case and __packet_lookup_frame_in_block will check if block-0
+ *         is free and can now be re-used.
+ */
+static inline void prb_freeze_queue(struct kbdq_core *pkc,
+				  struct packet_sock *po)
+{
+	pkc->reset_pending_on_curr_blk = 1;
+	po->stats_u.stats3.tp_freeze_q_cnt++;
+}
+
+#define TOTAL_PKT_LEN_INCL_ALIGN(length) (ALIGN_V3((length)))
+
+/*
+ * If the next block is free then we will dispatch it
+ * and return a good offset.
+ * Else, we will freeze the queue.
+ * So, caller must check the return value.
+ */
+static void *prb_dispatch_next_block(struct kbdq_core *pkc,
+		struct packet_sock *po)
+{
+	struct block_desc *pbd;
+
+	smp_rmb();
+
+	/* 1. Get current block num */
+	pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+
+	/* 2. If this block is currently in_use then freeze the queue */
+	if (TP_STATUS_USER & BLOCK_STATUS(pbd)) {
+		prb_freeze_queue(pkc, po);
+		return NULL;
+	}
+
+	/*
+	 * 3.
+	 * open this block and return the offset where the first packet
+	 * needs to get stored.
+	 */
+	prb_open_block(pkc, pbd);
+	return (void *)pkc->nxt_offset;
+}
+
+static void prb_retire_current_block(struct kbdq_core *pkc,
+		struct packet_sock *po, unsigned int status)
+{
+	struct block_desc *pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+
+	/* retire/close the current block */
+	if (likely(TP_STATUS_KERNEL == BLOCK_STATUS(pbd))) {
+		/*
+		 * Plug the case where copy_bits() is in progress on
+		 * cpu-0 and tpacket_rcv() got invoked on cpu-1, didn't
+		 * have space to copy the pkt in the current block and
+		 * called prb_retire_current_block()
+		 *
+		 * We don't need to worry about the TMO case because
+		 * the timer-handler already handled this case.
+		 */
+		if (!(status & TP_STATUS_BLK_TMO)) {
+			while (atomic_read(&pkc->blk_fill_in_prog)) {
+				/* Waiting for skb_copy_bits to finish... */
+				cpu_relax();
+			}
+		}
+		prb_close_block(pkc, pbd, po, status);
+		return;
+	}
+
+	WARN(1, "ERROR-pbd[%d]:%p\n", pkc->kactive_blk_num, pbd);
+	dump_stack();
+	BUG();
+}
+
+static inline int prb_curr_blk_in_use(struct kbdq_core *pkc,
+				      struct block_desc *pbd)
+{
+	return TP_STATUS_USER & BLOCK_STATUS(pbd);
+}
+
+static inline int prb_queue_frozen(struct kbdq_core *pkc)
+{
+	return pkc->reset_pending_on_curr_blk;
+}
+
+static inline void prb_clear_blk_fill_status(struct packet_ring_buffer *rb)
+{
+	struct kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
+	atomic_dec(&pkc->blk_fill_in_prog);
+}
+
+static void prb_fill_rxhash(struct kbdq_core *pkc,
+			struct tpacket3_hdr *ppd)
+{
+	ppd->tp_rxhash = skb_get_rxhash(pkc->skb);
+}
+
+static void prb_run_all_ft_ops(struct kbdq_core *pkc,
+			struct tpacket3_hdr *ppd)
+{
+	int ops;
+	for (ops = 0; ops < pkc->kfops.num_ops; ops++)
+		pkc->kfops.fn_ptrs[ops](pkc, ppd);
+}
+
+static inline void prb_fill_curr_block(char *curr, struct kbdq_core *pkc,
+				struct block_desc *pbd,
+				unsigned int len)
+{
+	struct tpacket3_hdr *ppd;
+
+	ppd  = (struct tpacket3_hdr *)curr;
+	ppd->tp_next_offset = TOTAL_PKT_LEN_INCL_ALIGN(len);
+	pkc->prev = curr;
+	pkc->nxt_offset += TOTAL_PKT_LEN_INCL_ALIGN(len);
+	BLOCK_LEN(pbd) += TOTAL_PKT_LEN_INCL_ALIGN(len);
+	BLOCK_NUM_PKTS(pbd) += 1;
+	atomic_inc(&pkc->blk_fill_in_prog);
+	prb_run_all_ft_ops(pkc, ppd);
+}
+
+/* Assumes caller has the sk->rx_queue.lock */
+static void *__packet_lookup_frame_in_block(struct packet_sock *po,
+					    struct sk_buff *skb,
+						int status,
+					    unsigned int len
+					    )
+{
+	struct kbdq_core *pkc;
+	struct block_desc *pbd;
+	char *curr, *end;
+
+	pkc = GET_PBDQC_FROM_RB(((struct packet_ring_buffer *)&po->rx_ring));
+	pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+	pkc->skb = skb;
+
+	/* Queue is frozen when user space is lagging behind */
+	if (prb_queue_frozen(pkc)) {
+		/*
+		 * Check if that last block which caused the queue to freeze,
+		 * is still in_use by user-space.
+		 */
+		if (prb_curr_blk_in_use(pkc, pbd)) {
+			/* Can't record this packet */
+			return NULL;
+		} else {
+			/*
+			 * Ok, the block was released by user-space.
+			 * Now let's open that block.
+			 * opening a block also thaws the queue.
+			 * Thawing is a side effect.
+			 */
+			prb_open_block(pkc, pbd);
+		}
+	}
+
+	smp_mb();
+	curr = pkc->nxt_offset;
+	end = (char *) ((char *)pbd + pkc->kblk_size);
+
+	/* first try the current block */
+	if (curr+TOTAL_PKT_LEN_INCL_ALIGN(len) < end) {
+		prb_fill_curr_block(curr, pkc, pbd, len);
+		return (void *)curr;
+	}
+
+	/* Ok, close the current block */
+	prb_retire_current_block(pkc, po, 0);
+
+	/* Now, try to dispatch the next block */
+	curr = (char *)prb_dispatch_next_block(pkc, po);
+	if (curr) {
+		pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+		prb_fill_curr_block(curr, pkc, pbd, len);
+		return (void *)curr;
+	}
+
+	/*
+	 * No free blocks are available.user_space hasn't caught up yet.
+	 * Queue was just frozen and now this packet will get dropped.
+	 */
+	return NULL;
+}
+
+static inline void *packet_current_rx_frame(struct packet_sock *po,
+					    struct sk_buff *skb,
+					    int status, unsigned int len)
+{
+	char *curr = NULL;
+	switch (po->tp_version) {
+	case TPACKET_V1:
+	case TPACKET_V2:
+		curr = packet_lookup_frame(po, &po->rx_ring,
+					po->rx_ring.head, status);
+		return curr;
+	case TPACKET_V3:
+		return __packet_lookup_frame_in_block(po, skb, status, len);
+	default:
+		WARN(1, "TPACKET version not supported\n");
+		BUG();
+		return 0;
+	}
+}
+
+static inline void *prb_lookup_block(struct packet_sock *po,
+				     struct packet_ring_buffer *rb,
+				     unsigned int previous,
+				     int status)
+{
+	struct kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
+	struct block_desc *pbd = GET_PBLOCK_DESC(pkc, previous);
+
+	if (status != BLOCK_STATUS(pbd))
+		return NULL;
+	return pbd;
+}
+
+static inline int prb_previous_blk_num(struct packet_ring_buffer *rb)
+{
+	unsigned int prev;
+	if (rb->prb_bdqc.kactive_blk_num)
+		prev = rb->prb_bdqc.kactive_blk_num-1;
+	else
+		prev = rb->prb_bdqc.knum_blocks-1;
+	return prev;
+}
+
+/* Assumes caller has held the rx_queue.lock */
+static inline void *__prb_previous_block(struct packet_sock *po,
+					 struct packet_ring_buffer *rb,
+					 int status)
+{
+	unsigned int previous = prb_previous_blk_num(rb);
+	return prb_lookup_block(po, rb, previous, status);
+}
+
+static inline void *packet_previous_rx_frame(struct packet_sock *po,
+					     struct packet_ring_buffer *rb,
+					     int status)
+{
+	if (po->tp_version <= TPACKET_V2)
+		return packet_previous_frame(po, rb, status);
+
+	return __prb_previous_block(po, rb, status);
+}
+
+static inline void packet_increment_rx_head(struct packet_sock *po,
+					    struct packet_ring_buffer *rb)
+{
+	switch (po->tp_version) {
+	case TPACKET_V1:
+	case TPACKET_V2:
+		return packet_increment_head(rb);
+	case TPACKET_V3:
+	default:
+		WARN(1, "TPACKET version not supported.\n");
+		BUG();
+		return;
+	}
+}
+
 static inline void *packet_previous_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status)
@@ -982,12 +1708,13 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	union {
 		struct tpacket_hdr *h1;
 		struct tpacket2_hdr *h2;
+		struct tpacket3_hdr *h3;
 		void *raw;
 	} h;
 	u8 *skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
-	unsigned long status = TP_STATUS_LOSING|TP_STATUS_USER;
+	unsigned long status = TP_STATUS_USER;
 	unsigned short macoff, netoff, hdrlen;
 	struct sk_buff *copy_skb = NULL;
 	struct timeval tv;
@@ -1033,37 +1760,46 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 			po->tp_reserve;
 		macoff = netoff - maclen;
 	}
-
-	if (macoff + snaplen > po->rx_ring.frame_size) {
-		if (po->copy_thresh &&
-		    atomic_read(&sk->sk_rmem_alloc) + skb->truesize <
-		    (unsigned)sk->sk_rcvbuf) {
-			if (skb_shared(skb)) {
-				copy_skb = skb_clone(skb, GFP_ATOMIC);
-			} else {
-				copy_skb = skb_get(skb);
-				skb_head = skb->data;
+	if (po->tp_version <= TPACKET_V2) {
+		if (macoff + snaplen > po->rx_ring.frame_size) {
+			if (po->copy_thresh &&
+				atomic_read(&sk->sk_rmem_alloc) + skb->truesize
+				< (unsigned)sk->sk_rcvbuf) {
+				if (skb_shared(skb)) {
+					copy_skb = skb_clone(skb, GFP_ATOMIC);
+				} else {
+					copy_skb = skb_get(skb);
+					skb_head = skb->data;
+				}
+				if (copy_skb)
+					skb_set_owner_r(copy_skb, sk);
 			}
-			if (copy_skb)
-				skb_set_owner_r(copy_skb, sk);
+			snaplen = po->rx_ring.frame_size - macoff;
+			if ((int)snaplen < 0)
+				snaplen = 0;
 		}
-		snaplen = po->rx_ring.frame_size - macoff;
-		if ((int)snaplen < 0)
-			snaplen = 0;
 	}
-
 	spin_lock(&sk->sk_receive_queue.lock);
-	h.raw = packet_current_frame(po, &po->rx_ring, TP_STATUS_KERNEL);
+	h.raw = packet_current_rx_frame(po, skb,
+					TP_STATUS_KERNEL, (macoff+snaplen));
 	if (!h.raw)
 		goto ring_is_full;
-	packet_increment_head(&po->rx_ring);
+	if (po->tp_version <= TPACKET_V2) {
+		packet_increment_rx_head(po, &po->rx_ring);
+	/*
+	 * LOSING will be reported till you read the stats,
+	 * because it's COR - Clear On Read.
+	 * Anyways, moving it for V1/V2 only as V3 doesn't need this
+	 * at packet level.
+	 */
+		if (po->stats.tp_drops)
+			status |= TP_STATUS_LOSING;
+	}
 	po->stats.tp_packets++;
 	if (copy_skb) {
 		status |= TP_STATUS_COPY;
 		__skb_queue_tail(&sk->sk_receive_queue, copy_skb);
 	}
-	if (!po->stats.tp_drops)
-		status &= ~TP_STATUS_LOSING;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
@@ -1114,6 +1850,36 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		h.h2->tp_padding = 0;
 		hdrlen = sizeof(*h.h2);
 		break;
+	case TPACKET_V3:
+		/* tp_nxt_offset is already populated above.
+		 * So DONT clear those fields here
+		 */
+		h.h3->tp_status = status;
+		h.h3->tp_len = skb->len;
+		h.h3->tp_snaplen = snaplen;
+		h.h3->tp_mac = macoff;
+		h.h3->tp_net = netoff;
+		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
+				&& shhwtstamps->syststamp.tv64)
+			ts = ktime_to_timespec(shhwtstamps->syststamp);
+		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
+				&& shhwtstamps->hwtstamp.tv64)
+			ts = ktime_to_timespec(shhwtstamps->hwtstamp);
+		else if (skb->tstamp.tv64)
+			ts = ktime_to_timespec(skb->tstamp);
+		else
+			getnstimeofday(&ts);
+		h.h3->tp_sec  = ts.tv_sec;
+		h.h3->tp_nsec = ts.tv_nsec;
+		if (vlan_tx_tag_present(skb)) {
+			h.h3->tp_vlan_tci = vlan_tx_tag_get(skb);
+			h.h3->tp_status |= TP_STATUS_VLAN_VALID;
+		} else {
+			h.h3->tp_vlan_tci = 0;
+		}
+		h.h3->tp_padding = 0;
+		hdrlen = sizeof(*h.h3);
+		break;
 	default:
 		BUG();
 	}
@@ -1134,13 +1900,19 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	{
 		u8 *start, *end;
 
-		end = (u8 *)PAGE_ALIGN((unsigned long)h.raw + macoff + snaplen);
-		for (start = h.raw; start < end; start += PAGE_SIZE)
-			flush_dcache_page(pgv_to_page(start));
+		if (po->tp_version <= TPACKET_V2) {
+			end = (u8 *)PAGE_ALIGN((unsigned long)h.raw
+				+ macoff + snaplen);
+			for (start = h.raw; start < end; start += PAGE_SIZE)
+				flush_dcache_page(pgv_to_page(start));
+		}
 		smp_wmb();
 	}
 #endif
-	__packet_set_status(po, h.raw, status);
+	if (po->tp_version <= TPACKET_V2)
+		__packet_set_status(po, h.raw, status);
+	else
+		prb_clear_blk_fill_status(&po->rx_ring);
 
 	sk->sk_data_ready(sk, 0);
 
@@ -1631,7 +2403,7 @@ static int packet_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	struct packet_sock *po;
 	struct net *net;
-	struct tpacket_req req;
+	union tpacket_req_u req_u;
 
 	if (!sk)
 		return 0;
@@ -1654,13 +2426,13 @@ static int packet_release(struct socket *sock)
 
 	packet_flush_mclist(sk);
 
-	memset(&req, 0, sizeof(req));
+	memset(&req_u, 0, sizeof(req_u));
 
 	if (po->rx_ring.pg_vec)
-		packet_set_ring(sk, &req, 1, 0);
+		packet_set_ring(sk, &req_u, 1, 0);
 
 	if (po->tx_ring.pg_vec)
-		packet_set_ring(sk, &req, 1, 1);
+		packet_set_ring(sk, &req_u, 1, 1);
 
 	fanout_release(sk);
 
@@ -2280,15 +3052,27 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 	case PACKET_RX_RING:
 	case PACKET_TX_RING:
 	{
-		struct tpacket_req req;
+		union tpacket_req_u req_u;
+		int len;
 
-		if (optlen < sizeof(req))
+		switch (po->tp_version) {
+		case TPACKET_V1:
+		case TPACKET_V2:
+			len = sizeof(req_u.req);
+			break;
+		case TPACKET_V3:
+		default:
+			len = sizeof(req_u.req3);
+			break;
+		}
+		if (optlen < len)
 			return -EINVAL;
 		if (pkt_sk(sk)->has_vnet_hdr)
 			return -EINVAL;
-		if (copy_from_user(&req, optval, sizeof(req)))
+		if (copy_from_user(&req_u.req, optval, len))
 			return -EFAULT;
-		return packet_set_ring(sk, &req, 0, optname == PACKET_TX_RING);
+		return packet_set_ring(sk, &req_u, 0,
+			optname == PACKET_TX_RING);
 	}
 	case PACKET_COPY_THRESH:
 	{
@@ -2315,6 +3099,7 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		switch (val) {
 		case TPACKET_V1:
 		case TPACKET_V2:
+		case TPACKET_V3:
 			po->tp_version = val;
 			return 0;
 		default:
@@ -2424,6 +3209,7 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	struct packet_sock *po = pkt_sk(sk);
 	void *data;
 	struct tpacket_stats st;
+	union tpacket_stats_u st_u;
 
 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -2436,15 +3222,27 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 
 	switch (optname) {
 	case PACKET_STATISTICS:
-		if (len > sizeof(struct tpacket_stats))
-			len = sizeof(struct tpacket_stats);
+		if (po->tp_version == TPACKET_V3) {
+			len = sizeof(struct tpacket_stats_v3);
+		} else {
+			if (len > sizeof(struct tpacket_stats))
+				len = sizeof(struct tpacket_stats);
+		}
 		spin_lock_bh(&sk->sk_receive_queue.lock);
-		st = po->stats;
+		if (po->tp_version == TPACKET_V3) {
+			memcpy(&st_u.stats3, &po->stats,
+			sizeof(struct tpacket_stats));
+			st_u.stats3.tp_freeze_q_cnt =
+			po->stats_u.stats3.tp_freeze_q_cnt;
+			st_u.stats3.tp_packets += po->stats.tp_drops;
+			data = &st_u.stats3;
+		} else {
+			st = po->stats;
+			st.tp_packets += st.tp_drops;
+			data = &st;
+		}
 		memset(&po->stats, 0, sizeof(st));
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
-		st.tp_packets += st.tp_drops;
-
-		data = &st;
 		break;
 	case PACKET_AUXDATA:
 		if (len > sizeof(int))
@@ -2485,6 +3283,9 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		case TPACKET_V2:
 			val = sizeof(struct tpacket2_hdr);
 			break;
+		case TPACKET_V3:
+			val = sizeof(struct tpacket3_hdr);
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -2641,7 +3442,8 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 
 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (po->rx_ring.pg_vec) {
-		if (!packet_previous_frame(po, &po->rx_ring, TP_STATUS_KERNEL))
+		if (!packet_previous_rx_frame(po, &po->rx_ring,
+			TP_STATUS_KERNEL))
 			mask |= POLLIN | POLLRDNORM;
 	}
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
@@ -2760,7 +3562,7 @@ out_free_pgvec:
 	goto out;
 }
 
-static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
+static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		int closing, int tx_ring)
 {
 	struct pgv *pg_vec = NULL;
@@ -2769,7 +3571,15 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 	struct packet_ring_buffer *rb;
 	struct sk_buff_head *rb_queue;
 	__be16 num;
-	int err;
+	int err = -EINVAL;
+	/* Added to avoid minimal code churn */
+	struct tpacket_req *req = &req_u->req;
+
+	/* Opening a Tx-ring is NOT supported in TPACKET_V3 */
+	if (!closing && tx_ring && (po->tp_version > TPACKET_V2)) {
+		WARN(1, "Tx-ring is not supported.\n");
+		goto out;
+	}
 
 	rb = tx_ring ? &po->tx_ring : &po->rx_ring;
 	rb_queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
@@ -2795,6 +3605,9 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		case TPACKET_V2:
 			po->tp_hdrlen = TPACKET2_HDRLEN;
 			break;
+		case TPACKET_V3:
+			po->tp_hdrlen = TPACKET3_HDRLEN;
+			break;
 		}
 
 		err = -EINVAL;
@@ -2820,6 +3633,17 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		pg_vec = alloc_pg_vec(req, order);
 		if (unlikely(!pg_vec))
 			goto out;
+		switch (po->tp_version) {
+		case TPACKET_V3:
+		/* Transmit path is not supported. We checked
+		 * it above but just being paranoid
+		 */
+			if (!tx_ring)
+				init_prb_bdqc(po, rb, pg_vec, req_u, tx_ring);
+				break;
+		default:
+			break;
+		}
 	}
 	/* Done */
 	else {
@@ -2872,7 +3696,11 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		register_prot_hook(sk);
 	}
 	spin_unlock(&po->bind_lock);
-
+	if (closing && (po->tp_version > TPACKET_V2)) {
+		/* Because we don't support block-based V3 on tx-ring */
+		if (!tx_ring)
+			prb_shutdown_retire_blk_timer(po, tx_ring, rb_queue);
+	}
 	release_sock(sk);
 
 	if (pg_vec)
-- 
1.7.5.2

