From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] pkt_sched: fq: more robust memory allocation
Date: Sun, 15 Dec 2013 13:15:25 -0800
Message-ID: <1387142125.19078.219.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386894912.19078.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39166 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab3LOVP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 16:15:27 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so4530364pdi.38
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 13:15:27 -0800 (PST)
In-Reply-To: <1386894912.19078.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch brings NUMA support and automatic fallback to vmalloc()
in case kmalloc() failed to allocate FQ hash table.

NUMA support depends on XPS being setup for the device before
qdisc allocation. After a XPS change, it might be worth creating
qdisc hierarchy again.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: added fq_alloc_node() as David suggested

 net/sched/sch_fq.c |   34 ++++++++++++++++++++++++++++------
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 95d843961907..f2fb92dd970d 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -47,6 +47,7 @@
 #include <linux/rbtree.h>
 #include <linux/hash.h>
 #include <linux/prefetch.h>
+#include <linux/vmalloc.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/sock.h>
@@ -578,15 +579,36 @@ static void fq_rehash(struct fq_sched_data *q,
 	q->stat_gc_flows += fcnt;
 }
 
-static int fq_resize(struct fq_sched_data *q, u32 log)
+static void *fq_alloc_node(size_t sz, int node)
 {
+	void *ptr;
+
+	ptr = kmalloc_node(sz, GFP_KERNEL | __GFP_REPEAT | __GFP_NOWARN, node);
+	if (!ptr)
+		ptr = vmalloc_node(sz, node);
+	return ptr;
+}
+
+static void fq_free(void *addr)
+{
+	if (addr && is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
+
+static int fq_resize(struct Qdisc *sch, u32 log)
+{
+	struct fq_sched_data *q = qdisc_priv(sch);
 	struct rb_root *array;
 	u32 idx;
 
 	if (q->fq_root && log == q->fq_trees_log)
 		return 0;
 
-	array = kmalloc(sizeof(struct rb_root) << log, GFP_KERNEL);
+	/* If XPS was setup, we can allocate memory on right NUMA node */
+	array = fq_alloc_node(sizeof(struct rb_root) << log,
+			      netdev_queue_numa_node_read(sch->dev_queue));
 	if (!array)
 		return -ENOMEM;
 
@@ -595,7 +617,7 @@ static int fq_resize(struct fq_sched_data *q, u32 log)
 
 	if (q->fq_root) {
 		fq_rehash(q, q->fq_root, q->fq_trees_log, array, log);
-		kfree(q->fq_root);
+		fq_free(q->fq_root);
 	}
 	q->fq_root = array;
 	q->fq_trees_log = log;
@@ -676,7 +698,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	if (!err)
-		err = fq_resize(q, fq_log);
+		err = fq_resize(sch, fq_log);
 
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = fq_dequeue(sch);
@@ -697,7 +719,7 @@ static void fq_destroy(struct Qdisc *sch)
 	struct fq_sched_data *q = qdisc_priv(sch);
 
 	fq_reset(sch);
-	kfree(q->fq_root);
+	fq_free(q->fq_root);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
@@ -723,7 +745,7 @@ static int fq_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt)
 		err = fq_change(sch, opt);
 	else
-		err = fq_resize(q, q->fq_trees_log);
+		err = fq_resize(sch, q->fq_trees_log);
 
 	return err;
 }
