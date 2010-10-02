From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Sat, 02 Oct 2010 18:11:55 +0200
Message-ID: <1286035915.2582.2472.camel@edumazet-laptop>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local> <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
	 <1285941388.2641.175.camel@edumazet-laptop>
	 <20101002093255.GA2049@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56794 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004Ab0JBQMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Oct 2010 12:12:03 -0400
Received: by fxm14 with SMTP id 14so1128659fxm.19
        for <netdev@vger.kernel.org>; Sat, 02 Oct 2010 09:12:00 -0700 (PDT)
In-Reply-To: <20101002093255.GA2049@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 octobre 2010 =C3=A0 11:32 +0200, Jarek Poplawski a =C3=A9c=
rit :
> On Fri, Oct 01, 2010 at 03:56:28PM +0200, Eric Dumazet wrote:
> =20
> >  static void netdev_init_queue_locks(struct net_device *dev)
> >  {
> >  	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL=
);
> > -	__netdev_init_queue_locks_one(dev, &dev->ingress_queue, NULL);
> > +	__netdev_init_queue_locks_one(dev, dev_ingress_queue(dev), NULL);
>=20
> Is dev_ingress_queue(dev) not NULL anytime here?

Yes, but I felt this could be removed later. If you feel its OK right
now, I am OK too ;)

>=20
> >  }
> > =20
> >  unsigned long netdev_fix_features(unsigned long features, const ch=
ar *name)
> > @@ -5447,16 +5448,37 @@ static void netdev_init_one_queue(struct ne=
t_device *dev,
> >  				  struct netdev_queue *queue,
> >  				  void *_unused)
> >  {
> > -	queue->dev =3D dev;
> > +	if (queue)
> > +		queue->dev =3D dev;
> >  }
> > =20
> >  static void netdev_init_queues(struct net_device *dev)
> >  {
> > -	netdev_init_one_queue(dev, &dev->ingress_queue, NULL);
> > +	netdev_init_one_queue(dev, dev_ingress_queue(dev), NULL);
>=20
> Is dev_ingress_queue(dev) not NULL anytime here?
>=20

Yes

> >  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> >  	spin_lock_init(&dev->tx_global_lock);
> >  }
> > =20
> > +struct netdev_queue *dev_ingress_queue_create(struct net_device *d=
ev)
> > +{
> > +	struct netdev_queue *queue =3D dev_ingress_queue(dev);
> > +
> > +#ifdef CONFIG_NET_CLS_ACT
> > +	if (queue)
> > +		return queue;
> > +	queue =3D kzalloc(sizeof(*queue), GFP_KERNEL);
> > +	if (!queue)
> > +		return NULL;
> > +	netdev_init_one_queue(dev, queue, NULL);
> > +	__netdev_init_queue_locks_one(dev, queue, NULL);
> > +	queue->qdisc =3D &noop_qdisc;
> > +	queue->qdisc_sleeping =3D &noop_qdisc;
> > +	smp_wmb();
>=20
> Why don't we need smp_rmb() in handle_ing()?
>=20

I only wanted to see if Al Viro was using ingress on its Alpha
machine ;)

I am going to use regular rcu api to ease code understanding :)


> > +	dev->ingress_queue =3D queue;
> > +#endif
> > +	return queue;
> > +}
> > +
> >  /**
> >   *	alloc_netdev_mq - allocate network device
> >   *	@sizeof_priv:	size of private data to allocate space for
> > @@ -5559,6 +5581,8 @@ void free_netdev(struct net_device *dev)
> > =20
> >  	kfree(dev->_tx);
> > =20
> > +	kfree(dev_ingress_queue(dev));
> > +
> >  	/* Flush device addresses */
> >  	dev_addr_flush(dev);
> > =20
> > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > index b802078..8635110 100644
> > --- a/net/sched/sch_api.c
> > +++ b/net/sched/sch_api.c
> > @@ -240,7 +240,10 @@ struct Qdisc *qdisc_lookup(struct net_device *=
dev, u32 handle)
> >  	if (q)
> >  		goto out;
> > =20
> > -	q =3D qdisc_match_from_root(dev->ingress_queue.qdisc_sleeping, ha=
ndle);
> > +	if (!dev_ingress_queue(dev))
> > +		goto out;
> > +	q =3D qdisc_match_from_root(dev_ingress_queue(dev)->qdisc_sleepin=
g,
> > +				  handle);
>=20


> I'd prefer:
>  +	if (dev_ingress_queue(dev))
>  +		q =3D qdisc_match_from_root(dev_ingress_queue(dev)->qdisc_sleepin=
g,
>=20

Yes

> >  out:
> >  	return q;
> >  }
> > @@ -690,6 +693,8 @@ static int qdisc_graft(struct net_device *dev, =
struct Qdisc *parent,
> >  		    (new && new->flags & TCQ_F_INGRESS)) {
> >  			num_q =3D 1;
> >  			ingress =3D 1;
> > +			if (!dev_ingress_queue(dev))
> > +				return -ENOENT;
>=20
> Is this test really needed here?

To avoid a NULL dereference some lines later.
Do I have a guarantee its not NULL here ?

>=20
> >  		}
> > =20
> >  		if (dev->flags & IFF_UP)
> > @@ -701,7 +706,7 @@ static int qdisc_graft(struct net_device *dev, =
struct Qdisc *parent,
> >  		}
> > =20
> >  		for (i =3D 0; i < num_q; i++) {
> > -			struct netdev_queue *dev_queue =3D &dev->ingress_queue;
> > +			struct netdev_queue *dev_queue =3D dev_ingress_queue(dev);
> > =20
> >  			if (!ingress)
> >  				dev_queue =3D netdev_get_tx_queue(dev, i);
> > @@ -979,7 +984,8 @@ static int tc_get_qdisc(struct sk_buff *skb, st=
ruct nlmsghdr *n, void *arg)
> >  					return -ENOENT;
> >  				q =3D qdisc_leaf(p, clid);
> >  			} else { /* ingress */
> > -				q =3D dev->ingress_queue.qdisc_sleeping;
> > +				if (dev_ingress_queue(dev))
> > +					q =3D dev_ingress_queue(dev)->qdisc_sleeping;
> >  			}
> >  		} else {
> >  			q =3D dev->qdisc;
> > @@ -1044,7 +1050,8 @@ replay:
> >  					return -ENOENT;
> >  				q =3D qdisc_leaf(p, clid);
> >  			} else { /*ingress */
> > -				q =3D dev->ingress_queue.qdisc_sleeping;
> > +				if (dev_ingress_queue_create(dev))
> > +					q =3D dev_ingress_queue(dev)->qdisc_sleeping;
>=20
> I wonder if doing dev_ingress_queue_create() just before qdisc_create=
()
> (and the test here) isn't more readable.

Sorry, I dont understand. I want to create ingress_queue only if user
wants it. If we setup (egress) trafic shaping, no need to setup
ingress_queue.

> > =20
> > @@ -753,7 +755,7 @@ void dev_activate(struct net_device *dev)
> > =20
> >  	need_watchdog =3D 0;
> >  	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdo=
g);
> > -	transition_one_qdisc(dev, &dev->ingress_queue, NULL);
> > +	transition_one_qdisc(dev, dev_ingress_queue(dev), NULL);
>=20
> I'd prefer here and similarly later:
>=20
>  +	if (dev_ingress_queue(dev))
>  +		transition_one_qdisc(dev, dev_ingress_queue(dev), NULL);
>=20
> to show NULL dev_queue is only legal in this one case.

OK, thanks a lot for the extended review Jarek (and Jamal of course)

Here is the V3 then.

[PATCH net-next V3] net: dynamic ingress_queue allocation

ingress being not used very much, and net_device->ingress_queue being
quite a big object (128 or 256 bytes), use a dynamic allocation if
needed (tc qdisc add dev eth0 ingress ...)

dev_ingress_queue(dev) helper should be used only with RTNL taken.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V3: add rcu notations & address Jarek comments
 include/linux/netdevice.h |    2 -
 include/linux/rtnetlink.h |    8 ++++++
 net/core/dev.c            |   34 ++++++++++++++++++++++-------
 net/sched/sch_api.c       |   42 ++++++++++++++++++++++++------------
 net/sched/sch_generic.c   |   12 ++++++----
 5 files changed, 71 insertions(+), 27 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ceed347..92d81ed 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -986,7 +986,7 @@ struct net_device {
 	rx_handler_func_t	*rx_handler;
 	void			*rx_handler_data;
=20
-	struct netdev_queue	ingress_queue; /* use two cache lines */
+	struct netdev_queue __rcu *ingress_queue;
=20
 /*
  * Cache lines mostly used on transmit path
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 68c436b..0bb7b48 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -6,6 +6,7 @@
 #include <linux/if_link.h>
 #include <linux/if_addr.h>
 #include <linux/neighbour.h>
+#include <linux/netdevice.h>
=20
 /* rtnetlink families. Values up to 127 are reserved for real address
  * families, values above 128 may be used arbitrarily.
@@ -769,6 +770,13 @@ extern int lockdep_rtnl_is_held(void);
 #define rtnl_dereference(p)					\
 	rcu_dereference_check(p, lockdep_rtnl_is_held())
=20
+static inline struct netdev_queue *dev_ingress_queue(struct net_device=
 *dev)
+{
+	return rtnl_dereference(dev->ingress_queue);
+}
+
+extern struct netdev_queue *dev_ingress_queue_create(struct net_device=
 *dev);
+
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index a313bab..b078ec8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2702,11 +2702,10 @@ EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
  * the ingress scheduler, you just cant add policies on ingress.
  *
  */
-static int ing_filter(struct sk_buff *skb)
+static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 {
 	struct net_device *dev =3D skb->dev;
 	u32 ttl =3D G_TC_RTTL(skb->tc_verd);
-	struct netdev_queue *rxq;
 	int result =3D TC_ACT_OK;
 	struct Qdisc *q;
=20
@@ -2720,8 +2719,6 @@ static int ing_filter(struct sk_buff *skb)
 	skb->tc_verd =3D SET_TC_RTTL(skb->tc_verd, ttl);
 	skb->tc_verd =3D SET_TC_AT(skb->tc_verd, AT_INGRESS);
=20
-	rxq =3D &dev->ingress_queue;
-
 	q =3D rxq->qdisc;
 	if (q !=3D &noop_qdisc) {
 		spin_lock(qdisc_lock(q));
@@ -2737,7 +2734,9 @@ static inline struct sk_buff *handle_ing(struct s=
k_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	if (skb->dev->ingress_queue.qdisc =3D=3D &noop_qdisc)
+	struct netdev_queue *rxq =3D rcu_dereference(skb->dev->ingress_queue)=
;
+
+	if (!rxq || rxq->qdisc =3D=3D &noop_qdisc)
 		goto out;
=20
 	if (*pt_prev) {
@@ -2745,7 +2744,7 @@ static inline struct sk_buff *handle_ing(struct s=
k_buff *skb,
 		*pt_prev =3D NULL;
 	}
=20
-	switch (ing_filter(skb)) {
+	switch (ing_filter(skb, rxq)) {
 	case TC_ACT_SHOT:
 	case TC_ACT_STOLEN:
 		kfree_skb(skb);
@@ -4940,7 +4939,6 @@ static void __netdev_init_queue_locks_one(struct =
net_device *dev,
 static void netdev_init_queue_locks(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
-	__netdev_init_queue_locks_one(dev, &dev->ingress_queue, NULL);
 }
=20
 unsigned long netdev_fix_features(unsigned long features, const char *=
name)
@@ -5452,11 +5450,29 @@ static void netdev_init_one_queue(struct net_de=
vice *dev,
=20
 static void netdev_init_queues(struct net_device *dev)
 {
-	netdev_init_one_queue(dev, &dev->ingress_queue, NULL);
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
 	spin_lock_init(&dev->tx_global_lock);
 }
=20
+struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
+{
+	struct netdev_queue *queue =3D dev_ingress_queue(dev);
+
+#ifdef CONFIG_NET_CLS_ACT
+	if (queue)
+		return queue;
+	queue =3D kzalloc(sizeof(*queue), GFP_KERNEL);
+	if (!queue)
+		return NULL;
+	netdev_init_one_queue(dev, queue, NULL);
+	__netdev_init_queue_locks_one(dev, queue, NULL);
+	queue->qdisc =3D &noop_qdisc;
+	queue->qdisc_sleeping =3D &noop_qdisc;
+	rcu_assign_pointer(dev->ingress_queue, queue);
+#endif
+	return queue;
+}
+
 /**
  *	alloc_netdev_mq - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
@@ -5559,6 +5575,8 @@ void free_netdev(struct net_device *dev)
=20
 	kfree(dev->_tx);
=20
+	kfree(rcu_dereference_raw(dev->ingress_queue));
+
 	/* Flush device addresses */
 	dev_addr_flush(dev);
=20
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b802078..b22ca2d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -240,7 +240,10 @@ struct Qdisc *qdisc_lookup(struct net_device *dev,=
 u32 handle)
 	if (q)
 		goto out;
=20
-	q =3D qdisc_match_from_root(dev->ingress_queue.qdisc_sleeping, handle=
);
+	if (dev_ingress_queue(dev))
+		q =3D qdisc_match_from_root(
+			dev_ingress_queue(dev)->qdisc_sleeping,
+			handle);
 out:
 	return q;
 }
@@ -690,6 +693,8 @@ static int qdisc_graft(struct net_device *dev, stru=
ct Qdisc *parent,
 		    (new && new->flags & TCQ_F_INGRESS)) {
 			num_q =3D 1;
 			ingress =3D 1;
+			if (!dev_ingress_queue(dev))
+				return -ENOENT;
 		}
=20
 		if (dev->flags & IFF_UP)
@@ -701,7 +706,7 @@ static int qdisc_graft(struct net_device *dev, stru=
ct Qdisc *parent,
 		}
=20
 		for (i =3D 0; i < num_q; i++) {
-			struct netdev_queue *dev_queue =3D &dev->ingress_queue;
+			struct netdev_queue *dev_queue =3D dev_ingress_queue(dev);
=20
 			if (!ingress)
 				dev_queue =3D netdev_get_tx_queue(dev, i);
@@ -979,7 +984,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct=
 nlmsghdr *n, void *arg)
 					return -ENOENT;
 				q =3D qdisc_leaf(p, clid);
 			} else { /* ingress */
-				q =3D dev->ingress_queue.qdisc_sleeping;
+				if (dev_ingress_queue(dev))
+					q =3D dev_ingress_queue(dev)->qdisc_sleeping;
 			}
 		} else {
 			q =3D dev->qdisc;
@@ -1043,8 +1049,9 @@ replay:
 				if ((p =3D qdisc_lookup(dev, TC_H_MAJ(clid))) =3D=3D NULL)
 					return -ENOENT;
 				q =3D qdisc_leaf(p, clid);
-			} else { /*ingress */
-				q =3D dev->ingress_queue.qdisc_sleeping;
+			} else { /* ingress */
+				if (dev_ingress_queue_create(dev))
+					q =3D dev_ingress_queue(dev)->qdisc_sleeping;
 			}
 		} else {
 			q =3D dev->qdisc;
@@ -1123,11 +1130,14 @@ replay:
 create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
-	if (clid =3D=3D TC_H_INGRESS)
-		q =3D qdisc_create(dev, &dev->ingress_queue, p,
-				 tcm->tcm_parent, tcm->tcm_parent,
-				 tca, &err);
-	else {
+	if (clid =3D=3D TC_H_INGRESS) {
+		if (dev_ingress_queue(dev))
+			q =3D qdisc_create(dev, dev_ingress_queue(dev), p,
+					 tcm->tcm_parent, tcm->tcm_parent,
+					 tca, &err);
+		else
+			err =3D -ENOENT;
+	} else {
 		struct netdev_queue *dev_queue;
=20
 		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
@@ -1304,8 +1314,10 @@ static int tc_dump_qdisc(struct sk_buff *skb, st=
ruct netlink_callback *cb)
 		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
 			goto done;
=20
-		dev_queue =3D &dev->ingress_queue;
-		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s=
_q_idx) < 0)
+		dev_queue =3D dev_ingress_queue(dev);
+		if (dev_queue &&
+		    tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb,
+				       &q_idx, s_q_idx) < 0)
 			goto done;
=20
 cont:
@@ -1595,8 +1607,10 @@ static int tc_dump_tclass(struct sk_buff *skb, s=
truct netlink_callback *cb)
 	if (tc_dump_tclass_root(dev->qdisc, skb, tcm, cb, &t, s_t) < 0)
 		goto done;
=20
-	dev_queue =3D &dev->ingress_queue;
-	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, =
s_t) < 0)
+	dev_queue =3D dev_ingress_queue(dev);
+	if (dev_queue &&
+	    tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb,
+				&t, s_t) < 0)
 		goto done;
=20
 done:
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 545278a..3d57681 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -753,7 +753,8 @@ void dev_activate(struct net_device *dev)
=20
 	need_watchdog =3D 0;
 	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog);
-	transition_one_qdisc(dev, &dev->ingress_queue, NULL);
+	if (dev_ingress_queue(dev))
+		transition_one_qdisc(dev, dev_ingress_queue(dev), NULL);
=20
 	if (need_watchdog) {
 		dev->trans_start =3D jiffies;
@@ -812,7 +813,8 @@ static bool some_qdisc_is_busy(struct net_device *d=
ev)
 void dev_deactivate(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
-	dev_deactivate_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	if (dev_ingress_queue(dev))
+		dev_deactivate_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
=20
 	dev_watchdog_down(dev);
=20
@@ -838,7 +840,8 @@ void dev_init_scheduler(struct net_device *dev)
 {
 	dev->qdisc =3D &noop_qdisc;
 	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
-	dev_init_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	if (dev_ingress_queue(dev))
+		dev_init_scheduler_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
=20
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
@@ -861,7 +864,8 @@ static void shutdown_scheduler_queue(struct net_dev=
ice *dev,
 void dev_shutdown(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
-	shutdown_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	if (dev_ingress_queue(dev))
+		shutdown_scheduler_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
 	qdisc_destroy(dev->qdisc);
 	dev->qdisc =3D &noop_qdisc;
=20


