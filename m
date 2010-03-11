From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v6] rps: Receive Packet Steering
Date: Thu, 11 Mar 2010 09:11:14 -0800
Message-ID: <65634d661003110911w4b23a962gb79955ff2cc19db3@mail.gmail.com>
References: <alpine.DEB.1.00.1003102249380.21248@pokey.mtv.corp.google.com>
	 <1268318738.2986.518.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:56558 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933303Ab0CKRLV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 12:11:21 -0500
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o2BHBHPH005047
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 17:11:18 GMT
Received: from fxm26 (fxm26.prod.google.com [10.184.13.26])
	by wpaz33.hot.corp.google.com with ESMTP id o2BHBFVQ001589
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 09:11:15 -0800
Received: by fxm26 with SMTP id 26so290637fxm.35
        for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 09:11:15 -0800 (PST)
In-Reply-To: <1268318738.2986.518.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, thanks for the great comments!

>
> - When a netdevice is freed, I believe you leak rps_maps if they were
> previously allocated. I found following patch necessary to fix it.
>
Yes.

> - Maybe use max(RPM_MAP_SIZE(x), L1_CACHE_BYTES) for allocations to
> avoid false sharing for small maps. (Or else, other part of cache lin=
e
> might be given to a user that might dirty it at high rate)
>
Okay.

> - "struct netdev_rx_queue" being only read in fast path, I am not sur=
e
> an alignement is necessary, apart the false sharing that can be
> separately addressed.
>
If we get rid of the double indirection like you describe below, then
this can be allocated in the same way dev->_tx is (kcalloc).  Also,
this might a a good structure for writing stats, etc.

>
> - A double indirection to get a struct netdev_rx_queue pointer is
> expensive, not for heavy load benchmarks, but for latencies in seldom
> used devices. I understand you added this for kobject deferred releas=
e
> and kfreeing, but this seems a high price to pay in our fast path. I
> used another solution.
>
Yes, this is much better.  The kobject documentation has dire warnings
about placing more than one kobject in a data structure, I think I
took that too literally!

>
> - WARN(1, "Recieved packet on %s for queue %u, "
> =A0 -> Received
>
Yes, i before e expect after c...

> - Use of cpumask_t for variable on stack is discouraged, we shall use
> cpumask_var_t if possible. Easy for show/store commands. (see my patc=
h)
>
Yes.

> Yet, adding a memory allocation in net_rx_action() seems overkill, so=
 we
> might use two static masks per cpu, and perform a flip ? This would h=
elp
> machines with 4096 cpus : To Be Done ?

That is an interesting idea.  I'll try it.

>
>
> - RTNL to guard rps map exchange ???
> This sounds like BKL (Big Kernel Lock) syndrom to me :
> Trying to avoid it if possible is better, because it wont exist anymo=
re
> in ten years with 0.99 probability.
>
Yes.

>
> For ease of discussion, I cooked following patch on top of yours :
>

I will apply it.

> Thanks !
>
> =A0include/linux/netdevice.h | =A0 =A08 ++-
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 64 ++++++++++---------=
----------
> =A0net/core/net-sysfs.c =A0 =A0 =A0| =A0 78 ++++++++++++++++++++++---=
-----------
> =A03 files changed, 77 insertions(+), 73 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 468da0a..3f4a986 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -544,9 +544,11 @@ struct rps_map {
>
> =A0/* This structure contains an instance of an RX queue. */
> =A0struct netdev_rx_queue {
> - =A0 =A0 =A0 struct kobject kobj;
> =A0 =A0 =A0 =A0struct rps_map *rps_map;
> -} ____cacheline_aligned_in_smp;
> + =A0 =A0 =A0 struct kobject kobj;
> + =A0 =A0 =A0 struct netdev_rx_queue *first;
> + =A0 =A0 =A0 atomic_t count;
> +};
>
> =A0/*
> =A0* This structure defines the management hooks for network devices.
> @@ -897,7 +899,7 @@ struct net_device {
>
> =A0 =A0 =A0 =A0struct kset =A0 =A0 =A0 =A0 =A0 =A0 *queues_kset;
>
> - =A0 =A0 =A0 struct netdev_rx_queue =A0**_rx;
> + =A0 =A0 =A0 struct netdev_rx_queue =A0*_rx;
>
> =A0 =A0 =A0 =A0/* Number of RX queues allocated at alloc_netdev_mq() =
time =A0*/
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0num_rx_queues;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 939b1a2..402f23a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2195,15 +2195,15 @@ static int get_rps_cpu(struct net_device *dev=
, struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 index =3D skb_get_rx_queue(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(index >=3D dev->num_rx_qu=
eues)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (net_ratelimit()) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN(1,=
 "Recieved packet on %s for queue %u, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN(1,=
 "Received packet on %s for queue %u, "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
"but number of RX queues is %u\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 dev->name, index, dev->num_rx_queues);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx[index];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx + index;
> =A0 =A0 =A0 =A0} else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx[0];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx;
>
> =A0 =A0 =A0 =A0if (!rxqueue->rps_map)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> @@ -5236,20 +5236,17 @@ int register_netdevice(struct net_device *dev=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * alloc_netdev_mq
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->_rx =3D kzalloc(sizeof(struct netd=
ev_rx_queue *),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->_rx =3D kzalloc(max_t(unsigned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0sizeof(struct netdev_rx_queue),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0L1_CACHE_BYTES),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
GFP_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!dev->_rx) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->_rx[0] =3D kzalloc(sizeof(struct n=
etdev_rx_queue),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!dev->_rx[0]) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(dev->_rx);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->_rx[0].first =3D dev->_rx;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_set(&dev->_rx[0].count, 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->num_rx_queues =3D 1;
> =A0 =A0 =A0 =A0}
>
> @@ -5610,7 +5607,7 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*setup)(struct net_device *), un=
signed int queue_count)
> =A0{
> =A0 =A0 =A0 =A0struct netdev_queue *tx;
> - =A0 =A0 =A0 struct netdev_rx_queue **rx;
> + =A0 =A0 =A0 struct netdev_rx_queue *rx;
> =A0 =A0 =A0 =A0struct net_device *dev;
> =A0 =A0 =A0 =A0size_t alloc_size;
> =A0 =A0 =A0 =A0struct net_device *p;
> @@ -5635,37 +5632,30 @@ struct net_device *alloc_netdev_mq(int sizeof=
_priv, const char *name,
>
> =A0 =A0 =A0 =A0tx =3D kcalloc(queue_count, sizeof(struct netdev_queue=
), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!tx) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "alloc_netdev: Unable t=
o allocate "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"tx qdiscs.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("alloc_netdev: Unable to allocat=
e tx qdiscs.\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto free_p;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Allocate RX queue structures, this includes an arr=
ay of pointers
> - =A0 =A0 =A0 =A0* and netdev_queue_rx stuctures (individually alloca=
ted since
> - =A0 =A0 =A0 =A0* each has a kobject).
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 rx =3D kzalloc(queue_count *
> - =A0 =A0 =A0 =A0 =A0 sizeof(struct netdev_rx_queue *), GFP_KERNEL);
> + =A0 =A0 =A0 rx =3D kzalloc(max_t(unsigned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0queue_count * si=
zeof(struct netdev_rx_queue),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0L1_CACHE_BYTES),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!rx) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "alloc_netdev: Unable t=
o allocate "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"rx queues array.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("alloc_netdev: Unable to allocat=
e rx queues.\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto free_tx;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 for (i =3D 0; i < queue_count; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx[i] =3D kzalloc(sizeof(struct netdev_=
rx_queue), GFP_KERNEL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!rx[i]) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "alloc_=
netdev: Unable to allocate "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "rx queues.\n")=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_rx;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 atomic_set(&rx->count, queue_count);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Use counter is located in first element of this ar=
ray
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for (i =3D 0; i < queue_count; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx[i].first =3D rx;
>
> =A0 =A0 =A0 =A0dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
> =A0 =A0 =A0 =A0dev->padded =3D (char *)dev - (char *)p;
>
> =A0 =A0 =A0 =A0if (dev_addr_init(dev))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_tx;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_rx;
>
> =A0 =A0 =A0 =A0dev_unicast_init(dev);
>
> @@ -5693,8 +5683,6 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
> =A0 =A0 =A0 =A0return dev;
>
> =A0free_rx:
> - =A0 =A0 =A0 for (i =3D 0; i < queue_count; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(rx[i]);
> =A0 =A0 =A0 =A0kfree(rx);
> =A0free_tx:
> =A0 =A0 =A0 =A0kfree(tx);
> @@ -5720,12 +5708,6 @@ void free_netdev(struct net_device *dev)
>
> =A0 =A0 =A0 =A0kfree(dev->_tx);
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Free RX queue pointer array. =A0Actual netdev_rx_q=
ueue objects are
> - =A0 =A0 =A0 =A0* freed by kobject release.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 kfree(dev->_rx);
> -
> =A0 =A0 =A0 =A0/* Flush device addresses */
> =A0 =A0 =A0 =A0dev_addr_flush(dev);
>
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index a07d6ec..de75258 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -516,24 +516,26 @@ static ssize_t show_rps_map(struct netdev_rx_qu=
eue *queue,
> =A0 =A0 =A0 =A0size_t len =3D 0;
> =A0 =A0 =A0 =A0struct rps_map *map;
> =A0 =A0 =A0 =A0int i;
> - =A0 =A0 =A0 cpumask_t mask;
> + =A0 =A0 =A0 cpumask_var_t mask;
>
> - =A0 =A0 =A0 cpus_clear(mask);
> + =A0 =A0 =A0 if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0map =3D rcu_dereference(queue->rps_map);
> =A0 =A0 =A0 =A0if (map) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D 0; i < map->len; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_set(map->cpus[i], m=
ask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cpu(map->cp=
us[i], mask);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D cpumask_scnprintf(buf + len, P=
AGE_SIZE, &mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D cpumask_scnprintf(buf + len, P=
AGE_SIZE, mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PAGE_SIZE - len < 3) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0rcu_read_unlock();
> -
> + =A0 =A0 =A0 free_cpumask_var(mask);
> =A0 =A0 =A0 =A0len +=3D sprintf(buf + len, "\n");
> =A0 =A0 =A0 =A0return len;
> =A0}
> @@ -550,38 +552,48 @@ ssize_t store_rps_map(struct netdev_rx_queue *q=
ueue,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char *buf, size_t le=
n)
> =A0{
> =A0 =A0 =A0 =A0struct rps_map *old_map, *map;
> - =A0 =A0 =A0 cpumask_t mask;
> - =A0 =A0 =A0 int err, cpu, i, weight;
> + =A0 =A0 =A0 cpumask_var_t mask;
> + =A0 =A0 =A0 int err, cpu, i;
> + =A0 =A0 =A0 static DEFINE_SPINLOCK(rps_map_lock);
>
> =A0 =A0 =A0 =A0if (!capable(CAP_NET_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
> - =A0 =A0 =A0 err =3D bitmap_parse(buf, len, cpumask_bits(&mask), nr_=
cpumask_bits);
> - =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 err =3D bitmap_parse(buf, len, cpumask_bits(mask), nr_c=
pumask_bits);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 map =3D kzalloc(max_t(unsigned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RPS_MAP_SIZE(cp=
umask_weight(mask)),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 L1_CACHE_BYTES)=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
> + =A0 =A0 =A0 if (!map) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 i =3D 0;
> + =A0 =A0 =A0 for_each_cpu_and(cpu, mask, cpu_online_mask)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map->cpus[i++] =3D cpu;
> + =A0 =A0 =A0 if (i)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map->len =3D i;
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(map);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map =3D NULL;
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 weight =3D cpumask_weight(&mask);
> - =A0 =A0 =A0 if (weight) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 map =3D kzalloc(RPS_MAP_SIZE(weight), G=
=46P_KERNEL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!map)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpus_and(mask, mask, cpu_online_map);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_cpu_mask(cpu, mask)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 map->cpus[i++] =3D cpu;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 map->len =3D i;
> - =A0 =A0 =A0 } else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 map =3D NULL;
> -
> - =A0 =A0 =A0 rtnl_lock();
> + =A0 =A0 =A0 spin_lock(&rps_map_lock);
> =A0 =A0 =A0 =A0old_map =3D queue->rps_map;
> =A0 =A0 =A0 =A0rcu_assign_pointer(queue->rps_map, map);
> - =A0 =A0 =A0 rtnl_unlock();
> + =A0 =A0 =A0 spin_unlock(&rps_map_lock);
>
> =A0 =A0 =A0 =A0if (old_map)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0call_rcu(&old_map->rcu, rps_map_releas=
e);
>
> + =A0 =A0 =A0 free_cpumask_var(mask);
> =A0 =A0 =A0 =A0return len;
> =A0}
>
> @@ -596,8 +608,16 @@ static struct attribute *rx_queue_default_attrs[=
] =3D {
> =A0static void rx_queue_release(struct kobject *kobj)
> =A0{
> =A0 =A0 =A0 =A0struct netdev_rx_queue *queue =3D to_rx_queue(kobj);
> + =A0 =A0 =A0 struct rps_map *map =3D queue->rps_map;
> + =A0 =A0 =A0 struct netdev_rx_queue *first =3D queue->first;
>
> - =A0 =A0 =A0 kfree(queue);
> + =A0 =A0 =A0 if (map)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_rcu(&map->rcu, rps_map_release);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Free the array containing us only if all elems wer=
e released
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (atomic_dec_and_test(&first->count))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(first);
> =A0}
>
> =A0static struct kobj_type rx_queue_ktype =3D {
> @@ -609,7 +629,7 @@ static struct kobj_type rx_queue_ktype =3D {
> =A0static int rx_queue_add_kobject(struct net_device *net, int index)
> =A0{
> =A0 =A0 =A0 =A0int error =3D 0;
> - =A0 =A0 =A0 struct netdev_rx_queue *queue =3D net->_rx[index];
> + =A0 =A0 =A0 struct netdev_rx_queue *queue =3D net->_rx + index;
> =A0 =A0 =A0 =A0struct kobject *kobj =3D &queue->kobj;
>
> =A0 =A0 =A0 =A0kobj->kset =3D net->queues_kset;
> @@ -642,7 +662,7 @@ static int rx_queue_register_kobjects(struct net_=
device *net)
>
> =A0 =A0 =A0 =A0if (error)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (--i >=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kobject_put(&net->_rx[i=
]->kobj);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kobject_put(&net->_rx[i=
].kobj);
>
> =A0 =A0 =A0 =A0return error;
> =A0}
> @@ -652,7 +672,7 @@ static void rx_queue_remove_kobjects(struct net_d=
evice *net)
> =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < net->num_rx_queues; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kobject_put(&net->_rx[i]->kobj);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kobject_put(&net->_rx[i].kobj);
> =A0 =A0 =A0 =A0kset_unregister(net->queues_kset);
> =A0}
>
>
>
