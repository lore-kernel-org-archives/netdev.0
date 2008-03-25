From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/5] [NET] NETNS: Omit seq_net_private->net without
 CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 08:44:34 +0900 (JST)
Message-ID: <20080326.084434.91814180.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dlezcano@fr.ibm.com, brian.haley@hp.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55051 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbYCYXnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without CONFIG_NET_NS, no namespace other than &init_net exists,
no need to store net in seq_net_private.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 fs/proc/proc_net.c       |    6 +++---
 include/linux/seq_file.h |    7 +++++++
 net/core/neighbour.c     |    8 ++++----
 net/ipv4/fib_hash.c      |    5 ++---
 net/ipv4/fib_trie.c      |   13 ++++++-------
 net/ipv4/raw.c           |    4 ++--
 net/ipv4/route.c         |   29 +++++++++++++++--------------
 net/ipv6/addrconf.c      |    4 ++--
 net/ipv6/mcast.c         |    4 ++--
 net/netfilter/x_tables.c |    4 ++--
 net/netlink/af_netlink.c |    6 +++---
 net/unix/af_unix.c       |   10 +++++-----
 12 files changed, 53 insertions(+), 47 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 4caa5f7..13cd783 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -44,7 +44,9 @@ int seq_open_net(struct inode *ino, struct file *f,
 		put_net(net);
 		return -ENOMEM;
 	}
+#ifdef CONFIG_NET_NS
 	p->net = net;
+#endif
 	return 0;
 }
 EXPORT_SYMBOL_GPL(seq_open_net);
@@ -52,12 +54,10 @@ EXPORT_SYMBOL_GPL(seq_open_net);
 int seq_release_net(struct inode *ino, struct file *f)
 {
 	struct seq_file *seq;
-	struct seq_net_private *p;
 
 	seq = f->private_data;
-	p = seq->private;
 
-	put_net(p->net);
+	put_net(seq_file_net(seq));
 	seq_release_private(ino, f);
 	return 0;
 }
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index 67c2563..d870a82 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -5,6 +5,7 @@
 #include <linux/types.h>
 #include <linux/string.h>
 #include <linux/mutex.h>
+#include <net/net_namespace.h>
 
 struct seq_operations;
 struct file;
@@ -64,7 +65,9 @@ extern struct list_head *seq_list_next(void *v, struct list_head *head,
 
 struct net;
 struct seq_net_private {
+#ifdef CONFIG_NET_NS
 	struct net *net;
+#endif
 };
 
 int seq_open_net(struct inode *, struct file *,
@@ -72,7 +75,11 @@ int seq_open_net(struct inode *, struct file *,
 int seq_release_net(struct inode *, struct file *);
 static inline struct net *seq_file_net(struct seq_file *seq)
 {
+#ifdef CONFIG_NET_NS
 	return ((struct seq_net_private *)seq->private)->net;
+#else
+	return &init_net;
+#endif
 }
 
 #endif
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 065fbac..b8d491f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2145,7 +2145,7 @@ EXPORT_SYMBOL(__neigh_for_each_release);
 static struct neighbour *neigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = state->p.net;
+	struct net *net = seq_file_net(seq);
 	struct neigh_table *tbl = state->tbl;
 	struct neighbour *n = NULL;
 	int bucket = state->bucket;
@@ -2186,7 +2186,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 					loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = state->p.net;
+	struct net *net = seq_file_net(seq);
 	struct neigh_table *tbl = state->tbl;
 
 	if (state->neigh_sub_iter) {
@@ -2246,7 +2246,7 @@ static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
 static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net * net = state->p.net;
+	struct net *net = seq_file_net(seq);
 	struct neigh_table *tbl = state->tbl;
 	struct pneigh_entry *pn = NULL;
 	int bucket = state->bucket;
@@ -2269,7 +2269,7 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 					    loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net * net = state->p.net;
+	struct net *net = seq_file_net(seq);
 	struct neigh_table *tbl = state->tbl;
 
 	pn = pn->next;
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 8d58d85..02088de 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -821,7 +821,7 @@ static struct fib_alias *fib_get_first(struct seq_file *seq)
 	struct fib_table *main_table;
 	struct fn_hash *table;
 
-	main_table = fib_get_table(iter->p.net, RT_TABLE_MAIN);
+	main_table = fib_get_table(seq_file_net(seq), RT_TABLE_MAIN);
 	table = (struct fn_hash *)main_table->tb_data;
 
 	iter->bucket    = 0;
@@ -959,11 +959,10 @@ static struct fib_alias *fib_get_idx(struct seq_file *seq, loff_t pos)
 static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(fib_hash_lock)
 {
-	struct fib_iter_state *iter = seq->private;
 	void *v = NULL;
 
 	read_lock(&fib_hash_lock);
-	if (fib_get_table(iter->p.net, RT_TABLE_MAIN))
+	if (fib_get_table(seq_file_net(seq), RT_TABLE_MAIN))
 		v = *pos ? fib_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 	return v;
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ce6cb34..9e491e7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2279,9 +2279,10 @@ static const struct file_operations fib_triestat_fops = {
 	.release = fib_triestat_seq_release,
 };
 
-static struct node *fib_trie_get_idx(struct fib_trie_iter *iter, loff_t pos)
+static struct node *fib_trie_get_idx(struct seq_file *seq, loff_t pos)
 {
-	struct net *net = iter->p.net;
+	struct fib_trie_iter *iter = seq->private;
+	struct net *net = seq_file_net(seq);
 	loff_t idx = 0;
 	unsigned int h;
 
@@ -2309,16 +2310,14 @@ static struct node *fib_trie_get_idx(struct fib_trie_iter *iter, loff_t pos)
 static void *fib_trie_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
-	struct fib_trie_iter *iter = seq->private;
-
 	rcu_read_lock();
-	return fib_trie_get_idx(iter, *pos);
+	return fib_trie_get_idx(seq, *pos);
 }
 
 static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct fib_trie_iter *iter = seq->private;
-	struct net *net = iter->p.net;
+	struct net *net = seq_file_net(seq);
 	struct fib_table *tb = iter->tb;
 	struct hlist_node *tb_node;
 	unsigned int h;
@@ -2513,7 +2512,7 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 	struct fib_table *tb;
 
 	rcu_read_lock();
-	tb = fib_get_table(iter->p.net, RT_TABLE_MAIN);
+	tb = fib_get_table(seq_file_net(seq), RT_TABLE_MAIN);
 	if (!tb)
 		return NULL;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index be19a40..25dc8b3 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -856,7 +856,7 @@ static struct sock *raw_get_first(struct seq_file *seq)
 		struct hlist_node *node;
 
 		sk_for_each(sk, node, &state->h->ht[state->bucket])
-			if (sock_net(sk) == state->p.net)
+			if (sock_net(sk) == seq_file_net(seq))
 				goto found;
 	}
 	sk = NULL;
@@ -872,7 +872,7 @@ static struct sock *raw_get_next(struct seq_file *seq, struct sock *sk)
 		sk = sk_next(sk);
 try_again:
 		;
-	} while (sk && sock_net(sk) != state->p.net);
+	} while (sk && sock_net(sk) != seq_file_net(seq));
 
 	if (!sk && ++state->bucket < RAW_HTABLE_SIZE) {
 		sk = sk_head(&state->h->ht[state->bucket]);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 194f5cc..eab8d75 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -276,15 +276,16 @@ struct rt_cache_iter_state {
 	int genid;
 };
 
-static struct rtable *rt_cache_get_first(struct rt_cache_iter_state *st)
+static struct rtable *rt_cache_get_first(struct seq_file *seq)
 {
+	struct rt_cache_iter_state *st = seq->private;
 	struct rtable *r = NULL;
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
 		rcu_read_lock_bh();
 		r = rcu_dereference(rt_hash_table[st->bucket].chain);
 		while (r) {
-			if (dev_net(r->u.dst.dev) == st->p.net &&
+			if (dev_net(r->u.dst.dev) == seq_file_net(seq) &&
 			    r->rt_genid == st->genid)
 				return r;
 			r = rcu_dereference(r->u.dst.rt_next);
@@ -294,9 +295,10 @@ static struct rtable *rt_cache_get_first(struct rt_cache_iter_state *st)
 	return r;
 }
 
-static struct rtable *__rt_cache_get_next(struct rt_cache_iter_state *st,
+static struct rtable *__rt_cache_get_next(struct seq_file *seq,
 					  struct rtable *r)
 {
+	struct rt_cache_iter_state *st = seq->private;
 	r = r->u.dst.rt_next;
 	while (!r) {
 		rcu_read_unlock_bh();
@@ -308,11 +310,12 @@ static struct rtable *__rt_cache_get_next(struct rt_cache_iter_state *st,
 	return rcu_dereference(r);
 }
 
-static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st,
+static struct rtable *rt_cache_get_next(struct seq_file *seq,
 					struct rtable *r)
 {
-	while ((r = __rt_cache_get_next(st, r)) != NULL) {
-		if (dev_net(r->u.dst.dev) != st->p.net)
+	struct rt_cache_iter_state *st = seq->private;
+	while ((r = __rt_cache_get_next(seq, r)) != NULL) {
+		if (dev_net(r->u.dst.dev) != seq_file_net(seq))
 			continue;
 		if (r->rt_genid == st->genid)
 			break;
@@ -320,12 +323,12 @@ static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st,
 	return r;
 }
 
-static struct rtable *rt_cache_get_idx(struct rt_cache_iter_state *st, loff_t pos)
+static struct rtable *rt_cache_get_idx(struct seq_file *seq, loff_t pos)
 {
-	struct rtable *r = rt_cache_get_first(st);
+	struct rtable *r = rt_cache_get_first(seq);
 
 	if (r)
-		while (pos && (r = rt_cache_get_next(st, r)))
+		while (pos && (r = rt_cache_get_next(seq, r)))
 			--pos;
 	return pos ? NULL : r;
 }
@@ -333,9 +336,8 @@ static struct rtable *rt_cache_get_idx(struct rt_cache_iter_state *st, loff_t po
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct rt_cache_iter_state *st = seq->private;
-
 	if (*pos)
-		return rt_cache_get_idx(st, *pos - 1);
+		return rt_cache_get_idx(seq, *pos - 1);
 	st->genid = atomic_read(&rt_genid);
 	return SEQ_START_TOKEN;
 }
@@ -343,12 +345,11 @@ static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 static void *rt_cache_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct rtable *r;
-	struct rt_cache_iter_state *st = seq->private;
 
 	if (v == SEQ_START_TOKEN)
-		r = rt_cache_get_first(st);
+		r = rt_cache_get_first(seq);
 	else
-		r = rt_cache_get_next(st, v);
+		r = rt_cache_get_next(seq, v);
 	++*pos;
 	return r;
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f2c90f1..ac5d4f4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2766,7 +2766,7 @@ static struct inet6_ifaddr *if6_get_first(struct seq_file *seq)
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct if6_iter_state *state = seq->private;
-	struct net *net = state->p.net;
+	struct net *net = seq_file_net(seq);
 
 	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
 		ifa = inet6_addr_lst[state->bucket];
@@ -2782,7 +2782,7 @@ static struct inet6_ifaddr *if6_get_first(struct seq_file *seq)
 static struct inet6_ifaddr *if6_get_next(struct seq_file *seq, struct inet6_ifaddr *ifa)
 {
 	struct if6_iter_state *state = seq->private;
-	struct net *net = state->p.net;
+	struct net *net = seq_file_net(seq);
 
 	ifa = ifa->lst_next;
 try_again:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 20a3d8e..d810cff 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2355,7 +2355,7 @@ static inline struct ifmcaddr6 *igmp6_mc_get_first(struct seq_file *seq)
 {
 	struct ifmcaddr6 *im = NULL;
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
-	struct net *net = state->p.net;
+	struct net *net = seq_file_net(seq);
 
 	state->idev = NULL;
 	for_each_netdev(net, state->dev) {
@@ -2486,7 +2486,7 @@ static inline struct ip6_sf_list *igmp6_mcf_get_first(struct seq_file *seq)
 	struct ip6_sf_list *psf = NULL;
 	struct ifmcaddr6 *im = NULL;
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
-	struct net *net = state->p.net;
+	struct net *net = seq_file_net(seq);
 
 	state->idev = NULL;
 	state->im = NULL;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index a679208..0bd9568 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -727,7 +727,7 @@ struct xt_names_priv {
 static void *xt_table_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct xt_names_priv *priv = seq->private;
-	struct net *net = priv->p.net;
+	struct net *net = seq_file_net(seq);
 	int af = priv->af;
 
 	mutex_lock(&xt[af].mutex);
@@ -737,7 +737,7 @@ static void *xt_table_seq_start(struct seq_file *seq, loff_t *pos)
 static void *xt_table_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct xt_names_priv *priv = seq->private;
-	struct net *net = priv->p.net;
+	struct net *net = seq_file_net(seq);
 	int af = priv->af;
 
 	return seq_list_next(v, &net->xt.tables[af], pos);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 712a7bf..1d16d95 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1758,7 +1758,7 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 
 		for (j = 0; j <= hash->mask; j++) {
 			sk_for_each(s, node, &hash->table[j]) {
-				if (sock_net(s) != iter->p.net)
+				if (sock_net(s) != seq_file_net(seq))
 					continue;
 				if (off == pos) {
 					iter->link = i;
@@ -1794,7 +1794,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	s = v;
 	do {
 		s = sk_next(s);
-	} while (s && (sock_net(s) != iter->p.net));
+	} while (s && sock_net(s) != seq_file_net(seq));
 	if (s)
 		return s;
 
@@ -1806,7 +1806,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 		for (; j <= hash->mask; j++) {
 			s = sk_head(&hash->table[j]);
-			while (s && sock_net(s) != iter->p.net)
+			while (s && sock_net(s) != seq_file_net(seq))
 				s = sk_next(s);
 			if (s) {
 				iter->link = i;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index cb9d0cb..4a47930 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2016,13 +2016,14 @@ struct unix_iter_state {
 	struct seq_net_private p;
 	int i;
 };
-static struct sock *unix_seq_idx(struct unix_iter_state *iter, loff_t pos)
+static struct sock *unix_seq_idx(struct seq_file *seq, loff_t pos)
 {
+	struct unix_iter_state *iter = seq->private;
 	loff_t off = 0;
 	struct sock *s;
 
 	for (s = first_unix_socket(&iter->i); s; s = next_unix_socket(&iter->i, s)) {
-		if (sock_net(s) != iter->p.net)
+		if (sock_net(s) != seq_file_net(seq))
 			continue;
 		if (off == pos)
 			return s;
@@ -2035,9 +2036,8 @@ static struct sock *unix_seq_idx(struct unix_iter_state *iter, loff_t pos)
 static void *unix_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(unix_table_lock)
 {
-	struct unix_iter_state *iter = seq->private;
 	spin_lock(&unix_table_lock);
-	return *pos ? unix_seq_idx(iter, *pos - 1) : ((void *) 1);
+	return *pos ? unix_seq_idx(seq, *pos - 1) : ((void *) 1);
 }
 
 static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -2050,7 +2050,7 @@ static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		sk = first_unix_socket(&iter->i);
 	else
 		sk = next_unix_socket(&iter->i, sk);
-	while (sk && (sock_net(sk) != iter->p.net))
+	while (sk && (sock_net(sk) != seq_file_net(seq)))
 		sk = next_unix_socket(&iter->i, sk);
 	return sk;
 }
-- 
1.4.4.4

