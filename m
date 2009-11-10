From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: RFC: net: allow to propagate errors through
 ->ndo_hard_start_xmit()
Date: Tue, 10 Nov 2009 18:08:38 +0100
Message-ID: <20091110170838.GA4195@ami.dom.local>
References: <4AF87070.6020007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:62430 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbZKJRUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 12:20:07 -0500
Received: by bwz27 with SMTP id 27so248079bwz.21
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 09:20:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4AF87070.6020007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2009 at 08:41:36PM +0100, Patrick McHardy wrote:
> I've updated my patch to propagate error values (errno and NET_XMIT
> codes) through ndo_hard_start_xmit() and incorporated the suggestions
> made last time, namely:
> 
> - move slightly complicated return value check to inline function and
>   add a few comments
> 
> - fix error handling while in the middle of transmitting GSO skbs
> 
> I've also audited the tree once again for invalid return values and
> found a single remaining instance in a Wimax driver, I'll take care
> of that later.
> 
> Two questions remain:
> 
> - I'm not sure the error handling in dev_hard_start_xmit() for GSO
>   skbs is optimal. When the driver returns an error, it is assumed
>   the current segment has been freed. The patch then frees the
>   entire GSO skb, including all remaining segments. Alternatively
>   it could try to transmit the remaining segments later.

Anyway, it seems this freeing should be described in the changelog,
if not moved to a separate patch, since it fixes another problem,
unless I forgot something.

> 
> - Stephen recently introduced an enum for the netdev_tx codes, with
>   this patch drivers are allowed to return different values.
>   The mainly useful part about Stephen's patch IMO is the netdev_tx
>   typedef to make it easier to locate ndo_start_xmit() functions
>   which are defined in different files than the netdev_ops.
>   So we could remove the enum again and simply typedef an int.
> 
> Any opinions are welcome :)

> commit 08a98f11bc1c1452df74c171409218d2243f0818
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Nov 9 20:33:14 2009 +0100
> 
>     net: allow to propagate errors through ->ndo_hard_start_xmit()
>     
>     Currently the ->ndo_hard_start_xmit() callbacks are only permitted to return
>     one of the NETDEV_TX codes. This prevents any kind of error propagation for
>     virtual devices, like queue congestion of the underlying device in case of
>     layered devices, or unreachability in case of tunnels.
>     
>     This patches changes the NET_XMIT codes to avoid clashes with the NETDEV_TX

-     This patches changes the NET_XMIT codes to avoid clashes with the NETDEV_TX
+     This patch changes the NET_XMIT codes to avoid clashes with the NETDEV_TX

>     codes and changes the two callers of dev_hard_start_xmit() to expect either
>     errno codes, NET_XMIT codes or NETDEV_TX codes as return value.
>     
>     In case of qdisc_restart(), all non NETDEV_TX codes are mapped to NETDEV_TX_OK
>     since no error propagation is possible when using qdiscs. In case of
>     dev_queue_xmit(), the error is propagated upwards.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 465add6..ab2812c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -63,27 +63,48 @@ struct wireless_dev;
>  #define HAVE_FREE_NETDEV		/* free_netdev() */
>  #define HAVE_NETDEV_PRIV		/* netdev_priv() */
>  
> -#define NET_XMIT_SUCCESS	0
> -#define NET_XMIT_DROP		1	/* skb dropped			*/
> -#define NET_XMIT_CN		2	/* congestion notification	*/
> -#define NET_XMIT_POLICED	3	/* skb is shot by police	*/
> -#define NET_XMIT_MASK		0xFFFF	/* qdisc flags in net/sch_generic.h */
> +/*
> + * Transmit return codes: transmit return codes originate from three different
> + * namespaces:
> + *
> + * - qdisc return codes
> + * - driver transmit return codes
> + * - errno values
> + *
> + * Drivers are allowed to return any one of those in their hard_start_xmit()
> + * function. Real network devices commonly used with qdiscs should only return
> + * the driver transmit return codes though - when qdiscs are used, the actual
> + * transmission happens asynchronously, so the value is not propagated to
> + * higher layers. Virtual network devices transmit synchronously, in this case
> + * the driver transmit return codes are consumed by dev_queue_xmit(), all
> + * others are propagated to higher layers.
> + */
> +
> +/* qdisc ->enqueue() return codes. */
> +#define NET_XMIT_SUCCESS	0x00
> +#define NET_XMIT_DROP		0x10	/* skb dropped			*/
> +#define NET_XMIT_CN		0x20	/* congestion notification	*/
> +#define NET_XMIT_POLICED	0x30	/* skb is shot by police	*/
> +#define NET_XMIT_MASK		0xf0	/* qdisc flags in net/sch_generic.h */
>  
>  /* Backlog congestion levels */
> -#define NET_RX_SUCCESS		0   /* keep 'em coming, baby */
> -#define NET_RX_DROP		1  /* packet dropped */
> +#define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
> +#define NET_RX_DROP		1	/* packet dropped */

Should these NET_RX codes be mixed with transmit codes?

>  
>  /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
>   * indicates that the device will soon be dropping packets, or already drops
>   * some packets of the same priority; prompting us to send less aggressively. */
> -#define net_xmit_eval(e)	((e) == NET_XMIT_CN? 0 : (e))
> +#define net_xmit_eval(e)	((e) == NET_XMIT_CN ? 0 : (e))
>  #define net_xmit_errno(e)	((e) != NET_XMIT_CN ? -ENOBUFS : 0)
>  
>  /* Driver transmit return codes */
> +#define NETDEV_TX_MASK		0xf
> +
>  enum netdev_tx {
> -	NETDEV_TX_OK = 0,	/* driver took care of packet */
> -	NETDEV_TX_BUSY,		/* driver tx path was busy*/
> -	NETDEV_TX_LOCKED = -1,	/* driver tx lock was already taken */
> +	__NETDEV_TX_MIN	 = INT_MIN,	/* make sure enum is signed */
> +	NETDEV_TX_OK	 = 0,		/* driver took care of packet */
> +	NETDEV_TX_BUSY	 = 1,		/* driver tx path was busy*/
> +	NETDEV_TX_LOCKED = 2,		/* driver tx lock was already taken */
>  };
>  typedef enum netdev_tx netdev_tx_t;
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index bf629ac..1f5752d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1756,7 +1756,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			struct netdev_queue *txq)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
> -	int rc;
> +	int rc = NETDEV_TX_OK;

Isn't it enough to add this in one place only: before this
"goto out_kfree_skb"?

>  
>  	if (likely(!skb->next)) {
>  		if (!list_empty(&ptype_all))
> @@ -1804,6 +1804,8 @@ gso:
>  		nskb->next = NULL;
>  		rc = ops->ndo_start_xmit(nskb, dev);
>  		if (unlikely(rc != NETDEV_TX_OK)) {
> +			if (rc & ~NETDEV_TX_MASK)
> +				goto out_kfree_gso_skb;

If e.g. (rc == NETDEV_TX_OK | NET_XMIT_CN), why exactly is this freeing
necessary now?

Is e.g. (rc == NETDEV_TX_BUSY | NET_XMIT_CN) legal? If so, there would
be use after kfree, I guess. Otherwise, it should be documented above
(and maybe checked somewhere as well).

>  			nskb->next = skb->next;
>  			skb->next = nskb;
>  			return rc;
> @@ -1813,11 +1815,14 @@ gso:
>  			return NETDEV_TX_BUSY;
>  	} while (skb->next);
>  
> -	skb->destructor = DEV_GSO_CB(skb)->destructor;
> +	rc = NETDEV_TX_OK;

When is (rc != NETDEV_TX_OK) possible in this place?

>  
> +out_kfree_gso_skb:
> +	if (likely(skb->next == NULL))
> +		skb->destructor = DEV_GSO_CB(skb)->destructor;
>  out_kfree_skb:
>  	kfree_skb(skb);
> -	return NETDEV_TX_OK;
> +	return rc;
>  }
>  
>  static u32 skb_tx_hashrnd;
> @@ -1905,6 +1910,23 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  	return rc;
>  }
>  
> +static inline bool dev_xmit_complete(int rc)
> +{
> +	/* successful transmission */
> +	if (rc == NETDEV_TX_OK)
> +		return true;
> +
> +	/* error while transmitting, driver consumed skb */
> +	if (rc < 0)
> +		return true;
> +
> +	/* error while queueing to a different device, driver consumed skb */
> +	if (rc & NET_XMIT_MASK)
> +		return true;
> +
> +	return false;
> +}
> +
>  /**
>   *	dev_queue_xmit - transmit a buffer
>   *	@skb: buffer to transmit
> @@ -2002,8 +2024,8 @@ gso:
>  			HARD_TX_LOCK(dev, txq, cpu);
>  
>  			if (!netif_tx_queue_stopped(txq)) {
> -				rc = NET_XMIT_SUCCESS;
> -				if (!dev_hard_start_xmit(skb, dev, txq)) {
> +				rc = dev_hard_start_xmit(skb, dev, txq);
> +				if (dev_xmit_complete(rc)) {
>  					HARD_TX_UNLOCK(dev, txq);
>  					goto out;
>  				}
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 4ae6aa5..b13821a 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -120,8 +120,15 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>  
>  	HARD_TX_LOCK(dev, txq, smp_processor_id());
>  	if (!netif_tx_queue_stopped(txq) &&
> -	    !netif_tx_queue_frozen(txq))
> +	    !netif_tx_queue_frozen(txq)) {
>  		ret = dev_hard_start_xmit(skb, dev, txq);
> +
> +		/* an error implies that the skb was consumed */
> +		if (ret < 0)
> +			ret = NETDEV_TX_OK;

  +		else (?)

Jarek P.

> +		/* all NET_XMIT codes map to NETDEV_TX_OK */
> +		ret &= ~NET_XMIT_MASK;
> +	}
>  	HARD_TX_UNLOCK(dev, txq);
>  
>  	spin_lock(root_lock);

