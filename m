From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 21:43:57 +0100
Message-ID: <1322599437.2596.10.camel@edumazet-laptop>
References: <alpine.WNT.2.00.1111291027320.1036@TSI>
	 <1322589661.2596.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322589661.2596.2.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 29 novembre 2011 =C3=A0 19:01 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le mardi 29 novembre 2011 =C3=A0 10:44 -0700, Marc Aurele La France a=
 =C3=A9crit :
> > Hi.
> >=20
> > Commit (1) seems to imply that all dst_get_neighbour() references n=
ow need=20
> > to be wrapped with rcu_read_lock()/rcu_read_unlock() sequences.  Se=
e (2)=20
> > for one such proposed change.
> >=20
> > In the case I have here (ipoib), this commit results in ...
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> > [ INFO: suspicious rcu_dereference_check() usage. ]
> > ---------------------------------------------------
> > include/net/dst.h:91 invoked rcu_dereference_check() without protec=
tion!
> >=20
> > other info that might help us debug this:
> >=20
> >=20
> > rcu_scheduler_active =3D 1, debug_locks =3D 1
> > 4 locks held by kworker/3:1/630:
> >   #0:  (ib_cm){.+.+.+}, at: [<ffffffff81055735>]=20
> > process_one_work+0x1ab/0x4f9
> >   #1:  ((&(&work->work)->work)){+.+.+.}, at: [<ffffffff81055735>]=20
> > process_one_work+0x1ab/0x4f9
> >   #2:  (rcu_read_lock_bh){.+....}, at: [<ffffffff81388216>]=20
> > dev_queue_xmit+0x0/0x5ae
> >   #3:  (_xmit_INFINIBAND){+.-...}, at: [<ffffffff8139eecc>]=20
> > sch_direct_xmit+0x4d/0x22b
> >=20
> > stack backtrace:
> > Pid: 630, comm: kworker/3:1 Not tainted 3.1.3-smp #1
> > Call Trace:
> >   [<ffffffff8106c385>] lockdep_rcu_dereference+0x9b/0xa4
> >   [<ffffffff81351cda>] ipoib_start_xmit+0xf4/0x36f
> >   [<ffffffff81384215>] dev_hard_start_xmit+0x2a7/0x54f
> >   [<ffffffff8139eeef>] sch_direct_xmit+0x70/0x22b
> >   [<ffffffff8138851f>] dev_queue_xmit+0x309/0x5ae
> >   [<ffffffff81388216>] ? napi_gro_receive+0xb3/0xb3
> >   [<ffffffff813582d3>] ipoib_cm_rep_handler+0x208/0x248
> >   [<ffffffff81433e16>] ? _raw_spin_unlock_irqrestore+0x3d/0x5b
> >   [<ffffffff8135a912>] ipoib_cm_tx_handler+0x95/0x27f
> >   [<ffffffff8106d183>] ? __trace_hardirqs_on_caller+0x41/0x65
> >   [<ffffffff81327b29>] cm_process_work+0x26/0xbc
> >   [<ffffffff81328d74>] cm_rep_handler+0x274/0x2ae
> >   [<ffffffff81329582>] cm_work_handler+0x41/0x91
> >   [<ffffffff8105582c>] process_one_work+0x2a2/0x4f9
> >   [<ffffffff81055735>] ? process_one_work+0x1ab/0x4f9
> >   [<ffffffff810580c6>] ? worker_thread+0x4a/0x1ca
> >   [<ffffffff81329541>] ? cm_req_handler+0x355/0x355
> >   [<ffffffff81058175>] worker_thread+0xf9/0x1ca
> >   [<ffffffff8105807c>] ? gcwq_mayday_timeout+0x77/0x77
> >   [<ffffffff8105bfa3>] kthread+0x86/0x8e
> >   [<ffffffff81436b34>] kernel_thread_helper+0x4/0x10
> >   [<ffffffff8143425d>] ? retint_restore_args+0xe/0xe
> >   [<ffffffff8105bf1d>] ? kthread_stop+0x1cd/0x1cd
> >   [<ffffffff81436b30>] ? gs_change+0xb/0xb
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> > [ INFO: suspicious rcu_dereference_check() usage. ]
> > ---------------------------------------------------
> > include/net/dst.h:91 invoked rcu_dereference_check() without protec=
tion!
> >=20
> > other info that might help us debug this:
> >=20
> >=20
> > rcu_scheduler_active =3D 1, debug_locks =3D 1
> > 2 locks held by kworker/u:2/748:
> >   #0:  ((name)){.+.+.+}, at: [<ffffffff81055735>]=20
> > process_one_work+0x1ab/0x4f9
> >   #1:  ((&port_priv->work)){+.+.+.}, at: [<ffffffff81055735>]=20
> > process_one_work+0x1ab/0x4f9
> >=20
> > stack backtrace:
> > Pid: 748, comm: kworker/u:2 Not tainted 3.1.3-smp #1
> > Call Trace:
> >   [<ffffffff8106c385>] lockdep_rcu_dereference+0x9b/0xa4
> >   [<ffffffff81354e68>] ipoib_mcast_join_finish+0x362/0x48a
> >   [<ffffffff81355481>] ipoib_mcast_sendonly_join_complete+0x3b/0x17=
4
> >   [<ffffffff813246b3>] mcast_work_handler+0xba/0x182
> >   [<ffffffff813248aa>] join_handler+0xe6/0xee
> >   [<ffffffff81322af1>] ib_sa_mcmember_rec_callback+0x51/0x5c
> >   [<ffffffff8132289c>] recv_handler+0x44/0x50
> >   [<ffffffff8131efca>] ib_mad_complete_recv+0xc3/0x125
> >   [<ffffffff8131debe>] ? find_mad_agent+0x13a/0x149
> >   [<ffffffff8131f30a>] ib_mad_recv_done_handler+0x2de/0x326
> >   [<ffffffff8131f3b0>] ib_mad_completion_handler+0x5e/0x91
> >   [<ffffffff8105582c>] process_one_work+0x2a2/0x4f9
> >   [<ffffffff81055735>] ? process_one_work+0x1ab/0x4f9
> >   [<ffffffff810580c6>] ? worker_thread+0x4a/0x1ca
> >   [<ffffffff8131f352>] ? ib_mad_recv_done_handler+0x326/0x326
> >   [<ffffffff81058175>] worker_thread+0xf9/0x1ca
> >   [<ffffffff8105807c>] ? gcwq_mayday_timeout+0x77/0x77
> >   [<ffffffff8105bfa3>] kthread+0x86/0x8e
> >   [<ffffffff81436b34>] kernel_thread_helper+0x4/0x10
> >   [<ffffffff8143425d>] ? retint_restore_args+0xe/0xe
> >   [<ffffffff8105bf1d>] ? kthread_stop+0x1cd/0x1cd
> >   [<ffffffff81436b30>] ? gs_change+0xb/0xb
> >=20
> > Comments/flames?
> >=20
> > Thanks.
> >=20
> > Marc.
> >=20
> > PS:  Please reply-to-all as I am not subscribed to netdev.
> >=20
> > (1) http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;=
a=3Dcommitdiff;h=3Df2c31e32b378a6653f8de606149d963baf11d7d3
> > (2) http://www.spinics.net/lists/netdev/msg179639.html
> >=20
> > +----------------------------------+-------------------------------=
---+
> > |  Marc Aurele La France           |  work:   1-780-492-9310       =
   |
> > |  Academic Information and        |  fax:    1-780-492-1729       =
   |
> > |    Communications Technologies   |  email:  tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org      =
   |
> > |  352 General Services Building   +-------------------------------=
---+
> > |  University of Alberta           |                               =
   |
> > |  Edmonton, Alberta               |    Standard disclaimers apply =
   |
> > |  T6G 2H1                         |                               =
   |
> > |  CANADA                          |                               =
   |
> > +----------------------------------+-------------------------------=
---+
>=20
> Thanks for the report Marc, I'll take a look asap.
>=20
>=20

Hi Marc

Here is the patch I cooked based on your report, thanks a lot !

Eric

[PATCH] net: infiniband/ulp/ipoib: fix lockdep splats

commit f2c31e32b37 (net: fix NULL dereferences in check_peer_redir())
forgot to take care of infiniband uses of dst neighbours.

Many thanks to Marc Aurele who provided a nice bug report.

Reported-by: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   17 ++++++++-------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    6 +++--
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infini=
band/ulp/ipoib/ipoib_main.c
index 7567b60..c36a2ab 100644
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
@@ -793,13 +796,13 @@ static int ipoib_start_xmit(struct sk_buff *skb, =
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
 	return NETDEV_TX_OK;
 }
=20
@@ -837,7 +840,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
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
