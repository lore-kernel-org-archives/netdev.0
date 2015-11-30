From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: suppress too verbose messages in
 tcp_send_ack()
Date: Mon, 30 Nov 2015 08:57:28 -0800
Message-ID: <1448902648.24696.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151130.110607.1409128209032271059.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34331 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbbK3Q5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 11:57:30 -0500
Received: by padhx2 with SMTP id hx2so190121433pad.1
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 08:57:30 -0800 (PST)
In-Reply-To: <20151130.110607.1409128209032271059.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If tcp_send_ack() can not allocate skb, we properly handle this
and setup a timer to try later.

Use __GFP_NOWARN to avoid polluting syslog in the case host is
under memory pressure, so that pertinent messages are not lost under
a flood of useless information.

sk_gfp_atomic() can use its gfp_mask argument (all callers currently
were using GFP_ATOMIC before this patch)

We rename sk_gfp_atomic() to sk_gfp_mask() to clearly express this
function now takes into account its second argument (gfp_mask)

Note that when tcp_transmit_skb() is called with clone_it set to false,
we do not attempt memory allocations, so can pass a 0 gfp_mask, which
most compilers can emit faster than a non zero or constant value.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: rename sk_gfp_atomic() to sk_gfp_mask()

 include/net/sock.h    |    4 ++--
 net/ipv4/tcp_output.c |   14 ++++++++------
 net/ipv6/tcp_ipv6.c   |    6 +++---
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4ba18d1..89073bda77df 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -774,9 +774,9 @@ static inline int sk_memalloc_socks(void)
 
 #endif
 
-static inline gfp_t sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
+static inline gfp_t sk_gfp_mask(const struct sock *sk, gfp_t gfp_mask)
 {
-	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
+	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
 }
 
 static inline void sk_acceptq_removed(struct sock *sk)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cb7ca569052c..a800cee88035 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2296,7 +2296,7 @@ void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 		return;
 
 	if (tcp_write_xmit(sk, cur_mss, nonagle, 0,
-			   sk_gfp_atomic(sk, GFP_ATOMIC)))
+			   sk_gfp_mask(sk, GFP_ATOMIC)))
 		tcp_check_probe_timer(sk);
 }
 
@@ -3352,8 +3352,9 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
-	if (!buff) {
+	buff = alloc_skb(MAX_TCP_HEADER,
+			 sk_gfp_mask(sk, GFP_ATOMIC | __GFP_NOWARN));
+	if (unlikely(!buff)) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
@@ -3375,7 +3376,7 @@ void tcp_send_ack(struct sock *sk)
 
 	/* Send it off, this clears delayed acks for us. */
 	skb_mstamp_get(&buff->skb_mstamp);
-	tcp_transmit_skb(sk, buff, 0, sk_gfp_atomic(sk, GFP_ATOMIC));
+	tcp_transmit_skb(sk, buff, 0, (__force gfp_t)0);
 }
 EXPORT_SYMBOL_GPL(tcp_send_ack);
 
@@ -3396,7 +3397,8 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent, int mib)
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
-	skb = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
+	skb = alloc_skb(MAX_TCP_HEADER,
+			sk_gfp_mask(sk, GFP_ATOMIC | __GFP_NOWARN));
 	if (!skb)
 		return -1;
 
@@ -3409,7 +3411,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent, int mib)
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPHDR_ACK);
 	skb_mstamp_get(&skb->skb_mstamp);
 	NET_INC_STATS(sock_net(sk), mib);
-	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
+	return tcp_transmit_skb(sk, skb, 0, (__force gfp_t)0);
 }
 
 void tcp_send_window_probe(struct sock *sk)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c5429a636f1a..41bcd59a2ac7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1130,7 +1130,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		 */
 		tcp_md5_do_add(newsk, (union tcp_md5_addr *)&newsk->sk_v6_daddr,
 			       AF_INET6, key->key, key->keylen,
-			       sk_gfp_atomic(sk, GFP_ATOMIC));
+			       sk_gfp_mask(sk, GFP_ATOMIC));
 	}
 #endif
 
@@ -1146,7 +1146,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		/* Clone pktoptions received with SYN, if we own the req */
 		if (ireq->pktopts) {
 			newnp->pktoptions = skb_clone(ireq->pktopts,
-						      sk_gfp_atomic(sk, GFP_ATOMIC));
+						      sk_gfp_mask(sk, GFP_ATOMIC));
 			consume_skb(ireq->pktopts);
 			ireq->pktopts = NULL;
 			if (newnp->pktoptions)
@@ -1212,7 +1212,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 					       --ANK (980728)
 	 */
 	if (np->rxopt.all)
-		opt_skb = skb_clone(skb, sk_gfp_atomic(sk, GFP_ATOMIC));
+		opt_skb = skb_clone(skb, sk_gfp_mask(sk, GFP_ATOMIC));
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		struct dst_entry *dst = sk->sk_rx_dst;
