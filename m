From: Greg Rose <gregory.v.rose@intel.com>
Subject: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 12:47:15 -0800
Message-ID: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49034 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755753Ab2BUUrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 15:47:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a new netlink attribute type IFLA_EXT_MASK.  The mask
is a 32 bit value that can be used to indicate to the kernel that
certain extended ifinfo values are requested by the user application.
At this time the only mask value defined is RTEXT_FILTER_VF to
indicate that the user wants the ifinfo dump to send information
about the VFs belonging to the interface.

This patch fixes a bug in which certain applications do not have
large enough buffers to accommodate the extra information returned
by the kernel with large numbers of SR-IOV virtual functions.
Those applications will not send the new netlink attribute with
the interface info dump request netlink messages so they will
not get unexpectedly large request buffers returned by the kernel.

Modifies the rtnl_calcit function to traverse the list of net
devices and compute the minimum buffer size that can hold the
info dumps of all matching devices based upon the filter passed
in via the new netlink attribute filter mask.  If no filter
mask is sent then the buffer allocation defaults to NLMSG_GOODSIZE.

With this change it is possible to add yet to be defined netlink
attributes to the dump request which should make it fairly extensible
in the future.

CC: stable@vger.kernel.org
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/if_link.h   |    1 +
 include/linux/rtnetlink.h |    3 ++
 include/net/rtnetlink.h   |    2 +
 net/core/rtnetlink.c      |   66 ++++++++++++++++++++++++++++++++++-----------
 4 files changed, 55 insertions(+), 17 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 052c240..35357f6 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -137,6 +137,7 @@ enum {
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
 	IFLA_NET_NS_FD,
+	IFLA_EXT_MASK,		/* Extended info mask, VFs, etc */
 	__IFLA_MAX
 };
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 8e872ea..577592e 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -602,6 +602,9 @@ struct tcamsg {
 #define TCA_ACT_TAB 1 /* attr type must be >=1 */	
 #define TCAA_MAX 1
 
+/* New extended info filters for IFLA_EXT_MASK */
+#define RTEXT_FILTER_VF		(1 << 0)
+
 /* End of information exported to user level */
 
 #ifdef __KERNEL__
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 678f1ff..3702939 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -6,7 +6,7 @@
 
 typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *, void *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
-typedef u16 (*rtnl_calcit_func)(struct sk_buff *);
+typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
 
 extern int	__rtnl_register(int protocol, int msgtype,
 				rtnl_doit_func, rtnl_dumpit_func,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4fd78dd..a429ba7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -60,7 +60,6 @@ struct rtnl_link {
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
-static u16 min_ifinfo_dump_size;
 
 void rtnl_lock(void)
 {
@@ -770,7 +769,8 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
-static noinline size_t if_nlmsg_size(const struct net_device *dev)
+static noinline size_t if_nlmsg_size(const struct net_device *dev,
+				     u32 ext_filter_mask)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
@@ -788,8 +788,9 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_MASTER */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
-	       + nla_total_size(4) /* IFLA_NUM_VF */
-	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
+	       + nla_total_size(ext_filter_mask
+			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
+	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
@@ -872,7 +873,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
 
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
-			    unsigned int flags)
+			    unsigned int flags, u32 ext_filter_mask)
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
@@ -1064,6 +1065,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	struct hlist_head *head;
 	struct hlist_node *node;
+	struct nlattr *tb[IFLA_MAX+1];
+	u32 ext_filter_mask = 0;
 
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
@@ -1071,6 +1074,12 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 	cb->seq = net->dev_base_seq;
 
+	nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
+		    ifla_policy);
+
+	if (tb[IFLA_EXT_MASK])
+		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
@@ -1080,7 +1089,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
 					     NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq, 0,
-					     NLM_F_MULTI) <= 0)
+					     NLM_F_MULTI,
+					     ext_filter_mask) <= 0)
 				goto out;
 
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
@@ -1116,6 +1126,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
+	[IFLA_EXT_MASK]		= { .type = NLA_U32 },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1541,8 +1552,6 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-	min_ifinfo_dump_size = max_t(u16, if_nlmsg_size(dev),
-				     min_ifinfo_dump_size);
 
 	return err;
 }
@@ -1874,6 +1883,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	struct net_device *dev = NULL;
 	struct sk_buff *nskb;
 	int err;
+	u32 ext_filter_mask = 0;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
@@ -1882,6 +1892,9 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	if (tb[IFLA_IFNAME])
 		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
 
+	if (tb[IFLA_EXT_MASK])
+		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+
 	ifm = nlmsg_data(nlh);
 	if (ifm->ifi_index > 0)
 		dev = __dev_get_by_index(net, ifm->ifi_index);
@@ -1893,12 +1906,12 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	if (dev == NULL)
 		return -ENODEV;
 
-	nskb = nlmsg_new(if_nlmsg_size(dev), GFP_KERNEL);
+	nskb = nlmsg_new(if_nlmsg_size(dev, ext_filter_mask), GFP_KERNEL);
 	if (nskb == NULL)
 		return -ENOBUFS;
 
 	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).pid,
-			       nlh->nlmsg_seq, 0, 0);
+			       nlh->nlmsg_seq, 0, 0, ext_filter_mask);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -1909,8 +1922,31 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	return err;
 }
 
-static u16 rtnl_calcit(struct sk_buff *skb)
+static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	struct nlattr *tb[IFLA_MAX+1];
+	u32 ext_filter_mask = 0;
+	u16 min_ifinfo_dump_size = 0;
+
+	nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX, ifla_policy);
+
+	if (tb[IFLA_EXT_MASK])
+		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+
+	if (!ext_filter_mask)
+		return NLMSG_GOODSIZE;
+	/*
+	 * traverse the list of net devices and compute the minimum
+	 * buffer size based upon the filter mask.
+	 */
+	list_for_each_entry_rcu(dev, &net->dev_base_head, dev_list) {
+		min_ifinfo_dump_size = max_t(u16, min_ifinfo_dump_size,
+					     if_nlmsg_size(dev,
+						           ext_filter_mask));
+	}
+
 	return min_ifinfo_dump_size;
 }
 
@@ -1945,13 +1981,11 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 	int err = -ENOBUFS;
 	size_t if_info_size;
 
-	skb = nlmsg_new((if_info_size = if_nlmsg_size(dev)), GFP_KERNEL);
+	skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
-	min_ifinfo_dump_size = max_t(u16, if_info_size, min_ifinfo_dump_size);
-
-	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0);
+	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -2009,7 +2043,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			return -EOPNOTSUPP;
 		calcit = rtnl_get_calcit(family, type);
 		if (calcit)
-			min_dump_alloc = calcit(skb);
+			min_dump_alloc = calcit(skb, nlh);
 
 		__rtnl_unlock();
 		rtnl = net->rtnl;
