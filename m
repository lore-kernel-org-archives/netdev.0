From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH for 2.6.32 (untested)] netns: Add quota for number of NET_NS instances.
Date: Sun, 20 Nov 2011 16:22:40 +0900
Message-ID: <201111201622.FDJ51567.VLFHQFMFOOSOtJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:60829 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab1KTHWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 02:22:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to solve below problems, can we add sysctl variable for
restricting number of NET_NS instances?
--------------------------------------------------
[PATCH for 2.6.32 (untested)] netns: Add quota for number of NET_NS instances.

CONFIG_NET_NS support in 2.6.32 has a problem that leads to OOM killer when
clone(CLONE_NEWNET) is called instantly.
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/720095
But disabling CONFIG_NET_NS broke lxc containers.
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/790863

This patch introduces /proc/sys/net/core/netns_max interface that limits
max number of network namespace instances.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/net/sock.h         |    4 ++++
 net/core/net_namespace.c   |    9 +++++++++
 net/core/sysctl_net_core.c |   10 ++++++++++
 3 files changed, 23 insertions(+)

--- linux-2.6.32.48.orig/include/net/sock.h
+++ linux-2.6.32.48/include/net/sock.h
@@ -1598,4 +1598,8 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+#ifdef CONFIG_NET_NS
+extern int max_netns_count;
+#endif
+
 #endif	/* _SOCK_H */
--- linux-2.6.32.48.orig/net/core/net_namespace.c
+++ linux-2.6.32.48/net/core/net_namespace.c
@@ -81,12 +81,18 @@ static struct net_generic *net_alloc_gen
 #ifdef CONFIG_NET_NS
 static struct kmem_cache *net_cachep;
 static struct workqueue_struct *netns_wq;
+static atomic_t used_netns_count = ATOMIC_INIT(0);
+unsigned int max_netns_count;
 
 static struct net *net_alloc(void)
 {
 	struct net *net = NULL;
 	struct net_generic *ng;
 
+	atomic_inc(&used_netns_count);
+	if (atomic_read(&used_netns_count) > max_netns_count)
+		goto out;
+
 	ng = net_alloc_generic();
 	if (!ng)
 		goto out;
@@ -96,7 +102,9 @@ static struct net *net_alloc(void)
 		goto out_free;
 
 	rcu_assign_pointer(net->gen, ng);
+	return net;
 out:
+	atomic_dec(&used_netns_count);
 	return net;
 
 out_free:
@@ -115,6 +123,7 @@ static void net_free(struct net *net)
 #endif
 	kfree(net->gen);
 	kmem_cache_free(net_cachep, net);
+	atomic_dec(&used_netns_count);
 }
 
 static struct net *net_create(void)
--- linux-2.6.32.48.orig/net/core/sysctl_net_core.c
+++ linux-2.6.32.48/net/core/sysctl_net_core.c
@@ -89,6 +89,16 @@ static struct ctl_table net_core_table[]
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#ifdef CONFIG_NET_NS
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "netns_max",
+		.data           = &max_netns_count,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec,
+	},
+#endif
 #endif /* CONFIG_NET */
 	{
 		.ctl_name	= NET_CORE_BUDGET,
