From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] ipv4: check rt_genid in dst_check
Date: Thu, 18 Mar 2010 13:48:22 +0200
Message-ID: <1268912902-27050-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:63936 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648Ab0CRLsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 07:48:30 -0400
Received: by ewy8 with SMTP id 8so1082711ewy.28
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 04:48:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xfrm_dst keeps a reference to ipv4 rtable entries on each
cached bundle. The only we to renew xfrm_dst when the underlying
route has changed, is to implement dst_check for this. This is
what ipv6 side does too.

The problems started after 87c1e12b5eeb7b30b4b41291bef8e0b41fc3dde9
which fixed a bug causing xfrm_dst to not get reused, until that all
lookups always generated new xfrm_dst with new route reference
and path mtu worked. But after the fix, the old routes started
to get reused even after they were expired causing pmtu to break
(well it would occationally work if the rtable gc has ran recently
and marked the route obsolete causing dst_check to get called).

Signed-off-by: Timo Teras <timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/ipv4/route.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a770df2..59449a3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1441,7 +1441,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 					dev_hold(rt->u.dst.dev);
 				if (rt->idev)
 					in_dev_hold(rt->idev);
-				rt->u.dst.obsolete	= 0;
+				rt->u.dst.obsolete	= -1;
 				rt->u.dst.lastuse	= jiffies;
 				rt->u.dst.path		= &rt->u.dst;
 				rt->u.dst.neighbour	= NULL;
@@ -1506,7 +1506,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 	struct dst_entry *ret = dst;
 
 	if (rt) {
-		if (dst->obsolete) {
+		if (dst->obsolete > 0) {
 			ip_rt_put(rt);
 			ret = NULL;
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
@@ -1726,7 +1726,9 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
-	return NULL;
+	if (dst && dst->dev && rt_is_expired((struct rtable *) dst))
+		return NULL;
+	return dst;
 }
 
 static void ipv4_dst_destroy(struct dst_entry *dst)
@@ -1888,7 +1890,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (!rth)
 		goto e_nobufs;
 
-	rth->u.dst.output= ip_rt_bug;
+	rth->u.dst.output = ip_rt_bug;
+	rth->u.dst.obsolete = -1;
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
 	rth->u.dst.flags= DST_HOST;
@@ -2054,6 +2057,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->fl.oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
+	rth->u.dst.obsolete = -1;
 	rth->u.dst.input = ip_forward;
 	rth->u.dst.output = ip_output;
 	rth->rt_genid = rt_genid(dev_net(rth->u.dst.dev));
@@ -2218,6 +2222,7 @@ local_input:
 		goto e_nobufs;
 
 	rth->u.dst.output= ip_rt_bug;
+	rth->u.dst.obsolete = -1;
 	rth->rt_genid = rt_genid(net);
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
@@ -2444,6 +2449,7 @@ static int __mkroute_output(struct rtable **result,
 	rth->rt_spec_dst= fl->fl4_src;
 
 	rth->u.dst.output=ip_output;
+	rth->u.dst.obsolete = -1;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 
 	RT_CACHE_STAT_INC(out_slow_tot);
-- 
1.6.3.3

