From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] net/flow: remove sleeping and deferral mechanism from
 flow_cache_flush
Date: Tue, 20 Dec 2011 09:23:32 +0100
Message-ID: <20111220082332.GN6348@secunet.com>
References: <1317056956-23644-1-git-send-email-madalin.bucur@freescale.com>
 <20110927.152836.1747700807304689813.davem@davemloft.net>
 <20110927.153132.900366550174236643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: madalin.bucur@freescale.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37505 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667Ab1LTIXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Dec 2011 03:23:35 -0500
Content-Disposition: inline
In-Reply-To: <20110927.153132.900366550174236643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2011 at 03:31:32PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 27 Sep 2011 15:28:36 -0400 (EDT)
> 
> > afinfo->garbage_collect is the only other place __xfrm_garbage_collect
> > is referenced, and that is completely unused and should thus be deleted
> > (I'll take care of that in net-next).
> 
> Nevermind I see how these are referenced directly via xfrm4_policy.c
> and xfrm6_policy.c, sigh...

Is there any progress in fixing this issue? I've seen this occasionally
on some of our production systems, so I fixed it for us in the meantime
with the patch below. I could submit this for inclusion if noone else
wants to fix it in a different manner.

------
net: Add a flow_cache_flush_deferred function

flow_cach_flush() might sleep but can be called from
atomic context via the xfrm garbage collector. So add
a flow_cache_flush_deferred() function and use this if
the xfrm garbage colector is invoked from within the
packet path.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/flow.h     |    1 +
 net/core/flow.c        |   12 ++++++++++++
 net/xfrm/xfrm_policy.c |   18 ++++++++++++++----
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index a094477..57f15a7 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -207,6 +207,7 @@ extern struct flow_cache_object *flow_cache_lookup(
 		u8 dir, flow_resolve_t resolver, void *ctx);
 
 extern void flow_cache_flush(void);
+extern void flow_cache_flush_deferred(void);
 extern atomic_t flow_cache_genid;
 
 #endif
diff --git a/net/core/flow.c b/net/core/flow.c
index 8ae42de..e318c7e 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -358,6 +358,18 @@ void flow_cache_flush(void)
 	put_online_cpus();
 }
 
+static void flow_cache_flush_task(struct work_struct *work)
+{
+	flow_cache_flush();
+}
+
+static DECLARE_WORK(flow_cache_flush_work, flow_cache_flush_task);
+
+void flow_cache_flush_deferred(void)
+{
+	schedule_work(&flow_cache_flush_work);
+}
+
 static int __cpuinit flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
 {
 	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2118d64..9049a5c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2276,8 +2276,6 @@ static void __xfrm_garbage_collect(struct net *net)
 {
 	struct dst_entry *head, *next;
 
-	flow_cache_flush();
-
 	spin_lock_bh(&xfrm_policy_sk_bundle_lock);
 	head = xfrm_policy_sk_bundles;
 	xfrm_policy_sk_bundles = NULL;
@@ -2290,6 +2288,18 @@ static void __xfrm_garbage_collect(struct net *net)
 	}
 }
 
+static void xfrm_garbage_collect(struct net *net)
+{
+	flow_cache_flush();
+	__xfrm_garbage_collect(net);
+}
+
+static void xfrm_garbage_collect_deferred(struct net *net)
+{
+	flow_cache_flush_deferred();
+	__xfrm_garbage_collect(net);
+}
+
 static void xfrm_init_pmtu(struct dst_entry *dst)
 {
 	do {
@@ -2422,7 +2432,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 		if (likely(dst_ops->neigh_lookup == NULL))
 			dst_ops->neigh_lookup = xfrm_neigh_lookup;
 		if (likely(afinfo->garbage_collect == NULL))
-			afinfo->garbage_collect = __xfrm_garbage_collect;
+			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
 		xfrm_policy_afinfo[afinfo->family] = afinfo;
 	}
 	write_unlock_bh(&xfrm_policy_afinfo_lock);
@@ -2516,7 +2526,7 @@ static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void
 
 	switch (event) {
 	case NETDEV_DOWN:
-		__xfrm_garbage_collect(dev_net(dev));
+		xfrm_garbage_collect(dev_net(dev));
 	}
 	return NOTIFY_DONE;
 }
-- 
1.7.0.4
