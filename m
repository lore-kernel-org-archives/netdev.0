From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH] rtnetlink: Fix problem with buffer allocation
Date: Fri, 10 Feb 2012 07:05:18 -0800
Message-ID: <20120210150518.4002.85507.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63595 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845Ab2BJPFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 10:05:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some application buffers are not large enough to accommodate the extra
information dumped when an interface has many virtual function devices.
This patch modifies the interface information dump code to check the
netlink message header flags field for a filter bit indicating that
the application wishes to see the extended information.  If the bit
is set then a 16K buffer will be allocated.  This is because the
only application that will be using this filter bit is the iproute2
'ip' command which allocates 16K buffers for communication with the
kernel.

Since this is a newly created filter bit we can be sure that no other
library routines or user applications that use the netlink dump feature
will be setting the bit.  So in essence the default kernel filter wil
be "off" as per Dave's request.

Comments have been added to make sure that anyone who uses the new
filter bit to request the extended interface information had better
make sure they've allocated a 16K buffer.

If the user space application has not set the NLM_F_EXT bit in the
netlink message header then the dump buffer size calculation
function rtnl_calcit will return NLMSG_GOODSIZE, which was the default
behavior in the past.

This still leaves open the problem with future SR-IOV devices that will
support as many as 255 virtual functions.  The iproute2 application buffer
is only 16K and will not be sufficient to hold the information for all
255 VFs.  One possible solution would be to use additional flags in the
netlink message header to indicate which "blocks" of VF devices to display.
Since 16K is enough to display 128 VF devices we could use one or two
unused filter bits to indicate "first half" or "second half" of the
extended device information or some such scheme.

>From the looks of it the netlink "GET" Request flags still have 8 unused
bits.  Hopefully that will be enough for future development.  Stephen
Hemminger asked that I not implment a new flag so I've done the best I
can with the flags field already in the netlink message header.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/netlink.h |    7 +++++++
 include/net/rtnetlink.h |    2 +-
 net/core/rtnetlink.c    |   29 +++++++++++++++++------------
 3 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index a390e9d..041aabf 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -59,6 +59,12 @@ struct nlmsghdr {
 #define NLM_F_MATCH	0x200	/* return all matching	*/
 #define NLM_F_ATOMIC	0x400	/* atomic GET		*/
 #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
+/*
+ * Applications that set NLM_F_EXT have allocated
+ * a 16K or larger buffer.
+ * (Or they should have before using this flag)
+ */
+#define NLM_F_EXT	0x800   /* Get extended interface info such as VFs */
 
 /* Modifiers to NEW request */
 #define NLM_F_REPLACE	0x100	/* Override existing		*/
@@ -215,6 +221,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 #else
 #define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
 #endif
+#define NLMSG_EXT_GOODSIZE	SKB_WITH_OVERHEAD(16384UL)
 
 #define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
 
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
index 39aa20b..12b5398 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -60,7 +60,6 @@ struct rtnl_link {
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
-static u16 min_ifinfo_dump_size;
 
 void rtnl_lock(void)
 {
@@ -941,10 +940,11 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
-	if (dev->dev.parent)
+	if (dev->dev.parent && (flags & NLM_F_EXT))
 		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
 
-	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
+	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent
+	    && (flags & NLM_F_EXT)) {
 		int i;
 
 		struct nlattr *vfinfo, *vf;
@@ -1043,11 +1043,13 @@ nla_put_failure:
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
+	struct nlmsghdr *nlh = cb->nlh;
 	int h, s_h;
 	int idx = 0, s_idx;
 	struct net_device *dev;
 	struct hlist_head *head;
 	struct hlist_node *node;
+	unsigned int flags;
 
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
@@ -1061,10 +1063,10 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
+			flags = NLM_F_MULTI | (nlh->nlmsg_flags & NLM_F_EXT);
 			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
 					     NETLINK_CB(cb->skb).pid,
-					     cb->nlh->nlmsg_seq, 0,
-					     NLM_F_MULTI) <= 0)
+					     nlh->nlmsg_seq, 0, flags) <= 0)
 				goto out;
 
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
@@ -1511,8 +1513,6 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-	min_ifinfo_dump_size = max_t(u16, if_nlmsg_size(dev),
-				     min_ifinfo_dump_size);
 
 	return err;
 }
@@ -1879,9 +1879,16 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	return err;
 }
 
-static u16 rtnl_calcit(struct sk_buff *skb)
+static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	return min_ifinfo_dump_size;
+	/*
+	 * Applications should only set NLM_F_EXT if they've allocated
+	 * a 16K or larger buffer.
+	 */
+	if (nlh->nlmsg_flags & NLM_F_EXT)
+		return NLMSG_EXT_GOODSIZE;
+	else
+		return NLMSG_GOODSIZE;
 }
 
 static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1919,8 +1926,6 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 	if (skb == NULL)
 		goto errout;
 
-	min_ifinfo_dump_size = max_t(u16, if_info_size, min_ifinfo_dump_size);
-
 	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
@@ -1979,7 +1984,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			return -EOPNOTSUPP;
 		calcit = rtnl_get_calcit(family, type);
 		if (calcit)
-			min_dump_alloc = calcit(skb);
+			min_dump_alloc = calcit(skb, nlh);
 
 		__rtnl_unlock();
 		rtnl = net->rtnl;
