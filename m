From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tcp: tso_fragment() might avoid GFP_ATOMIC
Date: Thu, 24 Jun 2010 13:00:22 +0200
Message-ID: <1277377222.2816.296.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53470 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861Ab0FXLA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 07:00:26 -0400
Received: by wyi11 with SMTP id 11so1549660wyi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 04:00:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can pass a gfp argument to tso_fragment() and avoid GFP_ATOMIC
allocations sometimes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_output.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 51d316d..25ff62e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1460,7 +1460,7 @@ int tcp_may_send_now(struct sock *sk)
  * packet has never been sent out before (and thus is not cloned).
  */
 static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
-			unsigned int mss_now)
+			unsigned int mss_now, gfp_t gfp)
 {
 	struct sk_buff *buff;
 	int nlen = skb->len - len;
@@ -1470,7 +1470,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 	if (skb->len != skb->data_len)
 		return tcp_fragment(sk, skb, len, mss_now);
 
-	buff = sk_stream_alloc_skb(sk, 0, GFP_ATOMIC);
+	buff = sk_stream_alloc_skb(sk, 0, gfp);
 	if (unlikely(buff == NULL))
 		return -ENOMEM;
 
@@ -1768,7 +1768,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 						    cwnd_quota);
 
 		if (skb->len > limit &&
-		    unlikely(tso_fragment(sk, skb, limit, mss_now)))
+		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
 			break;
 
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;


