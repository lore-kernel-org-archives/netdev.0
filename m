From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Wed, 25 Mar 2009 04:53:16 +0100
Message-ID: <49C9AAAC.30607@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net> <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se> <49C8A415.1090606@cosmosbay.com> <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se> <49C8CCF4.5050104@cosmosbay.com> <49C8D13D.10307@cosmosbay.com> <49C8D58A.6060401@trash.net> <49C8E0D3.1010202@cosmosbay.com> <49C8E268.6090507@trash.net> <49C8E48D.2070501@cosmosbay.com> <49C8F871.9070600@cosmosbay.com> <49C8F8E0.9050502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49C8F8E0.9050502@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Eric Dumazet a =E9crit :
>>> Patrick McHardy a =E9crit :
>>>> Eric Dumazet wrote:
>>
>>>>> Maybe we could use SLAB_DESTROY_BY_RCU thing and no more call_rcu=
()
>>>>> queueing
>>>>> problem. That would better use CPU caches as well...
>>>> I'm not sure I understand the rules correctly, but we'd still
>>>> have to wait for the grace period before an object can be reused,
>>>> no?
>>> No we dont have to, but we must do additionnal checks after getting
>>> a reference on object found on lookup.
>>> (We must re-check the keys used during search)
>>>
>>> This re-check is not very expensive since everything is hot in cpu
>>> cache.
>>>
>>> Check Documentation/RCU/rculist_nulls.txt for some documentation.
>>>
>>
>> Patrick, I can work on this if you want, since this stuff is fresh
>> in my head, let me know if you already challenged it or not :)
>=20
> I'm still looking at the details, if you want to take care of this,
> that would be great .)
>=20
>=20

I have a litle problem on __nf_conntrack_find() being exported.

Problem is that with SLAB_DESTROY_BY_RCU we must take a reference on ob=
ject
to recheck it. So ideally  only nf_conntrack_find_get() should be used,
or callers of __nf_conntrack_find() should lock nf_conntrack_lock
(as properly done for example in net/netfilter/nf_conntrack_netlink.c, =
line 1292)

Here is preliminary patch for review (not tested at all, its 4h50 am he=
re :) )

Could you help me, by checking __nf_conntrack_find() use in net/netfilt=
er/xt_connlimit.c ?
and line 1246 of net/netfilter/nf_conntrack_netlink.c

This part is a litle bit gray for me. :)

Thank you

(Patch against nf-next-2.6 tree of course)

Eric

 include/net/netfilter/nf_conntrack.h                  |   14 -
 include/net/netfilter/nf_conntrack_tuple.h            |    6
 include/net/netns/conntrack.h                         |    5
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |   16 -
 net/ipv4/netfilter/nf_nat_core.c                      |    2
 net/netfilter/nf_conntrack_core.c                     |  121 +++++----=
-
 net/netfilter/nf_conntrack_expect.c                   |    2
 net/netfilter/nf_conntrack_helper.c                   |    7
 net/netfilter/nf_conntrack_netlink.c                  |    7
 net/netfilter/nf_conntrack_standalone.c               |   16 -
 10 files changed, 109 insertions(+), 87 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilt=
er/nf_conntrack.h
index 4dfb793..6c3f964 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -91,8 +91,7 @@ struct nf_conn_help {
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
=20
-struct nf_conn
-{
+struct nf_conn {
 	/* Usage count in here is 1 for hash table/destruct timer, 1 per skb,
            plus 1 for any connection(s) we are `master' for */
 	struct nf_conntrack ct_general;
@@ -126,7 +125,6 @@ struct nf_conn
 #ifdef CONFIG_NET_NS
 	struct net *ct_net;
 #endif
-	struct rcu_head rcu;
 };
=20
 static inline struct nf_conn *
@@ -190,9 +188,13 @@ static inline void nf_ct_put(struct nf_conn *ct)
 extern int nf_ct_l3proto_try_module_get(unsigned short l3proto);
 extern void nf_ct_l3proto_module_put(unsigned short l3proto);
=20
-extern struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, i=
nt *vmalloced);
-extern void nf_ct_free_hashtable(struct hlist_head *hash, int vmalloce=
d,
-				 unsigned int size);
+/*
+ * Allocate a hashtable of hlist_head (if nulls =3D=3D 0),
+ * or hlist_nulls_head (if nulls =3D=3D 1)
+ */
+extern void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced=
, int nulls);
+
+extern void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned i=
nt size);
=20
 extern struct nf_conntrack_tuple_hash *
 __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *=
tuple);
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/n=
etfilter/nf_conntrack_tuple.h
index f2f6aa7..2628c15 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -12,6 +12,7 @@
=20
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <linux/list_nulls.h>
=20
 /* A `tuple' is a structure containing the information to uniquely
   identify a connection.  ie. if two packets have the same tuple, they
@@ -146,9 +147,8 @@ static inline void nf_ct_dump_tuple(const struct nf=
_conntrack_tuple *t)
 	((enum ip_conntrack_dir)(h)->tuple.dst.dir)
=20
 /* Connections have two entries in the hash table: one for each way */
-struct nf_conntrack_tuple_hash
-{
-	struct hlist_node hnode;
+struct nf_conntrack_tuple_hash {
+	struct hlist_nulls_node hnnode;
 	struct nf_conntrack_tuple tuple;
 };
=20
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrac=
k.h
index f4498a6..9dc5840 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -2,6 +2,7 @@
 #define __NETNS_CONNTRACK_H
=20
 #include <linux/list.h>
+#include <linux/list_nulls.h>
 #include <asm/atomic.h>
=20
 struct ctl_table_header;
@@ -10,9 +11,9 @@ struct nf_conntrack_ecache;
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
-	struct hlist_head	*hash;
+	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
-	struct hlist_head	unconfirmed;
+	struct hlist_nulls_head	unconfirmed;
 	struct ip_conntrack_stat *stat;
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct nf_conntrack_ecache *ecache;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/ne=
t/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 6ba5c55..fcbcf62 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -25,30 +25,30 @@ struct ct_iter_state {
 	unsigned int bucket;
 };
=20
-static struct hlist_node *ct_get_first(struct seq_file *seq)
+static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 {
 	struct net *net =3D seq_file_net(seq);
 	struct ct_iter_state *st =3D seq->private;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
=20
 	for (st->bucket =3D 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
 		n =3D rcu_dereference(net->ct.hash[st->bucket].first);
-		if (n)
+		if (!is_a_nulls(n))
 			return n;
 	}
 	return NULL;
 }
=20
-static struct hlist_node *ct_get_next(struct seq_file *seq,
-				      struct hlist_node *head)
+static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
+				      struct hlist_nulls_node *head)
 {
 	struct net *net =3D seq_file_net(seq);
 	struct ct_iter_state *st =3D seq->private;
=20
 	head =3D rcu_dereference(head->next);
-	while (head =3D=3D NULL) {
+	while (is_a_nulls(head)) {
 		if (++st->bucket >=3D nf_conntrack_htable_size)
 			return NULL;
 		head =3D rcu_dereference(net->ct.hash[st->bucket].first);
@@ -56,9 +56,9 @@ static struct hlist_node *ct_get_next(struct seq_file=
 *seq,
 	return head;
 }
=20
-static struct hlist_node *ct_get_idx(struct seq_file *seq, loff_t pos)
+static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq, loff_=
t pos)
 {
-	struct hlist_node *head =3D ct_get_first(seq);
+	struct hlist_nulls_node *head =3D ct_get_first(seq);
=20
 	if (head)
 		while (pos && (head =3D ct_get_next(seq, head)))
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_n=
at_core.c
index a65cf69..fe65187 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -679,7 +679,7 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 static int __net_init nf_nat_net_init(struct net *net)
 {
 	net->ipv4.nat_bysource =3D nf_ct_alloc_hashtable(&nf_nat_htable_size,
-						      &net->ipv4.nat_vmalloced);
+						      &net->ipv4.nat_vmalloced, 0);
 	if (!net->ipv4.nat_bysource)
 		return -ENOMEM;
 	return 0;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 55befe5..9f714e9 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -29,6 +29,7 @@
 #include <linux/netdevice.h>
 #include <linux/socket.h>
 #include <linux/mm.h>
+#include <linux/rculist_nulls.h>
=20
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
@@ -163,8 +164,8 @@ static void
 clean_from_lists(struct nf_conn *ct)
 {
 	pr_debug("clean_from_lists(%p)\n", ct);
-	hlist_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
-	hlist_del_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnode);
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode);
=20
 	/* Destroy all pending expectations */
 	nf_ct_remove_expectations(ct);
@@ -204,8 +205,8 @@ destroy_conntrack(struct nf_conntrack *nfct)
=20
 	/* We overload first tuple to link into unconfirmed list. */
 	if (!nf_ct_is_confirmed(ct)) {
-		BUG_ON(hlist_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode));
-		hlist_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
+		BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnod=
e));
+		hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 	}
=20
 	NF_CT_STAT_INC(net, delete);
@@ -242,18 +243,26 @@ static void death_by_timeout(unsigned long ul_con=
ntrack)
 	nf_ct_put(ct);
 }
=20
+/*
+ * Warning :
+ * - Caller must take a reference on returned object
+ *   and recheck nf_ct_tuple_equal(tuple, &h->tuple)
+ * OR
+ * - Caller must lock nf_conntrack_lock before calling this function
+ */
 struct nf_conntrack_tuple_hash *
 __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *=
tuple)
 {
 	struct nf_conntrack_tuple_hash *h;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	unsigned int hash =3D hash_conntrack(tuple);
=20
 	/* Disable BHs the entire time since we normally need to disable them
 	 * at least once for the stats anyway.
 	 */
 	local_bh_disable();
-	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
+begin:
+	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
 		if (nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(net, found);
 			local_bh_enable();
@@ -261,6 +270,13 @@ __nf_conntrack_find(struct net *net, const struct =
nf_conntrack_tuple *tuple)
 		}
 		NF_CT_STAT_INC(net, searched);
 	}
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (get_nulls_value(n) !=3D hash)
+		goto begin;
 	local_bh_enable();
=20
 	return NULL;
@@ -275,11 +291,18 @@ nf_conntrack_find_get(struct net *net, const stru=
ct nf_conntrack_tuple *tuple)
 	struct nf_conn *ct;
=20
 	rcu_read_lock();
+begin:
 	h =3D __nf_conntrack_find(net, tuple);
 	if (h) {
 		ct =3D nf_ct_tuplehash_to_ctrack(h);
 		if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
 			h =3D NULL;
+		else {
+			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple))) {
+				nf_ct_put(ct);
+				goto begin;
+			}
+		}
 	}
 	rcu_read_unlock();
=20
@@ -293,9 +316,9 @@ static void __nf_conntrack_hash_insert(struct nf_co=
nn *ct,
 {
 	struct net *net =3D nf_ct_net(ct);
=20
-	hlist_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode,
+	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 			   &net->ct.hash[hash]);
-	hlist_add_head_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnode,
+	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode,
 			   &net->ct.hash[repl_hash]);
 }
=20
@@ -318,7 +341,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	enum ip_conntrack_info ctinfo;
 	struct net *net;
=20
@@ -350,17 +373,17 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* See if there's one in the list already, including reverse:
 	   NAT could have grabbed it without realizing, since we're
 	   not in the hash.  If there is, we lost race. */
-	hlist_for_each_entry(h, n, &net->ct.hash[hash], hnode)
+	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 				      &h->tuple))
 			goto out;
-	hlist_for_each_entry(h, n, &net->ct.hash[repl_hash], hnode)
+	hlist_nulls_for_each_entry(h, n, &net->ct.hash[repl_hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				      &h->tuple))
 			goto out;
=20
 	/* Remove from unconfirmed list */
-	hlist_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
=20
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	/* Timer relative to confirmation time, not original
@@ -399,14 +422,14 @@ nf_conntrack_tuple_taken(const struct nf_conntrac=
k_tuple *tuple,
 {
 	struct net *net =3D nf_ct_net(ignored_conntrack);
 	struct nf_conntrack_tuple_hash *h;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	unsigned int hash =3D hash_conntrack(tuple);
=20
 	/* Disable BHs the entire time since we need to disable them at
 	 * least once for the stats anyway.
 	 */
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
+	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
 		if (nf_ct_tuplehash_to_ctrack(h) !=3D ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(net, found);
@@ -430,14 +453,14 @@ static noinline int early_drop(struct net *net, u=
nsigned int hash)
 	/* Use oldest entry, which is roughly LRU */
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct =3D NULL, *tmp;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	unsigned int i, cnt =3D 0;
 	int dropped =3D 0;
=20
 	rcu_read_lock();
 	for (i =3D 0; i < nf_conntrack_htable_size; i++) {
-		hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash],
-					 hnode) {
+		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash],
+					 hnnode) {
 			tmp =3D nf_ct_tuplehash_to_ctrack(h);
 			if (!test_bit(IPS_ASSURED_BIT, &tmp->status))
 				ct =3D tmp;
@@ -508,27 +531,19 @@ struct nf_conn *nf_conntrack_alloc(struct net *ne=
t,
 #ifdef CONFIG_NET_NS
 	ct->ct_net =3D net;
 #endif
-	INIT_RCU_HEAD(&ct->rcu);
=20
 	return ct;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
=20
-static void nf_conntrack_free_rcu(struct rcu_head *head)
-{
-	struct nf_conn *ct =3D container_of(head, struct nf_conn, rcu);
-
-	nf_ct_ext_free(ct);
-	kmem_cache_free(nf_conntrack_cachep, ct);
-}
-
 void nf_conntrack_free(struct nf_conn *ct)
 {
 	struct net *net =3D nf_ct_net(ct);
=20
 	nf_ct_ext_destroy(ct);
 	atomic_dec(&net->ct.count);
-	call_rcu(&ct->rcu, nf_conntrack_free_rcu);
+	nf_ct_ext_free(ct);
+	kmem_cache_free(nf_conntrack_cachep, ct);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_free);
=20
@@ -594,7 +609,7 @@ init_conntrack(struct net *net,
 	}
=20
 	/* Overload tuple linked list to put us in unconfirmed list. */
-	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode,
+	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 		       &net->ct.unconfirmed);
=20
 	spin_unlock_bh(&nf_conntrack_lock);
@@ -934,17 +949,17 @@ get_next_corpse(struct net *net, int (*iter)(stru=
ct nf_conn *i, void *data),
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
=20
 	spin_lock_bh(&nf_conntrack_lock);
 	for (; *bucket < nf_conntrack_htable_size; (*bucket)++) {
-		hlist_for_each_entry(h, n, &net->ct.hash[*bucket], hnode) {
+		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
 			ct =3D nf_ct_tuplehash_to_ctrack(h);
 			if (iter(ct, data))
 				goto found;
 		}
 	}
-	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode) {
+	hlist_nulls_for_each_entry(h, n, &net->ct.unconfirmed, hnnode) {
 		ct =3D nf_ct_tuplehash_to_ctrack(h);
 		if (iter(ct, data))
 			set_bit(IPS_DYING_BIT, &ct->status);
@@ -992,7 +1007,7 @@ static int kill_all(struct nf_conn *i, void *data)
 	return 1;
 }
=20
-void nf_ct_free_hashtable(struct hlist_head *hash, int vmalloced, unsi=
gned int size)
+void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size=
)
 {
 	if (vmalloced)
 		vfree(hash);
@@ -1060,26 +1075,28 @@ void nf_conntrack_cleanup(struct net *net)
 	}
 }
=20
-struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, int *vma=
lloced)
+void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int n=
ulls)
 {
-	struct hlist_head *hash;
-	unsigned int size, i;
+	struct hlist_nulls_head *hash;
+	unsigned int nr_slots, i;
+	size_t sz;
=20
 	*vmalloced =3D 0;
=20
-	size =3D *sizep =3D roundup(*sizep, PAGE_SIZE / sizeof(struct hlist_h=
ead));
-	hash =3D (void*)__get_free_pages(GFP_KERNEL|__GFP_NOWARN,
-				       get_order(sizeof(struct hlist_head)
-						 * size));
+	BUILD_BUG_ON(sizeof(struct hlist_nulls_head) !=3D sizeof(struct hlist=
_head));
+	nr_slots =3D *sizep =3D roundup(*sizep, PAGE_SIZE / sizeof(struct hli=
st_nulls_head));
+	sz =3D nr_slots * sizeof(struct hlist_nulls_head);
+	hash =3D (void *)__get_free_pages(GFP_KERNEL | __GFP_NOWARN | __GFP_Z=
ERO,
+					get_order(sz));
 	if (!hash) {
 		*vmalloced =3D 1;
 		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
-		hash =3D vmalloc(sizeof(struct hlist_head) * size);
+		hash =3D __vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	}
=20
-	if (hash)
-		for (i =3D 0; i < size; i++)
-			INIT_HLIST_HEAD(&hash[i]);
+	if (hash && nulls)
+		for (i =3D 0; i < nr_slots; i++)
+			INIT_HLIST_NULLS_HEAD(&hash[i], i);
=20
 	return hash;
 }
@@ -1090,7 +1107,7 @@ int nf_conntrack_set_hashsize(const char *val, st=
ruct kernel_param *kp)
 	int i, bucket, vmalloced, old_vmalloced;
 	unsigned int hashsize, old_size;
 	int rnd;
-	struct hlist_head *hash, *old_hash;
+	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
=20
 	/* On boot, we can set this without any fancy locking. */
@@ -1101,7 +1118,7 @@ int nf_conntrack_set_hashsize(const char *val, st=
ruct kernel_param *kp)
 	if (!hashsize)
 		return -EINVAL;
=20
-	hash =3D nf_ct_alloc_hashtable(&hashsize, &vmalloced);
+	hash =3D nf_ct_alloc_hashtable(&hashsize, &vmalloced, 1);
 	if (!hash)
 		return -ENOMEM;
=20
@@ -1116,12 +1133,12 @@ int nf_conntrack_set_hashsize(const char *val, =
struct kernel_param *kp)
 	 */
 	spin_lock_bh(&nf_conntrack_lock);
 	for (i =3D 0; i < nf_conntrack_htable_size; i++) {
-		while (!hlist_empty(&init_net.ct.hash[i])) {
-			h =3D hlist_entry(init_net.ct.hash[i].first,
-					struct nf_conntrack_tuple_hash, hnode);
-			hlist_del_rcu(&h->hnode);
+		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
+			h =3D hlist_nulls_entry(init_net.ct.hash[i].first,
+					struct nf_conntrack_tuple_hash, hnnode);
+			hlist_nulls_del_rcu(&h->hnnode);
 			bucket =3D __hash_conntrack(&h->tuple, hashsize, rnd);
-			hlist_add_head(&h->hnode, &hash[bucket]);
+			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
 	old_size =3D nf_conntrack_htable_size;
@@ -1172,7 +1189,7 @@ static int nf_conntrack_init_init_net(void)
=20
 	nf_conntrack_cachep =3D kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
-						0, 0, NULL);
+						0, SLAB_DESTROY_BY_RCU, NULL);
 	if (!nf_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
 		ret =3D -ENOMEM;
@@ -1212,7 +1229,7 @@ static int nf_conntrack_init_net(struct net *net)
 	if (ret < 0)
 		goto err_ecache;
 	net->ct.hash =3D nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
-						  &net->ct.hash_vmalloc);
+					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
 		ret =3D -ENOMEM;
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_con=
ntrack_expect.c
index 357ba39..3940f99 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -604,7 +604,7 @@ int nf_conntrack_expect_init(struct net *net)
=20
 	net->ct.expect_count =3D 0;
 	net->ct.expect_hash =3D nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
-						  &net->ct.expect_vmalloc);
+						  &net->ct.expect_vmalloc, 0);
 	if (net->ct.expect_hash =3D=3D NULL)
 		goto err1;
=20
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_con=
ntrack_helper.c
index a51bdac..6066144 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -158,6 +158,7 @@ static void __nf_conntrack_helper_unregister(struct=
 nf_conntrack_helper *me,
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_expect *exp;
 	const struct hlist_node *n, *next;
+	const struct hlist_nulls_node *nn;
 	unsigned int i;
=20
 	/* Get rid of expectations */
@@ -174,10 +175,10 @@ static void __nf_conntrack_helper_unregister(stru=
ct nf_conntrack_helper *me,
 	}
=20
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode)
+	hlist_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
 		unhelp(h, me);
 	for (i =3D 0; i < nf_conntrack_htable_size; i++) {
-		hlist_for_each_entry(h, n, &net->ct.hash[i], hnode)
+		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 			unhelp(h, me);
 	}
 }
@@ -217,7 +218,7 @@ int nf_conntrack_helper_init(void)
=20
 	nf_ct_helper_hsize =3D 1; /* gets rounded up to use one page */
 	nf_ct_helper_hash =3D nf_ct_alloc_hashtable(&nf_ct_helper_hsize,
-						  &nf_ct_helper_vmalloc);
+						  &nf_ct_helper_vmalloc, 0);
 	if (!nf_ct_helper_hash)
 		return -ENOMEM;
=20
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_co=
nntrack_netlink.c
index 1b75c9e..6520c94 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -19,6 +19,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/rculist.h>
+#include <linux/rculist_nulls.h>
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/skbuff.h>
@@ -536,7 +537,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct ne=
tlink_callback *cb)
 {
 	struct nf_conn *ct, *last;
 	struct nf_conntrack_tuple_hash *h;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	struct nfgenmsg *nfmsg =3D NLMSG_DATA(cb->nlh);
 	u_int8_t l3proto =3D nfmsg->nfgen_family;
=20
@@ -544,8 +545,8 @@ ctnetlink_dump_table(struct sk_buff *skb, struct ne=
tlink_callback *cb)
 	last =3D (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < nf_conntrack_htable_size; cb->args[0]++) {
 restart:
-		hlist_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
-					 hnode) {
+		hlist_nulls_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
+					 hnnode) {
 			if (NF_CT_DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
 				continue;
 			ct =3D nf_ct_tuplehash_to_ctrack(h);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf=
_conntrack_standalone.c
index 4da54b0..f768368 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -44,30 +44,30 @@ struct ct_iter_state {
 	unsigned int bucket;
 };
=20
-static struct hlist_node *ct_get_first(struct seq_file *seq)
+static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 {
 	struct net *net =3D seq_file_net(seq);
 	struct ct_iter_state *st =3D seq->private;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
=20
 	for (st->bucket =3D 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
 		n =3D rcu_dereference(net->ct.hash[st->bucket].first);
-		if (n)
+		if (!is_a_nulls(n))
 			return n;
 	}
 	return NULL;
 }
=20
-static struct hlist_node *ct_get_next(struct seq_file *seq,
-				      struct hlist_node *head)
+static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
+				      struct hlist_nulls_node *head)
 {
 	struct net *net =3D seq_file_net(seq);
 	struct ct_iter_state *st =3D seq->private;
=20
 	head =3D rcu_dereference(head->next);
-	while (head =3D=3D NULL) {
+	while (is_a_nulls(head)) {
 		if (++st->bucket >=3D nf_conntrack_htable_size)
 			return NULL;
 		head =3D rcu_dereference(net->ct.hash[st->bucket].first);
@@ -75,9 +75,9 @@ static struct hlist_node *ct_get_next(struct seq_file=
 *seq,
 	return head;
 }
=20
-static struct hlist_node *ct_get_idx(struct seq_file *seq, loff_t pos)
+static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq, loff_=
t pos)
 {
-	struct hlist_node *head =3D ct_get_first(seq);
+	struct hlist_nulls_node *head =3D ct_get_first(seq);
=20
 	if (head)
 		while (pos && (head =3D ct_get_next(seq, head)))

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
