From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 2/2] kcm: Use stream parser
Date: Tue, 5 Jul 2016 12:03:34 -0700
Message-ID: <1467745414-2763835-3-git-send-email-tom@herbertland.com>
References: <1467745414-2763835-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:21540 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752201AbcGETDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:03:48 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65J21Eb023597
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2016 12:03:48 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 240jkxg1pt-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 12:03:48 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 33273e7c42e311e6896f24be05956610-4b4f8af0 for <netdev@vger.kernel.org>;	Tue,
 05 Jul 2016 12:03:46 -0700
In-Reply-To: <1467745414-2763835-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt KCM to use the stream parser. This mostly involves removing
the RX handling and setting up the strparser using the interface.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/kcm.h |  36 +----
 net/kcm/Kconfig   |   1 +
 net/kcm/kcmproc.c |  41 +++--
 net/kcm/kcmsock.c | 435 +++++++-----------------------------------------------
 4 files changed, 86 insertions(+), 427 deletions(-)

diff --git a/include/net/kcm.h b/include/net/kcm.h
index 2840b58..4acfa31 100644
--- a/include/net/kcm.h
+++ b/include/net/kcm.h
@@ -13,6 +13,7 @@
 
 #include <linux/skbuff.h>
 #include <net/sock.h>
+#include <net/strparser.h>
 #include <uapi/linux/kcm.h>
 
 extern unsigned int kcm_net_id;
@@ -21,16 +22,8 @@ extern unsigned int kcm_net_id;
 #define KCM_STATS_INCR(stat) ((stat)++)
 
 struct kcm_psock_stats {
-	unsigned long long rx_msgs;
-	unsigned long long rx_bytes;
 	unsigned long long tx_msgs;
 	unsigned long long tx_bytes;
-	unsigned int rx_aborts;
-	unsigned int rx_mem_fail;
-	unsigned int rx_need_more_hdr;
-	unsigned int rx_msg_too_big;
-	unsigned int rx_msg_timeouts;
-	unsigned int rx_bad_hdr_len;
 	unsigned long long reserved;
 	unsigned long long unreserved;
 	unsigned int tx_aborts;
@@ -64,13 +57,6 @@ struct kcm_tx_msg {
 	struct sk_buff *last_skb;
 };
 
-struct kcm_rx_msg {
-	int full_len;
-	int accum_len;
-	int offset;
-	int early_eaten;
-};
-
 /* Socket structure for KCM client sockets */
 struct kcm_sock {
 	struct sock sk;
@@ -104,11 +90,11 @@ struct bpf_prog;
 /* Structure for an attached lower socket */
 struct kcm_psock {
 	struct sock *sk;
+	struct strparser strp;
 	struct kcm_mux *mux;
 	int index;
 
 	u32 tx_stopped : 1;
-	u32 rx_stopped : 1;
 	u32 done : 1;
 	u32 unattaching : 1;
 
@@ -121,18 +107,12 @@ struct kcm_psock {
 	struct kcm_psock_stats stats;
 
 	/* Receive */
-	struct sk_buff *rx_skb_head;
-	struct sk_buff **rx_skb_nextp;
-	struct sk_buff *ready_rx_msg;
 	struct list_head psock_ready_list;
-	struct work_struct rx_work;
-	struct delayed_work rx_delayed_work;
 	struct bpf_prog *bpf_prog;
 	struct kcm_sock *rx_kcm;
 	unsigned long long saved_rx_bytes;
 	unsigned long long saved_rx_msgs;
-	struct timer_list rx_msg_timer;
-	unsigned int rx_need_bytes;
+	struct sk_buff *ready_rx_msg;
 
 	/* Transmit */
 	struct kcm_sock *tx_kcm;
@@ -146,6 +126,7 @@ struct kcm_net {
 	struct mutex mutex;
 	struct kcm_psock_stats aggregate_psock_stats;
 	struct kcm_mux_stats aggregate_mux_stats;
+	struct strp_aggr_stats aggregate_strp_stats;
 	struct list_head mux_list;
 	int count;
 };
@@ -163,6 +144,7 @@ struct kcm_mux {
 
 	struct kcm_mux_stats stats;
 	struct kcm_psock_stats aggregate_psock_stats;
+	struct strp_aggr_stats aggregate_strp_stats;
 
 	/* Receive */
 	spinlock_t rx_lock ____cacheline_aligned_in_smp;
@@ -190,14 +172,6 @@ static inline void aggregate_psock_stats(struct kcm_psock_stats *stats,
 	/* Save psock statistics in the mux when psock is being unattached. */
 
 #define SAVE_PSOCK_STATS(_stat) (agg_stats->_stat += stats->_stat)
-	SAVE_PSOCK_STATS(rx_msgs);
-	SAVE_PSOCK_STATS(rx_bytes);
-	SAVE_PSOCK_STATS(rx_aborts);
-	SAVE_PSOCK_STATS(rx_mem_fail);
-	SAVE_PSOCK_STATS(rx_need_more_hdr);
-	SAVE_PSOCK_STATS(rx_msg_too_big);
-	SAVE_PSOCK_STATS(rx_msg_timeouts);
-	SAVE_PSOCK_STATS(rx_bad_hdr_len);
 	SAVE_PSOCK_STATS(tx_msgs);
 	SAVE_PSOCK_STATS(tx_bytes);
 	SAVE_PSOCK_STATS(reserved);
diff --git a/net/kcm/Kconfig b/net/kcm/Kconfig
index 5db94d9..87fca36 100644
--- a/net/kcm/Kconfig
+++ b/net/kcm/Kconfig
@@ -3,6 +3,7 @@ config AF_KCM
 	tristate "KCM sockets"
 	depends on INET
 	select BPF_SYSCALL
+	select STREAM_PARSER
 	---help---
 	  KCM (Kernel Connection Multiplexor) sockets provide a method
 	  for multiplexing messages of a message based application
diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index fda7f47..9d0cf0d 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -159,8 +159,8 @@ static void kcm_format_psock(struct kcm_psock *psock, struct seq_file *seq,
 	seq_printf(seq,
 		   "   psock-%-5u %-10llu %-16llu %-10llu %-16llu %-8d %-8d %-8d %-8d ",
 		   psock->index,
-		   psock->stats.rx_msgs,
-		   psock->stats.rx_bytes,
+		   psock->strp.stats.rx_msgs,
+		   psock->strp.stats.rx_bytes,
 		   psock->stats.tx_msgs,
 		   psock->stats.tx_bytes,
 		   psock->sk->sk_receive_queue.qlen,
@@ -174,7 +174,7 @@ static void kcm_format_psock(struct kcm_psock *psock, struct seq_file *seq,
 	if (psock->tx_stopped)
 		seq_puts(seq, "TxStop ");
 
-	if (psock->rx_stopped)
+	if (psock->strp.rx_stopped)
 		seq_puts(seq, "RxStop ");
 
 	if (psock->tx_kcm)
@@ -279,6 +279,7 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct kcm_psock_stats psock_stats;
 	struct kcm_mux_stats mux_stats;
+	struct strp_aggr_stats strp_stats;
 	struct kcm_mux *mux;
 	struct kcm_psock *psock;
 	struct net *net = seq->private;
@@ -286,20 +287,28 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 
 	memset(&mux_stats, 0, sizeof(mux_stats));
 	memset(&psock_stats, 0, sizeof(psock_stats));
+	memset(&strp_stats, 0, sizeof(strp_stats));
 
 	mutex_lock(&knet->mutex);
 
 	aggregate_mux_stats(&knet->aggregate_mux_stats, &mux_stats);
 	aggregate_psock_stats(&knet->aggregate_psock_stats,
 			      &psock_stats);
+	aggregate_strp_stats(&knet->aggregate_strp_stats,
+			     &strp_stats);
 
 	list_for_each_entry_rcu(mux, &knet->mux_list, kcm_mux_list) {
 		spin_lock_bh(&mux->lock);
 		aggregate_mux_stats(&mux->stats, &mux_stats);
 		aggregate_psock_stats(&mux->aggregate_psock_stats,
 				      &psock_stats);
-		list_for_each_entry(psock, &mux->psocks, psock_list)
+		aggregate_strp_stats(&mux->aggregate_strp_stats,
+				     &strp_stats);
+		list_for_each_entry(psock, &mux->psocks, psock_list) {
 			aggregate_psock_stats(&psock->stats, &psock_stats);
+			save_strp_stats(&psock->strp, &strp_stats);
+		}
+
 		spin_unlock_bh(&mux->lock);
 	}
 
@@ -332,7 +341,7 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   mux_stats.rx_ready_drops);
 
 	seq_printf(seq,
-		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
+		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
 		   "Psock",
 		   "RX-Msgs",
 		   "RX-Bytes",
@@ -341,6 +350,8 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   "Reserved",
 		   "Unreserved",
 		   "RX-Aborts",
+		   "RX-Intr",
+		   "RX-Unrecov",
 		   "RX-MemFail",
 		   "RX-NeedMor",
 		   "RX-BadLen",
@@ -349,20 +360,22 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   "TX-Aborts");
 
 	seq_printf(seq,
-		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10llu %-10llu %-10u %-10u %-10u %-10u %-10u %-10u %-10u\n",
+		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10llu %-10llu %-10u %-10u %-10u %-10u %-10u %-10u %-10u %-10u %-10u\n",
 		   "",
-		   psock_stats.rx_msgs,
-		   psock_stats.rx_bytes,
+		   strp_stats.rx_msgs,
+		   strp_stats.rx_bytes,
 		   psock_stats.tx_msgs,
 		   psock_stats.tx_bytes,
 		   psock_stats.reserved,
 		   psock_stats.unreserved,
-		   psock_stats.rx_aborts,
-		   psock_stats.rx_mem_fail,
-		   psock_stats.rx_need_more_hdr,
-		   psock_stats.rx_bad_hdr_len,
-		   psock_stats.rx_msg_too_big,
-		   psock_stats.rx_msg_timeouts,
+		   strp_stats.rx_aborts,
+		   strp_stats.rx_interrupted,
+		   strp_stats.rx_unrecov_intr,
+		   strp_stats.rx_mem_fail,
+		   strp_stats.rx_need_more_hdr,
+		   strp_stats.rx_bad_hdr_len,
+		   strp_stats.rx_msg_too_big,
+		   strp_stats.rx_msg_timeouts,
 		   psock_stats.tx_aborts);
 
 	return 0;
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index cb39e05..36ca602 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -35,38 +35,12 @@ static inline struct kcm_tx_msg *kcm_tx_msg(struct sk_buff *skb)
 	return (struct kcm_tx_msg *)skb->cb;
 }
 
-static inline struct kcm_rx_msg *kcm_rx_msg(struct sk_buff *skb)
-{
-	return (struct kcm_rx_msg *)((void *)skb->cb +
-				     offsetof(struct qdisc_skb_cb, data));
-}
-
 static void report_csk_error(struct sock *csk, int err)
 {
 	csk->sk_err = EPIPE;
 	csk->sk_error_report(csk);
 }
 
-/* Callback lock held */
-static void kcm_abort_rx_psock(struct kcm_psock *psock, int err,
-			       struct sk_buff *skb)
-{
-	struct sock *csk = psock->sk;
-
-	/* Unrecoverable error in receive */
-
-	del_timer(&psock->rx_msg_timer);
-
-	if (psock->rx_stopped)
-		return;
-
-	psock->rx_stopped = 1;
-	KCM_STATS_INCR(psock->stats.rx_aborts);
-
-	/* Report an error on the lower socket */
-	report_csk_error(csk, err);
-}
-
 static void kcm_abort_tx_psock(struct kcm_psock *psock, int err,
 			       bool wakeup_kcm)
 {
@@ -109,12 +83,13 @@ static void kcm_abort_tx_psock(struct kcm_psock *psock, int err,
 static void kcm_update_rx_mux_stats(struct kcm_mux *mux,
 				    struct kcm_psock *psock)
 {
-	KCM_STATS_ADD(mux->stats.rx_bytes,
-		      psock->stats.rx_bytes - psock->saved_rx_bytes);
+	STRP_STATS_ADD(mux->stats.rx_bytes,
+		       psock->strp.stats.rx_bytes -
+		       psock->saved_rx_bytes);
 	mux->stats.rx_msgs +=
-		psock->stats.rx_msgs - psock->saved_rx_msgs;
-	psock->saved_rx_msgs = psock->stats.rx_msgs;
-	psock->saved_rx_bytes = psock->stats.rx_bytes;
+		psock->strp.stats.rx_msgs - psock->saved_rx_msgs;
+	psock->saved_rx_msgs = psock->strp.stats.rx_msgs;
+	psock->saved_rx_bytes = psock->strp.stats.rx_bytes;
 }
 
 static void kcm_update_tx_mux_stats(struct kcm_mux *mux,
@@ -167,11 +142,12 @@ static void kcm_rcv_ready(struct kcm_sock *kcm)
 		 */
 		list_del(&psock->psock_ready_list);
 		psock->ready_rx_msg = NULL;
+		strp_unpause(&psock->strp);
 
 		/* Commit clearing of ready_rx_msg for queuing work */
 		smp_mb();
 
-		queue_work(kcm_wq, &psock->rx_work);
+		strp_check_rcv(&psock->strp);
 	}
 
 	/* Buffer limit is okay now, add to ready list */
@@ -285,6 +261,7 @@ static struct kcm_sock *reserve_rx_kcm(struct kcm_psock *psock,
 
 	if (list_empty(&mux->kcm_rx_waiters)) {
 		psock->ready_rx_msg = head;
+		strp_pause(&psock->strp);
 		list_add_tail(&psock->psock_ready_list,
 			      &mux->psocks_ready);
 		spin_unlock_bh(&mux->rx_lock);
@@ -353,343 +330,42 @@ static void unreserve_rx_kcm(struct kcm_psock *psock,
 	spin_unlock_bh(&mux->rx_lock);
 }
 
-static void kcm_start_rx_timer(struct kcm_psock *psock)
+static int kcm_rcv_strparser(struct strparser *strp, struct sk_buff *skb)
 {
-	if (psock->sk->sk_rcvtimeo)
-		mod_timer(&psock->rx_msg_timer, psock->sk->sk_rcvtimeo);
-}
-
-/* Macro to invoke filter function. */
-#define KCM_RUN_FILTER(prog, ctx) \
-	(*prog->bpf_func)(ctx, prog->insnsi)
-
-/* Lower socket lock held */
-static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
-			unsigned int orig_offset, size_t orig_len)
-{
-	struct kcm_psock *psock = (struct kcm_psock *)desc->arg.data;
-	struct kcm_rx_msg *rxm;
+	struct kcm_psock *psock = container_of(strp, struct kcm_psock, strp);
 	struct kcm_sock *kcm;
-	struct sk_buff *head, *skb;
-	size_t eaten = 0, cand_len;
-	ssize_t extra;
-	int err;
-	bool cloned_orig = false;
-
-	if (psock->ready_rx_msg)
-		return 0;
-
-	head = psock->rx_skb_head;
-	if (head) {
-		/* Message already in progress */
-
-		rxm = kcm_rx_msg(head);
-		if (unlikely(rxm->early_eaten)) {
-			/* Already some number of bytes on the receive sock
-			 * data saved in rx_skb_head, just indicate they
-			 * are consumed.
-			 */
-			eaten = orig_len <= rxm->early_eaten ?
-				orig_len : rxm->early_eaten;
-			rxm->early_eaten -= eaten;
-
-			return eaten;
-		}
-
-		if (unlikely(orig_offset)) {
-			/* Getting data with a non-zero offset when a message is
-			 * in progress is not expected. If it does happen, we
-			 * need to clone and pull since we can't deal with
-			 * offsets in the skbs for a message expect in the head.
-			 */
-			orig_skb = skb_clone(orig_skb, GFP_ATOMIC);
-			if (!orig_skb) {
-				KCM_STATS_INCR(psock->stats.rx_mem_fail);
-				desc->error = -ENOMEM;
-				return 0;
-			}
-			if (!pskb_pull(orig_skb, orig_offset)) {
-				KCM_STATS_INCR(psock->stats.rx_mem_fail);
-				kfree_skb(orig_skb);
-				desc->error = -ENOMEM;
-				return 0;
-			}
-			cloned_orig = true;
-			orig_offset = 0;
-		}
-
-		if (!psock->rx_skb_nextp) {
-			/* We are going to append to the frags_list of head.
-			 * Need to unshare the frag_list.
-			 */
-			err = skb_unclone(head, GFP_ATOMIC);
-			if (err) {
-				KCM_STATS_INCR(psock->stats.rx_mem_fail);
-				desc->error = err;
-				return 0;
-			}
-
-			if (unlikely(skb_shinfo(head)->frag_list)) {
-				/* We can't append to an sk_buff that already
-				 * has a frag_list. We create a new head, point
-				 * the frag_list of that to the old head, and
-				 * then are able to use the old head->next for
-				 * appending to the message.
-				 */
-				if (WARN_ON(head->next)) {
-					desc->error = -EINVAL;
-					return 0;
-				}
-
-				skb = alloc_skb(0, GFP_ATOMIC);
-				if (!skb) {
-					KCM_STATS_INCR(psock->stats.rx_mem_fail);
-					desc->error = -ENOMEM;
-					return 0;
-				}
-				skb->len = head->len;
-				skb->data_len = head->len;
-				skb->truesize = head->truesize;
-				*kcm_rx_msg(skb) = *kcm_rx_msg(head);
-				psock->rx_skb_nextp = &head->next;
-				skb_shinfo(skb)->frag_list = head;
-				psock->rx_skb_head = skb;
-				head = skb;
-			} else {
-				psock->rx_skb_nextp =
-				    &skb_shinfo(head)->frag_list;
-			}
-		}
-	}
-
-	while (eaten < orig_len) {
-		/* Always clone since we will consume something */
-		skb = skb_clone(orig_skb, GFP_ATOMIC);
-		if (!skb) {
-			KCM_STATS_INCR(psock->stats.rx_mem_fail);
-			desc->error = -ENOMEM;
-			break;
-		}
-
-		cand_len = orig_len - eaten;
-
-		head = psock->rx_skb_head;
-		if (!head) {
-			head = skb;
-			psock->rx_skb_head = head;
-			/* Will set rx_skb_nextp on next packet if needed */
-			psock->rx_skb_nextp = NULL;
-			rxm = kcm_rx_msg(head);
-			memset(rxm, 0, sizeof(*rxm));
-			rxm->offset = orig_offset + eaten;
-		} else {
-			/* Unclone since we may be appending to an skb that we
-			 * already share a frag_list with.
-			 */
-			err = skb_unclone(skb, GFP_ATOMIC);
-			if (err) {
-				KCM_STATS_INCR(psock->stats.rx_mem_fail);
-				desc->error = err;
-				break;
-			}
-
-			rxm = kcm_rx_msg(head);
-			*psock->rx_skb_nextp = skb;
-			psock->rx_skb_nextp = &skb->next;
-			head->data_len += skb->len;
-			head->len += skb->len;
-			head->truesize += skb->truesize;
-		}
-
-		if (!rxm->full_len) {
-			ssize_t len;
-
-			len = KCM_RUN_FILTER(psock->bpf_prog, head);
-
-			if (!len) {
-				/* Need more header to determine length */
-				if (!rxm->accum_len) {
-					/* Start RX timer for new message */
-					kcm_start_rx_timer(psock);
-				}
-				rxm->accum_len += cand_len;
-				eaten += cand_len;
-				KCM_STATS_INCR(psock->stats.rx_need_more_hdr);
-				WARN_ON(eaten != orig_len);
-				break;
-			} else if (len > psock->sk->sk_rcvbuf) {
-				/* Message length exceeds maximum allowed */
-				KCM_STATS_INCR(psock->stats.rx_msg_too_big);
-				desc->error = -EMSGSIZE;
-				psock->rx_skb_head = NULL;
-				kcm_abort_rx_psock(psock, EMSGSIZE, head);
-				break;
-			} else if (len <= (ssize_t)head->len -
-					  skb->len - rxm->offset) {
-				/* Length must be into new skb (and also
-				 * greater than zero)
-				 */
-				KCM_STATS_INCR(psock->stats.rx_bad_hdr_len);
-				desc->error = -EPROTO;
-				psock->rx_skb_head = NULL;
-				kcm_abort_rx_psock(psock, EPROTO, head);
-				break;
-			}
-
-			rxm->full_len = len;
-		}
-
-		extra = (ssize_t)(rxm->accum_len + cand_len) - rxm->full_len;
-
-		if (extra < 0) {
-			/* Message not complete yet. */
-			if (rxm->full_len - rxm->accum_len >
-			    tcp_inq(psock->sk)) {
-				/* Don't have the whole messages in the socket
-				 * buffer. Set psock->rx_need_bytes to wait for
-				 * the rest of the message. Also, set "early
-				 * eaten" since we've already buffered the skb
-				 * but don't consume yet per tcp_read_sock.
-				 */
-
-				if (!rxm->accum_len) {
-					/* Start RX timer for new message */
-					kcm_start_rx_timer(psock);
-				}
-
-				psock->rx_need_bytes = rxm->full_len -
-						       rxm->accum_len;
-				rxm->accum_len += cand_len;
-				rxm->early_eaten = cand_len;
-				KCM_STATS_ADD(psock->stats.rx_bytes, cand_len);
-				desc->count = 0; /* Stop reading socket */
-				break;
-			}
-			rxm->accum_len += cand_len;
-			eaten += cand_len;
-			WARN_ON(eaten != orig_len);
-			break;
-		}
-
-		/* Positive extra indicates ore bytes than needed for the
-		 * message
-		 */
-
-		WARN_ON(extra > cand_len);
-
-		eaten += (cand_len - extra);
-
-		/* Hurray, we have a new message! */
-		del_timer(&psock->rx_msg_timer);
-		psock->rx_skb_head = NULL;
-		KCM_STATS_INCR(psock->stats.rx_msgs);
 
 try_queue:
-		kcm = reserve_rx_kcm(psock, head);
-		if (!kcm) {
-			/* Unable to reserve a KCM, message is held in psock. */
-			break;
-		}
-
-		if (kcm_queue_rcv_skb(&kcm->sk, head)) {
-			/* Should mean socket buffer full */
-			unreserve_rx_kcm(psock, false);
-			goto try_queue;
-		}
+	kcm = reserve_rx_kcm(psock, skb);
+	if (!kcm) {
+		 /* Unable to reserve a KCM, message is held in psock. */
+		return 1;
 	}
 
-	if (cloned_orig)
-		kfree_skb(orig_skb);
-
-	KCM_STATS_ADD(psock->stats.rx_bytes, eaten);
-
-	return eaten;
-}
-
-/* Called with lock held on lower socket */
-static int psock_tcp_read_sock(struct kcm_psock *psock)
-{
-	read_descriptor_t desc;
-
-	desc.arg.data = psock;
-	desc.error = 0;
-	desc.count = 1; /* give more than one skb per call */
-
-	/* sk should be locked here, so okay to do tcp_read_sock */
-	tcp_read_sock(psock->sk, &desc, kcm_tcp_recv);
-
-	unreserve_rx_kcm(psock, true);
-
-	return desc.error;
-}
-
-/* Lower sock lock held */
-static void psock_tcp_data_ready(struct sock *sk)
-{
-	struct kcm_psock *psock;
-
-	read_lock_bh(&sk->sk_callback_lock);
-
-	psock = (struct kcm_psock *)sk->sk_user_data;
-	if (unlikely(!psock || psock->rx_stopped))
-		goto out;
-
-	if (psock->ready_rx_msg)
-		goto out;
-
-	if (psock->rx_need_bytes) {
-		if (tcp_inq(sk) >= psock->rx_need_bytes)
-			psock->rx_need_bytes = 0;
-		else
-			goto out;
+	if (kcm_queue_rcv_skb(&kcm->sk, skb)) {
+		/* Should mean socket buffer full */
+		unreserve_rx_kcm(psock, false);
+		goto try_queue;
 	}
 
-	if (psock_tcp_read_sock(psock) == -ENOMEM)
-		queue_delayed_work(kcm_wq, &psock->rx_delayed_work, 0);
-
-out:
-	read_unlock_bh(&sk->sk_callback_lock);
+	return 0;
 }
 
-static void do_psock_rx_work(struct kcm_psock *psock)
+static int kcm_parse_func_strparser(struct strparser *strp, struct sk_buff *skb)
 {
-	read_descriptor_t rd_desc;
-	struct sock *csk = psock->sk;
-
-	/* We need the read lock to synchronize with psock_tcp_data_ready. We
-	 * need the socket lock for calling tcp_read_sock.
-	 */
-	lock_sock(csk);
-	read_lock_bh(&csk->sk_callback_lock);
-
-	if (unlikely(csk->sk_user_data != psock))
-		goto out;
-
-	if (unlikely(psock->rx_stopped))
-		goto out;
-
-	if (psock->ready_rx_msg)
-		goto out;
-
-	rd_desc.arg.data = psock;
+	struct kcm_psock *psock = container_of(strp, struct kcm_psock, strp);
+	struct bpf_prog *prog = psock->bpf_prog;
 
-	if (psock_tcp_read_sock(psock) == -ENOMEM)
-		queue_delayed_work(kcm_wq, &psock->rx_delayed_work, 0);
-
-out:
-	read_unlock_bh(&csk->sk_callback_lock);
-	release_sock(csk);
+	return (*prog->bpf_func)(skb, prog->insnsi);
 }
 
-static void psock_rx_work(struct work_struct *w)
+static int kcm_read_sock_done(struct strparser *strp, int err)
 {
-	do_psock_rx_work(container_of(w, struct kcm_psock, rx_work));
-}
+	struct kcm_psock *psock = container_of(strp, struct kcm_psock, strp);
 
-static void psock_rx_delayed_work(struct work_struct *w)
-{
-	do_psock_rx_work(container_of(w, struct kcm_psock,
-				      rx_delayed_work.work));
+	unreserve_rx_kcm(psock, true);
+
+	return err;
 }
 
 static void psock_tcp_state_change(struct sock *sk)
@@ -705,15 +381,18 @@ static void psock_tcp_state_change(struct sock *sk)
 static void psock_tcp_write_space(struct sock *sk)
 {
 	struct kcm_psock *psock;
+	struct strparser *strp;
 	struct kcm_mux *mux;
 	struct kcm_sock *kcm;
 
 	read_lock_bh(&sk->sk_callback_lock);
 
-	psock = (struct kcm_psock *)sk->sk_user_data;
-	if (unlikely(!psock))
+	strp = (struct strparser *)sk->sk_user_data;
+	if (unlikely(!strp))
 		goto out;
 
+	psock = container_of(strp, struct kcm_psock, strp);
+
 	mux = psock->mux;
 
 	spin_lock_bh(&mux->lock);
@@ -1411,7 +1090,7 @@ static int kcm_recvmsg(struct socket *sock, struct msghdr *msg,
 	struct kcm_sock *kcm = kcm_sk(sk);
 	int err = 0;
 	long timeo;
-	struct kcm_rx_msg *rxm;
+	struct strp_rx_msg *rxm;
 	int copied = 0;
 	struct sk_buff *skb;
 
@@ -1425,7 +1104,7 @@ static int kcm_recvmsg(struct socket *sock, struct msghdr *msg,
 
 	/* Okay, have a message on the receive queue */
 
-	rxm = kcm_rx_msg(skb);
+	rxm = strp_rx_msg(skb);
 
 	if (len > rxm->full_len)
 		len = rxm->full_len;
@@ -1481,7 +1160,7 @@ static ssize_t kcm_splice_read(struct socket *sock, loff_t *ppos,
 	struct sock *sk = sock->sk;
 	struct kcm_sock *kcm = kcm_sk(sk);
 	long timeo;
-	struct kcm_rx_msg *rxm;
+	struct strp_rx_msg *rxm;
 	int err = 0;
 	ssize_t copied;
 	struct sk_buff *skb;
@@ -1498,7 +1177,7 @@ static ssize_t kcm_splice_read(struct socket *sock, loff_t *ppos,
 
 	/* Okay, have a message on the receive queue */
 
-	rxm = kcm_rx_msg(skb);
+	rxm = strp_rx_msg(skb);
 
 	if (len > rxm->full_len)
 		len = rxm->full_len;
@@ -1674,15 +1353,6 @@ static void init_kcm_sock(struct kcm_sock *kcm, struct kcm_mux *mux)
 	spin_unlock_bh(&mux->rx_lock);
 }
 
-static void kcm_rx_msg_timeout(unsigned long arg)
-{
-	struct kcm_psock *psock = (struct kcm_psock *)arg;
-
-	/* Message assembly timed out */
-	KCM_STATS_INCR(psock->stats.rx_msg_timeouts);
-	kcm_abort_rx_psock(psock, ETIMEDOUT, NULL);
-}
-
 static int kcm_attach(struct socket *sock, struct socket *csock,
 		      struct bpf_prog *prog)
 {
@@ -1692,6 +1362,7 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	struct kcm_psock *psock = NULL, *tpsock;
 	struct list_head *head;
 	int index = 0;
+	struct strp_callbacks cb;
 
 	if (csock->ops->family != PF_INET &&
 	    csock->ops->family != PF_INET6)
@@ -1713,11 +1384,12 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	psock->sk = csk;
 	psock->bpf_prog = prog;
 
-	setup_timer(&psock->rx_msg_timer, kcm_rx_msg_timeout,
-		    (unsigned long)psock);
+	cb.rcv_msg = kcm_rcv_strparser;
+	cb.abort_parser = NULL;
+	cb.parse_msg = kcm_parse_func_strparser;
+	cb.read_sock_done = kcm_read_sock_done;
 
-	INIT_WORK(&psock->rx_work, psock_rx_work);
-	INIT_DELAYED_WORK(&psock->rx_delayed_work, psock_rx_delayed_work);
+	strp_init(&psock->strp, csk, &cb);
 
 	sock_hold(csk);
 
@@ -1725,8 +1397,8 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	psock->save_data_ready = csk->sk_data_ready;
 	psock->save_write_space = csk->sk_write_space;
 	psock->save_state_change = csk->sk_state_change;
-	csk->sk_user_data = psock;
-	csk->sk_data_ready = psock_tcp_data_ready;
+	csk->sk_user_data = &psock->strp;
+	csk->sk_data_ready = strp_tcp_data_ready;
 	csk->sk_write_space = psock_tcp_write_space;
 	csk->sk_state_change = psock_tcp_state_change;
 	write_unlock_bh(&csk->sk_callback_lock);
@@ -1750,7 +1422,7 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	spin_unlock_bh(&mux->lock);
 
 	/* Schedule RX work in case there are already bytes queued */
-	queue_work(kcm_wq, &psock->rx_work);
+	strp_check_rcv(&psock->strp);
 
 	return 0;
 }
@@ -1798,7 +1470,7 @@ static void kcm_unattach(struct kcm_psock *psock)
 	csk->sk_data_ready = psock->save_data_ready;
 	csk->sk_write_space = psock->save_write_space;
 	csk->sk_state_change = psock->save_state_change;
-	psock->rx_stopped = 1;
+	strp_stop(&psock->strp);
 
 	if (WARN_ON(psock->rx_kcm)) {
 		write_unlock_bh(&csk->sk_callback_lock);
@@ -1814,6 +1486,7 @@ static void kcm_unattach(struct kcm_psock *psock)
 		list_del(&psock->psock_ready_list);
 		kfree_skb(psock->ready_rx_msg);
 		psock->ready_rx_msg = NULL;
+		strp_unpause(&psock->strp);
 		KCM_STATS_INCR(mux->stats.rx_ready_drops);
 	}
 
@@ -1821,18 +1494,14 @@ static void kcm_unattach(struct kcm_psock *psock)
 
 	write_unlock_bh(&csk->sk_callback_lock);
 
-	del_timer_sync(&psock->rx_msg_timer);
-	cancel_work_sync(&psock->rx_work);
-	cancel_delayed_work_sync(&psock->rx_delayed_work);
+	strp_done(&psock->strp);
 
 	bpf_prog_put(psock->bpf_prog);
 
-	kfree_skb(psock->rx_skb_head);
-	psock->rx_skb_head = NULL;
-
 	spin_lock_bh(&mux->lock);
 
 	aggregate_psock_stats(&psock->stats, &mux->aggregate_psock_stats);
+	save_strp_stats(&psock->strp, &mux->aggregate_strp_stats);
 
 	KCM_STATS_INCR(mux->stats.psock_unattach);
 
@@ -2072,6 +1741,8 @@ static void release_mux(struct kcm_mux *mux)
 	aggregate_mux_stats(&mux->stats, &knet->aggregate_mux_stats);
 	aggregate_psock_stats(&mux->aggregate_psock_stats,
 			      &knet->aggregate_psock_stats);
+	aggregate_strp_stats(&mux->aggregate_strp_stats,
+			     &knet->aggregate_strp_stats);
 	list_del_rcu(&mux->kcm_mux_list);
 	knet->count--;
 	mutex_unlock(&knet->mutex);
-- 
2.8.0.rc2
