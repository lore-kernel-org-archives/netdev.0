From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] net: fix a build failure when !CONFIG_PROC_FS
Date: Tue, 19 Feb 2013 20:47:05 +0800
Message-ID: <1361278025-22864-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:50805 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3BSMrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 07:47:20 -0500
Received: by mail-pa0-f41.google.com with SMTP id fb11so3425807pad.28
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 04:47:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

When !CONFIG_PROC_FS dev_mcast_init() is not defined,
actually we can just merge dev_mcast_init() into
dev_proc_init().

Reported-by: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f111b4f..b3d00fa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2646,7 +2646,6 @@ extern void		netdev_notify_peers(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
-extern void		dev_mcast_init(void);
 extern struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					       struct rtnl_link_stats64 *storage);
 extern void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
diff --git a/net/core/dev.c b/net/core/dev.c
index 8d9ddb0..17bc535 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6260,7 +6260,6 @@ static int __init net_dev_init(void)
 
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
-	dev_mcast_init();
 	rc = 0;
 out:
 	return rc;
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index ac87066..0f6bb6f 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -341,11 +341,6 @@ static struct pernet_operations __net_initdata dev_proc_ops = {
 	.exit = dev_proc_net_exit,
 };
 
-int __init dev_proc_init(void)
-{
-	return register_pernet_subsys(&dev_proc_ops);
-}
-
 static int dev_mc_seq_show(struct seq_file *seq, void *v)
 {
 	struct netdev_hw_addr *ha;
@@ -408,7 +403,10 @@ static struct pernet_operations __net_initdata dev_mc_net_ops = {
 	.exit = dev_mc_net_exit,
 };
 
-void __init dev_mcast_init(void)
+int __init dev_proc_init(void)
 {
-	register_pernet_subsys(&dev_mc_net_ops);
+	int ret = register_pernet_subsys(&dev_proc_ops);
+	if (!ret)
+		return register_pernet_subsys(&dev_mc_net_ops);
+	return ret;
 }
