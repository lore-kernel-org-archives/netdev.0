From: Florian Westphal <fw@strlen.de>
Subject: [RFC net-next 9/9] xfrm: add a small xdst pcpu cache
Date: Wed, 28 Jun 2017 15:26:52 +0200
Message-ID: <20170628132652.1275-10-fw@strlen.de>
References: <20170628132652.1275-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34240 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751754AbdF1N1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 09:27:09 -0400
In-Reply-To: <20170628132652.1275-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

retain last used xfrm_dst in a pcpu cache.
On next request, reuse this dst if the policies are the same.

The cache does'nt help at all with strictly-RR workloads as
we never have a hit.

Also, the cache adds cost of this_cpu_xchg() in packet path.
It would be better to use plain this_cpu_read/write, however,
a netdev notifier can run in parallel on other cpu and write same
pcpu value so the xchg is needed to avoid race.

The notifier is needed so we do not add long hangs when a device
is dismantled but some pcpu xdst still holds a reference.

Test results using 4 network namespaces and null encryption:

ns1           ns2          -> ns3           -> ns4
netperf -> xfrm/null enc   -> xfrm/null dec -> netserver

what                    TCP_STREAM      UDP_STREAM      UDP_RR
Flow cache:		14804.4		279.738		326213.0
No flow cache:		14158.3		257.458		228486.8
Pcpu cache:		14766.4		286.958		239433.5

UDP tests used 64byte packets, tests ran for one minute each,
value is average over ten iterations.

'Flow cache' is 'net-next', 'No flow cache' is net-next plus this
series but without this one.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/xfrm.h     |  1 +
 net/xfrm/xfrm_device.c |  1 +
 net/xfrm/xfrm_policy.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9b85367529a4..8bde1d569790 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -316,6 +316,7 @@ int xfrm_policy_register_afinfo(const struct xfrm_policy_afinfo *afinfo, int fam
 void xfrm_policy_unregister_afinfo(const struct xfrm_policy_afinfo *afinfo);
 void km_policy_notify(struct xfrm_policy *xp, int dir,
 		      const struct km_event *c);
+void xfrm_policy_dev_unreg(void);
 void km_state_notify(struct xfrm_state *x, const struct km_event *c);
 
 struct xfrm_tmpl;
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index d01cb256e89c..8221d05d43d1 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -151,6 +151,7 @@ static int xfrm_dev_register(struct net_device *dev)
 
 static int xfrm_dev_unregister(struct net_device *dev)
 {
+	xfrm_policy_dev_unreg();
 	return NOTIFY_DONE;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f4419d1b9f38..ac83b39850ce 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -44,6 +44,7 @@ struct xfrm_flo {
 	u8 flags;
 };
 
+static DEFINE_PER_CPU(struct xfrm_dst *, xfrm_last_dst);
 static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo const __rcu *xfrm_policy_afinfo[AF_INET6 + 1]
 						__read_mostly;
@@ -1700,6 +1701,34 @@ static int xfrm_expand_policies(const struct flowi *fl, u16 family,
 
 }
 
+void xfrm_policy_dev_unreg(void)
+{
+	int cpu;
+
+	local_bh_disable();
+	rcu_read_lock();
+	for_each_possible_cpu(cpu) {
+		struct xfrm_dst *tmp, *old;
+
+		old = per_cpu(xfrm_last_dst, cpu);
+		if (!old || xfrm_bundle_ok(old))
+			continue;
+
+		tmp = cmpxchg(&(per_cpu(xfrm_last_dst, cpu)), old, NULL);
+		if (tmp == old)
+			dst_release(&old->u.dst);
+	}
+	rcu_read_unlock();
+	local_bh_enable();
+}
+
+static void xfrm_last_dst_update(struct xfrm_dst *xdst)
+{
+	struct xfrm_dst *old = this_cpu_xchg(xfrm_last_dst, xdst);
+	if (old)
+		dst_release(&old->u.dst);
+}
+
 static struct xfrm_dst *
 xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 			       const struct flowi *fl, u16 family,
@@ -1711,17 +1740,29 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	struct xfrm_dst *xdst;
 	int err;
 
+	xdst = this_cpu_read(xfrm_last_dst);
+	if (xdst &&
+	    xdst->u.dst.dev == dst_orig->dev &&
+	    xdst->num_pols == num_pols &&
+	    memcmp(xdst->pols, pols,
+		   sizeof(struct xfrm_policy *) * num_pols) == 0 &&
+	    xfrm_bundle_ok(xdst) &&
+	    dst_hold_safe(&xdst->u.dst))
+		return xdst;
+
 	/* Try to instantiate a bundle */
 	err = xfrm_tmpl_resolve(pols, num_pols, fl, xfrm, family);
 	if (err <= 0) {
 		if (err != 0 && err != -EAGAIN)
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
+		xfrm_last_dst_update(NULL);
 		return ERR_PTR(err);
 	}
 
 	dst = xfrm_bundle_create(pols[0], xfrm, err, fl, dst_orig);
 	if (IS_ERR(dst)) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTBUNDLEGENERROR);
+		xfrm_last_dst_update(NULL);
 		return ERR_CAST(dst);
 	}
 
@@ -1731,6 +1772,9 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 	xdst->policy_genid = atomic_read(&pols[0]->genid);
 
+	atomic_set(&xdst->u.dst.__refcnt, 2);
+	xfrm_last_dst_update(xdst);
+
 	return xdst;
 }
 
-- 
2.13.0
