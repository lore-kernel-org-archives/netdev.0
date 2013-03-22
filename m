From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 2/2] ipv6: provide addr and netconf dump consistency info
Date: Fri, 22 Mar 2013 17:28:43 +0100
Message-ID: <1363969723-4390-2-git-send-email-nicolas.dichtel@6wind.com>
References: <514C8559.5030301@6wind.com>
 <1363969723-4390-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, junwei.zhang@6wind.com, hongjun.li@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56376 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933802Ab3CVQ2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:28:52 -0400
In-Reply-To: <1363969723-4390-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a dev_addr_genid for IPv6. The goal is to use it, combined with
dev_base_seq to check if a change occurs during a netlink dump.
If a change is detected, the flag NLM_F_DUMP_INTR is set in the first message
after the dump was interrupted.

Note that only dump of unicast addresses is checked (multicast and anycast are
not checked).

Reported-by: Junwei Zhang <junwei.zhang@6wind.com>
Reported-by: Hongjun Li <hongjun.li@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netns/ipv6.h | 1 +
 net/ipv6/addrconf.c      | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 1242f37..005e2c2 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -71,6 +71,7 @@ struct netns_ipv6 {
 	struct fib_rules_ops	*mr6_rules_ops;
 #endif
 #endif
+	atomic_t		dev_addr_genid;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fa36a67..d0e40d4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -622,6 +622,8 @@ static int inet6_netconf_dump_devconf(struct sk_buff *skb,
 		idx = 0;
 		head = &net->dev_index_head[h];
 		rcu_read_lock();
+		cb->seq = atomic_read(&net->ipv6.dev_addr_genid) ^
+			  net->dev_base_seq;
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
@@ -639,6 +641,7 @@ static int inet6_netconf_dump_devconf(struct sk_buff *skb,
 				rcu_read_unlock();
 				goto done;
 			}
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
@@ -3875,6 +3878,7 @@ static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
 						NLM_F_MULTI);
 			if (err <= 0)
 				break;
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 		}
 		break;
 	}
@@ -3932,6 +3936,7 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 	s_ip_idx = ip_idx = cb->args[2];
 
 	rcu_read_lock();
+	cb->seq = atomic_read(&net->ipv6.dev_addr_genid) ^ net->dev_base_seq;
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
@@ -4409,6 +4414,8 @@ errout:
 
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
+	struct net *net = dev_net(ifp->idev->dev);
+
 	inet6_ifa_notify(event ? : RTM_NEWADDR, ifp);
 
 	switch (event) {
@@ -4434,6 +4441,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 			dst_free(&ifp->rt->dst);
 		break;
 	}
+	atomic_inc(&net->ipv6.dev_addr_genid);
 }
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
-- 
1.8.0.1
