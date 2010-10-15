From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/3] fib_hash: RCU conversion phase 1
Date: Fri, 15 Oct 2010 08:53:34 +0200
Message-ID: <1287125614.2659.1841.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60939 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232Ab0JOGx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 02:53:56 -0400
Received: by wyb28 with SMTP id 28so353778wyb.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 23:53:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First step for RCU conversion of fib_hash :

struct fn_zone are created and never deleted.

Very classic conversion, using rcu_assign_pointer(), rcu_dereference()
and rtnl_dereference() verbs.

__rcu markers on fz_next and fn_zone_list

They are created under RTNL, we dont need fib_hash_lock anymore in
fn_new_zone().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_hash.c |   57 ++++++++++++++++++++++++++++--------------
 1 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 10001aa..04f05a9 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -57,7 +57,7 @@ struct fib_node {
 #define EMBEDDED_HASH_SIZE (L1_CACHE_BYTES / sizeof(struct hlist_head))
 
 struct fn_zone {
-	struct fn_zone		*fz_next;	/* Next not empty zone	*/
+	struct fn_zone __rcu	*fz_next;	/* Next not empty zone	*/
 	struct hlist_head	*fz_hash;	/* Hash table pointer	*/
 	u32			fz_hashmask;	/* (fz_divisor - 1)	*/
 
@@ -73,8 +73,8 @@ struct fn_zone {
 };
 
 struct fn_hash {
-	struct fn_zone	*fn_zones[33];
-	struct fn_zone	*fn_zone_list;
+	struct fn_zone		*fn_zones[33];
+	struct fn_zone __rcu	*fn_zone_list;
 };
 
 static inline u32 fn_hash(__be32 key, struct fn_zone *fz)
@@ -219,21 +219,21 @@ fn_new_zone(struct fn_hash *table, int z)
 	fz->fz_mask = inet_make_mask(z);
 
 	/* Find the first not empty zone with more specific mask */
-	for (i=z+1; i<=32; i++)
+	for (i = z + 1; i <= 32; i++)
 		if (table->fn_zones[i])
 			break;
-	write_lock_bh(&fib_hash_lock);
-	if (i>32) {
+	if (i > 32) {
 		/* No more specific masks, we are the first. */
-		fz->fz_next = table->fn_zone_list;
-		table->fn_zone_list = fz;
+		rcu_assign_pointer(fz->fz_next,
+				   rtnl_dereference(table->fn_zone_list));
+		rcu_assign_pointer(table->fn_zone_list, fz);
 	} else {
-		fz->fz_next = table->fn_zones[i]->fz_next;
-		table->fn_zones[i]->fz_next = fz;
+		rcu_assign_pointer(fz->fz_next,
+				   rtnl_dereference(table->fn_zones[i]->fz_next));
+		rcu_assign_pointer(table->fn_zones[i]->fz_next, fz);
 	}
 	table->fn_zones[z] = fz;
 	fib_hash_genid++;
-	write_unlock_bh(&fib_hash_lock);
 	return fz;
 }
 
@@ -245,8 +245,11 @@ int fib_table_lookup(struct fib_table *tb,
 	struct fn_zone *fz;
 	struct fn_hash *t = (struct fn_hash *)tb->tb_data;
 
+	rcu_read_lock();
 	read_lock(&fib_hash_lock);
-	for (fz = t->fn_zone_list; fz; fz = fz->fz_next) {
+	for (fz = rcu_dereference(t->fn_zone_list);
+	     fz != NULL;
+	     fz = rcu_dereference(fz->fz_next)) {
 		struct hlist_head *head;
 		struct hlist_node *node;
 		struct fib_node *f;
@@ -267,6 +270,7 @@ int fib_table_lookup(struct fib_table *tb,
 	err = 1;
 out:
 	read_unlock(&fib_hash_lock);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -362,6 +366,7 @@ static struct fib_node *fib_find_node(struct fn_zone *fz, __be32 key)
 	return NULL;
 }
 
+/* Caller must hold RTNL. */
 int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
@@ -657,13 +662,16 @@ static int fn_flush_list(struct fn_zone *fz, int idx)
 	return found;
 }
 
+/* caller must hold RTNL. */
 int fib_table_flush(struct fib_table *tb)
 {
 	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
 	struct fn_zone *fz;
 	int found = 0;
 
-	for (fz = table->fn_zone_list; fz; fz = fz->fz_next) {
+	for (fz = rtnl_dereference(table->fn_zone_list);
+	     fz != NULL;
+	     fz = rtnl_dereference(fz->fz_next)) {
 		int i;
 
 		for (i = fz->fz_divisor - 1; i >= 0; i--)
@@ -741,23 +749,29 @@ fn_hash_dump_zone(struct sk_buff *skb, struct netlink_callback *cb,
 int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 		   struct netlink_callback *cb)
 {
-	int m, s_m;
+	int m = 0, s_m;
 	struct fn_zone *fz;
 	struct fn_hash *table = (struct fn_hash *)tb->tb_data;
 
 	s_m = cb->args[2];
+	rcu_read_lock();
 	read_lock(&fib_hash_lock);
-	for (fz = table->fn_zone_list, m=0; fz; fz = fz->fz_next, m++) {
-		if (m < s_m) continue;
+	for (fz = rcu_dereference(table->fn_zone_list);
+	     fz != NULL;
+	     fz = rcu_dereference(fz->fz_next), m++) {
+		if (m < s_m)
+			continue;
 		if (fn_hash_dump_zone(skb, cb, tb, fz) < 0) {
 			cb->args[2] = m;
 			read_unlock(&fib_hash_lock);
+			rcu_read_unlock();
 			return -1;
 		}
 		memset(&cb->args[3], 0,
 		       sizeof(cb->args) - 3*sizeof(cb->args[0]));
 	}
 	read_unlock(&fib_hash_lock);
+	rcu_read_unlock();
 	cb->args[2] = m;
 	return skb->len;
 }
@@ -820,8 +834,9 @@ static struct fib_alias *fib_get_first(struct seq_file *seq)
 	iter->genid	= fib_hash_genid;
 	iter->valid	= 1;
 
-	for (iter->zone = table->fn_zone_list; iter->zone;
-	     iter->zone = iter->zone->fz_next) {
+	for (iter->zone = rcu_dereference(table->fn_zone_list);
+	     iter->zone != NULL;
+	     iter->zone = rcu_dereference(iter->zone->fz_next)) {
 		int maxslot;
 
 		if (!iter->zone->fz_nent)
@@ -906,7 +921,7 @@ static struct fib_alias *fib_get_next(struct seq_file *seq)
 			}
 		}
 
-		iter->zone = iter->zone->fz_next;
+		iter->zone = rcu_dereference(iter->zone->fz_next);
 
 		if (!iter->zone)
 			goto out;
@@ -946,9 +961,11 @@ static struct fib_alias *fib_get_idx(struct seq_file *seq, loff_t pos)
 
 static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(fib_hash_lock)
+	__acquires(RCU)
 {
 	void *v = NULL;
 
+	rcu_read_lock();
 	read_lock(&fib_hash_lock);
 	if (fib_get_table(seq_file_net(seq), RT_TABLE_MAIN))
 		v = *pos ? fib_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -963,8 +980,10 @@ static void *fib_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 static void fib_seq_stop(struct seq_file *seq, void *v)
 	__releases(fib_hash_lock)
+	__releases(RCU)
 {
 	read_unlock(&fib_hash_lock);
+	rcu_read_unlock();
 }
 
 static unsigned fib_flag_trans(int type, __be32 mask, struct fib_info *fi)


