From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net_sched: sch_fq: use rb_entry()
Date: Tue, 20 Dec 2016 22:02:15 +0800
Message-ID: <6aa180710d70b09d4f81d3d219b3161077e1ff11.1482204526.git.geliangtang@gmail.com>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33890 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934512AbcLTODn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 09:03:43 -0500
In-Reply-To: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/sched/sch_fq.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 86309a3..a4f738a 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -136,7 +136,7 @@ static void fq_flow_set_throttled(struct fq_sched_data *q, struct fq_flow *f)
 		struct fq_flow *aux;
 
 		parent = *p;
-		aux = container_of(parent, struct fq_flow, rate_node);
+		aux = rb_entry(parent, struct fq_flow, rate_node);
 		if (f->time_next_packet >= aux->time_next_packet)
 			p = &parent->rb_right;
 		else
@@ -188,7 +188,7 @@ static void fq_gc(struct fq_sched_data *q,
 	while (*p) {
 		parent = *p;
 
-		f = container_of(parent, struct fq_flow, fq_node);
+		f = rb_entry(parent, struct fq_flow, fq_node);
 		if (f->sk == sk)
 			break;
 
@@ -256,7 +256,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 	while (*p) {
 		parent = *p;
 
-		f = container_of(parent, struct fq_flow, fq_node);
+		f = rb_entry(parent, struct fq_flow, fq_node);
 		if (f->sk == sk) {
 			/* socket might have been reallocated, so check
 			 * if its sk_hash is the same.
@@ -424,7 +424,7 @@ static void fq_check_throttled(struct fq_sched_data *q, u64 now)
 
 	q->time_next_delayed_flow = ~0ULL;
 	while ((p = rb_first(&q->delayed)) != NULL) {
-		struct fq_flow *f = container_of(p, struct fq_flow, rate_node);
+		struct fq_flow *f = rb_entry(p, struct fq_flow, rate_node);
 
 		if (f->time_next_packet > now) {
 			q->time_next_delayed_flow = f->time_next_packet;
@@ -563,7 +563,7 @@ static void fq_reset(struct Qdisc *sch)
 	for (idx = 0; idx < (1U << q->fq_trees_log); idx++) {
 		root = &q->fq_root[idx];
 		while ((p = rb_first(root)) != NULL) {
-			f = container_of(p, struct fq_flow, fq_node);
+			f = rb_entry(p, struct fq_flow, fq_node);
 			rb_erase(p, root);
 
 			fq_flow_purge(f);
@@ -593,7 +593,7 @@ static void fq_rehash(struct fq_sched_data *q,
 		oroot = &old_array[idx];
 		while ((op = rb_first(oroot)) != NULL) {
 			rb_erase(op, oroot);
-			of = container_of(op, struct fq_flow, fq_node);
+			of = rb_entry(op, struct fq_flow, fq_node);
 			if (fq_gc_candidate(of)) {
 				fcnt++;
 				kmem_cache_free(fq_flow_cachep, of);
@@ -606,7 +606,7 @@ static void fq_rehash(struct fq_sched_data *q,
 			while (*np) {
 				parent = *np;
 
-				nf = container_of(parent, struct fq_flow, fq_node);
+				nf = rb_entry(parent, struct fq_flow, fq_node);
 				BUG_ON(nf->sk == of->sk);
 
 				if (nf->sk > of->sk)
-- 
2.9.3
