From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] ipv6: don't call fib6_run_gc() until routing is ready
Date: Mon,  9 Sep 2013 21:45:04 +0200 (CEST)
Message-ID: <20130909194504.1C691E5E72@unicorn.suse.cz>
References: <20130909.132720.1372904024173191622.davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35820 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752571Ab3IITpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 15:45:07 -0400
In-Reply-To: <20130909.132720.1372904024173191622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When loading the ipv6 module, ndisc_init() is called before
ip6_route_init(). As the former registers a handler calling
fib6_run_gc(), this opens a window to run the garbage collector
before necessary data structures are initialized. If a network
device is initialized in this window, adding MAC address to it
triggers a NETDEV_CHANGEADDR event, leading to a crash in
fib6_clean_all().

Take the event handler registration out of ndisc_init() into a
separate function ndisc_late_init() and move it after
ip6_route_init().

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/net/ndisc.h |  2 ++
 net/ipv6/af_inet6.c |  6 ++++++
 net/ipv6/ndisc.c    | 18 +++++++++++-------
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 3c4211f..ea0cc26 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -190,7 +190,9 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
 }
 
 extern int			ndisc_init(void);
+extern int			ndisc_late_init(void);
 
+extern void			ndisc_late_cleanup(void);
 extern void			ndisc_cleanup(void);
 
 extern int			ndisc_rcv(struct sk_buff *skb);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 136fe55..7c96100 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -915,6 +915,9 @@ static int __init inet6_init(void)
 	err = ip6_route_init();
 	if (err)
 		goto ip6_route_fail;
+	err = ndisc_late_init();
+	if (err)
+		goto ndisc_late_fail;
 	err = ip6_flowlabel_init();
 	if (err)
 		goto ip6_flowlabel_fail;
@@ -981,6 +984,8 @@ ipv6_exthdrs_fail:
 addrconf_fail:
 	ip6_flowlabel_cleanup();
 ip6_flowlabel_fail:
+	ndisc_late_cleanup();
+ndisc_late_fail:
 	ip6_route_cleanup();
 ip6_route_fail:
 #ifdef CONFIG_PROC_FS
@@ -1043,6 +1048,7 @@ static void __exit inet6_exit(void)
 	ipv6_exthdrs_exit();
 	addrconf_cleanup();
 	ip6_flowlabel_cleanup();
+	ndisc_late_cleanup();
 	ip6_route_cleanup();
 #ifdef CONFIG_PROC_FS
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1217945..f8a55ff 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1727,24 +1727,28 @@ int __init ndisc_init(void)
 	if (err)
 		goto out_unregister_pernet;
 #endif
-	err = register_netdevice_notifier(&ndisc_netdev_notifier);
-	if (err)
-		goto out_unregister_sysctl;
 out:
 	return err;
 
-out_unregister_sysctl:
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_unregister(&nd_tbl.parms);
 out_unregister_pernet:
-#endif
 	unregister_pernet_subsys(&ndisc_net_ops);
 	goto out;
+#endif
 }
 
-void ndisc_cleanup(void)
+int __init ndisc_late_init(void)
+{
+	return register_netdevice_notifier(&ndisc_netdev_notifier);
+}
+
+void ndisc_late_cleanup(void)
 {
 	unregister_netdevice_notifier(&ndisc_netdev_notifier);
+}
+
+void ndisc_cleanup(void)
+{
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(&nd_tbl.parms);
 #endif
-- 
1.8.1.4
