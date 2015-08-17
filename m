From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: Add oif to dst lookups
Date: Mon, 17 Aug 2015 21:58:20 +0200
Message-ID: <1439841501-20990-4-git-send-email-steffen.klassert@secunet.com>
References: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55648 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbbHQT6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 15:58:33 -0400
In-Reply-To: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>

Rules can be installed that direct route lookups to specific tables based
on oif. Plumb the oif through the xfrm lookups so it gets set in the flow
struct and passed to the resolver routines.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |  7 +++++--
 net/ipv4/xfrm4_policy.c | 11 ++++++-----
 net/ipv6/xfrm6_policy.c |  7 ++++---
 net/xfrm/xfrm_policy.c  | 24 ++++++++++++++----------
 4 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f0ee97e..312e3fe 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -285,10 +285,13 @@ struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(struct net *net);
-	struct dst_entry	*(*dst_lookup)(struct net *net, int tos,
+	struct dst_entry	*(*dst_lookup)(struct net *net,
+					       int tos, int oif,
 					       const xfrm_address_t *saddr,
 					       const xfrm_address_t *daddr);
-	int			(*get_saddr)(struct net *net, xfrm_address_t *saddr, xfrm_address_t *daddr);
+	int			(*get_saddr)(struct net *net, int oif,
+					     xfrm_address_t *saddr,
+					     xfrm_address_t *daddr);
 	void			(*decode_session)(struct sk_buff *skb,
 						  struct flowi *fl,
 						  int reverse);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index bff6974..55b3c0f 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -19,7 +19,7 @@
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
 static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
-					    int tos,
+					    int tos, int oif,
 					    const xfrm_address_t *saddr,
 					    const xfrm_address_t *daddr)
 {
@@ -28,6 +28,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->daddr = daddr->a4;
 	fl4->flowi4_tos = tos;
+	fl4->flowi4_oif = oif;
 	if (saddr)
 		fl4->saddr = saddr->a4;
 
@@ -38,22 +39,22 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 	return ERR_CAST(rt);
 }
 
-static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
+static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos, int oif,
 					  const xfrm_address_t *saddr,
 					  const xfrm_address_t *daddr)
 {
 	struct flowi4 fl4;
 
-	return __xfrm4_dst_lookup(net, &fl4, tos, saddr, daddr);
+	return __xfrm4_dst_lookup(net, &fl4, tos, oif, saddr, daddr);
 }
 
-static int xfrm4_get_saddr(struct net *net,
+static int xfrm4_get_saddr(struct net *net, int oif,
 			   xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
 	struct dst_entry *dst;
 	struct flowi4 fl4;
 
-	dst = __xfrm4_dst_lookup(net, &fl4, 0, NULL, daddr);
+	dst = __xfrm4_dst_lookup(net, &fl4, 0, oif, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ed0583c..a74013d 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -26,7 +26,7 @@
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
 
-static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
+static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 					  const xfrm_address_t *saddr,
 					  const xfrm_address_t *daddr)
 {
@@ -35,6 +35,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
 	int err;
 
 	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_oif = oif;
 	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
 	if (saddr)
 		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
@@ -50,13 +51,13 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
 	return dst;
 }
 
-static int xfrm6_get_saddr(struct net *net,
+static int xfrm6_get_saddr(struct net *net, int oif,
 			   xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
 	struct dst_entry *dst;
 	struct net_device *dev;
 
-	dst = xfrm6_dst_lookup(net, 0, NULL, daddr);
+	dst = xfrm6_dst_lookup(net, 0, oif, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 18cead7..94af3d0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -115,7 +115,8 @@ static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
 	rcu_read_unlock();
 }
 
-static inline struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos,
+static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
+						  int tos, int oif,
 						  const xfrm_address_t *saddr,
 						  const xfrm_address_t *daddr,
 						  int family)
@@ -127,14 +128,15 @@ static inline struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos,
 	if (unlikely(afinfo == NULL))
 		return ERR_PTR(-EAFNOSUPPORT);
 
-	dst = afinfo->dst_lookup(net, tos, saddr, daddr);
+	dst = afinfo->dst_lookup(net, tos, oif, saddr, daddr);
 
 	xfrm_policy_put_afinfo(afinfo);
 
 	return dst;
 }
 
-static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos,
+static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x,
+						int tos, int oif,
 						xfrm_address_t *prev_saddr,
 						xfrm_address_t *prev_daddr,
 						int family)
@@ -153,7 +155,7 @@ static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos,
 		daddr = x->coaddr;
 	}
 
-	dst = __xfrm_dst_lookup(net, tos, saddr, daddr, family);
+	dst = __xfrm_dst_lookup(net, tos, oif, saddr, daddr, family);
 
 	if (!IS_ERR(dst)) {
 		if (prev_saddr != saddr)
@@ -1373,15 +1375,15 @@ int __xfrm_sk_clone_policy(struct sock *sk)
 }
 
 static int
-xfrm_get_saddr(struct net *net, xfrm_address_t *local, xfrm_address_t *remote,
-	       unsigned short family)
+xfrm_get_saddr(struct net *net, int oif, xfrm_address_t *local,
+	       xfrm_address_t *remote, unsigned short family)
 {
 	int err;
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
-	err = afinfo->get_saddr(net, local, remote);
+	err = afinfo->get_saddr(net, oif, local, remote);
 	xfrm_policy_put_afinfo(afinfo);
 	return err;
 }
@@ -1410,7 +1412,9 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
 			if (xfrm_addr_any(local, tmpl->encap_family)) {
-				error = xfrm_get_saddr(net, &tmp, remote, tmpl->encap_family);
+				error = xfrm_get_saddr(net, fl->flowi_oif,
+						       &tmp, remote,
+						       tmpl->encap_family);
 				if (error)
 					goto fail;
 				local = &tmp;
@@ -1690,8 +1694,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			family = xfrm[i]->props.family;
-			dst = xfrm_dst_lookup(xfrm[i], tos, &saddr, &daddr,
-					      family);
+			dst = xfrm_dst_lookup(xfrm[i], tos, fl->flowi_oif,
+					      &saddr, &daddr, family);
 			err = PTR_ERR(dst);
 			if (IS_ERR(dst))
 				goto put_states;
-- 
1.9.1
