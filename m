From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for March 22 (net-sysfs.c)
Date: Mon, 22 Mar 2010 21:48:42 +0100
Message-ID: <1269290922.3043.9.camel@edumazet-laptop>
References: <20100322171937.d753bdba.sfr@canb.auug.org.au>
	 <4BA78D3D.9090007@oracle.com>
	 <20100322.102206.148561893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322.102206.148561893.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 22 mars 2010 =C3=A0 10:22 -0700, David Miller a =C3=A9crit :
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Mon, 22 Mar 2010 08:31:09 -0700
>=20
> > When CONFIG_SYSFS is not enabled:
> >=20
> > net/core/net-sysfs.c:742: error: implicit declaration of function '=
rx_queue_remove_kobjects'
> > net/core/net-sysfs.c:783: error: implicit declaration of function '=
rx_queue_register_kobjects'
> >=20
>=20

I cooked following patch and added a new CONFIG_RPS setting, I believe
its cleaner and could help.

Thanks

[PATCH net-next-2.6] net: RPS depends on CONFIG_SYSFS

Randy Dunlap found net/core/net-sysfs.c could not compile if
CONFIG_SYSFS=3Dn

Defines CONFIG_RPS in net/Kconfig to let user disable RPS if wanted.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    4 ++++
 net/Kconfig               |    5 +++++
 net/core/dev.c            |   29 +++++++++++++++++++----------
 net/core/net-sysfs.c      |    7 ++++++-
 4 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c96c41e..c94cdb4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -531,6 +531,7 @@ struct netdev_queue {
 	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
=20
+#if defined(CONFIG_RPS)
 /*
  * This structure holds an RPS map which can be of variable length.  T=
he
  * map is an array of CPUs.
@@ -549,6 +550,7 @@ struct netdev_rx_queue {
 	struct netdev_rx_queue *first;
 	atomic_t count;
 } ____cacheline_aligned_in_smp;
+#endif
=20
 /*
  * This structure defines the management hooks for network devices.
@@ -897,12 +899,14 @@ struct net_device {
=20
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
=20
+#ifdef CONFIG_RPS
 	struct kset		*queues_kset;
=20
 	struct netdev_rx_queue	*_rx;
=20
 	/* Number of RX queues allocated at alloc_netdev_mq() time  */
 	unsigned int		num_rx_queues;
+#endif
=20
 	struct netdev_queue	rx_queue;
=20
diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..8189502 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -203,6 +203,11 @@ source "net/ieee802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
=20
+config RPS
+	boolean "RPS: Remote Packet Steering"
+	depends on SMP && SYSFS
+	default y
+
 menu "Network testing"
=20
 config NET_PKTGEN
diff --git a/net/core/dev.c b/net/core/dev.c
index a03aab4..0ea0f96 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2177,7 +2177,7 @@ int weight_p __read_mostly =3D 64;            /* =
old backlog weight */
=20
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
=20
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
@@ -2325,7 +2325,7 @@ enqueue:
=20
 		/* Schedule NAPI for backlog device */
 		if (napi_schedule_prep(&queue->backlog)) {
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 			if (cpu !=3D smp_processor_id()) {
 				struct rps_remote_softirq_cpus *rcpus =3D
 				    &__get_cpu_var(rps_remote_softirq_cpus);
@@ -2376,7 +2376,7 @@ int netif_rx(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
=20
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	cpu =3D get_rps_cpu(skb->dev, skb);
 	if (cpu < 0)
 		cpu =3D smp_processor_id();
@@ -2750,7 +2750,7 @@ out:
  */
 int netif_receive_skb(struct sk_buff *skb)
 {
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	int cpu;
=20
 	cpu =3D get_rps_cpu(skb->dev, skb);
@@ -3187,7 +3187,7 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
=20
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 /*
  * net_rps_action sends any pending IPI's for rps.  This is only calle=
d from
  * softirq and interrupts must be enabled.
@@ -3212,7 +3212,7 @@ static void net_rx_action(struct softirq_action *=
h)
 	unsigned long time_limit =3D jiffies + 2;
 	int budget =3D netdev_budget;
 	void *have;
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	int select;
 	struct rps_remote_softirq_cpus *rcpus;
 #endif
@@ -3278,7 +3278,7 @@ static void net_rx_action(struct softirq_action *=
h)
 		netpoll_poll_unlock(have);
 	}
 out:
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	rcpus =3D &__get_cpu_var(rps_remote_softirq_cpus);
 	select =3D rcpus->select;
 	rcpus->select ^=3D 1;
@@ -5275,6 +5275,7 @@ int register_netdevice(struct net_device *dev)
=20
 	dev->iflink =3D -1;
=20
+#ifdef CONFIG_RPS
 	if (!dev->num_rx_queues) {
 		/*
 		 * Allocate a single RX queue if driver never called
@@ -5291,7 +5292,7 @@ int register_netdevice(struct net_device *dev)
 		atomic_set(&dev->_rx->count, 1);
 		dev->num_rx_queues =3D 1;
 	}
-
+#endif
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret =3D dev->netdev_ops->ndo_init(dev);
@@ -5649,11 +5650,13 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
 	struct netdev_queue *tx;
-	struct netdev_rx_queue *rx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
+#ifdef CONFIG_RPS
+	struct netdev_rx_queue *rx;
 	int i;
+#endif
=20
 	BUG_ON(strlen(name) >=3D sizeof(dev->name));
=20
@@ -5679,6 +5682,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 		goto free_p;
 	}
=20
+#ifdef CONFIG_RPS
 	rx =3D kcalloc(queue_count, sizeof(struct netdev_rx_queue), GFP_KERNE=
L);
 	if (!rx) {
 		printk(KERN_ERR "alloc_netdev: Unable to allocate "
@@ -5694,6 +5698,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	 */
 	for (i =3D 0; i < queue_count; i++)
 		rx[i].first =3D rx;
+#endif
=20
 	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded =3D (char *)dev - (char *)p;
@@ -5709,8 +5714,10 @@ struct net_device *alloc_netdev_mq(int sizeof_pr=
iv, const char *name,
 	dev->num_tx_queues =3D queue_count;
 	dev->real_num_tx_queues =3D queue_count;
=20
+#ifdef CONFIG_RPS
 	dev->_rx =3D rx;
 	dev->num_rx_queues =3D queue_count;
+#endif
=20
 	dev->gso_max_size =3D GSO_MAX_SIZE;
=20
@@ -5727,8 +5734,10 @@ struct net_device *alloc_netdev_mq(int sizeof_pr=
iv, const char *name,
 	return dev;
=20
 free_rx:
+#ifdef CONFIG_RPS
 	kfree(rx);
 free_tx:
+#endif
 	kfree(tx);
 free_p:
 	kfree(p);
@@ -6232,7 +6241,7 @@ static int __init net_dev_init(void)
 		queue->completion_queue =3D NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
=20
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 		queue->csd.func =3D trigger_softirq;
 		queue->csd.info =3D queue;
 		queue->csd.flags =3D 0;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7a46343..1e7fdd6 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -466,6 +466,7 @@ static struct attribute_group wireless_group =3D {
 };
 #endif
=20
+#ifdef CONFIG_RPS
 /*
  * RX queue sysfs structures and functions.
  */
@@ -675,7 +676,7 @@ static void rx_queue_remove_kobjects(struct net_dev=
ice *net)
 		kobject_put(&net->_rx[i].kobj);
 	kset_unregister(net->queues_kset);
 }
-
+#endif /* CONFIG_RPS */
 #endif /* CONFIG_SYSFS */
=20
 #ifdef CONFIG_HOTPLUG
@@ -739,7 +740,9 @@ void netdev_unregister_kobject(struct net_device * =
net)
 	if (!net_eq(dev_net(net), &init_net))
 		return;
=20
+#ifdef CONFIG_RPS
 	rx_queue_remove_kobjects(net);
+#endif
=20
 	device_del(dev);
 }
@@ -780,11 +783,13 @@ int netdev_register_kobject(struct net_device *ne=
t)
 	if (error)
 		return error;
=20
+#ifdef CONFIG_RPS
 	error =3D rx_queue_register_kobjects(net);
 	if (error) {
 		device_del(dev);
 		return error;
 	}
+#endif
=20
 	return error;
 }
