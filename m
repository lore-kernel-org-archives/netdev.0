From: adobriyan@gmail.com
Subject: [PATCH 10/38] netns ct: per-netns expectations
Date: Fri, 22 Aug 2008 02:00:40 +0400
Message-ID: <20080821220040.GJ31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make per-netns expectation hash and expectation count.

Expectation always belongs to netns to which it's master conntrack belongs.
This is natural and allows to not bloat expectations.

Proc files and leaf users in protocol modules are stubbed to init_net,
this is temporary.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_expect.h           |   20 ++++--
 include/net/netns/conntrack.h                         |    3 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    4 -
 net/ipv4/netfilter/nf_nat_pptp.c                      |    2 
 net/netfilter/nf_conntrack_core.c                     |    8 +-
 net/netfilter/nf_conntrack_expect.c                   |   53 ++++++++----------
 net/netfilter/nf_conntrack_h323_main.c                |    2 
 net/netfilter/nf_conntrack_helper.c                   |    2 
 net/netfilter/nf_conntrack_netlink.c                  |   12 ++--
 net/netfilter/nf_conntrack_pptp.c                     |    4 -
 net/netfilter/nf_conntrack_sip.c                      |    3 -
 11 files changed, 61 insertions(+), 52 deletions(-)

--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -6,7 +6,6 @@
 #define _NF_CONNTRACK_EXPECT_H
 #include <net/netfilter/nf_conntrack.h>
 
-extern struct hlist_head *nf_ct_expect_hash;
 extern unsigned int nf_ct_expect_hsize;
 extern unsigned int nf_ct_expect_max;
 
@@ -56,6 +55,15 @@ struct nf_conntrack_expect
 	struct rcu_head rcu;
 };
 
+static inline struct net *nf_ct_exp_net(struct nf_conntrack_expect *exp)
+{
+#ifdef CONFIG_NET_NS
+	return exp->master->ct_net;	/* by definition */
+#else
+	return &init_net;
+#endif
+}
+
 struct nf_conntrack_expect_policy
 {
 	unsigned int	max_expected;
@@ -67,17 +75,17 @@ struct nf_conntrack_expect_policy
 #define NF_CT_EXPECT_PERMANENT	0x1
 #define NF_CT_EXPECT_INACTIVE	0x2
 
-int nf_conntrack_expect_init(void);
-void nf_conntrack_expect_fini(void);
+int nf_conntrack_expect_init(struct net *net);
+void nf_conntrack_expect_fini(struct net *net);
 
 struct nf_conntrack_expect *
-__nf_ct_expect_find(const struct nf_conntrack_tuple *tuple);
+__nf_ct_expect_find(struct net *net, const struct nf_conntrack_tuple *tuple);
 
 struct nf_conntrack_expect *
-nf_ct_expect_find_get(const struct nf_conntrack_tuple *tuple);
+nf_ct_expect_find_get(struct net *net, const struct nf_conntrack_tuple *tuple);
 
 struct nf_conntrack_expect *
-nf_ct_find_expectation(const struct nf_conntrack_tuple *tuple);
+nf_ct_find_expectation(struct net *net, const struct nf_conntrack_tuple *tuple);
 
 void nf_ct_unlink_expect(struct nf_conntrack_expect *exp);
 void nf_ct_remove_expectations(struct nf_conn *ct);
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -7,5 +7,8 @@ struct netns_ct {
 	atomic_t		count;
 	struct hlist_head	*hash;
 	int			hash_vmalloc;
+	unsigned int		expect_count;
+	struct hlist_head	*expect_hash;
+	int			expect_vmalloc;
 };
 #endif
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -181,7 +181,7 @@ static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 	struct hlist_node *n;
 
 	for (st->bucket = 0; st->bucket < nf_ct_expect_hsize; st->bucket++) {
-		n = rcu_dereference(nf_ct_expect_hash[st->bucket].first);
+		n = rcu_dereference(init_net.ct.expect_hash[st->bucket].first);
 		if (n)
 			return n;
 	}
@@ -197,7 +197,7 @@ static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
 	while (head == NULL) {
 		if (++st->bucket >= nf_ct_expect_hsize)
 			return NULL;
-		head = rcu_dereference(nf_ct_expect_hash[st->bucket].first);
+		head = rcu_dereference(init_net.ct.expect_hash[st->bucket].first);
 	}
 	return head;
 }
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -73,7 +73,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 
 	pr_debug("trying to unexpect other dir: ");
 	nf_ct_dump_tuple_ip(&t);
-	other_exp = nf_ct_expect_find_get(&t);
+	other_exp = nf_ct_expect_find_get(&init_net, &t);
 	if (other_exp) {
 		nf_ct_unexpect_related(other_exp);
 		nf_ct_expect_put(other_exp);
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -562,7 +562,7 @@ init_conntrack(struct net *net,
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
 
 	spin_lock_bh(&nf_conntrack_lock);
-	exp = nf_ct_find_expectation(tuple);
+	exp = nf_ct_find_expectation(net, tuple);
 	if (exp) {
 		pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
 			 ct, exp);
@@ -1036,7 +1036,7 @@ void nf_conntrack_cleanup(struct net *net)
 			     nf_conntrack_htable_size);
 
 	nf_conntrack_acct_fini();
-	nf_conntrack_expect_fini();
+	nf_conntrack_expect_fini(net);
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
 }
@@ -1171,7 +1171,7 @@ int nf_conntrack_init(struct net *net)
 	if (ret < 0)
 		goto err_free_conntrack_slab;
 
-	ret = nf_conntrack_expect_init();
+	ret = nf_conntrack_expect_init(net);
 	if (ret < 0)
 		goto out_fini_proto;
 
@@ -1201,7 +1201,7 @@ int nf_conntrack_init(struct net *net)
 out_fini_helper:
 	nf_conntrack_helper_fini();
 out_fini_expect:
-	nf_conntrack_expect_fini();
+	nf_conntrack_expect_fini(net);
 out_fini_proto:
 	nf_conntrack_proto_fini();
 err_free_conntrack_slab:
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -28,17 +28,12 @@
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
 
-struct hlist_head *nf_ct_expect_hash __read_mostly;
-EXPORT_SYMBOL_GPL(nf_ct_expect_hash);
-
 unsigned int nf_ct_expect_hsize __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);
 
 static unsigned int nf_ct_expect_hash_rnd __read_mostly;
-static unsigned int nf_ct_expect_count;
 unsigned int nf_ct_expect_max __read_mostly;
 static int nf_ct_expect_hash_rnd_initted __read_mostly;
-static int nf_ct_expect_vmalloc;
 
 static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
 
@@ -46,12 +41,13 @@ static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
 void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
 {
 	struct nf_conn_help *master_help = nfct_help(exp->master);
+	struct net *net = nf_ct_exp_net(exp);
 
 	NF_CT_ASSERT(master_help);
 	NF_CT_ASSERT(!timer_pending(&exp->timeout));
 
 	hlist_del_rcu(&exp->hnode);
-	nf_ct_expect_count--;
+	net->ct.expect_count--;
 
 	hlist_del(&exp->lnode);
 	master_help->expecting[exp->class]--;
@@ -87,17 +83,17 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 }
 
 struct nf_conntrack_expect *
-__nf_ct_expect_find(const struct nf_conntrack_tuple *tuple)
+__nf_ct_expect_find(struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i;
 	struct hlist_node *n;
 	unsigned int h;
 
-	if (!nf_ct_expect_count)
+	if (!net->ct.expect_count)
 		return NULL;
 
 	h = nf_ct_expect_dst_hash(tuple);
-	hlist_for_each_entry_rcu(i, n, &nf_ct_expect_hash[h], hnode) {
+	hlist_for_each_entry_rcu(i, n, &net->ct.expect_hash[h], hnode) {
 		if (nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask))
 			return i;
 	}
@@ -107,12 +103,12 @@ EXPORT_SYMBOL_GPL(__nf_ct_expect_find);
 
 /* Just find a expectation corresponding to a tuple. */
 struct nf_conntrack_expect *
-nf_ct_expect_find_get(const struct nf_conntrack_tuple *tuple)
+nf_ct_expect_find_get(struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i;
 
 	rcu_read_lock();
-	i = __nf_ct_expect_find(tuple);
+	i = __nf_ct_expect_find(net, tuple);
 	if (i && !atomic_inc_not_zero(&i->use))
 		i = NULL;
 	rcu_read_unlock();
@@ -124,17 +120,17 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_find_get);
 /* If an expectation for this connection is found, it gets delete from
  * global list then returned. */
 struct nf_conntrack_expect *
-nf_ct_find_expectation(const struct nf_conntrack_tuple *tuple)
+nf_ct_find_expectation(struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i, *exp = NULL;
 	struct hlist_node *n;
 	unsigned int h;
 
-	if (!nf_ct_expect_count)
+	if (!net->ct.expect_count)
 		return NULL;
 
 	h = nf_ct_expect_dst_hash(tuple);
-	hlist_for_each_entry(i, n, &nf_ct_expect_hash[h], hnode) {
+	hlist_for_each_entry(i, n, &net->ct.expect_hash[h], hnode) {
 		if (!(i->flags & NF_CT_EXPECT_INACTIVE) &&
 		    nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask)) {
 			exp = i;
@@ -311,6 +307,7 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_put);
 static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 {
 	struct nf_conn_help *master_help = nfct_help(exp->master);
+	struct net *net = nf_ct_exp_net(exp);
 	const struct nf_conntrack_expect_policy *p;
 	unsigned int h = nf_ct_expect_dst_hash(&exp->tuple);
 
@@ -319,8 +316,8 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	hlist_add_head(&exp->lnode, &master_help->expectations);
 	master_help->expecting[exp->class]++;
 
-	hlist_add_head_rcu(&exp->hnode, &nf_ct_expect_hash[h]);
-	nf_ct_expect_count++;
+	hlist_add_head_rcu(&exp->hnode, &net->ct.expect_hash[h]);
+	net->ct.expect_count++;
 
 	setup_timer(&exp->timeout, nf_ct_expectation_timed_out,
 		    (unsigned long)exp);
@@ -371,6 +368,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
 	struct nf_conntrack_expect *i;
 	struct nf_conn *master = expect->master;
 	struct nf_conn_help *master_help = nfct_help(master);
+	struct net *net = nf_ct_exp_net(expect);
 	struct hlist_node *n;
 	unsigned int h;
 	int ret;
@@ -383,7 +381,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
 		goto out;
 	}
 	h = nf_ct_expect_dst_hash(&expect->tuple);
-	hlist_for_each_entry(i, n, &nf_ct_expect_hash[h], hnode) {
+	hlist_for_each_entry(i, n, &net->ct.expect_hash[h], hnode) {
 		if (expect_matches(i, expect)) {
 			/* Refresh timer: if it's dying, ignore.. */
 			if (refresh_timer(i)) {
@@ -406,7 +404,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
 		}
 	}
 
-	if (nf_ct_expect_count >= nf_ct_expect_max) {
+	if (net->ct.expect_count >= nf_ct_expect_max) {
 		if (net_ratelimit())
 			printk(KERN_WARNING
 			       "nf_conntrack: expectation table full\n");
@@ -434,7 +432,7 @@ static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 	struct hlist_node *n;
 
 	for (st->bucket = 0; st->bucket < nf_ct_expect_hsize; st->bucket++) {
-		n = rcu_dereference(nf_ct_expect_hash[st->bucket].first);
+		n = rcu_dereference(init_net.ct.expect_hash[st->bucket].first);
 		if (n)
 			return n;
 	}
@@ -450,7 +448,7 @@ static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
 	while (head == NULL) {
 		if (++st->bucket >= nf_ct_expect_hsize)
 			return NULL;
-		head = rcu_dereference(nf_ct_expect_hash[st->bucket].first);
+		head = rcu_dereference(init_net.ct.expect_hash[st->bucket].first);
 	}
 	return head;
 }
@@ -558,7 +556,7 @@ static void exp_proc_remove(void)
 
 module_param_named(expect_hashsize, nf_ct_expect_hsize, uint, 0600);
 
-int nf_conntrack_expect_init(void)
+int nf_conntrack_expect_init(struct net *net)
 {
 	int err = -ENOMEM;
 
@@ -569,9 +567,10 @@ int nf_conntrack_expect_init(void)
 	}
 	nf_ct_expect_max = nf_ct_expect_hsize * 4;
 
-	nf_ct_expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
-						  &nf_ct_expect_vmalloc);
-	if (nf_ct_expect_hash == NULL)
+	net->ct.expect_count = 0;
+	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
+						  &net->ct.expect_vmalloc);
+	if (net->ct.expect_hash == NULL)
 		goto err1;
 
 	nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
@@ -589,16 +588,16 @@ int nf_conntrack_expect_init(void)
 err3:
 	kmem_cache_destroy(nf_ct_expect_cachep);
 err2:
-	nf_ct_free_hashtable(nf_ct_expect_hash, nf_ct_expect_vmalloc,
+	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 err1:
 	return err;
 }
 
-void nf_conntrack_expect_fini(void)
+void nf_conntrack_expect_fini(struct net *net)
 {
 	exp_proc_remove();
 	kmem_cache_destroy(nf_ct_expect_cachep);
-	nf_ct_free_hashtable(nf_ct_expect_hash, nf_ct_expect_vmalloc,
+	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1218,7 +1218,7 @@ static struct nf_conntrack_expect *find_expect(struct nf_conn *ct,
 	tuple.dst.u.tcp.port = port;
 	tuple.dst.protonum = IPPROTO_TCP;
 
-	exp = __nf_ct_expect_find(&tuple);
+	exp = __nf_ct_expect_find(&init_net, &tuple);
 	if (exp && exp->master == ct)
 		return exp;
 	return NULL;
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -145,7 +145,7 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	/* Get rid of expectations */
 	for (i = 0; i < nf_ct_expect_hsize; i++) {
 		hlist_for_each_entry_safe(exp, n, next,
-					  &nf_ct_expect_hash[i], hnode) {
+					  &init_net.ct.expect_hash[i], hnode) {
 			struct nf_conn_help *help = nfct_help(exp->master);
 			if ((help->helper == me || exp->helper == me) &&
 			    del_timer(&exp->timeout)) {
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1467,7 +1467,7 @@ ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conntrack_expect *)cb->args[1];
 	for (; cb->args[0] < nf_ct_expect_hsize; cb->args[0]++) {
 restart:
-		hlist_for_each_entry(exp, n, &nf_ct_expect_hash[cb->args[0]],
+		hlist_for_each_entry(exp, n, &init_net.ct.expect_hash[cb->args[0]],
 				     hnode) {
 			if (l3proto && exp->tuple.src.l3num != l3proto)
 				continue;
@@ -1529,7 +1529,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	exp = nf_ct_expect_find_get(&tuple);
+	exp = nf_ct_expect_find_get(&init_net, &tuple);
 	if (!exp)
 		return -ENOENT;
 
@@ -1583,7 +1583,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 			return err;
 
 		/* bump usage count to 2 */
-		exp = nf_ct_expect_find_get(&tuple);
+		exp = nf_ct_expect_find_get(&init_net, &tuple);
 		if (!exp)
 			return -ENOENT;
 
@@ -1613,7 +1613,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		}
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, n, next,
-						  &nf_ct_expect_hash[i],
+						  &init_net.ct.expect_hash[i],
 						  hnode) {
 				m_help = nfct_help(exp->master);
 				if (m_help->helper == h
@@ -1629,7 +1629,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		spin_lock_bh(&nf_conntrack_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, n, next,
-						  &nf_ct_expect_hash[i],
+						  &init_net.ct.expect_hash[i],
 						  hnode) {
 				if (del_timer(&exp->timeout)) {
 					nf_ct_unlink_expect(exp);
@@ -1724,7 +1724,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		return err;
 
 	spin_lock_bh(&nf_conntrack_lock);
-	exp = __nf_ct_expect_find(&tuple);
+	exp = __nf_ct_expect_find(&init_net, &tuple);
 
 	if (!exp) {
 		spin_unlock_bh(&nf_conntrack_lock);
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -121,7 +121,7 @@ static void pptp_expectfn(struct nf_conn *ct,
 		pr_debug("trying to unexpect other dir: ");
 		nf_ct_dump_tuple(&inv_t);
 
-		exp_other = nf_ct_expect_find_get(&inv_t);
+		exp_other = nf_ct_expect_find_get(&init_net, &inv_t);
 		if (exp_other) {
 			/* delete other expectation.  */
 			pr_debug("found\n");
@@ -154,7 +154,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 		nf_ct_put(sibling);
 		return 1;
 	} else {
-		exp = nf_ct_expect_find_get(t);
+		exp = nf_ct_expect_find_get(&init_net, t);
 		if (exp) {
 			pr_debug("unexpect_related of expect %p\n", exp);
 			nf_ct_unexpect_related(exp);
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -775,7 +775,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb,
 
 	rcu_read_lock();
 	do {
-		exp = __nf_ct_expect_find(&tuple);
+		exp = __nf_ct_expect_find(&init_net, &tuple);
 
 		if (!exp || exp->master == ct ||
 		    nfct_help(exp->master)->helper != nfct_help(ct)->helper ||
-- 
1.5.6.3


