From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 20:58:08 +0100
Message-ID: <49CA8CD0.2010907@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net> <49CA74CA.1040603@cosmosbay.com> <49CA76C4.2090409@trash.net> <49CA7DAF.9070207@cosmosbay.com> <49CA7F45.5020800@trash.n
 et> <49CA8350.5040407@cosmosbay.com> <49CA88D4.6010808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49CA88D4.6010808@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Patrick McHardy a =E9crit :
>>>>      NF_CT_ASSERT(ct);
>>>> +    if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
>>>> +        return 0;
>>> Can we assume the next pointer still points to the next entry
>>> in the same chain after the refcount dropped to zero?
>>>
>>
>> We are looking chain N.
>> If we cannot atomic_inc() refcount, we got some deleted entry.
>> If we could atomic_inc, we can meet an entry that just moved to
>> another chain X
>>
>> When hitting its end, we continue the search to the N+1 chain so we
>> only skip the end of previous chain (N). We can 'forget' some entrie=
s,
>> we can print
>> several time one given entry.
>>
>>
>> We could solve this by :
>>
>> 1) Checking hash value : if not one expected ->    Going back to hea=
d
>> of chain N, (potentially re-printing already handled entries)
>>    So it is not a *perfect* solution.
>>
>> 2) Use a locking to forbid writers (as done in UDP/TCP), but it is
>> expensive and
>> wont solve other problem :
>>
>> We wont avoid emitting same entry several time anyway (this is a fla=
w
>> of current seq_file handling, since we 'count' entries to be skiped,
>> and this is
>> wrong if some entries were deleted or inserted meanwhile)
>>
>> We have same problem on /proc/net/udp & /proc/net/tcp, I am not sure
>> we should care...
>=20
> I think double entries are not a problem, as you say, there
> are already other cases where this can happen. But I think we
> should try our best that every entry present at the start and
> still present at the end of a dump is also contained in the
> dump, otherwise the guantees seem to weak to still be useful.
> Your first proposal would do exactly that, right?

If your concern is to not forget entries, and we are allowed to print s=
ome entries several times,
then we can just check the final "nulls" value, and if we find a differ=
ent value than expected for
chain N, go back to begining of chain N.

No need to check hash value (this could help not print several time sam=
e entry, we dont care that much)

+       while (is_a_nulls(head)) {
+               if (likely(get_nulls_value(head) =3D=3D st->bucket)) {
+                       if (++st->bucket >=3D nf_conntrack_htable_size)
+                               return NULL;
+               }

Thank you

[PATCH] conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()

Use "hlist_nulls" infrastructure we added in 2.6.29 for RCUification of=
 UDP & TCP.

This permits an easy conversion from call_rcu() based hash lists to a
SLAB_DESTROY_BY_RCU one.

Avoiding call_rcu() delay at nf_conn freeing time has numerous gains.

=46irst, it doesnt fill RCU queues (up to 10000 elements per cpu).
This reduces OOM possibility, if queued elements are not taken into acc=
ount
This reduces latency problems when RCU queue size hits hilimit and trig=
gers
emergency mode.

- It allows fast reuse of just freed elements, permitting better use of
CPU cache.

- We delete rcu_head from "struct nf_conn", shrinking size of this stru=
cture
by 8 or 16 bytes.

This patch only takes care of "struct nf_conn".
call_rcu() is still used for less critical conntrack parts, that may
be converted later if necessary.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/netfilter/nf_conntrack.h                  |   14 -
 include/net/netfilter/nf_conntrack_tuple.h            |    6
 include/net/netns/conntrack.h                         |    5
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |   63 ++---
 net/ipv4/netfilter/nf_nat_core.c                      |    2
 net/netfilter/nf_conntrack_core.c                     |  123 +++++----=
-
 net/netfilter/nf_conntrack_expect.c                   |    2
 net/netfilter/nf_conntrack_helper.c                   |    7
 net/netfilter/nf_conntrack_netlink.c                  |   20 -
 net/netfilter/nf_conntrack_standalone.c               |   57 ++--
 net/netfilter/xt_connlimit.c                          |    6
 11 files changed, 174 insertions(+), 131 deletions(-)

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
index 6ba5c55..8668a3d 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -25,40 +25,42 @@ struct ct_iter_state {
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
-		if (++st->bucket >=3D nf_conntrack_htable_size)
-			return NULL;
+	while (is_a_nulls(head)) {
+		if (likely(get_nulls_value(head) =3D=3D st->bucket)) {
+			if (++st->bucket >=3D nf_conntrack_htable_size)
+				return NULL;
+		}
 		head =3D rcu_dereference(net->ct.hash[st->bucket].first);
 	}
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
@@ -87,69 +89,76 @@ static void ct_seq_stop(struct seq_file *s, void *v=
)
=20
 static int ct_seq_show(struct seq_file *s, void *v)
 {
-	const struct nf_conntrack_tuple_hash *hash =3D v;
-	const struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(hash);
+	struct nf_conntrack_tuple_hash *hash =3D v;
+	struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(hash);
 	const struct nf_conntrack_l3proto *l3proto;
 	const struct nf_conntrack_l4proto *l4proto;
+	int ret =3D 0;
=20
 	NF_CT_ASSERT(ct);
+	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		return 0;
+
=20
 	/* we only want to print DIR_ORIGINAL */
 	if (NF_CT_DIRECTION(hash))
-		return 0;
+		goto release;
 	if (nf_ct_l3num(ct) !=3D AF_INET)
-		return 0;
+		goto release;
=20
 	l3proto =3D __nf_ct_l3proto_find(nf_ct_l3num(ct));
 	NF_CT_ASSERT(l3proto);
 	l4proto =3D __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct))=
;
 	NF_CT_ASSERT(l4proto);
=20
+	ret =3D -ENOSPC;
 	if (seq_printf(s, "%-8s %u %ld ",
 		      l4proto->name, nf_ct_protonum(ct),
 		      timer_pending(&ct->timeout)
 		      ? (long)(ct->timeout.expires - jiffies)/HZ : 0) !=3D 0)
-		return -ENOSPC;
+		goto release;
=20
 	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
-		return -ENOSPC;
+		goto release;
=20
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
=20
 	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
-		return -ENOSPC;
+		goto release;
=20
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
 		if (seq_printf(s, "[UNREPLIED] "))
-			return -ENOSPC;
+			goto release;
=20
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
=20
 	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
-		return -ENOSPC;
+		goto release;
=20
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
 		if (seq_printf(s, "[ASSURED] "))
-			return -ENOSPC;
+			goto release;
=20
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	if (seq_printf(s, "mark=3D%u ", ct->mark))
-		return -ENOSPC;
+		goto release;
 #endif
=20
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	if (seq_printf(s, "secmark=3D%u ", ct->secmark))
-		return -ENOSPC;
+		goto release;
 #endif
=20
 	if (seq_printf(s, "use=3D%u\n", atomic_read(&ct->ct_general.use)))
-		return -ENOSPC;
-
-	return 0;
+		goto release;
+	ret =3D 0;
+release:
+	nf_ct_put(ct);
+	return ret;
 }
=20
 static const struct seq_operations ct_seq_ops =3D {
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
index 54e983f..c55bbdc 100644
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
-			hlist_add_head_rcu(&h->hnode, &hash[bucket]);
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
@@ -1202,7 +1219,7 @@ static int nf_conntrack_init_net(struct net *net)
 	int ret;
=20
 	atomic_set(&net->ct.count, 0);
-	INIT_HLIST_HEAD(&net->ct.unconfirmed);
+	INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, 0);
 	net->ct.stat =3D alloc_percpu(struct ip_conntrack_stat);
 	if (!net->ct.stat) {
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
index 1b75c9e..349bbef 100644
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
@@ -544,27 +545,27 @@ ctnetlink_dump_table(struct sk_buff *skb, struct =
netlink_callback *cb)
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
+			if (!atomic_inc_not_zero(&ct->ct_general.use))
+				continue;
 			/* Dump entries of a given L3 protocol number.
 			 * If it is not specified, ie. l3proto =3D=3D 0,
 			 * then dump everything. */
 			if (l3proto && nf_ct_l3num(ct) !=3D l3proto)
-				continue;
+				goto releasect;
 			if (cb->args[1]) {
 				if (ct !=3D last)
-					continue;
+					goto releasect;
 				cb->args[1] =3D 0;
 			}
 			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
 						cb->nlh->nlmsg_seq,
 						IPCTNL_MSG_CT_NEW,
 						1, ct) < 0) {
-				if (!atomic_inc_not_zero(&ct->ct_general.use))
-					continue;
 				cb->args[1] =3D (unsigned long)ct;
 				goto out;
 			}
@@ -577,6 +578,8 @@ restart:
 				if (acct)
 					memset(acct, 0, sizeof(struct nf_conn_counter[IP_CT_DIR_MAX]));
 			}
+releasect:
+		nf_ct_put(ct);
 		}
 		if (cb->args[1]) {
 			cb->args[1] =3D 0;
@@ -1242,13 +1245,12 @@ ctnetlink_create_conntrack(struct nlattr *cda[]=
,
 		if (err < 0)
 			goto err2;
=20
-		master_h =3D __nf_conntrack_find(&init_net, &master);
+		master_h =3D nf_conntrack_find_get(&init_net, &master);
 		if (master_h =3D=3D NULL) {
 			err =3D -ENOENT;
 			goto err2;
 		}
 		master_ct =3D nf_ct_tuplehash_to_ctrack(master_h);
-		nf_conntrack_get(&master_ct->ct_general);
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
 		ct->master =3D master_ct;
 	}
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf=
_conntrack_standalone.c
index 4da54b0..1935153 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -44,40 +44,42 @@ struct ct_iter_state {
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
-		if (++st->bucket >=3D nf_conntrack_htable_size)
-			return NULL;
+	while (is_a_nulls(head)) {
+		if (likely(get_nulls_value(head) =3D=3D st->bucket)) {
+			if (++st->bucket >=3D nf_conntrack_htable_size)
+				return NULL;
+		}
 		head =3D rcu_dereference(net->ct.hash[st->bucket].first);
 	}
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
@@ -107,67 +109,74 @@ static void ct_seq_stop(struct seq_file *s, void =
*v)
 /* return 0 on success, 1 in case of error */
 static int ct_seq_show(struct seq_file *s, void *v)
 {
-	const struct nf_conntrack_tuple_hash *hash =3D v;
-	const struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(hash);
+	struct nf_conntrack_tuple_hash *hash =3D v;
+	struct nf_conn *ct =3D nf_ct_tuplehash_to_ctrack(hash);
 	const struct nf_conntrack_l3proto *l3proto;
 	const struct nf_conntrack_l4proto *l4proto;
+	int ret =3D 0;
=20
 	NF_CT_ASSERT(ct);
+	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		return 0;
=20
 	/* we only want to print DIR_ORIGINAL */
 	if (NF_CT_DIRECTION(hash))
-		return 0;
+		goto release;
=20
 	l3proto =3D __nf_ct_l3proto_find(nf_ct_l3num(ct));
 	NF_CT_ASSERT(l3proto);
 	l4proto =3D __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct))=
;
 	NF_CT_ASSERT(l4proto);
=20
+	ret =3D -ENOSPC;
 	if (seq_printf(s, "%-8s %u %-8s %u %ld ",
 		       l3proto->name, nf_ct_l3num(ct),
 		       l4proto->name, nf_ct_protonum(ct),
 		       timer_pending(&ct->timeout)
 		       ? (long)(ct->timeout.expires - jiffies)/HZ : 0) !=3D 0)
-		return -ENOSPC;
+		goto release;
=20
 	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
-		return -ENOSPC;
+		goto release;
=20
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
=20
 	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
-		return -ENOSPC;
+		goto release;
=20
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
 		if (seq_printf(s, "[UNREPLIED] "))
-			return -ENOSPC;
+			goto release;
=20
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
=20
 	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
-		return -ENOSPC;
+		goto release;
=20
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
 		if (seq_printf(s, "[ASSURED] "))
-			return -ENOSPC;
+			goto release;
=20
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (seq_printf(s, "mark=3D%u ", ct->mark))
-		return -ENOSPC;
+		goto release;
 #endif
=20
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	if (seq_printf(s, "secmark=3D%u ", ct->secmark))
-		return -ENOSPC;
+		goto release;
 #endif
=20
 	if (seq_printf(s, "use=3D%u\n", atomic_read(&ct->ct_general.use)))
-		return -ENOSPC;
+		goto release;
=20
+	ret =3D 0;
+release:
+	nf_ct_put(ct);
 	return 0;
 }
=20
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.=
c
index 7f404cc..6809809 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -108,7 +108,7 @@ static int count_them(struct xt_connlimit_data *dat=
a,
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
 	struct xt_connlimit_conn *tmp;
-	const struct nf_conn *found_ct;
+	struct nf_conn *found_ct;
 	struct list_head *hash;
 	bool addit =3D true;
 	int matches =3D 0;
@@ -123,7 +123,7 @@ static int count_them(struct xt_connlimit_data *dat=
a,
=20
 	/* check the saved connections */
 	list_for_each_entry_safe(conn, tmp, hash, list) {
-		found    =3D __nf_conntrack_find(&init_net, &conn->tuple);
+		found    =3D nf_conntrack_find_get(&init_net, &conn->tuple);
 		found_ct =3D NULL;
=20
 		if (found !=3D NULL)
@@ -151,6 +151,7 @@ static int count_them(struct xt_connlimit_data *dat=
a,
 			 * we do not care about connections which are
 			 * closed already -> ditch it
 			 */
+			nf_ct_put(found_ct);
 			list_del(&conn->list);
 			kfree(conn);
 			continue;
@@ -160,6 +161,7 @@ static int count_them(struct xt_connlimit_data *dat=
a,
 		    match->family))
 			/* same source network -> be counted! */
 			++matches;
+		nf_ct_put(found_ct);
 	}
=20
 	rcu_read_unlock();


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
