From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Validate route entry type at insert instead of
 every lookup.
Date: Mon, 07 Mar 2011 15:13:35 -0800 (PST)
Message-ID: <20110307.151335.242130370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35655
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756385Ab1CGXM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:12:57 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5A74A24C089
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2011 15:13:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fib_semantic_match() requires that if the type doesn't signal an
automatic error, it must be of type RTN_UNICAST, RTN_LOCAL,
RTN_BROADCAST, RTN_ANYCAST, or RTN_MULTICAST.

Checking this every route lookup is pointless work.

Instead validate it during route insertion, via fib_create_info().

Also, there was nothing making sure the type value was less than
RTN_MAX, so add that missing check while we're here.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_semantics.c |   54 +++++++++++++++++++++++----------------------
 1 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 562f34c..c29291b 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -707,6 +707,9 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	int nhs = 1;
 	struct net *net = cfg->fc_nlinfo.nl_net;
 
+	if (cfg->fc_type > RTN_MAX)
+		goto err_inval;
+
 	/* Fast check to catch the most weird cases */
 	if (fib_props[cfg->fc_type].scope > cfg->fc_scope)
 		goto err_inval;
@@ -812,6 +815,17 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
 			goto err_inval;
 		goto link_it;
+	} else {
+		switch (cfg->fc_type) {
+		case RTN_UNICAST:
+		case RTN_LOCAL:
+		case RTN_BROADCAST:
+		case RTN_ANYCAST:
+		case RTN_MULTICAST:
+			break;
+		default:
+			goto err_inval;
+		}
 	}
 
 	if (cfg->fc_scope > RT_SCOPE_HOST)
@@ -915,35 +929,23 @@ int fib_semantic_match(struct fib_table *tb, struct list_head *head,
 			if (fi->fib_flags & RTNH_F_DEAD)
 				continue;
 
-			switch (fa->fa_type) {
-			case RTN_UNICAST:
-			case RTN_LOCAL:
-			case RTN_BROADCAST:
-			case RTN_ANYCAST:
-			case RTN_MULTICAST:
-				for_nexthops(fi) {
-					if (nh->nh_flags & RTNH_F_DEAD)
-						continue;
-					if (!flp->oif || flp->oif == nh->nh_oif)
-						break;
-				}
+			for_nexthops(fi) {
+				if (nh->nh_flags & RTNH_F_DEAD)
+					continue;
+				if (!flp->oif || flp->oif == nh->nh_oif)
+					break;
+			}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-				if (nhsel < fi->fib_nhs) {
-					nh_sel = nhsel;
-					goto out_fill_res;
-				}
+			if (nhsel < fi->fib_nhs) {
+				nh_sel = nhsel;
+				goto out_fill_res;
+			}
 #else
-				if (nhsel < 1)
-					goto out_fill_res;
+			if (nhsel < 1)
+				goto out_fill_res;
 #endif
-				endfor_nexthops(fi);
-				continue;
-
-			default:
-				pr_warning("fib_semantic_match bad type %#x\n",
-					   fa->fa_type);
-				return -EINVAL;
-			}
+			endfor_nexthops(fi);
+			continue;
 		}
 		return err;
 	}
-- 
1.7.4.1

