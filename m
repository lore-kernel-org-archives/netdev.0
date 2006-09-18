From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix wildcard as tunnel source
Date: Mon, 18 Sep 2006 11:43:49 +0200
Message-ID: <450E6A55.50307@trash.net>
References: <44F99954.1040606@trash.net> <20060918.001904.105429466.davem@davemloft.net> <450E4FF9.9030406@trash.net> <450E6953.2020008@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060507050604040609080208"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:8592 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965613AbWIRJq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 05:46:59 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <450E6953.2020008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060507050604040609080208
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> [XFRM]: Fix wildcard as tunnel source
> 
> Hashing SAs by source address breaks templates with wildcards as tunnel
> source since the source address used for hashing/lookup is still 0/0.
> Move source address lookup to xfrm_tmpl_resolve_one() so we can use the
> real address in the lookup.
> 
>  
>  static inline int
> +xfrm_addr_any(xfrm_address_t *addr, unsigned short family)
> +{
> +	switch (family) {
> +	case AF_INET:
> +		return addr->a4 == 0;
> +	case AF_INET6:
> +		return ipv6_addr_any((struct in6_addr*)addr->a6);

D'oh. Fixed patch attached.


--------------060507050604040609080208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix wildcard as tunnel source

Hashing SAs by source address breaks templates with wildcards as tunnel
source since the source address used for hashing/lookup is still 0/0.
Move source address lookup to xfrm_tmpl_resolve_one() so we can use the
real address in the lookup.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f3307c3183e50959247f28c773590b5d7902097f
tree 78ddff768dc25145110767f182408ed6993828c5
parent c2cb1937e1054380c49699188810b9c6e04c8e21
author Patrick McHardy <kaber@trash.net> Mon, 18 Sep 2006 11:34:25 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 18 Sep 2006 11:34:25 +0200

 include/net/xfrm.h      |   13 +++++++++++++
 net/ipv4/xfrm4_policy.c |   20 ++++++++++++++++++++
 net/ipv4/xfrm4_state.c  |   15 ---------------
 net/ipv6/xfrm6_policy.c |   21 +++++++++++++++++++++
 net/ipv6/xfrm6_state.c  |   16 ----------------
 net/xfrm/xfrm_policy.c  |   21 +++++++++++++++++++++
 6 files changed, 75 insertions(+), 31 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bf8e2df..c6fac69 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -223,6 +223,7 @@ struct xfrm_policy_afinfo {
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(void);
 	int			(*dst_lookup)(struct xfrm_dst **dst, struct flowi *fl);
+	int			(*get_saddr)(xfrm_address_t *saddr, xfrm_address_t *daddr);
 	struct dst_entry	*(*find_bundle)(struct flowi *fl, struct xfrm_policy *policy);
 	int			(*bundle_create)(struct xfrm_policy *policy, 
 						 struct xfrm_state **xfrm, 
@@ -632,6 +633,18 @@ #endif
 }
 
 static inline int
+xfrm_addr_any(xfrm_address_t *addr, unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+		return addr->a4 == 0;
+	case AF_INET6:
+		return ipv6_addr_any((struct in6_addr *)&addr->a6);
+	}
+	return 0;
+}
+
+static inline int
 __xfrm4_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x)
 {
 	return	(tmpl->saddr.a4 &&
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4795985..eabcd27 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -21,6 +21,25 @@ static int xfrm4_dst_lookup(struct xfrm_
 	return __ip_route_output_key((struct rtable**)dst, fl);
 }
 
+static int xfrm4_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
+{
+	struct rtable *rt;
+	struct flowi fl_tunnel = {
+		.nl_u = {
+			.ip4_u = {
+				.daddr = daddr->a4,
+			},
+		},
+	};
+
+	if (!xfrm4_dst_lookup((struct xfrm_dst **)&rt, &fl_tunnel)) {
+		saddr->a4 = rt->rt_src;
+		dst_release(&rt->u.dst);
+		return 0;
+	}
+	return -EHOSTUNREACH;
+}
+
 static struct dst_entry *
 __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 {
@@ -298,6 +317,7 @@ static struct xfrm_policy_afinfo xfrm4_p
 	.family = 		AF_INET,
 	.dst_ops =		&xfrm4_dst_ops,
 	.dst_lookup =		xfrm4_dst_lookup,
+	.get_saddr =		xfrm4_get_saddr,
 	.find_bundle = 		__xfrm4_find_bundle,
 	.bundle_create =	__xfrm4_bundle_create,
 	.decode_session =	_decode_session4,
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 6a2a4ab..fe20344 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -42,21 +42,6 @@ __xfrm4_init_tempsel(struct xfrm_state *
 	x->props.saddr = tmpl->saddr;
 	if (x->props.saddr.a4 == 0)
 		x->props.saddr.a4 = saddr->a4;
-	if (tmpl->mode == XFRM_MODE_TUNNEL && x->props.saddr.a4 == 0) {
-		struct rtable *rt;
-	        struct flowi fl_tunnel = {
-        	        .nl_u = {
-        			.ip4_u = {
-					.daddr = x->id.daddr.a4,
-				}
-			}
-		};
-		if (!xfrm_dst_lookup((struct xfrm_dst **)&rt,
-		                     &fl_tunnel, AF_INET)) {
-			x->props.saddr.a4 = rt->rt_src;
-			dst_release(&rt->u.dst);
-		}
-	}
 	x->props.mode = tmpl->mode;
 	x->props.reqid = tmpl->reqid;
 	x->props.family = AF_INET;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 9391c4c..6a252e2 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -34,6 +34,26 @@ static int xfrm6_dst_lookup(struct xfrm_
 	return err;
 }
 
+static int xfrm6_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
+{
+	struct rt6_info *rt;
+	struct flowi fl_tunnel = {
+		.nl_u = {
+			.ip6_u = {
+				.daddr = *(struct in6_addr *)&daddr->a6,
+			},
+		},
+	};
+
+	if (!xfrm6_dst_lookup((struct xfrm_dst **)&rt, &fl_tunnel)) {
+		ipv6_get_saddr(&rt->u.dst, (struct in6_addr *)&daddr->a6,
+			       (struct in6_addr *)&saddr->a6);
+		dst_release(&rt->u.dst);
+		return 0;
+	}
+	return -EHOSTUNREACH;
+}
+
 static struct dst_entry *
 __xfrm6_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 {
@@ -362,6 +382,7 @@ static struct xfrm_policy_afinfo xfrm6_p
 	.family =		AF_INET6,
 	.dst_ops =		&xfrm6_dst_ops,
 	.dst_lookup =		xfrm6_dst_lookup,
+	.get_saddr = 		xfrm6_get_saddr,
 	.find_bundle =		__xfrm6_find_bundle,
 	.bundle_create =	__xfrm6_bundle_create,
 	.decode_session =	_decode_session6,
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index d88cd92..711bfaf 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -42,22 +42,6 @@ __xfrm6_init_tempsel(struct xfrm_state *
 	memcpy(&x->props.saddr, &tmpl->saddr, sizeof(x->props.saddr));
 	if (ipv6_addr_any((struct in6_addr*)&x->props.saddr))
 		memcpy(&x->props.saddr, saddr, sizeof(x->props.saddr));
-	if (tmpl->mode == XFRM_MODE_TUNNEL && ipv6_addr_any((struct in6_addr*)&x->props.saddr)) {
-		struct rt6_info *rt;
-		struct flowi fl_tunnel = {
-			.nl_u = {
-				.ip6_u = {
-					.daddr = *(struct in6_addr *)daddr,
-				}
-			}
-		};
-		if (!xfrm_dst_lookup((struct xfrm_dst **)&rt,
-		                     &fl_tunnel, AF_INET6)) {
-			ipv6_get_saddr(&rt->u.dst, (struct in6_addr *)daddr,
-			               (struct in6_addr *)&x->props.saddr);
-			dst_release(&rt->u.dst);
-		}
-	}
 	x->props.mode = tmpl->mode;
 	x->props.reqid = tmpl->reqid;
 	x->props.family = AF_INET6;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 537854f..b6e2e79 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1107,6 +1107,20 @@ int __xfrm_sk_clone_policy(struct sock *
 	return 0;
 }
 
+static int
+xfrm_get_saddr(xfrm_address_t *local, xfrm_address_t *remote,
+	       unsigned short family)
+{
+	int err;
+	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+
+	if (unlikely(afinfo == NULL))
+		return -EINVAL;
+	err = afinfo->get_saddr(local, remote);
+	xfrm_policy_put_afinfo(afinfo);
+	return err;
+}
+
 /* Resolve list of templates for the flow, given policy. */
 
 static int
@@ -1118,6 +1132,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy
 	int i, error;
 	xfrm_address_t *daddr = xfrm_flowi_daddr(fl, family);
 	xfrm_address_t *saddr = xfrm_flowi_saddr(fl, family);
+	xfrm_address_t tmp;
 
 	for (nx=0, i = 0; i < policy->xfrm_nr; i++) {
 		struct xfrm_state *x;
@@ -1128,6 +1143,12 @@ xfrm_tmpl_resolve_one(struct xfrm_policy
 		if (tmpl->mode == XFRM_MODE_TUNNEL) {
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
+			if (xfrm_addr_any(local, family)) {
+				error = xfrm_get_saddr(&tmp, remote, family);
+				if (error)
+					goto fail;
+				local = &tmp;
+			}
 		}
 
 		x = xfrm_state_find(remote, local, fl, tmpl, policy, &error, family);

--------------060507050604040609080208--
