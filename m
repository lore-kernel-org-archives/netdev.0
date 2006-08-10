From: Patrick McHardy <kaber@trash.net>
Subject: [DECNET 05/06]: Increase number of possible routing tables to 2^32
Date: Thu, 10 Aug 2006 21:30:04 +0200 (MEST)
Message-ID: <20060810193004.14867.2690.sendpatchset@localhost.localdomain>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46042 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932071AbWHJTaG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 15:30:06 -0400
To: davem@davemloft.net
In-Reply-To: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[DECNET]: Increase number of possible routing tables to 2^32

Increase the number of possible routing tables to 2^32 by replacing the
fixed sized array of pointers by a hash table and replacing iterations
over all possible table IDs by hash table walking.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9203e4cdab89d96c474c6a903ef9a1f47c7eee07
tree e0c6a2c5e3a691919863b4eb871fc3a25ebd5d44
parent cad398a8f3ef363abba9e6450dded94a022c96fa
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:54:19 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:54:19 +0200

 include/net/dn_fib.h  |    3 -
 net/decnet/dn_fib.c   |   49 -------------------
 net/decnet/dn_rules.c |    2 -
 net/decnet/dn_table.c |  125 ++++++++++++++++++++++++++++++++++++-------------
 4 files changed, 93 insertions(+), 86 deletions(-)

diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index cd9c378..d97aa10 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -94,6 +94,7 @@ #define DN_FIB_INFO(f) ((f)->fn_info)
 
 
 struct dn_fib_table {
+	struct hlist_node hlist;
 	u32 n;
 
 	int (*insert)(struct dn_fib_table *t, struct rtmsg *r, 
@@ -177,8 +178,6 @@ static inline void dn_fib_res_put(struct
 		fib_rule_put(res->r);
 }
 
-extern struct dn_fib_table *dn_fib_tables[];
-
 #else /* Endnode */
 
 #define dn_fib_init()  do { } while(0)
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index fb59637..5ccca3e 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -532,39 +532,6 @@ int dn_fib_rtm_newroute(struct sk_buff *
 	return -ENOBUFS;
 }
 
-
-int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
-{
-	u32 t;
-	u32 s_t;
-	struct dn_fib_table *tb;
-
-	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
-		((struct rtmsg *)NLMSG_DATA(cb->nlh))->rtm_flags&RTM_F_CLONED)
-			return dn_cache_dump(skb, cb);
-
-	s_t = cb->args[0];
-	if (s_t == 0)
-		s_t = cb->args[0] = RT_MIN_TABLE;
-
-	for(t = s_t; t <= RT_TABLE_MAX; t++) {
-		if (t < s_t)
-			continue;
-		if (t > s_t)
-			memset(&cb->args[1], 0,
-			       sizeof(cb->args) - sizeof(cb->args[0]));
-		tb = dn_fib_get_table(t, 0);
-		if (tb == NULL)
-			continue;
-		if (tb->dump(tb, skb, cb) < 0)
-			break;
-	}
-
-	cb->args[0] = t;
-
-	return skb->len;
-}
-
 static void fib_magic(int cmd, int type, __le16 dst, int dst_len, struct dn_ifaddr *ifa)
 {
 	struct dn_fib_table *tb;
@@ -762,22 +729,6 @@ int dn_fib_sync_up(struct net_device *de
         return ret;
 }
 
-void dn_fib_flush(void)
-{
-        int flushed = 0;
-        struct dn_fib_table *tb;
-        u32 id;
-
-        for(id = RT_TABLE_MAX; id > 0; id--) {
-                if ((tb = dn_fib_get_table(id, 0)) == NULL)
-                        continue;
-                flushed += tb->flush(tb);
-        }
-
-        if (flushed)
-                dn_rt_cache_flush(-1);
-}
-
 static struct notifier_block dn_fib_dnaddr_notifier = {
 	.notifier_call = dn_fib_dnaddr_event,
 };
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 096f127..878312f 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -210,7 +210,7 @@ unsigned dnet_addr_type(__le16 addr)
 	struct flowi fl = { .nl_u = { .dn_u = { .daddr = addr } } };
 	struct dn_fib_res res;
 	unsigned ret = RTN_UNICAST;
-	struct dn_fib_table *tb = dn_fib_tables[RT_TABLE_LOCAL];
+	struct dn_fib_table *tb = dn_fib_get_table(RT_TABLE_LOCAL, 0);
 
 	res.r = NULL;
 
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index d2ad791..5701a3f 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -75,9 +75,9 @@ #define DN_FIB_SCAN_KEY(f, fp, key) \
 for( ; ((f) = *(fp)) != NULL && dn_key_eq((f)->fn_key, (key)); (fp) = &(f)->fn_next)
 
 #define RT_TABLE_MIN 1
-
+#define DN_FIB_TABLE_HASHSZ 256
+static struct hlist_head dn_fib_table_hash[DN_FIB_TABLE_HASHSZ];
 static DEFINE_RWLOCK(dn_fib_tables_lock);
-struct dn_fib_table *dn_fib_tables[RT_TABLE_MAX + 1];
 
 static kmem_cache_t *dn_hash_kmem __read_mostly;
 static int dn_fib_hash_zombies;
@@ -357,7 +357,7 @@ static __inline__ int dn_hash_dump_bucke
 {
 	int i, s_i;
 
-	s_i = cb->args[3];
+	s_i = cb->args[4];
 	for(i = 0; f; i++, f = f->fn_next) {
 		if (i < s_i)
 			continue;
@@ -370,11 +370,11 @@ static __inline__ int dn_hash_dump_bucke
 				(f->fn_state & DN_S_ZOMBIE) ? 0 : f->fn_type,
 				f->fn_scope, &f->fn_key, dz->dz_order, 
 				f->fn_info, NLM_F_MULTI) < 0) {
-			cb->args[3] = i;
+			cb->args[4] = i;
 			return -1;
 		}
 	}
-	cb->args[3] = i;
+	cb->args[4] = i;
 	return skb->len;
 }
 
@@ -385,20 +385,20 @@ static __inline__ int dn_hash_dump_zone(
 {
 	int h, s_h;
 
-	s_h = cb->args[2];
+	s_h = cb->args[3];
 	for(h = 0; h < dz->dz_divisor; h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
-			memset(&cb->args[3], 0, sizeof(cb->args) - 3*sizeof(cb->args[0]));
+			memset(&cb->args[4], 0, sizeof(cb->args) - 4*sizeof(cb->args[0]));
 		if (dz->dz_hash == NULL || dz->dz_hash[h] == NULL)
 			continue;
 		if (dn_hash_dump_bucket(skb, cb, tb, dz, dz->dz_hash[h]) < 0) {
-			cb->args[2] = h;
+			cb->args[3] = h;
 			return -1;
 		}
 	}
-	cb->args[2] = h;
+	cb->args[3] = h;
 	return skb->len;
 }
 
@@ -409,26 +409,63 @@ static int dn_fib_table_dump(struct dn_f
 	struct dn_zone *dz;
 	struct dn_hash *table = (struct dn_hash *)tb->data;
 
-	s_m = cb->args[1];
+	s_m = cb->args[2];
 	read_lock(&dn_fib_tables_lock);
 	for(dz = table->dh_zone_list, m = 0; dz; dz = dz->dz_next, m++) {
 		if (m < s_m)
 			continue;
 		if (m > s_m)
-			memset(&cb->args[2], 0, sizeof(cb->args) - 2*sizeof(cb->args[0]));
+			memset(&cb->args[3], 0, sizeof(cb->args) - 3*sizeof(cb->args[0]));
 
 		if (dn_hash_dump_zone(skb, cb, tb, dz) < 0) {
-			cb->args[1] = m;
+			cb->args[2] = m;
 			read_unlock(&dn_fib_tables_lock);
 			return -1;
 		}
 	}
 	read_unlock(&dn_fib_tables_lock);
-	cb->args[1] = m;
+	cb->args[2] = m;
 
         return skb->len;
 }
 
+int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	unsigned int h, s_h;
+	unsigned int e = 0, s_e;
+	struct dn_fib_table *tb;
+	struct hlist_node *node;
+	int dumped = 0;
+
+	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
+		((struct rtmsg *)NLMSG_DATA(cb->nlh))->rtm_flags&RTM_F_CLONED)
+			return dn_cache_dump(skb, cb);
+
+	s_h = cb->args[0];
+	s_e = cb->args[1];
+
+	for (h = s_h; h < DN_FIB_TABLE_HASHSZ; h++, s_h = 0) {
+		e = 0;
+		hlist_for_each_entry(tb, node, &dn_fib_table_hash[h], hlist) {
+			if (e < s_e)
+				goto next;
+			if (dumped)
+				memset(&cb->args[2], 0, sizeof(cb->args) -
+				                 2 * sizeof(cb->args[0]));
+			if (tb->dump(tb, skb, cb) < 0)
+				goto out;
+			dumped = 1;
+next:
+			e++;
+		}
+	}
+out:
+	cb->args[1] = e;
+	cb->args[0] = h;
+
+	return skb->len;
+}
+
 static int dn_fib_table_insert(struct dn_fib_table *tb, struct rtmsg *r, struct dn_kern_rta *rta, struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
 	struct dn_hash *table = (struct dn_hash *)tb->data;
@@ -740,6 +777,8 @@ out:
 struct dn_fib_table *dn_fib_get_table(u32 n, int create)
 {
         struct dn_fib_table *t;
+	struct hlist_node *node;
+	unsigned int h;
 
         if (n < RT_TABLE_MIN)
                 return NULL;
@@ -747,8 +786,15 @@ struct dn_fib_table *dn_fib_get_table(u3
         if (n > RT_TABLE_MAX)
                 return NULL;
 
-        if (dn_fib_tables[n]) 
-                return dn_fib_tables[n];
+	h = n & (DN_FIB_TABLE_HASHSZ - 1);
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(t, node, &dn_fib_table_hash[h], hlist) {
+		if (t->n == n) {
+			rcu_read_unlock();
+			return t;
+		}
+	}
+	rcu_read_unlock();
 
         if (!create)
                 return NULL;
@@ -769,33 +815,37 @@ struct dn_fib_table *dn_fib_get_table(u3
         t->flush  = dn_fib_table_flush;
         t->dump = dn_fib_table_dump;
 	memset(t->data, 0, sizeof(struct dn_hash));
-        dn_fib_tables[n] = t;
+	hlist_add_head_rcu(&t->hlist, &dn_fib_table_hash[h]);
 
         return t;
 }
 
-static void dn_fib_del_tree(u32 n)
-{
-	struct dn_fib_table *t;
-
-	write_lock(&dn_fib_tables_lock);
-	t = dn_fib_tables[n];
-	dn_fib_tables[n] = NULL;
-	write_unlock(&dn_fib_tables_lock);
-
-	kfree(t);
-}
-
 struct dn_fib_table *dn_fib_empty_table(void)
 {
         u32 id;
 
         for(id = RT_TABLE_MIN; id <= RT_TABLE_MAX; id++)
-                if (dn_fib_tables[id] == NULL)
+		if (dn_fib_get_table(id, 0) == NULL)
                         return dn_fib_get_table(id, 1);
         return NULL;
 }
 
+void dn_fib_flush(void)
+{
+        int flushed = 0;
+        struct dn_fib_table *tb;
+	struct hlist_node *node;
+	unsigned int h;
+
+	for (h = 0; h < DN_FIB_TABLE_HASHSZ; h++) {
+		hlist_for_each_entry(tb, node, &dn_fib_table_hash[h], hlist)
+	                flushed += tb->flush(tb);
+        }
+
+        if (flushed)
+                dn_rt_cache_flush(-1);
+}
+
 void __init dn_fib_table_init(void)
 {
 	dn_hash_kmem = kmem_cache_create("dn_fib_info_cache",
@@ -806,10 +856,17 @@ void __init dn_fib_table_init(void)
 
 void __exit dn_fib_table_cleanup(void)
 {
-	int i;
-
-	for (i = RT_TABLE_MIN; i <= RT_TABLE_MAX; ++i)
-		dn_fib_del_tree(i);
+	struct dn_fib_table *t;
+	struct hlist_node *node, *next;
+	unsigned int h;
 
-	return;
+	write_lock(&dn_fib_tables_lock);
+	for (h = 0; h < DN_FIB_TABLE_HASHSZ; h++) {
+		hlist_for_each_entry_safe(t, node, next, &dn_fib_table_hash[h],
+		                          hlist) {
+			hlist_del(&t->hlist);
+			kfree(t);
+		}
+	}
+	write_unlock(&dn_fib_tables_lock);
 }
