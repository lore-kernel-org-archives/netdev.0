From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V2 3/7] udp: use limited socket backlog
Date: Wed,  3 Mar 2010 16:36:25 +0800
Message-ID: <1267605389-7369-3-git-send-email-yi.zhu@intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60230 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872Ab0CCIes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 03:34:48 -0500
In-Reply-To: <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make udp adapt to the limited socket backlog change.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/ipv4/udp.c |    6 ++++--
 net/ipv6/udp.c |   28 ++++++++++++++++++----------
 2 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 608a544..e7eb47f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1371,8 +1371,10 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
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
index 52b8347..6480491 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -583,16 +583,20 @@ static void flush_stack(struct sock **stack, unsigned int count,
 			bh_lock_sock(sk);
 			if (!sock_owned_by_user(sk))
 				udpv6_queue_rcv_skb(sk, skb1);
-			else
-				sk_add_backlog(sk, skb1);
+			else if (sk_add_backlog_limited(sk, skb1)) {
+				kfree_skb(skb1);
+				bh_unlock_sock(sk);
+				goto drop;
+			}
 			bh_unlock_sock(sk);
-		} else {
-			atomic_inc(&sk->sk_drops);
-			UDP6_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_RCVBUFERRORS, IS_UDPLITE(sk));
-			UDP6_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_INERRORS, IS_UDPLITE(sk));
+			continue;
 		}
+drop:
+		atomic_inc(&sk->sk_drops);
+		UDP6_INC_STATS_BH(sock_net(sk),
+				UDP_MIB_RCVBUFERRORS, IS_UDPLITE(sk));
+		UDP6_INC_STATS_BH(sock_net(sk),
+				UDP_MIB_INERRORS, IS_UDPLITE(sk));
 	}
 }
 /*
@@ -754,8 +758,12 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
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
-- 
1.6.3.3

