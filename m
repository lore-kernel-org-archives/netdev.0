From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v10 2/3] net: core: Add offload stats to if_stats_msg
Date: Fri, 16 Sep 2016 15:05:37 +0200
Message-ID: <1474031138-2065-3-git-send-email-jiri@resnulli.us>
References: <1474031138-2065-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35797 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765809AbcIPNFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 09:05:45 -0400
Received: by mail-wm0-f68.google.com with SMTP id 133so3689680wmq.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 06:05:44 -0700 (PDT)
In-Reply-To: <1474031138-2065-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a nested attribute of offload stats to if_stats_msg
named IFLA_STATS_LINK_OFFLOAD_XSTATS.
Under it, add SW stats, meaning stats only per packets that went via
slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/if_link.h |   9 ++++
 net/core/rtnetlink.c         | 111 +++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 116 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9bf3aec..2351776 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -826,6 +826,7 @@ enum {
 	IFLA_STATS_LINK_64,
 	IFLA_STATS_LINK_XSTATS,
 	IFLA_STATS_LINK_XSTATS_SLAVE,
+	IFLA_STATS_LINK_OFFLOAD_XSTATS,
 	__IFLA_STATS_MAX,
 };
 
@@ -845,6 +846,14 @@ enum {
 };
 #define LINK_XSTATS_TYPE_MAX (__LINK_XSTATS_TYPE_MAX - 1)
 
+/* These are stats embedded into IFLA_STATS_LINK_OFFLOAD_XSTATS */
+enum {
+	IFLA_OFFLOAD_XSTATS_UNSPEC,
+	IFLA_OFFLOAD_XSTATS_CPU_HIT, /* struct rtnl_link_stats64 */
+	__IFLA_OFFLOAD_XSTATS_MAX
+};
+#define IFLA_OFFLOAD_XSTATS_MAX (__IFLA_OFFLOAD_XSTATS_MAX - 1)
+
 /* XDP section */
 
 enum {
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 937e459..0dbae42 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3577,6 +3577,91 @@ static bool stats_attr_valid(unsigned int mask, int attrid, int idxattr)
 	       (!idxattr || idxattr == attrid);
 }
 
+#define IFLA_OFFLOAD_XSTATS_FIRST (IFLA_OFFLOAD_XSTATS_UNSPEC + 1)
+static int rtnl_get_offload_stats_attr_size(int attr_id)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return sizeof(struct rtnl_link_stats64);
+	}
+
+	return 0;
+}
+
+static int rtnl_get_offload_stats(struct sk_buff *skb, struct net_device *dev,
+				  int *prividx)
+{
+	struct nlattr *attr = NULL;
+	int attr_id, size;
+	void *attr_data;
+	int err;
+
+	if (!(dev->netdev_ops && dev->netdev_ops->ndo_has_offload_stats &&
+	      dev->netdev_ops->ndo_get_offload_stats))
+		return -ENODATA;
+
+	for (attr_id = IFLA_OFFLOAD_XSTATS_FIRST;
+	     attr_id <= IFLA_OFFLOAD_XSTATS_MAX; attr_id++) {
+		if (attr_id < *prividx)
+			continue;
+
+		size = rtnl_get_offload_stats_attr_size(attr_id);
+		if (!size)
+			continue;
+
+		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
+			continue;
+
+		attr = nla_reserve_64bit(skb, attr_id, size,
+					 IFLA_OFFLOAD_XSTATS_UNSPEC);
+		if (!attr)
+			goto nla_put_failure;
+
+		attr_data = nla_data(attr);
+		memset(attr_data, 0, size);
+		err = dev->netdev_ops->ndo_get_offload_stats(attr_id, dev,
+							     attr_data);
+		if (err)
+			goto get_offload_stats_failure;
+	}
+
+	if (!attr)
+		return -ENODATA;
+
+	*prividx = 0;
+	return 0;
+
+nla_put_failure:
+	err = -EMSGSIZE;
+get_offload_stats_failure:
+	*prividx = attr_id;
+	return err;
+}
+
+static int rtnl_get_offload_stats_size(const struct net_device *dev)
+{
+	int nla_size = 0;
+	int attr_id;
+	int size;
+
+	if (!(dev->netdev_ops && dev->netdev_ops->ndo_has_offload_stats &&
+	      dev->netdev_ops->ndo_get_offload_stats))
+		return 0;
+
+	for (attr_id = IFLA_OFFLOAD_XSTATS_FIRST;
+	     attr_id <= IFLA_OFFLOAD_XSTATS_MAX; attr_id++) {
+		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
+			continue;
+		size = rtnl_get_offload_stats_attr_size(attr_id);
+		nla_size += nla_total_size_64bit(size);
+	}
+
+	if (nla_size != 0)
+		nla_size += nla_total_size(0);
+
+	return nla_size;
+}
+
 static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 			       int type, u32 pid, u32 seq, u32 change,
 			       unsigned int flags, unsigned int filter_mask,
@@ -3586,6 +3671,7 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 	struct nlmsghdr *nlh;
 	struct nlattr *attr;
 	int s_prividx = *prividx;
+	int err;
 
 	ASSERT_RTNL();
 
@@ -3614,8 +3700,6 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
 
 		if (ops && ops->fill_linkxstats) {
-			int err;
-
 			*idxattr = IFLA_STATS_LINK_XSTATS;
 			attr = nla_nest_start(skb,
 					      IFLA_STATS_LINK_XSTATS);
@@ -3639,8 +3723,6 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		if (master)
 			ops = master->rtnl_link_ops;
 		if (ops && ops->fill_linkxstats) {
-			int err;
-
 			*idxattr = IFLA_STATS_LINK_XSTATS_SLAVE;
 			attr = nla_nest_start(skb,
 					      IFLA_STATS_LINK_XSTATS_SLAVE);
@@ -3655,6 +3737,24 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS,
+			     *idxattr)) {
+		*idxattr = IFLA_STATS_LINK_OFFLOAD_XSTATS;
+		attr = nla_nest_start(skb, IFLA_STATS_LINK_OFFLOAD_XSTATS);
+		if (!attr)
+			goto nla_put_failure;
+
+		err = rtnl_get_offload_stats(skb, dev, prividx);
+		if (err == -ENODATA)
+			nla_nest_cancel(skb, attr);
+		else
+			nla_nest_end(skb, attr);
+
+		if (err && err != -ENODATA)
+			goto nla_put_failure;
+		*idxattr = 0;
+	}
+
 	nlmsg_end(skb, nlh);
 
 	return 0;
@@ -3708,6 +3808,9 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 		}
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS, 0))
+		size += rtnl_get_offload_stats_size(dev);
+
 	return size;
 }
 
-- 
2.5.5
