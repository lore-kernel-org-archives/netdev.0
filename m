From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC net-next] ipv6: avoid high order memory allocations for /proc/net/ipv6_route
Date: Tue, 27 Aug 2013 20:24:42 +0200
Message-ID: <20130827182442.GA27466@order.stressinduktion.org>
References: <20130821175024.GA14419@order.stressinduktion.org> <20130822031602.GA19269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: greearb@candelatech.com, kaber@trash.net, eric.dumazet@gmail.com,
	gaofeng@cn.fujitsu.com, kuznet@ms2.inr.ac.ru, davem@davemloft.net
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49745 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237Ab3H0SYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 14:24:44 -0400
Content-Disposition: inline
In-Reply-To: <20130822031602.GA19269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben and Patrick!

I have a question regarding this patch:

commit 2bec5a369ee79576a3eea2c23863325089785a2c
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Feb 8 05:19:03 2010 +0000

    ipv6: fib: fix crash when changing large fib while dumping it
    
    When the fib size exceeds what can be dumped in a single skb, the
    dump is suspended and resumed once the last skb has been received
    by userspace. When the fib is changed while the dump is suspended,
    the walker might contain stale pointers, causing a crash when the
    dump is resumed.

Below is a patch to switch /proc/net/ipv6_route to an iterating interface
as well, thus avoiding large order allocations in the procfs code.

Looking at the netlink dump code I think I might also need the
serialnumber check and restart logic but I could not reproduce any NULL-ptr
deref with my code or with your patch reverted. Maybe you remember some
special cases how to reproduce this? There was already some doubt the
serialnumber check would be needed in this thread:
https://lkml.org/lkml/2012/6/12/386

I also tried to check the walker logic and have not found any spots where it
should produce such a BUG.

It would also help to know the exact kernel version on which this bug was
produced.

Thanks a lot!

On Thu, Aug 22, 2013 at 05:16:02AM +0200, Hannes Frederic Sowa wrote:
> On Wed, Aug 21, 2013 at 07:50:24PM +0200, Hannes Frederic Sowa wrote:
> > I created this patch in a hurry while trying to get the rt6i_flags of
> > the routing entries on a system with lots of routes (I later cleaned it
> > up a bit).
> > 
> > The current approach for dumping routes over netlink is to redump a tree
> > as soon as the serialnumber on the nodes changes. Is this behavior more
> > preferable as to just ignore the routes for that moment? I am in favour
> > of not restarting the dump on /proc/net/ipv6_route.
> 
> Ok, I hit the same panics as Patrick once did
> while some more stress testing this change
> (http://permalink.gmane.org/gmane.linux.network/151391).
> 
> As I read this up, this was also the reason the serial checks where
> introduced. It also tries to skip visited notes, so please void my
> question above.
> 
> The reason is a disconnected fib6_node in FWS_U state trying to walk
> up. I'll investigate if we can fix this up in the walker post-cleanup on
> fib6_repair_tree/fib6_del_route (then we could also remove the serial
> number checks on inet6_dump_fib) or I will make the appropriate serial
> changes to this patch, too.

This was actually an error in my debugging code. I could not trigger it
afterwards. It was fully my fault.

Current patch looks like this:

[PATCH RFC] ipv6: avoid high order memory allocations for /proc/net/ipv6_route

Dumping routes on a system with lots rt6_infos in the fibs causes up to
11-order allocations in seq_file (which fail). While we could switch
there to vmalloc we could just implement the streaming interface for
/proc/net/ipv6_route. This patch switches /proc/net/ipv6_route from
single_open_net to seq_open_net.

loff_t *pos tracks dst entries.

Also kill never used struct rt6_proc_arg and now unused function
fib6_clean_all_ro.

Cc: Ben Greear <greearb@candelatech.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h |   7 +-
 net/ipv6/ip6_fib.c    | 191 +++++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv6/route.c      |  46 +-----------
 3 files changed, 176 insertions(+), 68 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 48ec25a..9bd5de8 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -281,10 +281,6 @@ struct fib6_node		*fib6_locate(struct fib6_node *root,
 					     const struct in6_addr *daddr, int dst_len,
 					     const struct in6_addr *saddr, int src_len);
 
-extern void			fib6_clean_all_ro(struct net *net,
-					       int (*func)(struct rt6_info *, void *arg),
-					       int prune, void *arg);
-
 extern void			fib6_clean_all(struct net *net,
 					       int (*func)(struct rt6_info *, void *arg),
 					       int prune, void *arg);
@@ -306,6 +302,9 @@ extern void			fib6_gc_cleanup(void);
 
 extern int			fib6_init(void);
 
+extern int			ipv6_route_open(struct inode *inode,
+						struct file *file);
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 extern int			fib6_rules_init(void);
 extern void			fib6_rules_cleanup(void);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 73db48e..04192af 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1529,25 +1529,6 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 	fib6_walk(&c.w);
 }
 
-void fib6_clean_all_ro(struct net *net, int (*func)(struct rt6_info *, void *arg),
-		    int prune, void *arg)
-{
-	struct fib6_table *table;
-	struct hlist_head *head;
-	unsigned int h;
-
-	rcu_read_lock();
-	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
-		head = &net->ipv6.fib_table_hash[h];
-		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
-			read_lock_bh(&table->tb6_lock);
-			fib6_clean_tree(net, &table->tb6_root,
-					func, prune, arg);
-			read_unlock_bh(&table->tb6_lock);
-		}
-	}
-	rcu_read_unlock();
-}
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    int prune, void *arg)
 {
@@ -1782,3 +1763,175 @@ void fib6_gc_cleanup(void)
 	unregister_pernet_subsys(&fib6_net_ops);
 	kmem_cache_destroy(fib6_node_kmem);
 }
+
+#ifdef CONFIG_PROC_FS
+
+struct ipv6_route_iter {
+	struct seq_net_private p;
+	struct fib6_walker_t w;
+	loff_t skip;
+	struct fib6_table *tbl;
+};
+
+static int ipv6_route_seq_show(struct seq_file *seq, void *v)
+{
+	struct rt6_info *rt = v;
+	struct ipv6_route_iter *iter = seq->private;
+
+	seq_printf(seq, "%pi6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
+
+#ifdef CONFIG_IPV6_SUBTREES
+	seq_printf(seq, "%pi6 %02x ", &rt->rt6i_src.addr, rt->rt6i_src.plen);
+#else
+	seq_puts(seq, "00000000000000000000000000000000 00 ");
+#endif
+	if (rt->rt6i_flags & RTF_GATEWAY)
+		seq_printf(seq, "%pi6", &rt->rt6i_gateway);
+	else
+		seq_puts(seq, "00000000000000000000000000000000");
+
+	seq_printf(seq, " %08x %08x %08x %08x %8s\n",
+		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
+		   rt->dst.__use, rt->rt6i_flags,
+		   rt->dst.dev ? rt->dst.dev->name : "");
+	iter->w.leaf = NULL;
+	return 0;
+}
+
+static int ipv6_route_yield(struct fib6_walker_t *w)
+{
+	struct ipv6_route_iter *iter = w->args;
+
+	if (!iter->skip)
+		return 1;
+
+	do {
+		iter->w.leaf = iter->w.leaf->dst.rt6_next;
+		iter->skip--;
+		if (!iter->skip && iter->w.leaf)
+			return 1;
+	} while (iter->w.leaf);
+
+	return 0;
+}
+
+static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
+{
+	memset(&iter->w, 0, sizeof(iter->w));
+	iter->w.func = ipv6_route_yield;
+	iter->w.root = &iter->tbl->tb6_root;
+	iter->w.state = FWS_INIT;
+	iter->w.node = iter->w.root;
+	iter->w.args = iter;
+	INIT_LIST_HEAD(&iter->w.lh);
+	fib6_walker_link(&iter->w);
+}
+
+static struct fib6_table *ipv6_route_seq_next_table(struct fib6_table *tbl,
+						    struct net *net)
+{
+	unsigned int h;
+	struct hlist_node *node;
+
+	if (tbl) {
+		h = (tbl->tb6_id & (FIB6_TABLE_HASHSZ - 1)) + 1;
+		node = rcu_dereference_bh(hlist_next_rcu(&tbl->tb6_hlist));
+	} else {
+		h = 0;
+		node = NULL;
+	}
+
+	while (!node && h < FIB6_TABLE_HASHSZ) {
+		node = rcu_dereference_bh(
+			hlist_first_rcu(&net->ipv6.fib_table_hash[h++]));
+	}
+	return hlist_entry_safe(node, struct fib6_table, tb6_hlist);
+}
+
+static void *ipv6_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	int r;
+	struct rt6_info *n;
+	struct net *net = seq_file_net(seq);
+	struct ipv6_route_iter *iter = seq->private;
+
+	if (!v)
+		goto iter_table;
+
+	n = ((struct rt6_info *)v)->dst.rt6_next;
+	if (n) {
+		++*pos;
+		return n;
+	}
+
+iter_table:
+	read_lock(&iter->tbl->tb6_lock);
+	r = fib6_walk_continue(&iter->w);
+	read_unlock(&iter->tbl->tb6_lock);
+	if (r > 0) {
+		if (v)
+			++*pos;
+		return iter->w.leaf;
+	} else if (r < 0) {
+		fib6_walker_unlink(&iter->w);
+		return NULL;
+	}
+	fib6_walker_unlink(&iter->w);
+
+	iter->tbl = ipv6_route_seq_next_table(iter->tbl, net);
+	if (!iter->tbl)
+		return NULL;
+
+	ipv6_route_seq_setup_walk(iter);
+	goto iter_table;
+}
+
+static void *ipv6_route_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU_BH)
+{
+	struct net *net = seq_file_net(seq);
+	struct ipv6_route_iter *iter = seq->private;
+
+	rcu_read_lock_bh();
+	iter->tbl = ipv6_route_seq_next_table(NULL, net);
+	iter->skip = *pos;
+
+	if (iter->tbl) {
+		ipv6_route_seq_setup_walk(iter);
+		return ipv6_route_seq_next(seq, NULL, pos);
+	} else {
+		return NULL;
+	}
+}
+
+static bool ipv6_route_iter_active(struct ipv6_route_iter *iter)
+{
+	struct fib6_walker_t *w = &iter->w;
+	return w->node && !(w->state == FWS_U && w->node == w->root);
+}
+
+static void ipv6_route_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU_BH)
+{
+	struct ipv6_route_iter *iter = seq->private;
+
+	if (ipv6_route_iter_active(iter))
+		fib6_walker_unlink(&iter->w);
+
+	rcu_read_unlock_bh();
+}
+
+static const struct seq_operations ipv6_route_seq_ops = {
+	.start	= ipv6_route_seq_start,
+	.next	= ipv6_route_seq_next,
+	.stop	= ipv6_route_seq_stop,
+	.show	= ipv6_route_seq_show
+};
+
+int ipv6_route_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &ipv6_route_seq_ops,
+			    sizeof(struct ipv6_route_iter));
+}
+
+#endif /* CONFIG_PROC_FS */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e22c4db..42cb227 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2729,56 +2729,12 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 
 #ifdef CONFIG_PROC_FS
 
-struct rt6_proc_arg
-{
-	char *buffer;
-	int offset;
-	int length;
-	int skip;
-	int len;
-};
-
-static int rt6_info_route(struct rt6_info *rt, void *p_arg)
-{
-	struct seq_file *m = p_arg;
-
-	seq_printf(m, "%pi6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
-
-#ifdef CONFIG_IPV6_SUBTREES
-	seq_printf(m, "%pi6 %02x ", &rt->rt6i_src.addr, rt->rt6i_src.plen);
-#else
-	seq_puts(m, "00000000000000000000000000000000 00 ");
-#endif
-	if (rt->rt6i_flags & RTF_GATEWAY) {
-		seq_printf(m, "%pi6", &rt->rt6i_gateway);
-	} else {
-		seq_puts(m, "00000000000000000000000000000000");
-	}
-	seq_printf(m, " %08x %08x %08x %08x %8s\n",
-		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
-		   rt->dst.__use, rt->rt6i_flags,
-		   rt->dst.dev ? rt->dst.dev->name : "");
-	return 0;
-}
-
-static int ipv6_route_show(struct seq_file *m, void *v)
-{
-	struct net *net = (struct net *)m->private;
-	fib6_clean_all_ro(net, rt6_info_route, 0, m);
-	return 0;
-}
-
-static int ipv6_route_open(struct inode *inode, struct file *file)
-{
-	return single_open_net(inode, file, ipv6_route_show);
-}
-
 static const struct file_operations ipv6_route_proc_fops = {
 	.owner		= THIS_MODULE,
 	.open		= ipv6_route_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= single_release_net,
+	.release	= seq_release_net,
 };
 
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
-- 
1.8.3.1
