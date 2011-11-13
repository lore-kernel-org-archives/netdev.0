From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 2/8 2.6.32] udp: use limited socket backlog
Date: Sun, 13 Nov 2011 23:17:35 +0300
Message-ID: <20111113201735.GC1362@elgon.mountain>
References: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg@kroah.com>, Zhu Yi <yi.zhu@intel.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:39589 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab1KMURz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:17:55 -0500
Content-Disposition: inline
In-Reply-To: <20111113201336.GA1362@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had to make some changes to the first chunk in net/ipv6/udp.c to
make this to apply.

>From 55349790d7cbf0d381873a7ece1dcafcffd4aaa9 Mon Sep 17 00:00:00 2001
From: Zhu Yi <yi.zhu@intel.com>
Date: Thu, 4 Mar 2010 18:01:42 +0000
Subject: [PATCH] udp: use limited socket backlog

Make udp adapt to the limited socket backlog change.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0ac8833..2eaeaf1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1177,8 +1177,10 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc = __udp_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
+	else if (sk_add_backlog_limited(sk, skb)) {
+		bh_unlock_sock(sk);
+		goto drop;
+	}
 	bh_unlock_sock(sk);
 
 	return rc;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index ca520d4..4400eb0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -473,16 +473,19 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			bh_lock_sock(sk2);
 			if (!sock_owned_by_user(sk2))
 				udpv6_queue_rcv_skb(sk2, buff);
-			else
-				sk_add_backlog(sk2, buff);
+			else if (sk_add_backlog_limited(sk2, buff)) {
+				kfree_skb(buff);
+				bh_unlock_sock(sk2);
+				goto out;
+			}
 			bh_unlock_sock(sk2);
 		}
 	}
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
+	else if (sk_add_backlog_limited(sk, skb))
+		kfree_skb(skb);
 	bh_unlock_sock(sk);
 out:
 	spin_unlock(&hslot->lock);
@@ -601,8 +604,12 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		udpv6_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
+	else if (sk_add_backlog_limited(sk, skb)) {
+		atomic_inc(&sk->sk_drops);
+		bh_unlock_sock(sk);
+		sock_put(sk);
+		goto discard;
+	}
 	bh_unlock_sock(sk);
 	sock_put(sk);
 	return 0;
