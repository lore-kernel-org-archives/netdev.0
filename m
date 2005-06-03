From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: ioctl send PID in netlink events
Date: Thu, 02 Jun 2005 23:32:55 -0400
Message-ID: <1117769575.6095.91.camel@localhost.localdomain>
References: <1117720349.6050.59.camel@localhost.localdomain>
	 <20050603010059.GU15391@postel.suug.ch>
	 <1117762655.6095.3.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Ufypw+g9dyMzRlXKv19C"
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1117762655.6095.3.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Ufypw+g9dyMzRlXKv19C
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave,

If you havent applied that patch to net-2.6.13 heres one that removes
those extrenous printks.

On Thu, 2005-02-06 at 21:37 -0400, jamal wrote:

> The second one could probably use the new macros.
> Maybe i will wait until Dave puts this in his tree and send a small
> change; else you could send it.
> 

Actually cant be done, sorry i lied ;->

cheers,
jamal

--=-Ufypw+g9dyMzRlXKv19C
Content-Disposition: attachment; filename=ifconf-2
Content-Type: text/plain; name=ifconf-2; charset=utf-8
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
@@ -1112,7 +1112,7 @@
 
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

--=-Ufypw+g9dyMzRlXKv19C--
