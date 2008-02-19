From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 13/17 net-2.6.26] [NETNS]: Register /proc/net/rt_cache for each namespace.
Date: Tue, 19 Feb 2008 10:31:33 +0300
Message-ID: <1203406297-32725-13-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:61411 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754527AbYBSHbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:15 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c11e6bf..5f67eba 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -545,7 +545,7 @@ static int ip_rt_acct_read(char *buffer, char **start, off_t offset,
 }
 #endif
 
-static __init int ip_rt_proc_init(struct net *net)
+static int __net_init ip_rt_do_proc_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
@@ -577,8 +577,26 @@ err2:
 err1:
 	return -ENOMEM;
 }
+
+static void __net_exit ip_rt_do_proc_exit(struct net *net)
+{
+	remove_proc_entry("rt_cache", net->proc_net_stat);
+	remove_proc_entry("rt_cache", net->proc_net);
+	remove_proc_entry("rt_acct", net->proc_net);
+}
+
+static struct pernet_operations ip_rt_proc_ops __net_initdata =  {
+	.init = ip_rt_do_proc_init,
+	.exit = ip_rt_do_proc_exit,
+};
+
+static int __init ip_rt_proc_init(void)
+{
+	return register_pernet_subsys(&ip_rt_proc_ops);
+}
+
 #else
-static inline int ip_rt_proc_init(struct net *net)
+static inline int ip_rt_proc_init(void)
 {
 	return 0;
 }
@@ -3056,7 +3074,7 @@ int __init ip_rt_init(void)
 		ip_rt_secret_interval;
 	add_timer(&rt_secret_timer);
 
-	if (ip_rt_proc_init(&init_net))
+	if (ip_rt_proc_init())
 		printk(KERN_ERR "Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
 	xfrm_init();
-- 
1.5.3.rc5

