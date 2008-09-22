From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Mon, 22 Sep 2008 19:42:56 +0800
Message-ID: <20080922114256.GA27055@gondor.apana.org.au>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36726 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751645AbYIVLnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 07:43:06 -0400
Content-Disposition: inline
In-Reply-To: <48D66677.2040309@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 06:21:27PM +0300, Timo Ter=E4s wrote:
>
> But the flaw still exists: the entries which interator->next points
> can be deleted if there is a walking that takes a long time and
> meanwhile we get walks that complete fast.

Thanks, I guess that's why I'm not paid to work on RCU :)

> So if we do list_del_rcu() on delete, could we also xfrm_state_hold()
> the entry pointed to by that list entry. And then on GC we could
> xfrm_state_put() the next entry.

Unfortunately it's not that simple since we'll be in the same
bind if the entry after the next entry gets deleted as well as
the next entry.

The only other solution is to go back to the original scheme
where we keep the list intact until GC.  However, nobody has
come up with a way of doing that that allows the SA creation
path to run locklessly with respect to the dumping path.

So I think we'll have to stick with the quasi-RCU solution for
now.  Here's a patch to fix the flaw that you discovered.

ipsec: Fix xfrm_state_walk race

As discovered by Timo Ter=E4s, the currently xfrm_state_walk scheme
is racy because if a second dump finishes before the first, we
may free xfrm states that the first dump would walk over later.

This patch fixes this by storing the dumps in a list in order
to calculate the correct completion counter which cures this
problem.

I've expanded netlink_cb in order to accomodate the extra state
related to this.  It shouldn't be a big deal since netlink_cb
is kmalloced for each dump and we're just increasing it by 4 or
8 bytes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 9ff1b54..cbba776 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -220,7 +220,7 @@ struct netlink_callback
 	int		(*dump)(struct sk_buff * skb, struct netlink_callback *cb);
 	int		(*done)(struct netlink_callback *cb);
 	int		family;
-	long		args[6];
+	long		args[7];
 };
=20
 struct netlink_notify
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4bb9499..48630b2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1246,6 +1246,8 @@ struct xfrm6_tunnel {
 };
=20
 struct xfrm_state_walk {
+	struct list_head list;
+	unsigned long genid;
 	struct xfrm_state *state;
 	int count;
 	u8 proto;
@@ -1281,13 +1283,7 @@ static inline void xfrm6_fini(void)
 extern int xfrm_proc_init(void);
 #endif
=20
-static inline void xfrm_state_walk_init(struct xfrm_state_walk *walk, =
u8 proto)
-{
-	walk->proto =3D proto;
-	walk->state =3D NULL;
-	walk->count =3D 0;
-}
-
+extern void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 prot=
o);
 extern int xfrm_state_walk(struct xfrm_state_walk *walk,
 			   int (*func)(struct xfrm_state *, int, void*), void *);
 extern void xfrm_state_walk_done(struct xfrm_state_walk *walk);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fe84a46..f7805c5 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -64,6 +64,9 @@ static unsigned long xfrm_state_walk_ongoing;
 /* Counter indicating walk completion, protected by xfrm_cfg_mutex. */
 static unsigned long xfrm_state_walk_completed;
=20
+/* List of outstanding state walks used to set the completed counter. =
 */
+static LIST_HEAD(xfrm_state_walks);
+
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int fa=
mily);
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
=20
@@ -1582,7 +1585,6 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
 			if (err) {
 				xfrm_state_hold(last);
 				walk->state =3D last;
-				xfrm_state_walk_ongoing++;
 				goto out;
 			}
 		}
@@ -1597,25 +1599,44 @@ int xfrm_state_walk(struct xfrm_state_walk *wal=
k,
 		err =3D func(last, 0, data);
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	if (old !=3D NULL) {
+	if (old !=3D NULL)
 		xfrm_state_put(old);
-		xfrm_state_walk_completed++;
-		if (!list_empty(&xfrm_state_gc_leftovers))
-			schedule_work(&xfrm_state_gc_work);
-	}
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_walk);
=20
+void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto)
+{
+	walk->proto =3D proto;
+	walk->state =3D NULL;
+	walk->count =3D 0;
+	list_add_tail(&walk->list, &xfrm_state_walks);
+	walk->genid =3D ++xfrm_state_walk_ongoing;
+}
+EXPORT_SYMBOL(xfrm_state_walk_init);
+
 void xfrm_state_walk_done(struct xfrm_state_walk *walk)
 {
+	struct list_head *prev;
+
 	if (walk->state !=3D NULL) {
 		xfrm_state_put(walk->state);
 		walk->state =3D NULL;
-		xfrm_state_walk_completed++;
-		if (!list_empty(&xfrm_state_gc_leftovers))
-			schedule_work(&xfrm_state_gc_work);
 	}
+
+	prev =3D walk->list.prev;
+	list_del(&walk->list);
+
+	if (prev !=3D &xfrm_state_walks) {
+		list_entry(prev, struct xfrm_state_walk, list)->genid =3D
+			walk->genid;
+		return;
+	}
+
+	xfrm_state_walk_completed =3D walk->genid;
+
+	if (!list_empty(&xfrm_state_gc_leftovers))
+		schedule_work(&xfrm_state_gc_work);
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
=20

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
