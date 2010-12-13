From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 4/5] ifb: add multiqueue support
Date: Tue, 14 Dec 2010 07:42:37 +0800
Message-ID: <AANLkTim=9JfQQ__Pii0c8XUvYFSLmj_gtK77twJ9iAbR@mail.gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
 <1292251414-5154-4-git-send-email-xiaosuo@gmail.com> <1292257573.2759.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:59023 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755602Ab0LMXm7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 18:42:59 -0500
Received: by fxm18 with SMTP id 18so53632fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:42:57 -0800 (PST)
In-Reply-To: <1292257573.2759.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 12:26 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 13 d=E9cembre 2010 =E0 22:43 +0800, Changli Gao a =E9crit :
>> Each ifb NIC has nr_cpu_ids rx queues and nr_cpu_ids queues. Packets
>> transmitted to ifb are enqueued to the corresponding per cpu tx queu=
es,
>> and processed in the corresponding per cpu tasklet latter.
>>
>> The stats are converted to the u64 ones.
>>
>> tq is a stack variable now. It makes ifb_q_private smaller and tx qu=
eue
>> locked only once in ri_tasklet.
>>
>
> Might be good to say the tx_queue_len is multiplied by number of onli=
ne
> cpus ;)

Thanks for completion.

>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0drivers/net/ifb.c | =A0211 ++++++++++++++++++++++++++++++++++++--=
----------------
>> =A01 file changed, 141 insertions(+), 70 deletions(-)
>> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
>> index 57c5cfb..16c767b 100644
>> --- a/drivers/net/ifb.c
>> +++ b/drivers/net/ifb.c
>> @@ -37,56 +37,63 @@
>> =A0#include <net/net_namespace.h>
>>
>> =A0#define TX_Q_LIMIT =A0 =A032
>> +struct ifb_q_private {
>> + =A0 =A0 struct tasklet_struct =A0 ifb_tasklet;
>> + =A0 =A0 struct sk_buff_head =A0 =A0 rq;
>> + =A0 =A0 struct u64_stats_sync =A0 syncp;
>> + =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_packets;
>> + =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_bytes;
>> + =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_dropped;
>> +};
>> +
>> =A0struct ifb_private {
>> - =A0 =A0 struct tasklet_struct =A0 ifb_tasklet;
>> - =A0 =A0 int =A0 =A0 tasklet_pending;
>> - =A0 =A0 struct sk_buff_head =A0 =A0 rq;
>> - =A0 =A0 struct sk_buff_head =A0 =A0 tq;
>> + =A0 =A0 struct ifb_q_private __percpu =A0 *q;
>
> You probably could use dev->ml_priv (lstats/tstats/dstats)
> so that ifb_private just disapears (we save a full cache line)

Good idea. Thanks.

>
>> =A0};
>>
>> =A0static int numifbs =3D 2;
>>
>> -static void ri_tasklet(unsigned long dev)
>> +static void ri_tasklet(unsigned long _dev)
>> =A0{
>> -
>> - =A0 =A0 struct net_device *_dev =3D (struct net_device *)dev;
>> - =A0 =A0 struct ifb_private *dp =3D netdev_priv(_dev);
>> - =A0 =A0 struct net_device_stats *stats =3D &_dev->stats;
>> + =A0 =A0 struct net_device *dev =3D (struct net_device *)_dev;
>> + =A0 =A0 struct ifb_private *p =3D netdev_priv(dev);
>> + =A0 =A0 struct ifb_q_private *qp;
>> =A0 =A0 =A0 struct netdev_queue *txq;
>> =A0 =A0 =A0 struct sk_buff *skb;
>> -
>> - =A0 =A0 txq =3D netdev_get_tx_queue(_dev, 0);
>> - =A0 =A0 skb =3D skb_peek(&dp->tq);
>> - =A0 =A0 if (skb =3D=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (__netif_tx_trylock(txq)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_splice_tail_init=
(&dp->rq, &dp->tq);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __netif_tx_unlock(txq);
>> - =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* reschedule */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto resched;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 struct sk_buff_head tq;
>> +
>> + =A0 =A0 __skb_queue_head_init(&tq);
>> + =A0 =A0 txq =3D netdev_get_tx_queue(dev, raw_smp_processor_id());
>> + =A0 =A0 qp =3D per_cpu_ptr(p->q, raw_smp_processor_id());
>
> =A0 =A0 =A0 =A0qp =3D this_cpu_ptr(dev->ifb_qp); is faster

and less, thanks. :)

>
>> + =A0 =A0 if (!__netif_tx_trylock(txq)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule(&qp->ifb_tasklet);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 }
>> + =A0 =A0 skb_queue_splice_tail_init(&qp->rq, &tq);
>> + =A0 =A0 if (netif_tx_queue_stopped(txq))
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_tx_wake_queue(txq);
>> + =A0 =A0 __netif_tx_unlock(txq);
>>
>> - =A0 =A0 while ((skb =3D skb_dequeue(&dp->tq)) !=3D NULL) {
>> + =A0 =A0 while ((skb =3D __skb_dequeue(&tq)) !=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 from =3D G_TC_FROM(skb->tc_verd);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->tc_verd =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->tc_verd =3D SET_TC_NCLS(skb->tc_ver=
d);
>> - =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_packets++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_bytes +=3D skb->len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_begin(&qp->syncp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 txq->tx_packets++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 txq->tx_bytes +=3D skb->len;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D dev_get_by_index_rcu(&init_=
net, skb->skb_iif);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb->dev) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 txq->tx_dropped++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&qp->=
syncp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_dropped++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_queue_len(&dp->tq)=
 !=3D 0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto resch=
ed;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> - =A0 =A0 =A0 =A0 =A0 =A0 skb->skb_iif =3D _dev->ifindex;
>> + =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&qp->syncp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb->skb_iif =3D dev->ifindex;
>
> Why is this necessary ? shouldnt skb->skb_iif already be dev->ifindex=
 ?

No. In fact, act_mirred use skb_iff to save the original dev.

        skb2->skb_iif =3D skb->dev->ifindex;
        skb2->dev =3D dev;

>
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (from & AT_EGRESS) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_queue_xmit(skb);
>> @@ -96,48 +103,32 @@ static void ri_tasklet(unsigned long dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> =A0 =A0 =A0 }
>> -
>> - =A0 =A0 if (__netif_tx_trylock(txq)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 skb =3D skb_peek(&dp->rq);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dp->tasklet_pending =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_queue_stopped(_d=
ev))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake=
_queue(_dev);
>> - =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __netif_tx_unlock(txq);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto resched;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 __netif_tx_unlock(txq);
>> - =A0 =A0 } else {
>> -resched:
>> - =A0 =A0 =A0 =A0 =A0 =A0 dp->tasklet_pending =3D 1;
>> - =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule(&dp->ifb_tasklet);
>> - =A0 =A0 }
>> -
>> =A0}
>>
>> =A0static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_devic=
e *dev)
>> =A0{
>> - =A0 =A0 struct ifb_private *dp =3D netdev_priv(dev);
>> - =A0 =A0 struct net_device_stats *stats =3D &dev->stats;
>> + =A0 =A0 struct ifb_private *p =3D netdev_priv(dev);
>> + =A0 =A0 struct ifb_q_private *qp =3D per_cpu_ptr(p->q,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0skb_get_queue_mapping(skb));
>
> Would be good to add a
>
> WARN_ON(skb_get_queue_mapping(skb) !=3D smp_processor_id());

I think it maybe what Jamal wants too. Thanks.

>
>
>> =A0 =A0 =A0 u32 from =3D G_TC_FROM(skb->tc_verd);
>>
>> - =A0 =A0 stats->rx_packets++;
>> - =A0 =A0 stats->rx_bytes +=3D skb->len;
>> + =A0 =A0 u64_stats_update_begin(&qp->syncp);
>> + =A0 =A0 qp->rx_packets++;
>> + =A0 =A0 qp->rx_bytes +=3D skb->len;
>>
>> =A0 =A0 =A0 if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 qp->rx_dropped++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&qp->syncp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> - =A0 =A0 =A0 =A0 =A0 =A0 stats->rx_dropped++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_OK;
>> =A0 =A0 =A0 }
>> + =A0 =A0 u64_stats_update_end(&qp->syncp);
>>
>> - =A0 =A0 __skb_queue_tail(&dp->rq, skb);
>> - =A0 =A0 if (!dp->tasklet_pending) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 dp->tasklet_pending =3D 1;
>> - =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule(&dp->ifb_tasklet);
>> - =A0 =A0 }
>> + =A0 =A0 __skb_queue_tail(&qp->rq, skb);
>> + =A0 =A0 if (skb_queue_len(&qp->rq) =3D=3D 1)
>> + =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule(&qp->ifb_tasklet);
>>
>> - =A0 =A0 if (skb_queue_len(&dp->rq) >=3D dev->tx_queue_len)
>> + =A0 =A0 if (skb_queue_len(&qp->rq) >=3D dev->tx_queue_len)
>
> This seems wrong...
> You need to change to netif_tx_stop_queue(txq)

Thanks for catching this. I missed it.

>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(dev);
>>
>> =A0 =A0 =A0 return NETDEV_TX_OK;
>> @@ -145,33 +136,103 @@ static netdev_tx_t ifb_xmit(struct sk_buff *s=
kb, struct net_device *dev)
>>
>> =A0static int ifb_close(struct net_device *dev)
>> =A0{
>> - =A0 =A0 struct ifb_private *dp =3D netdev_priv(dev);
>> -
>> - =A0 =A0 tasklet_kill(&dp->ifb_tasklet);
>> - =A0 =A0 netif_stop_queue(dev);
>> - =A0 =A0 __skb_queue_purge(&dp->rq);
>> - =A0 =A0 __skb_queue_purge(&dp->tq);
>> + =A0 =A0 struct ifb_private *p =3D netdev_priv(dev);
>> + =A0 =A0 struct ifb_q_private *qp;
>> + =A0 =A0 int cpu;
>> +
>> + =A0 =A0 for_each_possible_cpu(cpu) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 qp =3D per_cpu_ptr(p->q, cpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 tasklet_kill(&qp->ifb_tasklet);
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_tx_stop_queue(netdev_get_tx_queue(de=
v, cpu));
>> + =A0 =A0 =A0 =A0 =A0 =A0 __skb_queue_purge(&qp->rq);
>> + =A0 =A0 }
>>
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> =A0static int ifb_open(struct net_device *dev)
>> =A0{
>> - =A0 =A0 struct ifb_private *dp =3D netdev_priv(dev);
>> + =A0 =A0 int cpu;
>> +
>
>
>
>> + =A0 =A0 for_each_possible_cpu(cpu)
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_tx_start_queue(netdev_get_tx_queue(d=
ev, cpu));
>> +
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static int ifb_init(struct net_device *dev)
>> +{
>> + =A0 =A0 struct ifb_private *p =3D netdev_priv(dev);
>> + =A0 =A0 struct ifb_q_private *q;
>> + =A0 =A0 int cpu;
>>
>> - =A0 =A0 tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)=
dev);
>> - =A0 =A0 __skb_queue_head_init(&dp->rq);
>> - =A0 =A0 __skb_queue_head_init(&dp->tq);
>> - =A0 =A0 netif_start_queue(dev);
>> + =A0 =A0 p->q =3D alloc_percpu(struct ifb_q_private);
>> + =A0 =A0 if (!p->q)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>
> Hmm, maybe =A0use netdev_queue_numa_node_write() somewhere, so that
> qdisc_alloc() can use NUMA affinities.

I'll add it, thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
