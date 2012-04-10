From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 10 Apr 2012 11:41:51 +0300
Message-ID: <20120410084151.GA27193@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <1334044558.3126.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334044558.3126.5.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 09:55:58AM +0200, Eric Dumazet wrote:
> On Sun, 2012-04-08 at 20:13 +0300, Michael S. Tsirkin wrote:
> > commit 0110d6f22f392f976e84ab49da1b42f85b64a3c5
> > tun: orphan an skb on tx
> > Fixed a configuration where skbs get queued
> > at the tun device forever, blocking senders.
> > 
> > However this fix isn't waterproof:
> > userspace can control whether the interface
> > is stopped, and if it is, packets
> > get queued in the qdisc, again potentially forever.
> > 
> > Complete the fix by setting a private flag and orphaning
> > at the qdisc level.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/net/tun.c       |    3 +++
> >  include/linux/if.h      |    1 +
> >  net/core/dev.c          |    5 +++++
> >  net/sched/sch_generic.c |    5 +++++
> >  4 files changed, 14 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index bb8c72c..15c5bb8 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -535,6 +535,9 @@ static void tun_net_init(struct net_device *dev)
> >  		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
> >  		break;
> >  	}
> > +	/* Once queue becomes full, we stop tx until userspace
> > +	 * dequeues some packets, that is potentially forever. */
> > +	dev->priv_flags |= IFF_TX_CAN_STALL;
> >  }
> >  
> >  /* Character device part */
> > diff --git a/include/linux/if.h b/include/linux/if.h
> > index f995c66..dd2c7f7 100644
> > --- a/include/linux/if.h
> > +++ b/include/linux/if.h
> > @@ -81,6 +81,7 @@
> >  #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
> >  #define IFF_TEAM_PORT	0x40000		/* device used as team port */
> >  #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
> > +#define IFF_TX_CAN_STALL 0x100000	/* Device can stop tx forever */
> >  
> > 
> >  #define IF_GET_IFACE	0x0001		/* for querying only */
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 5d59155..e812706 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2516,6 +2516,11 @@ int dev_queue_xmit(struct sk_buff *skb)
> >  	struct Qdisc *q;
> >  	int rc = -ENOMEM;
> >  
> > +	/* Orphan the skb - required if we might hang on to it
> > +	 * for indefinite time. */
> > +	if (dev->priv_flags & IFF_TX_CAN_STALL)
> > +		skb_orphan(skb);
> > +
> >  	/* Disable soft irqs for various locks below. Also
> >  	 * stops preemption for RCU.
> >  	 */
> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> > index 67fc573..27883d1 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -120,6 +120,11 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
> >  	/* And release qdisc */
> >  	spin_unlock(root_lock);
> >  
> > +	/* Orphan the skb - required if we might hang on to it
> > +	 * for indefinite time. */
> > +	if (dev->priv_flags & IFF_TX_CAN_STALL)
> > +		skb_orphan(skb);
> > +
> >  	HARD_TX_LOCK(dev, txq, smp_processor_id());
> >  	if (!netif_xmit_frozen_or_stopped(txq))
> >  		ret = dev_hard_start_xmit(skb, dev, txq);
> 
> This slows down the core fastpath for a very specific use.

You are right.
I presume the fastpath is when the device is *not* stalled,
correct? So maybe it's ok to add this logic on slow path
where the queue is stopped and we queue the packet?
When the queue is running tun can orphan the skb itself.

This is what the change at the bottom of this mail on top of my
patch does - untested yet and naturally needs to be combined
and resubmitted properly, assuming it makes sense.

Would this, in your opinion, address this concern adequately?
Thanks!

> In your case I would just not use qdisc at all, like other virtual
> devices.

I think that if we do this, this also disables gso
for the device, doesn't it?
If true that would be a problem as this would
hurt performance of virtualized setups a lot.

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index bb8c72c..fd8c7f0 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -396,7 +396,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	    sk_filter(tun->socket.sk, skb))
>  		goto drop;
>  
> -	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
> +	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= TUN_READQ_SIZE) {
>  		if (!(tun->flags & TUN_ONE_QUEUE)) {
>  			/* Normal queueing mode. */
>  			/* Packet scheduler handles dropping of further packets. */

tx_queue_len is controllable by SIOCSIFTXQLEN
so we'll need to override SIOCSIFTXQLEN somehow
to avoid breaking userspace that actually uses SIOCSIFTXQLEN, right?

> @@ -521,7 +521,7 @@ static void tun_net_init(struct net_device *dev)
>  		/* Zero header length */
>  		dev->type = ARPHRD_NONE;
>  		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
> -		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
> +		dev->tx_queue_len = 0;
>  		break;
>  
>  	case TUN_TAP_DEV:
> @@ -532,7 +532,7 @@ static void tun_net_init(struct net_device *dev)
>  
>  		eth_hw_addr_random(dev);
>  
> -		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
> +		dev->tx_queue_len = 0;
>  		break;
>  	}
>  }
> 

I presume the fastpath is when the device is *not* stalled,
correct? So maybe the following on top of my patch - untested
and naturally would need to be combined and resubmitted properly -
would address the concern?
Thanks for the review!


diff --git a/net/core/dev.c b/net/core/dev.c
index 9d713b8..e42529b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2455,6 +2455,11 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		rc = NET_XMIT_SUCCESS;
 	} else {
 		skb_dst_force(skb);
+		/* Orphan the skb - required if we might hang on to it
+		 * for indefinite time. */
+		if (unlikely(dev->priv_flags & IFF_TX_CAN_STALL))
+			skb_orphan(skb);
+
 		rc = q->enqueue(skb, q) & NET_XMIT_MASK;
 		if (qdisc_run_begin(q)) {
 			if (unlikely(contended)) {
@@ -2517,11 +2522,6 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
-	/* Orphan the skb - required if we might hang on to it
-	 * for indefinite time. */
-	if (dev->priv_flags & IFF_TX_CAN_STALL)
-		skb_orphan(skb);
-
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 27883d1..ccc6137 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -120,14 +120,11 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	/* And release qdisc */
 	spin_unlock(root_lock);
 
-	/* Orphan the skb - required if we might hang on to it
-	 * for indefinite time. */
-	if (dev->priv_flags & IFF_TX_CAN_STALL)
-		skb_orphan(skb);
-
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_xmit_frozen_or_stopped(txq))
+	if (likely(!netif_xmit_frozen_or_stopped(txq)))
 		ret = dev_hard_start_xmit(skb, dev, txq);
+	else if (dev->priv_flags & IFF_TX_CAN_STALL)
+		skb_orphan(skb);
 
 	HARD_TX_UNLOCK(dev, txq);
 
