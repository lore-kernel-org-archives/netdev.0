From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 12:23:49 +0800
Message-ID: <20080924042349.GA5419@gondor.apana.org.au>
References: <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi> <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi> <20080923133234.GA30370@gondor.apana.org.au> <48D8F337.2050103@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39673 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750959AbYIXEX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 00:23:59 -0400
Content-Disposition: inline
In-Reply-To: <48D8F337.2050103@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 04:46:31PM +0300, Timo Ter=E4s wrote:
>
> Ah, the other layers take it at least on _walk_init paths. But
> _walk_done can be called from recv() syscalls. The af_key
> implementation does not take xfrm_cfg_mutex there. I don't think
> xfrm_user does that either as it does not pass cb_mutex to
> netlink_kernel_create. So at least the _state_walk_done path
> is unsafe as-is, I think.

OK we'd need to fix that up.

However, I've got a new idea :) Let's put the dumpers on the
list directly and then we won't have to deal any of this crap
about states going away.

Warning: compile tested only!

ipsec: Put dumpers on the dump list

As it is we go to extraordinary lengths to ensure that states
don't go away while dumpers go to sleep.  It's much easier if
we just put the dumpers themselves on the list since they can't
go away while they're going.

I've also changed the order of addition on new states to prevent
a never-ending dump.

=46inally the obsolete last optimisation is now gone.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

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
index 48630b2..17f9494 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -120,9 +120,8 @@ extern struct mutex xfrm_cfg_mutex;
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
@@ -138,6 +137,8 @@ struct xfrm_state
=20
 	/* Key manger bits */
 	struct {
+		/* These two fields correspond to xfrm_state_walk. */
+		struct list_head all;
 		u8		state;
 		u8		dying;
 		u32		seq;
@@ -1246,11 +1247,11 @@ struct xfrm6_tunnel {
 };
=20
 struct xfrm_state_walk {
-	struct list_head list;
-	unsigned long genid;
-	struct xfrm_state *state;
-	int count;
+	/* These two fields correspond to xfrm_state. */
+	struct list_head all;
+	u8 state;
 	u8 proto;
+	int count;
 };
=20
 struct xfrm_policy_walk {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f7805c5..ff3bb24 100644
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
-		list_del(&x->all);
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
@@ -939,7 +922,7 @@ static void __xfrm_state_insert(struct xfrm_state *=
x)
=20
 	x->genid =3D ++xfrm_state_genid;
=20
-	list_add_tail(&x->all, &xfrm_state_all);
+	list_add(&x->km.all, &xfrm_state_all);
=20
 	h =3D xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
 			  x->props.reqid, x->props.family);
@@ -1564,79 +1547,54 @@ int xfrm_state_walk(struct xfrm_state_walk *wal=
k,
 		    int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
-	struct xfrm_state *old, *x, *last =3D NULL;
+	struct xfrm_state *x;
 	int err =3D 0;
=20
-	if (walk->state =3D=3D NULL && walk->count !=3D 0)
-		return 0;
-
-	old =3D x =3D walk->state;
-	walk->state =3D NULL;
 	spin_lock_bh(&xfrm_state_lock);
-	if (x =3D=3D NULL)
-		x =3D list_first_entry(&xfrm_state_all, struct xfrm_state, all);
-	list_for_each_entry_from(x, &xfrm_state_all, all) {
+	if (list_empty(&walk->all))
+		x =3D list_first_entry(&xfrm_state_all, struct xfrm_state, km.all);
+	else
+		x =3D list_entry(&walk->all, struct xfrm_state, km.all);
+	list_for_each_entry_from(x, &xfrm_state_all, km.all) {
 		if (x->km.state =3D=3D XFRM_STATE_DEAD)
 			continue;
 		if (!xfrm_id_proto_match(x->id.proto, walk->proto))
 			continue;
-		if (last) {
-			err =3D func(last, walk->count, data);
-			if (err) {
-				xfrm_state_hold(last);
-				walk->state =3D last;
-				goto out;
-			}
+		err =3D func(x, walk->count, data);
+		if (err) {
+			list_move_tail(&walk->all, &x->km.all);
+			goto out;
 		}
-		last =3D x;
 		walk->count++;
 	}
 	if (walk->count =3D=3D 0) {
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
+	walk->state =3D XFRM_STATE_DEAD;
 	walk->count =3D 0;
-	list_add_tail(&walk->list, &xfrm_state_walks);
-	walk->genid =3D ++xfrm_state_walk_ongoing;
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

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
