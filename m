From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next-2.6] ipsec: Put dumpers on the dump list
Date: Wed, 01 Oct 2008 13:58:14 +0300
Message-ID: <48E357C6.404@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:38807 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbYJAK6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 06:58:21 -0400
Received: by ug-out-1314.google.com with SMTP id k3so764185ugf.37
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 03:58:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu came up with the idea and the original patch to make
xfrm_state dump list contain also dumpers:

As it is we go to extraordinary lengths to ensure that states
don't go away while dumpers go to sleep.  It's much easier if
we just put the dumpers themselves on the list since they can't
go away while they're going.

I've also changed the order of addition on new states to prevent
a never-ending dump.

Timo Ter=E4s improved the patch to apply cleanly to latest tree,
modified iteration code to be more readable by using a common
struct for entries in the list, implemented the same idea for
xfrm_policy dumping and moved the af_key specific "last" entry
caching to af_key.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
Rebased to apply on top of "key: Free dumping state on socket
close". No other changes compared to previous send.

 include/linux/netlink.h |    2 +-
 include/net/xfrm.h      |   70 ++++++++++++------------------
 net/key/af_key.c        |   38 ++++++++++++++--
 net/xfrm/xfrm_policy.c  |  111 +++++++++++++++++++++++++--------------=
--------
 net/xfrm/xfrm_state.c   |  109 +++++++++++++++------------------------=
-------
 net/xfrm/xfrm_user.c    |    4 +-
 6 files changed, 159 insertions(+), 175 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index cbba776..9ff1b54 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -220,7 +220,7 @@ struct netlink_callback
 	int		(*dump)(struct sk_buff * skb, struct netlink_callback *cb);
 	int		(*done)(struct netlink_callback *cb);
 	int		family;
-	long		args[7];
+	long		args[6];
 };
=20
 struct netlink_notify
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 48630b2..b98d205 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -117,12 +117,21 @@ extern struct mutex xfrm_cfg_mutex;
       metrics. Plus, it will be made via sk->sk_dst_cache. Solved.
  */
=20
+struct xfrm_state_walk {
+	struct list_head	all;
+	u8			state;
+	union {
+		u8		dying;
+		u8		proto;
+	};
+	u32			seq;
+};
+
 /* Full description of state of transformer. */
 struct xfrm_state
 {
-	struct list_head	all;
 	union {
-		struct list_head	gclist;
+		struct hlist_node	gclist;
 		struct hlist_node	bydst;
 	};
 	struct hlist_node	bysrc;
@@ -136,12 +145,8 @@ struct xfrm_state
=20
 	u32			genid;
=20
-	/* Key manger bits */
-	struct {
-		u8		state;
-		u8		dying;
-		u32		seq;
-	} km;
+	/* Key manager bits */
+	struct xfrm_state_walk	km;
=20
 	/* Parameters of this state. */
 	struct {
@@ -449,10 +454,20 @@ struct xfrm_tmpl
=20
 #define XFRM_MAX_DEPTH		6
=20
+struct xfrm_policy_walk_entry {
+	struct list_head	all;
+	u8			dead;
+};
+
+struct xfrm_policy_walk {
+	struct xfrm_policy_walk_entry walk;
+	u8 type;
+	u32 seq;
+};
+
 struct xfrm_policy
 {
 	struct xfrm_policy	*next;
-	struct list_head	bytype;
 	struct hlist_node	bydst;
 	struct hlist_node	byidx;
=20
@@ -467,13 +482,12 @@ struct xfrm_policy
 	struct xfrm_lifetime_cfg lft;
 	struct xfrm_lifetime_cur curlft;
 	struct dst_entry       *bundles;
-	u16			family;
+	struct xfrm_policy_walk_entry walk;
 	u8			type;
 	u8			action;
 	u8			flags;
-	u8			dead;
 	u8			xfrm_nr;
-	/* XXX 1 byte hole, try to pack */
+	u16			family;
 	struct xfrm_sec_ctx	*security;
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
@@ -1245,20 +1259,6 @@ struct xfrm6_tunnel {
 	int priority;
 };
=20
-struct xfrm_state_walk {
-	struct list_head list;
-	unsigned long genid;
-	struct xfrm_state *state;
-	int count;
-	u8 proto;
-};
-
-struct xfrm_policy_walk {
-	struct xfrm_policy *policy;
-	int count;
-	u8 type, cur_type;
-};
-
 extern void xfrm_init(void);
 extern void xfrm4_init(void);
 extern void xfrm_state_init(void);
@@ -1410,24 +1410,10 @@ static inline int xfrm4_udp_encap_rcv(struct so=
ck *sk, struct sk_buff *skb)
=20
 struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp);
=20
-static inline void xfrm_policy_walk_init(struct xfrm_policy_walk *walk=
, u8 type)
-{
-	walk->cur_type =3D XFRM_POLICY_TYPE_MAIN;
-	walk->type =3D type;
-	walk->policy =3D NULL;
-	walk->count =3D 0;
-}
-
-static inline void xfrm_policy_walk_done(struct xfrm_policy_walk *walk=
)
-{
-	if (walk->policy !=3D NULL) {
-		xfrm_pol_put(walk->policy);
-		walk->policy =3D NULL;
-	}
-}
-
+extern void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 ty=
pe);
 extern int xfrm_policy_walk(struct xfrm_policy_walk *walk,
 	int (*func)(struct xfrm_policy *, int, int, void*), void *);
+extern void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
 struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 					  struct xfrm_selector *sel,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index b7f5a1c..7ae641d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -58,6 +58,7 @@ struct pfkey_sock {
 			struct xfrm_policy_walk	policy;
 			struct xfrm_state_walk	state;
 		} u;
+		struct sk_buff	*skb;
 	} dump;
 };
=20
@@ -76,6 +77,10 @@ static int pfkey_can_dump(struct sock *sk)
 static void pfkey_terminate_dump(struct pfkey_sock *pfk)
 {
 	if (pfk->dump.dump) {
+		if (pfk->dump.skb) {
+			kfree_skb(pfk->dump.skb);
+			pfk->dump.skb =3D NULL;
+		}
 		pfk->dump.done(pfk);
 		pfk->dump.dump =3D NULL;
 		pfk->dump.done =3D NULL;
@@ -308,12 +313,25 @@ static int pfkey_broadcast(struct sk_buff *skb, g=
fp_t allocation,
=20
 static int pfkey_do_dump(struct pfkey_sock *pfk)
 {
+	struct sadb_msg *hdr;
 	int rc;
=20
 	rc =3D pfk->dump.dump(pfk);
 	if (rc =3D=3D -ENOBUFS)
 		return 0;
=20
+	if (pfk->dump.skb) {
+		if (!pfkey_can_dump(&pfk->sk))
+			return 0;
+
+		hdr =3D (struct sadb_msg *) pfk->dump.skb->data;
+		hdr->sadb_msg_seq =3D 0;
+		hdr->sadb_msg_errno =3D rc;
+		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
+				&pfk->sk);
+		pfk->dump.skb =3D NULL;
+	}
+
 	pfkey_terminate_dump(pfk);
 	return rc;
 }
@@ -1744,9 +1762,14 @@ static int dump_sa(struct xfrm_state *x, int cou=
nt, void *ptr)
 	out_hdr->sadb_msg_satype =3D pfkey_proto2satype(x->id.proto);
 	out_hdr->sadb_msg_errno =3D 0;
 	out_hdr->sadb_msg_reserved =3D 0;
-	out_hdr->sadb_msg_seq =3D count;
+	out_hdr->sadb_msg_seq =3D count + 1;
 	out_hdr->sadb_msg_pid =3D pfk->dump.msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, &pfk->sk);
+
+	if (pfk->dump.skb)
+		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
+				&pfk->sk);
+	pfk->dump.skb =3D out_skb;
+
 	return 0;
 }
=20
@@ -2245,7 +2268,7 @@ static int pfkey_spdadd(struct sock *sk, struct s=
k_buff *skb, struct sadb_msg *h
 	return 0;
=20
 out:
-	xp->dead =3D 1;
+	xp->walk.dead =3D 1;
 	xfrm_policy_destroy(xp);
 	return err;
 }
@@ -2583,9 +2606,14 @@ static int dump_sp(struct xfrm_policy *xp, int d=
ir, int count, void *ptr)
 	out_hdr->sadb_msg_type =3D SADB_X_SPDDUMP;
 	out_hdr->sadb_msg_satype =3D SADB_SATYPE_UNSPEC;
 	out_hdr->sadb_msg_errno =3D 0;
-	out_hdr->sadb_msg_seq =3D count;
+	out_hdr->sadb_msg_seq =3D count + 1;
 	out_hdr->sadb_msg_pid =3D pfk->dump.msg_pid;
-	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, &pfk->sk);
+
+	if (pfk->dump.skb)
+		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
+				&pfk->sk);
+	pfk->dump.skb =3D out_skb;
+
 	return 0;
 }
=20
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ef9ccbc..b7ec080 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -46,7 +46,7 @@ EXPORT_SYMBOL(xfrm_cfg_mutex);
=20
 static DEFINE_RWLOCK(xfrm_policy_lock);
=20
-static struct list_head xfrm_policy_bytype[XFRM_POLICY_TYPE_MAX];
+static struct list_head xfrm_policy_all;
 unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
 EXPORT_SYMBOL(xfrm_policy_count);
=20
@@ -164,7 +164,7 @@ static void xfrm_policy_timer(unsigned long data)
=20
 	read_lock(&xp->lock);
=20
-	if (xp->dead)
+	if (xp->walk.dead)
 		goto out;
=20
 	dir =3D xfrm_policy_id2dir(xp->index);
@@ -236,7 +236,7 @@ struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp)
 	policy =3D kzalloc(sizeof(struct xfrm_policy), gfp);
=20
 	if (policy) {
-		INIT_LIST_HEAD(&policy->bytype);
+		INIT_LIST_HEAD(&policy->walk.all);
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
@@ -252,17 +252,13 @@ EXPORT_SYMBOL(xfrm_policy_alloc);
=20
 void xfrm_policy_destroy(struct xfrm_policy *policy)
 {
-	BUG_ON(!policy->dead);
+	BUG_ON(!policy->walk.dead);
=20
 	BUG_ON(policy->bundles);
=20
 	if (del_timer(&policy->timer))
 		BUG();
=20
-	write_lock_bh(&xfrm_policy_lock);
-	list_del(&policy->bytype);
-	write_unlock_bh(&xfrm_policy_lock);
-
 	security_xfrm_policy_free(policy->security);
 	kfree(policy);
 }
@@ -310,8 +306,8 @@ static void xfrm_policy_kill(struct xfrm_policy *po=
licy)
 	int dead;
=20
 	write_lock_bh(&policy->lock);
-	dead =3D policy->dead;
-	policy->dead =3D 1;
+	dead =3D policy->walk.dead;
+	policy->walk.dead =3D 1;
 	write_unlock_bh(&policy->lock);
=20
 	if (unlikely(dead)) {
@@ -609,6 +605,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy =
*policy, int excl)
 	if (delpol) {
 		hlist_del(&delpol->bydst);
 		hlist_del(&delpol->byidx);
+		list_del(&delpol->walk.all);
 		xfrm_policy_count[dir]--;
 	}
 	policy->index =3D delpol ? delpol->index : xfrm_gen_index(policy->typ=
e, dir);
@@ -617,7 +614,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy =
*policy, int excl)
 	policy->curlft.use_time =3D 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
-	list_add_tail(&policy->bytype, &xfrm_policy_bytype[policy->type]);
+	list_add(&policy->walk.all, &xfrm_policy_all);
 	write_unlock_bh(&xfrm_policy_lock);
=20
 	if (delpol)
@@ -684,6 +681,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, =
int dir,
 				}
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
+				list_del(&pol->walk.all);
 				xfrm_policy_count[dir]--;
 			}
 			ret =3D pol;
@@ -727,6 +725,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int d=
ir, u32 id, int delete,
 				}
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
+				list_del(&pol->walk.all);
 				xfrm_policy_count[dir]--;
 			}
 			ret =3D pol;
@@ -840,6 +839,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *a=
udit_info)
 					continue;
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
+				list_del(&pol->walk.all);
 				write_unlock_bh(&xfrm_policy_lock);
=20
 				xfrm_audit_policy_delete(pol, 1,
@@ -867,60 +867,68 @@ int xfrm_policy_walk(struct xfrm_policy_walk *wal=
k,
 		     int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
-	struct xfrm_policy *old, *pol, *last =3D NULL;
+	struct xfrm_policy *pol;
+	struct xfrm_policy_walk_entry *x;
 	int error =3D 0;
=20
 	if (walk->type >=3D XFRM_POLICY_TYPE_MAX &&
 	    walk->type !=3D XFRM_POLICY_TYPE_ANY)
 		return -EINVAL;
=20
-	if (walk->policy =3D=3D NULL && walk->count !=3D 0)
+	if (list_empty(&walk->walk.all) && walk->seq !=3D 0)
 		return 0;
=20
-	old =3D pol =3D walk->policy;
-	walk->policy =3D NULL;
-	read_lock_bh(&xfrm_policy_lock);
-
-	for (; walk->cur_type < XFRM_POLICY_TYPE_MAX; walk->cur_type++) {
-		if (walk->type !=3D walk->cur_type &&
-		    walk->type !=3D XFRM_POLICY_TYPE_ANY)
+	write_lock_bh(&xfrm_policy_lock);
+	if (list_empty(&walk->walk.all))
+		x =3D list_first_entry(&xfrm_policy_all, struct xfrm_policy_walk_ent=
ry, all);
+	else
+		x =3D list_entry(&walk->walk.all, struct xfrm_policy_walk_entry, all=
);
+	list_for_each_entry_from(x, &xfrm_policy_all, all) {
+		if (x->dead)
 			continue;
-
-		if (pol =3D=3D NULL) {
-			pol =3D list_first_entry(&xfrm_policy_bytype[walk->cur_type],
-					       struct xfrm_policy, bytype);
-		}
-		list_for_each_entry_from(pol, &xfrm_policy_bytype[walk->cur_type], b=
ytype) {
-			if (pol->dead)
-				continue;
-			if (last) {
-				error =3D func(last, xfrm_policy_id2dir(last->index),
-					     walk->count, data);
-				if (error) {
-					xfrm_pol_hold(last);
-					walk->policy =3D last;
-					goto out;
-				}
-			}
-			last =3D pol;
-			walk->count++;
+		pol =3D container_of(x, struct xfrm_policy, walk);
+		if (walk->type !=3D XFRM_POLICY_TYPE_ANY &&
+		    walk->type !=3D pol->type)
+			continue;
+		error =3D func(pol, xfrm_policy_id2dir(pol->index),
+			     walk->seq, data);
+		if (error) {
+			list_move_tail(&walk->walk.all, &x->all);
+			goto out;
 		}
-		pol =3D NULL;
+		walk->seq++;
 	}
-	if (walk->count =3D=3D 0) {
+	if (walk->seq =3D=3D 0) {
 		error =3D -ENOENT;
 		goto out;
 	}
-	if (last)
-		error =3D func(last, xfrm_policy_id2dir(last->index), 0, data);
+	list_del_init(&walk->walk.all);
 out:
-	read_unlock_bh(&xfrm_policy_lock);
-	if (old !=3D NULL)
-		xfrm_pol_put(old);
+	write_unlock_bh(&xfrm_policy_lock);
 	return error;
 }
 EXPORT_SYMBOL(xfrm_policy_walk);
=20
+void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type)
+{
+	INIT_LIST_HEAD(&walk->walk.all);
+	walk->walk.dead =3D 1;
+	walk->type =3D type;
+	walk->seq =3D 0;
+}
+EXPORT_SYMBOL(xfrm_policy_walk_init);
+
+void xfrm_policy_walk_done(struct xfrm_policy_walk *walk)
+{
+	if (list_empty(&walk->walk.all))
+		return;
+
+	write_lock_bh(&xfrm_policy_lock);
+	list_del(&walk->walk.all);
+	write_unlock_bh(&xfrm_policy_lock);
+}
+EXPORT_SYMBOL(xfrm_policy_walk_done);
+
 /*
  * Find policy to apply to this flow.
  *
@@ -1077,7 +1085,7 @@ static void __xfrm_policy_link(struct xfrm_policy=
 *pol, int dir)
 	struct hlist_head *chain =3D policy_hash_bysel(&pol->selector,
 						     pol->family, dir);
=20
-	list_add_tail(&pol->bytype, &xfrm_policy_bytype[pol->type]);
+	list_add(&pol->walk.all, &xfrm_policy_all);
 	hlist_add_head(&pol->bydst, chain);
 	hlist_add_head(&pol->byidx, xfrm_policy_byidx+idx_hash(pol->index));
 	xfrm_policy_count[dir]++;
@@ -1095,6 +1103,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(s=
truct xfrm_policy *pol,
=20
 	hlist_del(&pol->bydst);
 	hlist_del(&pol->byidx);
+	list_del(&pol->walk.all);
 	xfrm_policy_count[dir]--;
=20
 	return pol;
@@ -1720,7 +1729,7 @@ restart:
=20
 		for (pi =3D 0; pi < npols; pi++) {
 			read_lock_bh(&pols[pi]->lock);
-			pol_dead |=3D pols[pi]->dead;
+			pol_dead |=3D pols[pi]->walk.dead;
 			read_unlock_bh(&pols[pi]->lock);
 		}
=20
@@ -2415,9 +2424,7 @@ static void __init xfrm_policy_init(void)
 			panic("XFRM: failed to allocate bydst hash\n");
 	}
=20
-	for (dir =3D 0; dir < XFRM_POLICY_TYPE_MAX; dir++)
-		INIT_LIST_HEAD(&xfrm_policy_bytype[dir]);
-
+	INIT_LIST_HEAD(&xfrm_policy_all);
 	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }
@@ -2601,7 +2608,7 @@ static int xfrm_policy_migrate(struct xfrm_policy=
 *pol,
 	int i, j, n =3D 0;
=20
 	write_lock_bh(&pol->lock);
-	if (unlikely(pol->dead)) {
+	if (unlikely(pol->walk.dead)) {
 		/* target policy has been deleted */
 		write_unlock_bh(&pol->lock);
 		return -ENOENT;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 053970e..747fd8c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -59,14 +59,6 @@ static unsigned int xfrm_state_hashmax __read_mostly=
 =3D 1 * 1024 * 1024;
 static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
=20
-/* Counter indicating ongoing walk, protected by xfrm_state_lock. */
-static unsigned long xfrm_state_walk_ongoing;
-/* Counter indicating walk completion, protected by xfrm_cfg_mutex. */
-static unsigned long xfrm_state_walk_completed;
-
-/* List of outstanding state walks used to set the completed counter. =
 */
-static LIST_HEAD(xfrm_state_walks);
-
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int fa=
mily);
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
=20
@@ -199,8 +191,7 @@ static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
 static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
=20
 static struct work_struct xfrm_state_gc_work;
-static LIST_HEAD(xfrm_state_gc_leftovers);
-static LIST_HEAD(xfrm_state_gc_list);
+static HLIST_HEAD(xfrm_state_gc_list);
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
=20
 int __xfrm_state_delete(struct xfrm_state *x);
@@ -412,23 +403,16 @@ static void xfrm_state_gc_destroy(struct xfrm_sta=
te *x)
=20
 static void xfrm_state_gc_task(struct work_struct *data)
 {
-	struct xfrm_state *x, *tmp;
-	unsigned long completed;
+	struct xfrm_state *x;
+	struct hlist_node *entry, *tmp;
+	struct hlist_head gc_list;
=20
-	mutex_lock(&xfrm_cfg_mutex);
 	spin_lock_bh(&xfrm_state_gc_lock);
-	list_splice_tail_init(&xfrm_state_gc_list, &xfrm_state_gc_leftovers);
+	hlist_move_list(&xfrm_state_gc_list, &gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
=20
-	completed =3D xfrm_state_walk_completed;
-	mutex_unlock(&xfrm_cfg_mutex);
-
-	list_for_each_entry_safe(x, tmp, &xfrm_state_gc_leftovers, gclist) {
-		if ((long)(x->lastused - completed) > 0)
-			break;
-		list_del(&x->gclist);
+	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, gclist)
 		xfrm_state_gc_destroy(x);
-	}
=20
 	wake_up(&km_waitq);
 }
@@ -529,7 +513,7 @@ struct xfrm_state *xfrm_state_alloc(void)
 	if (x) {
 		atomic_set(&x->refcnt, 1);
 		atomic_set(&x->tunnel_users, 0);
-		INIT_LIST_HEAD(&x->all);
+		INIT_LIST_HEAD(&x->km.all);
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
@@ -556,7 +540,7 @@ void __xfrm_state_destroy(struct xfrm_state *x)
 	WARN_ON(x->km.state !=3D XFRM_STATE_DEAD);
=20
 	spin_lock_bh(&xfrm_state_gc_lock);
-	list_add_tail(&x->gclist, &xfrm_state_gc_list);
+	hlist_add_head(&x->gclist, &xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 	schedule_work(&xfrm_state_gc_work);
 }
@@ -569,8 +553,7 @@ int __xfrm_state_delete(struct xfrm_state *x)
 	if (x->km.state !=3D XFRM_STATE_DEAD) {
 		x->km.state =3D XFRM_STATE_DEAD;
 		spin_lock(&xfrm_state_lock);
-		x->lastused =3D xfrm_state_walk_ongoing;
-		list_del_rcu(&x->all);
+		list_del(&x->km.all);
 		hlist_del(&x->bydst);
 		hlist_del(&x->bysrc);
 		if (x->id.spi)
@@ -871,7 +854,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address=
_t *saddr,
=20
 		if (km_query(x, tmpl, pol) =3D=3D 0) {
 			x->km.state =3D XFRM_STATE_ACQ;
-			list_add_tail(&x->all, &xfrm_state_all);
+			list_add(&x->km.all, &xfrm_state_all);
 			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 			h =3D xfrm_src_hash(daddr, saddr, family);
 			hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -940,7 +923,7 @@ static void __xfrm_state_insert(struct xfrm_state *=
x)
=20
 	x->genid =3D ++xfrm_state_genid;
=20
-	list_add_tail(&x->all, &xfrm_state_all);
+	list_add(&x->km.all, &xfrm_state_all);
=20
 	h =3D xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
@@ -1069,7 +1052,7 @@ static struct xfrm_state *__find_acq_core(unsigne=
d short family, u8 mode, u32 re
 		xfrm_state_hold(x);
 		x->timer.expires =3D jiffies + sysctl_xfrm_acq_expires*HZ;
 		add_timer(&x->timer);
-		list_add_tail(&x->all, &xfrm_state_all);
+		list_add(&x->km.all, &xfrm_state_all);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h =3D xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -1566,79 +1549,59 @@ int xfrm_state_walk(struct xfrm_state_walk *wal=
k,
 		    int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
-	struct xfrm_state *old, *x, *last =3D NULL;
+	struct xfrm_state *state;
+	struct xfrm_state_walk *x;
 	int err =3D 0;
=20
-	if (walk->state =3D=3D NULL && walk->count !=3D 0)
+	if (walk->seq !=3D 0 && list_empty(&walk->all))
 		return 0;
=20
-	old =3D x =3D walk->state;
-	walk->state =3D NULL;
 	spin_lock_bh(&xfrm_state_lock);
-	if (x =3D=3D NULL)
-		x =3D list_first_entry(&xfrm_state_all, struct xfrm_state, all);
+	if (list_empty(&walk->all))
+		x =3D list_first_entry(&xfrm_state_all, struct xfrm_state_walk, all)=
;
+	else
+		x =3D list_entry(&walk->all, struct xfrm_state_walk, all);
 	list_for_each_entry_from(x, &xfrm_state_all, all) {
-		if (x->km.state =3D=3D XFRM_STATE_DEAD)
+		if (x->state =3D=3D XFRM_STATE_DEAD)
 			continue;
-		if (!xfrm_id_proto_match(x->id.proto, walk->proto))
+		state =3D container_of(x, struct xfrm_state, km);
+		if (!xfrm_id_proto_match(state->id.proto, walk->proto))
 			continue;
-		if (last) {
-			err =3D func(last, walk->count, data);
-			if (err) {
-				xfrm_state_hold(last);
-				walk->state =3D last;
-				goto out;
-			}
+		err =3D func(state, walk->seq, data);
+		if (err) {
+			list_move_tail(&walk->all, &x->all);
+			goto out;
 		}
-		last =3D x;
-		walk->count++;
+		walk->seq++;
 	}
-	if (walk->count =3D=3D 0) {
+	if (walk->seq =3D=3D 0) {
 		err =3D -ENOENT;
 		goto out;
 	}
-	if (last)
-		err =3D func(last, 0, data);
+	list_del_init(&walk->all);
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	if (old !=3D NULL)
-		xfrm_state_put(old);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_walk);
=20
 void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto)
 {
+	INIT_LIST_HEAD(&walk->all);
 	walk->proto =3D proto;
-	walk->state =3D NULL;
-	walk->count =3D 0;
-	list_add_tail(&walk->list, &xfrm_state_walks);
-	walk->genid =3D ++xfrm_state_walk_ongoing;
+	walk->state =3D XFRM_STATE_DEAD;
+	walk->seq =3D 0;
 }
 EXPORT_SYMBOL(xfrm_state_walk_init);
=20
 void xfrm_state_walk_done(struct xfrm_state_walk *walk)
 {
-	struct list_head *prev;
-
-	if (walk->state !=3D NULL) {
-		xfrm_state_put(walk->state);
-		walk->state =3D NULL;
-	}
-
-	prev =3D walk->list.prev;
-	list_del(&walk->list);
-
-	if (prev !=3D &xfrm_state_walks) {
-		list_entry(prev, struct xfrm_state_walk, list)->genid =3D
-			walk->genid;
+	if (list_empty(&walk->all))
 		return;
-	}
-
-	xfrm_state_walk_completed =3D walk->genid;
=20
-	if (!list_empty(&xfrm_state_gc_leftovers))
-		schedule_work(&xfrm_state_gc_work);
+	spin_lock_bh(&xfrm_state_lock);
+	list_del(&walk->all);
+	spin_lock_bh(&xfrm_state_lock);
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
=20
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 04c4150..76f75df 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1102,7 +1102,7 @@ static struct xfrm_policy *xfrm_policy_construct(=
struct xfrm_userpolicy_info *p,
 	return xp;
  error:
 	*errp =3D err;
-	xp->dead =3D 1;
+	xp->walk.dead =3D 1;
 	xfrm_policy_destroy(xp);
 	return NULL;
 }
@@ -1595,7 +1595,7 @@ static int xfrm_add_pol_expire(struct sk_buff *sk=
b, struct nlmsghdr *nlh,
 		return -ENOENT;
=20
 	read_lock(&xp->lock);
-	if (xp->dead) {
+	if (xp->walk.dead) {
 		read_unlock(&xp->lock);
 		goto out;
 	}
--=20
1.5.4.3
