From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next V2] net: dynamic ingress_queue allocation
Date: Fri, 01 Oct 2010 15:56:28 +0200
Message-ID: <1285941388.2641.175.camel@edumazet-laptop>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local>  <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39845 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331Ab0JAN4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 09:56:35 -0400
Received: by fxm14 with SMTP id 14so577691fxm.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 06:56:34 -0700 (PDT)
In-Reply-To: <1285933506.3553.176.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 01 octobre 2010 =C3=A0 07:45 -0400, jamal a =C3=A9crit :
> On Fri, 2010-10-01 at 00:58 +0200, Eric Dumazet wrote:
> > Hi Jamal
> >=20
> > Here is the dynamic allocation I promised. I lightly tested it, cou=
ld
> > you review it please ?
> > Thanks !
> >=20
> > [PATCH net-next2.6] net: dynamic ingress_queue allocation
> >=20
> > ingress being not used very much, and net_device->ingress_queue bei=
ng
> > quite a big object (128 or 256 bytes), use a dynamic allocation if
> > needed (tc qdisc add dev eth0 ingress ...)
>=20
> I agree with the principle that it is valuable in making it dynamic f=
or
> people who dont want it; but, but (like my kid would say, sniff, snif=
f)
> you are making me sad saying it is not used very much ;-> It is used
> very much in my world. My friend Jarek uses it;->
>=20

;)

>=20
> > +#ifdef CONFIG_NET_CLS_ACT
>=20
> I think appropriately this should be NET_SCH_INGRESS (everywhere else=
 as
> well).
>=20

I first thought of this, and found it would add a new dependence on
vmlinux :

If someone wants to add NET_SCH_INGRESS module, he would need to
recompile whole kernel and reboot.

This is probably why ing_filter() and handle_ing() are enclosed with
CONFIG_NET_CLS_ACT, not CONFIG_NET_SCH_INGRESS.

Since struct net_dev only holds one pointer (after this patch), I
believe its better to use same dependence.

>=20
> > +static inline struct netdev_queue *dev_ingress_queue(struct net_de=
vice *dev)
> > +{
> > +#ifdef CONFIG_NET_CLS_ACT
> > +	return dev->ingress_queue;
> > +#else
> > +	return NULL;
> > +#endif
>=20
> Above, if you just returned dev->ingress_queue wouldnt it always be=20
> NULL if it was not allocated?
>=20

ingress_queue is not defined in "struct net_device *dev" if=20
!CONFIG_NET_CLS_ACT

Returning NULL here permits dead code elimination by compiler.

Then, probably nobody unset CONFIG_NET_CLS_ACT, so we can probably avoi=
d
this preprocessor stuff.

>=20
> > @@ -2737,7 +2734,9 @@ static inline struct sk_buff *handle_ing(stru=
ct sk_buff *skb,
> >  					 struct packet_type **pt_prev,
> >  					 int *ret, struct net_device *orig_dev)
> >  {
> > -	if (skb->dev->ingress_queue.qdisc =3D=3D &noop_qdisc)
> > +	struct netdev_queue *rxq =3D dev_ingress_queue(skb->dev);
> > +
> > +	if (!rxq || rxq->qdisc =3D=3D &noop_qdisc)
> >  		goto out;
>=20
> I stared at above a little longer since this is the only fast path
> affected; is it a few more cycles now for people who love ingress?

I see, this adds an indirection and a conditional branch, but this
should be in cpu cache and well predicted.

I thought adding a fake "struct netdev_queue" object, with a qdisc
pointing to noop_qdisc. But this would slow down a bit non ingress
users ;)

=46or people not using ingress, my solution removes an access to an ext=
ra
cache line. So network latency is improved a bit when cpu caches are
full of user land data.

>=20
> > @@ -690,6 +693,8 @@ static int qdisc_graft(struct net_device *dev, =
struct Qdisc *parent,
> >  		    (new && new->flags & TCQ_F_INGRESS)) {
> >  			num_q =3D 1;
> >  			ingress =3D 1;
> > +			if (!dev_ingress_queue(dev))
> > +				return -ENOENT;
> >  		}
> > =20
>=20
> The above looks clever but worries me because it changes the old flow=
=2E
> If you have time,  the following tests will alleviate my fears
>=20
> 1) compile support for ingress and add/delete ingress qdisc

This worked for me, but I dont know complex setups.

> 2) Dont compile support and add/delete ingress qdisc

tc gives an error (a bit like !CONFIG_NET_SCH_INGRESS)

# tc qdisc add dev eth0 ingress
RTNETLINK answers: No such file or directory
# tc -s -d qdisc show dev eth0
qdisc mq 0: root=20
 Sent 636 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20


> 3) Compile ingress as a module and add/delete ingress qdisc
>=20
>=20

Seems to work like 1)

> Other than that excellent work Eric. And you can add my
> Acked/reviewed-by etc.
>=20
> BTW, did i say i like your per-cpu stats stuff? It applies nicely to
> qdiscs, actions etc ;->

I took a look at ifb as suggested by Stephen but could not see trivial
changes (LLTX or per-cpu stats), since central lock is needed I am
afraid. And qdisc are the same, stats updates are mostly free as we
dirtied cache line for the lock.

Thanks Jamal !

Here is the V2, with two #ifdef removed.


[PATCH net-next V2] net: dynamic ingress_queue allocation

ingress being not used very much, and net_device->ingress_queue being
quite a big object (128 or 256 bytes), use a dynamic allocation if
needed (tc qdisc add dev eth0 ingress ...)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |   11 ++++++--
 net/core/dev.c            |   48 +++++++++++++++++++++++++++---------
 net/sched/sch_api.c       |   40 ++++++++++++++++++++----------
 net/sched/sch_generic.c   |   36 +++++++++++++++------------
 4 files changed, 92 insertions(+), 43 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ceed347..4f86009 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -986,8 +986,7 @@ struct net_device {
 	rx_handler_func_t	*rx_handler;
 	void			*rx_handler_data;
=20
-	struct netdev_queue	ingress_queue; /* use two cache lines */
-
+	struct netdev_queue	*ingress_queue;
 /*
  * Cache lines mostly used on transmit path
  */
@@ -1115,6 +1114,14 @@ static inline void netdev_for_each_tx_queue(stru=
ct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
=20
+
+static inline struct netdev_queue *dev_ingress_queue(struct net_device=
 *dev)
+{
+	return dev->ingress_queue;
+}
+
+extern struct netdev_queue *dev_ingress_queue_create(struct net_device=
 *dev);
+
 /*
  * Net namespace inlines
  */
diff --git a/net/core/dev.c b/net/core/dev.c
index a313bab..e3bb8c9 100644
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
+	struct netdev_queue *rxq =3D dev_ingress_queue(skb->dev);
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
@@ -4932,15 +4931,17 @@ static void __netdev_init_queue_locks_one(struc=
t net_device *dev,
 					  struct netdev_queue *dev_queue,
 					  void *_unused)
 {
-	spin_lock_init(&dev_queue->_xmit_lock);
-	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
-	dev_queue->xmit_lock_owner =3D -1;
+	if (dev_queue) {
+		spin_lock_init(&dev_queue->_xmit_lock);
+		netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
+		dev_queue->xmit_lock_owner =3D -1;
+	}
 }
=20
 static void netdev_init_queue_locks(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
-	__netdev_init_queue_locks_one(dev, &dev->ingress_queue, NULL);
+	__netdev_init_queue_locks_one(dev, dev_ingress_queue(dev), NULL);
 }
=20
 unsigned long netdev_fix_features(unsigned long features, const char *=
name)
@@ -5447,16 +5448,37 @@ static void netdev_init_one_queue(struct net_de=
vice *dev,
 				  struct netdev_queue *queue,
 				  void *_unused)
 {
-	queue->dev =3D dev;
+	if (queue)
+		queue->dev =3D dev;
 }
=20
 static void netdev_init_queues(struct net_device *dev)
 {
-	netdev_init_one_queue(dev, &dev->ingress_queue, NULL);
+	netdev_init_one_queue(dev, dev_ingress_queue(dev), NULL);
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
+	smp_wmb();
+	dev->ingress_queue =3D queue;
+#endif
+	return queue;
+}
+
 /**
  *	alloc_netdev_mq - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
@@ -5559,6 +5581,8 @@ void free_netdev(struct net_device *dev)
=20
 	kfree(dev->_tx);
=20
+	kfree(dev_ingress_queue(dev));
+
 	/* Flush device addresses */
 	dev_addr_flush(dev);
=20
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b802078..8635110 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -240,7 +240,10 @@ struct Qdisc *qdisc_lookup(struct net_device *dev,=
 u32 handle)
 	if (q)
 		goto out;
=20
-	q =3D qdisc_match_from_root(dev->ingress_queue.qdisc_sleeping, handle=
);
+	if (!dev_ingress_queue(dev))
+		goto out;
+	q =3D qdisc_match_from_root(dev_ingress_queue(dev)->qdisc_sleeping,
+				  handle);
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
@@ -1044,7 +1050,8 @@ replay:
 					return -ENOENT;
 				q =3D qdisc_leaf(p, clid);
 			} else { /*ingress */
-				q =3D dev->ingress_queue.qdisc_sleeping;
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
index 545278a..c42dec5 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -721,16 +721,18 @@ static void transition_one_qdisc(struct net_devic=
e *dev,
 				 struct netdev_queue *dev_queue,
 				 void *_need_watchdog)
 {
-	struct Qdisc *new_qdisc =3D dev_queue->qdisc_sleeping;
-	int *need_watchdog_p =3D _need_watchdog;
+	if (dev_queue) {
+		struct Qdisc *new_qdisc =3D dev_queue->qdisc_sleeping;
+		int *need_watchdog_p =3D _need_watchdog;
=20
-	if (!(new_qdisc->flags & TCQ_F_BUILTIN))
-		clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
+		if (!(new_qdisc->flags & TCQ_F_BUILTIN))
+			clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
=20
-	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
-	if (need_watchdog_p && new_qdisc !=3D &noqueue_qdisc) {
-		dev_queue->trans_start =3D 0;
-		*need_watchdog_p =3D 1;
+		rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
+		if (need_watchdog_p && new_qdisc !=3D &noqueue_qdisc) {
+			dev_queue->trans_start =3D 0;
+			*need_watchdog_p =3D 1;
+		}
 	}
 }
=20
@@ -753,7 +755,7 @@ void dev_activate(struct net_device *dev)
=20
 	need_watchdog =3D 0;
 	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog);
-	transition_one_qdisc(dev, &dev->ingress_queue, NULL);
+	transition_one_qdisc(dev, dev_ingress_queue(dev), NULL);
=20
 	if (need_watchdog) {
 		dev->trans_start =3D jiffies;
@@ -768,7 +770,7 @@ static void dev_deactivate_queue(struct net_device =
*dev,
 	struct Qdisc *qdisc_default =3D _qdisc_default;
 	struct Qdisc *qdisc;
=20
-	qdisc =3D dev_queue->qdisc;
+	qdisc =3D dev_queue ? dev_queue->qdisc : NULL;
 	if (qdisc) {
 		spin_lock_bh(qdisc_lock(qdisc));
=20
@@ -812,7 +814,7 @@ static bool some_qdisc_is_busy(struct net_device *d=
ev)
 void dev_deactivate(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
-	dev_deactivate_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	dev_deactivate_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
=20
 	dev_watchdog_down(dev);
=20
@@ -830,15 +832,17 @@ static void dev_init_scheduler_queue(struct net_d=
evice *dev,
 {
 	struct Qdisc *qdisc =3D _qdisc;
=20
-	dev_queue->qdisc =3D qdisc;
-	dev_queue->qdisc_sleeping =3D qdisc;
+	if (dev_queue) {
+		dev_queue->qdisc =3D qdisc;
+		dev_queue->qdisc_sleeping =3D qdisc;
+	}
 }
=20
 void dev_init_scheduler(struct net_device *dev)
 {
 	dev->qdisc =3D &noop_qdisc;
 	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
-	dev_init_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	dev_init_scheduler_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
=20
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
@@ -847,7 +851,7 @@ static void shutdown_scheduler_queue(struct net_dev=
ice *dev,
 				     struct netdev_queue *dev_queue,
 				     void *_qdisc_default)
 {
-	struct Qdisc *qdisc =3D dev_queue->qdisc_sleeping;
+	struct Qdisc *qdisc =3D dev_queue ? dev_queue->qdisc_sleeping : NULL;
 	struct Qdisc *qdisc_default =3D _qdisc_default;
=20
 	if (qdisc) {
@@ -861,7 +865,7 @@ static void shutdown_scheduler_queue(struct net_dev=
ice *dev,
 void dev_shutdown(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
-	shutdown_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	shutdown_scheduler_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
 	qdisc_destroy(dev->qdisc);
 	dev->qdisc =3D &noop_qdisc;
=20


