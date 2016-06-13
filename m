From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 2/3] ipv4: make flow functions more grepable by removing flowi4_update_output
Date: Mon, 13 Jun 2016 22:47:37 +0200
Message-ID: <1465850858-8559-3-git-send-email-hannes@stressinduktion.org>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
Cc: ja@ssi.bg, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33552 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423033AbcFMUrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:47:51 -0400
In-Reply-To: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/flow.h              | 11 -----------
 include/net/route.h             |  8 ++++----
 net/netfilter/ipvs/ip_vs_xmit.c |  9 +++++++--
 net/sctp/protocol.c             | 10 ++++------
 4 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 2c8e95b987c98c..6276a81f7b3d13 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -90,17 +90,6 @@ struct flowi4 {
 #define fl4_gre_key		uli.gre_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
-/* Reset some input parameters after previous lookup */
-static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
-					__be32 daddr, __be32 saddr)
-{
-	fl4->flowi4_oif = oif;
-	fl4->flowi4_tos = tos;
-	fl4->daddr = daddr;
-	fl4->saddr = saddr;
-}
-				      
-
 struct flowi6 {
 	struct flowi_common	__fl_common;
 #define flowi6_oif		__fl_common.flowic_oif
diff --git a/include/net/route.h b/include/net/route.h
index 61164593d41ecf..8937e36fc9fd11 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -320,7 +320,8 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 		if (IS_ERR(rt))
 			return rt;
 		ip_rt_put(rt);
-		flowi4_update_output(fl4, oif, tos, fl4->daddr, fl4->saddr);
+		fl4->flowi4_oif = oif;
+		fl4->flowi4_tos = tos;
 	}
 	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 	return ip_route_output_flow(net, fl4, sk);
@@ -335,9 +336,8 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 		fl4->fl4_dport = dport;
 		fl4->fl4_sport = sport;
 		ip_rt_put(rt);
-		flowi4_update_output(fl4, sk->sk_bound_dev_if,
-				     RT_CONN_FLAGS(sk), fl4->daddr,
-				     fl4->saddr);
+		fl4->flowi4_oif = sk->sk_bound_dev_if;
+		fl4->flowi4_tos = RT_CONN_FLAGS(sk);
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		return ip_route_output_flow(sock_net(sk), fl4, sk);
 	}
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 01d3d894de4630..89444ee244c930 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -140,7 +140,10 @@ retry:
 		if (PTR_ERR(rt) == -EINVAL && *saddr &&
 		    rt_mode & IP_VS_RT_MODE_CONNECT && !loop) {
 			*saddr = 0;
-			flowi4_update_output(&fl4, 0, 0, daddr, 0);
+			fl4.flowi4_oif = 0;
+			fl4.flowi4_tos = 0;
+			fl4.daddr = daddr;
+			fl4.saddr = 0;
 			goto retry;
 		}
 		IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n", &daddr);
@@ -148,7 +151,9 @@ retry:
 	} else if (!*saddr && rt_mode & IP_VS_RT_MODE_CONNECT && fl4.saddr) {
 		ip_rt_put(rt);
 		*saddr = fl4.saddr;
-		flowi4_update_output(&fl4, 0, 0, daddr, fl4.saddr);
+		fl4.flowi4_oif = 0;
+		fl4.flowi4_tos = 0;
+		fl4.daddr = daddr;
 		loop++;
 		goto retry;
 	}
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 40022ee885d7e8..f85b37a73ee633 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -499,12 +499,10 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 			continue;
 
 		fl4->fl4_sport = laddr->a.v4.sin_port;
-		flowi4_update_output(fl4,
-				     asoc->base.sk->sk_bound_dev_if,
-				     RT_CONN_FLAGS(asoc->base.sk),
-				     daddr->v4.sin_addr.s_addr,
-				     laddr->a.v4.sin_addr.s_addr);
-
+		fl4->flowi4_oif = asoc->base.sk->sk_bound_dev_if;
+		fl4->flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
+		fl4->daddr = daddr->v4.sin_addr.s_addr;
+		fl4->saddr = laddr->a.v4.sin_addr.s_addr;
 		rt = ip_route_output_key(sock_net(sk), fl4);
 		if (IS_ERR(rt))
 			continue;
-- 
2.5.5
