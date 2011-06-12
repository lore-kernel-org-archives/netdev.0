From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] l2tp: fix l2tp_ip_sendmsg() route handling
Date: Sun, 12 Jun 2011 10:27:09 +0200
Message-ID: <1307867229.2872.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55411 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab1FLI1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 04:27:16 -0400
Received: by wya21 with SMTP id 21so2622299wya.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 01:27:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_ip_sendmsg() in non connected mode incorrectly calls
sk_setup_caps(). Subsequent send() calls send data to wrong destination.

We can also avoid changing dst refcount in connected mode, using
appropriate rcu locking. Once output route lookups can also be done
under rcu, sendto() calls wont change dst refcounts too.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: James Chapman <jchapman@katalix.com>
---
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index b6466e7..d21e7eb 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -480,18 +480,16 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	if (connected)
 		rt = (struct rtable *) __sk_dst_check(sk, 0);
 
+	rcu_read_lock();
 	if (rt == NULL) {
-		struct ip_options_rcu *inet_opt;
+		const struct ip_options_rcu *inet_opt;
 
-		rcu_read_lock();
 		inet_opt = rcu_dereference(inet->inet_opt);
 
 		/* Use correct destination address if we have options. */
 		if (inet_opt && inet_opt->opt.srr)
 			daddr = inet_opt->opt.faddr;
 
-		rcu_read_unlock();
-
 		/* If this fails, retransmit mechanism of transport layer will
 		 * keep trying until route appears or the connection times
 		 * itself out.
@@ -503,12 +501,20 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 					   sk->sk_bound_dev_if);
 		if (IS_ERR(rt))
 			goto no_route;
-		sk_setup_caps(sk, &rt->dst);
+		if (connected)
+			sk_setup_caps(sk, &rt->dst);
+		else
+			dst_release(&rt->dst); /* safe since we hold rcu_read_lock */
 	}
-	skb_dst_set(skb, dst_clone(&rt->dst));
+
+	/* We dont need to clone dst here, it is guaranteed to not disappear.
+	 *  __dev_xmit_skb() might force a refcount if needed.
+	 */
+	skb_dst_set_noref(skb, &rt->dst);
 
 	/* Queue the packet to IP for output */
 	rc = ip_queue_xmit(skb, &inet->cork.fl);
+	rcu_read_unlock();
 
 error:
 	/* Update stats */
@@ -525,6 +531,7 @@ out:
 	return rc;
 
 no_route:
+	rcu_read_unlock();
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	rc = -EHOSTUNREACH;


