From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v4 2/2] macvtap: Implement multiqueue for macvtap driver
Date: Wed, 4 Aug 2010 19:37:23 +0800
Message-ID: <AANLkTimgSg+iFouARaFv8X6S8d2e6L+ffkZkoOaja20R@mail.gmail.com>
References: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com>
	<20100804105525.22212.45090.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, arnd@arndb.de, mst@redhat.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	therbert@google.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42453 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932673Ab0HDLho convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 07:37:44 -0400
Received: by wyb39 with SMTP id 39so5401830wyb.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 04:37:43 -0700 (PDT)
In-Reply-To: <20100804105525.22212.45090.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 4, 2010 at 6:55 PM, Krishna Kumar <krkumar2@in.ibm.com> wro=
te:
> From: Krishna Kumar <krkumar2@in.ibm.com>
>
> Implement multiqueue facility for macvtap driver. The idea is that
> a macvtap device can be opened multiple times and the fd's can be
> used to register eg, as backend for vhost.
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> =A0drivers/net/macvtap.c =A0 =A0 =A0| =A0 89 ++++++++++++++++++++++++=
++++-------
> =A0include/linux/if_macvlan.h | =A0 =A09 +++
> =A02 files changed, 80 insertions(+), 18 deletions(-)
>
> diff -ruNp org/drivers/net/macvtap.c new/drivers/net/macvtap.c
> --- org/drivers/net/macvtap.c =A0 2010-07-28 15:10:10.000000000 +0530
> +++ new/drivers/net/macvtap.c =A0 2010-08-04 16:19:32.000000000 +0530
> @@ -84,26 +84,45 @@ static const struct proto_ops macvtap_so
> =A0static DEFINE_SPINLOCK(macvtap_lock);
>
> =A0/*
> - * Choose the next free queue, for now there is only one
> + * get_slot: return a [unused/occupied] slot in vlan->taps[]:
> + * =A0 =A0 - if 'q' is NULL, return the first empty slot;
> + * =A0 =A0 - otherwise, return the slot this pointer occupies.
> =A0*/
> +static int get_slot(struct macvlan_dev *vlan, struct macvtap_queue *=
q)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < MAX_MACVTAP_QUEUES; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rcu_dereference(vlan->taps[i]) =3D=3D=
 q)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return i;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Should never happen */
> + =A0 =A0 =A0 BUG_ON(1);
> +}
> +
> =A0static int macvtap_set_queue(struct net_device *dev, struct file *=
file,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 macvtap_queue *q)
> =A0{
> =A0 =A0 =A0 =A0struct macvlan_dev *vlan =3D netdev_priv(dev);
> + =A0 =A0 =A0 int index;
> =A0 =A0 =A0 =A0int err =3D -EBUSY;
>
> =A0 =A0 =A0 =A0spin_lock(&macvtap_lock);
> - =A0 =A0 =A0 if (rcu_dereference(vlan->tap))
> + =A0 =A0 =A0 if (vlan->numvtaps =3D=3D MAX_MACVTAP_QUEUES)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0err =3D 0;
> + =A0 =A0 =A0 index =3D get_slot(vlan, NULL);
> =A0 =A0 =A0 =A0rcu_assign_pointer(q->vlan, vlan);
> - =A0 =A0 =A0 rcu_assign_pointer(vlan->tap, q);
> + =A0 =A0 =A0 rcu_assign_pointer(vlan->taps[index], q);
> =A0 =A0 =A0 =A0sock_hold(&q->sk);
>
> =A0 =A0 =A0 =A0q->file =3D file;
> =A0 =A0 =A0 =A0file->private_data =3D q;
>
> + =A0 =A0 =A0 vlan->numvtaps++;
> +
> =A0out:
> =A0 =A0 =A0 =A0spin_unlock(&macvtap_lock);
> =A0 =A0 =A0 =A0return err;
> @@ -124,9 +143,12 @@ static void macvtap_put_queue(struct mac
> =A0 =A0 =A0 =A0spin_lock(&macvtap_lock);
> =A0 =A0 =A0 =A0vlan =3D rcu_dereference(q->vlan);
> =A0 =A0 =A0 =A0if (vlan) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(vlan->tap, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int index =3D get_slot(vlan, q);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(vlan->taps[index], N=
ULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_assign_pointer(q->vlan, NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock_put(&q->sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 --vlan->numvtaps;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0spin_unlock(&macvtap_lock);
> @@ -136,39 +158,72 @@ static void macvtap_put_queue(struct mac
> =A0}
>
> =A0/*
> - * Since we only support one queue, just dereference the pointer.
> + * Select a queue based on the rxq of the device on which this packe=
t
> + * arrived. If the incoming device is not mq, calculate a flow hash =
to
> + * select a queue. vlan->numvtaps is cached in case it reduces durin=
g
> + * the execution of this function.
> =A0*/
> =A0static struct macvtap_queue *macvtap_get_queue(struct net_device *=
dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0struct macvlan_dev *vlan =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct macvtap_queue *tap =3D NULL;
> + =A0 =A0 =A0 int numvtaps =3D vlan->numvtaps;
> + =A0 =A0 =A0 __u32 rxq;
> +
> + =A0 =A0 =A0 if (!numvtaps)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 if (likely(skb_rx_queue_recorded(skb))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq =3D skb_get_rx_queue(skb);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (unlikely(rxq >=3D numvtaps))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq -=3D numvtaps;
>
> - =A0 =A0 =A0 return rcu_dereference(vlan->tap);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tap =3D rcu_dereference(vlan->taps[rxq]=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tap)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 rxq =3D skb_get_rxhash(skb);
> + =A0 =A0 =A0 if (!rxq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq =3D smp_processor_id();
> +
> + =A0 =A0 =A0 tap =3D rcu_dereference(vlan->taps[rxq & (numvtaps - 1)=
]);
> +

numvtaps maybe not power of 2. So some queue maybe can't be used.
You'd better maintain a online queue map and get the index as
get_rps_cpu() dones.

((u64)rxhash * numvtaps) >> 32

for the sbks, we can't get a valid rxhash, we'd better pass them to a
specified queue, such as queue 0.

> +out:
> + =A0 =A0 =A0 return tap;
> =A0}
>
> =A0/*
> =A0* The net_device is going away, give up the reference
> - * that it holds on the queue (all the queues one day)
> - * and safely set the pointer from the queues to NULL.
> + * that it holds on all queues and safely set the pointer
> + * from the queues to NULL.
> =A0*/
> =A0static void macvtap_del_queues(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct macvlan_dev *vlan =3D netdev_priv(dev);
> - =A0 =A0 =A0 struct macvtap_queue *q;
> + =A0 =A0 =A0 struct macvtap_queue *q, *qlist[MAX_MACVTAP_QUEUES];
> + =A0 =A0 =A0 int i, j =3D 0;
>
> + =A0 =A0 =A0 /* macvtap_put_queue can free some slots, so go through=
 all slots */
> =A0 =A0 =A0 =A0spin_lock(&macvtap_lock);
> - =A0 =A0 =A0 q =3D rcu_dereference(vlan->tap);
> - =A0 =A0 =A0 if (!q) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&macvtap_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 for (i =3D 0; i < MAX_MACVTAP_QUEUES && vlan->numvtaps;=
 i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q =3D rcu_dereference(vlan->taps[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (q) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qlist[j++] =3D q;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(vlan=
->taps[i], NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(q->v=
lan, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan->numvtaps--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
> -
> - =A0 =A0 =A0 rcu_assign_pointer(vlan->tap, NULL);
> - =A0 =A0 =A0 rcu_assign_pointer(q->vlan, NULL);
> + =A0 =A0 =A0 BUG_ON(vlan->numvtaps !=3D 0);
> =A0 =A0 =A0 =A0spin_unlock(&macvtap_lock);
>
> =A0 =A0 =A0 =A0synchronize_rcu();
> - =A0 =A0 =A0 sock_put(&q->sk);
> +
> + =A0 =A0 =A0 for (--j; j >=3D 0; j--)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_put(&qlist[j]->sk);
> =A0}
>
> =A0/*
> diff -ruNp org/include/linux/if_macvlan.h new/include/linux/if_macvla=
n.h
> --- org/include/linux/if_macvlan.h =A0 =A0 =A02010-07-28 15:10:10.000=
000000 +0530
> +++ new/include/linux/if_macvlan.h =A0 =A0 =A02010-08-04 16:19:32.000=
000000 +0530
> @@ -40,6 +40,12 @@ struct macvlan_rx_stats {
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 rx_errors;
> =A0};
>
> +/*
> + * Maximum times a macvtap device can be opened. This can be used to
> + * configure the number of receive queue, e.g. for multiqueue virtio=
=2E
> + */
> +#define MAX_MACVTAP_QUEUES =A0 =A0 (NR_CPUS < 16 ? NR_CPUS : 16)
> +
> =A0struct macvlan_dev {
> =A0 =A0 =A0 =A0struct net_device =A0 =A0 =A0 *dev;
> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0list;
> @@ -50,7 +56,8 @@ struct macvlan_dev {
> =A0 =A0 =A0 =A0enum macvlan_mode =A0 =A0 =A0 mode;
> =A0 =A0 =A0 =A0int (*receive)(struct sk_buff *skb);
> =A0 =A0 =A0 =A0int (*forward)(struct net_device *dev, struct sk_buff =
*skb);
> - =A0 =A0 =A0 struct macvtap_queue =A0 =A0*tap;
> + =A0 =A0 =A0 struct macvtap_queue =A0 =A0*taps[MAX_MACVTAP_QUEUES];
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 numvtaps;
> =A0};
>
> =A0static inline void macvlan_count_rx(const struct macvlan_dev *vlan=
,
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
