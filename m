From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/10] netfilter: fix netns dependencies with conntrack templates
Date: Thu, 23 Jul 2015 01:00:51 +0200
Message-ID: <1437606052-5179-10-git-send-email-pablo@netfilter.org>
References: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54458 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446AbbGVWz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 18:55:29 -0400
In-Reply-To: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Daniel Borkmann:

"When adding connection tracking template rules to a netns, f.e. to
configure netfilter zones, the kernel will endlessly busy-loop as soon
as we try to delete the given netns in case there's at least one
template present, which is problematic i.e. if there is such bravery that
the priviledged user inside the netns is assumed untrusted.

Minimal example:

  ip netns add foo
  ip netns exec foo iptables -t raw -A PREROUTING -d 1.2.3.4 -j CT --zone 1
  ip netns del foo

What happens is that when nf_ct_iterate_cleanup() is being called from
nf_conntrack_cleanup_net_list() for a provided netns, we always end up
with a net->ct.count > 0 and thus jump back to i_see_dead_people. We
don't get a soft-lockup as we still have a schedule() point, but the
serving CPU spins on 100% from that point onwards.

Since templates are normally allocated with nf_conntrack_alloc(), we
also bump net->ct.count. The issue why they are not yet nf_ct_put() is
because the per netns .exit() handler from x_tables (which would eventually
invoke xt_CT's xt_ct_tg_destroy() that drops reference on info->ct) is
called in the dependency chain at a *later* point in time than the per
netns .exit() handler for the connection tracker.

This is clearly a chicken'n'egg problem: after the connection tracker
.exit() handler, we've teared down all the connection tracking
infrastructure already, so rightfully, xt_ct_tg_destroy() cannot be
invoked at a later point in time during the netns cleanup, as that would
lead to a use-after-free. At the same time, we cannot make x_tables depend
on the connection tracker module, so that the xt_ct_tg_destroy() would
be invoked earlier in the cleanup chain."

Daniel confirms this has to do with the order in which modules are loaded or
having compiled nf_conntrack as modules while x_tables built-in. So we have no
guarantees regarding the order in which netns callbacks are executed.

Fix this by allocating the templates through kmalloc() from the respective
SYNPROXY and CT targets, so they don't depend on the conntrack kmem cache.
Then, release then via nf_ct_tmpl_free() from destroy_conntrack(). This branch
is marked as unlikely since conntrack templates are rarely allocated and only
from the configuration plane path.

Note that templates are not kept in any list to avoid further dependencies with
nf_conntrack anymore, thus, the tmpl larval list is removed.

Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Tested-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/netfilter/nf_conntrack.h |    2 +-
 include/net/netns/conntrack.h        |    1 -
 net/netfilter/nf_conntrack_core.c    |   67 ++++++++++++++++++++++------------
 net/netfilter/nf_synproxy_core.c     |    7 ++--
 net/netfilter/xt_CT.c                |    8 ++--
 5 files changed, 51 insertions(+), 34 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 095433b..37cd391 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -291,7 +291,7 @@ extern unsigned int nf_conntrack_max;
 extern unsigned int nf_conntrack_hash_rnd;
 void init_nf_conntrack_hash_rnd(void);
 
-void nf_conntrack_tmpl_insert(struct net *net, struct nf_conn *tmpl);
+struct nf_conn *nf_ct_tmpl_alloc(struct net *net, u16 zone, gfp_t flags);
 
 #define NF_CT_STAT_INC(net, count)	  __this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_INC_ATOMIC(net, count) this_cpu_inc((net)->ct.stat->count)
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 29d6a94..723b61c 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -68,7 +68,6 @@ struct ct_pcpu {
 	spinlock_t		lock;
 	struct hlist_nulls_head unconfirmed;
 	struct hlist_nulls_head dying;
-	struct hlist_nulls_head tmpl;
 };
 
 struct netns_ct {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 13fad86..651039a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -287,6 +287,46 @@ static void nf_ct_del_from_dying_or_unconfirmed_list(struct nf_conn *ct)
 	spin_unlock(&pcpu->lock);
 }
 
+/* Released via destroy_conntrack() */
+struct nf_conn *nf_ct_tmpl_alloc(struct net *net, u16 zone, gfp_t flags)
+{
+	struct nf_conn *tmpl;
+
+	tmpl = kzalloc(sizeof(struct nf_conn), GFP_KERNEL);
+	if (tmpl == NULL)
+		return NULL;
+
+	tmpl->status = IPS_TEMPLATE;
+	write_pnet(&tmpl->ct_net, net);
+
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	if (zone) {
+		struct nf_conntrack_zone *nf_ct_zone;
+
+		nf_ct_zone = nf_ct_ext_add(tmpl, NF_CT_EXT_ZONE, GFP_ATOMIC);
+		if (!nf_ct_zone)
+			goto out_free;
+		nf_ct_zone->id = zone;
+	}
+#endif
+	atomic_set(&tmpl->ct_general.use, 0);
+
+	return tmpl;
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+out_free:
+	kfree(tmpl);
+	return NULL;
+#endif
+}
+EXPORT_SYMBOL_GPL(nf_ct_tmpl_alloc);
+
+static void nf_ct_tmpl_free(struct nf_conn *tmpl)
+{
+	nf_ct_ext_destroy(tmpl);
+	nf_ct_ext_free(tmpl);
+	kfree(tmpl);
+}
+
 static void
 destroy_conntrack(struct nf_conntrack *nfct)
 {
@@ -298,6 +338,10 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	NF_CT_ASSERT(atomic_read(&nfct->use) == 0);
 	NF_CT_ASSERT(!timer_pending(&ct->timeout));
 
+	if (unlikely(nf_ct_is_template(ct))) {
+		nf_ct_tmpl_free(ct);
+		return;
+	}
 	rcu_read_lock();
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto && l4proto->destroy)
@@ -540,28 +584,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_check_insert);
 
-/* deletion from this larval template list happens via nf_ct_put() */
-void nf_conntrack_tmpl_insert(struct net *net, struct nf_conn *tmpl)
-{
-	struct ct_pcpu *pcpu;
-
-	__set_bit(IPS_TEMPLATE_BIT, &tmpl->status);
-	__set_bit(IPS_CONFIRMED_BIT, &tmpl->status);
-	nf_conntrack_get(&tmpl->ct_general);
-
-	/* add this conntrack to the (per cpu) tmpl list */
-	local_bh_disable();
-	tmpl->cpu = smp_processor_id();
-	pcpu = per_cpu_ptr(nf_ct_net(tmpl)->ct.pcpu_lists, tmpl->cpu);
-
-	spin_lock(&pcpu->lock);
-	/* Overload tuple linked list to put us in template list. */
-	hlist_nulls_add_head_rcu(&tmpl->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
-				 &pcpu->tmpl);
-	spin_unlock_bh(&pcpu->lock);
-}
-EXPORT_SYMBOL_GPL(nf_conntrack_tmpl_insert);
-
 /* Confirm a connection given skb; places it in hash table */
 int
 __nf_conntrack_confirm(struct sk_buff *skb)
@@ -1751,7 +1773,6 @@ int nf_conntrack_init_net(struct net *net)
 		spin_lock_init(&pcpu->lock);
 		INIT_HLIST_NULLS_HEAD(&pcpu->unconfirmed, UNCONFIRMED_NULLS_VAL);
 		INIT_HLIST_NULLS_HEAD(&pcpu->dying, DYING_NULLS_VAL);
-		INIT_HLIST_NULLS_HEAD(&pcpu->tmpl, TEMPLATE_NULLS_VAL);
 	}
 
 	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 789feea..71f1e9f 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -349,12 +349,10 @@ static void __net_exit synproxy_proc_exit(struct net *net)
 static int __net_init synproxy_net_init(struct net *net)
 {
 	struct synproxy_net *snet = synproxy_pernet(net);
-	struct nf_conntrack_tuple t;
 	struct nf_conn *ct;
 	int err = -ENOMEM;
 
-	memset(&t, 0, sizeof(t));
-	ct = nf_conntrack_alloc(net, 0, &t, &t, GFP_KERNEL);
+	ct = nf_ct_tmpl_alloc(net, 0, GFP_KERNEL);
 	if (IS_ERR(ct)) {
 		err = PTR_ERR(ct);
 		goto err1;
@@ -365,7 +363,8 @@ static int __net_init synproxy_net_init(struct net *net)
 	if (!nfct_synproxy_ext_add(ct))
 		goto err2;
 
-	nf_conntrack_tmpl_insert(net, ct);
+	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
+	nf_conntrack_get(&ct->ct_general);
 	snet->tmpl = ct;
 
 	snet->stats = alloc_percpu(struct synproxy_stats);
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 75747ae..c663003 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -184,7 +184,6 @@ out:
 static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 			  struct xt_ct_target_info_v1 *info)
 {
-	struct nf_conntrack_tuple t;
 	struct nf_conn *ct;
 	int ret = -EOPNOTSUPP;
 
@@ -202,8 +201,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	if (ret < 0)
 		goto err1;
 
-	memset(&t, 0, sizeof(t));
-	ct = nf_conntrack_alloc(par->net, info->zone, &t, &t, GFP_KERNEL);
+	ct = nf_ct_tmpl_alloc(par->net, info->zone, GFP_KERNEL);
 	ret = PTR_ERR(ct);
 	if (IS_ERR(ct))
 		goto err2;
@@ -227,8 +225,8 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 		if (ret < 0)
 			goto err3;
 	}
-
-	nf_conntrack_tmpl_insert(par->net, ct);
+	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
+	nf_conntrack_get(&ct->ct_general);
 out:
 	info->ct = ct;
 	return 0;
-- 
1.7.10.4
