From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] [XFRM] IPv6: Fix dst/routing check at transformation.
Date: Fri, 21 Dec 2007 12:40:39 +0900
Message-ID: <11982084391595-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:58062 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755043AbXLUEJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:09:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 specific thing is wrongly removed from transformation at net-2.6.25.
This patch recovers it with current design.

o Update "path" of xfrm_dst since IPv6 transformation should
  care about routing changes. It is required by MIPv6 and
  off-link destined IPsec.
o Rename nfheader_len which is for non-fragment transformation used by
  MIPv6 to rt6i_nfheader_len as IPv6 name space.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/net/ip6_fib.h   |    2 +-
 include/net/xfrm.h      |    3 +++
 net/ipv4/xfrm4_policy.c |    7 +++++++
 net/ipv6/ip6_output.c   |    4 ++--
 net/ipv6/xfrm6_policy.c |   17 +++++++++++++++++
 net/xfrm/xfrm_policy.c  |   21 +++++++++++++++++++++
 6 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 14830ed..d8d85b1 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -101,7 +101,7 @@ struct rt6_info
 	atomic_t			rt6i_ref;
 
 	/* more non-fragment space at head required */
-	unsigned short			nfheader_len;
+	unsigned short			rt6i_nfheader_len;
 
 	u8				rt6i_protocol;
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 32b99e2..6df8253 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -242,6 +242,9 @@ struct xfrm_policy_afinfo {
 						  struct flowi *fl,
 						  int reverse);
 	int			(*get_tos)(struct flowi *fl);
+	int			(*init_path)(struct xfrm_dst *path,
+					     struct dst_entry *dst,
+					     int nfheader_len);
 	int			(*fill_dst)(struct xfrm_dst *xdst,
 					    struct net_device *dev);
 };
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 5ccae3a..656345f 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -84,6 +84,12 @@ static int xfrm4_get_tos(struct flowi *fl)
 	return fl->fl4_tos;
 }
 
+static int xfrm4_init_path(struct xfrm_dst *path, struct dst_entry *dst,
+			   int nfheader_len)
+{
+	return 0;
+}
+
 static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 {
 	struct rtable *rt = (struct rtable *)xdst->route;
@@ -251,6 +257,7 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.find_bundle = 		__xfrm4_find_bundle,
 	.decode_session =	_decode_session4,
 	.get_tos =		xfrm4_get_tos,
+	.init_path =		xfrm4_init_path,
 	.fill_dst =		xfrm4_fill_dst,
 };
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 388a098..cb6bb89 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1126,7 +1126,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
 		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0) -
-			    rt->nfheader_len;
+			    rt->rt6i_nfheader_len;
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
 	} else {
@@ -1141,7 +1141,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
-	fragheaderlen = sizeof(struct ipv6hdr) + rt->nfheader_len +
+	fragheaderlen = sizeof(struct ipv6hdr) + rt->rt6i_nfheader_len +
 			(opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d26b7dc..cf373b4 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -98,6 +98,20 @@ static int xfrm6_get_tos(struct flowi *fl)
 	return 0;
 }
 
+static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
+			   int nfheader_len)
+{
+	if (dst->ops->family == AF_INET6) {
+		struct rt6_info *rt = (struct rt6_info*)dst;
+		if (rt->rt6i_node)
+			path->path_cookie = rt->rt6i_node->fn_sernum;
+	}
+
+	path->u.rt6.rt6i_nfheader_len = nfheader_len;
+
+	return 0;
+}
+
 static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 {
 	struct rt6_info *rt = (struct rt6_info*)xdst->route;
@@ -115,6 +129,8 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 						   RTF_LOCAL);
 	xdst->u.rt6.rt6i_metric = rt->rt6i_metric;
 	xdst->u.rt6.rt6i_node = rt->rt6i_node;
+	if (rt->rt6i_node)
+		xdst->route_cookie = rt->rt6i_node->fn_sernum;
 	xdst->u.rt6.rt6i_gateway = rt->rt6i_gateway;
 	xdst->u.rt6.rt6i_dst = rt->rt6i_dst;
 	xdst->u.rt6.rt6i_src = rt->rt6i_src;
@@ -266,6 +282,7 @@ static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.find_bundle =		__xfrm6_find_bundle,
 	.decode_session =	_decode_session6,
 	.get_tos =		xfrm6_get_tos,
+	.init_path =		xfrm6_init_path,
 	.fill_dst =		xfrm6_fill_dst,
 };
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d2084b1..4f823f4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1266,6 +1266,23 @@ static inline struct xfrm_dst *xfrm_alloc_dst(int family)
 	return xdst;
 }
 
+static inline int xfrm_init_path(struct xfrm_dst *path, struct dst_entry *dst,
+				 int nfheader_len)
+{
+	struct xfrm_policy_afinfo *afinfo =
+		xfrm_policy_get_afinfo(dst->ops->family);
+	int err;
+
+	if (!afinfo)
+		return -EINVAL;
+
+	err = afinfo->init_path(path, dst, nfheader_len);
+
+	xfrm_policy_put_afinfo(afinfo);
+
+	return err;
+}
+
 static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 {
 	struct xfrm_policy_afinfo *afinfo =
@@ -1298,6 +1315,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	int i = 0;
 	int err;
 	int header_len = 0;
+	int nfheader_len = 0;
 	int trailer_len = 0;
 	int tos;
 	int family = policy->selector.family;
@@ -1352,6 +1370,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		dst_prev = dst1;
 
 		header_len += xfrm[i]->props.header_len;
+		if (xfrm[i]->type->flags & XFRM_TYPE_NON_FRAGMENT)
+			nfheader_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 	}
 
@@ -1366,6 +1386,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	/* Copy neighbout for reachability confirmation */
 	dst0->neighbour = neigh_clone(dst->neighbour);
 
+	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);
 	xfrm_init_pmtu(dst_prev);
 
 	for (dst_prev = dst0; dst_prev != dst; dst_prev = dst_prev->child) {
-- 
1.4.4.2

