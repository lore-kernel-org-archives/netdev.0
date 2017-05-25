From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: add reference counting to metrics
Date: Thu, 25 May 2017 14:27:35 -0700
Message-ID: <1495747655.6465.113.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
         <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
         <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg>
         <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
         <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg>
         <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
         <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
         <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg>
         <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com>
         <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg>
         <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com>
         <alpine.LFD.2.20.1705152317090.4002@ja.home.ssi.bg>
         <CAM_iQpWAjTJL54h_Pdg3DigjEK4kQdSz0pmAks6ByoP67ROOFg@mail.gmail.com>
         <alpine.LFD.2.20.1705160955310.1856@ja.home.ssi.bg>
         <CAM_iQpVuqBkQxq=g4n5t33Gv0mxR_S0iOtQxgBHKceam8pmwfQ@mail.gmail.com>
         <CAM_iQpVBKjwqmU1p-xLYwy=032fewdCfDetaSxC+aQoE=dgMfQ@mail.gmail.com>
         <1495572267.6465.79.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpX0X3h4Sf+bHUXdJgBqUTxNat0FBT0PeRpLYWju9ci59Q@mail.gmail.com>
         <CANn89i+mPR+7-AVO2Dsd=KfO=COOVY42AKjwEs=0=GUCML6HUQ@mail.gmail.com>
         <CAM_iQpUfLmN3yWsCfpx4ZTptBnuYFNuY5CjBKdwoDpvH5K8P=w@mail.gmail.com>
         <1495665921.6465.95.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Julian Anastasov <ja@ssi.bg>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35854 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939112AbdEYV1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 17:27:42 -0400
Received: by mail-pf0-f194.google.com with SMTP id n23so41500640pfb.3
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 14:27:42 -0700 (PDT)
In-Reply-To: <1495665921.6465.95.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andrey Konovalov reported crashes in ipv4_mtu()

I could reproduce the issue with KASAN kernels, between
10.246.7.151 and 10.246.7.152 :

1) 20 concurrent netperf -t TCP_RR -H 10.246.7.152 -l 1000 &

2) At the same time run following loop :
while :
do
 ip ro add 10.246.7.152 dev eth0 src 10.246.7.151 mtu 1500
 ip ro del 10.246.7.152 dev eth0 src 10.246.7.151 mtu 1500
done


Cong Wang attempted to add back rt->fi in commit
82486aa6f1b9 ("ipv4: restore rt->fi for reference counting")
but this proved to add some issues that were complex to solve.

Instead, I suggested to add a refcount to the metrics themselves,
being a standalone object (in particular, no reference to other objects)

I tried to make this patch as small as possible to ease its backport,
instead of being super clean. Note that we believe that only ipv4 dst
need to take care of the metric refcount. But if this is wrong,
this patch adds the basic infrastructure to extend this to other
families.

Many thanks to Julian Anastasov for reviewing this patch, and Cong Wang
for his efforts on this problem.

Fixes: 2860583fe840 ("ipv4: Kill rt->fi")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/net/dst.h        |    8 +++++++-
 include/net/ip_fib.h     |   10 +++++-----
 net/core/dst.c           |   23 ++++++++++++++---------
 net/ipv4/fib_semantics.c |   17 ++++++++++-------
 net/ipv4/route.c         |   10 +++++++++-
 5 files changed, 45 insertions(+), 23 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 049af33da3b6c95897d544670cea65c542317673..cfc0437841665d7ed46a714915c50d723c24901c 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -107,10 +107,16 @@ struct dst_entry {
 	};
 };
 
+struct dst_metrics {
+	u32		metrics[RTAX_MAX];
+	atomic_t	refcnt;
+};
+extern const struct dst_metrics dst_default_metrics;
+
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
-extern const u32 dst_default_metrics[];
 
 #define DST_METRICS_READ_ONLY		0x1UL
+#define DST_METRICS_REFCOUNTED		0x2UL
 #define DST_METRICS_FLAGS		0x3UL
 #define __DST_METRICS_PTR(Y)	\
 	((u32 *)((Y) & ~DST_METRICS_FLAGS))
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 6692c5758b332d468f1e0611ecc4f3e03ae03b2b..f7f6aa789c6174c41ca9739206d586c559c1f3a1 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -114,11 +114,11 @@ struct fib_info {
 	__be32			fib_prefsrc;
 	u32			fib_tb_id;
 	u32			fib_priority;
-	u32			*fib_metrics;
-#define fib_mtu fib_metrics[RTAX_MTU-1]
-#define fib_window fib_metrics[RTAX_WINDOW-1]
-#define fib_rtt fib_metrics[RTAX_RTT-1]
-#define fib_advmss fib_metrics[RTAX_ADVMSS-1]
+	struct dst_metrics	*fib_metrics;
+#define fib_mtu fib_metrics->metrics[RTAX_MTU-1]
+#define fib_window fib_metrics->metrics[RTAX_WINDOW-1]
+#define fib_rtt fib_metrics->metrics[RTAX_RTT-1]
+#define fib_advmss fib_metrics->metrics[RTAX_ADVMSS-1]
 	int			fib_nhs;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_weight;
diff --git a/net/core/dst.c b/net/core/dst.c
index 960e503b5a529a2c4f1866f49c150493ee98d7da..6192f11beec9077de964e2aeff4f78547f08b8da 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -151,13 +151,13 @@ int dst_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dst_discard_out);
 
-const u32 dst_default_metrics[RTAX_MAX + 1] = {
+const struct dst_metrics dst_default_metrics = {
 	/* This initializer is needed to force linker to place this variable
 	 * into const section. Otherwise it might end into bss section.
 	 * We really want to avoid false sharing on this variable, and catch
 	 * any writes on it.
 	 */
-	[RTAX_MAX] = 0xdeadbeef,
+	.refcnt = ATOMIC_INIT(1),
 };
 
 void dst_init(struct dst_entry *dst, struct dst_ops *ops,
@@ -169,7 +169,7 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	if (dev)
 		dev_hold(dev);
 	dst->ops = ops;
-	dst_init_metrics(dst, dst_default_metrics, true);
+	dst_init_metrics(dst, dst_default_metrics.metrics, true);
 	dst->expires = 0UL;
 	dst->path = dst;
 	dst->from = NULL;
@@ -314,25 +314,30 @@ EXPORT_SYMBOL(dst_release);
 
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
 {
-	u32 *p = kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
+	struct dst_metrics *p = kmalloc(sizeof(*p), GFP_ATOMIC);
 
 	if (p) {
-		u32 *old_p = __DST_METRICS_PTR(old);
+		struct dst_metrics *old_p = (struct dst_metrics *)__DST_METRICS_PTR(old);
 		unsigned long prev, new;
 
-		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+		atomic_set(&p->refcnt, 1);
+		memcpy(p->metrics, old_p->metrics, sizeof(p->metrics));
 
 		new = (unsigned long) p;
 		prev = cmpxchg(&dst->_metrics, old, new);
 
 		if (prev != old) {
 			kfree(p);
-			p = __DST_METRICS_PTR(prev);
+			p = (struct dst_metrics *)__DST_METRICS_PTR(prev);
 			if (prev & DST_METRICS_READ_ONLY)
 				p = NULL;
+		} else if (prev & DST_METRICS_REFCOUNTED) {
+			if (atomic_dec_and_test(&old_p->refcnt))
+				kfree(old_p);
 		}
 	}
-	return p;
+	BUILD_BUG_ON(offsetof(struct dst_metrics, metrics) != 0);
+	return (u32 *)p;
 }
 EXPORT_SYMBOL(dst_cow_metrics_generic);
 
@@ -341,7 +346,7 @@ void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old)
 {
 	unsigned long prev, new;
 
-	new = ((unsigned long) dst_default_metrics) | DST_METRICS_READ_ONLY;
+	new = ((unsigned long) &dst_default_metrics) | DST_METRICS_READ_ONLY;
 	prev = cmpxchg(&dst->_metrics, old, new);
 	if (prev == old)
 		kfree(__DST_METRICS_PTR(old));
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da449ddb8cc172bd9091c00057a69a095f98b56d..ad9ad4aab5da7c7d11c3b80edbdfcbdd3d7153fe 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -203,6 +203,7 @@ static void rt_fibinfo_free_cpus(struct rtable __rcu * __percpu *rtp)
 static void free_fib_info_rcu(struct rcu_head *head)
 {
 	struct fib_info *fi = container_of(head, struct fib_info, rcu);
+	struct dst_metrics *m;
 
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
@@ -213,8 +214,9 @@ static void free_fib_info_rcu(struct rcu_head *head)
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
 	} endfor_nexthops(fi);
 
-	if (fi->fib_metrics != (u32 *) dst_default_metrics)
-		kfree(fi->fib_metrics);
+	m = fi->fib_metrics;
+	if (m != &dst_default_metrics && atomic_dec_and_test(&m->refcnt))
+		kfree(m);
 	kfree(fi);
 }
 
@@ -971,11 +973,11 @@ fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
 			val = 255;
 		if (type == RTAX_FEATURES && (val & ~RTAX_FEATURE_MASK))
 			return -EINVAL;
-		fi->fib_metrics[type - 1] = val;
+		fi->fib_metrics->metrics[type - 1] = val;
 	}
 
 	if (ecn_ca)
-		fi->fib_metrics[RTAX_FEATURES - 1] |= DST_FEATURE_ECN_CA;
+		fi->fib_metrics->metrics[RTAX_FEATURES - 1] |= DST_FEATURE_ECN_CA;
 
 	return 0;
 }
@@ -1033,11 +1035,12 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		goto failure;
 	fib_info_cnt++;
 	if (cfg->fc_mx) {
-		fi->fib_metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
+		fi->fib_metrics = kzalloc(sizeof(*fi->fib_metrics), GFP_KERNEL);
 		if (!fi->fib_metrics)
 			goto failure;
+		atomic_set(&fi->fib_metrics->refcnt, 1);
 	} else
-		fi->fib_metrics = (u32 *) dst_default_metrics;
+		fi->fib_metrics = (struct dst_metrics *)&dst_default_metrics;
 
 	fi->fib_net = net;
 	fi->fib_protocol = cfg->fc_protocol;
@@ -1238,7 +1241,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	if (fi->fib_priority &&
 	    nla_put_u32(skb, RTA_PRIORITY, fi->fib_priority))
 		goto nla_put_failure;
-	if (rtnetlink_put_metrics(skb, fi->fib_metrics) < 0)
+	if (rtnetlink_put_metrics(skb, fi->fib_metrics->metrics) < 0)
 		goto nla_put_failure;
 
 	if (fi->fib_prefsrc &&
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 655d9eebe43e16a59102edcd3ea4bc177c6b341d..6883b3d4ba8f69de2cb924612d60f5671a219a84 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1385,8 +1385,12 @@ static void rt_add_uncached_list(struct rtable *rt)
 
 static void ipv4_dst_destroy(struct dst_entry *dst)
 {
+	struct dst_metrics *p = (struct dst_metrics *)DST_METRICS_PTR(dst);
 	struct rtable *rt = (struct rtable *) dst;
 
+	if (p != &dst_default_metrics && atomic_dec_and_test(&p->refcnt))
+		kfree(p);
+
 	if (!list_empty(&rt->rt_uncached)) {
 		struct uncached_list *ul = rt->rt_uncached_list;
 
@@ -1438,7 +1442,11 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			rt->rt_gateway = nh->nh_gw;
 			rt->rt_uses_gateway = 1;
 		}
-		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+		dst_init_metrics(&rt->dst, fi->fib_metrics->metrics, true);
+		if (fi->fib_metrics != &dst_default_metrics) {
+			rt->dst._metrics |= DST_METRICS_REFCOUNTED;
+			atomic_inc(&fi->fib_metrics->refcnt);
+		}
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
