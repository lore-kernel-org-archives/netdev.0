From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Thu,  4 Apr 2013 17:12:42 +0200
Message-ID: <1365088362-4318-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, dbaluta@ixiacom.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45824 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762116Ab3DDPMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 11:12:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bc8e4b954e46 (xfrm6: ensure to use the same dev when building a bundle)
broke IPsec for IPv4 over IPv6 tunnels (because dev points to an IPv4 only
interface, hence in6_dev_get(dev) returns NULL.

After looking again into commit 25ee3286dcbc ([IPSEC]: Merge common code into
xfrm_bundle_create), it seems that previously we were using dev from the route,
for both IPv4 and IPv6.

In fact, xfrm_fill_dst() is called during a loop on chained dst, but dev points
always to the same device.

By analogy, I made the same change for IPv4 side (only IPv6 part is tested).

Reported-by: Daniel Baluta <dbaluta@ixiacom.com>
Tested-by: Daniel Baluta <dbaluta@ixiacom.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

This patch is only a RFC, it needs more tests. Any comments/help is welcome to
understand if the patch do the right thing or if the bug if somewere else.

If the patch is correct, I can also remove the argument dev from
xfrm[4|6]_fill_dst, because it will not be used anymore.

FYI, the initial thread for commit bc8e4b954e46 can be found here:
http://kerneltrap.org/mailarchive/linux-netdev/2010/4/15/6274817

 net/ipv4/xfrm4_policy.c | 4 ++--
 net/ipv6/xfrm6_policy.c | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 9a459be..3cffae9 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -81,8 +81,8 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	xdst->u.rt.rt_iif = fl4->flowi4_iif;
 
-	xdst->u.dst.dev = dev;
-	dev_hold(dev);
+	xdst->u.dst.dev = rt->dst.dev;
+	dev_hold(rt->dst.dev);
 
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 4ef7bdb..680b890 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -99,10 +99,10 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 {
 	struct rt6_info *rt = (struct rt6_info*)xdst->route;
 
-	xdst->u.dst.dev = dev;
-	dev_hold(dev);
+	xdst->u.dst.dev = rt->dst.dev;
+	dev_hold(rt->dst.dev);
 
-	xdst->u.rt6.rt6i_idev = in6_dev_get(dev);
+	xdst->u.rt6.rt6i_idev = in6_dev_get(rt->dst.dev);
 	if (!xdst->u.rt6.rt6i_idev)
 		return -ENODEV;
 
-- 
1.8.0.1
