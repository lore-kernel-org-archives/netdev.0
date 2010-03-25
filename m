From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 06:13:54 +0100
Message-ID: <1269494034.15280.51.camel@edumazet-laptop>
References: <4BAAE6E9.6030103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65245 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab0CYFOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 01:14:00 -0400
Received: by bwz1 with SMTP id 1so545203bwz.21
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 22:13:58 -0700 (PDT)
In-Reply-To: <4BAAE6E9.6030103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 12:30 +0800, Changli Gao a =C3=A9crit :
> +#ifdef CONFIG_SMP
> +#include <linux/if_pppox.h>
> +#endif

BTW, when I see this kind of illogical thing, I do think we should have
a CONFIG_RPS setting...

David, may I submit again my former patch adding CONFIG_RPS, but not a
user selectable boolean ?

[PATCH net-next-2.6] rps: add CONFIG_RPS

RPS currently depends on SMP and SYSFS

Adding a CONFIG_RPS makes sense in case this requirement changes in the
future. This patch saves about 1500 bytes of kernel text in case SMP is
on but SYSFS is off.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    4 ++++
 net/Kconfig               |    5 +++++
 net/core/dev.c            |   29 +++++++++++++++++++----------
 3 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c96c41e..53c272f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -531,6 +531,7 @@ struct netdev_queue {
 	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
=20
+#ifdef CONFIG_RPS
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
index 041c35e..6851464 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -203,6 +203,11 @@ source "net/ieee802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
=20
+config RPS
+	boolean
+	depends on SMP && SYSFS
+	default y
+
 menu "Network testing"
=20
 config NET_PKTGEN
diff --git a/net/core/dev.c b/net/core/dev.c
index 5e3dc28..bcb3ed2 100644
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
@@ -3189,7 +3189,7 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
=20
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 /*
  * net_rps_action sends any pending IPI's for rps.  This is only calle=
d from
  * softirq and interrupts must be enabled.
@@ -3214,7 +3214,7 @@ static void net_rx_action(struct softirq_action *=
h)
 	unsigned long time_limit =3D jiffies + 2;
 	int budget =3D netdev_budget;
 	void *have;
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	int select;
 	struct rps_remote_softirq_cpus *rcpus;
 #endif
@@ -3280,7 +3280,7 @@ static void net_rx_action(struct softirq_action *=
h)
 		netpoll_poll_unlock(have);
 	}
 out:
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	rcpus =3D &__get_cpu_var(rps_remote_softirq_cpus);
 	select =3D rcpus->select;
 	rcpus->select ^=3D 1;
@@ -5277,6 +5277,7 @@ int register_netdevice(struct net_device *dev)
=20
 	dev->iflink =3D -1;
=20
+#ifdef CONFIG_RPS
 	if (!dev->num_rx_queues) {
 		/*
 		 * Allocate a single RX queue if driver never called
@@ -5293,7 +5294,7 @@ int register_netdevice(struct net_device *dev)
 		atomic_set(&dev->_rx->count, 1);
 		dev->num_rx_queues =3D 1;
 	}
-
+#endif
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret =3D dev->netdev_ops->ndo_init(dev);
@@ -5653,11 +5654,13 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
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
@@ -5683,6 +5686,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 		goto free_p;
 	}
=20
+#ifdef CONFIG_RPS
 	rx =3D kcalloc(queue_count, sizeof(struct netdev_rx_queue), GFP_KERNE=
L);
 	if (!rx) {
 		printk(KERN_ERR "alloc_netdev: Unable to allocate "
@@ -5698,6 +5702,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	 */
 	for (i =3D 0; i < queue_count; i++)
 		rx[i].first =3D rx;
+#endif
=20
 	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded =3D (char *)dev - (char *)p;
@@ -5713,8 +5718,10 @@ struct net_device *alloc_netdev_mq(int sizeof_pr=
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
@@ -5731,8 +5738,10 @@ struct net_device *alloc_netdev_mq(int sizeof_pr=
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
@@ -6236,7 +6245,7 @@ static int __init net_dev_init(void)
 		queue->completion_queue =3D NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
=20
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 		queue->csd.func =3D trigger_softirq;
 		queue->csd.info =3D queue;
 		queue->csd.flags =3D 0;


