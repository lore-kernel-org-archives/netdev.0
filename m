From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 07/16] [IPv4] address: Convert address notification to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:07 +0200
Message-ID: <20060814214341.215063778@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:20174 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964983AbWHNVow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:52 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_ip4_addr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds support for NLM_F_ECHO allowing applications to easly
see which address have been deleted, added, or promoted.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/devinet.c
+++ net-2.6.19.git/net/ipv4/devinet.c
@@ -88,7 +88,7 @@ static struct nla_policy ifa_ipv4_policy
 	[IFA_LABEL]     	= { .type = NLA_STRING },
 };
 
-static void rtmsg_ifa(int event, struct in_ifaddr *);
+static void rtmsg_ifa(int event, struct in_ifaddr *, struct nlmsghdr *, u32);
 
 static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
@@ -239,8 +239,8 @@ int inet_addr_onlink(struct in_device *i
 	return 0;
 }
 
-static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
-			 int destroy)
+static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
+			 int destroy, struct nlmsghdr *nlh, u32 pid)
 {
 	struct in_ifaddr *promote = NULL;
 	struct in_ifaddr *ifa, *ifa1 = *ifap;
@@ -273,7 +273,7 @@ static void inet_del_ifa(struct in_devic
 			if (!do_promote) {
 				*ifap1 = ifa->ifa_next;
 
-				rtmsg_ifa(RTM_DELADDR, ifa);
+				rtmsg_ifa(RTM_DELADDR, ifa, nlh, pid);
 				blocking_notifier_call_chain(&inetaddr_chain,
 						NETDEV_DOWN, ifa);
 				inet_free_ifa(ifa);
@@ -298,7 +298,7 @@ static void inet_del_ifa(struct in_devic
 	   is valid, it will try to restore deleted routes... Grr.
 	   So that, this order is correct.
 	 */
-	rtmsg_ifa(RTM_DELADDR, ifa1);
+	rtmsg_ifa(RTM_DELADDR, ifa1, nlh, pid);
 	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
 
 	if (promote) {
@@ -310,7 +310,7 @@ static void inet_del_ifa(struct in_devic
 		}
 
 		promote->ifa_flags &= ~IFA_F_SECONDARY;
-		rtmsg_ifa(RTM_NEWADDR, promote);
+		rtmsg_ifa(RTM_NEWADDR, promote, nlh, pid);
 		blocking_notifier_call_chain(&inetaddr_chain,
 				NETDEV_UP, promote);
 		for (ifa = promote->ifa_next; ifa; ifa = ifa->ifa_next) {
@@ -329,7 +329,14 @@ static void inet_del_ifa(struct in_devic
 	}
 }
 
-static int inet_insert_ifa(struct in_ifaddr *ifa)
+static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
+			 int destroy)
+{
+	__inet_del_ifa(in_dev, ifap, destroy, NULL, 0);
+}
+
+static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
+			     u32 pid)
 {
 	struct in_device *in_dev = ifa->ifa_dev;
 	struct in_ifaddr *ifa1, **ifap, **last_primary;
@@ -374,12 +381,17 @@ static int inet_insert_ifa(struct in_ifa
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
 	   listeners of netlink will know about new ifaddr */
-	rtmsg_ifa(RTM_NEWADDR, ifa);
+	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, pid);
 	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
 
 	return 0;
 }
 
+static int inet_insert_ifa(struct in_ifaddr *ifa)
+{
+	return __inet_insert_ifa(ifa, NULL, 0);
+}
+
 static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
 {
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
@@ -466,7 +478,7 @@ static int inet_rtm_deladdr(struct sk_bu
 		    !inet_ifa_match(nla_get_u32(tb[IFA_ADDRESS]), ifa)))
 			continue;
 
-		inet_del_ifa(in_dev, ifap, 1);
+		__inet_del_ifa(in_dev, ifap, 1, nlh, NETLINK_CB(skb).pid);
 		return 0;
 	}
 
@@ -558,7 +570,7 @@ static int inet_rtm_newaddr(struct sk_bu
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
 
-	return inet_insert_ifa(ifa);
+	return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).pid);
 }
 
 /*
@@ -1189,18 +1201,27 @@ done:
 	return skb->len;
 }
 
-static void rtmsg_ifa(int event, struct in_ifaddr* ifa)
+static void rtmsg_ifa(int event, struct in_ifaddr* ifa, struct nlmsghdr *nlh,
+		      u32 pid)
 {
 	struct sk_buff *skb;
+	u32 seq = nlh ? nlh->nlmsg_seq : 0;
+	int err = -ENOBUFS;
 
 	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_IFADDR, ENOBUFS);
-	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
+		goto errout;
+
+	err = inet_fill_ifaddr(skb, ifa, pid, seq, event, 0);
+	if (err < 0) {
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_IFADDR, EINVAL);
-	} else
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_IFADDR, GFP_KERNEL);
+		goto errout;
+	}
+
+	err = rtnl_notify(skb, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(RTNLGRP_IPV4_IFADDR, err);
 }
 
 static struct rtnetlink_link inet_rtnetlink_table[RTM_NR_MSGTYPES] = {

