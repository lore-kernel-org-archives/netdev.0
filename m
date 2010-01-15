From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/fib_semantics.c: quiet sparse "shadows" noise
Date: Fri, 15 Jan 2010 01:17:30 -0800 (PST)
Message-ID: <20100115.011730.263631545.davem@davemloft.net>
References: <201001141652.42757.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: hartleys@visionengravers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51103
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757039Ab0AOJRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 04:17:21 -0500
In-Reply-To: <201001141652.42757.hartleys@visionengravers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Thu, 14 Jan 2010 16:52:41 -0700

> net/ipv4/fib_semantics.c: quiet sparse "shadows" noise
> 
> If CONFIG_IP_ROUTE_MULTIPATH is defined the symbol 'nh' is
> declared twice in the function fib_sync_down_dev. First as the
> loop variable used to iterate the hlist. Then again due to the
> change_nexthops macro. This produces a sparse warning and
> makes the code harder to understand.
> 
> Fix the issue by renaming the first symbol.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

I think it's easier to fix this by using a less simple name
in change_nexthops(), so I'll deal with this using the following
patch.

Thanks for reporting this:

ipv4: Use less conflicting local var name in change_nexthops() loop macro.

As noticed by H Hartley Sweeten, since change_nexthops() uses 'nh'
as it's iterator variable, it can conflict with other existing
local vars.

Use "nexthop_nh" to avoid the conflict and make it easier to figure
out where this magic variable comes from.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_semantics.c |   76 ++++++++++++++++++++++++----------------------
 1 files changed, 40 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index ed19aa6..96b2101 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -62,8 +62,8 @@ static DEFINE_SPINLOCK(fib_multipath_lock);
 #define for_nexthops(fi) { int nhsel; const struct fib_nh * nh; \
 for (nhsel=0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; nh++, nhsel++)
 
-#define change_nexthops(fi) { int nhsel; struct fib_nh * nh; \
-for (nhsel=0, nh = (struct fib_nh *)((fi)->fib_nh); nhsel < (fi)->fib_nhs; nh++, nhsel++)
+#define change_nexthops(fi) { int nhsel; struct fib_nh *nexthop_nh; \
+for (nhsel=0, nexthop_nh = (struct fib_nh *)((fi)->fib_nh); nhsel < (fi)->fib_nhs; nexthop_nh++, nhsel++)
 
 #else /* CONFIG_IP_ROUTE_MULTIPATH */
 
@@ -72,7 +72,7 @@ for (nhsel=0, nh = (struct fib_nh *)((fi)->fib_nh); nhsel < (fi)->fib_nhs; nh++,
 #define for_nexthops(fi) { int nhsel = 0; const struct fib_nh * nh = (fi)->fib_nh; \
 for (nhsel=0; nhsel < 1; nhsel++)
 
-#define change_nexthops(fi) { int nhsel = 0; struct fib_nh * nh = (struct fib_nh *)((fi)->fib_nh); \
+#define change_nexthops(fi) { int nhsel = 0; struct fib_nh *nexthop_nh = (struct fib_nh *)((fi)->fib_nh); \
 for (nhsel=0; nhsel < 1; nhsel++)
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
@@ -145,9 +145,9 @@ void free_fib_info(struct fib_info *fi)
 		return;
 	}
 	change_nexthops(fi) {
-		if (nh->nh_dev)
-			dev_put(nh->nh_dev);
-		nh->nh_dev = NULL;
+		if (nexthop_nh->nh_dev)
+			dev_put(nexthop_nh->nh_dev);
+		nexthop_nh->nh_dev = NULL;
 	} endfor_nexthops(fi);
 	fib_info_cnt--;
 	release_net(fi->fib_net);
@@ -162,9 +162,9 @@ void fib_release_info(struct fib_info *fi)
 		if (fi->fib_prefsrc)
 			hlist_del(&fi->fib_lhash);
 		change_nexthops(fi) {
-			if (!nh->nh_dev)
+			if (!nexthop_nh->nh_dev)
 				continue;
-			hlist_del(&nh->nh_hash);
+			hlist_del(&nexthop_nh->nh_hash);
 		} endfor_nexthops(fi)
 		fi->fib_dead = 1;
 		fib_info_put(fi);
@@ -395,19 +395,20 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 		if (!rtnh_ok(rtnh, remaining))
 			return -EINVAL;
 
-		nh->nh_flags = (cfg->fc_flags & ~0xFF) | rtnh->rtnh_flags;
-		nh->nh_oif = rtnh->rtnh_ifindex;
-		nh->nh_weight = rtnh->rtnh_hops + 1;
+		nexthop_nh->nh_flags =
+			(cfg->fc_flags & ~0xFF) | rtnh->rtnh_flags;
+		nexthop_nh->nh_oif = rtnh->rtnh_ifindex;
+		nexthop_nh->nh_weight = rtnh->rtnh_hops + 1;
 
 		attrlen = rtnh_attrlen(rtnh);
 		if (attrlen > 0) {
 			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
-			nh->nh_gw = nla ? nla_get_be32(nla) : 0;
+			nexthop_nh->nh_gw = nla ? nla_get_be32(nla) : 0;
 #ifdef CONFIG_NET_CLS_ROUTE
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
-			nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
+			nexthop_nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
 #endif
 		}
 
@@ -738,7 +739,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 	fi->fib_nhs = nhs;
 	change_nexthops(fi) {
-		nh->nh_parent = fi;
+		nexthop_nh->nh_parent = fi;
 	} endfor_nexthops(fi)
 
 	if (cfg->fc_mx) {
@@ -808,7 +809,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			goto failure;
 	} else {
 		change_nexthops(fi) {
-			if ((err = fib_check_nh(cfg, fi, nh)) != 0)
+			if ((err = fib_check_nh(cfg, fi, nexthop_nh)) != 0)
 				goto failure;
 		} endfor_nexthops(fi)
 	}
@@ -843,11 +844,11 @@ link_it:
 		struct hlist_head *head;
 		unsigned int hash;
 
-		if (!nh->nh_dev)
+		if (!nexthop_nh->nh_dev)
 			continue;
-		hash = fib_devindex_hashfn(nh->nh_dev->ifindex);
+		hash = fib_devindex_hashfn(nexthop_nh->nh_dev->ifindex);
 		head = &fib_info_devhash[hash];
-		hlist_add_head(&nh->nh_hash, head);
+		hlist_add_head(&nexthop_nh->nh_hash, head);
 	} endfor_nexthops(fi)
 	spin_unlock_bh(&fib_info_lock);
 	return fi;
@@ -1080,21 +1081,21 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 		prev_fi = fi;
 		dead = 0;
 		change_nexthops(fi) {
-			if (nh->nh_flags&RTNH_F_DEAD)
+			if (nexthop_nh->nh_flags&RTNH_F_DEAD)
 				dead++;
-			else if (nh->nh_dev == dev &&
-					nh->nh_scope != scope) {
-				nh->nh_flags |= RTNH_F_DEAD;
+			else if (nexthop_nh->nh_dev == dev &&
+				 nexthop_nh->nh_scope != scope) {
+				nexthop_nh->nh_flags |= RTNH_F_DEAD;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 				spin_lock_bh(&fib_multipath_lock);
-				fi->fib_power -= nh->nh_power;
-				nh->nh_power = 0;
+				fi->fib_power -= nexthop_nh->nh_power;
+				nexthop_nh->nh_power = 0;
 				spin_unlock_bh(&fib_multipath_lock);
 #endif
 				dead++;
 			}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-			if (force > 1 && nh->nh_dev == dev) {
+			if (force > 1 && nexthop_nh->nh_dev == dev) {
 				dead = fi->fib_nhs;
 				break;
 			}
@@ -1144,18 +1145,20 @@ int fib_sync_up(struct net_device *dev)
 		prev_fi = fi;
 		alive = 0;
 		change_nexthops(fi) {
-			if (!(nh->nh_flags&RTNH_F_DEAD)) {
+			if (!(nexthop_nh->nh_flags&RTNH_F_DEAD)) {
 				alive++;
 				continue;
 			}
-			if (nh->nh_dev == NULL || !(nh->nh_dev->flags&IFF_UP))
+			if (nexthop_nh->nh_dev == NULL ||
+			    !(nexthop_nh->nh_dev->flags&IFF_UP))
 				continue;
-			if (nh->nh_dev != dev || !__in_dev_get_rtnl(dev))
+			if (nexthop_nh->nh_dev != dev ||
+			    !__in_dev_get_rtnl(dev))
 				continue;
 			alive++;
 			spin_lock_bh(&fib_multipath_lock);
-			nh->nh_power = 0;
-			nh->nh_flags &= ~RTNH_F_DEAD;
+			nexthop_nh->nh_power = 0;
+			nexthop_nh->nh_flags &= ~RTNH_F_DEAD;
 			spin_unlock_bh(&fib_multipath_lock);
 		} endfor_nexthops(fi)
 
@@ -1182,9 +1185,9 @@ void fib_select_multipath(const struct flowi *flp, struct fib_result *res)
 	if (fi->fib_power <= 0) {
 		int power = 0;
 		change_nexthops(fi) {
-			if (!(nh->nh_flags&RTNH_F_DEAD)) {
-				power += nh->nh_weight;
-				nh->nh_power = nh->nh_weight;
+			if (!(nexthop_nh->nh_flags&RTNH_F_DEAD)) {
+				power += nexthop_nh->nh_weight;
+				nexthop_nh->nh_power = nexthop_nh->nh_weight;
 			}
 		} endfor_nexthops(fi);
 		fi->fib_power = power;
@@ -1204,9 +1207,10 @@ void fib_select_multipath(const struct flowi *flp, struct fib_result *res)
 	w = jiffies % fi->fib_power;
 
 	change_nexthops(fi) {
-		if (!(nh->nh_flags&RTNH_F_DEAD) && nh->nh_power) {
-			if ((w -= nh->nh_power) <= 0) {
-				nh->nh_power--;
+		if (!(nexthop_nh->nh_flags&RTNH_F_DEAD) &&
+		    nexthop_nh->nh_power) {
+			if ((w -= nexthop_nh->nh_power) <= 0) {
+				nexthop_nh->nh_power--;
 				fi->fib_power--;
 				res->nh_sel = nhsel;
 				spin_unlock_bh(&fib_multipath_lock);
-- 
1.6.5

