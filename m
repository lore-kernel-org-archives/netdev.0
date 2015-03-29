From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/4] xfrm: simplify xfrm_address_t use
Date: Sun, 29 Mar 2015 16:59:24 +0200
Message-ID: <e70181767cd48da03733b6817466085c4629ff9a.1427639592.git.jbenc@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:39724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720AbbC2PAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 11:00:23 -0400
In-Reply-To: <cover.1427639592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In many places, the a6 field is typecasted to struct in6_addr. As the
fields are in union anyway, just add in6_addr type to the union and
get rid of the typecasting.

Modifying the uapi header is okay, the union has still the same size.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/xfrm.h         | 6 +++---
 include/uapi/linux/xfrm.h  | 2 ++
 net/ipv6/xfrm6_mode_beet.c | 4 ++--
 net/ipv6/xfrm6_policy.c    | 4 +---
 net/key/af_key.c           | 2 +-
 net/xfrm/xfrm_state.c      | 8 ++++----
 6 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d0ac7d7be8a7..461f83539493 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1025,7 +1025,7 @@ xfrm_addr_any(const xfrm_address_t *addr, unsigned short family)
 	case AF_INET:
 		return addr->a4 == 0;
 	case AF_INET6:
-		return ipv6_addr_any((struct in6_addr *)&addr->a6);
+		return ipv6_addr_any(&addr->in6);
 	}
 	return 0;
 }
@@ -1238,8 +1238,8 @@ void xfrm_flowi_addr_get(const struct flowi *fl,
 		memcpy(&daddr->a4, &fl->u.ip4.daddr, sizeof(daddr->a4));
 		break;
 	case AF_INET6:
-		*(struct in6_addr *)saddr->a6 = fl->u.ip6.saddr;
-		*(struct in6_addr *)daddr->a6 = fl->u.ip6.daddr;
+		saddr->in6 = fl->u.ip6.saddr;
+		daddr->in6 = fl->u.ip6.daddr;
 		break;
 	}
 }
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 02d5125a5ee8..2cd9e608d0d1 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_XFRM_H
 #define _LINUX_XFRM_H
 
+#include <linux/in6.h>
 #include <linux/types.h>
 
 /* All of the structures in this file may not change size as they are
@@ -13,6 +14,7 @@
 typedef union {
 	__be32		a4;
 	__be32		a6[4];
+	struct in6_addr	in6;
 } xfrm_address_t;
 
 /* Ident of a specific xfrm_state. It is used on input to lookup
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 9949a356d62c..1e205c3253ac 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -95,8 +95,8 @@ static int xfrm6_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	ip6h = ipv6_hdr(skb);
 	ip6h->payload_len = htons(skb->len - size);
-	ip6h->daddr = *(struct in6_addr *)&x->sel.daddr.a6;
-	ip6h->saddr = *(struct in6_addr *)&x->sel.saddr.a6;
+	ip6h->daddr = x->sel.daddr.in6;
+	ip6h->saddr = x->sel.saddr.in6;
 	err = 0;
 out:
 	return err;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 11dbcc1790d2..f35ca3522c62 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -61,9 +61,7 @@ static int xfrm6_get_saddr(struct net *net,
 		return -EHOSTUNREACH;
 
 	dev = ip6_dst_idev(dst)->dev;
-	ipv6_dev_get_saddr(dev_net(dev), dev,
-			   (struct in6_addr *)&daddr->a6, 0,
-			   (struct in6_addr *)&saddr->a6);
+	ipv6_dev_get_saddr(dev_net(dev), dev, &daddr->in6, 0, &saddr->in6);
 	dst_release(dst);
 	return 0;
 }
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9255fd9d94bc..f0d52d721b3a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -709,7 +709,7 @@ static unsigned int pfkey_sockaddr_fill(const xfrm_address_t *xaddr, __be16 port
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = port;
 		sin6->sin6_flowinfo = 0;
-		sin6->sin6_addr = *(struct in6_addr *)xaddr->a6;
+		sin6->sin6_addr = xaddr->in6;
 		sin6->sin6_scope_id = 0;
 		return 128;
 	    }
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index de971b6d38c5..f5e39e35d73a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1043,12 +1043,12 @@ static struct xfrm_state *__find_acq_core(struct net *net,
 			break;
 
 		case AF_INET6:
-			*(struct in6_addr *)x->sel.daddr.a6 = *(struct in6_addr *)daddr;
-			*(struct in6_addr *)x->sel.saddr.a6 = *(struct in6_addr *)saddr;
+			x->sel.daddr.in6 = daddr->in6;
+			x->sel.saddr.in6 = saddr->in6;
 			x->sel.prefixlen_d = 128;
 			x->sel.prefixlen_s = 128;
-			*(struct in6_addr *)x->props.saddr.a6 = *(struct in6_addr *)saddr;
-			*(struct in6_addr *)x->id.daddr.a6 = *(struct in6_addr *)daddr;
+			x->props.saddr.in6 = saddr->in6;
+			x->id.daddr.in6 = daddr->in6;
 			break;
 		}
 
-- 
1.8.3.1
