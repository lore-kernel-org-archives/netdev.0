From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/4] tcp: simplify inetpeer_addr_base use
Date: Sun, 29 Mar 2015 16:59:23 +0200
Message-ID: <8abc3216b42b7a0c47f87fc76eb96c005ad22f71.1427639592.git.jbenc@redhat.com>
References: <cover.1427639592.git.jbenc@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Chapman <jchapman@katalix.com>,
	Paul Moore <paul@paul-moore.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbbC2PAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 11:00:03 -0400
In-Reply-To: <cover.1427639592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In many places, the a6 field is typecasted to struct in6_addr. As the
fields are in union anyway, just add in6_addr type to the union and get rid
of the typecasting.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/inetpeer.h |  3 ++-
 net/ipv4/tcp_metrics.c | 22 ++++++++--------------
 2 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 80479abddf73..d5332ddcea3f 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -19,6 +19,7 @@ struct inetpeer_addr_base {
 	union {
 		__be32			a4;
 		__be32			a6[4];
+		struct in6_addr		in6;
 	};
 };
 
@@ -151,7 +152,7 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
 {
 	struct inetpeer_addr daddr;
 
-	*(struct in6_addr *)daddr.addr.a6 = *v6daddr;
+	daddr.addr.in6 = *v6daddr;
 	daddr.family = AF_INET6;
 	return inet_getpeer(base, &daddr, create);
 }
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 5bef3513af77..f62c2c68ced0 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -80,17 +80,11 @@ static void tcp_metric_set(struct tcp_metrics_block *tm,
 static bool addr_same(const struct inetpeer_addr *a,
 		      const struct inetpeer_addr *b)
 {
-	const struct in6_addr *a6, *b6;
-
 	if (a->family != b->family)
 		return false;
 	if (a->family == AF_INET)
 		return a->addr.a4 == b->addr.a4;
-
-	a6 = (const struct in6_addr *) &a->addr.a6[0];
-	b6 = (const struct in6_addr *) &b->addr.a6[0];
-
-	return ipv6_addr_equal(a6, b6);
+	return ipv6_addr_equal(&a->addr.in6, &b->addr.in6);
 }
 
 struct tcpm_hash_bucket {
@@ -256,8 +250,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		*(struct in6_addr *)saddr.addr.a6 = inet_rsk(req)->ir_v6_loc_addr;
-		*(struct in6_addr *)daddr.addr.a6 = inet_rsk(req)->ir_v6_rmt_addr;
+		saddr.addr.in6 = inet_rsk(req)->ir_v6_loc_addr;
+		daddr.addr.in6 = inet_rsk(req)->ir_v6_rmt_addr;
 		hash = ipv6_addr_hash(&inet_rsk(req)->ir_v6_rmt_addr);
 		break;
 #endif
@@ -304,9 +298,9 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 			hash = (__force unsigned int) daddr.addr.a4;
 		} else {
 			saddr.family = AF_INET6;
-			*(struct in6_addr *)saddr.addr.a6 = tw->tw_v6_rcv_saddr;
+			saddr.addr.in6 = tw->tw_v6_rcv_saddr;
 			daddr.family = AF_INET6;
-			*(struct in6_addr *)daddr.addr.a6 = tw->tw_v6_daddr;
+			daddr.addr.in6 = tw->tw_v6_daddr;
 			hash = ipv6_addr_hash(&tw->tw_v6_daddr);
 		}
 	}
@@ -354,9 +348,9 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 			hash = (__force unsigned int) daddr.addr.a4;
 		} else {
 			saddr.family = AF_INET6;
-			*(struct in6_addr *)saddr.addr.a6 = sk->sk_v6_rcv_saddr;
+			saddr.addr.in6 = sk->sk_v6_rcv_saddr;
 			daddr.family = AF_INET6;
-			*(struct in6_addr *)daddr.addr.a6 = sk->sk_v6_daddr;
+			daddr.addr.in6 = sk->sk_v6_daddr;
 			hash = ipv6_addr_hash(&sk->sk_v6_daddr);
 		}
 	}
@@ -966,7 +960,7 @@ static int __parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 		addr->family = AF_INET6;
 		memcpy(addr->addr.a6, nla_data(a), sizeof(addr->addr.a6));
 		if (hash)
-			*hash = ipv6_addr_hash((struct in6_addr *) addr->addr.a6);
+			*hash = ipv6_addr_hash(&addr->addr.in6);
 		return 0;
 	}
 	return optional ? 1 : -EAFNOSUPPORT;
-- 
1.8.3.1
