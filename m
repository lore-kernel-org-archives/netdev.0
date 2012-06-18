From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ipv6: Move ipv6 proc file registration to end of init order
Date: Tue, 19 Jun 2012 00:08:33 +0200
Message-ID: <1432a6aff6ee203a688e78b06ed8000475385564.1340057223.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752146Ab2FRWIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 18:08:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/net/ipv6_route reflects the contents of fib_table_hash. The proc
handler is installed in ip6_route_net_init() whereas fib_table_hash is
allocated in fib6_net_init() _after_ the proc handler has been installed.

This opens up a short time frame to access fib_table_hash with its pants
down.

Move the registration of the proc files to a later point in the init
order to avoid the race.

Tested :-)

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv6/route.c |   41 +++++++++++++++++++++++++++++++----------
 1 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 999a982..becb048 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2957,10 +2957,6 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
 
-#ifdef CONFIG_PROC_FS
-	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
-	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
-#endif
 	net->ipv6.ip6_rt_gc_expire = 30*HZ;
 
 	ret = 0;
@@ -2981,10 +2977,6 @@ out_ip6_dst_ops:
 
 static void __net_exit ip6_route_net_exit(struct net *net)
 {
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(net, "ipv6_route");
-	proc_net_remove(net, "rt6_stats");
-#endif
 	kfree(net->ipv6.ip6_null_entry);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	kfree(net->ipv6.ip6_prohibit_entry);
@@ -2993,11 +2985,33 @@ static void __net_exit ip6_route_net_exit(struct net *net)
 	dst_entries_destroy(&net->ipv6.ip6_dst_ops);
 }
 
+static int __net_init ip6_route_net_init_late(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
+	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
+#endif
+	return 0;
+}
+
+static void __net_exit ip6_route_net_exit_late(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(net, "ipv6_route");
+	proc_net_remove(net, "rt6_stats");
+#endif
+}
+
 static struct pernet_operations ip6_route_net_ops = {
 	.init = ip6_route_net_init,
 	.exit = ip6_route_net_exit,
 };
 
+static struct pernet_operations ip6_route_net_late_ops = {
+	.init = ip6_route_net_init_late,
+	.exit = ip6_route_net_exit_late,
+};
+
 static struct notifier_block ip6_route_dev_notifier = {
 	.notifier_call = ip6_route_dev_notify,
 	.priority = 0,
@@ -3047,19 +3061,25 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto xfrm6_init;
 
+	ret = register_pernet_subsys(&ip6_route_net_late_ops);
+	if (ret)
+		goto fib6_rules_init;
+
 	ret = -ENOBUFS;
 	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL, NULL) ||
 	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL, NULL) ||
 	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL, NULL))
-		goto fib6_rules_init;
+		goto out_register_late_subsys;
 
 	ret = register_netdevice_notifier(&ip6_route_dev_notifier);
 	if (ret)
-		goto fib6_rules_init;
+		goto out_register_late_subsys;
 
 out:
 	return ret;
 
+out_register_late_subsys:
+	unregister_pernet_subsys(&ip6_route_net_late_ops);
 fib6_rules_init:
 	fib6_rules_cleanup();
 xfrm6_init:
@@ -3078,6 +3098,7 @@ out_kmem_cache:
 void ip6_route_cleanup(void)
 {
 	unregister_netdevice_notifier(&ip6_route_dev_notifier);
+	unregister_pernet_subsys(&ip6_route_net_late_ops);
 	fib6_rules_cleanup();
 	xfrm6_fini();
 	fib6_gc_cleanup();
-- 
1.7.7.6
