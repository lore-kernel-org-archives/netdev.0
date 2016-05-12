From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] net: core: add SW stats to if_stats_msg
Date: Thu, 12 May 2016 11:59:57 +0200
Message-ID: <1463047198-10630-4-git-send-email-jiri@resnulli.us>
References: <1463047198-10630-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33076 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbcELKAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 06:00:05 -0400
Received: by mail-wm0-f67.google.com with SMTP id r12so14979886wme.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 03:00:04 -0700 (PDT)
In-Reply-To: <1463047198-10630-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

If there is a dedicated ndo to return SW stats - use
it. Otherwise (indicates that there is no HW stats) use
the default stats ndo.
Return results under IFLA_STATS_LINK_SW_64.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 35 +++++++++++++++++++++++++++++------
 2 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 98175e7..fcfb944 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -823,6 +823,7 @@ enum {
 	IFLA_STATS_UNSPEC, /* also used as 64bit pad attribute */
 	IFLA_STATS_LINK_64,
 	IFLA_STATS_LINK_XSTATS,
+	IFLA_STATS_LINK_SW_64,
 	__IFLA_STATS_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a127d67..f8b12e4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3481,6 +3481,9 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 	struct nlmsghdr *nlh;
 	struct nlattr *attr;
 	int s_prividx = *prividx;
+	struct rtnl_link_stats64 *sp;
+	struct rtnl_link_stats64 *stats64_sp = 0;
+	int err;
 
 	ASSERT_RTNL();
 
@@ -3493,24 +3496,20 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 	ifsm->filter_mask = filter_mask;
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_64, *idxattr)) {
-		struct rtnl_link_stats64 *sp;
-
 		attr = nla_reserve_64bit(skb, IFLA_STATS_LINK_64,
 					 sizeof(struct rtnl_link_stats64),
 					 IFLA_STATS_UNSPEC);
 		if (!attr)
 			goto nla_put_failure;
 
-		sp = nla_data(attr);
-		dev_get_stats(dev, sp);
+		stats64_sp = nla_data(attr);
+		dev_get_stats(dev, stats64_sp);
 	}
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, *idxattr)) {
 		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
 
 		if (ops && ops->fill_linkxstats) {
-			int err;
-
 			*idxattr = IFLA_STATS_LINK_XSTATS;
 			attr = nla_nest_start(skb,
 					      IFLA_STATS_LINK_XSTATS);
@@ -3525,6 +3524,27 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, *idxattr)) {
+		attr = nla_reserve_64bit(skb, IFLA_STATS_LINK_SW_64,
+					 sizeof(struct rtnl_link_stats64),
+					 IFLA_STATS_UNSPEC);
+		if (!attr)
+			goto nla_put_failure;
+
+		sp = nla_data(attr);
+		err = dev_get_sw_stats(dev, sp);
+		if (err) {
+			/* if err it means there is no dedicated ndo to
+			 * get SW stats - so it is returned by the default
+			 * stats ndo
+			 */
+			if (stats64_sp)
+				copy_rtnl_link_stats64(sp, stats64_sp);
+			else
+				dev_get_stats(dev, sp);
+		}
+	}
+
 	nlmsg_end(skb, nlh);
 
 	return 0;
@@ -3541,6 +3561,7 @@ nla_put_failure:
 
 static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
 	[IFLA_STATS_LINK_64]	= { .len = sizeof(struct rtnl_link_stats64) },
+	[IFLA_STATS_LINK_SW_64] = { .len = sizeof(struct rtnl_link_stats64) },
 };
 
 static size_t if_nlmsg_stats_size(const struct net_device *dev,
@@ -3550,6 +3571,8 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_64, 0))
 		size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, 0))
+		size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, 0)) {
 		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
-- 
2.5.5
