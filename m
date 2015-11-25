From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: suppress too verbose messages in
 tcp_send_ack()
Date: Wed, 25 Nov 2015 13:50:50 -0800
Message-ID: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33226 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbbKYVuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 16:50:52 -0500
Received: by pabfh17 with SMTP id fh17so70960435pab.0
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 13:50:52 -0800 (PST)
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

Note that when tcp_transmit_skb() is called with clone_it set to false,
we do not attempt memory allocations, so can pass a 0 gfp_mask, which
most compilers can emit faster than a non zero value.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h    |    2 +-
 net/ipv4/tcp_output.c |   12 +++++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4ba18d1..ead514332ae8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -776,7 +776,7 @@ static inline int sk_memalloc_socks(void)
 
 static inline gfp_t sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
 {
-	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
+	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
 }
 
 static inline void sk_acceptq_removed(struct sock *sk)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cb7ca569052c..0a1d4f6ab52f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3352,8 +3352,9 @@ void tcp_send_ack(struct sock *sk)
 	 * tcp_transmit_skb() will set the ownership to this
 	 * sock.
 	 */
-	buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
-	if (!buff) {
+	buff = alloc_skb(MAX_TCP_HEADER,
+			 sk_gfp_atomic(sk, GFP_ATOMIC | __GFP_NOWARN));
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
+			sk_gfp_atomic(sk, GFP_ATOMIC | __GFP_NOWARN));
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
