From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/7] ipv4: Use flowi4_init_output() in net/route.h
Date: Thu, 31 Mar 2011 17:12:13 -0700 (PDT)
Message-ID: <20110331.171213.260095718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751809Ab1DAAMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:12:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8693524C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:12:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |   60 ++++++++++++++++++++------------------------------
 1 files changed, 24 insertions(+), 36 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index f88429c..b242885 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -149,17 +149,12 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct sock
 						   __be16 dport, __be16 sport,
 						   __u8 proto, __u8 tos, int oif)
 {
-	struct flowi4 fl4 = {
-		.flowi4_oif = oif,
-		.flowi4_flags = sk ? inet_sk_flowi_flags(sk) : 0,
-		.flowi4_mark = sk ? sk->sk_mark : 0,
-		.daddr = daddr,
-		.saddr = saddr,
-		.flowi4_tos = tos,
-		.flowi4_proto = proto,
-		.fl4_dport = dport,
-		.fl4_sport = sport,
-	};
+	struct flowi4 fl4;
+
+	flowi4_init_output(&fl4, oif, sk ? sk->sk_mark : 0, tos,
+			   RT_SCOPE_UNIVERSE, proto,
+			   sk ? inet_sk_flowi_flags(sk) : 0,
+			   daddr, saddr, dport, sport);
 	if (sk)
 		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
 	return ip_route_output_flow(net, &fl4, sk);
@@ -229,25 +224,21 @@ static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
 					      __be16 sport, __be16 dport,
 					      struct sock *sk, bool can_sleep)
 {
-	struct flowi4 fl4 = {
-		.flowi4_oif = oif,
-		.flowi4_mark = sk->sk_mark,
-		.daddr = dst,
-		.saddr = src,
-		.flowi4_tos = tos,
-		.flowi4_proto = protocol,
-		.fl4_sport = sport,
-		.fl4_dport = dport,
-	};
 	struct net *net = sock_net(sk);
 	struct rtable *rt;
+	struct flowi4 fl4;
+	__u8 flow_flags;
 
+	flow_flags = 0;
 	if (inet_sk(sk)->transparent)
-		fl4.flowi4_flags |= FLOWI_FLAG_ANYSRC;
+		flow_flags |= FLOWI_FLAG_ANYSRC;
 	if (protocol == IPPROTO_TCP)
-		fl4.flowi4_flags |= FLOWI_FLAG_PRECOW_METRICS;
+		flow_flags |= FLOWI_FLAG_PRECOW_METRICS;
 	if (can_sleep)
-		fl4.flowi4_flags |= FLOWI_FLAG_CAN_SLEEP;
+		flow_flags |= FLOWI_FLAG_CAN_SLEEP;
+
+	flowi4_init_output(&fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
+			   protocol, flow_flags, dst, src, dport, sport);
 
 	if (!dst || !src) {
 		rt = __ip_route_output_key(net, &fl4);
@@ -267,20 +258,17 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 					       __be16 dport, struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi4 fl4 = {
-			.flowi4_oif = rt->rt_oif,
-			.flowi4_mark = rt->rt_mark,
-			.daddr = rt->rt_dst,
-			.saddr = rt->rt_src,
-			.flowi4_tos = rt->rt_tos,
-			.flowi4_proto = protocol,
-			.fl4_sport = sport,
-			.fl4_dport = dport
-		};
+		struct flowi4 fl4;
+		__u8 flow_flags;
+
+		flow_flags = 0;
 		if (inet_sk(sk)->transparent)
-			fl4.flowi4_flags |= FLOWI_FLAG_ANYSRC;
+			flow_flags |= FLOWI_FLAG_ANYSRC;
 		if (protocol == IPPROTO_TCP)
-			fl4.flowi4_flags |= FLOWI_FLAG_PRECOW_METRICS;
+			flow_flags |= FLOWI_FLAG_PRECOW_METRICS;
+		flowi4_init_output(&fl4, rt->rt_oif, rt->rt_mark, rt->rt_tos,
+				   RT_SCOPE_UNIVERSE, protocol, flow_flags,
+				   rt->rt_dst, rt->rt_src, dport, sport);
 		ip_rt_put(rt);
 		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
 		return ip_route_output_flow(sock_net(sk), &fl4, sk);
-- 
1.7.4.2

