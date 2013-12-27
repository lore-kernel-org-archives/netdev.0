From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: remove prune parameter for fib6_clean_all
Date: Fri, 27 Dec 2013 16:32:38 +0800
Message-ID: <1388133158-4142-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:58856 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab3L0Ics (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 03:32:48 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so9095140pbc.10
        for <netdev@vger.kernel.org>; Fri, 27 Dec 2013 00:32:48 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id sy10sm78981548pac.15.2013.12.27.00.32.42
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 00:32:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

since the prune parameter for fib6_clean_all always is 0, remove it.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/ip6_fib.h |    2 +-
 net/ipv6/ip6_fib.c    |    6 +++---
 net/ipv6/route.c      |    6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 2182525..aca0c27 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -282,7 +282,7 @@ struct fib6_node *fib6_locate(struct fib6_node *root,
 			      const struct in6_addr *saddr, int src_len);
 
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
-		    int prune, void *arg);
+		    void *arg);
 
 int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info);
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 5550a81..075602f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1530,7 +1530,7 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 }
 
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
-		    int prune, void *arg)
+		    void *arg)
 {
 	struct fib6_table *table;
 	struct hlist_head *head;
@@ -1542,7 +1542,7 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
-					func, prune, arg);
+					func, 0, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
@@ -1636,7 +1636,7 @@ void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 
 	gc_args.more = icmp6_dst_gc();
 
-	fib6_clean_all(net, fib6_age, 0, NULL);
+	fib6_clean_all(net, fib6_age, NULL);
 	now = jiffies;
 	net->ipv6.ip6_rt_last_gc = now;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 89b2735..0d978b4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2244,7 +2244,7 @@ void rt6_remove_prefsrc(struct inet6_ifaddr *ifp)
 		.net = net,
 		.addr = &ifp->addr,
 	};
-	fib6_clean_all(net, fib6_remove_prefsrc, 0, &adni);
+	fib6_clean_all(net, fib6_remove_prefsrc, &adni);
 }
 
 struct arg_dev_net {
@@ -2271,7 +2271,7 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 		.net = net,
 	};
 
-	fib6_clean_all(net, fib6_ifdown, 0, &adn);
+	fib6_clean_all(net, fib6_ifdown, &adn);
 	icmp6_clean_all(fib6_ifdown, &adn);
 }
 
@@ -2326,7 +2326,7 @@ void rt6_mtu_change(struct net_device *dev, unsigned int mtu)
 		.mtu = mtu,
 	};
 
-	fib6_clean_all(dev_net(dev), rt6_mtu_change_route, 0, &arg);
+	fib6_clean_all(dev_net(dev), rt6_mtu_change_route, &arg);
 }
 
 static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
-- 
1.7.10.4
