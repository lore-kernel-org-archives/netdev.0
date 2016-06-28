From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/2] net: rtnetlink: add support for the IFLA_STATS_LINK_XSTATS_SLAVE attribute
Date: Tue, 28 Jun 2016 16:57:05 +0200
Message-ID: <1467125826-11980-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1467125826-11980-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: linus.luessing@c0d3.blue, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38388 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcF1O5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 10:57:45 -0400
Received: by mail-wm0-f51.google.com with SMTP id r201so31923184wme.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 07:57:45 -0700 (PDT)
In-Reply-To: <1467125826-11980-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the IFLA_STATS_LINK_XSTATS_SLAVE attribute
which allows to export per-slave statistics if the master device supports
the linkxstats callback. The attribute is passed down to the linkxstats
callback and it is up to the callback user to use it (an example has been
added to the only current user - the bridge). This allows us to query only
specific slaves of master devices like bridge ports and export only what
we're interested in instead of having to dump all ports and searching only
for a single one. This will be used to export per-port IGMP/MLD stats and
also per-port vlan stats in the future, possibly other statistics as well.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: new patch

 include/net/rtnetlink.h      |  5 ++--
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 59 +++++++++++++++++++++++++++++++++++++++++---
 net/core/rtnetlink.c         | 50 +++++++++++++++++++++++++++++++++++--
 4 files changed, 108 insertions(+), 7 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 006a7b81d758..4113916cc1bb 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -98,10 +98,11 @@ struct rtnl_link_ops {
 						   const struct net_device *dev,
 						   const struct net_device *slave_dev);
 	struct net		*(*get_link_net)(const struct net_device *dev);
-	size_t			(*get_linkxstats_size)(const struct net_device *dev);
+	size_t			(*get_linkxstats_size)(const struct net_device *dev,
+						       int attr);
 	int			(*fill_linkxstats)(struct sk_buff *skb,
 						   const struct net_device *dev,
-						   int *prividx);
+						   int *prividx, int attr);
 };
 
 int __rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bb36bd5675a7..db2458ade81c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -822,6 +822,7 @@ enum {
 	IFLA_STATS_UNSPEC, /* also used as 64bit pad attribute */
 	IFLA_STATS_LINK_64,
 	IFLA_STATS_LINK_XSTATS,
+	IFLA_STATS_LINK_XSTATS_SLAVE,
 	__IFLA_STATS_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a5343c7232bf..765e7e72edb3 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1234,7 +1234,7 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	return 0;
 }
 
-static size_t br_get_linkxstats_size(const struct net_device *dev)
+static size_t bridge_get_linkxstats_size(const struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_vlan_group *vg;
@@ -1254,8 +1254,30 @@ static size_t br_get_linkxstats_size(const struct net_device *dev)
 	       nla_total_size(0);
 }
 
-static int br_fill_linkxstats(struct sk_buff *skb, const struct net_device *dev,
-			      int *prividx)
+static size_t brport_get_linkxstats_size(const struct net_device *dev)
+{
+	return nla_total_size(0);
+}
+
+static size_t br_get_linkxstats_size(const struct net_device *dev, int attr)
+{
+	size_t retsize = 0;
+
+	switch (attr) {
+	case IFLA_STATS_LINK_XSTATS:
+		retsize = bridge_get_linkxstats_size(dev);
+		break;
+	case IFLA_STATS_LINK_XSTATS_SLAVE:
+		retsize = brport_get_linkxstats_size(dev);
+		break;
+	}
+
+	return retsize;
+}
+
+static int bridge_fill_linkxstats(struct sk_buff *skb,
+				  const struct net_device *dev,
+				  int *prividx)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_vlan_group *vg;
@@ -1298,6 +1320,37 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static int brport_fill_linkxstats(struct sk_buff *skb,
+				  const struct net_device *dev,
+				  int *prividx)
+{
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, LINK_XSTATS_TYPE_BRIDGE);
+	if (!nest)
+		return -EMSGSIZE;
+	nla_nest_end(skb, nest);
+
+	return 0;
+}
+
+static int br_fill_linkxstats(struct sk_buff *skb, const struct net_device *dev,
+			      int *prividx, int attr)
+{
+	int ret = -EINVAL;
+
+	switch (attr) {
+	case IFLA_STATS_LINK_XSTATS:
+		ret = bridge_fill_linkxstats(skb, dev, prividx);
+		break;
+	case IFLA_STATS_LINK_XSTATS_SLAVE:
+		ret = brport_fill_linkxstats(skb, dev, prividx);
+		break;
+	}
+
+	return ret;
+}
+
 static struct rtnl_af_ops br_af_ops __read_mostly = {
 	.family			= AF_BRIDGE,
 	.get_link_af_size	= br_get_link_af_size_filtered,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eb49ca24274a..cfed7bc14ee6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3519,7 +3519,32 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 			if (!attr)
 				goto nla_put_failure;
 
-			err = ops->fill_linkxstats(skb, dev, prividx);
+			err = ops->fill_linkxstats(skb, dev, prividx, *idxattr);
+			nla_nest_end(skb, attr);
+			if (err)
+				goto nla_put_failure;
+			*idxattr = 0;
+		}
+	}
+
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS_SLAVE,
+			     *idxattr)) {
+		const struct rtnl_link_ops *ops = NULL;
+		const struct net_device *master;
+
+		master = netdev_master_upper_dev_get(dev);
+		if (master)
+			ops = master->rtnl_link_ops;
+		if (ops && ops->fill_linkxstats) {
+			int err;
+
+			*idxattr = IFLA_STATS_LINK_XSTATS_SLAVE;
+			attr = nla_nest_start(skb,
+					      IFLA_STATS_LINK_XSTATS_SLAVE);
+			if (!attr)
+				goto nla_put_failure;
+
+			err = ops->fill_linkxstats(skb, dev, prividx, *idxattr);
 			nla_nest_end(skb, attr);
 			if (err)
 				goto nla_put_failure;
@@ -3555,14 +3580,35 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS, 0)) {
 		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+		int attr = IFLA_STATS_LINK_XSTATS;
 
 		if (ops && ops->get_linkxstats_size) {
-			size += nla_total_size(ops->get_linkxstats_size(dev));
+			size += nla_total_size(ops->get_linkxstats_size(dev,
+									attr));
 			/* for IFLA_STATS_LINK_XSTATS */
 			size += nla_total_size(0);
 		}
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_XSTATS_SLAVE, 0)) {
+		struct net_device *_dev = (struct net_device *)dev;
+		const struct rtnl_link_ops *ops = NULL;
+		const struct net_device *master;
+
+		/* netdev_master_upper_dev_get can't take const */
+		master = netdev_master_upper_dev_get(_dev);
+		if (master)
+			ops = master->rtnl_link_ops;
+		if (ops && ops->get_linkxstats_size) {
+			int attr = IFLA_STATS_LINK_XSTATS_SLAVE;
+
+			size += nla_total_size(ops->get_linkxstats_size(dev,
+									attr));
+			/* for IFLA_STATS_LINK_XSTATS_SLAVE */
+			size += nla_total_size(0);
+		}
+	}
+
 	return size;
 }
 
-- 
2.1.4
