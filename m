From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 15:08:08 +0300
Message-ID: <48D8DC28.1020001@iki.fi>
References: <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:63049 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbYIWMIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 08:08:16 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1590130ugf.37
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 05:08:14 -0700 (PDT)
In-Reply-To: <20080923112416.GA28946@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 12:39:51PM +0300, Timo Ter=E4s wrote:
>> This would make it possibly to reclaim the deleted entries right
>> away.
>>
>> Does this sound better?
>=20
> Yep this sounds pretty good to me.
>=20
> Thanks,

So the patch would look something like this. Compile tested.
Will test later when it becomes possible to reboot my box.

Cheers,
 Timo

ipsec: Fix up xfrm_state_walk.state on node deletion

Now that we track xfrm_state_walks, it makes more sense to
fix up the state pointer on deletion of the node if needed.

This allows accurately to delete all entries immediately,
instead of possibly waiting for userland.

Also fixed locking of xfrm_state_walks list handling.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 include/linux/netlink.h |    2 +-
 include/net/xfrm.h      |    3 +-
 net/xfrm/xfrm_state.c   |   77 +++++++++++++++++----------------------=
-------
 3 files changed, 31 insertions(+), 51 deletions(-)

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
index 48630b2..7f787c7 100644
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
@@ -1247,7 +1247,6 @@ struct xfrm6_tunnel {
=20
 struct xfrm_state_walk {
 	struct list_head list;
-	unsigned long genid;
 	struct xfrm_state *state;
 	int count;
 	u8 proto;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 053970e..636f7ee 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -59,11 +59,6 @@ static unsigned int xfrm_state_hashmax __read_mostly=
 =3D 1 * 1024 * 1024;
 static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
=20
-/* Counter indicating ongoing walk, protected by xfrm_state_lock. */
-static unsigned long xfrm_state_walk_ongoing;
-/* Counter indicating walk completion, protected by xfrm_cfg_mutex. */
-static unsigned long xfrm_state_walk_completed;
-
 /* List of outstanding state walks used to set the completed counter. =
 */
 static LIST_HEAD(xfrm_state_walks);
=20
@@ -199,8 +194,7 @@ static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
 static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
=20
 static struct work_struct xfrm_state_gc_work;
-static LIST_HEAD(xfrm_state_gc_leftovers);
-static LIST_HEAD(xfrm_state_gc_list);
+static HLIST_HEAD(xfrm_state_gc_list);
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
=20
 int __xfrm_state_delete(struct xfrm_state *x);
@@ -412,23 +406,16 @@ static void xfrm_state_gc_destroy(struct xfrm_sta=
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
@@ -556,7 +543,7 @@ void __xfrm_state_destroy(struct xfrm_state *x)
 	WARN_ON(x->km.state !=3D XFRM_STATE_DEAD);
=20
 	spin_lock_bh(&xfrm_state_gc_lock);
-	list_add_tail(&x->gclist, &xfrm_state_gc_list);
+	hlist_add_head(&x->gclist, &xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 	schedule_work(&xfrm_state_gc_work);
 }
@@ -564,13 +551,22 @@ EXPORT_SYMBOL(__xfrm_state_destroy);
=20
 int __xfrm_state_delete(struct xfrm_state *x)
 {
+	struct xfrm_state_walk *walk;
+	struct xfrm_state *next;
 	int err =3D -ESRCH;
=20
 	if (x->km.state !=3D XFRM_STATE_DEAD) {
 		x->km.state =3D XFRM_STATE_DEAD;
 		spin_lock(&xfrm_state_lock);
-		x->lastused =3D xfrm_state_walk_ongoing;
-		list_del_rcu(&x->all);
+		if (list_is_last(&x->all, &xfrm_state_walks))
+			next =3D NULL;
+		else
+			next =3D container_of(x->all.next, struct xfrm_state, all);
+		list_for_each_entry(walk, &xfrm_state_walks, list) {
+			if (walk->state =3D=3D x)
+				walk->state =3D next;
+		}
+		list_del(&x->all);
 		hlist_del(&x->bydst);
 		hlist_del(&x->bysrc);
 		if (x->id.spi)
@@ -1566,15 +1562,16 @@ int xfrm_state_walk(struct xfrm_state_walk *wal=
k,
 		    int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
-	struct xfrm_state *old, *x, *last =3D NULL;
+	struct xfrm_state *x, *last =3D NULL;
 	int err =3D 0;
=20
 	if (walk->state =3D=3D NULL && walk->count !=3D 0)
 		return 0;
=20
-	old =3D x =3D walk->state;
-	walk->state =3D NULL;
 	spin_lock_bh(&xfrm_state_lock);
+	x =3D walk->state;
+	walk->state =3D NULL;
+
 	if (x =3D=3D NULL)
 		x =3D list_first_entry(&xfrm_state_all, struct xfrm_state, all);
 	list_for_each_entry_from(x, &xfrm_state_all, all) {
@@ -1585,7 +1582,6 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
 		if (last) {
 			err =3D func(last, walk->count, data);
 			if (err) {
-				xfrm_state_hold(last);
 				walk->state =3D last;
 				goto out;
 			}
@@ -1601,8 +1597,7 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
 		err =3D func(last, 0, data);
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	if (old !=3D NULL)
-		xfrm_state_put(old);
+
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_walk);
@@ -1612,33 +1607,19 @@ void xfrm_state_walk_init(struct xfrm_state_wal=
k *walk, u8 proto)
 	walk->proto =3D proto;
 	walk->state =3D NULL;
 	walk->count =3D 0;
+
+	spin_lock_bh(&xfrm_state_lock);
 	list_add_tail(&walk->list, &xfrm_state_walks);
-	walk->genid =3D ++xfrm_state_walk_ongoing;
+	spin_unlock_bh(&xfrm_state_lock);
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
+	spin_lock_bh(&xfrm_state_lock);
 	list_del(&walk->list);
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
+	spin_unlock_bh(&xfrm_state_lock);
+	walk->state =3D NULL;
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
=20
--=20
1.5.4.3
