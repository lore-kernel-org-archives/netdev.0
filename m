From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH net-2.6.23-rc5] ipsec interfamily route handling fix
Date: Thu, 6 Sep 2007 19:00:10 +0300
Message-ID: <200709061900.10508.joakim.koskela@hiit.fi>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:34891 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756942AbXIFQIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 12:08:23 -0400
Received: from [10.0.0.64] (88.193.26.249) by pne-smtpout3-sn1.fre.skanova.net (7.2.075)
        id 46CBD460000C6C1C for netdev@vger.kernel.org; Thu, 6 Sep 2007 18:08:21 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch addresses a couple of issues related to interfamily ipsec
modes. The problem is that the structure of the routing info changes
with the family during the __xfrmX_bundle_create, which hasn't been
taken properly into account. Seems that by coincidence it hasn't
caused problems on 32bit platforms, but crashes for example on x86_64
in 6-4 around line 209 of xfrm6_policy.c as rt doesn't point to a
rt6_info anymore, but actually a struct rtable. With 64bit pointers,
the rt->rt6i_node pointer seems to hit something usually not null in
the rtable that rt now points to, making it go for the path_cookie
assignment and subsequently crashing.

Tested on both 32/64bit with all four (44/46/64/66) combinations of
transformation. I'm still a bit worried about how for example nested
transformations work with all of this and would appreciate if someone
more familiar with the details of these structs could comment.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
---

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4ff8ed3..7410c0d 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -72,6 +72,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct 
xfrm_state **xfrm, int
 	struct dst_entry *dst, *dst_prev;
 	struct rtable *rt0 = (struct rtable*)(*dst_p);
 	struct rtable *rt = rt0;
+	unsigned short encap_family = AF_INET;
 	struct flowi fl_tunnel = {
 		.nl_u = {
 			.ip4_u = {
@@ -118,7 +119,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct 
xfrm_state **xfrm, int
 		trailer_len += xfrm[i]->props.trailer_len;
 
 		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
-			unsigned short encap_family = xfrm[i]->props.family;
+			encap_family = xfrm[i]->props.family;
 			switch (encap_family) {
 			case AF_INET:
 				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
@@ -180,16 +181,19 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct 
xfrm_state **xfrm, int
 		}
 		dst_prev->output = afinfo->output;
 		xfrm_state_put_afinfo(afinfo);
-		if (dst_prev->xfrm->props.family == AF_INET && rt->peer)
-			atomic_inc(&rt->peer->refcnt);
-		x->u.rt.peer = rt->peer;
+
+		if (encap_family == AF_INET) {
+			if (dst_prev->xfrm->props.family == AF_INET && rt->peer)
+				atomic_inc(&rt->peer->refcnt);
+			x->u.rt.peer = rt->peer;
+			x->u.rt.rt_type = rt->rt_type;
+			x->u.rt.rt_gateway = rt->rt_gateway;
+		}
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt.rt_flags = rt0->rt_flags&(RTCF_BROADCAST|RTCF_MULTICAST|
RTCF_LOCAL);
-		x->u.rt.rt_type = rt->rt_type;
 		x->u.rt.rt_src = rt0->rt_src;
 		x->u.rt.rt_dst = rt0->rt_dst;
-		x->u.rt.rt_gateway = rt->rt_gateway;
 		x->u.rt.rt_spec_dst = rt0->rt_spec_dst;
 		x->u.rt.idev = rt0->idev;
 		in_dev_hold(rt0->idev);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 3ec0c47..9733f39 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -131,6 +131,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct 
xfrm_state **xfrm, int
 	struct dst_entry *dst, *dst_prev;
 	struct rt6_info *rt0 = (struct rt6_info*)(*dst_p);
 	struct rt6_info *rt  = rt0;
+	unsigned short encap_family = AF_INET6;
 	struct flowi fl_tunnel = {
 		.nl_u = {
 			.ip6_u = {
@@ -180,11 +181,13 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct 
xfrm_state **xfrm, int
 
 		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL ||
 		    xfrm[i]->props.mode == XFRM_MODE_ROUTEOPTIMIZATION) {
-			unsigned short encap_family = xfrm[i]->props.family;
+			encap_family = xfrm[i]->props.family;
 			switch(encap_family) {
 			case AF_INET:
 				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
 				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
+				fl_tunnel.fl4_tos = 0;
+				fl_tunnel.fl4_scope = 0;
 				break;
 			case AF_INET6:
 				ipv6_addr_copy(&fl_tunnel.fl6_dst, __xfrm6_bundle_addr_remote(xfrm[i], 
&fl->fl6_dst));
@@ -205,7 +208,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct 
xfrm_state **xfrm, int
 
 	dst_prev->child = &rt->u.dst;
 	dst->path = &rt->u.dst;
-	if (rt->rt6i_node)
+	if (encap_family == AF_INET6 && rt->rt6i_node)
 		((struct xfrm_dst *)dst)->path_cookie = rt->rt6i_node->fn_sernum;
 
 	*dst_p = dst;
