From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V5 1/2] rtnl: Add support for netdev event to link messages
Date: Thu, 25 May 2017 11:31:54 -0400
Message-ID: <1495726316-27626-2-git-send-email-vyasevic@redhat.com>
References: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
Cc: dsahern@gmail.com, roopa@cumulusnetworks.com, jiri@resnulli.us,
        vfalico@gmail.com, andy@greyhouse.net,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:32848 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424300AbdEYPcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 11:32:19 -0400
Received: by mail-qt0-f194.google.com with SMTP id a46so30566120qte.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 08:32:18 -0700 (PDT)
In-Reply-To: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
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
index 15ac203..8779ab7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_EVENT,
 	__IFLA_MAX
 };
 
@@ -911,4 +912,14 @@ enum {
 
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
index 3d98fbf..06e0a74 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7084,7 +7084,7 @@ static void rollback_registered_many(struct list_head *head)
 
 		if (!dev->rtnl_link_ops ||
 		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U,
+			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U, 0,
 						     GFP_KERNEL);
 
 		/*
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index dab2834..96eb392 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -941,6 +941,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + rtnl_xdp_size() /* IFLA_XDP */
+	       + nla_total_size(4)  /* IFLA_EVENT */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
@@ -1282,9 +1283,40 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
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
@@ -1333,6 +1365,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
 		goto nla_put_failure;
 
+	if (rtnl_fill_link_event(skb, event))
+		goto nla_put_failure;
+
 	if (rtnl_fill_link_ifmap(skb, dev))
 		goto nla_put_failure;
 
@@ -1467,6 +1502,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
 	[IFLA_XDP]		= { .type = NLA_NESTED },
+	[IFLA_EVENT]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1626,7 +1662,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, 0,
 					       flags,
-					       ext_filter_mask);
+					       ext_filter_mask, 0);
 
 			if (err < 0) {
 				if (likely(skb->len))
@@ -2736,7 +2772,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -ENOBUFS;
 
 	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).portid,
-			       nlh->nlmsg_seq, 0, 0, ext_filter_mask);
+			       nlh->nlmsg_seq, 0, 0, ext_filter_mask, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -2808,7 +2844,8 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 }
 
 struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
-				       unsigned int change, gfp_t flags)
+				       unsigned int change,
+				       unsigned long event, gfp_t flags)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2819,7 +2856,7 @@ struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
 	if (skb == NULL)
 		goto errout;
 
-	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0);
+	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0, event);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -2840,18 +2877,25 @@ void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
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
@@ -4165,7 +4209,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
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
