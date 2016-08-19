From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v6_repost 2/3] net: core: add SW stats to if_stats_msg
Date: Fri, 19 Aug 2016 15:17:29 +0200
Message-ID: <1471612650-4508-3-git-send-email-jiri@resnulli.us>
References: <1471612650-4508-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33149 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754789AbcHSNRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 09:17:36 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so3427053wme.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 06:17:36 -0700 (PDT)
In-Reply-To: <1471612650-4508-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a nested attribute of SW stats to if_stats_msg
under IFLA_STATS_LINK_SW_64.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a1b5202..1c9b808 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -825,6 +825,7 @@ enum {
 	IFLA_STATS_LINK_64,
 	IFLA_STATS_LINK_XSTATS,
 	IFLA_STATS_LINK_XSTATS_SLAVE,
+	IFLA_STATS_LINK_SW_64,
 	__IFLA_STATS_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 189cc78..910f802 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3583,6 +3583,21 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		dev_get_stats(dev, sp);
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, *idxattr)) {
+		if (dev_have_sw_stats(dev)) {
+			struct rtnl_link_stats64 *sp;
+
+			attr = nla_reserve_64bit(skb, IFLA_STATS_LINK_SW_64,
+						 sizeof(struct rtnl_link_stats64),
+						 IFLA_STATS_UNSPEC);
+			if (!attr)
+				goto nla_put_failure;
+
+			sp = nla_data(attr);
+			dev_get_sw_stats(dev, sp);
+		}
+	}
+
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, *idxattr)) {
 		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
 
@@ -3644,6 +3659,7 @@ nla_put_failure:
 
 static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
 	[IFLA_STATS_LINK_64]	= { .len = sizeof(struct rtnl_link_stats64) },
+	[IFLA_STATS_LINK_SW_64] = { .len = sizeof(struct rtnl_link_stats64) },
 };
 
 static size_t if_nlmsg_stats_size(const struct net_device *dev,
@@ -3685,6 +3701,11 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 		}
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_SW_64, 0)) {
+		if (dev_have_sw_stats(dev))
+			size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
+	}
+
 	return size;
 }
 
-- 
2.5.5
