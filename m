From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 15:42:30 -0700
Message-ID: <200506222242.j5MMgbxS009935@guinness.s2io.com>
References: <20050622.132241.21929037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <hadi@cyberus.ca>, <becker@scyld.com>, <rick.jones2@hp.com>,
        <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>, <ak@suse.de>
In-Reply-To: <20050622.132241.21929037.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: David S. Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, June 22, 2005 1:23 PM
> To: ak@suse.de
> Cc: leonid.grossman@neterion.com; hadi@cyberus.ca; 
> becker@scyld.com; rick.jones2@hp.com; netdev@oss.sgi.com; 
> davem@redhat.com
> Subject: Re: RFC: NAPI packet weighting patch
> 
> From: Andi Kleen <ak@suse.de>
> Date: Wed, 22 Jun 2005 20:06:55 +0200
> 
> > However it is tricky because CPUs have only a limited load queue 
> > entries and doing too many prefetches will just overflow that.
> 
> Several processors can queue about 8 prefetch requests, and 
> these slots are independant of those consumed by a load.
> 
> Yes, if you queue too many prefetches, the queue overflows.
> 
> I think the optimal scheme would be:
> 
> 1) eth_type_trans() info in RX descriptor
> 2) prefetch(skb->data) done as early as possible in driver
>    RX handling
> 
> Actually, I believe to most optimal scheme is:
> 
> foo_driver_rx()
> {
> 	for_each_rx_descriptor() {
> 		...
> 		skb = driver_priv->rx_skbs[index];
> 		prefetch(skb->data);
> 
> 		skb = realloc_or_recycle_rx_descriptor(skb, index);
> 		if (skb == NULL)
> 			goto next_rxd;
> 
> 		skb->prot = eth_type_trans(skb, driver_priv->dev);
> 		netif_receive_skb(skb);
> 		...
> 	next_rxd:
> 		...
> 	}
> }
> 
> The idea is that first the prefetch goes into flight, then 
> you do the recycle or reallocation of the RX descriptor SKB, 
> then you try to touch the data.
> 
> This makes it very likely the prefetch will be in the cpu in time.
> 
> Everyone seems to have this absolute fetish about batching 
> the RX descriptor refilling work.  It's wrong, it should be 
> done when you pull a receive packet off the ring, for many 
> reasons.  Off the top of my head:

This is very hw-dependent, since there are NICs that read descriptors in
batches anyways - but the second argument below is compelling.

> 
> 1) Descriptors are refilled as soon as possible, decreasing
>    the chance of the device hitting the end of the RX ring
>    and thus unable to receive a packet.
> 
> 2) As shown above, it gives you compute time which can be used to
>    schedule the prefetch.  This nearly makes RX replenishment free.
>    Instead of having the CPU spin on a cache miss when we run
>    eth_type_trans() during those cycles, we do useful work.
> 
> I'm going to play around with these ideas in the tg3 driver.
> Obvious patch below.

We will play around with the s2io driver as well, there seem to be several
interesting ideas to try - thanks a lot for the input!
Cheers, Leonid

> 
> --- 1/drivers/net/tg3.c.~1~	2005-06-22 12:33:07.000000000 -0700
> +++ 2/drivers/net/tg3.c	2005-06-22 13:19:13.000000000 -0700
> @@ -2772,6 +2772,13 @@
>  			goto next_pkt_nopost;
>  		}
>  
> +		/* Prefetch now.  The recycle/realloc of the RX
> +		 * entry is moderately expensive, so by the time
> +		 * that is complete the data should have reached
> +		 * the cpu.
> +		 */
> +		prefetch(skb->data);
> +
>  		work_mask |= opaque_key;
>  
>  		if ((desc->err_vlan & RXD_ERR_MASK) != 0 &&
> 
