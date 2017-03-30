From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/6] net: mpls: Convert number of nexthops to u8
Date: Thu, 30 Mar 2017 09:18:20 -0700
Message-ID: <1490890704-8075-3-git-send-email-dsa@cumulusnetworks.com>
References: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:32840 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934295AbdC3QSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 12:18:33 -0400
Received: by mail-pg0-f44.google.com with SMTP id x125so44442546pgb.0
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 09:18:32 -0700 (PDT)
In-Reply-To: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Number of nexthops and number of alive nexthops are tracked using an
unsigned int. A route should never have more than 255 nexthops so
convert both to u8. Update all references and intermediate variables
to consistently use u8 as well.

Shrinks the size of mpls_route from 32 bytes to 24 bytes with a 2-byte
hole before the nexthops.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- label u16 hole in mpls_route as rt_reserved1

 net/mpls/af_mpls.c  | 28 +++++++++++++++++-----------
 net/mpls/internal.h |  5 +++--
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 6bdd2f95b576..665dec84f001 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -197,10 +197,10 @@ static u32 mpls_multipath_hash(struct mpls_route *rt, struct sk_buff *skb)
 static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 					     struct sk_buff *skb)
 {
-	unsigned int alive;
 	u32 hash = 0;
 	int nh_index = 0;
 	int n = 0;
+	u8 alive;
 
 	/* No need to look further into packet if there's only
 	 * one path
@@ -466,7 +466,7 @@ struct mpls_route_config {
 	int			rc_mp_len;
 };
 
-static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
+static struct mpls_route *mpls_rt_alloc(u8 num_nh, u8 max_alen)
 {
 	u8 max_alen_aligned = ALIGN(max_alen, VIA_ALEN_ALIGN);
 	struct mpls_route *rt;
@@ -744,11 +744,11 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 	return err;
 }
 
-static int mpls_count_nexthops(struct rtnexthop *rtnh, int len,
-			       u8 cfg_via_alen, u8 *max_via_alen)
+static u8 mpls_count_nexthops(struct rtnexthop *rtnh, int len,
+			      u8 cfg_via_alen, u8 *max_via_alen)
 {
-	int nhs = 0;
 	int remaining = len;
+	u8 nhs = 0;
 
 	if (!rtnh) {
 		*max_via_alen = cfg_via_alen;
@@ -773,7 +773,13 @@ static int mpls_count_nexthops(struct rtnexthop *rtnh, int len,
 						      via_alen);
 		}
 
+		/* number of nexthops is tracked by a u8.
+		 * Check for overflow.
+		 */
+		if (nhs == 255)
+			return 0;
 		nhs++;
+
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
@@ -787,8 +793,8 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 	struct rtnexthop *rtnh = cfg->rc_mp;
 	struct nlattr *nla_via, *nla_newdst;
 	int remaining = cfg->rc_mp_len;
-	int nhs = 0;
 	int err = 0;
+	u8 nhs = 0;
 
 	change_nexthops(rt) {
 		int attrlen;
@@ -842,7 +848,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	int err = -EINVAL;
 	u8 max_via_alen;
 	unsigned index;
-	int nhs;
+	u8 nhs;
 
 	index = cfg->rc_label;
 
@@ -1310,7 +1316,7 @@ static void mpls_ifdown(struct net_device *dev, int event)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
-	unsigned int alive, deleted;
+	u8 alive, deleted;
 	unsigned index;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
@@ -1362,7 +1368,7 @@ static void mpls_ifup(struct net_device *dev, unsigned int flags)
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
 	unsigned index;
-	int alive;
+	u8 alive;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	for (index = 0; index < net->mpls.platform_labels; index++) {
@@ -1786,8 +1792,8 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	} else {
 		struct rtnexthop *rtnh;
 		struct nlattr *mp;
-		int dead = 0;
-		int linkdown = 0;
+		u8 linkdown = 0;
+		u8 dead = 0;
 
 		mp = nla_nest_start(skb, RTA_MULTIPATH);
 		if (!mp)
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 91419fe63464..2ac97433c3b7 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -127,12 +127,13 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_payload_type;
 	u8			rt_max_alen;
 	u8			rt_ttl_propagate;
-	unsigned int		rt_nhn;
+	u8			rt_nhn;
 
 	/* rt_nhn_alive is accessed under RCU in the packet path; it
 	 * is modified handling netdev events with rtnl lock held
 	 */
-	unsigned int		rt_nhn_alive;
+	u8			rt_nhn_alive;
+	u16			rt_reserved1;
 	struct mpls_nh		rt_nh[0];
 };
 
-- 
2.1.4
