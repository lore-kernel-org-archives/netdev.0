From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH] tcp: refine autocork condition check
Date: Wed, 15 Oct 2014 18:34:53 +0800
Message-ID: <8e0610510498c7f6ecbe2e99ab6044030f93f792.1413369212.git.panweiping3@gmail.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbaJOKfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 06:35:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inspired by commit b2532eb9abd8 (tcp: fix ooo_okay setting vs Small Queues).

The last check in tcp_should_autocork() was meant to check that whether we
only have an ACK in Qdisc/NIC queues, or if TX completion was delayed after we
processed ACK packet, if so, we should push the packet immediately instead of
corking it.
Therefore we should compare sk_wmem_alloc with SKB_TRUESIZE(1) instead of
skb->truesize.

After this patch, tcp should have more chances to be corked, and the
performance should be a little better.  And netperf shows that this patch
works as expected.

./super_netperf.sh 300 -H 10.16.42.249 -t TCP_STREAM -- -m 1 -M 1
	      speed	TCPAutoCorking
Before patch: 169.38    222278
After patch:  173.27    232988

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 461003d..44f0bc6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -647,7 +647,7 @@ static bool tcp_should_autocork(struct sock *sk, struct sk_buff *skb,
 	return skb->len < size_goal &&
 	       sysctl_tcp_autocorking &&
 	       skb != tcp_write_queue_head(sk) &&
-	       atomic_read(&sk->sk_wmem_alloc) > skb->truesize;
+	       atomic_read(&sk->sk_wmem_alloc) > SKB_TRUESIZE(1);
 }
 
 static void tcp_push(struct sock *sk, int flags, int mss_now,
@@ -675,7 +675,7 @@ static void tcp_push(struct sock *sk, int flags, int mss_now,
 		/* It is possible TX completion already happened
 		 * before we set TSQ_THROTTLED.
 		 */
-		if (atomic_read(&sk->sk_wmem_alloc) > skb->truesize)
+		if (atomic_read(&sk->sk_wmem_alloc) > SKB_TRUESIZE(1))
 			return;
 	}
 
-- 
1.7.4
