From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v2)
Date: Tue, 12 Jan 2010 14:34:28 -0500
Message-ID: <4B4CCEC4.9090308@majjas.com>
References: <20100112.000804.186755338.davem@davemloft.net>
 <20100112085633.GB6628@ff.dom.local>
 <20100112.014218.112731835.davem@davemloft.net>
 <20100112.025620.210305029.davem@davemloft.net>
 <20100112081513.0175d579@nehalam> <20100112180430.GA3355@del.dom.local>
 <20100112101306.6a67c0a5@nehalam> <20100112182447.GB3355@del.dom.local>
 <20100112104945.462cf205@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:42354 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753772Ab0ALTfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 14:35:17 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta1.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KW5002SHFQEU100@mta1.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Tue, 12 Jan 2010 14:35:08 -0500 (EST)
In-reply-to: <20100112104945.462cf205@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/12/2010 1:49 PM, Stephen Hemminger wrote:
>
> This code makes transmit path and transmit reset safer by:
>    * adding memory barrier before checking available ring slots
>    * reseting state of tx ring elements after free
>    * seperate cleanup function from ring done function
>    * removing mostly unused tx_next element
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>
> ---
>
> What is supposed to happen:
>    * restart sky2_restart calls napi_disable while cleaning
>    * dev_close we can't call napi_disable() because of two ports
>      sharing same NAPI, so napi_synchronize() is used to make sure that
>      any NAPI running on other CPU has completed.
>    * if status is reported by chip for down device, then tx_done should ignore
>
> But, last patch was missing last step
>
> --- a/drivers/net/sky2.c	2010-01-11 10:49:50.907113126 -0800
> +++ b/drivers/net/sky2.c	2010-01-12 10:44:56.068391575 -0800
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
> +	if (unlikely(!netif_running(dev)))
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
> @@ -1836,13 +1845,10 @@ static void sky2_tx_complete(struct sky2
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
>   	if (tx_avail(sky2)>  MAX_SKB_TX_LE + 4)
>   		netif_wake_queue(dev);
> @@ -1870,6 +1876,21 @@ static void sky2_tx_reset(struct sky2_hw
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
> @@ -1933,8 +1954,7 @@ static int sky2_down(struct net_device *
>   	sky2_tx_reset(hw, port);
>
>   	/* Free any pending frames stuck in HW queue */
> -	sky2_tx_complete(sky2, sky2->tx_prod);
> -
> +	sky2_tx_clean(sky2);
>   	sky2_rx_clean(sky2);
>
>   	sky2_free_buffers(sky2);
> @@ -2411,15 +2431,6 @@ error:
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
> @@ -4201,7 +4212,7 @@ static int sky2_debug_show(struct seq_fi
>
>   	/* Dump contents of tx ring */
>   	sop = 1;
> -	for (idx = sky2->tx_next; idx != sky2->tx_prod&&  idx<  sky2->tx_ring_size;
> +	for (idx = sky2->tx_cons; idx != sky2->tx_prod&&  idx<  sky2->tx_ring_size;
>   	     idx = RING_NEXT(idx, sky2->tx_ring_size)) {
>   		const struct sky2_tx_le *le = sky2->tx_le + idx;
>   		u32 a = le32_to_cpu(le->addr);
> --- a/drivers/net/sky2.h	2010-01-11 17:29:22.817088617 -0800
> +++ b/drivers/net/sky2.h	2010-01-11 17:29:28.197120484 -0800
> @@ -2187,7 +2187,6 @@ struct sky2_port {
>   	u16		     tx_ring_size;
>   	u16		     tx_cons;		/* next le to check */
>   	u16		     tx_prod;		/* next le to use */
> -	u16		     tx_next;		/* debug only */
>
>   	u16		     tx_pending;
>   	u16		     tx_last_mss;
>    
Testing observation:

This makes no sense to me, but the DHCP multiple request/inform issue I 
noted with V1 of this patch is gone with V2 (this is a repeatable test). 
I don't see how this patch could make the difference as the device 
should never be down during this test. What am I missing?
