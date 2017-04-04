From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net-next 2/2] rtnl: Add support for netdev event to link messages
Date: Tue,  4 Apr 2017 09:23:42 -0400
Message-ID: <1491312223-18772-3-git-send-email-vyasevic@redhat.com>
References: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34719 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753605AbdDDNYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 09:24:25 -0400
Received: by mail-qt0-f196.google.com with SMTP id x35so23119559qtc.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 06:24:24 -0700 (PDT)
In-Reply-To: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When netdev events happen, a rtnetlink_event() handler will send
messages for every event in it's white list.  These messages contain
current information about a particular device, but they do not include
the iformation about which event just happened.  The consumer of
the message has to try to infer this information.  In some cases
(ex: NETDEV_NOTIFY_PEERS), that is not possible.

This patch adds a new extension to RTM_NEWLINK message called IFLA_EVENT
that would have an encoding of the which event triggered this
message.  This would allow the the message consumer to easily determine
if it is interested in a particular event or not.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
V2: Added support for 2 missed event types.

 include/linux/rtnetlink.h    |  3 +-
 include/uapi/linux/if_link.h | 21 ++++++++++
 net/core/dev.c               |  2 +-
 net/core/rtnetlink.c         | 92 +++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 107 insertions(+), 11 deletions(-)

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
index 320fc1e..e4a85cb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_EVENT,
 	__IFLA_MAX
 };
 
@@ -892,4 +893,24 @@ enum {
 
 #define IFLA_XDP_MAX (__IFLA_XDP_MAX - 1)
 
+enum {
+	IFLA_EVENT_UNSPEC,
+	IFLA_EVENT_REBOOT,
+	IFLA_EVENT_CHANGE_MTU,
+	IFLA_EVENT_CHANGE_ADDR,
+	IFLA_EVENT_CHANGE_NAME,
+	IFLA_EVENT_FEAT_CHANGE,
+	IFLA_EVENT_BONDING_FAILOVER,
+	IFLA_EVENT_POST_TYPE_CHANGE,
+	IFLA_EVENT_NOTIFY_PEERS,
+	IFLA_EVENT_CHANGE_UPPER,
+	IFLA_EVENT_RESEND_IGMP,
+	IFLA_EVENT_PRE_CHANGE_MTU,
+	IFLA_EVENT_CHANGE_INFO_DATA,
+	IFLA_EVENT_PRE_CHANGE_UPPER,
+	IFLA_EVENT_CHANGE_LOWER_STATE,
+	IFLA_EVENT_UDP_TUNNEL_PUSH_INFO,
+	IFLA_EVENT_CHANGE_TX_QUEUE_LEN,
+};
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index ef9fe60e..7efb417 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6840,7 +6840,7 @@ static void rollback_registered_many(struct list_head *head)
 
 		if (!dev->rtnl_link_ops ||
 		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U,
+			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U, 0,
 						     GFP_KERNEL);
 
 		/*
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 58419da..b2bd4c9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -944,6 +944,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + rtnl_xdp_size(dev) /* IFLA_XDP */
+	       + nla_total_size(4)  /* IFLA_EVENT */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
@@ -1276,9 +1277,70 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
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
+	case NETDEV_CHANGEMTU:
+		rtnl_event = IFLA_EVENT_CHANGE_MTU;
+		break;
+	case NETDEV_CHANGEADDR:
+		rtnl_event = IFLA_EVENT_CHANGE_ADDR;
+		break;
+	case NETDEV_CHANGENAME:
+		rtnl_event = IFLA_EVENT_CHANGE_NAME;
+		break;
+	case NETDEV_FEAT_CHANGE:
+		rtnl_event = IFLA_EVENT_FEAT_CHANGE;
+		break;
+	case NETDEV_BONDING_FAILOVER:
+		rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
+		break;
+	case NETDEV_POST_TYPE_CHANGE:
+		rtnl_event = IFLA_EVENT_POST_TYPE_CHANGE;
+		break;
+	case NETDEV_NOTIFY_PEERS:
+		rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
+		break;
+	case NETDEV_CHANGEUPPER:
+		rtnl_event = IFLA_EVENT_CHANGE_UPPER;
+		break;
+	case NETDEV_RESEND_IGMP:
+		rtnl_event = IFLA_EVENT_RESEND_IGMP;
+		break;
+	case NETDEV_PRECHANGEMTU:
+		rtnl_event = IFLA_EVENT_PRE_CHANGE_MTU;
+		break;
+	case NETDEV_CHANGEINFODATA:
+		rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
+		break;
+	case NETDEV_PRECHANGEUPPER:
+		rtnl_event = IFLA_EVENT_PRE_CHANGE_UPPER;
+		break;
+	case NETDEV_CHANGELOWERSTATE:
+		rtnl_event = IFLA_EVENT_CHANGE_LOWER_STATE;
+		break;
+	case NETDEV_UDP_TUNNEL_PUSH_INFO:
+		rtnl_event = IFLA_EVENT_UDP_TUNNEL_PUSH_INFO;
+		break;
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		rtnl_event = IFLA_EVENT_CHANGE_TX_QUEUE_LEN;
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
@@ -1327,6 +1389,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
 		goto nla_put_failure;
 
+	if (rtnl_fill_link_event(skb, event))
+		goto nla_put_failure;
+
 	if (rtnl_fill_link_ifmap(skb, dev))
 		goto nla_put_failure;
 
@@ -1461,6 +1526,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
 	[IFLA_XDP]		= { .type = NLA_NESTED },
+	[IFLA_EVENT]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1619,7 +1685,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, 0,
 					       flags,
-					       ext_filter_mask);
+					       ext_filter_mask, 0);
 			/* If we ran out of room on the first message,
 			 * we're in trouble
 			 */
@@ -2710,7 +2776,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
 		return -ENOBUFS;
 
 	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).portid,
-			       nlh->nlmsg_seq, 0, 0, ext_filter_mask);
+			       nlh->nlmsg_seq, 0, 0, ext_filter_mask, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -2782,7 +2848,8 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 }
 
 struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
-				       unsigned int change, gfp_t flags)
+				       unsigned int change,
+				       unsigned long event, gfp_t flags)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2793,7 +2860,7 @@ struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
 	if (skb == NULL)
 		goto errout;
 
-	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0);
+	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0, 0, event);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -2814,18 +2881,25 @@ void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
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
@@ -4132,7 +4206,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_UDP_TUNNEL_PUSH_INFO:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
+		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, event, GFP_KERNEL);
 		break;
 	default:
 		break;
-- 
2.7.4
