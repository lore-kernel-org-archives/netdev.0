From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 05/13] xfrm: policy: remove family field
Date: Thu, 16 Feb 2017 13:18:39 +0100
Message-ID: <1487247527-17925-6-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49312 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754634AbdBPMS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:58 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Only needed it to register the policy backend at init time.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |  5 ++---
 net/ipv4/xfrm4_policy.c |  5 +----
 net/ipv6/xfrm6_policy.c |  5 +----
 net/xfrm/xfrm_policy.c  | 34 +++++++++++++++++-----------------
 4 files changed, 21 insertions(+), 28 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index a22368e..6e06130 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -280,7 +280,6 @@ struct xfrm_replay {
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
-	unsigned short		family;
 	struct dst_ops		*dst_ops;
 	struct dst_entry	*(*dst_lookup)(struct net *net,
 					       int tos, int oif,
@@ -302,8 +301,8 @@ struct xfrm_policy_afinfo {
 	struct dst_entry	*(*blackhole_route)(struct net *net, struct dst_entry *orig);
 };
 
-int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
-void xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
+int xfrm_policy_register_afinfo(const struct xfrm_policy_afinfo *afinfo, int family);
+void xfrm_policy_unregister_afinfo(const struct xfrm_policy_afinfo *afinfo);
 void km_policy_notify(struct xfrm_policy *xp, int dir,
 		      const struct km_event *c);
 void km_state_notify(struct xfrm_state *x, const struct km_event *c);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 77ca91d..2561353 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -17,8 +17,6 @@
 #include <net/ip.h>
 #include <net/l3mdev.h>
 
-static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
-
 static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 					    int tos, int oif,
 					    const xfrm_address_t *saddr,
@@ -272,7 +270,6 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 };
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
-	.family = 		AF_INET,
 	.dst_ops =		&xfrm4_dst_ops_template,
 	.dst_lookup =		xfrm4_dst_lookup,
 	.get_saddr =		xfrm4_get_saddr,
@@ -376,7 +373,7 @@ static void __net_exit xfrm4_net_exit(struct net *net)
 
 static void __init xfrm4_policy_init(void)
 {
-	xfrm_policy_register_afinfo(&xfrm4_policy_afinfo);
+	xfrm_policy_register_afinfo(&xfrm4_policy_afinfo, AF_INET);
 }
 
 void __init xfrm4_init(void)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c273f22..3217e85 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -25,8 +25,6 @@
 #include <net/mip6.h>
 #endif
 
-static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
-
 static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 					  const xfrm_address_t *saddr,
 					  const xfrm_address_t *daddr)
@@ -292,7 +290,6 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 };
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
-	.family =		AF_INET6,
 	.dst_ops =		&xfrm6_dst_ops_template,
 	.dst_lookup =		xfrm6_dst_lookup,
 	.get_saddr =		xfrm6_get_saddr,
@@ -305,7 +302,7 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static int __init xfrm6_policy_init(void)
 {
-	return xfrm_policy_register_afinfo(&xfrm6_policy_afinfo);
+	return xfrm_policy_register_afinfo(&xfrm6_policy_afinfo, AF_INET6);
 }
 
 static void xfrm6_policy_fini(void)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 80695a1..7698785 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -45,7 +45,7 @@ struct xfrm_flo {
 };
 
 static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
-static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
+static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[AF_INET6 + 1]
 						__read_mostly;
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
@@ -103,11 +103,11 @@ bool xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl
 	return false;
 }
 
-static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
+static const struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
 {
-	struct xfrm_policy_afinfo *afinfo;
+	const struct xfrm_policy_afinfo *afinfo;
 
-	if (unlikely(family >= NPROTO))
+	if (unlikely(family >= ARRAY_SIZE(xfrm_policy_afinfo)))
 		return NULL;
 	rcu_read_lock();
 	afinfo = rcu_dereference(xfrm_policy_afinfo[family]);
@@ -2848,15 +2848,15 @@ static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
 	return dst->path->ops->neigh_lookup(dst, skb, daddr);
 }
 
-int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
+int xfrm_policy_register_afinfo(const struct xfrm_policy_afinfo *afinfo, int family)
 {
 	int err = 0;
-	if (unlikely(afinfo == NULL))
-		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+
+	if (WARN_ON(family >= ARRAY_SIZE(xfrm_policy_afinfo)))
 		return -EAFNOSUPPORT;
+
 	spin_lock(&xfrm_policy_afinfo_lock);
-	if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
+	if (unlikely(xfrm_policy_afinfo[family] != NULL))
 		err = -EEXIST;
 	else {
 		struct dst_ops *dst_ops = afinfo->dst_ops;
@@ -2874,7 +2874,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->link_failure = xfrm_link_failure;
 		if (likely(dst_ops->neigh_lookup == NULL))
 			dst_ops->neigh_lookup = xfrm_neigh_lookup;
-		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
+		rcu_assign_pointer(xfrm_policy_afinfo[family], afinfo);
 	}
 	spin_unlock(&xfrm_policy_afinfo_lock);
 
@@ -2882,16 +2882,16 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_policy_register_afinfo);
 
-void xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
+void xfrm_policy_unregister_afinfo(const struct xfrm_policy_afinfo *afinfo)
 {
 	struct dst_ops *dst_ops = afinfo->dst_ops;
+	int i;
 
-	if (unlikely(afinfo->family >= NPROTO))
-		return;
-
-	if (likely(xfrm_policy_afinfo[afinfo->family] != afinfo)) {
-		RCU_INIT_POINTER(xfrm_policy_afinfo[afinfo->family],
-					 NULL);
+	for (i = 0; i < ARRAY_SIZE(xfrm_policy_afinfo); i++) {
+		if (xfrm_policy_afinfo[i] != afinfo)
+			continue;
+		RCU_INIT_POINTER(xfrm_policy_afinfo[i], NULL);
+		break;
 	}
 
 	synchronize_rcu();
-- 
1.9.1
