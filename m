From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Thu, 4 Oct 2007 13:13:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710031817540.27745@kivilampi-30.cs.helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
 <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi>
 <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi>
 <4703A1BB.1040006@free.fr> <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi>
 <4703AE04.5090009@free.fr> <4703B16C.2000106@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44090 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbXJDKNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 06:13:14 -0400
In-Reply-To: <4703B16C.2000106@fr.ibm.com>
Content-ID: <Pine.LNX.4.64.0710031828281.27745@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Oct 2007, Cedric Le Goater wrote:

> Cedric Le Goater wrote:
> > 
> > Below are the messages I got on 2) right after running ketchup (which does 
> > a wget www.kernel.org) 

Oops, those tcp_fragment WARNINGs in the other mail were due to bug in 
the debug patch as it called verify too early in there (before queue was 
adjusted, no wonder it finds state inconsistent at that point, fixed that)...

...So please discard all old debug patches, they're all broken in this 
respect... :-(

> > not a warning on 1) with your extra verbose patch.
> 
> bummer, I got this one on 1) :(
>
> WARNING: at /home/legoater/linux/net-2.6.24.git/net/ipv4/tcp_input.c:2325 tcp_fastretrans_alert()
> Call Trace:
>  <IRQ>  [<ffffffff8022ddb6>] __wake_up+0x1f/0x4c
>  [<ffffffff803fd9d3>] tcp_ack+0xcee/0x18ac
>  [<ffffffff80400764>] tcp_rcv_established+0x61f/0x6df

...I just wonder why that's the first place where it occurs... Can you try 
the debug patch below (fixed verify place in tcp_fragment/collapse, added 
some of them to narrow it down, and handled GSO more user friendly way in 
the printout). Put it on top of those three patches (mm should be fine :-)).
...I wish the verify triggers way before the fastretrans trap (for some 
reason it didn't do that in the quoted trace, maybe I had some verifys 
missing in that old patch or something)...


-- 
 i.

 include/net/tcp.h     |    3 +
 net/ipv4/tcp_input.c  |   41 +++++++++++++++---
 net/ipv4/tcp_ipv4.c   |  113 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |    4 +-
 4 files changed, 154 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 991ccdc..54a0d91 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -43,6 +43,9 @@
 
 #include <linux/seq_file.h>
 
+extern void tcp_verify_fackets(struct sock *sk);
+extern void tcp_print_queue(struct sock *sk);
+
 extern struct inet_hashinfo tcp_hashinfo;
 
 extern atomic_t tcp_orphan_count;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 87c9ef5..7707b1d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1140,7 +1140,7 @@ static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
 	return dup_sack;
 }
 
-static int
+int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_una)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -1159,6 +1159,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int i;
 	int first_sack_index;
 
+	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
+		tcp_print_queue(sk);
+
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
 			tp->fackets_out = 0;
@@ -1421,6 +1424,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			}
 		}
 	}
+	tcp_verify_fackets(sk);
 
 	/* Check for lost retransmit. This superb idea is
 	 * borrowed from "ratehalving". Event "C".
@@ -1633,13 +1637,14 @@ void tcp_enter_frto(struct sock *sk)
 	tcp_set_ca_state(sk, TCP_CA_Disorder);
 	tp->high_seq = tp->snd_nxt;
 	tp->frto_counter = 1;
+	tcp_verify_fackets(sk);
 }
 
 /* Enter Loss state after F-RTO was applied. Dupack arrived after RTO,
  * which indicates that we should follow the traditional RTO recovery,
  * i.e. mark everything lost and do go-back-N retransmission.
  */
-static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
+void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1676,6 +1681,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_fackets(sk);
 
 	tp->snd_cwnd = tcp_packets_in_flight(tp) + allowed_segments;
 	tp->snd_cwnd_cnt = 0;
@@ -1754,6 +1760,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_fackets(sk);
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
@@ -2309,7 +2316,7 @@ static void tcp_mtup_probe_success(struct sock *sk, struct sk_buff *skb)
  * It does _not_ decide what to send, it is made in function
  * tcp_xmit_retransmit_queue().
  */
-static void
+void
 tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2318,13 +2325,20 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	int do_lost = is_dupack || ((flag&FLAG_DATA_SACKED) &&
 				    (tp->fackets_out > tp->reordering));
 
+	tcp_verify_fackets(sk);
+
 	/* Some technical things:
 	 * 1. Reno does not count dupacks (sacked_out) automatically. */
-	if (!tp->packets_out)
+	if (!tp->packets_out) {
+		WARN_ON(tcp_is_sack(tp) && tp->sacked_out);
 		tp->sacked_out = 0;
+	}
 
-	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
+	if (WARN_ON(!tp->sacked_out && tp->fackets_out)) {
+		printk(KERN_ERR "TCP %d\n", tcp_is_reno(tp));
+		tcp_print_queue(sk);
 		tp->fackets_out = 0;
+	}
 
 	/* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
@@ -2334,6 +2348,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	/* B. In all the states check for reneging SACKs. */
 	if (tp->sacked_out && tcp_check_sack_reneging(sk))
 		return;
+	
+	tcp_verify_fackets(sk);
 
 	/* C. Process data loss notification, provided it is valid. */
 	if ((flag&FLAG_DATA_LOST) &&
@@ -2390,6 +2406,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 		}
 	}
 
+	tcp_verify_fackets(sk);
+
 	/* F. Process state. */
 	switch (icsk->icsk_ca_state) {
 	case TCP_CA_Recovery:
@@ -2405,6 +2423,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 		if (!tcp_try_undo_loss(sk)) {
 			tcp_moderate_cwnd(tp);
 			tcp_xmit_retransmit_queue(sk);
+			tcp_verify_fackets(sk);
 			return;
 		}
 		if (icsk->icsk_ca_state != TCP_CA_Open)
@@ -2423,6 +2442,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 
 		if (!tcp_time_to_recover(sk)) {
 			tcp_try_to_open(sk, flag);
+			tcp_verify_fackets(sk);
 			return;
 		}
 
@@ -2434,6 +2454,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 			/* Restores the reduction we did in tcp_mtup_probe() */
 			tp->snd_cwnd++;
 			tcp_simple_retransmit(sk);
+			tcp_verify_fackets(sk);
 			return;
 		}
 
@@ -2460,11 +2481,13 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 		tp->snd_cwnd_cnt = 0;
 		tcp_set_ca_state(sk, TCP_CA_Recovery);
 	}
+	tcp_verify_fackets(sk);
 
 	if (do_lost || tcp_head_timedout(sk))
 		tcp_update_scoreboard(sk);
 	tcp_cwnd_down(sk, flag);
 	tcp_xmit_retransmit_queue(sk);
+	tcp_verify_fackets(sk);
 }
 
 /* Read draft-ietf-tcplw-high-performance before mucking
@@ -2573,7 +2596,7 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
  * is before the ack sequence we can discard it as it's confirmed to have
  * arrived at the other end.
  */
-static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
+int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2695,6 +2718,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
 		}
 	}
+	tcp_verify_fackets(sk);
+
 
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
@@ -3011,6 +3036,7 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 		tcp_ca_event(sk, CA_EVENT_SLOW_ACK);
 	}
 
+	tcp_verify_fackets(sk);
 	/* We passed data and got it acked, remove any soft error
 	 * log. Something worked...
 	 */
@@ -3031,6 +3057,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	if (tp->frto_counter)
 		frto_cwnd = tcp_process_frto(sk, flag);
 
+	tcp_verify_fackets(sk);
+
 	if (tcp_ack_is_dubious(sk, flag)) {
 		/* Advance CWND, if state allows this. */
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
@@ -3040,6 +3068,7 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
 			tcp_cong_avoid(sk, ack, prior_in_flight, 1);
+		tcp_verify_fackets(sk);
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7fed0a6..6a450a7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -108,6 +108,119 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
 };
 
+void tcp_print_queue(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	char s[50+1];
+	char p[50+1];
+	int idx = 0, i;
+	u32 hs = tp->highest_sack;
+	
+	if (!tp->sacked_out)
+		hs = tp->snd_una;
+	
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+		
+		for (i = 0; i < tcp_skb_pcount(skb); i++) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+				if (i)
+					s[idx] = 'g';
+				else if (tcp_skb_pcount(skb) > 1)
+					s[idx] = 'G';
+				else if (skb->len < tp->mss_cache)
+					s[idx] = 's';
+				else
+					s[idx] = 'S';
+			} else {
+				if (i)
+					s[idx] = '-';
+				else
+					s[idx] = '+';
+			}
+			p[idx] = ' ';
+			if (!i) {
+				if ((TCP_SKB_CB(skb)->seq == hs) && (tp->fastpath_skb_hint == skb))
+					p[idx] = 'x';
+				else if (tp->fastpath_skb_hint == skb)
+					p[idx] = 'f';
+				else if (TCP_SKB_CB(skb)->seq == hs)
+					p[idx] = 'h';
+			}
+			
+			if (++idx >= 50) {
+				s[idx] = 0;
+				p[idx] = 0;
+				printk(KERN_ERR "TCP wq(s) %s\n", s);
+				printk(KERN_ERR "TCP wq(i) %s\n", p);
+				idx = 0;
+			}
+		}
+	}
+	if (idx) {
+		s[idx] = '<';
+		s[idx+1] = 0;
+		p[idx] = '<';
+		p[idx+1] = 0;
+		printk(KERN_ERR "TCP wq(s) %s\n", s);
+		printk(KERN_ERR "TCP wq(i) %s\n", p);
+	}
+	printk(KERN_ERR "s%u f%u (%u) p%u seq: su%u hs%u sn%u (%u)\n",
+		tp->sacked_out, tp->fackets_out, tp->fastpath_cnt_hint,
+		tp->packets_out,
+		tp->snd_una, tp->highest_sack, tp->snd_nxt,
+		((tp->fastpath_skb_hint == NULL) ? 0 :
+			TCP_SKB_CB(tp->fastpath_skb_hint)->seq));
+}
+
+void tcp_verify_fackets(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	u32 fackets = 0;
+	int hisack_valid = 0;
+	int err = 0;
+	
+	if (tcp_is_reno(tp))
+		return;
+	
+	if (!tp->sacked_out) {
+		if (WARN_ON(tp->fackets_out))
+			err = 1;
+		else if (tp->fastpath_skb_hint == NULL)
+			return;
+	}
+	
+	/* ...expensive processing here... */
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		if (tp->sacked_out && (TCP_SKB_CB(skb)->seq == tp->highest_sack)) {
+			hisack_valid = 1;
+			if (WARN_ON(tp->fackets_out != fackets + tcp_skb_pcount(skb)))
+				err = 1;
+		}
+
+		if (skb == tp->fastpath_skb_hint)
+			if (WARN_ON(fackets != tp->fastpath_cnt_hint))
+				err = 1;
+
+		if (WARN_ON((fackets > tp->fackets_out) && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)))
+			err = 1;
+
+		fackets += tcp_skb_pcount(skb);
+	}
+	
+	if (WARN_ON(tp->sacked_out && !hisack_valid))
+		err = 1;
+	
+	if (err)
+		tcp_print_queue(sk);
+}
+
 static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
 {
 	return inet_csk_get_port(&tcp_hashinfo, sk, snum,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5329675..8a2917f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -778,6 +778,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 	/* Link BUFF into the send queue. */
 	skb_header_release(buff);
 	tcp_insert_write_queue_after(skb, buff, sk);
+	tcp_verify_fackets(sk);
 
 	return 0;
 }
@@ -1688,7 +1689,7 @@ u32 __tcp_select_window(struct sock *sk)
 }
 
 /* Attempt to collapse two adjacent SKB's during retransmission. */
-static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int mss_now)
+void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int mss_now)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *next_skb = tcp_write_queue_next(sk, skb);
@@ -1767,6 +1768,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int m
 		}
 
 		sk_stream_free_skb(sk, next_skb);
+		tcp_verify_fackets(sk);
 	}
 }
 
-- 
1.5.0.6

