From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] l2tp: fix a race in l2tp_ip_sendmsg()
Date: Fri, 08 Jun 2012 18:25:00 +0200
Message-ID: <1339172700.6001.128.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:34499 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422Ab2FHQZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 12:25:04 -0400
Received: by eeit10 with SMTP id t10so1220825eei.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 09:25:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 081b1b1bb27f (l2tp: fix l2tp_ip_sendmsg() route handling) added
a race, in case IP route cache is disabled.

In this case, we should not do the dst_release(&rt->dst), since it'll
free the dst immediately, instead of waiting a RCU grace period.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Chapman <jchapman@katalix.com>
Cc: Denys Fedoryshchenko <denys@visp.net.lb>
---
 net/l2tp/l2tp_ip.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 70614e7..61d8b75 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -464,10 +464,12 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 					   sk->sk_bound_dev_if);
 		if (IS_ERR(rt))
 			goto no_route;
-		if (connected)
+		if (connected) {
 			sk_setup_caps(sk, &rt->dst);
-		else
-			dst_release(&rt->dst); /* safe since we hold rcu_read_lock */
+		} else {
+			skb_dst_set(skb, &rt->dst);
+			goto xmit;
+		}
 	}
 
 	/* We dont need to clone dst here, it is guaranteed to not disappear.
@@ -475,6 +477,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	 */
 	skb_dst_set_noref(skb, &rt->dst);
 
+xmit:
 	/* Queue the packet to IP for output */
 	rc = ip_queue_xmit(skb, &inet->cork.fl);
 	rcu_read_unlock();
