From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Tue, 14 Apr 2009 14:06:05 +0200
Message-ID: <49E47C2D.1050508@cosmosbay.com>
References: <20090410191736.21efab8c@mako-desktop> <49E4744D.5090205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42189 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbZDNMGK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 08:06:10 -0400
In-Reply-To: <49E4744D.5090205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Mariusz Kozlowski wrote:
>>     Recent kernels (i.e. 2.6.30-rc1) will panic while doing rmmod of
>> nf_conntrack_irc.
>>
>> (gdb) l *(nf_conntrack_helper_unregister+0x158)
>> 0x4f8 is in nf_conntrack_helper_unregister
>> (/home/mako/linux/lkt/sources/linux-2.6/include/net/netfilter/nf_con=
ntrack.h:133).
>>
>> 128    };
>> 129  =20
>> 130    static inline struct nf_conn *
>> 131    nf_ct_tuplehash_to_ctrack(const struct nf_conntrack_tuple_has=
h
>> *hash)
>> 132    {
>> 133        return container_of(hash, struct nf_conn,
>> 134                    tuplehash[hash->tuple.dst.dir]);
>> 135    }
>> 136  =20
>> 137    static inline u_int16_t nf_ct_l3num(const struct nf_conn *ct)
>>
>>
>> I bisected it down to
>>
>>     netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of
>> call_rcu()
>=20
> Thanks for the report. Does this patch fix it?
>=20

Hi Patrick, sorry for the delay, I was in holidays.


I should have used different fields names (from "next", "first", ...) t=
o catch this
kind of errors at compile time :(

Something like :

diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
index 93150ec..b66c553 100644
--- a/include/linux/list_nulls.h
+++ b/include/linux/list_nulls.h
@@ -15,14 +15,14 @@
  */
=20
 struct hlist_nulls_head {
-	struct hlist_nulls_node *first;
+	struct hlist_nulls_node *nfirst;
 };
=20
 struct hlist_nulls_node {
-	struct hlist_nulls_node *next, **pprev;
+	struct hlist_nulls_node *nnext, **npprev;
 };
 #define INIT_HLIST_NULLS_HEAD(ptr, nulls) \
-	((ptr)->first =3D (struct hlist_nulls_node *) (1UL | (((long)nulls) <=
< 1)))
+	((ptr)->nfirst =3D (struct hlist_nulls_node *) (1UL | (((long)nulls) =
<< 1)))
=20
 #define hlist_nulls_entry(ptr, type, member) container_of(ptr,type,mem=
ber)
 /**
@@ -48,21 +48,21 @@ static inline unsigned long get_nulls_value(const s=
truct hlist_nulls_node *ptr)
=20
 static inline int hlist_nulls_unhashed(const struct hlist_nulls_node *=
h)
 {
-	return !h->pprev;
+	return !h->npprev;
 }
=20
 static inline int hlist_nulls_empty(const struct hlist_nulls_head *h)
 {
-	return is_a_nulls(h->first);
+	return is_a_nulls(h->nfirst);
 }
=20
 static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
 {
-	struct hlist_nulls_node *next =3D n->next;
-	struct hlist_nulls_node **pprev =3D n->pprev;
+	struct hlist_nulls_node *next =3D n->nnext;
+	struct hlist_nulls_node **pprev =3D n->npprev;
 	*pprev =3D next;
 	if (!is_a_nulls(next))
-		next->pprev =3D pprev;
+		next->npprev =3D pprev;
 }
=20
 /**
@@ -74,10 +74,10 @@ static inline void __hlist_nulls_del(struct hlist_n=
ulls_node *n)
  *
  */
 #define hlist_nulls_for_each_entry(tpos, pos, head, member)		       \
-	for (pos =3D (head)->first;					       \
+	for (pos =3D (head)->nfirst;					       \
 	     (!is_a_nulls(pos)) &&					       \
 		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); \
-	     pos =3D pos->next)
+	     pos =3D pos->nnext)
=20
 /**
  * hlist_nulls_for_each_entry_from - iterate over a hlist continuing f=
rom current point
@@ -89,6 +89,6 @@ static inline void __hlist_nulls_del(struct hlist_nul=
ls_node *n)
 #define hlist_nulls_for_each_entry_from(tpos, pos, member)	\
 	for (; (!is_a_nulls(pos)) && 				\
 		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1;}); \
-	     pos =3D pos->next)
+	     pos =3D pos->nnext)
=20
 #endif
diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_null=
s.h
index f9ddd03..2378c7c 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -33,7 +33,7 @@ static inline void hlist_nulls_del_init_rcu(struct hl=
ist_nulls_node *n)
 {
 	if (!hlist_nulls_unhashed(n)) {
 		__hlist_nulls_del(n);
-		n->pprev =3D NULL;
+		n->npprev =3D NULL;
 	}
 }
=20
@@ -59,7 +59,7 @@ static inline void hlist_nulls_del_init_rcu(struct hl=
ist_nulls_node *n)
 static inline void hlist_nulls_del_rcu(struct hlist_nulls_node *n)
 {
 	__hlist_nulls_del(n);
-	n->pprev =3D LIST_POISON2;
+	n->npprev =3D LIST_POISON2;
 }
=20
 /**
@@ -84,13 +84,13 @@ static inline void hlist_nulls_del_rcu(struct hlist=
_nulls_node *n)
 static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n=
,
 					struct hlist_nulls_head *h)
 {
-	struct hlist_nulls_node *first =3D h->first;
+	struct hlist_nulls_node *first =3D h->nfirst;
=20
-	n->next =3D first;
-	n->pprev =3D &h->first;
-	rcu_assign_pointer(h->first, n);
+	n->nnext =3D first;
+	n->npprev =3D &h->nfirst;
+	rcu_assign_pointer(h->nfirst, n);
 	if (!is_a_nulls(first))
-		first->pprev =3D &n->next;
+		first->npprev =3D &n->nnext;
 }
 /**
  * hlist_nulls_for_each_entry_rcu - iterate over rcu list of given typ=
e
@@ -101,10 +101,10 @@ static inline void hlist_nulls_add_head_rcu(struc=
t hlist_nulls_node *n,
  *
  */
 #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member) \
-	for (pos =3D rcu_dereference((head)->first);			 \
+	for (pos =3D rcu_dereference((head)->nfirst);			 \
 		(!is_a_nulls(pos)) && 			\
 		({ tpos =3D hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
-		pos =3D rcu_dereference(pos->next))
+		pos =3D rcu_dereference(pos->nnext))
=20
 #endif
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 4bb1ff9..5d94186 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -309,7 +309,7 @@ static inline struct sock *sk_head(const struct hli=
st_head *head)
=20
 static inline struct sock *__sk_nulls_head(const struct hlist_nulls_he=
ad *head)
 {
-	return hlist_nulls_entry(head->first, struct sock, sk_nulls_node);
+	return hlist_nulls_entry(head->nfirst, struct sock, sk_nulls_node);
 }
=20
 static inline struct sock *sk_nulls_head(const struct hlist_nulls_head=
 *head)
@@ -325,8 +325,8 @@ static inline struct sock *sk_next(const struct soc=
k *sk)
=20
 static inline struct sock *sk_nulls_next(const struct sock *sk)
 {
-	return (!is_a_nulls(sk->sk_nulls_node.next)) ?
-		hlist_nulls_entry(sk->sk_nulls_node.next,
+	return (!is_a_nulls(sk->sk_nulls_node.nnext)) ?
+		hlist_nulls_entry(sk->sk_nulls_node.nnext,
 				  struct sock, sk_nulls_node) :
 		NULL;
 }
@@ -348,7 +348,7 @@ static __inline__ void sk_node_init(struct hlist_no=
de *node)
=20
 static __inline__ void sk_nulls_node_init(struct hlist_nulls_node *nod=
e)
 {
-	node->pprev =3D NULL;
+	node->npprev =3D NULL;
 }
=20
 static __inline__ void __sk_del_node(struct sock *sk)
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/ne=
t/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 8668a3d..0bb6059 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -34,7 +34,7 @@ static struct hlist_nulls_node *ct_get_first(struct s=
eq_file *seq)
 	for (st->bucket =3D 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
-		n =3D rcu_dereference(net->ct.hash[st->bucket].first);
+		n =3D rcu_dereference(net->ct.hash[st->bucket].nfirst);
 		if (!is_a_nulls(n))
 			return n;
 	}
@@ -47,13 +47,13 @@ static struct hlist_nulls_node *ct_get_next(struct =
seq_file *seq,
 	struct net *net =3D seq_file_net(seq);
 	struct ct_iter_state *st =3D seq->private;
=20
-	head =3D rcu_dereference(head->next);
+	head =3D rcu_dereference(head->nnext);
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) =3D=3D st->bucket)) {
 			if (++st->bucket >=3D nf_conntrack_htable_size)
 				return NULL;
 		}
-		head =3D rcu_dereference(net->ct.hash[st->bucket].first);
+		head =3D rcu_dereference(net->ct.hash[st->bucket].nfirst);
 	}
 	return head;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5d427f8..1219f2d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1851,13 +1851,13 @@ EXPORT_SYMBOL(tcp_v4_destroy_sock);
 static inline struct inet_timewait_sock *tw_head(struct hlist_nulls_he=
ad *head)
 {
 	return hlist_nulls_empty(head) ? NULL :
-		list_entry(head->first, struct inet_timewait_sock, tw_node);
+		list_entry(head->nfirst, struct inet_timewait_sock, tw_node);
 }
=20
 static inline struct inet_timewait_sock *tw_next(struct inet_timewait_=
sock *tw)
 {
-	return !is_a_nulls(tw->tw_node.next) ?
-		hlist_nulls_entry(tw->tw_node.next, typeof(*tw), tw_node) : NULL;
+	return !is_a_nulls(tw->tw_node.nnext) ?
+		hlist_nulls_entry(tw->tw_node.nnext, typeof(*tw), tw_node) : NULL;
 }
=20
 static void *listening_get_next(struct seq_file *seq, void *cur)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 8020db6..56f9dc3 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1140,7 +1140,7 @@ int nf_conntrack_set_hashsize(const char *val, st=
ruct kernel_param *kp)
 	spin_lock_bh(&nf_conntrack_lock);
 	for (i =3D 0; i < nf_conntrack_htable_size; i++) {
 		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
-			h =3D hlist_nulls_entry(init_net.ct.hash[i].first,
+			h =3D hlist_nulls_entry(init_net.ct.hash[i].nfirst,
 					struct nf_conntrack_tuple_hash, hnnode);
 			hlist_nulls_del_rcu(&h->hnnode);
 			bucket =3D __hash_conntrack(&h->tuple, hashsize, rnd);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_con=
ntrack_helper.c
index 30b8e90..0fa5a42 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -176,7 +176,7 @@ static void __nf_conntrack_helper_unregister(struct=
 nf_conntrack_helper *me,
 	}
=20
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
+	hlist_nulls_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
 		unhelp(h, me);
 	for (i =3D 0; i < nf_conntrack_htable_size; i++) {
 		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf=
_conntrack_standalone.c
index 1935153..e6881db 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -53,7 +53,7 @@ static struct hlist_nulls_node *ct_get_first(struct s=
eq_file *seq)
 	for (st->bucket =3D 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
-		n =3D rcu_dereference(net->ct.hash[st->bucket].first);
+		n =3D rcu_dereference(net->ct.hash[st->bucket].nfirst);
 		if (!is_a_nulls(n))
 			return n;
 	}
@@ -66,13 +66,13 @@ static struct hlist_nulls_node *ct_get_next(struct =
seq_file *seq,
 	struct net *net =3D seq_file_net(seq);
 	struct ct_iter_state *st =3D seq->private;
=20
-	head =3D rcu_dereference(head->next);
+	head =3D rcu_dereference(head->nnext);
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) =3D=3D st->bucket)) {
 			if (++st->bucket >=3D nf_conntrack_htable_size)
 				return NULL;
 		}
-		head =3D rcu_dereference(net->ct.hash[st->bucket].first);
+		head =3D rcu_dereference(net->ct.hash[st->bucket].nfirst);
 	}
 	return head;
 }


