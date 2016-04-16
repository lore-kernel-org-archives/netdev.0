From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] rtnetlink: rtnl_fill_stats: avoid an unnecssary stats copy
Date: Fri, 15 Apr 2016 20:36:25 -0700
Message-ID: <1460777785-43349-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34805 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbcDPDga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 23:36:30 -0400
Received: by mail-pa0-f52.google.com with SMTP id r5so6772776pag.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 20:36:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch passes netlink attr data ptr directly to dev_get_stats
thus elimiating a stats copy.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a75f7e9..a7a3d34 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -808,11 +808,6 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->rx_nohandler = b->rx_nohandler;
 }
 
-static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
-{
-	memcpy(v, b, sizeof(*b));
-}
-
 /* All VF info */
 static inline int rtnl_vfinfo_size(const struct net_device *dev,
 				   u32 ext_filter_mask)
@@ -1054,25 +1049,23 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 					      struct net_device *dev)
 {
-	const struct rtnl_link_stats64 *stats;
-	struct rtnl_link_stats64 temp;
+	struct rtnl_link_stats64 *sp;
 	struct nlattr *attr;
 
-	stats = dev_get_stats(dev, &temp);
-
-	attr = nla_reserve(skb, IFLA_STATS,
-			   sizeof(struct rtnl_link_stats));
+	attr = nla_reserve(skb, IFLA_STATS64,
+			   sizeof(struct rtnl_link_stats64));
 	if (!attr)
 		return -EMSGSIZE;
 
-	copy_rtnl_link_stats(nla_data(attr), stats);
+	sp = nla_data(attr);
+	dev_get_stats(dev, sp);
 
-	attr = nla_reserve(skb, IFLA_STATS64,
-			   sizeof(struct rtnl_link_stats64));
+	attr = nla_reserve(skb, IFLA_STATS,
+			   sizeof(struct rtnl_link_stats));
 	if (!attr)
 		return -EMSGSIZE;
 
-	copy_rtnl_link_stats64(nla_data(attr), stats);
+	copy_rtnl_link_stats(nla_data(attr), sp);
 
 	return 0;
 }
-- 
1.9.1
