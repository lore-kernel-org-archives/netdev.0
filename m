From: kaber@trash.net
Subject: [PATCH 11/17] netfilter: nfnetlink_log: RCU conversion
Date: Tue, 15 Jun 2010 17:38:37 +0200
Message-ID: <1276616323-20880-12-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932276Ab0FOP34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:56 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

- instances_lock becomes a spinlock
- lockless lookups

While nfnetlink_log probably not performance critical, using less
rwlocks in our code is always welcomed...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nfnetlink_log.c |   49 ++++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index fc9a211..8ec23ec 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -66,9 +66,10 @@ struct nfulnl_instance {
 	u_int16_t group_num;		/* number of this queue */
 	u_int16_t flags;
 	u_int8_t copy_mode;
+	struct rcu_head rcu;
 };
 
-static DEFINE_RWLOCK(instances_lock);
+static DEFINE_SPINLOCK(instances_lock);
 static atomic_t global_seq;
 
 #define INSTANCE_BUCKETS	16
@@ -88,7 +89,7 @@ __instance_lookup(u_int16_t group_num)
 	struct nfulnl_instance *inst;
 
 	head = &instance_table[instance_hashfn(group_num)];
-	hlist_for_each_entry(inst, pos, head, hlist) {
+	hlist_for_each_entry_rcu(inst, pos, head, hlist) {
 		if (inst->group_num == group_num)
 			return inst;
 	}
@@ -106,22 +107,26 @@ instance_lookup_get(u_int16_t group_num)
 {
 	struct nfulnl_instance *inst;
 
-	read_lock_bh(&instances_lock);
+	rcu_read_lock_bh();
 	inst = __instance_lookup(group_num);
 	if (inst)
 		instance_get(inst);
-	read_unlock_bh(&instances_lock);
+	rcu_read_unlock_bh();
 
 	return inst;
 }
 
+static void nfulnl_instance_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct nfulnl_instance, rcu));
+	module_put(THIS_MODULE);
+}
+
 static void
 instance_put(struct nfulnl_instance *inst)
 {
-	if (inst && atomic_dec_and_test(&inst->use)) {
-		kfree(inst);
-		module_put(THIS_MODULE);
-	}
+	if (inst && atomic_dec_and_test(&inst->use))
+		call_rcu_bh(&inst->rcu, nfulnl_instance_free_rcu);
 }
 
 static void nfulnl_timer(unsigned long data);
@@ -132,7 +137,7 @@ instance_create(u_int16_t group_num, int pid)
 	struct nfulnl_instance *inst;
 	int err;
 
-	write_lock_bh(&instances_lock);
+	spin_lock_bh(&instances_lock);
 	if (__instance_lookup(group_num)) {
 		err = -EEXIST;
 		goto out_unlock;
@@ -169,12 +174,12 @@ instance_create(u_int16_t group_num, int pid)
 	hlist_add_head(&inst->hlist,
 		       &instance_table[instance_hashfn(group_num)]);
 
-	write_unlock_bh(&instances_lock);
+	spin_unlock_bh(&instances_lock);
 
 	return inst;
 
 out_unlock:
-	write_unlock_bh(&instances_lock);
+	spin_unlock_bh(&instances_lock);
 	return ERR_PTR(err);
 }
 
@@ -200,9 +205,9 @@ __instance_destroy(struct nfulnl_instance *inst)
 static inline void
 instance_destroy(struct nfulnl_instance *inst)
 {
-	write_lock_bh(&instances_lock);
+	spin_lock_bh(&instances_lock);
 	__instance_destroy(inst);
-	write_unlock_bh(&instances_lock);
+	spin_unlock_bh(&instances_lock);
 }
 
 static int
@@ -672,7 +677,7 @@ nfulnl_rcv_nl_event(struct notifier_block *this,
 		int i;
 
 		/* destroy all instances for this pid */
-		write_lock_bh(&instances_lock);
+		spin_lock_bh(&instances_lock);
 		for  (i = 0; i < INSTANCE_BUCKETS; i++) {
 			struct hlist_node *tmp, *t2;
 			struct nfulnl_instance *inst;
@@ -684,7 +689,7 @@ nfulnl_rcv_nl_event(struct notifier_block *this,
 					__instance_destroy(inst);
 			}
 		}
-		write_unlock_bh(&instances_lock);
+		spin_unlock_bh(&instances_lock);
 	}
 	return NOTIFY_DONE;
 }
@@ -861,19 +866,19 @@ static struct hlist_node *get_first(struct iter_state *st)
 
 	for (st->bucket = 0; st->bucket < INSTANCE_BUCKETS; st->bucket++) {
 		if (!hlist_empty(&instance_table[st->bucket]))
-			return instance_table[st->bucket].first;
+			return rcu_dereference_bh(instance_table[st->bucket].first);
 	}
 	return NULL;
 }
 
 static struct hlist_node *get_next(struct iter_state *st, struct hlist_node *h)
 {
-	h = h->next;
+	h = rcu_dereference_bh(h->next);
 	while (!h) {
 		if (++st->bucket >= INSTANCE_BUCKETS)
 			return NULL;
 
-		h = instance_table[st->bucket].first;
+		h = rcu_dereference_bh(instance_table[st->bucket].first);
 	}
 	return h;
 }
@@ -890,9 +895,9 @@ static struct hlist_node *get_idx(struct iter_state *st, loff_t pos)
 }
 
 static void *seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(instances_lock)
+	__acquires(rcu_bh)
 {
-	read_lock_bh(&instances_lock);
+	rcu_read_lock_bh();
 	return get_idx(seq->private, *pos);
 }
 
@@ -903,9 +908,9 @@ static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
 }
 
 static void seq_stop(struct seq_file *s, void *v)
-	__releases(instances_lock)
+	__releases(rcu_bh)
 {
-	read_unlock_bh(&instances_lock);
+	rcu_read_unlock_bh();
 }
 
 static int seq_show(struct seq_file *s, void *v)
-- 
1.7.0.4

