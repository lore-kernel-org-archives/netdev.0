From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK 03/04]: Remove unnecessary locking in dump callbacks
Date: Mon, 16 Apr 2007 09:51:55 +0200 (MEST)
Message-ID: <20070416074953.19262.13878.sendpatchset@localhost.localdomain>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34167 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932469AbXDPHv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 03:51:57 -0400
In-Reply-To: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RTNETLINK]: Remove unnecessary locking in dump callbacks

Since we're now holding the rtnl during the entire dump operation, we can
remove additional locking for rtnl protected data. This patch does that
for all simple cases (dev_base_lock for dev_base walking, RCU protection
for FIB rule dumping).

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 49310148887f3d7a6b78809b0a771628be4ef0a8
tree 901a913e7b2570765df8aeb5b628c3783ee4934a
parent 8d28b6a3d70b6c98bba6d1e60e2ecf8eb9fbbb2b
author Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:32 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:32 +0200

 net/bridge/br_netlink.c |    2 --
 net/core/fib_rules.c    |    4 +---
 net/core/rtnetlink.c    |    2 --
 net/decnet/dn_dev.c     |    3 ---
 net/ipv4/devinet.c      |   12 ++----------
 net/ipv6/addrconf.c     |    2 --
 6 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 5e84ade..35facc0 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -109,7 +109,6 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	int idx;
 
-	read_lock(&dev_base_lock);
 	for (dev = dev_base, idx = 0; dev; dev = dev->next) {
 		/* not a bridge port */
 		if (dev->br_port == NULL || idx < cb->args[0])
@@ -122,7 +121,6 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 skip:
 		++idx;
 	}
-	read_unlock(&dev_base_lock);
 
 	cb->args[0] = idx;
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index cb2dae1..8c5474e 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -495,8 +495,7 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 	int idx = 0;
 	struct fib_rule *rule;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(rule, ops->rules_list, list) {
+	list_for_each_entry(rule, ops->rules_list, list) {
 		if (idx < cb->args[1])
 			goto skip;
 
@@ -507,7 +506,6 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 skip:
 		idx++;
 	}
-	rcu_read_unlock();
 	cb->args[1] = idx;
 	rules_ops_put(ops);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 62f5c7f..bc95fab 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -543,7 +543,6 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_idx = cb->args[0];
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
 	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
 			continue;
@@ -552,7 +551,6 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 				     cb->nlh->nlmsg_seq, 0, NLM_F_MULTI) <= 0)
 			break;
 	}
-	read_unlock(&dev_base_lock);
 	cb->args[0] = idx;
 
 	return skb->len;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 61be2ca..5c2a995 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -799,7 +799,6 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	skip_ndevs = cb->args[0];
 	skip_naddr = cb->args[1];
 
-	read_lock(&dev_base_lock);
 	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
 		if (idx < skip_ndevs)
 			continue;
@@ -824,8 +823,6 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 		}
 	}
 done:
-	read_unlock(&dev_base_lock);
-
 	cb->args[0] = idx;
 	cb->args[1] = dn_idx;
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 9bdc795..088888d 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1182,17 +1182,13 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_ip_idx, s_idx = cb->args[0];
 
 	s_ip_idx = ip_idx = cb->args[1];
-	read_lock(&dev_base_lock);
 	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
 			continue;
 		if (idx > s_idx)
 			s_ip_idx = 0;
-		rcu_read_lock();
-		if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
-			rcu_read_unlock();
+		if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
 			continue;
-		}
 
 		for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
 		     ifa = ifa->ifa_next, ip_idx++) {
@@ -1200,16 +1196,12 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 				continue;
 			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
-					     RTM_NEWADDR, NLM_F_MULTI) <= 0) {
-				rcu_read_unlock();
+					     RTM_NEWADDR, NLM_F_MULTI) <= 0)
 				goto done;
-			}
 		}
-		rcu_read_unlock();
 	}
 
 done:
-	read_unlock(&dev_base_lock);
 	cb->args[0] = idx;
 	cb->args[1] = ip_idx;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index adb171e..ed65456 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3222,7 +3222,6 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 
 	s_idx = cb->args[0];
 	s_ip_idx = ip_idx = cb->args[1];
-	read_lock(&dev_base_lock);
 
 	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
@@ -3284,7 +3283,6 @@ done:
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
 	}
-	read_unlock(&dev_base_lock);
 	cb->args[0] = idx;
 	cb->args[1] = ip_idx;
 	return skb->len;
