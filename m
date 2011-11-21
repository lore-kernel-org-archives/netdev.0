From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH for 2.6.32 (untested)] netns: Add quota for number of NET_NS instances.
Date: Mon, 21 Nov 2011 22:07:57 +0900
Message-ID: <201111212207.GIC13020.FFLFVtOOOHJMSQ@I-love.SAKURA.ne.jp>
References: <201111201622.FDJ51567.VLFHQFMFOOSOtJ@I-love.SAKURA.ne.jp>
	<m1bos6wfnt.fsf@fess.ebiederm.org>
	<201111210157.pAL1vbRo089486@www262.sakura.ne.jp>
	<m1mxbqurax.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:50676 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871Ab1KUNII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 08:08:08 -0500
In-Reply-To: <m1mxbqurax.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> I am suggesting that if a netns instance is being cleaned up we should
> wait for one netns instance to be cleaned up.  A single netns instance
> does not take long to clean up (in general).  But a lot of netns
> instances do take a while.
> 
> With waiting for one netns instance to be cleaned up we should be able
> to guarantee that we don't develop a substantial backlog network
> namespaces to be cleaned up.  And that was the problem.

Ah, you are suggesting to wait for completion of cleaning up.
But unfortunately, we cannot sleep at __put_net().

> But the reality is that under high connection load if we actually want
> to use network namespaces we have to wait for previous network
> namespaces to clean up.

Right. Some quota with wait queue like below is wanted?
----------
This patch introduces /proc/sys/net/core/netns_max interface that limits
max number of network namespace instances. When number of network namespace
instances exceeded this quota, the process will be blocked in a killable state
rather than returning immediately. Setting this quota to 0 means nobody can
create new network namespace instances.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/net/sock.h         |    4 ++++
 net/core/net_namespace.c   |   15 +++++++++++++++
 net/core/sysctl_net_core.c |   10 ++++++++++
 3 files changed, 29 insertions(+)

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
@@ -81,12 +81,22 @@ static struct net_generic *net_alloc_gen
 #ifdef CONFIG_NET_NS
 static struct kmem_cache *net_cachep;
 static struct workqueue_struct *netns_wq;
+static atomic_t used_netns_count = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(netns_alloc_wait);
+unsigned int max_netns_count;
 
 static struct net *net_alloc(void)
 {
 	struct net *net = NULL;
 	struct net_generic *ng;
 
+	atomic_inc(&used_netns_count);
+	wait_event_killable(netns_alloc_wait,
+			    !max_netns_count ||
+			    atomic_read(&used_netns_count) <= max_netns_count);
+	if (atomic_read(&used_netns_count) > max_netns_count)
+		goto out;
+
 	ng = net_alloc_generic();
 	if (!ng)
 		goto out;
@@ -96,7 +106,10 @@ static struct net *net_alloc(void)
 		goto out_free;
 
 	rcu_assign_pointer(net->gen, ng);
+	return net;
 out:
+	atomic_dec(&used_netns_count);
+	wake_up(&netns_alloc_wait);
 	return net;
 
 out_free:
@@ -115,6 +128,8 @@ static void net_free(struct net *net)
 #endif
 	kfree(net->gen);
 	kmem_cache_free(net_cachep, net);
+	atomic_dec(&used_netns_count);
+	wake_up(&netns_alloc_wait);
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

> There is of course debian's solution which was to simply tweak vsftp
> to not use network namespaces on 2.6.32 and only enable the feature
> on later kernels.

Thank you for info. I added link to this thread to #790863 and would like to
wait for how they want to handle this problem. (Maybe they don't reenable
NET_NS, maybe they reenable NET_NS with some quota.)

Thanks.
