From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 22:31:23 +0100
Message-ID: <1322602283.2596.25.camel@edumazet-laptop>
References: <alpine.WNT.2.00.1111291027320.1036@TSI>
	 <1322589661.2596.2.camel@edumazet-laptop>
	 <1322599437.2596.10.camel@edumazet-laptop>
	 <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
	 <1322599991.2596.11.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291359290.1036@TSI>
	 <1322601444.2596.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322601444.2596.21.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 29 novembre 2011 =C3=A0 22:17 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le mardi 29 novembre 2011 =C3=A0 14:00 -0700, Marc Aurele La France a=
 =C3=A9crit :
> > On Tue, 29 Nov 2011, Eric Dumazet wrote:
> >=20
> > > Le mardi 29 novembre 2011 =C3=A0 12:47 -0800, Roland Dreier a =C3=
=A9crit :
> > >> Thanks Eric, I'll send this to Linus shortly.
> >=20
> > > Oh well, I forgot one rcu_read_unlock(), I'll send a V2...
> >=20
> > This also doesn't address the other dst_get_neighbour() instances=20
> > introduced by=20
> > http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3D=
commitdiff;h=3D69cce1d1404968f78b177a0314f5822d5afdbbfb
> >=20
>=20
> Oh well, a complete audit is needed, and I have no choice but doing i=
t.
>=20
> Thanks !
>=20

Here is the result of this audit, please double check and test it, I
only compiled this.

Thanks !

[PATCH V2] drivers/infiniband: fix lockdep splats

commit f2c31e32b37 (net: fix NULL dereferences in check_peer_redir())
forgot to take care of infiniband uses of dst neighbours.

Many thanks to Marc Aurele who provided a nice bug report and feedback.

Reported-by: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/infiniband/core/addr.c                 |    9 +++++--
 drivers/infiniband/hw/cxgb3/iwch_cm.c          |    4 +++
 drivers/infiniband/hw/cxgb4/cm.c               |    6 +++++
 drivers/infiniband/hw/nes/nes_cm.c             |    6 +++--
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   18 +++++++++------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    6 +++--
 6 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/a=
ddr.c
index 691276b..e9cf51b 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -216,7 +216,9 @@ static int addr4_resolve(struct sockaddr_in *src_in=
,
=20
 	neigh =3D neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->dst.dev);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
+		rcu_read_lock();
 		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
+		rcu_read_unlock();
 		ret =3D -ENODATA;
 		if (neigh)
 			goto release;
@@ -274,15 +276,16 @@ static int addr6_resolve(struct sockaddr_in6 *src=
_in,
 		goto put;
 	}
=20
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(dst);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
 		if (neigh)
 			neigh_event_send(neigh, NULL);
 		ret =3D -ENODATA;
-		goto put;
+	} else {
+		ret =3D rdma_copy_addr(addr, dst->dev, neigh->ha);
 	}
-
-	ret =3D rdma_copy_addr(addr, dst->dev, neigh->ha);
+	rcu_read_unlock();
 put:
 	dst_release(dst);
 	return ret;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband=
/hw/cxgb3/iwch_cm.c
index de6d077..c88b12b 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1375,8 +1375,10 @@ static int pass_accept_req(struct t3cdev *tdev, =
struct sk_buff *skb, void *ctx)
 		goto reject;
 	}
 	dst =3D &rt->dst;
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(dst);
 	l2t =3D t3_l2t_get(tdev, neigh, neigh->dev);
+	rcu_read_unlock();
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -1946,10 +1948,12 @@ int iwch_connect(struct iw_cm_id *cm_id, struct=
 iw_cm_conn_param *conn_param)
 	}
 	ep->dst =3D &rt->dst;
=20
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(ep->dst);
=20
 	/* get a l2t entry */
 	ep->l2t =3D t3_l2t_get(ep->com.tdev, neigh, neigh->dev);
+	rcu_read_unlock();
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err =3D -ENOMEM;
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/c=
xgb4/cm.c
index b36cdac..75b57be 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1594,6 +1594,7 @@ static int pass_accept_req(struct c4iw_dev *dev, =
struct sk_buff *skb)
 		goto reject;
 	}
 	dst =3D &rt->dst;
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(dst);
 	if (neigh->dev->flags & IFF_LOOPBACK) {
 		pdev =3D ip_dev_find(&init_net, peer_ip);
@@ -1620,6 +1621,7 @@ static int pass_accept_req(struct c4iw_dev *dev, =
struct sk_buff *skb)
 		rss_qid =3D dev->rdev.lldi.rxq_ids[
 			  cxgb4_port_idx(neigh->dev) * step];
 	}
+	rcu_read_unlock();
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -1820,6 +1822,7 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	}
 	ep->dst =3D &rt->dst;
=20
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(ep->dst);
=20
 	/* get a l2t entry */
@@ -1856,6 +1859,7 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 		ep->rss_qid =3D ep->com.dev->rdev.lldi.rxq_ids[
 			cxgb4_port_idx(neigh->dev) * step];
 	}
+	rcu_read_unlock();
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err =3D -ENOMEM;
@@ -2301,6 +2305,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct i=
w_cm_conn_param *conn_param)
 	}
 	ep->dst =3D &rt->dst;
=20
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(ep->dst);
=20
 	/* get a l2t entry */
@@ -2339,6 +2344,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct i=
w_cm_conn_param *conn_param)
 		ep->retry_with_mpa_v1 =3D 0;
 		ep->tried_with_mpa_v1 =3D 0;
 	}
+	rcu_read_unlock();
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err =3D -ENOMEM;
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw=
/nes/nes_cm.c
index dfce9ea..0a52d72 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1377,9 +1377,11 @@ static int nes_addr_resolve_neigh(struct nes_vni=
c *nesvnic, u32 dst_ip, int arpi
 		neigh_release(neigh);
 	}
=20
-	if ((neigh =3D=3D NULL) || (!(neigh->nud_state & NUD_VALID)))
+	if ((neigh =3D=3D NULL) || (!(neigh->nud_state & NUD_VALID))) {
+		rcu_read_lock();
 		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
-
+		rcu_read_unlock();
+	}
 	ip_rt_put(rt);
 	return rc;
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infini=
band/ulp/ipoib/ipoib_main.c
index 7567b60..ef38848 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -555,6 +555,7 @@ static int path_rec_start(struct net_device *dev,
 	return 0;
 }
=20
+/* called with rcu_read_lock */
 static void neigh_add_path(struct sk_buff *skb, struct net_device *dev=
)
 {
 	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
@@ -636,6 +637,7 @@ err_drop:
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
=20
+/* called with rcu_read_lock */
 static void ipoib_path_lookup(struct sk_buff *skb, struct net_device *=
dev)
 {
 	struct ipoib_dev_priv *priv =3D netdev_priv(skb->dev);
@@ -720,13 +722,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 	struct neighbour *n =3D NULL;
 	unsigned long flags;
=20
+	rcu_read_lock();
 	if (likely(skb_dst(skb)))
 		n =3D dst_get_neighbour(skb_dst(skb));
=20
 	if (likely(n)) {
 		if (unlikely(!*to_ipoib_neigh(n))) {
 			ipoib_path_lookup(skb, dev);
-			return NETDEV_TX_OK;
+			goto unlock;
 		}
=20
 		neigh =3D *to_ipoib_neigh(n);
@@ -749,17 +752,17 @@ static int ipoib_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 			ipoib_neigh_free(dev, neigh);
 			spin_unlock_irqrestore(&priv->lock, flags);
 			ipoib_path_lookup(skb, dev);
-			return NETDEV_TX_OK;
+			goto unlock;
 		}
=20
 		if (ipoib_cm_get(neigh)) {
 			if (ipoib_cm_up(neigh)) {
 				ipoib_cm_send(dev, skb, ipoib_cm_get(neigh));
-				return NETDEV_TX_OK;
+				goto unlock;
 			}
 		} else if (neigh->ah) {
 			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(n->ha));
-			return NETDEV_TX_OK;
+			goto unlock;
 		}
=20
 		if (skb_queue_len(&neigh->queue) < IPOIB_MAX_PATH_REC_QUEUE) {
@@ -793,13 +796,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 					   phdr->hwaddr + 4);
 				dev_kfree_skb_any(skb);
 				++dev->stats.tx_dropped;
-				return NETDEV_TX_OK;
+				goto unlock;
 			}
=20
 			unicast_arp_send(skb, dev, phdr);
 		}
 	}
-
+unlock:
+	rcu_read_unlock();
 	return NETDEV_TX_OK;
 }
=20
@@ -837,7 +841,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	dst =3D skb_dst(skb);
 	n =3D NULL;
 	if (dst)
-		n =3D dst_get_neighbour(dst);
+		n =3D dst_get_neighbour_raw(dst);
 	if ((!dst || !n) && daddr) {
 		struct ipoib_pseudoheader *phdr =3D
 			(struct ipoib_pseudoheader *) skb_push(skb, sizeof *phdr);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/i=
nfiniband/ulp/ipoib/ipoib_multicast.c
index 1b7a976..cad1894 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -266,7 +266,7 @@ static int ipoib_mcast_join_finish(struct ipoib_mca=
st *mcast,
=20
 		skb->dev =3D dev;
 		if (dst)
-			n =3D dst_get_neighbour(dst);
+			n =3D dst_get_neighbour_raw(dst);
 		if (!dst || !n) {
 			/* put pseudoheader back on for next time */
 			skb_push(skb, sizeof (struct ipoib_pseudoheader));
@@ -722,6 +722,8 @@ out:
 	if (mcast && mcast->ah) {
 		struct dst_entry *dst =3D skb_dst(skb);
 		struct neighbour *n =3D NULL;
+
+		rcu_read_lock();
 		if (dst)
 			n =3D dst_get_neighbour(dst);
 		if (n && !*to_ipoib_neigh(n)) {
@@ -734,7 +736,7 @@ out:
 				list_add_tail(&neigh->list, &mcast->neigh_list);
 			}
 		}
-
+		rcu_read_unlock();
 		spin_unlock_irqrestore(&priv->lock, flags);
 		ipoib_send(dev, skb, mcast->ah, IB_MULTICAST_QPN);
 		return;


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
