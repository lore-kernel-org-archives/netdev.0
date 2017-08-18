From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] ipv4: convert dst_metrics.refcnt from atomic_t
 to refcount_t
Date: Fri, 18 Aug 2017 12:08:07 -0700
Message-ID: <1503083287.22502.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502911469.4936.148.camel@edumazet-glaptop3.roam.corp.google.com>
         <1502925599.4936.153.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWbxs6aa-axQrwN5pipaCDX3ws_08LaQON8p4WfrJ7SDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35424 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdHRTIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 15:08:10 -0400
Received: by mail-pg0-f65.google.com with SMTP id t80so10188556pgb.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 12:08:10 -0700 (PDT)
In-Reply-To: <CAM_iQpWbxs6aa-axQrwN5pipaCDX3ws_08LaQON8p4WfrJ7SDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v3: added the include <linux/refcount.h> to be safe (Cong Wang)
v2: fix a missing change in net/ipv4/fib_semantics.c

 include/net/dst.h        |    3 ++-
 net/core/dst.c           |    6 +++---
 net/ipv4/fib_semantics.c |    4 ++--
 net/ipv4/route.c         |    4 ++--
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index f73611ec401754d4f52b5310a24da53566dafce6..93568bd0a3520bb7402f04d90cf04ac99c81cfbe 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -14,6 +14,7 @@
 #include <linux/rcupdate.h>
 #include <linux/bug.h>
 #include <linux/jiffies.h>
+#include <linux/refcount.h>
 #include <net/neighbour.h>
 #include <asm/processor.h>
 
@@ -107,7 +108,7 @@ struct dst_entry {
 
 struct dst_metrics {
 	u32		metrics[RTAX_MAX];
-	atomic_t	refcnt;
+	refcount_t	refcnt;
 };
 extern const struct dst_metrics dst_default_metrics;
 
diff --git a/net/core/dst.c b/net/core/dst.c
index 00aa972ad1a1a451c24f3f8211243ad35c19433a..d6ead757c25895da01eb61bc9636c7e9b3cdfb3e 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -55,7 +55,7 @@ const struct dst_metrics dst_default_metrics = {
 	 * We really want to avoid false sharing on this variable, and catch
 	 * any writes on it.
 	 */
-	.refcnt = ATOMIC_INIT(1),
+	.refcnt = REFCOUNT_INIT(1),
 };
 
 void dst_init(struct dst_entry *dst, struct dst_ops *ops,
@@ -213,7 +213,7 @@ u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
 		struct dst_metrics *old_p = (struct dst_metrics *)__DST_METRICS_PTR(old);
 		unsigned long prev, new;
 
-		atomic_set(&p->refcnt, 1);
+		refcount_set(&p->refcnt, 1);
 		memcpy(p->metrics, old_p->metrics, sizeof(p->metrics));
 
 		new = (unsigned long) p;
@@ -225,7 +225,7 @@ u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old)
 			if (prev & DST_METRICS_READ_ONLY)
 				p = NULL;
 		} else if (prev & DST_METRICS_REFCOUNTED) {
-			if (atomic_dec_and_test(&old_p->refcnt))
+			if (refcount_dec_and_test(&old_p->refcnt))
 				kfree(old_p);
 		}
 	}
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d521caf57385fa05f76036708057b95052330cb1..394d800db50c77c21b65e14569eb4d8b5246406f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -220,7 +220,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	} endfor_nexthops(fi);
 
 	m = fi->fib_metrics;
-	if (m != &dst_default_metrics && atomic_dec_and_test(&m->refcnt))
+	if (m != &dst_default_metrics && refcount_dec_and_test(&m->refcnt))
 		kfree(m);
 	kfree(fi);
 }
@@ -1090,7 +1090,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 			kfree(fi);
 			return ERR_PTR(err);
 		}
-		atomic_set(&fi->fib_metrics->refcnt, 1);
+		refcount_set(&fi->fib_metrics->refcnt, 1);
 	} else {
 		fi->fib_metrics = (struct dst_metrics *)&dst_default_metrics;
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d400c05431063fc7bdd15b83ab540acc86decb3d..872b4cb136d3fa0cda403836cc83a156a65310a3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1398,7 +1398,7 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 	struct dst_metrics *p = (struct dst_metrics *)DST_METRICS_PTR(dst);
 	struct rtable *rt = (struct rtable *) dst;
 
-	if (p != &dst_default_metrics && atomic_dec_and_test(&p->refcnt))
+	if (p != &dst_default_metrics && refcount_dec_and_test(&p->refcnt))
 		kfree(p);
 
 	if (!list_empty(&rt->rt_uncached)) {
@@ -1456,7 +1456,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 		dst_init_metrics(&rt->dst, fi->fib_metrics->metrics, true);
 		if (fi->fib_metrics != &dst_default_metrics) {
 			rt->dst._metrics |= DST_METRICS_REFCOUNTED;
-			atomic_inc(&fi->fib_metrics->refcnt);
+			refcount_inc(&fi->fib_metrics->refcnt);
 		}
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
