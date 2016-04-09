From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message to dump link stats
Date: Fri,  8 Apr 2016 23:38:11 -0700
Message-ID: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35399 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbcDIGiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 02:38:17 -0400
Received: by mail-pf0-f170.google.com with SMTP id n1so89002403pfn.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 23:38:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds a new RTM_GETSTATS message to query link stats via netlink
from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
returns a lot more than just stats and is expensive in some cases when
frequent polling for stats from userspace is a common operation.

RTM_GETSTATS is an attempt to provide a light weight netlink message
to explicity query only link stats from the kernel on an interface.
The idea is to also keep it extensible so that new kinds of stats can be
added to it in the future.

This patch adds the following attribute for NETDEV stats:
struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
        [IFLA_STATS_LINK64]  = { .len = sizeof(struct rtnl_link_stats64) },
};

This patch also allows for af family stats (an example af stats for IPV6
is available with the second patch in the series).

Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
a single interface or all interfaces with NLM_F_DUMP.

Future possible new types of stat attributes:
- IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
- IFLA_EXTENDED_STATS (nested. extended software netdev stats like bridge,
  vlan, vxlan etc)
- IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
  available via ethtool today)

This patch also declares a filter mask for all stat attributes.
User has to provide a mask of stats attributes to query. This will be
specified in a new hdr 'struct if_stats_msg' for stats messages.

Without any attributes in the filter_mask, no stats will be returned.

This patch has been tested with mofified iproute2 ifstat.

Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/rtnetlink.h        |   5 ++
 include/uapi/linux/if_link.h   |  18 ++++
 include/uapi/linux/rtnetlink.h |   5 ++
 net/core/rtnetlink.c           | 200 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 228 insertions(+)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 2f87c1b..fa68158 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -131,6 +131,11 @@ struct rtnl_af_ops {
 						    const struct nlattr *attr);
 	int			(*set_link_af)(struct net_device *dev,
 					       const struct nlattr *attr);
+	size_t			(*get_link_af_stats_size)(const struct net_device *dev,
+							  u32 filter_mask);
+	int			(*fill_link_af_stats)(struct sk_buff *skb,
+						      const struct net_device *dev,
+						      u32 filter_mask);
 };
 
 void __rtnl_af_unregister(struct rtnl_af_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9427f17..4cfd029 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -780,4 +780,22 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* STATS section */
+
+struct if_stats_msg {
+	__u8  family;
+	__u32 ifindex;
+	__u32 filter_mask;
+};
+
+enum {
+	IFLA_STATS_UNSPEC,
+	IFLA_STATS_LINK64,
+	__IFLA_STATS_MAX,
+};
+
+#define IFLA_STATS_MAX (__IFLA_STATS_MAX - 1)
+
+#define IFLA_STATS_FILTER_BIT(ATTR)	(1 << (ATTR))
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index ca764b5..cc885c4 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -139,6 +139,11 @@ enum {
 	RTM_GETNSID = 90,
 #define RTM_GETNSID RTM_GETNSID
 
+	RTM_NEWSTATS = 92,
+#define RTM_NEWSTATS RTM_NEWSTATS
+	RTM_GETSTATS = 94,
+#define RTM_GETSTATS RTM_GETSTATS
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a75f7e9..d1fba58 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3451,6 +3451,203 @@ out:
 	return err;
 }
 
+static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
+			       int type, u32 pid, u32 seq, u32 change,
+			       unsigned int flags, unsigned int filter_mask)
+{
+	const struct rtnl_link_stats64 *stats;
+	struct rtnl_link_stats64 temp;
+	struct if_stats_msg *ifsm;
+	struct nlmsghdr *nlh;
+	struct rtnl_af_ops *af_ops;
+	struct nlattr *attr;
+
+	ASSERT_RTNL();
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifsm), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ifsm = nlmsg_data(nlh);
+	ifsm->ifindex = dev->ifindex;
+	ifsm->filter_mask = filter_mask;
+
+	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK64)) {
+		attr = nla_reserve(skb, IFLA_STATS_LINK64,
+				   sizeof(struct rtnl_link_stats64));
+		if (!attr)
+			return -EMSGSIZE;
+
+		stats = dev_get_stats(dev, &temp);
+
+		copy_rtnl_link_stats64(nla_data(attr), stats);
+	}
+
+	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		if (af_ops->fill_link_af_stats) {
+			int err;
+
+			err = af_ops->fill_link_af_stats(skb, dev, filter_mask);
+			if (err < 0)
+				goto nla_put_failure;
+		}
+	}
+
+	nlmsg_end(skb, nlh);
+
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+
+	return -EMSGSIZE;
+}
+
+static const struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
+	[IFLA_STATS_LINK64]	= { .len = sizeof(struct rtnl_link_stats64) },
+};
+
+static size_t rtnl_link_get_af_stats_size(const struct net_device *dev,
+					  u32 filter_mask)
+{
+	struct rtnl_af_ops *af_ops;
+	size_t size = 0;
+
+	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		if (af_ops->get_link_af_stats_size)
+			size += af_ops->get_link_af_stats_size(dev,
+							       filter_mask);
+	}
+
+	return size;
+}
+
+static size_t if_nlmsg_stats_size(const struct net_device *dev,
+				  u32 filter_mask)
+{
+	size_t size = 0;
+
+	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK64))
+		size += nla_total_size(sizeof(struct rtnl_link_stats64));
+
+	size += rtnl_link_get_af_stats_size(dev, filter_mask);
+
+	return size;
+}
+
+static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct net *net = sock_net(skb->sk);
+	struct if_stats_msg *ifsm;
+	struct net_device *dev = NULL;
+	struct sk_buff *nskb;
+	u32 filter_mask;
+	int err;
+
+	ifsm = nlmsg_data(nlh);
+	if (ifsm->ifindex > 0)
+		dev = __dev_get_by_index(net, ifsm->ifindex);
+	else
+		return -EINVAL;
+
+	if (!dev)
+		return -ENODEV;
+
+	filter_mask = ifsm->filter_mask;
+	if (!filter_mask)
+		return -EINVAL;
+
+	nskb = nlmsg_new(if_nlmsg_stats_size(dev, filter_mask), GFP_KERNEL);
+	if (!nskb)
+		return -ENOBUFS;
+
+	err = rtnl_fill_statsinfo(nskb, dev, RTM_NEWSTATS,
+				  NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
+				  0, filter_mask);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in if_nlmsg_stats_size */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(nskb);
+	} else {
+		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
+	}
+
+	return err;
+}
+
+static u16 rtnl_stats_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	u16 min_ifinfo_dump_size = 0;
+	struct if_stats_msg *ifsm;
+	u32 filter_mask;
+
+	ifsm = nlmsg_data(nlh);
+	filter_mask = ifsm->filter_mask;
+
+	/* traverse the list of net devices and compute the minimum
+	 * buffer size based upon the filter mask.
+	 */
+	list_for_each_entry(dev, &net->dev_base_head, dev_list) {
+		min_ifinfo_dump_size = max_t(u16, min_ifinfo_dump_size,
+					     if_nlmsg_stats_size(dev,
+								 filter_mask));
+	}
+
+	return min_ifinfo_dump_size;
+}
+
+static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct if_stats_msg *ifsm;
+	int h, s_h;
+	int idx = 0, s_idx;
+	struct net_device *dev;
+	struct hlist_head *head;
+	unsigned int flags = NLM_F_MULTI;
+	u32 filter_mask = 0;
+	int err;
+
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
+
+	cb->seq = net->dev_base_seq;
+
+	ifsm = nlmsg_data(cb->nlh);
+	filter_mask = ifsm->filter_mask;
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry(dev, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			err = rtnl_fill_statsinfo(skb, dev, RTM_NEWSTATS,
+						  NETLINK_CB(cb->skb).portid,
+						  cb->nlh->nlmsg_seq, 0,
+						  flags, filter_mask);
+			/* If we ran out of room on the first message,
+			 * we're in trouble
+			 */
+			WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
+
+			if (err < 0)
+				goto out;
+
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
+cont:
+			idx++;
+		}
+	}
+out:
+	cb->args[1] = idx;
+	cb->args[0] = h;
+
+	return skb->len;
+}
+
 /* Process one rtnetlink message. */
 
 static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -3600,4 +3797,7 @@ void __init rtnetlink_init(void)
 	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
 	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
+
+	rtnl_register(PF_UNSPEC, RTM_GETSTATS, rtnl_stats_get, rtnl_stats_dump,
+		      rtnl_stats_calcit);
 }
-- 
1.9.1
