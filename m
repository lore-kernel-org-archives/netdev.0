From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 10/31] netns ct: per-netns conntrack hash
Date: Mon, 21 Jul 2008 20:37:52 +0400
Message-ID: <20080721163752.GN13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:7119 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbYGUQjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:39:40 -0400
Received: by ug-out-1314.google.com with SMTP id h2so274857ugf.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 09:39:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h                  |    6 -
 include/net/netfilter/nf_conntrack_core.h             |    3 
 include/net/netns/conntrack.h                         |    2 
 net/ipv4/netfilter/ipt_MASQUERADE.c                   |    2 
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c        |    2 
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    4 -
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c          |    2 
 net/ipv4/netfilter/nf_nat_core.c                      |    2 
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c        |    2 
 net/netfilter/nf_conntrack_core.c                     |   71 +++++++++---------
 net/netfilter/nf_conntrack_helper.c                   |    2 
 net/netfilter/nf_conntrack_netlink.c                  |   16 ++--
 net/netfilter/nf_conntrack_pptp.c                     |    2 
 net/netfilter/nf_conntrack_proto.c                    |    4 -
 net/netfilter/nf_conntrack_standalone.c               |    4 -
 net/netfilter/xt_connlimit.c                          |    2 
 16 files changed, 64 insertions(+), 62 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -201,11 +201,11 @@ extern void nf_ct_free_hashtable(struct hlist_head *hash, int vmalloced,
 				 unsigned int size);
 
 extern struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(const struct nf_conntrack_tuple *tuple);
+__nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple);
 
 extern void nf_conntrack_hash_insert(struct nf_conn *ct);
 
-extern void nf_conntrack_flush(void);
+extern void nf_conntrack_flush(struct net *net);
 
 extern bool nf_ct_get_tuplepr(const struct sk_buff *skb,
 			      unsigned int nhoff, u_int16_t l3num,
@@ -267,7 +267,7 @@ extern struct nf_conn nf_conntrack_untracked;
 
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 extern void
-nf_ct_iterate_cleanup(int (*iter)(struct nf_conn *i, void *data), void *data);
+nf_ct_iterate_cleanup(struct net *net, int (*iter)(struct nf_conn *i, void *data), void *data);
 extern void nf_conntrack_free(struct nf_conn *ct);
 extern struct nf_conn *
 nf_conntrack_alloc(struct net *net,
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -48,7 +48,7 @@ nf_ct_invert_tuple(struct nf_conntrack_tuple *inverse,
 
 /* Find a connection corresponding to a tuple. */
 extern struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(const struct nf_conntrack_tuple *tuple);
+nf_conntrack_find_get(struct net *net, const struct nf_conntrack_tuple *tuple);
 
 extern int __nf_conntrack_confirm(struct sk_buff *skb);
 
@@ -71,7 +71,6 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l3proto *l3proto,
             const struct nf_conntrack_l4proto *proto);
 
-extern struct hlist_head *nf_conntrack_hash;
 extern spinlock_t nf_conntrack_lock ;
 extern struct hlist_head unconfirmed;
 
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -5,5 +5,7 @@
 
 struct netns_ct {
 	atomic_t		count;
+	struct hlist_head	*hash;
+	int			hash_vmalloc;
 };
 #endif
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -129,7 +129,7 @@ static int masq_device_event(struct notifier_block *this,
 		   and forget them. */
 		NF_CT_ASSERT(dev->ifindex != 0);
 
-		nf_ct_iterate_cleanup(device_cmp, (void *)(long)dev->ifindex);
+		nf_ct_iterate_cleanup(&init_net, device_cmp, (void *)(long)dev->ifindex);
 	}
 
 	return NOTIFY_DONE;
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -323,7 +323,7 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 		return -EINVAL;
 	}
 
-	h = nf_conntrack_find_get(&tuple);
+	h = nf_conntrack_find_get(sock_net(sk), &tuple);
 	if (h) {
 		struct sockaddr_in sin;
 		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -44,7 +44,7 @@ static struct hlist_node *ct_get_first(struct seq_file *seq)
 	for (st->bucket = 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
-		n = rcu_dereference(nf_conntrack_hash[st->bucket].first);
+		n = rcu_dereference(init_net.ct.hash[st->bucket].first);
 		if (n)
 			return n;
 	}
@@ -60,7 +60,7 @@ static struct hlist_node *ct_get_next(struct seq_file *seq,
 	while (head == NULL) {
 		if (++st->bucket >= nf_conntrack_htable_size)
 			return NULL;
-		head = rcu_dereference(nf_conntrack_hash[st->bucket].first);
+		head = rcu_dereference(init_net.ct.hash[st->bucket].first);
 	}
 	return head;
 }
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -155,7 +155,7 @@ icmp_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&innertuple);
+	h = nf_conntrack_find_get(&init_net, &innertuple);
 	if (!h) {
 		pr_debug("icmp_error_message: no match\n");
 		return -NF_ACCEPT;
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -643,7 +643,7 @@ static int clean_nat(struct nf_conn *i, void *data)
 
 static void __exit nf_nat_cleanup(void)
 {
-	nf_ct_iterate_cleanup(&clean_nat, NULL);
+	nf_ct_iterate_cleanup(&init_net, &clean_nat, NULL);
 	synchronize_rcu();
 	nf_ct_free_hashtable(bysource, nf_nat_vmalloced, nf_nat_htable_size);
 	nf_ct_l3proto_put(l3proto);
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -156,7 +156,7 @@ icmpv6_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&intuple);
+	h = nf_conntrack_find_get(&init_net, &intuple);
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -49,15 +49,11 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
 
-struct hlist_head *nf_conntrack_hash __read_mostly;
-EXPORT_SYMBOL_GPL(nf_conntrack_hash);
-
 struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
 unsigned int nf_ct_log_invalid __read_mostly;
 HLIST_HEAD(unconfirmed);
-static int nf_conntrack_vmalloc __read_mostly;
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
 DEFINE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
@@ -241,7 +237,7 @@ static void death_by_timeout(unsigned long ul_conntrack)
 }
 
 struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(const struct nf_conntrack_tuple *tuple)
+__nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_node *n;
@@ -251,7 +247,7 @@ __nf_conntrack_find(const struct nf_conntrack_tuple *tuple)
 	 * at least once for the stats anyway.
 	 */
 	local_bh_disable();
-	hlist_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash], hnode) {
+	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
 		if (nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(found);
 			local_bh_enable();
@@ -267,13 +263,13 @@ EXPORT_SYMBOL_GPL(__nf_conntrack_find);
 
 /* Find a connection corresponding to a tuple. */
 struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(const struct nf_conntrack_tuple *tuple)
+nf_conntrack_find_get(struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 
 	rcu_read_lock();
-	h = __nf_conntrack_find(tuple);
+	h = __nf_conntrack_find(net, tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
@@ -289,10 +285,12 @@ static void __nf_conntrack_hash_insert(struct nf_conn *ct,
 				       unsigned int hash,
 				       unsigned int repl_hash)
 {
+	struct net *net = nf_ct_net(ct);
+
 	hlist_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode,
-			   &nf_conntrack_hash[hash]);
+			   &net->ct.hash[hash]);
 	hlist_add_head_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnode,
-			   &nf_conntrack_hash[repl_hash]);
+			   &net->ct.hash[repl_hash]);
 }
 
 void nf_conntrack_hash_insert(struct nf_conn *ct)
@@ -318,8 +316,10 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	struct nf_conn_help *help;
 	struct hlist_node *n;
 	enum ip_conntrack_info ctinfo;
+	struct net *net;
 
 	ct = nf_ct_get(skb, &ctinfo);
+	net = nf_ct_net(ct);
 
 	/* ipt_REJECT uses nf_conntrack_attach to attach related
 	   ICMP/TCP RST packets in other direction.  Actual packet
@@ -346,11 +346,11 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* See if there's one in the list already, including reverse:
 	   NAT could have grabbed it without realizing, since we're
 	   not in the hash.  If there is, we lost race. */
-	hlist_for_each_entry(h, n, &nf_conntrack_hash[hash], hnode)
+	hlist_for_each_entry(h, n, &net->ct.hash[hash], hnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 				      &h->tuple))
 			goto out;
-	hlist_for_each_entry(h, n, &nf_conntrack_hash[repl_hash], hnode)
+	hlist_for_each_entry(h, n, &net->ct.hash[repl_hash], hnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				      &h->tuple))
 			goto out;
@@ -393,6 +393,7 @@ int
 nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 			 const struct nf_conn *ignored_conntrack)
 {
+	struct net *net = nf_ct_net(ignored_conntrack);
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_node *n;
 	unsigned int hash = hash_conntrack(tuple);
@@ -401,7 +402,7 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	 * least once for the stats anyway.
 	 */
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash], hnode) {
+	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
 		if (nf_ct_tuplehash_to_ctrack(h) != ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(found);
@@ -420,7 +421,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_tuple_taken);
 
 /* There's a small race here where we may free a just-assured
    connection.  Too bad: we're in trouble anyway. */
-static noinline int early_drop(unsigned int hash)
+static noinline int early_drop(struct net *net, unsigned int hash)
 {
 	/* Use oldest entry, which is roughly LRU */
 	struct nf_conntrack_tuple_hash *h;
@@ -431,7 +432,7 @@ static noinline int early_drop(unsigned int hash)
 
 	rcu_read_lock();
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		hlist_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash],
+		hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash],
 					 hnode) {
 			tmp = nf_ct_tuplehash_to_ctrack(h);
 			if (!test_bit(IPS_ASSURED_BIT, &tmp->status))
@@ -477,7 +478,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
 		unsigned int hash = hash_conntrack(orig);
-		if (!early_drop(hash)) {
+		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
 				printk(KERN_WARNING
@@ -628,7 +629,7 @@ resolve_normal_ct(struct sk_buff *skb,
 	}
 
 	/* look for tuple match */
-	h = nf_conntrack_find_get(&tuple);
+	h = nf_conntrack_find_get(&init_net, &tuple);
 	if (!h) {
 		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
@@ -934,7 +935,7 @@ static void nf_conntrack_attach(struct sk_buff *nskb, struct sk_buff *skb)
 
 /* Bring out ya dead! */
 static struct nf_conn *
-get_next_corpse(int (*iter)(struct nf_conn *i, void *data),
+get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 		void *data, unsigned int *bucket)
 {
 	struct nf_conntrack_tuple_hash *h;
@@ -943,7 +944,7 @@ get_next_corpse(int (*iter)(struct nf_conn *i, void *data),
 
 	spin_lock_bh(&nf_conntrack_lock);
 	for (; *bucket < nf_conntrack_htable_size; (*bucket)++) {
-		hlist_for_each_entry(h, n, &nf_conntrack_hash[*bucket], hnode) {
+		hlist_for_each_entry(h, n, &net->ct.hash[*bucket], hnode) {
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			if (iter(ct, data))
 				goto found;
@@ -963,12 +964,12 @@ found:
 }
 
 void
-nf_ct_iterate_cleanup(int (*iter)(struct nf_conn *i, void *data), void *data)
+nf_ct_iterate_cleanup(struct net *net, int (*iter)(struct nf_conn *i, void *data), void *data)
 {
 	struct nf_conn *ct;
 	unsigned int bucket = 0;
 
-	while ((ct = get_next_corpse(iter, data, &bucket)) != NULL) {
+	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
 		/* Time to push up daises... */
 		if (del_timer(&ct->timeout))
 			death_by_timeout((unsigned long)ct);
@@ -994,9 +995,9 @@ void nf_ct_free_hashtable(struct hlist_head *hash, int vmalloced, unsigned int s
 }
 EXPORT_SYMBOL_GPL(nf_ct_free_hashtable);
 
-void nf_conntrack_flush(void)
+void nf_conntrack_flush(struct net *net)
 {
-	nf_ct_iterate_cleanup(kill_all, NULL);
+	nf_ct_iterate_cleanup(net, kill_all, NULL);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_flush);
 
@@ -1013,7 +1014,7 @@ void nf_conntrack_cleanup(struct net *net)
 
 	nf_ct_event_cache_flush();
  i_see_dead_people:
-	nf_conntrack_flush();
+	nf_conntrack_flush(net);
 	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
@@ -1025,7 +1026,7 @@ void nf_conntrack_cleanup(struct net *net)
 	rcu_assign_pointer(nf_ct_destroy, NULL);
 
 	kmem_cache_destroy(nf_conntrack_cachep);
-	nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_vmalloc,
+	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 
 	nf_conntrack_proto_fini();
@@ -1089,8 +1090,8 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	 */
 	spin_lock_bh(&nf_conntrack_lock);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		while (!hlist_empty(&nf_conntrack_hash[i])) {
-			h = hlist_entry(nf_conntrack_hash[i].first,
+		while (!hlist_empty(&init_net.ct.hash[i])) {
+			h = hlist_entry(init_net.ct.hash[i].first,
 					struct nf_conntrack_tuple_hash, hnode);
 			hlist_del_rcu(&h->hnode);
 			bucket = __hash_conntrack(&h->tuple, hashsize, rnd);
@@ -1098,12 +1099,12 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 		}
 	}
 	old_size = nf_conntrack_htable_size;
-	old_vmalloced = nf_conntrack_vmalloc;
-	old_hash = nf_conntrack_hash;
+	old_vmalloced = init_net.ct.hash_vmalloc;
+	old_hash = init_net.ct.hash;
 
 	nf_conntrack_htable_size = hashsize;
-	nf_conntrack_vmalloc = vmalloced;
-	nf_conntrack_hash = hash;
+	init_net.ct.hash_vmalloc = vmalloced;
+	init_net.ct.hash = hash;
 	nf_conntrack_hash_rnd = rnd;
 	spin_unlock_bh(&nf_conntrack_lock);
 
@@ -1138,9 +1139,9 @@ int nf_conntrack_init(struct net *net)
 		max_factor = 4;
 	}
 	atomic_set(&net->ct.count, 0);
-	nf_conntrack_hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
-						  &nf_conntrack_vmalloc);
-	if (!nf_conntrack_hash) {
+	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
+						  &net->ct.hash_vmalloc);
+	if (!net->ct.hash) {
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
 		goto err_out;
 	}
@@ -1193,7 +1194,7 @@ out_fini_proto:
 err_free_conntrack_slab:
 	kmem_cache_destroy(nf_conntrack_cachep);
 err_free_hash:
-	nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_vmalloc,
+	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 err_out:
 	return -ENOMEM;
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -159,7 +159,7 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	hlist_for_each_entry(h, n, &unconfirmed, hnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		hlist_for_each_entry(h, n, &nf_conntrack_hash[i], hnode)
+		hlist_for_each_entry(h, n, &init_net.ct.hash[i], hnode)
 			unhelp(h, me);
 	}
 	spin_unlock_bh(&nf_conntrack_lock);
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -552,7 +552,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < nf_conntrack_htable_size; cb->args[0]++) {
 restart:
-		hlist_for_each_entry_rcu(h, n, &nf_conntrack_hash[cb->args[0]],
+		hlist_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
 					 hnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
@@ -793,14 +793,14 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY, u3);
 	else {
 		/* Flush the whole table */
-		nf_conntrack_flush();
+		nf_conntrack_flush(&init_net);
 		return 0;
 	}
 
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&tuple);
+	h = nf_conntrack_find_get(&init_net, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -851,7 +851,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&tuple);
+	h = nf_conntrack_find_get(&init_net, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -1211,9 +1211,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	spin_lock_bh(&nf_conntrack_lock);
 	if (cda[CTA_TUPLE_ORIG])
-		h = __nf_conntrack_find(&otuple);
+		h = __nf_conntrack_find(&init_net, &otuple);
 	else if (cda[CTA_TUPLE_REPLY])
-		h = __nf_conntrack_find(&rtuple);
+		h = __nf_conntrack_find(&init_net, &rtuple);
 
 	if (h == NULL) {
 		struct nf_conntrack_tuple master;
@@ -1228,7 +1228,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			if (err < 0)
 				goto out_unlock;
 
-			master_h = __nf_conntrack_find(&master);
+			master_h = __nf_conntrack_find(&init_net, &master);
 			if (master_h == NULL) {
 				err = -ENOENT;
 				goto out_unlock;
@@ -1668,7 +1668,7 @@ ctnetlink_create_expect(struct nlattr *cda[], u_int8_t u3)
 		return err;
 
 	/* Look for master conntrack of this expectation */
-	h = nf_conntrack_find_get(&master_tuple);
+	h = nf_conntrack_find_get(&init_net, &master_tuple);
 	if (!h)
 		return -ENOENT;
 	ct = nf_ct_tuplehash_to_ctrack(h);
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -143,7 +143,7 @@ static int destroy_sibling_or_exp(const struct nf_conntrack_tuple *t)
 	pr_debug("trying to timeout ct or exp for tuple ");
 	nf_ct_dump_tuple(t);
 
-	h = nf_conntrack_find_get(t);
+	h = nf_conntrack_find_get(&init_net, t);
 	if (h)  {
 		sibling = nf_ct_tuplehash_to_ctrack(h);
 		pr_debug("setting timeout of conntrack %p to 0\n", sibling);
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -219,7 +219,7 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(kill_l3proto, proto);
+	nf_ct_iterate_cleanup(&init_net, kill_l3proto, proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
@@ -328,7 +328,7 @@ void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(kill_l4proto, l4proto);
+	nf_ct_iterate_cleanup(&init_net, kill_l4proto, l4proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -63,7 +63,7 @@ static struct hlist_node *ct_get_first(struct seq_file *seq)
 	for (st->bucket = 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
-		n = rcu_dereference(nf_conntrack_hash[st->bucket].first);
+		n = rcu_dereference(init_net.ct.hash[st->bucket].first);
 		if (n)
 			return n;
 	}
@@ -79,7 +79,7 @@ static struct hlist_node *ct_get_next(struct seq_file *seq,
 	while (head == NULL) {
 		if (++st->bucket >= nf_conntrack_htable_size)
 			return NULL;
-		head = rcu_dereference(nf_conntrack_hash[st->bucket].first);
+		head = rcu_dereference(init_net.ct.hash[st->bucket].first);
 	}
 	return head;
 }
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -123,7 +123,7 @@ static int count_them(struct xt_connlimit_data *data,
 
 	/* check the saved connections */
 	list_for_each_entry_safe(conn, tmp, hash, list) {
-		found    = __nf_conntrack_find(&conn->tuple);
+		found    = __nf_conntrack_find(&init_net, &conn->tuple);
 		found_ct = NULL;
 
 		if (found != NULL)
-- 
1.5.4.5


