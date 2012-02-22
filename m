From: Neal Cardwell <ncardwell@google.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 22 Feb 2012 00:51:39 -0500
Message-ID: <20120222055139.GB8026@google.com>
References: <1329849683.18384.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:61964 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab2BVF46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 00:56:58 -0500
Received: by eaaf13 with SMTP id f13so236267eaa.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 21:56:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1329849683.18384.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A few thoughts:

(1) Currently __tcp_grow_window has a very large negative impact due
    to quantization. AFAICT from inspecting the code, the rcv_ssthresh
    converges to the following output values given the following input
    skb->truesize/skb->len input values:

truesize/len   rcv_ssthresh
------------   -------------
<= 4/3         3/4 * tcp_space()
<= 8/3         3/8 * sysctl_tcp_rmem[2]
<= 16/3        3/16 * sysctl_tcp_rmem[2]
<= 32/3        3/32 * sysctl_tcp_rmem[2]
...

  As a sanity-check of this table, note that in the report above where
  we got tcpdump traces for the beginning and end of the connection,
  the receive window converged to 338832, which was 2208 bytes above
  (3/8)*sysctl_tcp_rmem[2] for his configuration of sysctl_tcp_rmem[2]
  = 897664.

  It would be nice to get rid of this huge jump between truesize of
  4/3*skb->len and 8/3*skb->len. Ideally we could make this
  continuous?

(2) I don't think we want to scale the increment using truesize, but
    rather calculate a cap using the truesize/skb->len ratio.

(3) We should use this cap to also cap the post-incremented value of
    rcv_ssthresh, so the increment itself does not take us over the
    target. (Again, note the example where the receive window ended up
    about 2MSS above the target.)

(4) We should only request an ACK now if the rcv_ssthresh actually
    increases.

With this in mind, this is the flavor of approach that occurs to me
(compiles, but not tested):

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 53c8ce4..ddecfdb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -296,22 +296,14 @@ static void tcp_fixup_sndbuf(struct sock *sk)
  * in common situations. Otherwise, we have to rely on queue collapsing.
  */
 
-/* Slow part of check#2. */
-static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
+/* Slow part of check#2. Estimate a budget for how many bytes of
+ * receive window we can afford to advertise at the current ratio of
+ * skb->len to skb->truesize.
+ */
+static u32 tcp_rcv_ssthresh_budget(const struct sk_buff *skb)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	/* Optimize this! */
-	int truesize = tcp_win_from_space(skb->truesize) >> 1;
-	int window = tcp_win_from_space(sysctl_tcp_rmem[2]) >> 1;
-
-	while (tp->rcv_ssthresh <= window) {
-		if (truesize <= skb->len)
-			return 2 * inet_csk(sk)->icsk_ack.rcv_mss;
-
-		truesize >>= 1;
-		window >>= 1;
-	}
-	return 0;
+	u32 skb_budget = sysctl_tcp_rmem[2] / skb->truesize;
+	return (u32) (skb->len * skb_budget);
 }
 
 static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
@@ -322,20 +314,25 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
 	    !sk_under_memory_pressure(sk)) {
-		int incr;
-
 		/* Check #2. Increase window, if skb with such overhead
 		 * will fit to rcvbuf in future.
 		 */
-		if (tcp_win_from_space(skb->truesize) <= skb->len)
-			incr = 2 * tp->advmss;
-		else
-			incr = __tcp_grow_window(sk, skb);
+		u32 rcv_ssthresh_budget = tcp_rcv_ssthresh_budget(skb);
+		if (tp->rcv_ssthresh < rcv_ssthresh_budget) {
+			/* With GRO or LRO we may receive an skb of
+			 * many MSS. To enable the sender's cwnd to
+			 * grow at a healthy pace in slow start we
+			 * must open the receive window proportionally
+			 * to skb size.
+			 */
+			u32 incr = skb->len;
 
-		if (incr) {
-			tp->rcv_ssthresh = min(tp->rcv_ssthresh + incr,
-					       tp->window_clamp);
-			inet_csk(sk)->icsk_ack.quick |= 1;
+			u32 rcv_ssthresh_cap = min(rcv_ssthresh_budget, tp->window_clamp);
+			u32 rcv_ssthresh_now = min(tp->rcv_ssthresh + incr, rcv_ssthresh_cap);
+			if (tp->rcv_ssthresh != rcv_ssthresh_now) {
+				tp->rcv_ssthresh = rcv_ssthresh_now;
+				inet_csk(sk)->icsk_ack.quick |= 1;
+			}
 		}
 	}
 }

neal
