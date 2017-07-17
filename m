From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 10/10] xfrm: add xdst pcpu cache
Date: Mon, 17 Jul 2017 13:57:27 +0200
Message-ID: <20170717115727.26042-11-fw@strlen.de>
References: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43968 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751380AbdGQL5n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:43 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

retain last used xfrm_dst in a pcpu cache.
On next request, reuse this dst if the policies are the same.

The cache will not help with strict RR workloads as there is no hit.

The cache packet-path part is reasonably small, the notifier part is
needed so we do not add long hangs when a device is dismantled but some
pcpu xdst still holds a reference, there are also calls to the flush
operation when userspace deletes SAs so modules can be removed
(there is no hit.

We need to run the dst_release on the correct cpu to avoid races with
packet path.  This is done by adding a work_struct for each cpu and then
doing the actual test/release on each affected cpu via schedule_work_on().

Test results using 4 network namespaces and null encryption:

ns1           ns2          -> ns3           -> ns4
netperf -> xfrm/null enc   -> xfrm/null dec -> netserver

what                    TCP_STREAM      UDP_STREAM      UDP_RR
Flow cache:             14644.61        294.35          327231.64
No flow cache:		14349.81	242.64		202301.72
Pcpu cache:		14629.70	292.21		205595.22

UDP tests used 64byte packets, tests ran for one minute each,
value is average over ten iterations.

'Flow cache' is 'net-next', 'No flow cache' is net-next plus this
series but without this patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/xfrm.h     |   1 +
 net/xfrm/xfrm_device.c |   2 +
 net/xfrm/xfrm_policy.c | 127 ++++++++++++++++++++++++++++++++++++++++++++++++-
 net/xfrm/xfrm_state.c  |   5 +-
 4 files changed, 132 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e0feba2ce76a..afb4929d7232 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -317,6 +317,7 @@ int xfrm_policy_register_afinfo(const struct xfrm_policy_afinfo *afinfo, int fam
 void xfrm_policy_unregister_afinfo(const struct xfrm_policy_afinfo *afinfo);
 void km_policy_notify(struct xfrm_policy *xp, int dir,
 		      const struct km_event *c);
+void xfrm_policy_cache_flush(void);
 void km_state_notify(struct xfrm_state *x, const struct km_event *c);
 
 struct xfrm_tmpl;
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 1f9a079e08b0..5cd7a244e88d 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -153,6 +153,7 @@ static int xfrm_dev_register(struct net_device *dev)
 
 static int xfrm_dev_unregister(struct net_device *dev)
 {
+	xfrm_policy_cache_flush();
 	return NOTIFY_DONE;
 }
 
@@ -175,6 +176,7 @@ static int xfrm_dev_down(struct net_device *dev)
 	if (dev->features & NETIF_F_HW_ESP)
 		xfrm_dev_state_flush(dev_net(dev), dev, true);
 
+	xfrm_policy_cache_flush();
 	return NOTIFY_DONE;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0f1db4c18b22..06c3bf7ab86b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -24,6 +24,7 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <linux/cpu.h>
 #include <linux/audit.h>
 #include <net/dst.h>
 #include <net/flow.h>
@@ -44,6 +45,8 @@ struct xfrm_flo {
 	u8 flags;
 };
 
+static DEFINE_PER_CPU(struct xfrm_dst *, xfrm_last_dst);
+static struct work_struct *xfrm_pcpu_work __read_mostly;
 static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo const __rcu *xfrm_policy_afinfo[AF_INET6 + 1]
 						__read_mostly;
@@ -972,6 +975,8 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 	}
 	if (!cnt)
 		err = -ESRCH;
+	else
+		xfrm_policy_cache_flush();
 out:
 	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
 	return err;
@@ -1700,6 +1705,102 @@ static int xfrm_expand_policies(const struct flowi *fl, u16 family,
 
 }
 
+static void xfrm_last_dst_update(struct xfrm_dst *xdst, struct xfrm_dst *old)
+{
+	this_cpu_write(xfrm_last_dst, xdst);
+	if (old)
+		dst_release(&old->u.dst);
+}
+
+static void __xfrm_pcpu_work_fn(void)
+{
+	struct xfrm_dst *old;
+
+	old = this_cpu_read(xfrm_last_dst);
+	if (old && !xfrm_bundle_ok(old))
+		xfrm_last_dst_update(NULL, old);
+}
+
+static void xfrm_pcpu_work_fn(struct work_struct *work)
+{
+	local_bh_disable();
+	rcu_read_lock();
+	__xfrm_pcpu_work_fn();
+	rcu_read_unlock();
+	local_bh_enable();
+}
+
+void xfrm_policy_cache_flush(void)
+{
+	struct xfrm_dst *old;
+	bool found = 0;
+	int cpu;
+
+	local_bh_disable();
+	rcu_read_lock();
+	for_each_possible_cpu(cpu) {
+		old = per_cpu(xfrm_last_dst, cpu);
+		if (old && !xfrm_bundle_ok(old)) {
+			if (smp_processor_id() == cpu) {
+				__xfrm_pcpu_work_fn();
+				continue;
+			}
+			found = true;
+			break;
+		}
+	}
+
+	rcu_read_unlock();
+	local_bh_enable();
+
+	if (!found)
+		return;
+
+	get_online_cpus();
+
+	for_each_possible_cpu(cpu) {
+		bool bundle_release;
+
+		rcu_read_lock();
+		old = per_cpu(xfrm_last_dst, cpu);
+		bundle_release = old && !xfrm_bundle_ok(old);
+		rcu_read_unlock();
+
+		if (!bundle_release)
+			continue;
+
+		if (cpu_online(cpu)) {
+			schedule_work_on(cpu, &xfrm_pcpu_work[cpu]);
+			continue;
+		}
+
+		rcu_read_lock();
+		old = per_cpu(xfrm_last_dst, cpu);
+		if (old && !xfrm_bundle_ok(old)) {
+			per_cpu(xfrm_last_dst, cpu) = NULL;
+			dst_release(&old->u.dst);
+		}
+		rcu_read_unlock();
+	}
+
+	put_online_cpus();
+}
+
+static bool xfrm_pol_dead(struct xfrm_dst *xdst)
+{
+	unsigned int num_pols = xdst->num_pols;
+	unsigned int pol_dead = 0, i;
+
+	for (i = 0; i < num_pols; i++)
+		pol_dead |= xdst->pols[i]->walk.dead;
+
+	/* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
+	if (pol_dead)
+		xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
+
+	return pol_dead;
+}
+
 static struct xfrm_dst *
 xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 			       const struct flowi *fl, u16 family,
@@ -1707,10 +1808,22 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 {
 	struct net *net = xp_net(pols[0]);
 	struct xfrm_state *xfrm[XFRM_MAX_DEPTH];
+	struct xfrm_dst *xdst, *old;
 	struct dst_entry *dst;
-	struct xfrm_dst *xdst;
 	int err;
 
+	xdst = this_cpu_read(xfrm_last_dst);
+	if (xdst &&
+	    xdst->u.dst.dev == dst_orig->dev &&
+	    xdst->num_pols == num_pols &&
+	    !xfrm_pol_dead(xdst) &&
+	    memcmp(xdst->pols, pols,
+		   sizeof(struct xfrm_policy *) * num_pols) == 0) {
+		dst_hold(&xdst->u.dst);
+		return xdst;
+	}
+
+	old = xdst;
 	/* Try to instantiate a bundle */
 	err = xfrm_tmpl_resolve(pols, num_pols, fl, xfrm, family);
 	if (err <= 0) {
@@ -1731,6 +1844,9 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 	xdst->policy_genid = atomic_read(&pols[0]->genid);
 
+	atomic_set(&xdst->u.dst.__refcnt, 2);
+	xfrm_last_dst_update(xdst, old);
+
 	return xdst;
 }
 
@@ -2843,6 +2959,15 @@ static struct pernet_operations __net_initdata xfrm_net_ops = {
 
 void __init xfrm_init(void)
 {
+	int i;
+
+	xfrm_pcpu_work = kmalloc_array(NR_CPUS, sizeof(*xfrm_pcpu_work),
+				       GFP_KERNEL);
+	BUG_ON(!xfrm_pcpu_work);
+
+	for (i = 0; i < NR_CPUS; i++)
+		INIT_WORK(&xfrm_pcpu_work[i], xfrm_pcpu_work_fn);
+
 	register_pernet_subsys(&xfrm_net_ops);
 	seqcount_init(&xfrm_policy_hash_generation);
 	xfrm_input_init();
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 6c0956d10db6..82cbbce69b79 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -724,9 +724,10 @@ int xfrm_state_flush(struct net *net, u8 proto, bool task_valid)
 			}
 		}
 	}
-	if (cnt)
+	if (cnt) {
 		err = 0;
-
+		xfrm_policy_cache_flush();
+	}
 out:
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	return err;
-- 
2.13.0
