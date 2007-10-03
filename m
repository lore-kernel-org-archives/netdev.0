From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 3 Oct 2007 15:34:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
 <470383D4.9060307@free.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1634493052-1191414881=:27745"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39425 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120AbXJCMeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 08:34:46 -0400
In-Reply-To: <470383D4.9060307@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1634493052-1191414881=:27745
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 3 Oct 2007, Cedric Le Goater wrote:

> Ilpo Järvinen wrote:
> > Sacktag fastpath_cnt_hint seems to be very tricky to get right...
> > I suppose this one fixes Cedric's case. I cannot say for sure    
> > until there is something more definite indication of
> > tcp_retrans_try_collapse origin than what the simple late WARN_ON
> > gave for us. ...Especially since it's non-trivial to have skb
> > hint "correctly" positioned in the write_queue while still ending
> > up calling that function. However, considering how difficult it
> > seems to be for Cedric to reproduce, it might well be this one.
> > 
> > In addition, I noticed another reset which wasn't previously   
> > converted to WARN_ON, so doing that now. Boot + simple xfer
> > tested. Please apply to net-2.6.24.
> 
> I'm dropping the previous patches you sent me and switching to this patchset. 
> right ?

Yes you can do that... However, there are two ways forward:

1) Drop and test with this patchset long enough to verify it's gone...
2) No dropping and get the more exact trace by reproducing, which can 
   point out to tcp_retrans_try_collapse confirming the source of the
   bug or revealing yet another bug...

The first one has one drawback, it cannot prove the fix very well since 
the bug could just not occur by chance... Path 2 would clearly show the 
place from where the problem originates because we will know that it got 
triggered! I personally would prefer path 2 but whether you want to go for 
that depends on the time you want to invest in it...

...I rediffed the tcp_verify_fackets patch too (below) just in case it 
would be something else in you case and you choose path 1 (put it on top 
of this patchset, applies with some offsets). In case the problem is gone, 
it shouldn't trigger and if it does, we'll have another bug caught.

Anyway, thanks for ccing right persons and netdev right from the 
beginning.


-- 
 i.

 include/net/tcp.h     |    3 +
 net/ipv4/tcp_input.c  |   25 +++++++++---
 net/ipv4/tcp_ipv4.c   |  103 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |    6 ++-
 4 files changed, 130 insertions(+), 7 deletions(-)

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
index 87c9ef5..93bdc20 100644
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
@@ -1160,8 +1160,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int first_sack_index;
 
 	if (!tp->sacked_out) {
-		if (WARN_ON(tp->fackets_out))
+		if (WARN_ON(tp->fackets_out)) {
 			tp->fackets_out = 0;
+			tcp_print_queue(sk);
+		}
 		tp->highest_sack = tp->snd_una;
 	}
 	prior_fackets = tp->fackets_out;
@@ -1421,6 +1423,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			}
 		}
 	}
+	tcp_verify_fackets(sk);
 
 	/* Check for lost retransmit. This superb idea is
 	 * borrowed from "ratehalving". Event "C".
@@ -1633,13 +1636,14 @@ void tcp_enter_frto(struct sock *sk)
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
@@ -1676,6 +1680,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_fackets(sk);
 
 	tp->snd_cwnd = tcp_packets_in_flight(tp) + allowed_segments;
 	tp->snd_cwnd_cnt = 0;
@@ -1754,6 +1759,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_fackets(sk);
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
@@ -2309,7 +2315,7 @@ static void tcp_mtup_probe_success(struct sock *sk, struct sk_buff *skb)
  * It does _not_ decide what to send, it is made in function
  * tcp_xmit_retransmit_queue().
  */
-static void
+void
 tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2323,8 +2329,11 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (!tp->packets_out)
 		tp->sacked_out = 0;
 
-	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
+	if (WARN_ON(!tp->sacked_out && tp->fackets_out)) {
+		printk(KERN_ERR "TCP %d\n", tcp_is_reno(tp));
+		tcp_print_queue(sk);
 		tp->fackets_out = 0;
+	}
 
 	/* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
@@ -2334,6 +2343,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	/* B. In all the states check for reneging SACKs. */
 	if (tp->sacked_out && tcp_check_sack_reneging(sk))
 		return;
+	
+	tcp_verify_fackets(sk);
 
 	/* C. Process data loss notification, provided it is valid. */
 	if ((flag&FLAG_DATA_LOST) &&
@@ -2573,7 +2584,7 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
  * is before the ack sequence we can discard it as it's confirmed to have
  * arrived at the other end.
  */
-static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
+int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2695,6 +2706,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
 		}
 	}
+	tcp_verify_fackets(sk);
+
 
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7fed0a6..b5877d0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -108,6 +108,109 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
 };
 
+void tcp_print_queue(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	char s[50+1];
+	char i[50+1];
+	int idx = 0;
+	u32 hs = tp->highest_sack;
+	
+	if (!tp->sacked_out)
+		hs = tp->snd_una;
+	
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+		
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+			if (skb->len < tp->mss_cache)
+				s[idx] = 's';
+			else
+				s[idx] = 'S';
+		} else {
+			s[idx] = '-';
+		}
+		if ((TCP_SKB_CB(skb)->seq == hs) && (tp->fastpath_skb_hint == skb))
+			i[idx] = 'x';
+		else if (tp->fastpath_skb_hint == skb)
+			i[idx] = 'f';
+		else if (TCP_SKB_CB(skb)->seq == hs)
+			i[idx] = 'h';
+		else
+			i[idx] = ' ';
+			
+		if (++idx >= 50) {
+			s[idx] = 0;
+			i[idx] = 0;
+			printk(KERN_ERR "TCP wq(s) %s\n", s);
+			printk(KERN_ERR "TCP wq(i) %s\n", i);
+			idx = 0;
+		}
+	}
+	if (idx) {
+		s[idx] = '<';
+		s[idx+1] = 0;
+		i[idx] = '<';
+		i[idx+1] = 0;
+		printk(KERN_ERR "TCP wq(s) %s\n", s);
+		printk(KERN_ERR "TCP wq(i) %s\n", i);
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
index 5329675..3aba96a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -773,6 +773,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 			tcp_verify_left_out(tp);
 		}
 		tcp_adjust_fackets_out(tp, skb, diff);
+		
+		tcp_verify_fackets(sk);
 	}
 
 	/* Link BUFF into the send queue. */
@@ -1688,7 +1690,7 @@ u32 __tcp_select_window(struct sock *sk)
 }
 
 /* Attempt to collapse two adjacent SKB's during retransmission. */
-static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int mss_now)
+void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int mss_now)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *next_skb = tcp_write_queue_next(sk, skb);
@@ -1766,6 +1768,8 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int m
 			tp->fastpath_cnt_hint -= tcp_skb_pcount(skb);
 		}
 
+		tcp_verify_fackets(sk);
+
 		sk_stream_free_skb(sk, next_skb);
 	}
 }
-- 
1.5.0.6

---696243703-1634493052-1191414881=:27745--
