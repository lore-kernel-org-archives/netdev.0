From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V3 net-next 1/2] rtnl: Add support for netdev event to link messages
Date: Fri,  5 May 2017 16:52:48 -0400
Message-ID: <1494017569-12869-2-git-send-email-vyasevic@redhat.com>
References: <1494017569-12869-1-git-send-email-vyasevic@redhat.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        jiri@resnulli.us, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33050 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752530AbdEEUxC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 16:53:02 -0400
Received: by mail-qk0-f195.google.com with SMTP id o85so2512308qkh.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 13:53:01 -0700 (PDT)
In-Reply-To: <1494017569-12869-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When netdev events happen, a rtnetlink_event() handler will send
messages for every event in it's white list.  These messages contain
current information about a particular device, but they do not include
the iformation about which event just happened.  So, it is impossible
to tell what just happend for these events.

This patch adds a new extension to RTM_NEWLINK message called IFLA_EVENT
that would have an encoding of event that triggered this
message.  This would allow the the message consumer to easily determine
if it needs to perform certain actions.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/rtnetlink.h    |  3 ++-
 include/uapi/linux/if_link.h | 11 ++++++++
 net/core/dev.c               |  2 +-
 net/core/rtnetlink.c         | 62 +++++++++++++++++++++++++++++++++++++-------
 4 files changed, 67 insertions(+), 11 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 57e5484..0459018 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -18,7 +18,8 @@ extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change, gfp_t flags);
 struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
-				       unsigned change, gfp_t flags);
+				       unsigned change, unsigned long event,
+				       gfp_t flags);
 void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev,
 		       gfp_t flags);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8e56ac7..0d4501e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_EVENT,
 	__IFLA_MAX
 };
 
@@ -902,4 +903,14 @@ enum {
 
 #define IFLA_XDP_MAX (__IFLA_XDP_MAX - 1)
 
+enum {
+	IFLA_EVENT_UNSPEC,
+	IFLA_EVENT_REBOOT,
+	IFLA_EVENT_FEAT_CHANGE,
+	IFLA_EVENT_BONDING_FAILOVER,
+	IFLA_EVENT_NOTIFY_PEERS,
+	IFLA_EVENT_RESEND_IGMP,
+	IFLA_EVENT_CHANGE_INFO_DATA,
+};
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index d07aa5f..e111521 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6988,7 +6988,7 @@ static void rollback_registered_many(struct list_head *head)
 
 		if (!dev->rtnl_link_ops ||
 		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U,
+			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U, 0,
 						     GFP_KERNEL);
 
 		/*
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6e67315..43d2223 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -942,6 +942,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + rtnl_xdp_size() /* IFLA_XDP */
+	       + nla_total_size(4)  /* IFLA_EVENT */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
@@ -1286,9 +1287,40 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 	return err;
 }
 
+static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
+{
+	u32 rtnl_event;
+
+	switch (event) {
+	case NETDEV_REBOOT:
+		rtnl_event = IFLA_EVENT_REBOOT;
+		break;
+	case NETDEV_FEAT_CHANGE:
+		rtnl_event = IFLA_EVENT_FEAT_CHANGE;
+		break;
+	case NETDEV_BONDING_FAILOVER:
+		rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
+		break;
+	case NETDEV_NOTIFY_PEERS:
+		rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
+		break;
+	case NETDEV_RESEND_IGMP:
+		rtnl_event = IFLA_EVENT_RESEND_IGMP;
+		break;
+	case NETDEV_CHANGEINFODATA:
+		rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
+		break;
+	default:
+		return 0;
+	}
+
+	return nla_put_u32(skb, IFLA_EVENT, rtnl_event);
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
-			    unsigned int flags, u32 ext_filter_mask)
+			    unsigned int flags, u32 ext_filter_mask,
+			    unsigned long event)
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
@@ -1337,6 +1369,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
 		goto nla_put_failure;
 
+	if (rtnl_fill_link_event(skb, event))
+		goto nla_put_failure;
+
 	if (rtnl_fill_link_ifmap(skb, dev))
 		goto nla_put_failure;
 
@@ -1471,6 +1506,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
 	[IFLA_XDP]		= { .type = NLA_NESTED },
+	[IFLA_EVENT]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1630,7 +1666,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, 0,
 					       flags,
-					       ext_filter_mask);
+					       ext_filter_mask, 0);
 			/* If we ran out of room on the first message,
 			 * we're in trouble
 			 */
@@ -2733,7 +2769,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -ENOBUFS;
 
 	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).portid,
-			       nlh->nlmsg_seq, 0, 0, ext_filter_mask);
+			       nlh->nlmsg_seq, 0, 0, ext_filter_mask, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -2805,7 +2841,8 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 }
 
 struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
-				       unsigned int change, gfp_t flags)
+				       unsigned int change,
+				       unsigned long event, gfp_t flags)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2816,7 +2853,7 @@ struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
 	if (skb == NULL)
 		goto errout;
 
-	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0);
+	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0, event);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -2837,18 +2874,25 @@ void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
 	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
 }
 
-void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
-		  gfp_t flags)
+static void rtmsg_ifinfo_event(int type, struct net_device *dev,
+			       unsigned int change, unsigned long event,
+			       gfp_t flags)
 {
 	struct sk_buff *skb;
 
 	if (dev->reg_state != NETREG_REGISTERED)
 		return;
 
-	skb = rtmsg_ifinfo_build_skb(type, dev, change, flags);
+	skb = rtmsg_ifinfo_build_skb(type, dev, change, event, flags);
 	if (skb)
 		rtmsg_ifinfo_send(skb, dev, flags);
 }
+
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
+		  gfp_t flags)
+{
+	rtmsg_ifinfo_event(type, dev, change, 0, flags);
+}
 EXPORT_SYMBOL(rtmsg_ifinfo);
 
 static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
@@ -4152,7 +4196,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
+		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, event, GFP_KERNEL);
 		break;
 	default:
 		break;
-- 
2.7.4
