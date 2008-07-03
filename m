From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v2 [PATCH 2/2] ipv4: Do cleanup for ip_mr_init
Date: Thu, 03 Jul 2008 12:13:36 +0800
Message-ID: <486C51F0.4010205@cn.fujitsu.com>
References: <48606D1B.3040507@cn.fujitsu.com> <20080702.181831.32808810.yoshfuji@linux-ipv6.org> <486C50AE.7000207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59984 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbYGCESE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 00:18:04 -0400
In-Reply-To: <486C50AE.7000207@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same as ip6_mr_init(), make ip_mr_init() return errno if fails.
But do not do error handling in inet_init(), just print a msg.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f5a1a0d..7bb3c09 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -228,7 +228,6 @@ extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 extern int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		struct group_filter __user *optval, int __user *optlen);
 extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
-extern void ip_mr_init(void);
 extern void ip_mc_init_dev(struct in_device *);
 extern void ip_mc_destroy_dev(struct in_device *);
 extern void ip_mc_up(struct in_device *);
diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index de4decf..df8efd4 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -147,8 +147,7 @@ static inline int ip_mroute_opt(int opt)
 extern int ip_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
-extern void ip_mr_init(void);
-
+extern int ip_mr_init(void);
 
 struct vif_device
 {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 24eca23..3bb9007 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1481,14 +1481,15 @@ static int __init inet_init(void)
 	 *	Initialise the multicast router
 	 */
 #if defined(CONFIG_IP_MROUTE)
-	ip_mr_init();
+	if (ip_mr_init())
+		printk(KERN_CRIT "inet_init: Cannot init ipv4 mroute\n");
 #endif
 	/*
 	 *	Initialise per-cpu ipv4 mibs
 	 */
 
 	if (init_ipv4_mibs())
-		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n"); ;
+		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n");
 
 	ipv4_proc_init();
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 11700a4..5225587 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1887,16 +1887,36 @@ static struct net_protocol pim_protocol = {
  *	Setup for IP multicast routing
  */
 
-void __init ip_mr_init(void)
+int __init ip_mr_init(void)
 {
+	int err;
+
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
 				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 				       NULL);
+	if (!mrt_cachep)
+		return -ENOMEM;
+
 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
-	register_netdevice_notifier(&ip_mr_notifier);
+	err = register_netdevice_notifier(&ip_mr_notifier);
+	if (err)
+		goto reg_notif_fail;
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "ip_mr_vif", 0, &ipmr_vif_fops);
-	proc_net_fops_create(&init_net, "ip_mr_cache", 0, &ipmr_mfc_fops);
+	err = -ENOMEM;
+	if (!proc_net_fops_create(&init_net, "ip_mr_vif", 0, &ipmr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(&init_net, "ip_mr_cache", 0, &ipmr_mfc_fops))
+		goto proc_cache_fail;
 #endif
+	return 0;
+reg_notif_fail:
+	kmem_cache_destroy(mrt_cachep);
+#ifdef CONFIG_PROC_FS
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip_mr_notifier);
+proc_cache_fail:
+	proc_net_remove(&init_net, "ip_mr_vif");
+#endif
+	return err;
 }


