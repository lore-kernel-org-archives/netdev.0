From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv3 net-next] tcp: kill pointless urg_mode
Date: Sat, 4 Oct 2008 15:08:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810041505340.697@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810030050001.23164@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0810032328550.30507@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0810040050540.30997@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-1333229167-1222984546=:23164"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58902 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbYJDMIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 08:08:21 -0400
In-Reply-To: <Pine.LNX.4.64.0810040050540.30997@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0810041505341.697@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1333229167-1222984546=:23164
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810032328552.30507@wrl-59.cs.helsinki.fi>

On Sat, 4 Oct 2008, Ilpo Järvinen wrote:

> On Fri, 3 Oct 2008, Ilpo Järvinen wrote:
> 
> > On Fri, 3 Oct 2008, Ilpo Järvinen wrote:
> > 
> > > It all started from me noticing that this urgent check in
> > > tcp_clean_rtx_queue is unnecessarily inside the loop. Then
> > > I took a longer look to it and found out that the users of
> > > urg_mode can trivially do without. Just drag snd_up with
> > > us when we advance.
> > 
> > Please hold a minute with this one while I inspect why I saw
> > some strange urg now in a tcpdump.
> 
> Ok, now it's right with win probes too...
>
> --
> 
> [PATCHv2 net-next] tcp: kill pointless urg_mode

Even better this time... tcp_urg_mode moved to tcp_output.c and exchanged
the tcp_transmit_skb checks to the original order.

--
[PATCHv3 net-next] tcp: kill pointless urg_mode

It all started from me noticing that this urgent check in
tcp_clean_rtx_queue is unnecessarily inside the loop. Then
I took a longer look to it and found out that the users of
urg_mode can trivially do without, well almost, there was
one gotcha.

Bonus: those funny people who use urg with >= 2^31 write_seq -
snd_una could now rejoice too (that's the only purpose for the
between being there, otherwise a simple compare would have done
the thing). Not that I assume that the rest of the tcp code
happily lives with such mind-boggling numbers :-). Alas, it
turned out to be impossible to set wmem to such numbers anyway,
yes I really tried a big sendfile after setting some wmem but
nothing happened :-). ...Tcp_wmem is int and so is sk_sndbuf...
So I hacked a bit variable to long and found out that it seems
to work... :-)

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h      |    9 ++++-----
 net/ipv4/tcp.c           |    4 +---
 net/ipv4/tcp_input.c     |   11 ++++++-----
 net/ipv4/tcp_minisocks.c |    1 +
 net/ipv4/tcp_output.c    |   18 ++++++++++++------
 5 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7672906..fe77e14 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -312,8 +312,11 @@ struct tcp_sock {
 	u32	retrans_out;	/* Retransmitted packets out		*/
 
 	u16	urg_data;	/* Saved octet of OOB data and control flags */
-	u8	urg_mode;	/* In urgent mode		*/
 	u8	ecn_flags;	/* ECN status bits.			*/
+	u8	reordering;	/* Packet reordering metric.		*/
+	u32	snd_up;		/* Urgent pointer		*/
+
+	u8	keepalive_probes; /* num of allowed keep alive probes	*/
 /*
  *      Options received (usually on last packet, some only on SYN packets).
  */
@@ -361,8 +364,6 @@ struct tcp_sock {
 
 	u32	lost_retrans_low;	/* Sent seq after any rxmit (lowest) */
 
-	u8	reordering;	/* Packet reordering metric.		*/
-	u8	keepalive_probes; /* num of allowed keep alive probes	*/
 	u32	prior_ssthresh; /* ssthresh saved at recovery start	*/
 	u32	high_seq;	/* snd_nxt at onset of congestion	*/
 
@@ -374,8 +375,6 @@ struct tcp_sock {
 	u32	total_retrans;	/* Total retransmits for entire connection */
 
 	u32	urg_seq;	/* Seq of received urgent pointer */
-	u32	snd_up;		/* Urgent pointer		*/
-
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ab341e..87268d2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -493,10 +493,8 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 static inline void tcp_mark_urg(struct tcp_sock *tp, int flags,
 				struct sk_buff *skb)
 {
-	if (flags & MSG_OOB) {
-		tp->urg_mode = 1;
+	if (flags & MSG_OOB)
 		tp->snd_up = tp->write_seq;
-	}
 }
 
 static inline void tcp_push(struct sock *sk, int flags, int mss_now,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f1f4b12..db1f194 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2840,7 +2840,8 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
  * is before the ack sequence we can discard it as it's confirmed to have
  * arrived at the other end.
  */
-static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
+static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
+			       u32 prior_snd_una)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2907,9 +2908,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 		if (sacked & TCPCB_LOST)
 			tp->lost_out -= acked_pcount;
 
-		if (unlikely(tp->urg_mode && !before(end_seq, tp->snd_up)))
-			tp->urg_mode = 0;
-
 		tp->packets_out -= acked_pcount;
 		pkts_acked += acked_pcount;
 
@@ -2939,6 +2937,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 			tp->lost_skb_hint = NULL;
 	}
 
+	if (likely(between(tp->snd_up, prior_snd_una, tp->snd_una)))
+		tp->snd_up = tp->snd_una;
+
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 		flag |= FLAG_SACK_RENEGING;
 
@@ -3315,7 +3316,7 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 		goto no_queue;
 
 	/* See if we can take anything off of the retransmit queue. */
-	flag |= tcp_clean_rtx_queue(sk, prior_fackets);
+	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
 
 	if (tp->frto_counter)
 		frto_cwnd = tcp_process_frto(sk, flag);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f976fc5..779f2e9 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -395,6 +395,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->pred_flags = 0;
 		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
 		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
+		newtp->snd_up = treq->snt_isn + 1;
 
 		tcp_prequeue_init(newtp);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a8499ef..f0545db 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -345,6 +345,11 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	TCP_SKB_CB(skb)->end_seq = seq;
 }
 
+static inline int tcp_urg_mode(const struct tcp_sock *tp)
+{
+	return tp->snd_una != tp->snd_up;
+}
+
 #define OPTION_SACK_ADVERTISE	(1 << 0)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
@@ -646,7 +651,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	th->check		= 0;
 	th->urg_ptr		= 0;
 
-	if (unlikely(tp->urg_mode &&
+	/* The urg_mode check is necessary during a below snd_una win probe */
+	if (unlikely(tcp_urg_mode(tp) &&
 		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
 		th->urg_ptr		= htons(tp->snd_up - tcb->seq);
 		th->urg			= 1;
@@ -1012,7 +1018,7 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
 /* Compute the current effective MSS, taking SACKs and IP options,
  * and even PMTU discovery events into account.
  *
- * LARGESEND note: !urg_mode is overkill, only frames up to snd_up
+ * LARGESEND note: !tcp_urg_mode is overkill, only frames up to snd_up
  * cannot be large. However, taking into account rare use of URG, this
  * is not a big flaw.
  */
@@ -1029,7 +1035,7 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 
 	mss_now = tp->mss_cache;
 
-	if (large_allowed && sk_can_gso(sk) && !tp->urg_mode)
+	if (large_allowed && sk_can_gso(sk) && !tcp_urg_mode(tp))
 		doing_tso = 1;
 
 	if (dst) {
@@ -1193,7 +1199,7 @@ static inline int tcp_nagle_test(struct tcp_sock *tp, struct sk_buff *skb,
 	/* Don't use the nagle rule for urgent data (or for the final FIN).
 	 * Nagle can be ignored during F-RTO too (see RFC4138).
 	 */
-	if (tp->urg_mode || (tp->frto_counter == 2) ||
+	if (tcp_urg_mode(tp) || (tp->frto_counter == 2) ||
 	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN))
 		return 1;
 
@@ -2358,6 +2364,7 @@ static void tcp_connect_init(struct sock *sk)
 	tcp_init_wl(tp, tp->write_seq, 0);
 	tp->snd_una = tp->write_seq;
 	tp->snd_sml = tp->write_seq;
+	tp->snd_up = tp->write_seq;
 	tp->rcv_nxt = 0;
 	tp->rcv_wup = 0;
 	tp->copied_seq = 0;
@@ -2567,8 +2574,7 @@ int tcp_write_wakeup(struct sock *sk)
 			tcp_event_new_data_sent(sk, skb);
 		return err;
 	} else {
-		if (tp->urg_mode &&
-		    between(tp->snd_up, tp->snd_una + 1, tp->snd_una + 0xFFFF))
+		if (between(tp->snd_up, tp->snd_una + 1, tp->snd_una + 0xFFFF))
 			tcp_xmit_probe_skb(sk, 1);
 		return tcp_xmit_probe_skb(sk, 0);
 	}
-- 
1.5.2.2

---696208474-1333229167-1222984546=:23164--
