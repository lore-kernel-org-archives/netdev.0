From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Three TCP/IP warnings in 2.6.25-rc7-git1
Date: Thu, 3 Apr 2008 12:53:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804030934040.10964@wrl-59.cs.helsinki.fi>
References: <47F15200.3060706@linux.intel.com> <47F46945.40500@linux.intel.com>
 <20080402.222846.92587028.davem@davemloft.net> <20080403055435.M45441@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arjan@linux.intel.com,
	Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55344 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbYDCJxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 05:53:31 -0400
In-Reply-To: <20080403055435.M45441@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Apr 2008, Denys Fedoryshchenko wrote:

> I can reproduce it during one day on my loaded proxies. I have:
> 
> [223178.376188] WARNING: at net/ipv4/tcp_input.c:2532 tcp_ack+0xd83/0x17bd()
> and
> [273139.505308] WARNING: at net/ipv4/tcp_input.c:2173
> tcp_mark_head_lost+0x11e/0x126()
> 
> This two... maybe third, but i didn't notice it yet.

Here's a low cost patch to gather at least some info about it. I suppose 
you're not able to run the processing a processing expensive verification?

--
 i.


---
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 723b368..db641ae 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -776,7 +776,7 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 }
 
 /* Use define here intentionally to get WARN_ON location shown at the caller */
-#define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
+extern void tcp_verify_left_out(struct tcp_sock *tp);
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6e46b4c..bc4cd30 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -167,6 +167,14 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	}
 }
 
+void tcp_verify_left_out(struct tcp_sock *tp)
+{
+	if (WARN_ON(tcp_left_out(tp) > tp->packets_out)) {
+		pr_err("TCP debug %u+%u/%u %d, please report to ilpo.jarvinen@helsinki.fi\n",
+			tp->lost_out, tp->sacked_out, tp->packets_out, tp->rx_opt.sack_ok);
+	}
+}
+
 static void tcp_incr_quickack(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2141,6 +2149,11 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 	int cnt;
 
 	BUG_TRAP(packets <= tp->packets_out);
+	if (packets > tp->packets_out) {
+		pr_err("TCP debug %u-%u/%u %d, please report to ilpo.jarvinen@helsinki.fi\n",
+			tp->fackets_out, tp->reordering, tp->packets_out,
+			tp->rx_opt.sack_ok);
+	}
 	if (tp->lost_skb_hint) {
 		skb = tp->lost_skb_hint;
 		cnt = tp->lost_cnt_hint;
@@ -2507,8 +2520,11 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 
 	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out = 0;
-	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
+	if (WARN_ON(!tp->sacked_out && tp->fackets_out)) {
+		pr_err("TCP debug %u/%u %d, please report to ilpo.jarvinen@helsinki.fi\n",
+			tp->fackets_out, tp->packets_out, tp->rx_opt.sack_ok);
 		tp->fackets_out = 0;
+	}
 
 	/* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6e25540..36a12f3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1892,6 +1892,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
 	    tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
+			WARN_ON(TCP_SKB_CB(skb)->sacked & TCPCB_LOST);
 			/* Reuse, even though it does some unnecessary work */
 			tcp_init_nondata_skb(skb, TCP_SKB_CB(skb)->end_seq - 1,
 					     TCP_SKB_CB(skb)->flags);
