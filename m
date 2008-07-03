From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v2 [PATCH 1/2] ipv6: Do cleanup for ip6_mr_init
Date: Thu, 03 Jul 2008 12:13:30 +0800
Message-ID: <486C51EA.2040401@cn.fujitsu.com>
References: <48606D1B.3040507@cn.fujitsu.com> <20080702.181831.32808810.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56163 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751131AbYGCESC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 00:18:02 -0400
In-Reply-To: <20080702.181831.32808810.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If do not do it, we will get following issues:
1. Leaving junks after inet6_init failing halfway.
2. Leaving proc and notifier junks after ipv6 modules unloading.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index e798959..4c4d6f5 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -135,7 +135,8 @@ extern int ip6_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
-extern void ip6_mr_init(void);
+extern int ip6_mr_init(void);
+extern void ip6_mr_cleanup(void);
 
 struct mif_device
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e84b3fd..5cb7bb4 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -957,7 +957,9 @@ static int __init inet6_init(void)
 	if (err)
 		goto icmp_fail;
 #ifdef CONFIG_IPV6_MROUTE
-	ip6_mr_init();
+	err = ip6_mr_init();
+	if (err)
+		goto ipmr_fail;
 #endif
 	err = ndisc_init();
 	if (err)
@@ -1061,6 +1063,10 @@ netfilter_fail:
 igmp_fail:
 	ndisc_cleanup();
 ndisc_fail:
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+ipmr_fail:
+#endif
 	icmpv6_cleanup();
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
@@ -1115,6 +1121,9 @@ static void __exit inet6_exit(void)
 	ipv6_netfilter_fini();
 	igmp6_cleanup();
 	ndisc_cleanup();
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+#endif
 	icmpv6_cleanup();
 	rawv6_exit();
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1479618..3b785db 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -956,23 +956,51 @@ static struct notifier_block ip6_mr_notifier = {
  *	Setup for IP multicast routing
  */
 
-void __init ip6_mr_init(void)
+int __init ip6_mr_init(void)
 {
+	int err;
+
 	mrt_cachep = kmem_cache_create("ip6_mrt_cache",
 				       sizeof(struct mfc6_cache),
 				       0, SLAB_HWCACHE_ALIGN,
 				       NULL);
 	if (!mrt_cachep)
-		panic("cannot allocate ip6_mrt_cache");
+		return -ENOMEM;
 
 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
-	register_netdevice_notifier(&ip6_mr_notifier);
+	err = register_netdevice_notifier(&ip6_mr_notifier);
+	if (err)
+		goto reg_notif_fail;
+#ifdef CONFIG_PROC_FS
+	err = -ENOMEM;
+	if (!proc_net_fops_create(&init_net, "ip6_mr_vif", 0, &ip6mr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(&init_net, "ip6_mr_cache",
+				     0, &ip6mr_mfc_fops))
+		goto proc_cache_fail;
+#endif
+	return 0;
+reg_notif_fail:
+	kmem_cache_destroy(mrt_cachep);
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "ip6_mr_vif", 0, &ip6mr_vif_fops);
-	proc_net_fops_create(&init_net, "ip6_mr_cache", 0, &ip6mr_mfc_fops);
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip6_mr_notifier);
+proc_cache_fail:
+	proc_net_remove(&init_net, "ip6_mr_vif");
 #endif
+	return err;
 }
 
+void ip6_mr_cleanup(void)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(&init_net, "ip6_mr_cache");
+	proc_net_remove(&init_net, "ip6_mr_vif");
+#endif
+	unregister_netdevice_notifier(&ip6_mr_notifier);
+	del_timer(&ipmr_expire_timer);
+	kmem_cache_destroy(mrt_cachep);
+}
 
 static int ip6mr_mfc_add(struct mf6cctl *mfc, int mrtsock)
 {


