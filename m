From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] dev: advertise the new nsid when the netns iface changes
Date: Tue,  3 Oct 2017 13:53:23 +0200
Message-ID: <20171003115323.21388-1-nicolas.dichtel@6wind.com>
References: <52f84baf-8027-d01f-8ece-db4f39a2f76f@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "Jason A . Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:36022 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751684AbdJCMAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 08:00:10 -0400
In-Reply-To: <52f84baf-8027-d01f-8ece-db4f39a2f76f@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x-netns interfaces are bound to two netns: the link netns and the upper
netns. Usually, this kind of interfaces is created in the link netns and
then moved to the upper netns. At the end, the interface is visible only
in the upper netns. The link nsid is advertised via netlink in the upper
netns, thus the user always knows where is the link part.

There is no such mechanism in the link netns. When the interface is moved
to another netns, the user cannot "follow" it.
This patch adds a new netlink attribute which helps to follow an interface
which moves to another netns. When the interface is unregistered, the new
nsid is advertised. If the interface is a x-netns interface (ie
rtnl_link_ops->get_link_net is defined), the nsid is allocated if needed.

CC: Jason A. Donenfeld <Jason@zx2c4.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/rtnetlink.h    |  4 +++-
 include/uapi/linux/if_link.h |  1 +
 net/core/dev.c               | 11 ++++++++---
 net/core/rtnetlink.c         | 31 ++++++++++++++++++++++---------
 4 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index dea59c8eec54..1251638e60d3 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -17,9 +17,11 @@ extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 			      u32 id, long expires, u32 error);
 
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change, gfp_t flags);
+void rtmsg_ifinfo_newnet(int type, struct net_device *dev, unsigned int change,
+			 gfp_t flags, int *new_nsid);
 struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
 				       unsigned change, u32 event,
-				       gfp_t flags);
+				       gfp_t flags, int *new_nsid);
 void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev,
 		       gfp_t flags);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ea87bd708ee9..cd580fc0e58f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -158,6 +158,7 @@ enum {
 	IFLA_PAD,
 	IFLA_XDP,
 	IFLA_EVENT,
+	IFLA_NEW_NETNSID,
 	__IFLA_MAX
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index e350c768d4b5..2341e9d64e02 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -145,6 +145,7 @@
 #include <linux/crash_dump.h>
 #include <linux/sctp.h>
 #include <net/udp_tunnel.h>
+#include <linux/net_namespace.h>
 
 #include "net-sysfs.h"
 
@@ -7178,7 +7179,7 @@ static void rollback_registered_many(struct list_head *head)
 		if (!dev->rtnl_link_ops ||
 		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
 			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U, 0,
-						     GFP_KERNEL);
+						     GFP_KERNEL, NULL);
 
 		/*
 		 *	Flush the unicast and multicast chains
@@ -8265,7 +8266,7 @@ EXPORT_SYMBOL(unregister_netdev);
 
 int dev_change_net_namespace(struct net_device *dev, struct net *net, const char *pat)
 {
-	int err;
+	int err, new_nsid;
 
 	ASSERT_RTNL();
 
@@ -8321,7 +8322,11 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 	rcu_barrier();
 	call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
-	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
+	if (dev->rtnl_link_ops && dev->rtnl_link_ops->get_link_net)
+		new_nsid = peernet2id_alloc(dev_net(dev), net);
+	else
+		new_nsid = peernet2id(dev_net(dev), net);
+	rtmsg_ifinfo_newnet(RTM_DELLINK, dev, ~0U, GFP_KERNEL, &new_nsid);
 
 	/*
 	 *	Flush the unicast and multicast chains
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e6955da0d58d..5bec24c348bf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -927,6 +927,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + rtnl_xdp_size() /* IFLA_XDP */
 	       + nla_total_size(4)  /* IFLA_EVENT */
+	       + nla_total_size(4)  /* IFLA_NEW_NETNSID */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
@@ -1386,7 +1387,7 @@ static int rtnl_fill_link_netnsid(struct sk_buff *skb,
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
-			    u32 event)
+			    u32 event, int *new_nsid)
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
@@ -1475,6 +1476,10 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_fill_link_netnsid(skb, dev))
 		goto nla_put_failure;
 
+	if (new_nsid &&
+	    nla_put_s32(skb, IFLA_NEW_NETNSID, *new_nsid) < 0)
+		goto nla_put_failure;
+
 	if (!(af_spec = nla_nest_start(skb, IFLA_AF_SPEC)))
 		goto nla_put_failure;
 
@@ -1704,7 +1709,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, 0,
 					       flags,
-					       ext_filter_mask, 0);
+					       ext_filter_mask, 0, NULL);
 
 			if (err < 0) {
 				if (likely(skb->len))
@@ -2817,7 +2822,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -ENOBUFS;
 
 	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).portid,
-			       nlh->nlmsg_seq, 0, 0, ext_filter_mask, 0);
+			       nlh->nlmsg_seq, 0, 0, ext_filter_mask, 0, NULL);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -2902,7 +2907,7 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 
 struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
 				       unsigned int change,
-				       u32 event, gfp_t flags)
+				       u32 event, gfp_t flags, int *new_nsid)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2913,7 +2918,8 @@ struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
 	if (skb == NULL)
 		goto errout;
 
-	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0, event);
+	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0, event,
+			       new_nsid);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -2936,14 +2942,14 @@ void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
 
 static void rtmsg_ifinfo_event(int type, struct net_device *dev,
 			       unsigned int change, u32 event,
-			       gfp_t flags)
+			       gfp_t flags, int *new_nsid)
 {
 	struct sk_buff *skb;
 
 	if (dev->reg_state != NETREG_REGISTERED)
 		return;
 
-	skb = rtmsg_ifinfo_build_skb(type, dev, change, event, flags);
+	skb = rtmsg_ifinfo_build_skb(type, dev, change, event, flags, new_nsid);
 	if (skb)
 		rtmsg_ifinfo_send(skb, dev, flags);
 }
@@ -2951,10 +2957,17 @@ static void rtmsg_ifinfo_event(int type, struct net_device *dev,
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
 		  gfp_t flags)
 {
-	rtmsg_ifinfo_event(type, dev, change, rtnl_get_event(0), flags);
+	rtmsg_ifinfo_event(type, dev, change, rtnl_get_event(0), flags, NULL);
 }
 EXPORT_SYMBOL(rtmsg_ifinfo);
 
+void rtmsg_ifinfo_newnet(int type, struct net_device *dev, unsigned int change,
+			 gfp_t flags, int *new_nsid)
+{
+	rtmsg_ifinfo_event(type, dev, change, rtnl_get_event(0), flags,
+			   new_nsid);
+}
+
 static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 				   struct net_device *dev,
 				   u8 *addr, u16 vid, u32 pid, u32 seq,
@@ -4330,7 +4343,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
 		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, rtnl_get_event(event),
-				   GFP_KERNEL);
+				   GFP_KERNEL, NULL);
 		break;
 	default:
 		break;
-- 
2.13.2
