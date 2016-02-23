From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next RFC] rtnetlink: add new RTM_GETSTATS to dump link stats
Date: Mon, 22 Feb 2016 22:01:33 -0800
Message-ID: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34894 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171AbcBWGBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 01:01:39 -0500
Received: by mail-pa0-f50.google.com with SMTP id ho8so107224641pac.2
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 22:01:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds a new RTM_GETSTATS message to query link stats via netlink
from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK returns a
lot more than just stats and is expensive in some cases when frequent
polling for stats from userspace is a common operation.

RTM_GETSTATS is an attempt to provide a light weight netlink message
to explicity query only link stats from the kernel on an interface.
The idea is to also keep it extensible so that new kinds of stats can be
added to it in the future.

To begin with, this patch adds the following types of stats (which are
also available via RTM_NEWLINK today):

struct nla_policy ifla_stats_policy[IFLA_LINK_STATS_MAX + 1] = {
        [IFLA_LINK_STATS]       = { .len = sizeof(struct rtnl_link_stats) },
        [IFLA_LINK_STATS64]     = { .len = sizeof(struct rtnl_link_stats64) },
        [IFLA_LINK_INET6_STATS] = {. type = NLA_NESTED },
};

Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
a single interface or all interfaces with NLM_F_DUMP.

Most of the above attributes maintain their current types like 'struct
rtnl_link_stats' because there are many apps today that understand this
format. These attributes can be made nested or new nested quivalents can
be added in the future if the need arises.

Future new types of stat attributes:
- IFLA_LINK_MPLS_STATS  (nested. for mpls/mdev stats)
- IFLA_LINK_EXTENDED_STATS (nested. extended software netdev stats like bridge,
  vlan, vxlan etc)
- IFLA_LINK_EXTENDED_HW_STATS (nested. extended hardware stats which are
  available via ethtool today)

Filtering stats (if the user wanted to query just ipv6 stats ?):
a) I have a version of the patch that uses 'struct ifinfomsg->ifi_family'
as a filter from userspace. But, given that in the future we may want to
not just filter by family, I have dropped it in favor of
attribute filtering (not included in this patch but point b) below).

b) RTM_GETSTATS message to contain attributes in the request message

	nlmsg_parse(nlh, ....IFLA_LINK_STATS_MAX, ifla_stats_policy...)

	if tb[IFLA_LINK_INET6_STATS]
		include ipv6 stats in the dump

	if tb[IFLA_LINK_MPLS_STATS]
		include mpls stats in the dump

This patch has been minimally tested with a patch to iproute2 ifstat.

Jamals original thought at netdev/netconf also had a RTM_NEWSTATS notification
that people can register to for stats updates. This patch does not include those
changes, but those can be added separately.

Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/rtnetlink.h        |   3 +
 include/uapi/linux/if_link.h   |  10 +++
 include/uapi/linux/rtnetlink.h |   6 ++
 net/core/rtnetlink.c           | 164 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c            |  69 +++++++++++++++--
 5 files changed, 244 insertions(+), 8 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 2f87c1b..8892d21 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -131,6 +131,9 @@ struct rtnl_af_ops {
 						    const struct nlattr *attr);
 	int			(*set_link_af)(struct net_device *dev,
 					       const struct nlattr *attr);
+	size_t			(*get_link_af_stats_size)(const struct net_device *dev);
+	int			(*fill_link_af_stats)(struct sk_buff *skb,
+						      const struct net_device *dev);
 };
 
 void __rtnl_af_unregister(struct rtnl_af_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d452cea..3d20091 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -739,4 +739,14 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* STATS section */
+enum {
+	IFLA_LINK_STATS,
+	IFLA_LINK_STATS64,
+	IFLA_LINK_INET6_STATS,
+	__IFLA_LINK_STATS_MAX,
+};
+
+#define IFLA_LINK_STATS_MAX (__IFLA_LINK_STATS_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index ca764b5..be41654 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -139,6 +139,12 @@ enum {
 	RTM_GETNSID = 90,
 #define RTM_GETNSID RTM_GETNSID
 
+	RTM_NEWSTATS = 91,
+#define RTM_NEWSTATS RTM_GETSTATS
+
+	RTM_GETSTATS = 92,
+#define RTM_GETSTATS RTM_GETSTATS
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 62737f4..18af7a1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3413,6 +3413,167 @@ out:
 	return err;
 }
 
+static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
+			       int type, u32 pid, u32 seq, u32 change,
+			       unsigned int flags)
+{
+	struct ifinfomsg *ifm;
+	struct nlmsghdr *nlh;
+	struct rtnl_af_ops *af_ops;
+
+	ASSERT_RTNL();
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ifm = nlmsg_data(nlh);
+	ifm->__ifi_pad = 0;
+	ifm->ifi_index = dev->ifindex;
+
+	if (rtnl_fill_stats(skb, dev))
+		goto nla_put_failure;
+
+	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		if (af_ops->fill_link_af_stats) {
+			int err;
+
+			err = af_ops->fill_link_af_stats(skb, dev);
+			if (err < 0)
+				goto nla_put_failure;
+		}
+	}
+
+	nlmsg_end(skb, nlh);
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static const struct nla_policy ifla_stats_policy[IFLA_LINK_STATS_MAX + 1] = {
+	[IFLA_LINK_STATS]	= { .len = sizeof(struct rtnl_link_stats) },
+	[IFLA_LINK_STATS64]	= { .len = sizeof(struct rtnl_link_stats64) },
+	[IFLA_LINK_INET6_STATS]	= {. type = NLA_NESTED },
+};
+
+static size_t rtnl_link_get_af_stats_size(const struct net_device *dev)
+{
+	struct rtnl_af_ops *af_ops;
+	size_t size;
+
+	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		if (af_ops->get_link_af_stats_size)
+			size += af_ops->get_link_af_stats_size(dev);
+	}
+
+	return size;
+}
+
+static noinline size_t if_nlmsg_stats_size(const struct net_device *dev)
+{
+	return nla_total_size(sizeof(struct rtnl_link_stats))
+		+ nla_total_size(sizeof(struct rtnl_link_stats64));
+		+ rtnl_link_get_af_stats_size(dev);
+}
+
+static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ifinfomsg *ifm;
+	struct net_device *dev = NULL;
+	struct sk_buff *nskb;
+	int err;
+
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_index > 0)
+		dev = __dev_get_by_index(net, ifm->ifi_index);
+	else
+		return -EINVAL;
+
+	if (!dev)
+		return -ENODEV;
+
+	nskb = nlmsg_new(if_nlmsg_stats_size(dev), GFP_KERNEL);
+	if (!nskb)
+		return -ENOBUFS;
+
+	err = rtnl_fill_statsinfo(nskb, dev, RTM_NEWSTATS,
+				  NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0, 0);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in if_nlmsg_size */
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
+
+	/* traverse the list of net devices and compute the minimum
+	 * buffer size based upon the filter mask.
+	 */
+	list_for_each_entry(dev, &net->dev_base_head, dev_list) {
+		min_ifinfo_dump_size = max_t(u16, min_ifinfo_dump_size,
+					     if_nlmsg_stats_size(dev));
+	}
+
+	return min_ifinfo_dump_size;
+}
+
+static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	int h, s_h;
+	int idx = 0, s_idx;
+	struct net_device *dev;
+	struct hlist_head *head;
+	unsigned int flags = NLM_F_MULTI;
+	int err;
+
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
+
+	cb->seq = net->dev_base_seq;
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry(dev, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			err = rtnl_fill_statsinfo(skb, dev, RTM_NEWLINK,
+						  NETLINK_CB(cb->skb).portid,
+						  cb->nlh->nlmsg_seq, 0,
+						  flags);
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
@@ -3562,4 +3723,7 @@ void __init rtnetlink_init(void)
 	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
 	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
+
+	rtnl_register(PF_UNSPEC, RTM_GETSTATS, rtnl_stats_get, rtnl_stats_dump,
+		      rtnl_stats_calcit);
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ac0ba9e..a9bbbc2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4786,6 +4786,29 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 	}
 }
 
+static int inet6_fill_ifla6_stats(struct sk_buff *skb,
+				  struct inet6_dev *idev)
+{
+	struct nlattr *nla;
+
+	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
+	if (!nla)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
+
+	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS,
+			  ICMP6_MIB_MAX * sizeof(u64));
+	if (!nla)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS,
+			 nla_len(nla));
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev,
 				  u32 ext_filter_mask)
 {
@@ -4810,15 +4833,8 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev,
 	if (ext_filter_mask & RTEXT_FILTER_SKIP_STATS)
 		return 0;
 
-	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
-	if (!nla)
-		goto nla_put_failure;
-	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
-
-	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS, ICMP6_MIB_MAX * sizeof(u64));
-	if (!nla)
+	if (inet6_fill_ifla6_stats(skb, idev))
 		goto nla_put_failure;
-	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
 
 	nla = nla_reserve(skb, IFLA_INET6_TOKEN, sizeof(struct in6_addr));
 	if (!nla)
@@ -4860,6 +4876,41 @@ static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev,
 	return 0;
 }
 
+static size_t inet6_get_link_af_stats_size(const struct net_device *dev)
+{
+	if (!__in6_dev_get(dev))
+		return 0;
+
+	return nla_total_size(sizeof(struct nlattr)) /* nested IFLA_LINK_INET6_STATS */
+		+ nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
+		+ nla_total_size(ICMP6_MIB_MAX * sizeof(u64));/* IFLA_INET6_ICMP6STATS */
+}
+
+static int inet6_fill_link_af_stats(struct sk_buff *skb,
+				    const struct net_device *dev)
+{
+	struct inet6_dev *idev = __in6_dev_get(dev);
+	struct nlattr *inet6_stats;
+
+	if (!idev)
+		return -ENODATA;
+
+	inet6_stats = nla_nest_start(skb, IFLA_LINK_INET6_STATS);
+	if (!inet6_stats)
+		return -EMSGSIZE;
+
+	if (inet6_fill_ifla6_stats(skb, idev) < 0)
+		goto errout;
+
+	nla_nest_end(skb, inet6_stats);
+
+	return 0;
+errout:
+	nla_nest_cancel(skb, inet6_stats);
+
+	return -EMSGSIZE;
+}
+
 static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 {
 	struct inet6_ifaddr *ifp;
@@ -5946,6 +5997,8 @@ static struct rtnl_af_ops inet6_ops __read_mostly = {
 	.get_link_af_size = inet6_get_link_af_size,
 	.validate_link_af = inet6_validate_link_af,
 	.set_link_af	  = inet6_set_link_af,
+	.get_link_af_stats_size = inet6_get_link_af_stats_size,
+	.fill_link_af_stats = inet6_fill_link_af_stats,
 };
 
 /*
-- 
1.9.1
