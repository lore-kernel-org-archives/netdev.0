From: James M Leddy <james.leddy@redhat.com>
Subject: [PATCH] udp: Add MIB counters for rcvbuferrors
Date: Tue, 17 Jun 2014 16:13:02 -0400
Message-ID: <1403035982-6548-1-git-send-email-james.leddy@redhat.com>
Cc: James M Leddy <james.leddy@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932927AbaFQUNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 16:13:35 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s5HKDZ1u014263
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 16:13:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MIB counters for rcvbuferrors in UDP to help diagnose problems.

Signed-off-by: James M Leddy <james.leddy@redhat.com>
---
 net/ipv4/udp.c |   13 ++++++++-----
 net/ipv6/udp.c |   15 ++++++++++-----
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4468e1a..8059902 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1542,12 +1542,17 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (rcu_access_pointer(sk->sk_filter) &&
-	    udp_lib_checksum_complete(skb))
-		goto csum_error;
+	    udp_lib_checksum_complete(skb)) {
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
+		goto drop;
+	}
 
 
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+				 is_udplite);
 		goto drop;
+	}
 
 	rc = 0;
 
@@ -1563,8 +1568,6 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	return rc;
 
-csum_error:
-	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 drop:
 	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	atomic_inc(&sk->sk_drops);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d9..94ba69c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -666,12 +666,18 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (rcu_access_pointer(sk->sk_filter)) {
-		if (udp_lib_checksum_complete(skb))
-			goto csum_error;
+		if (udp_lib_checksum_complete(skb)) {
+			UDP6_INC_STATS_BH(sock_net(sk),
+					  UDP_MIB_CSUMERRORS, is_udplite);
+			goto drop;
+		}
 	}
 
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
+		UDP6_INC_STATS_BH(sock_net(sk),
+				  UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
+	}
 
 	skb_dst_drop(skb);
 
@@ -686,8 +692,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_unlock_sock(sk);
 
 	return rc;
-csum_error:
-	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
+
 drop:
 	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	atomic_inc(&sk->sk_drops);
-- 
1.7.1
