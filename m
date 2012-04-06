From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netlink: fix races after skb queueing
Date: Fri, 06 Apr 2012 10:17:46 +0200
Message-ID: <1333700266.5312.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46373 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab2DFIRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 04:17:50 -0400
Received: by wejx9 with SMTP id x9so1324632wej.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 01:17:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As soon as an skb is queued into socket receive_queue, another thread
can consume it, so we are not allowed to reference skb anymore, or risk
use after free.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netlink/af_netlink.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 32bb753..faa48f7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -829,12 +829,19 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 	return 0;
 }
 
-int netlink_sendskb(struct sock *sk, struct sk_buff *skb)
+static int __netlink_sendskb(struct sock *sk, struct sk_buff *skb)
 {
 	int len = skb->len;
 
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk, len);
+	return len;
+}
+
+int netlink_sendskb(struct sock *sk, struct sk_buff *skb)
+{
+	int len = __netlink_sendskb(sk, skb);
+
 	sock_put(sk);
 	return len;
 }
@@ -957,8 +964,7 @@ static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 	    !test_bit(0, &nlk->state)) {
 		skb_set_owner_r(skb, sk);
-		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, skb->len);
+		__netlink_sendskb(sk, skb);
 		return atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1);
 	}
 	return -1;
@@ -1698,10 +1704,8 @@ static int netlink_dump(struct sock *sk)
 
 		if (sk_filter(sk, skb))
 			kfree_skb(skb);
-		else {
-			skb_queue_tail(&sk->sk_receive_queue, skb);
-			sk->sk_data_ready(sk, skb->len);
-		}
+		else
+			__netlink_sendskb(sk, skb);
 		return 0;
 	}
 
@@ -1715,10 +1719,8 @@ static int netlink_dump(struct sock *sk)
 
 	if (sk_filter(sk, skb))
 		kfree_skb(skb);
-	else {
-		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, skb->len);
-	}
+	else
+		__netlink_sendskb(sk, skb);
 
 	if (cb->done)
 		cb->done(cb);
