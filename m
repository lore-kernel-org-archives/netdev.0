From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] ipv6: Do cleanup for ip_mr_init
Date: Tue, 24 Jun 2008 11:42:19 +0800
Message-ID: <48606D1B.3040507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60462 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752979AbYFXDq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 23:46:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If do not do it, we will get following issues:
1. Leaving junks after inet6_init failing halfway.
2. Leaving proc and notifier junks after ipv6 modules unloading.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 include/linux/mroute6.h |    1 +
 net/ipv6/af_inet6.c     |    5 +++++
 net/ipv6/ip6mr.c        |   10 ++++++++++
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index e798959..05ffaac 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -136,6 +136,7 @@ extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
 extern void ip6_mr_init(void);
+extern void ip6_mr_cleanup(void);
 
 struct mif_device
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e84b3fd..15d4138 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -1061,6 +1061,9 @@ netfilter_fail:
 igmp_fail:
 	ndisc_cleanup();
 ndisc_fail:
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+#endif
 	icmpv6_cleanup();
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
@@ -1115,7 +1118,9 @@ static void __exit inet6_exit(void)
 	ipv6_netfilter_fini();
 	igmp6_cleanup();
 	ndisc_cleanup();
+#ifdef CONFIG_IPV6_MROUTE
 	icmpv6_cleanup();
+#endif
 	rawv6_exit();
 
 	unregister_pernet_subsys(&inet6_net_ops);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1479618..245c350 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -973,6 +973,16 @@ void __init ip6_mr_init(void)
 #endif
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
-- 
1.5.3.4


