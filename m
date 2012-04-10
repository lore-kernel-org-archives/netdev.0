From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 10 Apr 2012 09:55:58 +0200
Message-ID: <1334044558.3126.5.camel@edumazet-glaptop>
References: <20120408171323.GA16012@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120408171323.GA16012@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-08 at 20:13 +0300, Michael S. Tsirkin wrote:
> commit 0110d6f22f392f976e84ab49da1b42f85b64a3c5
> tun: orphan an skb on tx
> Fixed a configuration where skbs get queued
> at the tun device forever, blocking senders.
> 
> However this fix isn't waterproof:
> userspace can control whether the interface
> is stopped, and if it is, packets
> get queued in the qdisc, again potentially forever.
> 
> Complete the fix by setting a private flag and orphaning
> at the qdisc level.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/tun.c       |    3 +++
>  include/linux/if.h      |    1 +
>  net/core/dev.c          |    5 +++++
>  net/sched/sch_generic.c |    5 +++++
>  4 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index bb8c72c..15c5bb8 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -535,6 +535,9 @@ static void tun_net_init(struct net_device *dev)
>  		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
>  		break;
>  	}
> +	/* Once queue becomes full, we stop tx until userspace
> +	 * dequeues some packets, that is potentially forever. */
> +	dev->priv_flags |= IFF_TX_CAN_STALL;
>  }
>  
>  /* Character device part */
> diff --git a/include/linux/if.h b/include/linux/if.h
> index f995c66..dd2c7f7 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -81,6 +81,7 @@
>  #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
>  #define IFF_TEAM_PORT	0x40000		/* device used as team port */
>  #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
> +#define IFF_TX_CAN_STALL 0x100000	/* Device can stop tx forever */
>  
> 
>  #define IF_GET_IFACE	0x0001		/* for querying only */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5d59155..e812706 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2516,6 +2516,11 @@ int dev_queue_xmit(struct sk_buff *skb)
>  	struct Qdisc *q;
>  	int rc = -ENOMEM;
>  
> +	/* Orphan the skb - required if we might hang on to it
> +	 * for indefinite time. */
> +	if (dev->priv_flags & IFF_TX_CAN_STALL)
> +		skb_orphan(skb);
> +
>  	/* Disable soft irqs for various locks below. Also
>  	 * stops preemption for RCU.
>  	 */
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 67fc573..27883d1 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -120,6 +120,11 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>  	/* And release qdisc */
>  	spin_unlock(root_lock);
>  
> +	/* Orphan the skb - required if we might hang on to it
> +	 * for indefinite time. */
> +	if (dev->priv_flags & IFF_TX_CAN_STALL)
> +		skb_orphan(skb);
> +
>  	HARD_TX_LOCK(dev, txq, smp_processor_id());
>  	if (!netif_xmit_frozen_or_stopped(txq))
>  		ret = dev_hard_start_xmit(skb, dev, txq);

This slows down the core fastpath for a very specific use.

In your case I would just not use qdisc at all, like other virtual
devices.

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bb8c72c..fd8c7f0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -396,7 +396,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	    sk_filter(tun->socket.sk, skb))
 		goto drop;
 
-	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
+	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= TUN_READQ_SIZE) {
 		if (!(tun->flags & TUN_ONE_QUEUE)) {
 			/* Normal queueing mode. */
 			/* Packet scheduler handles dropping of further packets. */
@@ -521,7 +521,7 @@ static void tun_net_init(struct net_device *dev)
 		/* Zero header length */
 		dev->type = ARPHRD_NONE;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
-		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
+		dev->tx_queue_len = 0;
 		break;
 
 	case TUN_TAP_DEV:
@@ -532,7 +532,7 @@ static void tun_net_init(struct net_device *dev)
 
 		eth_hw_addr_random(dev);
 
-		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
+		dev->tx_queue_len = 0;
 		break;
 	}
 }
