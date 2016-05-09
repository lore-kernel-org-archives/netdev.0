From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 33/36] netfilter: conntrack: use a single expectation table for all namespaces
Date: Mon,  9 May 2016 20:46:51 +0200
Message-ID: <1462819614-5402-34-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45825 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808AbcEISrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5E983E8E8A
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 49757134702
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 08A78134704
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:33 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We already include netns address in the hash and compare the netns pointers
during lookup, so even if namespaces have overlapping addresses entries
will be spread across the expectation table.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_expect.h        |  1 +
 include/net/netns/conntrack.h                      |  1 -
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |  6 ++--
 net/netfilter/nf_conntrack_expect.c                | 42 ++++++++++------------
 net/netfilter/nf_conntrack_helper.c                |  2 +-
 net/netfilter/nf_conntrack_netlink.c               |  6 ++--
 6 files changed, 25 insertions(+), 33 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index dce56f0..5ed33ea 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -10,6 +10,7 @@
 
 extern unsigned int nf_ct_expect_hsize;
 extern unsigned int nf_ct_expect_max;
+extern struct hlist_head *nf_ct_expect_hash;
 
 struct nf_conntrack_expect {
 	/* Conntrack expectation list member */
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 251c435..2811ddc 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -94,7 +94,6 @@ struct netns_ct {
 	int			sysctl_checksum;
 
 	struct kmem_cache	*nf_conntrack_cachep;
-	struct hlist_head	*expect_hash;
 	struct ct_pcpu __percpu *pcpu_lists;
 	struct ip_conntrack_stat __percpu *stat;
 	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 2b4c729..c6f3c40 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -236,13 +236,12 @@ struct ct_expect_iter_state {
 
 static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_expect_iter_state *st = seq->private;
 	struct hlist_node *n;
 
 	for (st->bucket = 0; st->bucket < nf_ct_expect_hsize; st->bucket++) {
 		n = rcu_dereference(
-			hlist_first_rcu(&net->ct.expect_hash[st->bucket]));
+			hlist_first_rcu(&nf_ct_expect_hash[st->bucket]));
 		if (n)
 			return n;
 	}
@@ -252,7 +251,6 @@ static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
 					     struct hlist_node *head)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_expect_iter_state *st = seq->private;
 
 	head = rcu_dereference(hlist_next_rcu(head));
@@ -260,7 +258,7 @@ static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
 		if (++st->bucket >= nf_ct_expect_hsize)
 			return NULL;
 		head = rcu_dereference(
-			hlist_first_rcu(&net->ct.expect_hash[st->bucket]));
+			hlist_first_rcu(&nf_ct_expect_hash[st->bucket]));
 	}
 	return head;
 }
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 130f1be..9e36931 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -36,6 +36,9 @@
 unsigned int nf_ct_expect_hsize __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);
 
+struct hlist_head *nf_ct_expect_hash __read_mostly;
+EXPORT_SYMBOL_GPL(nf_ct_expect_hash);
+
 unsigned int nf_ct_expect_max __read_mostly;
 
 static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
@@ -112,7 +115,7 @@ __nf_ct_expect_find(struct net *net,
 		return NULL;
 
 	h = nf_ct_expect_dst_hash(net, tuple);
-	hlist_for_each_entry_rcu(i, &net->ct.expect_hash[h], hnode) {
+	hlist_for_each_entry_rcu(i, &nf_ct_expect_hash[h], hnode) {
 		if (nf_ct_exp_equal(tuple, i, zone, net))
 			return i;
 	}
@@ -152,7 +155,7 @@ nf_ct_find_expectation(struct net *net,
 		return NULL;
 
 	h = nf_ct_expect_dst_hash(net, tuple);
-	hlist_for_each_entry(i, &net->ct.expect_hash[h], hnode) {
+	hlist_for_each_entry(i, &nf_ct_expect_hash[h], hnode) {
 		if (!(i->flags & NF_CT_EXPECT_INACTIVE) &&
 		    nf_ct_exp_equal(tuple, i, zone, net)) {
 			exp = i;
@@ -363,7 +366,7 @@ static int nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	hlist_add_head(&exp->lnode, &master_help->expectations);
 	master_help->expecting[exp->class]++;
 
-	hlist_add_head_rcu(&exp->hnode, &net->ct.expect_hash[h]);
+	hlist_add_head_rcu(&exp->hnode, &nf_ct_expect_hash[h]);
 	net->ct.expect_count++;
 
 	setup_timer(&exp->timeout, nf_ct_expectation_timed_out,
@@ -415,7 +418,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 		goto out;
 	}
 	h = nf_ct_expect_dst_hash(net, &expect->tuple);
-	hlist_for_each_entry_safe(i, next, &net->ct.expect_hash[h], hnode) {
+	hlist_for_each_entry_safe(i, next, &nf_ct_expect_hash[h], hnode) {
 		if (expect_matches(i, expect)) {
 			if (del_timer(&i->timeout)) {
 				nf_ct_unlink_expect(i);
@@ -481,12 +484,11 @@ struct ct_expect_iter_state {
 
 static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_expect_iter_state *st = seq->private;
 	struct hlist_node *n;
 
 	for (st->bucket = 0; st->bucket < nf_ct_expect_hsize; st->bucket++) {
-		n = rcu_dereference(hlist_first_rcu(&net->ct.expect_hash[st->bucket]));
+		n = rcu_dereference(hlist_first_rcu(&nf_ct_expect_hash[st->bucket]));
 		if (n)
 			return n;
 	}
@@ -496,14 +498,13 @@ static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
 					     struct hlist_node *head)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_expect_iter_state *st = seq->private;
 
 	head = rcu_dereference(hlist_next_rcu(head));
 	while (head == NULL) {
 		if (++st->bucket >= nf_ct_expect_hsize)
 			return NULL;
-		head = rcu_dereference(hlist_first_rcu(&net->ct.expect_hash[st->bucket]));
+		head = rcu_dereference(hlist_first_rcu(&nf_ct_expect_hash[st->bucket]));
 	}
 	return head;
 }
@@ -636,28 +637,13 @@ module_param_named(expect_hashsize, nf_ct_expect_hsize, uint, 0400);
 
 int nf_conntrack_expect_pernet_init(struct net *net)
 {
-	int err = -ENOMEM;
-
 	net->ct.expect_count = 0;
-	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize, 0);
-	if (net->ct.expect_hash == NULL)
-		goto err1;
-
-	err = exp_proc_init(net);
-	if (err < 0)
-		goto err2;
-
-	return 0;
-err2:
-	nf_ct_free_hashtable(net->ct.expect_hash, nf_ct_expect_hsize);
-err1:
-	return err;
+	return exp_proc_init(net);
 }
 
 void nf_conntrack_expect_pernet_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	nf_ct_free_hashtable(net->ct.expect_hash, nf_ct_expect_hsize);
 }
 
 int nf_conntrack_expect_init(void)
@@ -673,6 +659,13 @@ int nf_conntrack_expect_init(void)
 				0, 0, NULL);
 	if (!nf_ct_expect_cachep)
 		return -ENOMEM;
+
+	nf_ct_expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize, 0);
+	if (!nf_ct_expect_hash) {
+		kmem_cache_destroy(nf_ct_expect_cachep);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
@@ -680,4 +673,5 @@ void nf_conntrack_expect_fini(void)
 {
 	rcu_barrier(); /* Wait for call_rcu() before destroy */
 	kmem_cache_destroy(nf_ct_expect_cachep);
+	nf_ct_free_hashtable(nf_ct_expect_hash, nf_ct_expect_hsize);
 }
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index cb48e6a..f703adb 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -400,7 +400,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	spin_lock_bh(&nf_conntrack_expect_lock);
 	for (i = 0; i < nf_ct_expect_hsize; i++) {
 		hlist_for_each_entry_safe(exp, next,
-					  &net->ct.expect_hash[i], hnode) {
+					  &nf_ct_expect_hash[i], hnode) {
 			struct nf_conn_help *help = nfct_help(exp->master);
 			if ((rcu_dereference_protected(
 					help->helper,
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 5dfb84d..a18d1ce 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2632,7 +2632,7 @@ ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conntrack_expect *)cb->args[1];
 	for (; cb->args[0] < nf_ct_expect_hsize; cb->args[0]++) {
 restart:
-		hlist_for_each_entry(exp, &net->ct.expect_hash[cb->args[0]],
+		hlist_for_each_entry(exp, &nf_ct_expect_hash[cb->args[0]],
 				     hnode) {
 			if (l3proto && exp->tuple.src.l3num != l3proto)
 				continue;
@@ -2890,7 +2890,7 @@ static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 		spin_lock_bh(&nf_conntrack_expect_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, next,
-						  &net->ct.expect_hash[i],
+						  &nf_ct_expect_hash[i],
 						  hnode) {
 
 				if (!net_eq(nf_ct_exp_net(exp), net))
@@ -2912,7 +2912,7 @@ static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 		spin_lock_bh(&nf_conntrack_expect_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, next,
-						  &net->ct.expect_hash[i],
+						  &nf_ct_expect_hash[i],
 						  hnode) {
 
 				if (!net_eq(nf_ct_exp_net(exp), net))
-- 
2.1.4
