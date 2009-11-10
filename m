From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 10:07:57 +0100
Message-ID: <4AF92D6D.8060300@gmail.com>
References: <4AF924A5.1050303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54733 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbZKJJIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 04:08:00 -0500
In-Reply-To: <4AF924A5.1050303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> ifb: add multi-queue support
>=20
> Add multi-queue support, and one kernel thread is created for per que=
ue.
> It can used to emulate multi-queue NIC in software, and distribute wo=
rk
> among CPUs.
> gentux linux # modprobe ifb numtxqs=3D2
> gentux linux # ifconfig ifb0 up
> gentux linux # pgrep ifb0
> 18508
> 18509
> gentux linux # taskset -p 1 18508
> pid 18508's current affinity mask: 3
> pid 18508's new affinity mask: 1
> gentux linux # taskset -p 2 18509
> pid 18509's current affinity mask: 3
> pid 18509's new affinity mask: 2
> gentux linux # tc qdisc add dev br0 ingress
> gentux linux # tc filter add dev br0 parent ffff: protocol ip basic
> action mirred egress redirect dev ifb0

Seems pretty cool !

I have some comments=20

>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> drivers/net/ifb.c | 309
> ++++++++++++++++++++++++++++++++----------------------
> 1 file changed, 186 insertions(+), 123 deletions(-)
>=20
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 030913f..6e04188 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -33,139 +33,101 @@
>  #include <linux/etherdevice.h>
>  #include <linux/init.h>
>  #include <linux/moduleparam.h>
> +#include <linux/wait.h>
> +#include <linux/sched.h>
> +#include <linux/kthread.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <net/ip.h>
>  #include <net/pkt_sched.h>
>  #include <net/net_namespace.h>
> =20
> -#define TX_TIMEOUT  (2*HZ)
> -
>  #define TX_Q_LIMIT    32
> +
>  struct ifb_private {
> -	struct tasklet_struct   ifb_tasklet;
> -	int     tasklet_pending;
> -	/* mostly debug stats leave in for now */
> -	unsigned long   st_task_enter; /* tasklet entered */
> -	unsigned long   st_txq_refl_try; /* transmit queue refill attempt *=
/
> -	unsigned long   st_rxq_enter; /* receive queue entered */
> -	unsigned long   st_rx2tx_tran; /* receive to trasmit transfers */
> -	unsigned long   st_rxq_notenter; /*receiveQ not entered, resched */
> -	unsigned long   st_rx_frm_egr; /* received from egress path */
> -	unsigned long   st_rx_frm_ing; /* received from ingress path */
> -	unsigned long   st_rxq_check;
> -	unsigned long   st_rxq_rsch;
> -	struct sk_buff_head     rq;
> -	struct sk_buff_head     tq;
> +	struct net_device	*dev;
> +	struct sk_buff_head	rq;
> +	struct sk_buff_head	tq;
> +	wait_queue_head_t	wq;
> +	struct task_struct	*task;
>  };

Maybe you should allocate true per_cpu structure, to avoid cache line s=
haring
and get appropriate NUMA properties.

At least use a __cacheline_aligned_in_smp ...

> =20
> +/* Number of ifb devices to be set up by this module. */
>  static int numifbs =3D 2;
> +module_param(numifbs, int, 0444);
> +MODULE_PARM_DESC(numifbs, "Number of ifb devices");
> =20
> -static void ri_tasklet(unsigned long dev);
> -static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *=
dev);
> -static int ifb_open(struct net_device *dev);
> -static int ifb_close(struct net_device *dev);
> +/* Number of TX queues per ifb */
> +static int numtxqs =3D 1;
> +module_param(numtxqs, int, 0444);
> +MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");
> =20
> -static void ri_tasklet(unsigned long dev)
> +static int ifb_thread(void *priv)
>  {
> -
> -	struct net_device *_dev =3D (struct net_device *)dev;
> -	struct ifb_private *dp =3D netdev_priv(_dev);
> -	struct net_device_stats *stats =3D &_dev->stats;
> -	struct netdev_queue *txq;

> +	struct ifb_private *dp =3D (struct ifb_private*)priv;

A space is required before * : (struct ifb_private *)priv;
(in many places in your patch)

> +	struct net_device *dev =3D dp->dev;


> +	struct net_device_stats *stats =3D &dev->stats;

Here you use a net_device_stats that is shared by all your queues,
your updates wont be protected and some will be lost.
You should use txq->tx_ counters.

> +	unsigned int num =3D dp - (struct ifb_private*)netdev_priv(dev);
> +	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, num);
>  	struct sk_buff *skb;
> -
> -	txq =3D netdev_get_tx_queue(_dev, 0);
> -	dp->st_task_enter++;
> -	if ((skb =3D skb_peek(&dp->tq)) =3D=3D NULL) {
> -		dp->st_txq_refl_try++;
> -		if (__netif_tx_trylock(txq)) {
> -			dp->st_rxq_enter++;
> -			while ((skb =3D skb_dequeue(&dp->rq)) !=3D NULL) {
> +	DEFINE_WAIT(wait);
> +
> +	while (1) {
> +		/* move skb from rq to tq */
> +		while (1) {
> +			prepare_to_wait(&dp->wq, &wait, TASK_UNINTERRUPTIBLE);
> +			while (!__netif_tx_trylock(txq))
> +				yield();
> +			while ((skb =3D skb_dequeue(&dp->rq)) !=3D NULL)
>  				skb_queue_tail(&dp->tq, skb);
> -				dp->st_rx2tx_tran++;
> -			}
> +			if (netif_queue_stopped(dev))
> +				netif_wake_queue(dev);
>  			__netif_tx_unlock(txq);
> -		} else {
> -			/* reschedule */
> -			dp->st_rxq_notenter++;
> -			goto resched;
> +			if (kthread_should_stop() || !skb_queue_empty(&dp->tq))
> +				break;
> +			schedule();
>  		}
> -	}
> -
> -	while ((skb =3D skb_dequeue(&dp->tq)) !=3D NULL) {
> -		u32 from =3D G_TC_FROM(skb->tc_verd);
> -
> -		skb->tc_verd =3D 0;
> -		skb->tc_verd =3D SET_TC_NCLS(skb->tc_verd);
> -		stats->tx_packets++;
> -		stats->tx_bytes +=3Dskb->len;
> -
> -		skb->dev =3D dev_get_by_index(&init_net, skb->iif);
> -		if (!skb->dev) {
> -			dev_kfree_skb(skb);
> -			stats->tx_dropped++;
> +		finish_wait(&dp->wq, &wait);
> +		if (kthread_should_stop())
>  			break;
> -		}
> -		dev_put(skb->dev);
> -		skb->iif =3D _dev->ifindex;
> -
> -		if (from & AT_EGRESS) {
> -			dp->st_rx_frm_egr++;
> -			dev_queue_xmit(skb);
> -		} else if (from & AT_INGRESS) {
> -			dp->st_rx_frm_ing++;
> -			skb_pull(skb, skb->dev->hard_header_len);
> -			netif_rx(skb);
> -		} else
> -			BUG();
> -	}
> =20
> -	if (__netif_tx_trylock(txq)) {
> -		dp->st_rxq_check++;
> -		if ((skb =3D skb_peek(&dp->rq)) =3D=3D NULL) {
> -			dp->tasklet_pending =3D 0;
> -			if (netif_queue_stopped(_dev))
> -				netif_wake_queue(_dev);
> -		} else {
> -			dp->st_rxq_rsch++;
> -			__netif_tx_unlock(txq);
> -			goto resched;
> +		/* transfer packets */
> +		while ((skb =3D skb_dequeue(&dp->tq)) !=3D NULL) {
> +			u32 from =3D G_TC_FROM(skb->tc_verd);
> +=09
> +			skb->tc_verd =3D 0;
> +			skb->tc_verd =3D SET_TC_NCLS(skb->tc_verd);

> +			stats->tx_packets++;
> +			stats->tx_bytes +=3Dskb->len;

Use :			txq->tx_packets++
			txq->tx_bytes +=3D skb->len;
> +=09
> +			skb->dev =3D dev_get_by_index(&init_net, skb->iif);
> +			if (!skb->dev) {
> +				dev_kfree_skb(skb);

> +				stats->tx_dropped++;
			txq->tx_dropped ?

> +				break;
> +			}
> +			dev_put(skb->dev);
> +			skb->iif =3D dev->ifindex;
> +=09
> +			if (from & AT_EGRESS) {
> +				dev_queue_xmit(skb);
> +			} else if (from & AT_INGRESS) {
> +				skb_pull(skb, skb->dev->hard_header_len);
> +				netif_rx_ni(skb);
> +			} else
> +				BUG();
>  		}
> -		__netif_tx_unlock(txq);
> -	} else {
> -resched:
> -		dp->tasklet_pending =3D 1;
> -		tasklet_schedule(&dp->ifb_tasklet);
>  	}
> =20
> -}
> -
> -static const struct net_device_ops ifb_netdev_ops =3D {
> -	.ndo_open	=3D ifb_open,
> -	.ndo_stop	=3D ifb_close,
> -	.ndo_start_xmit	=3D ifb_xmit,
> -	.ndo_validate_addr =3D eth_validate_addr,
> -};
> -
> -static void ifb_setup(struct net_device *dev)
> -{
> -	/* Initialize the device structure. */
> -	dev->destructor =3D free_netdev;
> -	dev->netdev_ops =3D &ifb_netdev_ops;
> -
> -	/* Fill in device structure with ethernet-generic values. */
> -	ether_setup(dev);
> -	dev->tx_queue_len =3D TX_Q_LIMIT;
> -
> -	dev->flags |=3D IFF_NOARP;
> -	dev->flags &=3D ~IFF_MULTICAST;
> -	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
> -	random_ether_addr(dev->dev_addr);
> +	return 0;
>  }
> =20
>  static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *=
dev)
>  {
> -	struct ifb_private *dp =3D netdev_priv(dev);
>  	struct net_device_stats *stats =3D &dev->stats;
>  	u32 from =3D G_TC_FROM(skb->tc_verd);
> +	int num =3D skb_get_queue_mapping(skb);
> +	struct ifb_private *dp =3D ((struct ifb_private*)netdev_priv(dev)) =
+ num;
> =20

>  	stats->rx_packets++;
>  	stats->rx_bytes+=3Dskb->len;

Not sure how to solve this problem (several cpus can updates counter in=
 //)

Thanks
