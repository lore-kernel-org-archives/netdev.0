From: Patrick McHardy <kaber@trash.net>
Subject: [IPV6 04/06]: Increase number of possible routing tables to 2^32
Date: Thu, 10 Aug 2006 21:30:03 +0200 (MEST)
Message-ID: <20060810193003.14867.80798.sendpatchset@localhost.localdomain>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44762 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751459AbWHJTaE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 15:30:04 -0400
To: davem@davemloft.net
In-Reply-To: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Increase number of possible routing tables to 2^32

Increase number of possible routing tables to 2^32 by replacing iterations
over all possible table IDs by hash table walking.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cad398a8f3ef363abba9e6450dded94a022c96fa
tree 4fea9c50650ab65d942dca9c2545d1810b227839
parent 148d1ca7c199005b5a92f8154a7caf3f78529672
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:53:33 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:53:33 +0200

 include/net/ip6_route.h |    7 ++
 net/ipv6/ip6_fib.c      |  171 ++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv6/route.c        |  128 -----------------------------------
 3 files changed, 159 insertions(+), 147 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 9bfa3cc..01bfe40 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -137,6 +137,13 @@ extern int inet6_rtm_newroute(struct sk_
 extern int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 extern int inet6_rtm_getroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 
+struct rt6_rtnl_dump_arg
+{
+	struct sk_buff *skb;
+	struct netlink_callback *cb;
+};
+
+extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 1f23161..bececbe 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -158,7 +158,26 @@ static struct fib6_table fib6_main_tbl =
 };
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
+#define FIB_TABLE_HASHSZ 256
+#else
+#define FIB_TABLE_HASHSZ 1
+#endif
+static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
+
+static void fib6_link_table(struct fib6_table *tb)
+{
+	unsigned int h;
+
+	h = tb->tb6_id & (FIB_TABLE_HASHSZ - 1);
 
+	/*
+	 * No protection necessary, this is the only list mutatation
+	 * operation, tables never disappear once they exist.
+	 */
+	hlist_add_head_rcu(&tb->tb6_hlist, &fib_table_hash[h]);
+}
+
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
 static struct fib6_table fib6_local_tbl = {
 	.tb6_id		= RT6_TABLE_LOCAL,
 	.tb6_lock	= RW_LOCK_UNLOCKED,
@@ -168,9 +187,6 @@ static struct fib6_table fib6_local_tbl 
 	},
 };
 
-#define FIB_TABLE_HASHSZ 256
-static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
-
 static struct fib6_table *fib6_alloc_table(u32 id)
 {
 	struct fib6_table *table;
@@ -186,19 +202,6 @@ static struct fib6_table *fib6_alloc_tab
 	return table;
 }
 
-static void fib6_link_table(struct fib6_table *tb)
-{
-	unsigned int h;
-
-	h = tb->tb6_id & (FIB_TABLE_HASHSZ - 1);
-
-	/*
-	 * No protection necessary, this is the only list mutatation
-	 * operation, tables never disappear once they exist.
-	 */
-	hlist_add_head_rcu(&tb->tb6_hlist, &fib_table_hash[h]);
-}
-
 struct fib6_table *fib6_new_table(u32 id)
 {
 	struct fib6_table *tb;
@@ -263,10 +266,135 @@ struct dst_entry *fib6_rule_lookup(struc
 
 static void __init fib6_tables_init(void)
 {
+	fib6_link_table(&fib6_main_tbl);
 }
 
 #endif
 
+static int fib6_dump_node(struct fib6_walker_t *w)
+{
+	int res;
+	struct rt6_info *rt;
+
+	for (rt = w->leaf; rt; rt = rt->u.next) {
+		res = rt6_dump_route(rt, w->args);
+		if (res < 0) {
+			/* Frame is full, suspend walking */
+			w->leaf = rt;
+			return 1;
+		}
+		BUG_TRAP(res!=0);
+	}
+	w->leaf = NULL;
+	return 0;
+}
+
+static void fib6_dump_end(struct netlink_callback *cb)
+{
+	struct fib6_walker_t *w = (void*)cb->args[2];
+
+	if (w) {
+		cb->args[2] = 0;
+		kfree(w);
+	}
+	cb->done = (void*)cb->args[3];
+	cb->args[1] = 3;
+}
+
+static int fib6_dump_done(struct netlink_callback *cb)
+{
+	fib6_dump_end(cb);
+	return cb->done ? cb->done(cb) : 0;
+}
+
+static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
+			   struct netlink_callback *cb)
+{
+	struct fib6_walker_t *w;
+	int res;
+
+	w = (void *)cb->args[2];
+	w->root = &table->tb6_root;
+
+	if (cb->args[4] == 0) {
+		read_lock_bh(&table->tb6_lock);
+		res = fib6_walk(w);
+		read_unlock_bh(&table->tb6_lock);
+		if (res > 0)
+			cb->args[4] = 1;
+	} else {
+		read_lock_bh(&table->tb6_lock);
+		res = fib6_walk_continue(w);
+		read_unlock_bh(&table->tb6_lock);
+		if (res != 0) {
+			if (res < 0)
+				fib6_walker_unlink(w);
+			goto end;
+		}
+		fib6_walker_unlink(w);
+		cb->args[4] = 0;
+	}
+end:
+	return res;
+}
+
+int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	unsigned int h, s_h;
+	unsigned int e = 0, s_e;
+	struct rt6_rtnl_dump_arg arg;
+	struct fib6_walker_t *w;
+	struct fib6_table *tb;
+	struct hlist_node *node;
+	int res = 0;
+
+	s_h = cb->args[0];
+	s_e = cb->args[1];
+
+	w = (void *)cb->args[2];
+	if (w == NULL) {
+		/* New dump:
+		 *
+		 * 1. hook callback destructor.
+		 */
+		cb->args[3] = (long)cb->done;
+		cb->done = fib6_dump_done;
+
+		/*
+		 * 2. allocate and initialize walker.
+		 */
+		w = kzalloc(sizeof(*w), GFP_ATOMIC);
+		if (w == NULL)
+			return -ENOMEM;
+		w->func = fib6_dump_node;
+		cb->args[2] = (long)w;
+	}
+
+	arg.skb = skb;
+	arg.cb = cb;
+	w->args = &arg;
+
+	for (h = s_h; h < FIB_TABLE_HASHSZ; h++, s_e = 0) {
+		e = 0;
+		hlist_for_each_entry(tb, node, &fib_table_hash[h], tb6_hlist) {
+			if (e < s_e)
+				goto next;
+			res = fib6_dump_table(tb, skb, cb);
+			if (res != 0)
+				goto out;
+next:
+			e++;
+		}
+	}
+out:
+	cb->args[1] = e;
+	cb->args[0] = h;
+
+	res = res < 0 ? res : skb->len;
+	if (res <= 0)
+		fib6_dump_end(cb);
+	return res;
+}
 
 /*
  *	Routing Table
@@ -1187,17 +1315,20 @@ static void fib6_clean_tree(struct fib6_
 void fib6_clean_all(int (*func)(struct rt6_info *, void *arg),
 		    int prune, void *arg)
 {
-	int i;
 	struct fib6_table *table;
+	struct hlist_node *node;
+	unsigned int h;
 
-	for (i = FIB6_TABLE_MIN; i <= FIB6_TABLE_MAX; i++) {
-		table = fib6_get_table(i);
-		if (table != NULL) {
+	rcu_read_lock();
+	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
+		hlist_for_each_entry_rcu(table, node, &fib_table_hash[h],
+					 tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(&table->tb6_root, func, prune, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
+	rcu_read_unlock();
 }
 
 static int fib6_prune_clone(struct rt6_info *rt, void *arg)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b8b5132..191d12f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1870,12 +1870,6 @@ int inet6_rtm_newroute(struct sk_buff *s
 			     rtm_get_table(arg, r->rtm_table));
 }
 
-struct rt6_rtnl_dump_arg
-{
-	struct sk_buff *skb;
-	struct netlink_callback *cb;
-};
-
 static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
 			 int iif, int type, u32 pid, u32 seq,
@@ -1972,7 +1966,7 @@ rtattr_failure:
 	return -1;
 }
 
-static int rt6_dump_route(struct rt6_info *rt, void *p_arg)
+int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
 	int prefix;
@@ -1988,126 +1982,6 @@ static int rt6_dump_route(struct rt6_inf
 		     prefix, NLM_F_MULTI);
 }
 
-static int fib6_dump_node(struct fib6_walker_t *w)
-{
-	int res;
-	struct rt6_info *rt;
-
-	for (rt = w->leaf; rt; rt = rt->u.next) {
-		res = rt6_dump_route(rt, w->args);
-		if (res < 0) {
-			/* Frame is full, suspend walking */
-			w->leaf = rt;
-			return 1;
-		}
-		BUG_TRAP(res!=0);
-	}
-	w->leaf = NULL;
-	return 0;
-}
-
-static void fib6_dump_end(struct netlink_callback *cb)
-{
-	struct fib6_walker_t *w = (void*)cb->args[0];
-
-	if (w) {
-		cb->args[0] = 0;
-		kfree(w);
-	}
-	cb->done = (void*)cb->args[1];
-	cb->args[1] = 0;
-}
-
-static int fib6_dump_done(struct netlink_callback *cb)
-{
-	fib6_dump_end(cb);
-	return cb->done ? cb->done(cb) : 0;
-}
-
-int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
-{
-	struct fib6_table *table;
-	struct rt6_rtnl_dump_arg arg;
-	struct fib6_walker_t *w;
-	int i, res = 0;
-
-	arg.skb = skb;
-	arg.cb = cb;
-
-	/*
-	 * cb->args[0] = pointer to walker structure
-	 * cb->args[1] = saved cb->done() pointer
-	 * cb->args[2] = current table being dumped
-	 */
-
-	w = (void*)cb->args[0];
-	if (w == NULL) {
-		/* New dump:
-		 * 
-		 * 1. hook callback destructor.
-		 */
-		cb->args[1] = (long)cb->done;
-		cb->done = fib6_dump_done;
-
-		/*
-		 * 2. allocate and initialize walker.
-		 */
-		w = kzalloc(sizeof(*w), GFP_ATOMIC);
-		if (w == NULL)
-			return -ENOMEM;
-		w->func = fib6_dump_node;
-		w->args = &arg;
-		cb->args[0] = (long)w;
-		cb->args[2] = FIB6_TABLE_MIN;
-	} else {
-		w->args = &arg;
-		i = cb->args[2];
-		if (i > FIB6_TABLE_MAX)
-			goto end;
-
-		table = fib6_get_table(i);
-		if (table != NULL) {
-			read_lock_bh(&table->tb6_lock);
-			w->root = &table->tb6_root;
-			res = fib6_walk_continue(w);
-			read_unlock_bh(&table->tb6_lock);
-			if (res != 0) {
-				if (res < 0)
-					fib6_walker_unlink(w);
-				goto end;
-			}
-		}
-
-		fib6_walker_unlink(w);
-		cb->args[2] = ++i;
-	}
-
-	for (i = cb->args[2]; i <= FIB6_TABLE_MAX; i++) {
-		table = fib6_get_table(i);
-		if (table == NULL)
-			continue;
-
-		read_lock_bh(&table->tb6_lock);
-		w->root = &table->tb6_root;
-		res = fib6_walk(w);
-		read_unlock_bh(&table->tb6_lock);
-		if (res)
-			break;
-	}
-end:
-	cb->args[2] = i;
-
-	res = res < 0 ? res : skb->len;
-	/* res < 0 is an error. (really, impossible)
-	   res == 0 means that dump is complete, but skb still can contain data.
-	   res > 0 dump is not complete, but frame is full.
-	 */
-	/* Destroy walker, if dump of this table is complete. */
-	if (res <= 0)
-		fib6_dump_end(cb);
-	return res;
-}
-
 int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct rtattr **rta = arg;
