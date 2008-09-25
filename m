From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Thu, 25 Sep 2008 15:57:15 +0800
Message-ID: <20080925075715.GA18101@gondor.apana.org.au>
References: <20080924055550.GA6506@gondor.apana.org.au> <48D9D86E.7020205@iki.fi> <20080924061349.GA6679@gondor.apana.org.au> <48D9DC1A.10903@iki.fi> <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au> <48DB29A9.2090204@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43096 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751306AbYIYH5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 03:57:30 -0400
Content-Disposition: inline
In-Reply-To: <48DB29A9.2090204@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 09:03:21AM +0300, Timo Ter=E4s wrote:
>
> I forgot to test pf_key support. And remembered why the "last"
> thingy was in the walking routines. In pf_key dumps, the dump
> is terminated when an entry with seq zero is received; that's
> why the final entry received special treatment. And now that
> breaks. The first entry is zero so pf_key dumps only one entry.
>=20
> Not sure if we should fix this in pf_key or in the walking routines.

This is part of the user-space ABI (and an RFC) so wecan't change
it.  I've put the last stuff back and fixed up the error handling
on the very last entry.

ipsec: Put xfrm_state dumpers on the dump list

Based on Herbert Xu's patch and idea. Timo improved the original
patch to apply cleanly and modified iteration code to be more
readable by using a common struct for entries in all list.

As it is we go to extraordinary lengths to ensure that states
don't go away while dumpers go to sleep.  It's much easier if
we just put the dumpers themselves on the list since they can't
go away while they're going.

I've also changed the order of addition on new states to prevent
a never-ending dump.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Timo Teras <timo.teras@iki.fi>

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
index 48630b2..becaa1e 100644
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
@@ -1245,14 +1250,6 @@ struct xfrm6_tunnel {
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
 struct xfrm_policy_walk {
 	struct xfrm_policy *policy;
 	int count;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 053970e..5b98f6f 100644
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
@@ -1566,79 +1549,72 @@ int xfrm_state_walk(struct xfrm_state_walk *wal=
k,
 		    int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
-	struct xfrm_state *old, *x, *last =3D NULL;
+	struct xfrm_state *state, *last =3D NULL;
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
+
 		if (last) {
-			err =3D func(last, walk->count, data);
-			if (err) {
-				xfrm_state_hold(last);
-				walk->state =3D last;
-				goto out;
-			}
+			err =3D func(last, walk->seq, data);
+			if (err)
+				goto save_dump;
 		}
-		last =3D x;
-		walk->count++;
+
+		last =3D state;
+		walk->seq++;
 	}
-	if (walk->count =3D=3D 0) {
+	if (walk->seq =3D=3D 0) {
 		err =3D -ENOENT;
 		goto out;
 	}
-	if (last)
-		err =3D func(last, 0, data);
+
+	list_del_init(&walk->all);
+	if (!last)
+		goto out;
+
+	err =3D func(last, 0, data);
+	if (err) {
+save_dump:
+		list_move_tail(&walk->all, &last->km.all);
+	}
+
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
=20
-	xfrm_state_walk_completed =3D walk->genid;
-
-	if (!list_empty(&xfrm_state_gc_leftovers))
-		schedule_work(&xfrm_state_gc_work);
+	spin_lock_bh(&xfrm_state_lock);
+	list_del(&walk->all);
+	spin_lock_bh(&xfrm_state_lock);
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
=20
Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
