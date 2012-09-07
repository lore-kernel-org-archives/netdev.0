From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipv4/route: arg delay is useless in rt_cache_flush()
Date: Fri,  7 Sep 2012 11:31:24 +0200
Message-ID: <1347010284-3419-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:32842 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886Ab2IGJcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 05:32:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since route cache deletion (89aef8921bfbac22f), delay is no
more used. Remove it.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/route.h     |  2 +-
 net/ipv4/arp.c          |  2 +-
 net/ipv4/devinet.c      |  6 +++---
 net/ipv4/fib_frontend.c | 20 ++++++++++----------
 net/ipv4/fib_rules.c    |  2 +-
 net/ipv4/fib_trie.c     |  6 +++---
 net/ipv4/route.c        | 14 +++-----------
 7 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 776a27f..da22243 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -108,7 +108,7 @@ extern struct ip_rt_acct __percpu *ip_rt_acct;
 
 struct in_device;
 extern int		ip_rt_init(void);
-extern void		rt_cache_flush(struct net *net, int how);
+extern void		rt_cache_flush(struct net *net);
 extern void		rt_flush_dev(struct net_device *dev);
 extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 extern struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 77e87af..4780045 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1225,7 +1225,7 @@ static int arp_netdev_event(struct notifier_block *this, unsigned long event,
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&arp_tbl, dev);
-		rt_cache_flush(dev_net(dev), 0);
+		rt_cache_flush(dev_net(dev));
 		break;
 	default:
 		break;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index adf273f..f14eff5 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1500,7 +1500,7 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 		if (i == IPV4_DEVCONF_ACCEPT_LOCAL - 1 ||
 		    i == IPV4_DEVCONF_ROUTE_LOCALNET - 1)
 			if ((new_value == 0) && (old_value != 0))
-				rt_cache_flush(net, 0);
+				rt_cache_flush(net);
 	}
 
 	return ret;
@@ -1534,7 +1534,7 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 				dev_disable_lro(idev->dev);
 			}
 			rtnl_unlock();
-			rt_cache_flush(net, 0);
+			rt_cache_flush(net);
 		}
 	}
 
@@ -1551,7 +1551,7 @@ static int ipv4_doint_and_flush(ctl_table *ctl, int write,
 	struct net *net = ctl->extra2;
 
 	if (write && *valp != val)
-		rt_cache_flush(net, 0);
+		rt_cache_flush(net);
 
 	return ret;
 }
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index acdee32..8a7cd79 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -148,7 +148,7 @@ static void fib_flush(struct net *net)
 	}
 
 	if (flushed)
-		rt_cache_flush(net, -1);
+		rt_cache_flush(net);
 }
 
 /*
@@ -999,11 +999,11 @@ static void nl_fib_lookup_exit(struct net *net)
 	net->ipv4.fibnl = NULL;
 }
 
-static void fib_disable_ip(struct net_device *dev, int force, int delay)
+static void fib_disable_ip(struct net_device *dev, int force)
 {
 	if (fib_sync_down_dev(dev, force))
 		fib_flush(dev_net(dev));
-	rt_cache_flush(dev_net(dev), delay);
+	rt_cache_flush(dev_net(dev));
 	arp_ifdown(dev);
 }
 
@@ -1020,7 +1020,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 		fib_sync_up(dev);
 #endif
 		atomic_inc(&net->ipv4.dev_addr_genid);
-		rt_cache_flush(dev_net(dev), -1);
+		rt_cache_flush(dev_net(dev));
 		break;
 	case NETDEV_DOWN:
 		fib_del_ifaddr(ifa, NULL);
@@ -1029,9 +1029,9 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 			/* Last address was deleted from this interface.
 			 * Disable IP.
 			 */
-			fib_disable_ip(dev, 1, 0);
+			fib_disable_ip(dev, 1);
 		} else {
-			rt_cache_flush(dev_net(dev), -1);
+			rt_cache_flush(dev_net(dev));
 		}
 		break;
 	}
@@ -1045,7 +1045,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_UNREGISTER) {
-		fib_disable_ip(dev, 2, -1);
+		fib_disable_ip(dev, 2);
 		rt_flush_dev(dev);
 		return NOTIFY_DONE;
 	}
@@ -1061,14 +1061,14 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		fib_sync_up(dev);
 #endif
 		atomic_inc(&net->ipv4.dev_addr_genid);
-		rt_cache_flush(net, -1);
+		rt_cache_flush(net);
 		break;
 	case NETDEV_DOWN:
-		fib_disable_ip(dev, 0, 0);
+		fib_disable_ip(dev, 0);
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGE:
-		rt_cache_flush(net, 0);
+		rt_cache_flush(net);
 		break;
 	}
 	return NOTIFY_DONE;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index a83d74e..274309d 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -259,7 +259,7 @@ static size_t fib4_rule_nlmsg_payload(struct fib_rule *rule)
 
 static void fib4_rule_flush_cache(struct fib_rules_ops *ops)
 {
-	rt_cache_flush(ops->fro_net, -1);
+	rt_cache_flush(ops->fro_net);
 }
 
 static const struct fib_rules_ops __net_initdata fib4_rules_ops_template = {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3c820da..8d76610 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1286,7 +1286,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 			fib_release_info(fi_drop);
 			if (state & FA_S_ACCESSED)
-				rt_cache_flush(cfg->fc_nlinfo.nl_net, -1);
+				rt_cache_flush(cfg->fc_nlinfo.nl_net);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
 				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
 
@@ -1333,7 +1333,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	list_add_tail_rcu(&new_fa->fa_list,
 			  (fa ? &fa->fa_list : fa_head));
 
-	rt_cache_flush(cfg->fc_nlinfo.nl_net, -1);
+	rt_cache_flush(cfg->fc_nlinfo.nl_net);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 succeeded:
@@ -1711,7 +1711,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 		trie_leaf_remove(t, l);
 
 	if (fa->fa_state & FA_S_ACCESSED)
-		rt_cache_flush(cfg->fc_nlinfo.nl_net, -1);
+		rt_cache_flush(cfg->fc_nlinfo.nl_net);
 
 	fib_release_info(fa->fa_info);
 	alias_free_mem_rcu(fa);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dc9549b..915c592 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -461,11 +461,7 @@ static void rt_cache_invalidate(struct net *net)
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
 }
 
-/*
- * delay < 0  : invalidate cache (fast : entries will be deleted later)
- * delay >= 0 : invalidate & flush cache (can be long)
- */
-void rt_cache_flush(struct net *net, int delay)
+void rt_cache_flush(struct net *net)
 {
 	rt_cache_invalidate(net);
 }
@@ -2345,7 +2341,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 
 void ip_rt_multicast_event(struct in_device *in_dev)
 {
-	rt_cache_flush(dev_net(in_dev->dev), 0);
+	rt_cache_flush(dev_net(in_dev->dev));
 }
 
 #ifdef CONFIG_SYSCTL
@@ -2354,16 +2350,12 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 					size_t *lenp, loff_t *ppos)
 {
 	if (write) {
-		int flush_delay;
 		ctl_table ctl;
 		struct net *net;
 
 		memcpy(&ctl, __ctl, sizeof(ctl));
-		ctl.data = &flush_delay;
-		proc_dointvec(&ctl, write, buffer, lenp, ppos);
-
 		net = (struct net *)__ctl->extra1;
-		rt_cache_flush(net, flush_delay);
+		rt_cache_flush(net);
 		return 0;
 	}
 
-- 
1.7.12
