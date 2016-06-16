From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 3/4] net: core: add SW stats to if_stats_msg
Date: Thu, 16 Jun 2016 10:37:16 +0200
Message-ID: <1466066237-7719-4-git-send-email-jiri@resnulli.us>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34221 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950AbcFPIha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 04:37:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so7620831wmz.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 01:37:29 -0700 (PDT)
In-Reply-To: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
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
 net/core/rtnetlink.c         | 41 +++++++++++++++++++++++++++++++++++------
 2 files changed, 36 insertions(+), 6 deletions(-)

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
index 7958cde..d2acf9d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1068,6 +1068,11 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
+{
+	memcpy(v, b, sizeof(*b));
+}
+
 static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 					      struct net_device *dev)
 {
@@ -3490,10 +3495,13 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 			       unsigned int flags, unsigned int filter_mask,
 			       int *idxattr, int *prividx)
 {
+	struct rtnl_link_stats64 *stats64_sp = NULL;
+	struct rtnl_link_stats64 *sp;
 	struct if_stats_msg *ifsm;
 	struct nlmsghdr *nlh;
 	struct nlattr *attr;
 	int s_prividx = *prividx;
+	int err;
 
 	ASSERT_RTNL();
 
@@ -3506,24 +3514,20 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
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
@@ -3538,6 +3542,28 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
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
+
+		if (dev_have_sw_stats(dev)) {
+			dev_get_sw_stats(dev, sp);
+		} else {
+			/* if SW stats are not available we return default
+			 * stats. We query only if we don't already have them.
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
@@ -3554,6 +3580,7 @@ nla_put_failure:
 
 static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
 	[IFLA_STATS_LINK_64]	= { .len = sizeof(struct rtnl_link_stats64) },
+	[IFLA_STATS_LINK_SW_64] = { .len = sizeof(struct rtnl_link_stats64) },
 };
 
 static size_t if_nlmsg_stats_size(const struct net_device *dev,
@@ -3563,6 +3590,8 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_64, 0))
 		size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, 0))
+		size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, 0)) {
 		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
-- 
2.5.5
