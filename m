From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 10:46:50 -0500
Message-ID: <4B4F3C6A.2090104@majjas.com>
References: <20100112.000804.186755338.davem@davemloft.net>
 <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam> <4B4CC0E3.5050106@majjas.com>
 <4B4CC29E.4020703@majjas.com> <4B4CDC28.2050508@majjas.com>
 <20100112201012.21894fd3@nehalam> <4B4DEEF9.7020806@majjas.com>
 <20100113194148.139091a3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	mikem@ring3k.org, flyboy@gmail.com, rjw@sisk.pl,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:51786 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756810Ab0ANPrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 10:47:23 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta1.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KW8000GDUIYK3W0@mta1.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Thu, 14 Jan 2010 10:47:22 -0500 (EST)
In-reply-to: <20100113194148.139091a3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/2010 10:41 PM, Stephen Hemminger wrote:
> Subject: sky2: safer transmit cleanup
>
> This code makes transmit path and transmit reset safer by:
>    * adding memory barrier before checking available ring slots
>    * reseting state of tx ring elements after free
>    * seperate cleanup function from ring done function
>    * removing mostly unused tx_next element
>    * ignoring transmit completion if device is offline
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>
> ---
> This patch is against the current net-next-2.6 tree.
> This version handles the case of dual port shared transmit status
> and other cases where it is possible for tx_done to be called when
> device is being changed.
>
> --- a/drivers/net/sky2.c	2010-01-13 08:32:51.360161158 -0800
> +++ b/drivers/net/sky2.c	2010-01-13 08:35:37.685531490 -0800
> @@ -1596,6 +1596,9 @@ static inline int tx_inuse(const struct
>   /* Number of list elements available for next tx */
>   static inline int tx_avail(const struct sky2_port *sky2)
>   {
> +	/* Makes sure update of tx_prod from start_xmit and
> +	   tx_cons from tx_done are seen. */
> +	smp_mb();
>   	return sky2->tx_pending - tx_inuse(sky2);
>   }
>
> @@ -1618,8 +1621,7 @@ static unsigned tx_le_req(const struct s
>   	return count;
>   }
>
> -static void sky2_tx_unmap(struct pci_dev *pdev,
> -			  const struct tx_ring_info *re)
> +static void sky2_tx_unmap(struct pci_dev *pdev, struct tx_ring_info *re)
>   {
>   	if (re->flags&  TX_MAP_SINGLE)
>   		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
> @@ -1629,6 +1631,7 @@ static void sky2_tx_unmap(struct pci_dev
>   		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
>   			       pci_unmap_len(re, maplen),
>   			       PCI_DMA_TODEVICE);
> +	re->flags = 0;
>   }
>
>   /*
> @@ -1804,7 +1807,8 @@ mapping_error:
>   }
>
>   /*
> - * Free ring elements from starting at tx_cons until "done"
> + * Transmit complete processing
> + * Free ring elements from starting at tx_cons until done index
>    *
>    * NB:
>    *  1. The hardware will tell us about partial completion of multi-part
> @@ -1813,11 +1817,14 @@ mapping_error:
>    *     looks at the tail of the queue of FIFO (tx_cons), not
>    *     the head (tx_prod)
>    */
> -static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
> +static void sky2_tx_done(struct net_device *dev, u16 done)
>   {
> -	struct net_device *dev = sky2->netdev;
> +	struct sky2_port *sky2 = netdev_priv(dev);
>   	unsigned idx;
>
> +	if (!(netif_running(dev)&  netif_device_present(dev)))
> +		return;
> +
>   	BUG_ON(done>= sky2->tx_ring_size);
>
>   	for (idx = sky2->tx_cons; idx != done;
> @@ -1828,6 +1835,8 @@ static void sky2_tx_complete(struct sky2
>   		sky2_tx_unmap(sky2->hw->pdev, re);
>
>   		if (skb) {
> +			re->skb = NULL;
> +
>   			if (unlikely(netif_msg_tx_done(sky2)))
>   				printk(KERN_DEBUG "%s: tx done %u\n",
>   				       dev->name, idx);
> @@ -1836,16 +1845,12 @@ static void sky2_tx_complete(struct sky2
>   			dev->stats.tx_bytes += skb->len;
>
>   			dev_kfree_skb_any(skb);
> -
> -			sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
>   		}
>   	}
>
>   	sky2->tx_cons = idx;
> -	smp_mb();
>
> -	/* Wake unless it's detached, and called e.g. from sky2_down() */
> -	if (tx_avail(sky2)>  MAX_SKB_TX_LE + 4&&  netif_device_present(dev))
> +	if (tx_avail(sky2)>  MAX_SKB_TX_LE + 4)
>   		netif_wake_queue(dev);
>   }
>
> @@ -1871,6 +1876,21 @@ static void sky2_tx_reset(struct sky2_hw
>   	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
>   }
>
> +static void sky2_tx_clean(struct sky2_port *sky2)
> +{
> +	u16 idx;
> +
> +	for (idx = 0; idx<  sky2->tx_ring_size; idx++) {
> +		struct tx_ring_info *re = sky2->tx_ring + idx;
> +
> +		sky2_tx_unmap(sky2->hw->pdev, re);
> +		if (re->skb) {
> +			dev_kfree_skb_any(re->skb);
> +			re->skb = NULL;
> +		}
> +	}
> +}
> +
>   /* Network shutdown */
>   static int sky2_down(struct net_device *dev)
>   {
> @@ -1934,8 +1954,7 @@ static int sky2_down(struct net_device *
>   	sky2_tx_reset(hw, port);
>
>   	/* Free any pending frames stuck in HW queue */
> -	sky2_tx_complete(sky2, sky2->tx_prod);
> -
> +	sky2_tx_clean(sky2);
>   	sky2_rx_clean(sky2);
>
>   	sky2_free_buffers(sky2);
> @@ -2412,15 +2431,6 @@ error:
>   	goto resubmit;
>   }
>
> -/* Transmit complete */
> -static inline void sky2_tx_done(struct net_device *dev, u16 last)
> -{
> -	struct sky2_port *sky2 = netdev_priv(dev);
> -
> -	if (netif_running(dev))
> -		sky2_tx_complete(sky2, last);
> -}
> -
>   static inline void sky2_skb_rx(const struct sky2_port *sky2,
>   			       u32 status, struct sk_buff *skb)
>   {
> @@ -3177,9 +3187,9 @@ static void sky2_reset(struct sky2_hw *h
>   static void sky2_detach(struct net_device *dev)
>   {
>   	if (netif_running(dev)) {
> -		netif_tx_lock(dev);
> +		netif_tx_lock_bh(dev);
>   		netif_device_detach(dev);	/* stop txq */
> -		netif_tx_unlock(dev);
> +		netif_tx_unlock_bh(dev);
>   		sky2_down(dev);
>   	}
>   }
> @@ -4202,7 +4212,7 @@ static int sky2_debug_show(struct seq_fi
>
>   	/* Dump contents of tx ring */
>   	sop = 1;
> -	for (idx = sky2->tx_next; idx != sky2->tx_prod&&  idx<  sky2->tx_ring_size;
> +	for (idx = sky2->tx_cons; idx != sky2->tx_prod&&  idx<  sky2->tx_ring_size;
>   	     idx = RING_NEXT(idx, sky2->tx_ring_size)) {
>   		const struct sky2_tx_le *le = sky2->tx_le + idx;
>   		u32 a = le32_to_cpu(le->addr);
> --- a/drivers/net/sky2.h	2010-01-13 08:32:27.919849429 -0800
> +++ b/drivers/net/sky2.h	2010-01-13 08:33:03.410162026 -0800
> @@ -2187,7 +2187,6 @@ struct sky2_port {
>   	u16		     tx_ring_size;
>   	u16		     tx_cons;		/* next le to check */
>   	u16		     tx_prod;		/* next le to use */
> -	u16		     tx_next;		/* debug only */
>
>   	u16		     tx_pending;
>   	u16		     tx_last_mss;
>    
Tested this a bit (w/o Mike's patch from this morning). Overall, works 
(vs. v3), but still something flaky going on WRT dhcp traffic:

Under load (and only under load) I'm seeing mutliple failed dhcp client 
requests - 4-6 discover/offer sequences before I see request/ack. I 
don't see errors, dropped packets, etc., at the time this is happening. 
I'd blow it off to load, but I don't see this with the earlier 
(pskb_may_pull) patch.

Going to rebuild with the inclusion of Mike's patch and see what happens.
