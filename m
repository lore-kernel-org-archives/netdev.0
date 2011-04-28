From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: dont hold rtnl mutex during netlink dump
 callbacks
Date: Thu, 28 Apr 2011 10:56:07 +0200
Message-ID: <1303980967.3360.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64178 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274Ab1D1I4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 04:56:13 -0400
Received: by wwa36 with SMTP id 36so2859264wwa.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 01:56:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Four years ago, Patrick made a change to hold rtnl mutex during netlink
dump callbacks.

I believe it was a wrong move. This slows down concurrent dumps, making
good old /proc/net/ files faster than rtnetlink in some situations.

This occurred to me because one "ip link show dev ..." was _very_ slow
on a workload adding/removing network devices in background.

All dump callbacks are able to use RCU locking now, so this patch does
roughly a revert of commits :

1c2d670f366 : [RTNETLINK]: Hold rtnl_mutex during netlink dump callbacks
6313c1e0992 : [RTNETLINK]: Remove unnecessary locking in dump callbacks

This let writers fight for rtnl mutex and readers going full speed.

It also takes care of phonet : phonet_route_get() is now called from rcu
read section. I renamed it to phonet_route_get_rcu()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    2 +-
 net/bridge/br_netlink.c     |    7 ++++---
 net/core/fib_rules.c        |    3 ++-
 net/core/rtnetlink.c        |   12 +++++-------
 net/decnet/dn_dev.c         |   10 ++++++----
 net/ipv6/ip6_fib.c          |    4 +++-
 net/phonet/pn_dev.c         |    6 +-----
 net/phonet/pn_netlink.c     |    4 +++-
 8 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 13649eb..8639de5 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -51,7 +51,7 @@ void phonet_address_notify(int event, struct net_device *dev, u8 addr);
 int phonet_route_add(struct net_device *dev, u8 daddr);
 int phonet_route_del(struct net_device *dev, u8 daddr);
 void rtm_phonet_notify(int event, struct net_device *dev, u8 dst);
-struct net_device *phonet_route_get(struct net *net, u8 daddr);
+struct net_device *phonet_route_get_rcu(struct net *net, u8 daddr);
 struct net_device *phonet_route_output(struct net *net, u8 daddr);
 
 #define PN_NO_ADDR	0xff
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 134a2ff..ffb0dc4 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -120,8 +120,9 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	int idx;
 
 	idx = 0;
-	for_each_netdev(net, dev) {
-		struct net_bridge_port *port = br_port_get_rtnl(dev);
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		struct net_bridge_port *port = br_port_get_rcu(dev);
 
 		/* not a bridge port */
 		if (!port || idx < cb->args[0])
@@ -135,7 +136,7 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 skip:
 		++idx;
 	}
-
+	rcu_read_unlock();
 	cb->args[0] = idx;
 
 	return skb->len;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 8248ebb..3911586 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -590,7 +590,8 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 	int idx = 0;
 	struct fib_rule *rule;
 
-	list_for_each_entry(rule, &ops->rules_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(rule, &ops->rules_list, list) {
 		if (idx < cb->args[1])
 			goto skip;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d7c4bb4..2963312 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1007,10 +1007,11 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
 
+	rcu_read_lock();
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
-		hlist_for_each_entry(dev, node, head, index_hlist) {
+		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
 			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
@@ -1023,6 +1024,7 @@ cont:
 		}
 	}
 out:
+	rcu_read_unlock();
 	cb->args[1] = idx;
 	cb->args[0] = h;
 
@@ -1879,7 +1881,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int min_len;
 	int family;
 	int type;
-	int err;
 
 	type = nlh->nlmsg_type;
 	if (type > RTM_MAX)
@@ -1906,11 +1907,8 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (dumpit == NULL)
 			return -EOPNOTSUPP;
 
-		__rtnl_unlock();
 		rtnl = net->rtnl;
-		err = netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
-		rtnl_lock();
-		return err;
+		return netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
 	}
 
 	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
@@ -1980,7 +1978,7 @@ static int __net_init rtnetlink_net_init(struct net *net)
 {
 	struct sock *sk;
 	sk = netlink_kernel_create(net, NETLINK_ROUTE, RTNLGRP_MAX,
-				   rtnetlink_rcv, &rtnl_mutex, THIS_MODULE);
+				   rtnetlink_rcv, NULL, THIS_MODULE);
 	if (!sk)
 		return -ENOMEM;
 	net->rtnl = sk;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 0dcaa90..404fa15 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -752,7 +752,8 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	skip_naddr = cb->args[1];
 
 	idx = 0;
-	for_each_netdev(&init_net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		if (idx < skip_ndevs)
 			goto cont;
 		else if (idx > skip_ndevs) {
@@ -761,11 +762,11 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 			skip_naddr = 0;
 		}
 
-		if ((dn_db = rtnl_dereference(dev->dn_ptr)) == NULL)
+		if ((dn_db = rcu_dereference(dev->dn_ptr)) == NULL)
 			goto cont;
 
-		for (ifa = rtnl_dereference(dn_db->ifa_list), dn_idx = 0; ifa;
-		     ifa = rtnl_dereference(ifa->ifa_next), dn_idx++) {
+		for (ifa = rcu_dereference(dn_db->ifa_list), dn_idx = 0; ifa;
+		     ifa = rcu_dereference(ifa->ifa_next), dn_idx++) {
 			if (dn_idx < skip_naddr)
 				continue;
 
@@ -778,6 +779,7 @@ cont:
 		idx++;
 	}
 done:
+	rcu_read_unlock();
 	cb->args[0] = idx;
 	cb->args[1] = dn_idx;
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index dd88df0..4076a0b 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -394,10 +394,11 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	arg.net = net;
 	w->args = &arg;
 
+	rcu_read_lock();
 	for (h = s_h; h < FIB6_TABLE_HASHSZ; h++, s_e = 0) {
 		e = 0;
 		head = &net->ipv6.fib_table_hash[h];
-		hlist_for_each_entry(tb, node, head, tb6_hlist) {
+		hlist_for_each_entry_rcu(tb, node, head, tb6_hlist) {
 			if (e < s_e)
 				goto next;
 			res = fib6_dump_table(tb, skb, cb);
@@ -408,6 +409,7 @@ next:
 		}
 	}
 out:
+	rcu_read_unlock();
 	cb->args[1] = e;
 	cb->args[0] = h;
 
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 947038d..47b3452 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -426,18 +426,14 @@ int phonet_route_del(struct net_device *dev, u8 daddr)
 	return 0;
 }
 
-struct net_device *phonet_route_get(struct net *net, u8 daddr)
+struct net_device *phonet_route_get_rcu(struct net *net, u8 daddr)
 {
 	struct phonet_net *pnn = phonet_pernet(net);
 	struct phonet_routes *routes = &pnn->routes;
 	struct net_device *dev;
 
-	ASSERT_RTNL(); /* no need to hold the device */
-
 	daddr >>= 2;
-	rcu_read_lock();
 	dev = rcu_dereference(routes->table[daddr]);
-	rcu_read_unlock();
 	return dev;
 }
 
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 58b3b1f..438accb 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -264,10 +264,11 @@ static int route_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	u8 addr, addr_idx = 0, addr_start_idx = cb->args[0];
 
+	rcu_read_lock();
 	for (addr = 0; addr < 64; addr++) {
 		struct net_device *dev;
 
-		dev = phonet_route_get(net, addr << 2);
+		dev = phonet_route_get_rcu(net, addr << 2);
 		if (!dev)
 			continue;
 
@@ -279,6 +280,7 @@ static int route_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 out:
+	rcu_read_unlock();
 	cb->args[0] = addr_idx;
 	cb->args[1] = 0;
 


