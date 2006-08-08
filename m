From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 08 Aug 2006 08:21:58 -0400
Message-ID: <1155039718.5138.58.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:58038 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932565AbWHHMWC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 08:22:02 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GAQax-00046l-LT
	for netdev@vger.kernel.org; Tue, 08 Aug 2006 08:22:03 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060806025123.GA27051@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Is the patch below making it in? As i pointed out in another email
tests reveal it is good.

cheers,
jamal

On Sun, 2006-06-08 at 12:51 +1000, Herbert Xu wrote:
> On Sat, Aug 05, 2006 at 07:36:50PM -0400, jamal wrote:
> > 
> > I know the qlen is >= 0 otherwise i will hit the BUG().
> > A qlen of 0 will be interesting to find as well.
> 
> When the queue is woken it will always to qdisc_run regardless of
> whether there are packets queued so this might explain what you're
> seeing.
> 
> Anyway, I've changed the unconditional atomic op into a memory
> barrier instead.  Let me know if this changes things for you.
> 
> I wonder if we could do the TX clean up within the transmission
> routine most of the time.  Has anyone tried this before?
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 627f224..e7e1306 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -2861,6 +2861,33 @@ e1000_transfer_dhcp_info(struct e1000_ad
>  	return 0;
>  }
>  
> +static int __e1000_maybe_stop_tx(struct net_device *netdev, int size)
> +{
> +	struct e1000_adapter *adapter = netdev_priv(netdev);
> +	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
> +
> +	netif_stop_queue(netdev);
> +	smp_mb__after_netif_stop_queue();
> +
> +	/* We need to check again in a case another CPU has just
> +	 * made room available.
> +	 */
> +	if (likely(E1000_DESC_UNUSED(tx_ring) < size))
> +		return -EBUSY;
> +
> +	/* A reprieve! */
> +	netif_start_queue(netdev);
> +	return 0;
> +}
> +
> +static inline int e1000_maybe_stop_tx(struct net_device *netdev,
> +				      struct e1000_tx_ring *tx_ring, int size)
> +{
> +	if (likely(E1000_DESC_UNUSED(tx_ring) >= size))
> +		return 0;
> +	return __e1000_maybe_stop_tx(netdev, size);
> +}
> +
>  #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
>  static int
>  e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
> @@ -2974,8 +3001,7 @@ #endif
>  
>  	/* need: count + 2 desc gap to keep tail from touching
>  	 * head, otherwise try next time */
> -	if (unlikely(E1000_DESC_UNUSED(tx_ring) < count + 2)) {
> -		netif_stop_queue(netdev);
> +	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
>  		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
>  		return NETDEV_TX_BUSY;
>  	}
> @@ -3022,8 +3048,7 @@ #endif
>  	netdev->trans_start = jiffies;
>  
>  	/* Make sure there is space in the ring for the next send. */
> -	if (unlikely(E1000_DESC_UNUSED(tx_ring) < MAX_SKB_FRAGS + 2))
> -		netif_stop_queue(netdev);
> +	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
>  
>  	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
>  	return NETDEV_TX_OK;
> @@ -3515,13 +3540,14 @@ #endif
>  	tx_ring->next_to_clean = i;
>  
>  #define TX_WAKE_THRESHOLD 32
> -	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
> -	             netif_carrier_ok(netdev))) {
> -		spin_lock(&tx_ring->tx_lock);
> -		if (netif_queue_stopped(netdev) &&
> -		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
> +	if (unlikely(cleaned && netif_carrier_ok(netdev) &&
> +		     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
> +		/* Make sure that anybody stopping the queue after this
> +		 * sees the new next_to_clean.
> +		 */
> +		smp_mb();
> +		if (netif_queue_stopped(netdev))
>  			netif_wake_queue(netdev);
> -		spin_unlock(&tx_ring->tx_lock);
>  	}
>  
>  	if (adapter->detect_tx_hung) {
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 75f02d8..7daaf71 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -33,6 +33,7 @@ #ifdef __KERNEL__
>  #include <asm/atomic.h>
>  #include <asm/cache.h>
>  #include <asm/byteorder.h>
> +#include <asm/system.h>
>  
>  #include <linux/device.h>
>  #include <linux/percpu.h>
> @@ -652,6 +653,12 @@ #endif
>  	set_bit(__LINK_STATE_XOFF, &dev->state);
>  }
>  
> +static inline void smp_mb__after_netif_stop_queue(void)
> +{
> +	/* Need to add smp_mb__after_set_bit(). */
> +	smp_mb();
> +}
> +
>  static inline int netif_queue_stopped(const struct net_device *dev)
>  {
>  	return test_bit(__LINK_STATE_XOFF, &dev->state);
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

