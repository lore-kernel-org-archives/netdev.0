From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 01/13] xfrm: input: constify xfrm_input_afinfo
Date: Thu, 16 Feb 2017 13:18:35 +0100
Message-ID: <1487247527-17925-2-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49294 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754521AbdBPMS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:57 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Nothing writes to these structures (the module owner was not used).

While at it, size xfrm_input_afinfo[] by the highest existing xfrm family
(INET6), not AF_MAX.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h        |  5 ++---
 net/ipv4/xfrm4_protocol.c |  3 +--
 net/ipv6/xfrm6_protocol.c |  3 +--
 net/xfrm/xfrm_input.c     | 31 +++++++++++--------------------
 4 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d9a81dc..da0e4dd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -349,13 +349,12 @@ struct xfrm_state_afinfo {
 
 struct xfrm_input_afinfo {
 	unsigned int		family;
-	struct module		*owner;
 	int			(*callback)(struct sk_buff *skb, u8 protocol,
 					    int err);
 };
 
-int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo);
-int xfrm_input_unregister_afinfo(struct xfrm_input_afinfo *afinfo);
+int xfrm_input_register_afinfo(const struct xfrm_input_afinfo *afinfo);
+int xfrm_input_unregister_afinfo(const struct xfrm_input_afinfo *afinfo);
 
 void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index dccefa9..8dd0e6a 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -188,9 +188,8 @@ static void xfrm4_ipcomp_err(struct sk_buff *skb, u32 info)
 	.netns_ok	=	1,
 };
 
-static struct xfrm_input_afinfo xfrm4_input_afinfo = {
+static const struct xfrm_input_afinfo xfrm4_input_afinfo = {
 	.family		=	AF_INET,
-	.owner		=	THIS_MODULE,
 	.callback	=	xfrm4_rcv_cb,
 };
 
diff --git a/net/ipv6/xfrm6_protocol.c b/net/ipv6/xfrm6_protocol.c
index 54d13f8..b2dc8ce 100644
--- a/net/ipv6/xfrm6_protocol.c
+++ b/net/ipv6/xfrm6_protocol.c
@@ -162,9 +162,8 @@ static void xfrm6_ipcomp_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
-static struct xfrm_input_afinfo xfrm6_input_afinfo = {
+static const struct xfrm_input_afinfo xfrm6_input_afinfo = {
 	.family		=	AF_INET6,
-	.owner		=	THIS_MODULE,
 	.callback	=	xfrm6_rcv_cb,
 };
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 3213fe8..8722294 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -19,19 +19,18 @@
 static struct kmem_cache *secpath_cachep __read_mostly;
 
 static DEFINE_SPINLOCK(xfrm_input_afinfo_lock);
-static struct xfrm_input_afinfo __rcu *xfrm_input_afinfo[NPROTO];
+static struct xfrm_input_afinfo const __rcu *xfrm_input_afinfo[AF_INET6 + 1];
 
 static struct gro_cells gro_cells;
 static struct net_device xfrm_napi_dev;
 
-int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo)
+int xfrm_input_register_afinfo(const struct xfrm_input_afinfo *afinfo)
 {
 	int err = 0;
 
-	if (unlikely(afinfo == NULL))
-		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+	if (WARN_ON(afinfo->family >= ARRAY_SIZE(xfrm_input_afinfo)))
 		return -EAFNOSUPPORT;
+
 	spin_lock_bh(&xfrm_input_afinfo_lock);
 	if (unlikely(xfrm_input_afinfo[afinfo->family] != NULL))
 		err = -EEXIST;
@@ -42,14 +41,10 @@ int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_input_register_afinfo);
 
-int xfrm_input_unregister_afinfo(struct xfrm_input_afinfo *afinfo)
+int xfrm_input_unregister_afinfo(const struct xfrm_input_afinfo *afinfo)
 {
 	int err = 0;
 
-	if (unlikely(afinfo == NULL))
-		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
-		return -EAFNOSUPPORT;
 	spin_lock_bh(&xfrm_input_afinfo_lock);
 	if (likely(xfrm_input_afinfo[afinfo->family] != NULL)) {
 		if (unlikely(xfrm_input_afinfo[afinfo->family] != afinfo))
@@ -63,12 +58,13 @@ int xfrm_input_unregister_afinfo(struct xfrm_input_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_input_unregister_afinfo);
 
-static struct xfrm_input_afinfo *xfrm_input_get_afinfo(unsigned int family)
+static const struct xfrm_input_afinfo *xfrm_input_get_afinfo(unsigned int family)
 {
-	struct xfrm_input_afinfo *afinfo;
+	const struct xfrm_input_afinfo *afinfo;
 
-	if (unlikely(family >= NPROTO))
+	if (WARN_ON_ONCE(family >= ARRAY_SIZE(xfrm_input_afinfo)))
 		return NULL;
+
 	rcu_read_lock();
 	afinfo = rcu_dereference(xfrm_input_afinfo[family]);
 	if (unlikely(!afinfo))
@@ -76,22 +72,17 @@ static struct xfrm_input_afinfo *xfrm_input_get_afinfo(unsigned int family)
 	return afinfo;
 }
 
-static void xfrm_input_put_afinfo(struct xfrm_input_afinfo *afinfo)
-{
-	rcu_read_unlock();
-}
-
 static int xfrm_rcv_cb(struct sk_buff *skb, unsigned int family, u8 protocol,
 		       int err)
 {
 	int ret;
-	struct xfrm_input_afinfo *afinfo = xfrm_input_get_afinfo(family);
+	const struct xfrm_input_afinfo *afinfo = xfrm_input_get_afinfo(family);
 
 	if (!afinfo)
 		return -EAFNOSUPPORT;
 
 	ret = afinfo->callback(skb, protocol, err);
-	xfrm_input_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	return ret;
 }
-- 
1.9.1
