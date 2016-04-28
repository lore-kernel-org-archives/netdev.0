From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/5] net: rtnetlink: add linkxstats callbacks and attribute
Date: Thu, 28 Apr 2016 17:52:48 +0200
Message-ID: <1461858771-4732-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35679 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbcD1PxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:53:03 -0400
Received: by mail-wm0-f52.google.com with SMTP id e201so82115370wme.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 08:53:03 -0700 (PDT)
In-Reply-To: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add callbacks to calculate the size and fill link extended statistics
which can be split into multiple messages and are dumped via the new
rtnl stats API (RTM_GETSTATS) with the IFLA_STATS_LINK_XSTATS attribute.
Also add that attribute to the idx mask check since it is expected to
be able to save state and resume dumping (e.g. future bridge per-vlan
stats will be dumped via this attribute and callbacks).
Each link type should nest its private attributes under the per-link type
attribute. This allows to have any number of separated private attributes
and to avoid one call to get the dev link type.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: add callback descriptions and make the size calculation more
accurate, change the netlink xstats message structure with one more
level for each rtnl link type which allows for private link type attributes
and also allows us to avoid 1 call to get the dev link type.

 include/net/rtnetlink.h      |  7 +++++++
 include/uapi/linux/if_link.h | 12 ++++++++++++
 net/core/rtnetlink.c         | 30 ++++++++++++++++++++++++++++++
 3 files changed, 49 insertions(+)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 2f87c1ba13de..006a7b81d758 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -47,6 +47,9 @@ static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
  *	@get_num_rx_queues: Function to determine number of receive queues
  *			    to create when creating a new device.
  *	@get_link_net: Function to get the i/o netns of the device
+ *	@get_linkxstats_size: Function to calculate the required room for
+ *			      dumping device-specific extended link stats
+ *	@fill_linkxstats: Function to dump device-specific extended link stats
  */
 struct rtnl_link_ops {
 	struct list_head	list;
@@ -95,6 +98,10 @@ struct rtnl_link_ops {
 						   const struct net_device *dev,
 						   const struct net_device *slave_dev);
 	struct net		*(*get_link_net)(const struct net_device *dev);
+	size_t			(*get_linkxstats_size)(const struct net_device *dev);
+	int			(*fill_linkxstats)(struct sk_buff *skb,
+						   const struct net_device *dev,
+						   int *prividx);
 };
 
 int __rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d82de331bb6b..8577c0e4116f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -802,6 +802,7 @@ struct if_stats_msg {
 enum {
 	IFLA_STATS_UNSPEC, /* also used as 64bit pad attribute */
 	IFLA_STATS_LINK_64,
+	IFLA_STATS_LINK_XSTATS,
 	__IFLA_STATS_MAX,
 };
 
@@ -809,4 +810,15 @@ enum {
 
 #define IFLA_STATS_FILTER_BIT(ATTR)	(1 << (ATTR - 1))
 
+/* These are embedded into IFLA_STATS_LINK_XSTATS:
+ * [IFLA_STATS_LINK_XSTATS]
+ * -> [LINK_XSTATS_TYPE_xxx]
+ *    -> [rtnl link type specific attributes]
+ */
+enum {
+	LINK_XSTATS_TYPE_UNSPEC,
+	__LINK_XSTATS_TYPE_MAX
+};
+#define LINK_XSTATS_TYPE_MAX (__LINK_XSTATS_TYPE_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index de529a20cd18..d471f097c739 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3483,6 +3483,26 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		dev_get_stats(dev, sp);
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, *idxattr)) {
+		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+
+		if (ops && ops->fill_linkxstats) {
+			int err;
+
+			*idxattr = IFLA_STATS_LINK_XSTATS;
+			attr = nla_nest_start(skb,
+					      IFLA_STATS_LINK_XSTATS);
+			if (!attr)
+				goto nla_put_failure;
+
+			err = ops->fill_linkxstats(skb, dev, prividx);
+			nla_nest_end(skb, attr);
+			if (err)
+				goto nla_put_failure;
+			*idxattr = 0;
+		}
+	}
+
 	nlmsg_end(skb, nlh);
 
 	return 0;
@@ -3509,6 +3529,16 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_64, 0))
 		size += nla_total_size_64bit(sizeof(struct rtnl_link_stats64));
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, 0)) {
+		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+
+		if (ops && ops->get_linkxstats_size) {
+			size += nla_total_size(ops->get_linkxstats_size(dev));
+			/* for IFLA_STATS_LINK_XSTATS */
+			size += nla_total_size(0);
+		}
+	}
+
 	return size;
 }
 
-- 
2.4.11
