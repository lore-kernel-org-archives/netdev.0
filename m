From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc8: WARNING: at net/ipv4/tcp_input.c:2173
 tcp_mark_head_lost+0x11d/0x150()
Date: Fri, 4 Apr 2008 21:51:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804031744190.32094@wrl-59.cs.helsinki.fi>
References: <1207199456.7616.3.camel@localhost>
 <Pine.LNX.4.64.0804031616330.21524@wrl-59.cs.helsinki.fi>
 <1207230008.4513.14.camel@localhost>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-46615883-1207234130=:32094"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Soeren Sonnenburg <kernel@nn7.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35444 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757514AbYDDSv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 14:51:56 -0400
In-Reply-To: <1207230008.4513.14.camel@localhost>
Content-ID: <Pine.LNX.4.64.0804042147160.415@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-46615883-1207234130=:32094
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0804042147161.415@wrl-59.cs.helsinki.fi>

On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:

> On Thu, 2008-04-03 at 16:26 +0300, Ilpo Järvinen wrote:
> > On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
> > 
> > > trying to download things, I am seeing this (ignore the tainted, it is
> > > from madwifi and although the module is loaded the device was never
> > > used)
> > > 
> > > Could anyone make sense of this please?
> > 
> > ...I'm just trying to find out who and where invariants of the TCP code
> > are broken. These were relatively recently enabled (pre-2.6.24 just didn't 
> > care too much). A number of long standing issues plus bugs from my 
> > modifications have been fixed because of the more rigid checking :-).
> > 
> > > ------------[ cut here ]------------
> > > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11d/0x150()
> > 
> > > ------------[ cut here ]------------
> > > WARNING: at net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x267/0x270()
> > 
> > > ------------[ cut here ]------------
> > > WARNING: at net/ipv4/tcp_input.c:2532 tcp_ack+0x1a6f/0x1d60()
> > 
> > Can you reproduce it? 
> 
> Yes, by massively downloading things :-) But I have no real recipe to
> make it easily reproducible...

Good :-), no need for recipes, just that you can trigger it more often 
tha once per month or so :-). I probably couldn't trigger it anyway here 
because they're often rather sensitive to network "weather", thus if you 
have problems in reproducing, doing tests around the same phase of the 
date cycle you saw it the first time might help.

Here's a debug patch which expensively verifies TCP's state in a number
of places during ACK to find first spot where the actual bug occurs.


-- 
 i.


[PATCH] TCP: debug S+L (for 2.6.25-rcs, incompatible with 2.6.24.y), v1.4

Debugs sacked & lost skb inconstencies in TCP write queue &
verifies fackets_out related variables.
---
 include/net/tcp.h     |   10 +++-
 net/ipv4/tcp_input.c  |   29 ++++++++++-
 net/ipv4/tcp_ipv4.c   |  134 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |   24 +++++++--
 4 files changed, 189 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 723b368..5cdc93d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -274,6 +274,9 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
+extern void tcp_print_queue(struct sock *sk);
+extern int			tcp_verify_wq(struct sock *sk);
+
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void			tcp_shutdown (struct sock *sk, int how);
@@ -776,7 +779,12 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 }
 
 /* Use define here intentionally to get WARN_ON location shown at the caller */
-#define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
+#define tcp_verify_left_out(tp)		\
+	do {\
+		int res; \
+		res = tcp_verify_wq((struct sock *)tp); \
+		WARN_ON(res || tcp_left_out(tp) > tp->packets_out); \
+	} while(0)
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6e46b4c..4dc2c20 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1428,8 +1428,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	int first_sack_index;
 
 	if (!tp->sacked_out) {
-		if (WARN_ON(tp->fackets_out))
+		if (WARN_ON(tp->fackets_out)) {
+			tcp_verify_left_out(tp);
 			tp->fackets_out = 0;
+		}
 		tcp_highest_sack_reset(sk);
 	}
 
@@ -2140,7 +2142,14 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 	struct sk_buff *skb;
 	int cnt;
 
+	tcp_verify_left_out(tp);
+
 	BUG_TRAP(packets <= tp->packets_out);
+	if (packets > tp->packets_out) {
+		pr_err("TCP debug %u/%u-%u/%u %d\n",
+			tp->fackets_out, tp->sacked_out, tp->reordering,
+			tp->packets_out, tp->rx_opt.sack_ok);
+	}
 	if (tp->lost_skb_hint) {
 		skb = tp->lost_skb_hint;
 		cnt = tp->lost_cnt_hint;
@@ -2505,6 +2514,8 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0;
 
+	tcp_verify_left_out(tp);
+
 	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out = 0;
 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
@@ -2649,6 +2660,10 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
 		tcp_update_scoreboard(sk, fast_rexmit);
 	tcp_cwnd_down(sk, flag);
+
+	WARN_ON(tcp_write_queue_head(sk) == NULL);
+	WARN_ON(!tp->packets_out);
+
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -2801,6 +2816,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 			tcp_mtup_probe_success(sk, skb);
 		}
 
+		WARN_ON((sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST)) ==
+				  (TCPCB_SACKED_ACKED|TCPCB_LOST));
+
 		if (sacked & TCPCB_RETRANS) {
 			if (sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out -= acked_pcount;
@@ -2891,6 +2909,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
@@ -3179,6 +3199,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	prior_fackets = tp->fackets_out;
 	prior_in_flight = tcp_packets_in_flight(tp);
 
+	tcp_verify_left_out(tp);
+
 	if (!(flag & FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
 		 * No more checks are required.
@@ -3238,9 +3260,14 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
 	}
 
+	if (WARN_ON((icsk->icsk_ca_state == TCP_CA_Open) && tcp_left_out(tp)))
+		tcp_print_queue(sk);
+
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
 		dst_confirm(sk->sk_dst_cache);
 
+	tcp_verify_left_out(tp);
+
 	return 1;
 
 no_queue:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ef141b8..356ee6e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -108,6 +108,140 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
 };
 
+void tcp_print_queue(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	char s[50+1];
+	char h[50+1];
+	int idx = 0;
+	int i;
+
+	i = 0;
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			printk(KERN_ERR "head %u %p\n", i, skb);
+		else
+			printk(KERN_ERR "skb %u %p\n", i, skb);
+		i++;
+	}
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		for (i = 0; i < tcp_skb_pcount(skb); i++) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+				s[idx] = 'S';
+				if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+					s[idx] = 'B';
+
+			} else if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
+				s[idx] = 'L';
+			} else {
+				s[idx] = ' ';
+			}
+			if (s[idx] != ' ' && skb->len < tp->mss_cache)
+				s[idx] += 'a' - 'A';
+
+			if (i == 0) {
+				if (skb == tcp_highest_sack(sk))
+					h[idx] = 'h';
+				else
+					h[idx] = '+';
+			} else {
+				h[idx] = '-';
+			}
+
+			if (++idx >= 50) {
+				s[idx] = 0;
+				h[idx] = 0;
+				printk(KERN_ERR "TCP wq(s) %s\n", s);
+				printk(KERN_ERR "TCP wq(h) %s\n", h);
+				idx = 0;
+			}
+		}
+	}
+	if (idx) {
+		s[idx] = '<';
+		s[idx+1] = 0;
+		h[idx] = '<';
+		h[idx+1] = 0;
+		printk(KERN_ERR "TCP wq(s) %s\n", s);
+		printk(KERN_ERR "TCP wq(h) %s\n", h);
+	}
+	printk(KERN_ERR "l%u s%u f%u p%u seq: su%u hs%u sn%u\n",
+		tp->lost_out, tp->sacked_out, tp->fackets_out, tp->packets_out,
+		tp->snd_una, tcp_highest_sack_seq(tp), tp->snd_nxt);
+}
+
+int tcp_verify_wq(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	u32 lost = 0;
+	u32 sacked = 0;
+	u32 packets = 0;
+	u32 fackets = 0;
+	int hs_valid = 0;
+	int inconsistent = 0;
+	struct sk_buff *skb;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		if ((fackets == packets) && (skb == tp->highest_sack))
+			hs_valid = 1;
+
+		packets += tcp_skb_pcount(skb);
+
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+			sacked += tcp_skb_pcount(skb);
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+				printk(KERN_ERR "Sacked bitmap S+L: %u %u-%u/%u\n",
+					TCP_SKB_CB(skb)->sacked,
+					TCP_SKB_CB(skb)->end_seq - tp->snd_una,
+					TCP_SKB_CB(skb)->seq - tp->snd_una,
+					tp->snd_una);
+			fackets = packets;
+			hs_valid = 0;
+		}
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			lost += tcp_skb_pcount(skb);
+	}
+
+	if ((fackets == packets) && (tp->highest_sack == tcp_send_head(sk)))
+		hs_valid = 1;
+
+	if ((lost != tp->lost_out) ||
+	    (tcp_is_sack(tp) && (sacked != tp->sacked_out)) ||
+	    ((sacked || (tcp_is_sack(tp) && tp->sacked_out)) && !hs_valid) ||
+	    (packets != tp->packets_out) ||
+	    (fackets != tp->fackets_out) ||
+	    (tcp_is_reno(tp) && tp->packets_out &&
+	     (tcp_left_out(tp) == tp->packets_out) &&
+	     !(TCP_SKB_CB(tcp_write_queue_head(sk))->sacked & TCPCB_LOST)) ||
+	    tcp_left_out(tp) > tp->packets_out) {
+		printk(KERN_ERR "P: %u L: %u vs %u S: %u vs %u F: %u vs %u w: %u-%u (%u)\n",
+			tp->packets_out,
+			lost, tp->lost_out,
+			sacked, tp->sacked_out,
+			fackets, tp->fackets_out,
+			tp->snd_una, tp->snd_nxt,
+			tp->rx_opt.sack_ok);
+		tcp_print_queue(sk);
+		inconsistent = 1;
+	}
+
+	WARN_ON(lost != tp->lost_out);
+	WARN_ON(tcp_is_sack(tp) && (sacked != tp->sacked_out));
+	WARN_ON(packets != tp->packets_out);
+	WARN_ON(fackets != tp->fackets_out);
+	WARN_ON(tcp_left_out(tp) > tp->packets_out);
+
+	return inconsistent;
+}
+
 static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6e25540..e7d78c2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -779,10 +779,9 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 			tp->lost_out -= diff;
 
 		/* Adjust Reno SACK estimate. */
-		if (tcp_is_reno(tp) && diff > 0) {
+		if (tcp_is_reno(tp) && diff > 0)
 			tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
-			tcp_verify_left_out(tp);
-		}
+
 		tcp_adjust_fackets_out(sk, skb, diff);
 	}
 
@@ -790,6 +789,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	skb_header_release(buff);
 	tcp_insert_write_queue_after(skb, buff, sk);
 
+	tcp_verify_left_out(tp);
+
 	return 0;
 }
 
@@ -1471,6 +1472,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 	} else if (result > 0) {
 		sent_pkts = 1;
 	}
+	tcp_verify_left_out(tp);
 
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
@@ -1772,6 +1774,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb,
 	tcp_clear_retrans_hints_partial(tp);
 
 	sk_wmem_free_skb(sk, next_skb);
+	tcp_verify_left_out(tp);
 }
 
 /* Do a simple retransmit without using the backoff mechanisms in
@@ -1803,13 +1806,13 @@ void tcp_simple_retransmit(struct sock *sk)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 	tcp_clear_all_retrans_hints(tp);
 
 	if (!lost)
 		return;
 
-	tcp_verify_left_out(tp);
-
 	/* Don't muck with the congestion window here.
 	 * Reason is that we do not increase amount of _data_
 	 * in network, but units changed and effective
@@ -1892,10 +1895,13 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
 	    tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
+			WARN_ON(TCP_SKB_CB(skb)->sacked & TCPCB_LOST);
 			/* Reuse, even though it does some unnecessary work */
 			tcp_init_nondata_skb(skb, TCP_SKB_CB(skb)->end_seq - 1,
 					     TCP_SKB_CB(skb)->flags);
 			skb->ip_summed = CHECKSUM_NONE;
+
+			tcp_verify_left_out(tp);
 		}
 	}
 
@@ -1978,8 +1984,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			 * packet to be MSS sized and all the
 			 * packet counting works out.
 			 */
-			if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
+			if (tcp_packets_in_flight(tp) >= tp->snd_cwnd) {
+				tcp_verify_left_out(tp);
 				return;
+			}
 
 			if (sacked & TCPCB_LOST) {
 				if (!(sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
@@ -2005,6 +2013,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 	/* OK, demanded retransmission is finished. */
 
 	/* Forward retransmissions are possible only during Recovery. */
@@ -2062,6 +2072,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 		NET_INC_STATS_BH(LINUX_MIB_TCPFORWARDRETRANS);
 	}
+
+	tcp_verify_left_out(tp);
 }
 
 /* Send a fin.  The caller locks the socket for us.  This cannot be
-- 
1.5.2.2
---696208474-46615883-1207234130=:32094--
