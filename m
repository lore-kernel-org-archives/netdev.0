From: jamal <hadi@cyberus.ca>
Subject: PATCH: ioctl send PID in netlink events
Date: Thu, 02 Jun 2005 09:52:29 -0400
Message-ID: <1117720349.6050.59.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Vf8rMgMoYxExZv+wVDZr"
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Vf8rMgMoYxExZv+wVDZr
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


This is where i was trying to get to ;->
This patch is on top of the earlier one i sent for explicit types.
I still have to think about how to best do IPV6 routes as well as ARP
and NDISC. If anyone has suggestions or wants to tackle them let me
know, the v6 route is not going to be a pretty one i think.

cheers,
jamal


This patch ensures that netlink events created as a result of programns
using ioctls (such as ifconfig, route etc) contains the correct PID of
those events.
 
Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca> 



--=-Vf8rMgMoYxExZv+wVDZr
Content-Disposition: attachment; filename=ifconf_pid_p
Content-Type: text/plain; name=ifconf_pid_p; charset=UTF-8
Content-Transfer-Encoding: 7bit

net/core/rtnetlink.c: needs update
net/ipv4/devinet.c: needs update
net/ipv4/fib_semantics.c: needs update
net/ipv6/addrconf.c: needs update
Index: net/core/rtnetlink.c
===================================================================
--- e4f7366a04d973a42a948d3b4175d66e9adf143e/net/core/rtnetlink.c  (mode:100644)
+++ uncommitted/net/core/rtnetlink.c  (mode:100644)
@@ -452,7 +452,7 @@
 	if (!skb)
 		return;
 
-	if (rtnetlink_fill_ifinfo(skb, dev, type, 0, 0, change, 0) < 0) {
+	if (rtnetlink_fill_ifinfo(skb, dev, type, current->pid, 0, change, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
Index: net/ipv4/devinet.c
===================================================================
--- e4f7366a04d973a42a948d3b4175d66e9adf143e/net/ipv4/devinet.c  (mode:100644)
+++ uncommitted/net/ipv4/devinet.c  (mode:100644)
@@ -236,6 +236,7 @@
 	struct in_ifaddr *promote = NULL;
 	struct in_ifaddr *ifa1 = *ifap;
 
+	printk("inet_del_ifa: pid %d\n",current->pid);
 	ASSERT_RTNL();
 
 	/* 1. Deleting primary ifaddr forces deletion all secondaries 
@@ -305,6 +306,7 @@
 
 	ASSERT_RTNL();
 
+	printk("inet_insert_ifa: pid %d\n",current->pid);
 	if (!ifa->ifa_local) {
 		inet_free_ifa(ifa);
 		return 0;
@@ -1112,7 +1114,7 @@
 
 	if (!skb)
 		netlink_set_err(rtnl, 0, RTMGRP_IPV4_IFADDR, ENOBUFS);
-	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
+	else if (inet_fill_ifaddr(skb, ifa, current->pid, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV4_IFADDR, EINVAL);
 	} else {
Index: net/ipv4/fib_semantics.c
===================================================================
--- e4f7366a04d973a42a948d3b4175d66e9adf143e/net/ipv4/fib_semantics.c  (mode:100644)
+++ uncommitted/net/ipv4/fib_semantics.c  (mode:100644)
@@ -276,7 +276,7 @@
 	       struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
 	struct sk_buff *skb;
-	u32 pid = req ? req->pid : 0;
+	u32 pid = req ? req->pid : n->nlmsg_pid;
 	int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
 
 	skb = alloc_skb(size, GFP_KERNEL);
@@ -1035,7 +1035,7 @@
 	}
 
 	nl->nlmsg_flags = NLM_F_REQUEST;
-	nl->nlmsg_pid = 0;
+	nl->nlmsg_pid = current->pid;
 	nl->nlmsg_seq = 0;
 	nl->nlmsg_len = NLMSG_LENGTH(sizeof(*rtm));
 	if (cmd == SIOCDELRT) {
Index: net/ipv6/addrconf.c
===================================================================
--- e4f7366a04d973a42a948d3b4175d66e9adf143e/net/ipv6/addrconf.c  (mode:100644)
+++ uncommitted/net/ipv6/addrconf.c  (mode:100644)
@@ -2872,7 +2872,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFADDR, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
+	if (inet6_fill_ifaddr(skb, ifa, current->pid, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFADDR, EINVAL);
 		return;
@@ -3007,7 +3007,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_ifinfo(skb, idev, 0, 0, event, 0) < 0) {
+	if (inet6_fill_ifinfo(skb, idev, current->pid, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, EINVAL);
 		return;
@@ -3064,7 +3064,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_prefix(skb, idev, pinfo, 0, 0, event, 0) < 0) {
+	if (inet6_fill_prefix(skb, idev, pinfo, current->pid, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, EINVAL);
 		return;

--=-Vf8rMgMoYxExZv+wVDZr--
