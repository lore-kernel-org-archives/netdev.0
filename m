From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/4] net: mpls: Convert number of nexthops to u8
Date: Sat, 25 Mar 2017 10:03:25 -0700
Message-ID: <1490461408-9551-2-git-send-email-dsa@cumulusnetworks.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34275 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdCYRDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 13:03:43 -0400
Received: by mail-pf0-f175.google.com with SMTP id p189so8244996pfp.1
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 10:03:42 -0700 (PDT)
In-Reply-To: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Number of nexthops and number of alive nexthops are tracked using an
unsigned int. A route should never have more than 255 nexthops so
convert both to u8. Update all references and intermediate variables
to consistently use u8 as well.

Shrinks the size of mpls_route from 32 bytes to 24 bytes with a 2-byte
hole before the nexthops.

Also, the ACCESS_ONCE is changed to READ_ONCE per checkpatch message.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c  | 29 ++++++++++++++++++-----------
 net/mpls/internal.h |  4 ++--
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index cd8be8d5e4ad..d3dc6c43a1d1 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -192,7 +192,7 @@ static u32 mpls_multipath_hash(struct mpls_route *rt, struct sk_buff *skb)
 static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 					     struct sk_buff *skb)
 {
-	int alive = ACCESS_ONCE(rt->rt_nhn_alive);
+	u8 alive = READ_ONCE(rt->rt_nhn_alive);
 	u32 hash = 0;
 	int nh_index = 0;
 	int n = 0;
@@ -458,7 +458,7 @@ struct mpls_route_config {
 	int			rc_mp_len;
 };
 
-static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
+static struct mpls_route *mpls_rt_alloc(u8 num_nh, u8 max_alen)
 {
 	u8 max_alen_aligned = ALIGN(max_alen, VIA_ALEN_ALIGN);
 	struct mpls_route *rt;
@@ -736,11 +736,11 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
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
@@ -765,7 +765,14 @@ static int mpls_count_nexthops(struct rtnexthop *rtnh, int len,
 						      via_alen);
 		}
 
+		/* number of nexthops is tracked by a u8.
+		 * Check for overflow.
+		 */
+		if (nhs == 255)
+			return 0;
+
 		nhs++;
+
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
@@ -779,8 +786,8 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 	struct rtnexthop *rtnh = cfg->rc_mp;
 	struct nlattr *nla_via, *nla_newdst;
 	int remaining = cfg->rc_mp_len;
-	int nhs = 0;
 	int err = 0;
+	u8 nhs = 0;
 
 	change_nexthops(rt) {
 		int attrlen;
@@ -834,7 +841,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	int err = -EINVAL;
 	u8 max_via_alen;
 	unsigned index;
-	int nhs;
+	u8 nhs;
 
 	index = cfg->rc_label;
 
@@ -1299,8 +1306,8 @@ static void mpls_ifdown(struct net_device *dev, int event)
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
 	unsigned int nh_flags = RTNH_F_DEAD | RTNH_F_LINKDOWN;
-	unsigned int alive;
 	unsigned index;
+	u8 alive;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	for (index = 0; index < net->mpls.platform_labels; index++) {
@@ -1339,7 +1346,7 @@ static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
 	unsigned index;
-	int alive;
+	u8 alive;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	for (index = 0; index < net->mpls.platform_labels; index++) {
@@ -1761,8 +1768,8 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
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
index 62928d8fabd1..66f388ba2d49 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -123,8 +123,8 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_payload_type;
 	u8			rt_max_alen;
 	u8			rt_ttl_propagate;
-	unsigned int		rt_nhn;
-	unsigned int		rt_nhn_alive;
+	u8			rt_nhn;
+	u8			rt_nhn_alive;
 	struct mpls_nh		rt_nh[0];
 };
 
-- 
2.1.4
