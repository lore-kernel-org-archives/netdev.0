From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next V3] net: percpu net_device refcount
Date: Mon, 11 Oct 2010 22:22:12 +0200
Message-ID: <1286828532.30423.16.camel@edumazet-laptop>
References: <20101011.121344.260085789.davem@davemloft.net>
	 <1286825929.3218.7.camel@edumazet-laptop>
	 <20101011.124137.102555159.davem@davemloft.net>
	 <20101011.124938.179933637.davem@davemloft.net>
	 <1286826685.3218.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36311 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756055Ab0JKUWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 16:22:34 -0400
Received: by wwb34 with SMTP id 34so409995wwb.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 13:22:32 -0700 (PDT)
In-Reply-To: <1286826685.3218.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 21:51 +0200, Eric Dumazet a =C3=A9crit =
:
> Le lundi 11 octobre 2010 =C3=A0 12:49 -0700, David Miller a =C3=A9cri=
t :
>=20
> > Actually I have to revert, this breaks the infiniband drivers
> > which access netdev->refcnt directly.
> >=20
> > drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_alloc_pd':
> > drivers/infiniband/hw/nes/nes_verbs.c:786:2: error: 'struct net_dev=
ice' has no member named 'refcnt'
> > drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_create_qp':
> > drivers/infiniband/hw/nes/nes_verbs.c:1418:2: error: 'struct net_de=
vice' has no member named 'refcnt'
> > drivers/infiniband/hw/nes/nes_cm.c: In function 'nes_disconnect':
> > drivers/infiniband/hw/nes/nes_cm.c:2703:2: error: 'struct net_devic=
e' has no member named 'refcnt'
> > drivers/infiniband/hw/nes/nes_cm.c: In function 'nes_accept':
> > drivers/infiniband/hw/nes/nes_cm.c:2793:2: error: 'struct net_devic=
e' has no member named 'refcnt'
>=20
> Ah ok, I'll make a build test before submitting v3, sorry for the
> inconvenience.
>=20

This was a bit long (allyesconfig), but eventually succeeded ...

Thanks !

[PATCH net-next V3] net: percpu net_device refcount

We tried very hard to remove all possible dev_hold()/dev_put() pairs in
network stack, using RCU conversions.

There is still an unavoidable device refcount change for every dst we
create/destroy, and this can slow down some workloads (routers or some
app servers, mmap af_packet)

We can switch to a percpu refcount implementation, now dynamic per_cpu
infrastructure is mature. On a 64 cpus machine, this consumes 256 bytes
per device.

On x86, dev_hold(dev) code :

before
        lock    incl 0x280(%ebx)
after:
        movl    0x260(%ebx),%eax
        incl    fs:(%eax)

Stress bench :

(Sending 160.000.000 UDP frames,
IP route cache disabled, dual E5540 @2.53GHz,
32bit kernel, FIB_TRIE)

Before:

real    1m1.662s
user    0m14.373s
sys     12m55.960s

After:

real    0m51.179s
user    0m15.329s
sys     10m15.942s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V3: export netdev_refcnt_read() for infiniband debugging

 drivers/infiniband/hw/nes/nes_cm.c    |    4 +-
 drivers/infiniband/hw/nes/nes_verbs.c |    4 +-
 include/linux/netdevice.h             |    7 ++--
 net/core/dev.c                        |   40 +++++++++++++++++++-----
 4 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw=
/nes/nes_cm.c
index 61e0efd..6220d9d 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -2701,7 +2701,7 @@ static int nes_disconnect(struct nes_qp *nesqp, i=
nt abrupt)
 	nesibdev =3D nesvnic->nesibdev;
=20
 	nes_debug(NES_DBG_CM, "netdev refcnt =3D %u.\n",
-			atomic_read(&nesvnic->netdev->refcnt));
+			netdev_refcnt_read(nesvnic->netdev));
=20
 	if (nesqp->active_conn) {
=20
@@ -2791,7 +2791,7 @@ int nes_accept(struct iw_cm_id *cm_id, struct iw_=
cm_conn_param *conn_param)
 	atomic_inc(&cm_accepts);
=20
 	nes_debug(NES_DBG_CM, "netdev refcnt =3D %u.\n",
-			atomic_read(&nesvnic->netdev->refcnt));
+			netdev_refcnt_read(nesvnic->netdev));
=20
 	/* allocate the ietf frame and space for private data */
 	nesqp->ietf_frame =3D pci_alloc_consistent(nesdev->pcidev,
diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband=
/hw/nes/nes_verbs.c
index 9046e66..546fc22 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -785,7 +785,7 @@ static struct ib_pd *nes_alloc_pd(struct ib_device =
*ibdev,
=20
 	nes_debug(NES_DBG_PD, "nesvnic=3D%p, netdev=3D%p %s, ibdev=3D%p, cont=
ext=3D%p, netdev refcnt=3D%u\n",
 			nesvnic, nesdev->netdev[0], nesdev->netdev[0]->name, ibdev, context=
,
-			atomic_read(&nesvnic->netdev->refcnt));
+			netdev_refcnt_read(nesvnic->netdev));
=20
 	err =3D nes_alloc_resource(nesadapter, nesadapter->allocated_pds,
 			nesadapter->max_pd, &pd_num, &nesadapter->next_pd);
@@ -1416,7 +1416,7 @@ static struct ib_qp *nes_create_qp(struct ib_pd *=
ibpd,
 	/* update the QP table */
 	nesdev->nesadapter->qp_table[nesqp->hwqp.qp_id-NES_FIRST_QPN] =3D nes=
qp;
 	nes_debug(NES_DBG_QP, "netdev refcnt=3D%u\n",
-			atomic_read(&nesvnic->netdev->refcnt));
+			netdev_refcnt_read(nesvnic->netdev));
=20
 	return &nesqp->ibqp;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4160db3..14fbb04 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1026,7 +1026,7 @@ struct net_device {
 	struct timer_list	watchdog_timer;
=20
 	/* Number of references to this device */
-	atomic_t		refcnt ____cacheline_aligned_in_smp;
+	int __percpu		*pcpu_refcnt;
=20
 	/* delayed register/unregister */
 	struct list_head	todo_list;
@@ -1330,6 +1330,7 @@ static inline void unregister_netdevice(struct ne=
t_device *dev)
 	unregister_netdevice_queue(dev, NULL);
 }
=20
+extern int 		netdev_refcnt_read(const struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
@@ -1798,7 +1799,7 @@ extern void netdev_run_todo(void);
  */
 static inline void dev_put(struct net_device *dev)
 {
-	atomic_dec(&dev->refcnt);
+	irqsafe_cpu_dec(*dev->pcpu_refcnt);
 }
=20
 /**
@@ -1809,7 +1810,7 @@ static inline void dev_put(struct net_device *dev=
)
  */
 static inline void dev_hold(struct net_device *dev)
 {
-	atomic_inc(&dev->refcnt);
+	irqsafe_cpu_inc(*dev->pcpu_refcnt);
 }
=20
 /* Carrier loss detection, dial on demand. The functions netif_carrier=
_on
diff --git a/net/core/dev.c b/net/core/dev.c
index 193eafa..04972a4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5192,9 +5192,6 @@ int init_dummy_netdev(struct net_device *dev)
 	 */
 	dev->reg_state =3D NETREG_DUMMY;
=20
-	/* initialize the ref count */
-	atomic_set(&dev->refcnt, 1);
-
 	/* NAPI wants this */
 	INIT_LIST_HEAD(&dev->napi_list);
=20
@@ -5202,6 +5199,11 @@ int init_dummy_netdev(struct net_device *dev)
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 	set_bit(__LINK_STATE_START, &dev->state);
=20
+	/* Note : We dont allocate pcpu_refcnt for dummy devices,
+	 * because users of this 'device' dont need to change
+	 * its refcount.
+	 */
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(init_dummy_netdev);
@@ -5243,6 +5245,16 @@ out:
 }
 EXPORT_SYMBOL(register_netdev);
=20
+int netdev_refcnt_read(const struct net_device *dev)
+{
+	int i, refcnt =3D 0;
+
+	for_each_possible_cpu(i)
+		refcnt +=3D *per_cpu_ptr(dev->pcpu_refcnt, i);
+	return refcnt;
+}
+EXPORT_SYMBOL(netdev_refcnt_read);
+
 /*
  * netdev_wait_allrefs - wait until all references are gone.
  *
@@ -5257,11 +5269,14 @@ EXPORT_SYMBOL(register_netdev);
 static void netdev_wait_allrefs(struct net_device *dev)
 {
 	unsigned long rebroadcast_time, warning_time;
+	int refcnt;
=20
 	linkwatch_forget_dev(dev);
=20
 	rebroadcast_time =3D warning_time =3D jiffies;
-	while (atomic_read(&dev->refcnt) !=3D 0) {
+	refcnt =3D netdev_refcnt_read(dev);
+
+	while (refcnt !=3D 0) {
 		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
 			rtnl_lock();
=20
@@ -5288,11 +5303,13 @@ static void netdev_wait_allrefs(struct net_devi=
ce *dev)
=20
 		msleep(250);
=20
+		refcnt =3D netdev_refcnt_read(dev);
+
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
 			printk(KERN_EMERG "unregister_netdevice: "
 			       "waiting for %s to become free. Usage "
 			       "count =3D %d\n",
-			       dev->name, atomic_read(&dev->refcnt));
+			       dev->name, refcnt);
 			warning_time =3D jiffies;
 		}
 	}
@@ -5350,7 +5367,7 @@ void netdev_run_todo(void)
 		netdev_wait_allrefs(dev);
=20
 		/* paranoia */
-		BUG_ON(atomic_read(&dev->refcnt));
+		BUG_ON(netdev_refcnt_read(dev));
 		WARN_ON(rcu_dereference_raw(dev->ip_ptr));
 		WARN_ON(dev->ip6_ptr);
 		WARN_ON(dev->dn_ptr);
@@ -5520,9 +5537,13 @@ struct net_device *alloc_netdev_mq(int sizeof_pr=
iv, const char *name,
 	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded =3D (char *)dev - (char *)p;
=20
-	if (dev_addr_init(dev))
+	dev->pcpu_refcnt =3D alloc_percpu(int);
+	if (!dev->pcpu_refcnt)
 		goto free_tx;
=20
+	if (dev_addr_init(dev))
+		goto free_pcpu;
+
 	dev_mc_init(dev);
 	dev_uc_init(dev);
=20
@@ -5553,6 +5574,8 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
=20
 free_tx:
 	kfree(tx);
+free_pcpu:
+	free_percpu(dev->pcpu_refcnt);
 free_p:
 	kfree(p);
 	return NULL;
@@ -5586,6 +5609,9 @@ void free_netdev(struct net_device *dev)
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);
=20
+	free_percpu(dev->pcpu_refcnt);
+	dev->pcpu_refcnt =3D NULL;
+
 	/*  Compatibility with error handling in drivers */
 	if (dev->reg_state =3D=3D NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);


