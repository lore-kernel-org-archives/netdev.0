From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to dump link stats
Date: Mon, 18 Apr 2016 14:10:19 -0700
Message-ID: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, davem@davemloft.net, tgraf@suug.ch,
	nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35129 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbcDRVKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 17:10:24 -0400
Received: by mail-pa0-f47.google.com with SMTP id fs9so63750176pac.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 14:10:24 -0700 (PDT)
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
        [IFLA_STATS_LINK_64]  = { .len = sizeof(struct rtnl_link_stats64) },
};

Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
a single interface or all interfaces with NLM_F_DUMP.

Future possible new types of stat attributes:
link af stats:
    - IFLA_STATS_LINK_IPV6  (nested. for ipv6 stats)
    - IFLA_STATS_LINK_MPLS  (nested. for mpls/mdev stats)
extended stats:
    - IFLA_STATS_LINK_EXTENDED (nested. extended software netdev stats like bridge,
      vlan, vxlan etc)
    - IFLA_STATS_LINK_HW_EXTENDED (nested. extended hardware stats which are
      available via ethtool today)

This patch also declares a filter mask for all stat attributes.
User has to provide a mask of stats attributes to query. filter mask
can be specified in the new hdr 'struct if_stats_msg' for stats messages.
Other important field in the header is the ifindex.

This api can also include attributes for global stats (eg tcp) in the future.
When global stats are included in a stats msg, the ifindex in the header
must be zero. A single stats message cannot contain both global and
netdev specific stats. To easily distinguish them, netdev specific stat
attributes name are prefixed with IFLA_STATS_LINK_

Without any attributes in the filter_mask, no stats will be returned.

This patch has been tested with mofified iproute2 ifstat.

Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
RFC to v1 (apologies for the delay in sending this version out. busy days):
        - Addressed feedback from Dave
                - removed rtnl_link_stats
                - Added hdr struct if_stats_msg to carry ifindex and
                  filter mask
                - new macro IFLA_STATS_FILTER_BIT(ATTR) for filter mask
        - split the ipv6 patch into a separate patch, need some more eyes on it
        - prefix attributes with IFLA_STATS instead of IFLA_LINK_STATS for
          shorter attribute names

v2:
        - move IFLA_STATS_INET6 declaration to the inet6 patch
        - get rid of RTM_DELSTATS
        - mark ipv6 patch RFC. It can be used as an example for
          other AF stats like stats

v3:
        - add required padding to the if_stats_msg structure(suggested by jamal)
        - rename netdev stat attributes with IFLA_STATS_LINK prefix
          so that they are easily distinguishable with global
          stats in the future (after global stats discussion with thomas)
        - get rid of unnecessary copy when getting stats with dev_get_stats
          (suggested by dave)

v4:
        - dropped calcit and af stats from this patch. Will add it
          back when it becomes necessary and with the first af stats
          patch
        - add check for null filter in dump and return -EINVAL:
          this follows rtnl_fdb_dump in returning an error.
          But since netlink_dump does not propagate the error
          to the user, the user will not see an error and
          but will also not see any data. This is consistent with
          other kinds of dumps.

v5:
        - fix selinux nlmsgtab to account for new RTM_*STATS messages

 include/uapi/linux/if_link.h   |  23 +++++++
 include/uapi/linux/rtnetlink.h |   5 ++
 net/core/rtnetlink.c           | 150 +++++++++++++++++++++++++++++++++++++++++
 security/selinux/nlmsgtab.c    |   4 +-
 4 files changed, 181 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bb3a90b..0762f35 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -781,4 +781,27 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* STATS section */
+
+struct if_stats_msg {
+	__u8  family;
+	__u8  pad1;
+	__u16 pad2;
+	__u32 ifindex;
+	__u32 filter_mask;
+};
+
+/* A stats attribute can be netdev specific or a global stat.
+ * For netdev stats, lets use the prefix IFLA_STATS_LINK_*
+ */
+enum {
+	IFLA_STATS_UNSPEC,
+	IFLA_STATS_LINK_64,
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
index a75f7e9..fe35102 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3451,6 +3451,153 @@ out:
 	return err;
 }
 
+static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
+			       int type, u32 pid, u32 seq, u32 change,
+			       unsigned int flags, unsigned int filter_mask)
+{
+	struct if_stats_msg *ifsm;
+	struct nlmsghdr *nlh;
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
+	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64)) {
+		struct rtnl_link_stats64 *sp;
+
+		attr = nla_reserve(skb, IFLA_STATS_LINK_64,
+				   sizeof(struct rtnl_link_stats64));
+		if (!attr)
+			goto nla_put_failure;
+
+		sp = nla_data(attr);
+		dev_get_stats(dev, sp);
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
+	[IFLA_STATS_LINK_64]	= { .len = sizeof(struct rtnl_link_stats64) },
+};
+
+static size_t if_nlmsg_stats_size(const struct net_device *dev,
+				  u32 filter_mask)
+{
+	size_t size = 0;
+
+	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK_64))
+		size += nla_total_size(sizeof(struct rtnl_link_stats64));
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
+	if (!filter_mask)
+		return -EINVAL;
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
@@ -3600,4 +3747,7 @@ void __init rtnetlink_init(void)
 	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
 	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
+
+	rtnl_register(PF_UNSPEC, RTM_GETSTATS, rtnl_stats_get, rtnl_stats_dump,
+		      NULL);
 }
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 8495b93..1714633 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -76,6 +76,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_NEWNSID,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_DELNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_NEWSTATS,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_GETSTATS,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 };
 
 static struct nlmsg_perm nlmsg_tcpdiag_perms[] =
@@ -155,7 +157,7 @@ int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm)
 	switch (sclass) {
 	case SECCLASS_NETLINK_ROUTE_SOCKET:
 		/* RTM_MAX always point to RTM_SETxxxx, ie RTM_NEWxxx + 3 */
-		BUILD_BUG_ON(RTM_MAX != (RTM_NEWNSID + 3));
+		BUILD_BUG_ON(RTM_MAX != (RTM_NEWSTATS + 3));
 		err = nlmsg_perm(nlmsg_type, perm, nlmsg_route_perms,
 				 sizeof(nlmsg_route_perms));
 		break;
-- 
1.9.1
