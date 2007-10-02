From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.23-rc8-mm2 - tcp_fastretrans_alert() WARNING
Date: Tue, 2 Oct 2007 23:06:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710022303510.26398@kivilampi-30.cs.helsinki.fi>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
 <46FD20F0.3050909@fr.ibm.com> <Pine.LNX.4.64.0709282143020.6013@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0709291532200.6776@kivilampi-30.cs.helsinki.fi>
 <46FE6751.3050205@free.fr> <Pine.LNX.4.64.0709292333480.8339@kivilampi-30.cs.helsinki.fi>
 <4700BD57.1090404@free.fr> <Pine.LNX.4.64.0710021310530.27745@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1712685498-1191355603=:26398"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41810 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbXJBUGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 16:06:46 -0400
In-Reply-To: <Pine.LNX.4.64.0710021310530.27745@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1712685498-1191355603=:26398
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 2 Oct 2007, Ilpo Järvinen wrote:

> I'm currently out of ideas where it could come from... so lets try 
> brute-force checking as your test case is not very high-speed... This 
> could hide it though... :-(
> 
> Please put the patch below on top of clean rc8-mm2 (it includes the patch
> I gave you last time) and try to reproduce.... These counter bugs can
> survive for sometime until !sacked_out condition occurs, so the patch
> below tries to find that out when inconsisteny occurs for the first time 
> regardless of sacked_out (I also removed some statics which hopefully 
> reduces compiler inlining for easier reading of the output). I tried this 
> myself (except for verify()s in frto funcs and minor printout 
> modifications), didn't trigger for me.

In case you haven't yet get started (or it's easy enough to replace), 
please use the one below instead (I forgot one counter from printout
in the last patch, which might turn out useful...). 

-- 
 i.


---
 include/net/tcp.h     |    3 +
 net/ipv4/tcp_input.c  |   23 +++++++++--
 net/ipv4/tcp_ipv4.c   |  103 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |    6 ++-
 4 files changed, 129 insertions(+), 6 deletions(-)

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
index e22ffe7..1d7367d 100644
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
@@ -1160,6 +1160,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int first_sack_index;
 
 	if (!tp->sacked_out) {
+		if (WARN_ON(tp->fackets_out))
+			tcp_print_queue(sk);
 		tp->fackets_out = 0;
 		tp->highest_sack = tp->snd_una;
 	}
@@ -1420,6 +1422,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			}
 		}
 	}
+	tcp_verify_fackets(sk);
 
 	/* Check for lost retransmit. This superb idea is
 	 * borrowed from "ratehalving". Event "C".
@@ -1632,13 +1635,14 @@ void tcp_enter_frto(struct sock *sk)
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
@@ -1675,6 +1679,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_fackets(sk);
 
 	tp->snd_cwnd = tcp_packets_in_flight(tp) + allowed_segments;
 	tp->snd_cwnd_cnt = 0;
@@ -1753,6 +1758,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_fackets(sk);
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
@@ -2308,7 +2314,7 @@ static void tcp_mtup_probe_success(struct sock *sk, struct sk_buff *skb)
  * It does _not_ decide what to send, it is made in function
  * tcp_xmit_retransmit_queue().
  */
-static void
+void
 tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2322,8 +2328,11 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
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
@@ -2333,6 +2342,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	/* B. In all the states check for reneging SACKs. */
 	if (tp->sacked_out && tcp_check_sack_reneging(sk))
 		return;
+	
+	tcp_verify_fackets(sk);
 
 	/* C. Process data loss notification, provided it is valid. */
 	if ((flag&FLAG_DATA_LOST) &&
@@ -2572,7 +2583,7 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
  * is before the ack sequence we can discard it as it's confirmed to have
  * arrived at the other end.
  */
-static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
+int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2694,6 +2705,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
 		}
 	}
+	tcp_verify_fackets(sk);
+
 
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7fed0a6..c38acc1 100644
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
+		tp->sacked_out, tp->fackets_out, tp->packets_out,
+		tp->fastpath_cnt_hint,
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
index 6199abe..4c70caf 100644
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
@@ -1764,6 +1766,8 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int m
 		if (tp->fastpath_skb_hint == next_skb)
 			tp->fastpath_skb_hint = skb;
 
+		tcp_verify_fackets(sk);
+
 		sk_stream_free_skb(sk, next_skb);
 	}
 }
-- 
1.5.0.6

---696243703-1712685498-1191355603=:26398--
