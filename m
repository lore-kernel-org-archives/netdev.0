From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking GSOed skbs
 when SACKed one-by-one (Was: Re: [RFC] TCP illinois max rtt aging)
Date: Tue, 11 Dec 2007 13:59:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712071254070.18529@kivilampi-30.cs.helsinki.fi>
 <20071207.044150.02925935.davem@davemloft.net>
 <Pine.LNX.4.64.0712071442530.18529@kivilampi-30.cs.helsinki.fi>
 <20071207.173201.95379610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1247317148-1197120552=:17809"
Cc: lachlan.andrew@gmail.com, Netdev <netdev@vger.kernel.org>,
	quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57021 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbXLKL7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:59:19 -0500
In-Reply-To: <20071207.173201.95379610.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0712111351470.22872@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1247317148-1197120552=:17809
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712111327171.22872@kivilampi-30.cs.helsinki.fi>

On Fri, 7 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 7 Dec 2007 15:05:59 +0200 (EET)
> 
> > On Fri, 7 Dec 2007, David Miller wrote:
> > 
> > > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> > > Date: Fri, 7 Dec 2007 13:05:46 +0200 (EET)
> > > 
> > > > I guess if you get a large cumulative ACK, the amount of processing is 
> > > > still overwhelming (added DaveM if he has some idea how to combat it).
> > > > 
> > > > Even a simple scenario (this isn't anything fancy at all, will occur all 
> > > > the time): Just one loss => rest skbs grow one by one into a single 
> > > > very large SACK block (and we do that efficiently for sure) => then the 
> > > > fast retransmit gets delivered and a cumulative ACK for whole orig_window 
> > > > arrives => clean_rtx_queue has to do a lot of processing. In this case we 
> > > > could optimize RB-tree cleanup away (by just blanking it all) but still 
> > > > getting rid of all those skbs is going to take a larger moment than I'd 
> > > > like to see.
> > > 
> > > Yes, it's the classic problem.  But it ought to be at least
> > > partially masked when TSO is in use, because we'll only process
> > > a handful of SKBs.  The more effectively TSO batches, the
> > > less work clean_rtx_queue() will do.
> > 
> > No, that's not what is going to happen, TSO won't help at all
> > because one-by-one SACKs will fragment every single one of them
> > (see tcp_match_skb_to_sack) :-(. ...So we're back in non-TSO
> > case, or am I missing something?
> 
> You're of course right, and it's ironic that I wrote the SACK
> splitting code so I should have known this :-)
> 
> A possible approach just occurred to me wherein we maintain
> the SACK state external to the SKBs so that we don't need to
> mess with them at all.
> 
> That would allow us to eliminate the TSO splitting but it would
> not remove the general problem of clean_rtx_queue()'s overhead.
> 
> I'll try to give some thought to this over the weekend.

How about this...

...I've left couple of FIXMEs there still, should be quite simple & 
straightforward to handle them if this seems viable solution at all.


Beware, this doesn't even compile yet because not all parameters are 
transferred currently (first_sack_index was killed earlier, I need to 
summon it back for this). Also, I'd need to do the dirty work of kill 
recv_sack_cache first to make this to not produce, well, interesting 
effects due to missed SACK blocks... :-)

Applies cleanly only after this:
  [TCP]: Push fack_count calculation deeper into functions


--
 i.

--
[RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking GSOed skbs when 
SACKed one-by-one

Because receiver reports out-of-order segment one-by-one using
SACK, the tcp_fragment may do a lot of unnecessary splits that
would be avoided if the sender could see the upcoming future.
Not only SACK processing suffers but clean_rtx_queue as well
is considerable hit when the corresponding cumulative ACK
arrives.

Thus implement a local cache for a single skb to avoid enormous
splitting efforts while the latest SACK block is still growing.
Messy enough, other parts must be made aware of this change as
well because the skb state is a bit fuzzy while have not yet
marked it in tcp_sacktag_one.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    2 +
 include/net/tcp.h     |   19 ++++++++
 net/ipv4/tcp_input.c  |  110 ++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp_output.c |    7 +++
 4 files changed, 133 insertions(+), 5 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 56342c3..4fbfa46 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -360,6 +360,8 @@ struct tcp_sock {
 	u32	fackets_out;	/* FACK'd packets			*/
 	u32	high_seq;	/* snd_nxt at onset of congestion	*/
 
+	u32	sack_pending;	/* End seqno of postponed SACK tagging	*/
+
 	u32	retrans_stamp;	/* Timestamp of the last retransmit,
 				 * also used in SYN-SENT to remember stamp of
 				 * the first SYN. */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5e6c433..e2b88e3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -462,6 +462,21 @@ extern void tcp_send_delayed_ack(struct sock *sk);
 
 /* tcp_input.c */
 extern void tcp_cwnd_application_limited(struct sock *sk);
+extern void __tcp_process_postponed_sack(struct sock *sk, struct sk_buff *skb);
+extern struct sk_buff *tcp_find_postponed_skb(struct sock *sk);
+
+static inline void tcp_process_postponed_sack(struct sock *sk)
+{
+	if (tcp_sk(sk)->sack_pending)
+		__tcp_process_postponed_sack(sk, tcp_find_postponed_skb(sk));
+}
+
+static inline void tcp_process_postponed_sack_overlapping(struct sock *sk,
+							  struct sk_buff *skb)
+{
+	if (tcp_sk(sk)->sack_pending && (skb == tcp_find_postponed_skb(sk)))
+		__tcp_process_postponed_sack(sk, skb);
+}
 
 /* tcp_timer.c */
 extern void tcp_init_xmit_timers(struct sock *);
@@ -1625,6 +1640,10 @@ static inline u32 tcp_highest_sack_seq(struct tcp_sock *tp)
 	if (tp->highest_sack == NULL)
 		return tp->snd_nxt;
 
+	if (tp->sack_pending &&
+	    before(TCP_SKB_CB(tp->highest_sack)->seq, tp->sack_pending))
+		return tp->sack_pending;
+
 	return TCP_SKB_CB(tp->highest_sack)->seq;
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 977c68c..5bed358 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1181,6 +1181,74 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 		tp->lost_retrans_low = new_low_seq;
 }
 
+struct sk_buff *tcp_find_postponed_skb(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (before(TCP_SKB_CB(tcp_highest_sack(sk))->seq, tp->sack_pending))
+		return tcp_highest_sack(sk);
+	else
+		return tcp_write_queue_find(sk, tp->sack_pending, 0);
+}
+
+static void tcp_clear_postponed_tweaks(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned int pcount;
+
+	pcount = (tp->sack_pending - TCP_SKB_CB(skb)->seq) / skb_shinfo(skb)->gso_size;
+
+	tp->sacked_out -= pcount;
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+		tp->lost_out += pcount;
+	/* FIXME: This might be unnecessary */
+	if (skb == tcp_highest_sack(sk))
+		tp->fackets_out -= pcount;
+}
+
+static int tcp_postpone_sack_handling(struct sock *sk, struct sk_buff *skb, u32 end_seq)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned int pcount;
+
+	if (tp->sack_pending) {
+		struct sk_buff *oskb = tcp_find_postponed_skb(sk);
+
+		/* Already considered this area? E.g., due to reordering */
+		if (unlikely((skb == oskb) && !after(end_seq, tp->sack_pending)))
+			return 1;
+
+		if (skb != oskb)
+			__tcp_process_postponed_sack(sk, oskb);
+		else
+			tcp_clear_postponed_tweaks(sk, oskb);
+	}
+
+	/* To be discarded very soon, this case might be improved somehow */
+	if (unlikely(!after(TCP_SKB_CB(skb)->seq, tp->snd_una)))
+		return 0;
+
+	/* 1 out of 2^32 hits this */
+	if (unlikely(!end_seq))
+		return 0;
+
+	pcount = (end_seq - TCP_SKB_CB(skb)->seq) / skb_shinfo(skb)->gso_size;
+
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+		tp->lost_out -= pcount;
+	tp->sacked_out += pcount;
+	if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp))) {
+		unsigned int fack_count_base;
+
+		fack_count_base = TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
+		tp->fackets_out = TCP_SKB_CB(skb)->fack_count -
+					fack_count_base + pcount;
+		tp->highest_sack = skb;
+	}
+	tp->sack_pending = end_seq;
+
+}
+
 /* Check if skb is fully within the SACK block. In presence of GSO skbs,
  * the incoming SACK may not exactly match but we can find smaller MSS
  * aligned portion of it that matches. Therefore we might need to fragment
@@ -1188,7 +1256,7 @@ static void tcp_mark_lost_retrans(struct sock *sk)
  * returns).
  */
 static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
-				 u32 start_seq, u32 end_seq)
+				 u32 start_seq, u32 end_seq, int likely_grows)
 {
 	int in_sack, err;
 	unsigned int pkt_len;
@@ -1201,10 +1269,14 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 
 		in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq);
 
-		if (!in_sack)
+		if (!in_sack) {
 			pkt_len = start_seq - TCP_SKB_CB(skb)->seq;
-		else
+		} else {
 			pkt_len = end_seq - TCP_SKB_CB(skb)->seq;
+
+			if (likely_grows && tcp_postpone_sack_handling(sk, skb, end_seq))
+				return -EAGAIN;
+		}
 		err = tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size);
 		if (err < 0)
 			return err;
@@ -1318,6 +1390,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 					int dup_sack, int *reord, int *flag,
 					int queue)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *next;
 
 	tcp_for_write_queue_from_safe(skb, next, sk, queue) {
@@ -1330,16 +1403,32 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 		if (!before(TCP_SKB_CB(skb)->seq, end_seq))
 			break;
 
-		in_sack = tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+		in_sack = tcp_match_skb_to_sack(sk, skb, start_seq, end_seq,
+						!dup_sack && first_block_idx);
 		if (unlikely(in_sack < 0))
 			break;
 
-		if (in_sack)
+		if (in_sack) {
+			if (tp->sack_pending && skb == tcp_find_postponed_skb(sk))
+				tcp_clear_postponed_tweaks(sk, skb);
 			*flag |= tcp_sacktag_one(skb, sk, reord, dup_sack);
+		}
 	}
 	return skb;
 }
 
+void __tcp_process_postponed_sack(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int reord = tp->packets_out;
+
+	tcp_clear_postponed_tweaks(sk, skb);
+	tp->sack_pending = 0;
+	tcp_sacktag_one(skb, sk, &reord, 0);
+
+	/* FIXME: reord handling here */
+}
+
 /* Avoid all extra work that is being done by sacktag while walking in
  * a normal way
  */
@@ -1705,6 +1794,8 @@ void tcp_enter_frto(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
+	tcp_process_postponed_sack(sk);
+
 	if ((!tp->frto_counter && icsk->icsk_ca_state <= TCP_CA_Disorder) ||
 	    tp->snd_una == tp->high_seq ||
 	    ((icsk->icsk_ca_state == TCP_CA_Loss || tp->frto_counter) &&
@@ -1777,6 +1868,8 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
+	tcp_process_postponed_sack(sk);
+
 	tp->lost_out = 0;
 	tp->retrans_out = 0;
 	if (tcp_is_reno(tp))
@@ -1875,10 +1968,12 @@ void tcp_enter_loss(struct sock *sk, int how)
 		/* Push undo marker, if it was plain RTO and nothing
 		 * was retransmitted. */
 		tp->undo_marker = tp->snd_una;
+		tcp_process_postponed_sack(sk);
 		tcp_clear_retrans_hints_partial(tp);
 	} else {
 		tp->sacked_out = 0;
 		tp->fackets_out = 0;
+		tp->sack_pending = 0;
 		tcp_clear_all_retrans_hints(tp);
 
 		tcp_for_write_queue(skb, sk, TCP_WQ_SACKED) {
@@ -2171,6 +2266,7 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 		if (tcp_is_fack(tp)) {
 			cnt = fc - fack_count_base + tcp_skb_pcount(skb);
 		} else {
+			/* FIXME: SACK postponing adaption */
 			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
 				cnt += tcp_skb_pcount(skb);
 			/* Add SACK blocks between this and skb->prev */
@@ -2224,6 +2320,9 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 		skb = tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
 			: tcp_write_queue_head(sk);
 
+		/* FIXME: Performance penalty of this likely significant */
+		tcp_process_postponed_sack(sk);
+
 		tcp_for_write_queue_from(skb, sk, 0) {
 			if (skb == tcp_send_head(sk))
 				break;
@@ -2422,6 +2521,7 @@ static int tcp_try_undo_loss(struct sock *sk)
 
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
+
 		tcp_for_write_queue(skb, sk, 0) {
 			if (skb == tcp_send_head(sk))
 				break;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1d83c65..e7cb39b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -696,6 +696,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
 
+	tcp_process_postponed_sack_overlapping(sk, skb);
+
 	/* Get a new skb... force flag on. */
 	buff = sk_stream_alloc_skb(sk, nsize, GFP_ATOMIC);
 	if (buff == NULL)
@@ -1761,6 +1763,8 @@ void tcp_simple_retransmit(struct sock *sk)
 	unsigned int mss = tcp_current_mss(sk, 0);
 	int lost = 0;
 
+	tcp_process_postponed_sack(sk);
+
 	tcp_for_write_queue(skb, sk, 0) {
 		if (skb == tcp_send_head(sk))
 			break;
@@ -1928,6 +1932,9 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	struct sk_buff *skb;
 	int packet_cnt;
 
+	/* FIXME: There are better was to do this in here */
+	tcp_process_postponed_sack(sk);
+
 	if (tp->retransmit_skb_hint) {
 		skb = tp->retransmit_skb_hint;
 		packet_cnt = tp->retransmit_cnt_hint;
-- 
1.5.0.6

---696243703-1247317148-1197120552=:17809--
