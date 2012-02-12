From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Sun, 12 Feb 2012 11:13:42 -0800
Message-ID: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14688 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755769Ab2BLTNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Feb 2012 14:13:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a new nlattr type IFLA_EXT_MASK.  The mask is a 32 bit
value that can be used to indicate to the kernel that certain
extended ifinfo values are requested by the user application.
At this time the only mask value created is RTEXT_FILTER_VF to
indicate that the user wants the ifinfo dump to send information
about the VFs belonging to the interface.

I have kept the NLM_F_EXT nlmsg_flags bit to indicate to the kernel
that the extended ifinfo dump filter mask is present.  It does not
act as the filter itself which has changed since the first submission
of this RFC.  Older versions of user applications won't set this
flag which should fix the problem of some applications not allocating
a large enough buffer for all the extended interface information.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/if_link.h   |    1 +
 include/linux/netlink.h   |    2 +
 include/linux/rtnetlink.h |    9 ++++++
 include/net/rtnetlink.h   |    2 +
 net/core/rtnetlink.c      |   73 ++++++++++++++++++++++++++++++++-------------
 5 files changed, 65 insertions(+), 22 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c52d4b5..4b24ff4 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -137,6 +137,7 @@ enum {
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
 	IFLA_NET_NS_FD,
+	IFLA_EXT_MASK,		/* Extended info mask, VFs, etc */
 	__IFLA_MAX
 };
 
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index a390e9d..fe9e938 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -59,6 +59,7 @@ struct nlmsghdr {
 #define NLM_F_MATCH	0x200	/* return all matching	*/
 #define NLM_F_ATOMIC	0x400	/* atomic GET		*/
 #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
+#define NLM_F_EXT	0x800	/* Get extended interface info such as VFs */
 
 /* Modifiers to NEW request */
 #define NLM_F_REPLACE	0x100	/* Override existing		*/
@@ -215,6 +216,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 #else
 #define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
 #endif
+#define NLMSG_EXT_GOODSIZE SKB_WITH_OVERHEAD(32768UL)
 
 #define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 8e872ea..89244b8 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -602,6 +602,15 @@ struct tcamsg {
 #define TCA_ACT_TAB 1 /* attr type must be >=1 */	
 #define TCAA_MAX 1
 
+struct rtnl_req_extended {
+	struct nlmsghdr nlh;
+	struct rtgenmsg g;
+	char ext[RTA_SPACE(sizeof(__u32))];
+};
+
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
index 65aebd4..67f8c95 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -60,7 +60,6 @@ struct rtnl_link {
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
-static u16 min_ifinfo_dump_size;
 
 void rtnl_lock(void)
 {
@@ -724,10 +723,11 @@ static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
 }
 
 /* All VF info */
-static inline int rtnl_vfinfo_size(const struct net_device *dev)
+static inline int rtnl_vfinfo_size(const struct net_device *dev,
+				   u32 ext_filter_mask)
 {
-	if (dev->dev.parent && dev_is_pci(dev->dev.parent)) {
-
+	if (dev->dev.parent && dev_is_pci(dev->dev.parent) &&
+	    (ext_filter_mask & RTEXT_FILTER_VF)) {
 		int num_vfs = dev_num_vf(dev->dev.parent);
 		size_t size = nla_total_size(sizeof(struct nlattr));
 		size += nla_total_size(num_vfs * sizeof(struct nlattr));
@@ -766,7 +766,8 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
-static noinline size_t if_nlmsg_size(const struct net_device *dev)
+static noinline size_t if_nlmsg_size(const struct net_device *dev,
+				     u32 ext_filter_mask)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
@@ -785,7 +786,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_NUM_VF */
-	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
+	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
@@ -868,7 +869,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
 
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
-			    unsigned int flags)
+			    unsigned int flags, u32 ext_filter_mask)
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
@@ -941,10 +942,11 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
-	if (dev->dev.parent)
+	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF))
 		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
 
-	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
+	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent
+	    && (ext_filter_mask & RTEXT_FILTER_VF)) {
 		int i;
 
 		struct nlattr *vfinfo, *vf;
@@ -1048,6 +1050,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	struct hlist_head *head;
 	struct hlist_node *node;
+	struct rtnl_req_extended *req;
+	u32 ext_filter_mask = 0;
 
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
@@ -1055,6 +1059,17 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 	cb->seq = net->dev_base_seq;
 
+	if (cb->nlh->nlmsg_flags && NLM_F_EXT) {
+		struct rtattr *ext_req;
+		u32 *ext_req_data;
+		req = (struct rtnl_req_extended *)cb->nlh;
+		ext_req = (struct rtattr *)&req->ext;
+		if (ext_req->rta_type == IFLA_EXT_MASK) {
+			ext_req_data = RTA_DATA(ext_req);
+			ext_filter_mask = *ext_req_data;
+		}
+	}
+
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
@@ -1064,7 +1079,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
 					     NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq, 0,
-					     NLM_F_MULTI) <= 0)
+					     NLM_F_MULTI,
+					     ext_filter_mask) <= 0)
 				goto out;
 
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
@@ -1100,6 +1116,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
+	[IFLA_EXT_MASK]		= { .type = NLA_U32 },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1509,8 +1526,6 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-	min_ifinfo_dump_size = max_t(u16, if_nlmsg_size(dev),
-				     min_ifinfo_dump_size);
 
 	return err;
 }
@@ -1861,12 +1876,12 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	if (dev == NULL)
 		return -ENODEV;
 
-	nskb = nlmsg_new(if_nlmsg_size(dev), GFP_KERNEL);
+	nskb = nlmsg_new(if_nlmsg_size(dev, 0), GFP_KERNEL);
 	if (nskb == NULL)
 		return -ENOBUFS;
 
 	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).pid,
-			       nlh->nlmsg_seq, 0, 0);
+			       nlh->nlmsg_seq, 0, 0, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -1877,9 +1892,26 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	return err;
 }
 
-static u16 rtnl_calcit(struct sk_buff *skb)
+static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	return min_ifinfo_dump_size;
+	struct rtnl_req_extended *req;
+	u32 ext_filter_mask = 0;
+
+	if (nlh->nlmsg_flags && NLM_F_EXT) {
+		struct rtattr *ext_req;
+		u32 *ext_req_data;
+		req = (struct rtnl_req_extended *)&nlh;
+		ext_req = (struct rtattr *)&req->ext;
+		if (ext_req->rta_type == IFLA_EXT_MASK) {
+			ext_req_data = RTA_DATA(ext_req);
+			ext_filter_mask = *ext_req_data;
+		}
+	}
+
+	if (ext_filter_mask & RTEXT_FILTER_VF)
+		return NLMSG_EXT_GOODSIZE;
+	else
+		return NLMSG_GOODSIZE;
 }
 
 static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1913,13 +1945,11 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
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
@@ -1949,6 +1979,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int type;
 	int err;
 
+
 	type = nlh->nlmsg_type;
 	if (type > RTM_MAX)
 		return -EOPNOTSUPP;
@@ -1977,7 +2008,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			return -EOPNOTSUPP;
 		calcit = rtnl_get_calcit(family, type);
 		if (calcit)
-			min_dump_alloc = calcit(skb);
+			min_dump_alloc = calcit(skb, nlh);
 
 		__rtnl_unlock();
 		rtnl = net->rtnl;
