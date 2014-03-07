From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: do not hold qdisc lock while allocating
 memory
Date: Thu, 06 Mar 2014 22:57:52 -0800
Message-ID: <1394175472.20149.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:52561 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbaCGG5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 01:57:53 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so3622450pdi.16
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 22:57:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Resizing fq hash table allocates memory while holding qdisc spinlock,
with BH disabled.

This is definitely not good, as allocation might sleep.

We can drop the lock and get it when needed, we hold RTNL so no other
changes can happen at the same time.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
---
 net/sched/sch_fq.c |   21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 08ef7a42c0e4..21e251766eb1 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -601,6 +601,7 @@ static int fq_resize(struct Qdisc *sch, u32 log)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
 	struct rb_root *array;
+	void *old_fq_root;
 	u32 idx;
 
 	if (q->fq_root && log == q->fq_trees_log)
@@ -615,13 +616,19 @@ static int fq_resize(struct Qdisc *sch, u32 log)
 	for (idx = 0; idx < (1U << log); idx++)
 		array[idx] = RB_ROOT;
 
-	if (q->fq_root) {
-		fq_rehash(q, q->fq_root, q->fq_trees_log, array, log);
-		fq_free(q->fq_root);
-	}
+	sch_tree_lock(sch);
+
+	old_fq_root = q->fq_root;
+	if (old_fq_root)
+		fq_rehash(q, old_fq_root, q->fq_trees_log, array, log);
+
 	q->fq_root = array;
 	q->fq_trees_log = log;
 
+	sch_tree_unlock(sch);
+
+	fq_free(old_fq_root);
+
 	return 0;
 }
 
@@ -697,9 +704,11 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 		q->flow_refill_delay = usecs_to_jiffies(usecs_delay);
 	}
 
-	if (!err)
+	if (!err) {
+		sch_tree_unlock(sch);
 		err = fq_resize(sch, fq_log);
-
+		sch_tree_lock(sch);
+	}
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = fq_dequeue(sch);
 
