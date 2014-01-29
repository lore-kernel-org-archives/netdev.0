From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 11:55:48 -0800
Message-ID: <1391025348.28432.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E905C8.1060408@hartkopp.net>
		 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52E956E6.7090002@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52E956E6.7090002@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-01-29 at 20:30 +0100, Oliver Hartkopp wrote:
> 
> On 29.01.2014 16:47, Eric Dumazet wrote:
> > On Wed, 2014-01-29 at 07:30 -0800, Eric Dumazet wrote:
> >> On Wed, 2014-01-29 at 07:02 -0800, Eric Dumazet wrote:
> >>
> >>> Thats how every protocol does this, with variants.
> >>>
> >>> Check l2tp_sock_wfree()/l2tp_skb_set_owner_w() for an example
> >>
> >> Also keep in mind this patch is needed for all kernels, not only 3.11+
> >>
> >> So better keep it as simple as possible, to ease backports.
> > 
> > Please try the following patch.
> > 
> 
> Hello Eric,
> 
> there were at least two problems with your patch:
> 
> 1. Only the stuff in net/can was addressed (missing drivers/net/can)
> 
> 2. The check for sk and the additional skb_orphan() is not needed as the
> can_skb_set_owner() is invoked only after 'fresh' skb allocation or after
> clone/skb_orphan() - so we know the skb state very good.

Yep, but then you added skb_orphan() calls. when skb is not shared.

> 
> I moved your suggested inline functions to include/linux/can/skb.h where
> all users (net/can and drivers) can access them.
> 
> So what has been done:
> 
> - can_skb_set_owner() is invoked on new created skbuffs (tx path)
> - can_skb_set_owner() is invoked on orphaned/cloned skbs (echo in drvs)
> 
> I did some tests with real CAN hardware and everything seems fine.
> 
> Please take a look if it looks correct to you.
> 
> If so I'll send a proper patch for it.
> 
> Regards,
> Oliver
> 
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index 13a9098..17a0a00 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -325,17 +325,20 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
>  	if (!priv->echo_skb[idx]) {
>  		struct sock *srcsk = skb->sk;
>  

This is still buggy.

You should not consume_skb() before having 
a ref count on skb->sk.


> -		if (atomic_read(&skb->users) != 1) {
> -			struct sk_buff *old_skb = skb;
> +		if (skb_shared(skb)) {
> +			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
>  
> -			skb = skb_clone(old_skb, GFP_ATOMIC);
> -			kfree_skb(old_skb);
> -			if (!skb)
> +			if (likely(nskb))
> +				consume_skb(skb);
> +			else {
> +				kfree_skb(skb);
>  				return;
> +			}
> +			skb = nskb;
>  		} else
>  			skb_orphan(skb);
>  
> -		skb->sk = srcsk;
> +		can_skb_set_owner(skb, srcsk);

Only after this point you can do the :

consume_skb(original_skb);



>  
>  		/* make settings for echo to reduce code in irq context */
>  		skb->protocol = htons(ETH_P_CAN);
> diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
> index e24e669..ee48cb1 100644
> --- a/drivers/net/can/janz-ican3.c
> +++ b/drivers/net/can/janz-ican3.c
> @@ -18,6 +18,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/can.h>
>  #include <linux/can/dev.h>
> +#include <linux/can/skb.h>
>  #include <linux/can/error.h>
>  
>  #include <linux/mfd/janz.h>
> @@ -1135,18 +1136,20 @@ static void ican3_put_echo_skb(struct ican3_dev *mod, struct sk_buff *skb)
>  {
>  	struct sock *srcsk = skb->sk;
>  

Same problem here.

> -	if (atomic_read(&skb->users) != 1) {
> -		struct sk_buff *old_skb = skb;
> +	if (skb_shared(skb)) {
> +		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
>  
> -		skb = skb_clone(old_skb, GFP_ATOMIC);
> -		kfree_skb(old_skb);
> -		if (!skb)
> +		if (likely(nskb))
> +			consume_skb(skb);
> +		else {
> +			kfree_skb(skb);
>  			return;
> -	} else {
> +		}
> +		skb = nskb;
> +	} else
>  		skb_orphan(skb);
> -	}
>  
> -	skb->sk = srcsk;
> +	can_skb_set_owner(skb, srcsk);
>  
>  	/* save this skb for tx interrupt echo handling */
>  	skb_queue_tail(&mod->echoq, skb);
> diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
> index 0a2a5ee..f764f00 100644
> --- a/drivers/net/can/vcan.c
> +++ b/drivers/net/can/vcan.c
> @@ -46,6 +46,7 @@
>  #include <linux/if_ether.h>
>  #include <linux/can.h>
>  #include <linux/can/dev.h>
> +#include <linux/can/skb.h>
>  #include <linux/slab.h>
>  #include <net/rtnetlink.h>
>  
> @@ -118,12 +119,22 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
>  	if (loop) {
>  		struct sock *srcsk = skb->sk;
>  

Same problem

> -		skb = skb_share_check(skb, GFP_ATOMIC);
> -		if (!skb)
> -			return NETDEV_TX_OK;
> +		if (skb_shared(skb)) {
> +			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
> +
> +			if (likely(nskb))
> +				consume_skb(skb);
> +			else {
> +				kfree_skb(skb);
> +				return NETDEV_TX_OK;
> +			}
> +			skb = nskb;
> +		} else
> +			skb_orphan(skb);
> +
> +		can_skb_set_owner(skb, srcsk);
>  
>  		/* receive with packet counting */
> -		skb->sk = srcsk;
>  		vcan_rx(skb, dev);
>  	} else {
>  		/* no looped packets => no counting */


I think you really should have a helper instead of copying this 3 times.


/*
 * like skb_share_check(), but transfert the skb->sk ownership
 */
static inline struct sk_buff *can_skb_share_check(struct sk_buff *skb)
{
	if (skb_shared(skb)) {
		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);

		if (likely(nskb)) {
			if (skb->sk)
				can_skb_set_owner(nskb, skb->sk);
			consume_skb(skb);
			return nskb;
		}
		kfree_skb(skb);
		return NULL;
	}
	return skb;
}


