From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: [RFC PATCH] fib_hash: improve route deletion scaling on interface drop with lots of interfaces
Date: Mon, 26 Oct 2009 20:03:02 -0400
Message-ID: <20091027000302.GA3141@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:59276 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755035AbZJ0AC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 20:02:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

Below is a patch to improve the scaling of interface destruction in 
fib_hash.  The general idea is to tie the fib_alias structure into a 
list off of net_device and walk that list during a fib_flush() caused 
by an interface drop.  This makes the resulting flush only have to walk 
the number of routes attached to an interface rather than the number of 
routes attached to all interfaces at the expense of a couple of additional 
pointers in struct fib_alias.

This patch is against Linus' tree.  I'll post against net-next after a 
bit more testing and feedback.  With 20,000 interfaces & routes, interface 
deletion time improves from 53s to 40s.  Note that this is with other changes 
applied to improve sysfs and procfs scaling, as otherwise those are the 
bottleneck.  Next up in the network code is rt_cache_flush().  Comments?

		-ben

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 812a5f3..982045b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -856,6 +856,7 @@ struct net_device
 
 	/* delayed register/unregister */
 	struct list_head	todo_list;
+	struct list_head	fib_list;
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
 
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ef91fe9..0c32193 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -149,7 +149,7 @@ struct fib_table {
 	int		(*tb_delete)(struct fib_table *, struct fib_config *);
 	int		(*tb_dump)(struct fib_table *table, struct sk_buff *skb,
 				     struct netlink_callback *cb);
-	int		(*tb_flush)(struct fib_table *table);
+	int		(*tb_flush)(struct fib_table *table, struct net_device *dev);
 	void		(*tb_select_default)(struct fib_table *table,
 					     const struct flowi *flp, struct fib_result *res);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..9f6f736 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5173,6 +5173,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	netdev_init_queues(dev);
 
 	INIT_LIST_HEAD(&dev->napi_list);
+	INIT_LIST_HEAD(&dev->fib_list);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 	strcpy(dev->name, name);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e2f9505..0283b1f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -128,18 +128,19 @@ void fib_select_default(struct net *net,
 		tb->tb_select_default(tb, flp, res);
 }
 
-static void fib_flush(struct net *net)
+static void fib_flush(struct net_device *dev)
 {
 	int flushed = 0;
 	struct fib_table *tb;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	unsigned int h;
+	struct net *net = dev_net(dev);
 
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
 		head = &net->ipv4.fib_table_hash[h];
 		hlist_for_each_entry(tb, node, head, tb_hlist)
-			flushed += tb->tb_flush(tb);
+			flushed += tb->tb_flush(tb, dev);
 	}
 
 	if (flushed)
@@ -805,7 +806,7 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 			   for stray nexthop entries, then ignite fib_flush.
 			*/
 			if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local))
-				fib_flush(dev_net(dev));
+				fib_flush(dev);
 		}
 	}
 #undef LOCAL_OK
@@ -895,7 +896,7 @@ static void nl_fib_lookup_exit(struct net *net)
 static void fib_disable_ip(struct net_device *dev, int force)
 {
 	if (fib_sync_down_dev(dev, force))
-		fib_flush(dev_net(dev));
+		fib_flush(dev);
 	rt_cache_flush(dev_net(dev), 0);
 	arp_ifdown(dev);
 }
@@ -1009,7 +1010,7 @@ static void __net_exit ip_fib_net_exit(struct net *net)
 		head = &net->ipv4.fib_table_hash[i];
 		hlist_for_each_entry_safe(tb, node, tmp, head, tb_hlist) {
 			hlist_del(node);
-			tb->tb_flush(tb);
+			tb->tb_flush(tb, NULL);
 			kfree(tb);
 		}
 	}
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index ecd3945..d08ba2f 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -377,6 +377,7 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 	u8 tos = cfg->fc_tos;
 	__be32 key;
 	int err;
+	struct net_device *dev;
 
 	if (cfg->fc_dst_len > 32)
 		return -EINVAL;
@@ -516,6 +517,10 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_scope = cfg->fc_scope;
 	new_fa->fa_state = 0;
+	new_fa->fa_fib_node = f;
+	new_fa->fa_fz = fz;
+
+	dev = fi->fib_dev;
 
 	/*
 	 * Insert new entry to the list.
@@ -527,6 +532,7 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 	list_add_tail(&new_fa->fa_list,
 		 (fa ? &fa->fa_list : &f->fn_alias));
 	fib_hash_genid++;
+	list_add_tail(&new_fa->fa_dev_list, &dev->fib_list);
 	write_unlock_bh(&fib_hash_lock);
 
 	if (new_f)
@@ -605,6 +611,7 @@ static int fn_hash_delete(struct fib_table *tb, struct fib_config *cfg)
 		kill_fn = 0;
 		write_lock_bh(&fib_hash_lock);
 		list_del(&fa->fa_list);
+		list_del(&fa->fa_dev_list);
 		if (list_empty(&f->fn_alias)) {
 			hlist_del(&f->fn_hash);
 			kill_fn = 1;
@@ -643,6 +650,7 @@ static int fn_flush_list(struct fn_zone *fz, int idx)
 			if (fi && (fi->fib_flags&RTNH_F_DEAD)) {
 				write_lock_bh(&fib_hash_lock);
 				list_del(&fa->fa_list);
+				list_del(&fa->fa_dev_list);
 				if (list_empty(&f->fn_alias)) {
 					hlist_del(&f->fn_hash);
 					kill_f = 1;
@@ -662,17 +670,69 @@ static int fn_flush_list(struct fn_zone *fz, int idx)
 	return found;
 }
 
-static int fn_hash_flush(struct fib_table *tb)
+static int fn_flush_alias(struct fn_hash *table, struct fib_alias *fa)
+{
+	int kill_f = 0;
+	struct fib_info *fi = fa->fa_info;
+	int found = 0;
+
+	if (!fi)
+		BUG();
+
+	if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+		struct fib_node *f = fa->fa_fib_node;
+		struct fn_zone *fz = fa->fa_fz;
+
+		write_lock_bh(&fib_hash_lock);
+		list_del(&fa->fa_list);
+		list_del(&fa->fa_dev_list);
+		if (list_empty(&f->fn_alias)) {
+			hlist_del(&f->fn_hash);
+			kill_f = 1;
+		}
+		fib_hash_genid++;
+		write_unlock_bh(&fib_hash_lock);
+
+		fn_free_alias(fa, f);
+		found++;
+
+		if (kill_f)
+			fn_free_node(f);
+		fz->fz_nent--;
+	}
+
+	return found;
+}
+
+static int fn_flush_dev(struct fn_hash *table, struct net_device *dev)
+{
+	int found = 0;
+	struct list_head *pos, *next;
+
+	list_for_each_safe(pos, next, &dev->fib_list) {
+		struct fib_alias *fa =
+			container_of(pos, struct fib_alias, fa_dev_list);
+		found += fn_flush_alias(table, fa);
+	}
+
+	return found;
+}
+
+static int fn_hash_flush(struct fib_table *tb, struct net_device *dev)
 {
 	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
 	struct fn_zone *fz;
 	int found = 0;
 
-	for (fz = table->fn_zone_list; fz; fz = fz->fz_next) {
-		int i;
+	if (dev) {
+		found = fn_flush_dev(table, dev);
+	} else {
+		for (fz = table->fn_zone_list; fz; fz = fz->fz_next) {
+			int i;
 
-		for (i = fz->fz_divisor - 1; i >= 0; i--)
-			found += fn_flush_list(fz, i);
+			for (i = fz->fz_divisor - 1; i >= 0; i--)
+				found += fn_flush_list(fz, i);
+		}
 	}
 	return found;
 }
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 637b133..9f2fad1 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -5,9 +5,17 @@
 #include <linux/list.h>
 #include <net/ip_fib.h>
 
+struct fib_node;
+struct fn_zone;
+
 struct fib_alias {
 	struct list_head	fa_list;
+	struct list_head	fa_dev_list;
 	struct fib_info		*fa_info;
+#ifdef CONFIG_IP_FIB_HASH
+	struct fib_node		*fa_fib_node;
+	struct fn_zone		*fa_fz;
+#endif
 	u8			fa_tos;
 	u8			fa_type;
 	u8			fa_scope;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 291bdf5..4805772 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1786,7 +1786,7 @@ static struct leaf *trie_leafindex(struct trie *t, int index)
 /*
  * Caller must hold RTNL.
  */
-static int fn_trie_flush(struct fib_table *tb)
+static int fn_trie_flush(struct fib_table *tb, struct net_device *dev)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct leaf *l, *ll = NULL;
