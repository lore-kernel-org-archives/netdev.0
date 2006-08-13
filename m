From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 01/16] [RTNETLINK]: Use rtnl_unicast() for rtnetlink unicasts
Date: Mon, 14 Aug 2006 00:00:01 +0200
Message-ID: <20060814214339.134019023@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:13262 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964972AbWHNVoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:21 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_unicast
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/linux/rtnetlink.h
===================================================================
--- net-2.6.19.git.orig/include/linux/rtnetlink.h
+++ net-2.6.19.git/include/linux/rtnetlink.h
@@ -584,6 +584,7 @@ struct rtnetlink_link
 
 extern struct rtnetlink_link * rtnetlink_links[NPROTO];
 extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
+extern int rtnl_unicast(struct sk_buff *skb, u32 pid);
 extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 
 extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -166,6 +166,11 @@ int rtnetlink_send(struct sk_buff *skb, 
 	return err;
 }
 
+int rtnl_unicast(struct sk_buff *skb, u32 pid)
+{
+	return nlmsg_unicast(rtnl, skb, pid);
+}
+
 int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 {
 	struct rtattr *mx = (struct rtattr*)skb->tail;
@@ -574,9 +579,7 @@ static int rtnl_getlink(struct sk_buff *
 		goto errout;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
+	err = rtnl_unicast(skb, NETLINK_CB(skb).pid);
 errout:
 	kfree(iw_buf);
 	dev_put(dev);
@@ -825,3 +828,4 @@ EXPORT_SYMBOL(rtnl);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);
 EXPORT_SYMBOL(rtnl_unlock);
+EXPORT_SYMBOL(rtnl_unicast);
Index: net-2.6.19.git/net/decnet/dn_route.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_route.c
+++ net-2.6.19.git/net/decnet/dn_route.c
@@ -1611,9 +1611,7 @@ int dn_cache_getroute(struct sk_buff *in
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-
-	return err;
+	return rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 
 out_free:
 	kfree_skb(skb);
Index: net-2.6.19.git/net/ipv4/ipmr.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/ipmr.c
+++ net-2.6.19.git/net/ipv4/ipmr.c
@@ -312,7 +312,8 @@ static void ipmr_destroy_unres(struct mf
 			e = NLMSG_DATA(nlh);
 			e->error = -ETIMEDOUT;
 			memset(&e->msg, 0, sizeof(e->msg));
-			netlink_unicast(rtnl, skb, NETLINK_CB(skb).dst_pid, MSG_DONTWAIT);
+
+			rtnl_unicast(skb, NETLINK_CB(skb).pid);
 		} else
 			kfree_skb(skb);
 	}
@@ -512,7 +513,6 @@ static void ipmr_cache_resolve(struct mf
 
 	while((skb=__skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (skb->nh.iph->version == 0) {
-			int err;
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
 			if (ipmr_fill_mroute(skb, c, NLMSG_DATA(nlh)) > 0) {
@@ -525,7 +525,8 @@ static void ipmr_cache_resolve(struct mf
 				e->error = -EMSGSIZE;
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
-			err = netlink_unicast(rtnl, skb, NETLINK_CB(skb).dst_pid, MSG_DONTWAIT);
+
+			rtnl_unicast(skb, NETLINK_CB(skb).pid);
 		} else
 			ip_mr_forward(skb, c, 0);
 	}
Index: net-2.6.19.git/net/ipv4/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/route.c
+++ net-2.6.19.git/net/ipv4/route.c
@@ -2809,10 +2809,9 @@ int inet_rtm_getroute(struct sk_buff *in
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
-out:	return err;
+	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
+out:
+	return err;
 
 out_free:
 	kfree_skb(skb);
Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -3268,9 +3268,7 @@ static int inet6_rtm_getaddr(struct sk_b
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
+	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 out:
 	in6_ifa_put(ifa);
 	return err;
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -2040,9 +2040,7 @@ int inet6_rtm_getroute(struct sk_buff *i
 		goto out_free;
 	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
+	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
 out:
 	return err;
 out_free:
Index: net-2.6.19.git/net/sched/act_api.c
===================================================================
--- net-2.6.19.git.orig/net/sched/act_api.c
+++ net-2.6.19.git/net/sched/act_api.c
@@ -459,7 +459,6 @@ static int
 act_get_notify(u32 pid, struct nlmsghdr *n, struct tc_action *a, int event)
 {
 	struct sk_buff *skb;
-	int err = 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
@@ -468,10 +467,8 @@ act_get_notify(u32 pid, struct nlmsghdr 
 		kfree_skb(skb);
 		return -EINVAL;
 	}
-	err = netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
-	if (err > 0)
-		err = 0;
-	return err;
+
+	return rtnl_unicast(skb, pid);
 }
 
 static struct tc_action *

