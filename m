From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 3/7] net: rtnetlink: add linkxstats callbacks and attribute
Date: Wed, 27 Apr 2016 18:18:18 +0200
Message-ID: <1461773902-13528-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37563 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbcD0QSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:18:33 -0400
Received: by mail-wm0-f42.google.com with SMTP id a17so22922351wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:18:33 -0700 (PDT)
In-Reply-To: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add callbacks to calculate the size and fill link extended statistics
which can be split into multiple messages and are dumped via the new
rtnl stats API (RTM_GETSTATS) with the IFLA_STATS_LINK_XSTATS attribute.
Also add that attribute to the idx mask check since it is expected to
be able to save state and resume dumping (e.g. future bridge per-vlan
stats will be dumped via this attribute and callbacks).

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/net/rtnetlink.h      |  6 +++++-
 include/uapi/linux/if_link.h |  8 ++++++++
 net/core/rtnetlink.c         | 26 ++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 3f3b0b1b8722..b449c1f3416f 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -95,6 +95,10 @@ struct rtnl_link_ops {
 						   const struct net_device *dev,
 						   const struct net_device *slave_dev);
 	struct net		*(*get_link_net)(const struct net_device *dev);
+	size_t			(*get_linkxstats_size)(const struct net_device *dev);
+	int			(*fill_linkxstats)(struct sk_buff *skb,
+						   const struct net_device *dev,
+						   int *lidx);
 };
 
 int __rtnl_link_register(struct rtnl_link_ops *ops);
@@ -154,6 +158,6 @@ int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len);
  * IFLA_STATS_IDX_ATTR_MASK has all the idx saving attributes set and is
  * used to check if more than one is being requested
  */
-#define IFLA_STATS_IDX_ATTR_MASK 0
+#define IFLA_STATS_IDX_ATTR_MASK IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_XSTATS)
 
 #endif
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ba69d4447249..1b874e26b15b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -798,6 +798,7 @@ struct if_stats_msg {
 enum {
 	IFLA_STATS_UNSPEC, /* also used as 64bit pad attribute */
 	IFLA_STATS_LINK_64,
+	IFLA_STATS_LINK_XSTATS,
 	__IFLA_STATS_MAX,
 };
 
@@ -805,4 +806,11 @@ enum {
 
 #define IFLA_STATS_FILTER_BIT(ATTR)	(1 << (ATTR - 1))
 
+/* These are embedded into IFLA_STATS_LINK_XSTATS */
+enum {
+	LINK_XSTATS_UNSPEC,
+	__LINK_XSTATS_MAX
+};
+#define LINK_XSTATS_MAX (__LINK_XSTATS_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ea03b6cd3d3c..9637618c408d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3477,6 +3477,23 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		dev_get_stats(dev, sp);
 	}
 
+	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_XSTATS)) {
+		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+
+		if (ops && ops->fill_linkxstats) {
+			int err;
+
+			attr = nla_nest_start(skb, IFLA_STATS_LINK_XSTATS);
+			if (!attr)
+				goto nla_put_failure;
+
+			err = ops->fill_linkxstats(skb, dev, lidx);
+			nla_nest_end(skb, attr);
+			if (err)
+				goto nla_put_failure;
+		}
+	}
+
 	nlmsg_end(skb, nlh);
 
 	return 0;
@@ -3503,6 +3520,15 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64))
 		size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
 
+	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_XSTATS)) {
+		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+
+		if (ops && ops->get_linkxstats_size)
+			size += nla_total_size(ops->get_linkxstats_size(dev));
+		/* anything dumped is embedded in IFLA_STATS_LINK_XSTATS */
+		size += nla_total_size(0);
+	}
+
 	return size;
 }
 
-- 
2.4.11
