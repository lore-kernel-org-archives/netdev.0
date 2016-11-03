From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 09/25] net/flowcache: Convert to hotplug state machine
Date: Thu,  3 Nov 2016 15:50:05 +0100
Message-ID: <20161103145021.28528-10-bigeasy@linutronix.de>
References: <20161103145021.28528-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: rt@linutronix.de,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        "David S. Miller" <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161103145021.28528-1-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Install the callbacks via the state machine. Use multi state support to avo=
id
custom list handling for the multiple instances.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: netdev@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 include/net/flow.h         |  1 +
 include/net/flowcache.h    |  2 +-
 net/core/flow.c            | 60 ++++++++++++++++++++----------------------=
----
 net/xfrm/xfrm_policy.c     |  1 +
 5 files changed, 30 insertions(+), 35 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 394eb7ed53be..86b940f19df8 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -56,6 +56,7 @@ enum cpuhp_state {
 	CPUHP_ARM_SHMOBILE_SCU_PREPARE,
 	CPUHP_SH_SH3X_PREPARE,
 	CPUHP_BLK_MQ_PREPARE,
+	CPUHP_NET_FLOW_PREPARE,
 	CPUHP_TIMERS_DEAD,
 	CPUHP_NOTF_ERR_INJ_PREPARE,
 	CPUHP_MIPS_SOC_PREPARE,
diff --git a/include/net/flow.h b/include/net/flow.h
index 035aa7716967..2e386bd6ee63 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -239,6 +239,7 @@ struct flow_cache_object *flow_cache_lookup(struct net =
*net,
 					    void *ctx);
 int flow_cache_init(struct net *net);
 void flow_cache_fini(struct net *net);
+void flow_cache_hp_init(void);
=20
 void flow_cache_flush(struct net *net);
 void flow_cache_flush_deferred(struct net *net);
diff --git a/include/net/flowcache.h b/include/net/flowcache.h
index c8f665ec6e0d..9caf3bfc8d2d 100644
--- a/include/net/flowcache.h
+++ b/include/net/flowcache.h
@@ -17,7 +17,7 @@ struct flow_cache_percpu {
 struct flow_cache {
 	u32				hash_shift;
 	struct flow_cache_percpu __percpu *percpu;
-	struct notifier_block		hotcpu_notifier;
+	struct hlist_node		node;
 	int				low_watermark;
 	int				high_watermark;
 	struct timer_list		rnd_timer;
diff --git a/net/core/flow.c b/net/core/flow.c
index 3937b1b68d5b..841fd7f87b30 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -419,28 +419,20 @@ static int flow_cache_cpu_prepare(struct flow_cache *=
fc, int cpu)
 	return 0;
 }
=20
-static int flow_cache_cpu(struct notifier_block *nfb,
-			  unsigned long action,
-			  void *hcpu)
+static int flow_cache_cpu_up_prep(unsigned int cpu, struct hlist_node *nod=
e)
 {
-	struct flow_cache *fc =3D container_of(nfb, struct flow_cache,
-						hotcpu_notifier);
-	int res, cpu =3D (unsigned long) hcpu;
+	struct flow_cache *fc =3D hlist_entry_safe(node, struct flow_cache, node);
+
+	return flow_cache_cpu_prepare(fc, cpu);
+}
+
+static int flow_cache_cpu_dead(unsigned int cpu, struct hlist_node *node)
+{
+	struct flow_cache *fc =3D hlist_entry_safe(node, struct flow_cache, node);
 	struct flow_cache_percpu *fcp =3D per_cpu_ptr(fc->percpu, cpu);
=20
-	switch (action) {
-	case CPU_UP_PREPARE:
-	case CPU_UP_PREPARE_FROZEN:
-		res =3D flow_cache_cpu_prepare(fc, cpu);
-		if (res)
-			return notifier_from_errno(res);
-		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		__flow_cache_shrink(fc, fcp, 0);
-		break;
-	}
-	return NOTIFY_OK;
+	__flow_cache_shrink(fc, fcp, 0);
+	return 0;
 }
=20
 int flow_cache_init(struct net *net)
@@ -467,18 +459,8 @@ int flow_cache_init(struct net *net)
 	if (!fc->percpu)
 		return -ENOMEM;
=20
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(i) {
-		if (flow_cache_cpu_prepare(fc, i))
-			goto err;
-	}
-	fc->hotcpu_notifier =3D (struct notifier_block){
-		.notifier_call =3D flow_cache_cpu,
-	};
-	__register_hotcpu_notifier(&fc->hotcpu_notifier);
-
-	cpu_notifier_register_done();
+	if (cpuhp_state_add_instance(CPUHP_NET_FLOW_PREPARE, &fc->node))
+		goto err;
=20
 	setup_timer(&fc->rnd_timer, flow_cache_new_hashrnd,
 		    (unsigned long) fc);
@@ -494,8 +476,6 @@ int flow_cache_init(struct net *net)
 		fcp->hash_table =3D NULL;
 	}
=20
-	cpu_notifier_register_done();
-
 	free_percpu(fc->percpu);
 	fc->percpu =3D NULL;
=20
@@ -509,7 +489,8 @@ void flow_cache_fini(struct net *net)
 	struct flow_cache *fc =3D &net->xfrm.flow_cache_global;
=20
 	del_timer_sync(&fc->rnd_timer);
-	unregister_hotcpu_notifier(&fc->hotcpu_notifier);
+
+	cpuhp_state_remove_instance_nocalls(CPUHP_NET_FLOW_PREPARE, &fc->node);
=20
 	for_each_possible_cpu(i) {
 		struct flow_cache_percpu *fcp =3D per_cpu_ptr(fc->percpu, i);
@@ -521,3 +502,14 @@ void flow_cache_fini(struct net *net)
 	fc->percpu =3D NULL;
 }
 EXPORT_SYMBOL(flow_cache_fini);
+
+void __init flow_cache_hp_init(void)
+{
+	int ret;
+
+	ret =3D cpuhp_setup_state_multi(CPUHP_NET_FLOW_PREPARE,
+				      "net/flow:prepare",
+				      flow_cache_cpu_up_prep,
+				      flow_cache_cpu_dead);
+	WARN_ON(ret < 0);
+}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fd6986634e6f..4a8eff11bdad 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3111,6 +3111,7 @@ static struct pernet_operations __net_initdata xfrm_n=
et_ops =3D {
=20
 void __init xfrm_init(void)
 {
+	flow_cache_hp_init();
 	register_pernet_subsys(&xfrm_net_ops);
 	seqcount_init(&xfrm_policy_hash_generation);
 	xfrm_input_init();
--=20
2.10.2
