From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/8] ipv4: Can final ip_route_connect() arg to boolean
 "can_sleep".
Date: Tue, 01 Mar 2011 15:11:21 -0800 (PST)
Message-ID: <20110301.151121.102558514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756985Ab1CAXKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:10:44 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0DD9924C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since that's what the current vague "flags" thing means.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    4 ++--
 net/dccp/ipv4.c     |    2 +-
 net/ipv4/af_inet.c  |    2 +-
 net/ipv4/datagram.c |    2 +-
 net/ipv4/tcp_ipv4.c |    2 +-
 net/l2tp/l2tp_ip.c  |    2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index b3f89ad..5e0826d 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -168,7 +168,7 @@ static inline char rt_tos2priority(u8 tos)
 static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 				   __be32 src, u32 tos, int oif, u8 protocol,
 				   __be16 sport, __be16 dport, struct sock *sk,
-				   int flags)
+				   bool can_sleep)
 {
 	struct flowi fl = { .oif = oif,
 			    .mark = sk->sk_mark,
@@ -196,7 +196,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 		*rp = NULL;
 	}
 	security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(net, rp, &fl, sk, flags);
+	return ip_route_output_flow(net, rp, &fl, sk, can_sleep ? 1 : 0);
 }
 
 static inline int ip_route_newports(struct rtable **rp, u8 protocol,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 9379891..8372d5c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -69,7 +69,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_DCCP,
-			       orig_sport, orig_dport, sk, 1);
+			       orig_sport, orig_dport, sk, true);
 	if (tmp < 0)
 		return tmp;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7ceb804..d16687d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1115,7 +1115,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 			       RT_CONN_FLAGS(sk),
 			       sk->sk_bound_dev_if,
 			       sk->sk_protocol,
-			       inet->inet_sport, inet->inet_dport, sk, 0);
+			       inet->inet_sport, inet->inet_dport, sk, false);
 	if (err)
 		return err;
 
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 174be6c..eaee1ed 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -49,7 +49,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	err = ip_route_connect(&rt, usin->sin_addr.s_addr, saddr,
 			       RT_CONN_FLAGS(sk), oif,
 			       sk->sk_protocol,
-			       inet->inet_sport, usin->sin_port, sk, 1);
+			       inet->inet_sport, usin->sin_port, sk, true);
 	if (err) {
 		if (err == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 27a0cc8..05bc6d9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -173,7 +173,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
-			       orig_sport, orig_dport, sk, 1);
+			       orig_sport, orig_dport, sk, true);
 	if (tmp < 0) {
 		if (tmp == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 110efb7..28e876a 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -323,7 +323,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	rc = ip_route_connect(&rt, lsa->l2tp_addr.s_addr, saddr,
 			      RT_CONN_FLAGS(sk), oif,
 			      IPPROTO_L2TP,
-			      0, 0, sk, 1);
+			      0, 0, sk, true);
 	if (rc) {
 		if (rc == -ENETUNREACH)
 			IP_INC_STATS_BH(&init_net, IPSTATS_MIB_OUTNOROUTES);
-- 
1.7.4.1

