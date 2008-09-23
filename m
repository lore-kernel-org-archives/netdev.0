From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 09:25:16 +0300
Message-ID: <48D88BCC.5030806@iki.fi>
References: <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:2226 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbYIWGZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 02:25:21 -0400
Received: by nf-out-0910.google.com with SMTP id d3so650024nfc.21
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 23:25:19 -0700 (PDT)
In-Reply-To: <20080923052239.GA26233@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 08:17:14AM +0300, Timo Ter=E4s wrote:
>> The extra step there wold be a hold call. The recursive _put on a
>> _put of some entry can happen only on dump path. As otherwise the
>> ->next entry is first held in state delete, but would be immediately
>> _put on the _put as the final step of _delete().
>>
>> So basically one additional atomic_inc() and one atomic_dec() on the
>> normal _delete() path.
>=20
> Can you post a patch? If this can be done locklessly then yes
> it would probably be a good way to go.  However, I'm not sure
> whether I understand your lockless proposal yet.

Something like this. I just compile tested, so I'm not sure if it
actually works.

This basically reverts the GC changes. The interesting bits are in
xfrm_state_delete(). It will _hold() the ->next entry unless we
were at last entry. This will make sure that when an entry is
in XFRM_STATE_DEAD the all.next is valid all the way until the
entry is destroyed.

The corresponding put is in _destroy(). Added it as a final thing
to do so hopefully compiler optimizes tail recursion to iteration.
(Seemed to do that in my case.)

And finally, _walk() was right all along. It returns to dumping
and first skips all dead entries. And just before return, when
all dead entries are already skipped the originally held entry
is _put(). That _put call (or the one in _walk_done()) will result
all dead entries that were held, to be iteratively put.

- Timo

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
index 48630b2..d5cba7b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -122,7 +122,7 @@ struct xfrm_state
 {
 	struct list_head	all;
 	union {
-		struct list_head	gclist;
+		struct hlist_node	gclist;
 		struct hlist_node	bydst;
 	};
 	struct hlist_node	bysrc;
@@ -1246,8 +1246,6 @@ struct xfrm6_tunnel {
 };
=20
 struct xfrm_state_walk {
-	struct list_head list;
-	unsigned long genid;
 	struct xfrm_state *state;
 	int count;
 	u8 proto;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 053970e..f45f006 100644
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
@@ -412,23 +403,17 @@ static void xfrm_state_gc_destroy(struct xfrm_sta=
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
+	gc_list.first =3D xfrm_state_gc_list.first;
+	INIT_HLIST_HEAD(&xfrm_state_gc_list);
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
@@ -553,12 +538,19 @@ EXPORT_SYMBOL(xfrm_state_alloc);
=20
 void __xfrm_state_destroy(struct xfrm_state *x)
 {
+	struct xfrm_state *next =3D NULL;
+
 	WARN_ON(x->km.state !=3D XFRM_STATE_DEAD);
=20
+	if (x->all.next !=3D &xfrm_state_all)
+		next =3D container_of(x->all.next, struct xfrm_state, all);
 	spin_lock_bh(&xfrm_state_gc_lock);
-	list_add_tail(&x->gclist, &xfrm_state_gc_list);
+	hlist_add_head(&x->gclist, &xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 	schedule_work(&xfrm_state_gc_work);
+
+	if (next !=3D NULL)
+		xfrm_state_put(next);
 }
 EXPORT_SYMBOL(__xfrm_state_destroy);
=20
@@ -569,8 +561,10 @@ int __xfrm_state_delete(struct xfrm_state *x)
 	if (x->km.state !=3D XFRM_STATE_DEAD) {
 		x->km.state =3D XFRM_STATE_DEAD;
 		spin_lock(&xfrm_state_lock);
-		x->lastused =3D xfrm_state_walk_ongoing;
 		list_del_rcu(&x->all);
+		if (x->all.next !=3D &xfrm_state_all)
+			xfrm_state_hold(container_of(x->all.next,
+						     struct xfrm_state, all));
 		hlist_del(&x->bydst);
 		hlist_del(&x->bysrc);
 		if (x->id.spi)
@@ -1612,33 +1606,15 @@ void xfrm_state_walk_init(struct xfrm_state_wal=
k *walk, u8 proto)
 	walk->proto =3D proto;
 	walk->state =3D NULL;
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
 	if (walk->state !=3D NULL) {
 		xfrm_state_put(walk->state);
 		walk->state =3D NULL;
 	}
-
-	prev =3D walk->list.prev;
-	list_del(&walk->list);
-
-	if (prev !=3D &xfrm_state_walks) {
-		list_entry(prev, struct xfrm_state_walk, list)->genid =3D
-			walk->genid;
-		return;
-	}
-
-	xfrm_state_walk_completed =3D walk->genid;
-
-	if (!list_empty(&xfrm_state_gc_leftovers))
-		schedule_work(&xfrm_state_gc_work);
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
=20
