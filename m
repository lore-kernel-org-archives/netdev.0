From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v3)
Date: Wed, 13 Jan 2010 07:35:13 +0000
Message-ID: <20100113073512.GA6053@ff.dom.local>
References: <20100112.000804.186755338.davem@davemloft.net> <20100112085633.GB6628@ff.dom.local> <20100112.014218.112731835.davem@davemloft.net> <20100112.025620.210305029.davem@davemloft.net> <20100112081513.0175d579@nehalam> <4B4CC0E3.5050106@majjas.com> <4B4CC29E.4020703@majjas.com> <4B4CDC28.2050508@majjas.com> <20100112201012.21894fd3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:45395 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab0AMHfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 02:35:22 -0500
Received: by fxm25 with SMTP id 25so6869fxm.21
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 23:35:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100112201012.21894fd3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 08:10:12PM -0800, Stephen Hemminger wrote:
> Subject: sky2: safer transmit cleanup
> 
> This code makes transmit path and transmit reset safer by:
>   * adding memory barrier before checking available ring slots
>   * reseting state of tx ring elements after free
>   * seperate cleanup function from ring done function
>   * removing mostly unused tx_next element

I agree this patch makes it safer, but still not really safe, at least
compared with the "sky2: Fix oops in sky2_xmit_frame() after TX
timeout" patch.

Btw, I'm not sure adding netif_running() test to protect dev_close()
is really needed, because it's after dev_deactivate(), so re-enabled
tx doesn't probably matter.

> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> This version adds missing _bh to sky2_detach

As I wrote before, I doubt adding tx lock alone at this place is the
proper fix for anything (the rx (napi) race is the real problem), but
without this _bh it's a bug.

Jarek P.

> 
> 
> --- a/drivers/net/sky2.c	2010-01-11 10:49:50.907113126 -0800
> +++ b/drivers/net/sky2.c	2010-01-12 17:21:58.415268802 -0800
> @@ -1596,6 +1596,9 @@ static inline int tx_inuse(const struct 
>  /* Number of list elements available for next tx */
>  static inline int tx_avail(const struct sky2_port *sky2)
>  {
> +	/* Makes sure update of tx_prod from start_xmit and
> +	   tx_cons from tx_done are seen. */
> +	smp_mb();
>  	return sky2->tx_pending - tx_inuse(sky2);
>  }
>  
> @@ -1618,8 +1621,7 @@ static unsigned tx_le_req(const struct s
>  	return count;
>  }
>  
> -static void sky2_tx_unmap(struct pci_dev *pdev,
> -			  const struct tx_ring_info *re)
> +static void sky2_tx_unmap(struct pci_dev *pdev, struct tx_ring_info *re)
>  {
>  	if (re->flags & TX_MAP_SINGLE)
>  		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
> @@ -1629,6 +1631,7 @@ static void sky2_tx_unmap(struct pci_dev
>  		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
>  			       pci_unmap_len(re, maplen),
>  			       PCI_DMA_TODEVICE);
> +	re->flags = 0;
>  }
>  
>  /*
> @@ -1804,7 +1807,8 @@ mapping_error:
>  }
>  
>  /*
> - * Free ring elements from starting at tx_cons until "done"
> + * Transmit complete processing
> + * Free ring elements from starting at tx_cons until done index
>   *
>   * NB:
>   *  1. The hardware will tell us about partial completion of multi-part
> @@ -1813,11 +1817,14 @@ mapping_error:
>   *     looks at the tail of the queue of FIFO (tx_cons), not
>   *     the head (tx_prod)
>   */
> -static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
> +static void sky2_tx_done(struct net_device *dev, u16 done)
>  {
> -	struct net_device *dev = sky2->netdev;
> +	struct sky2_port *sky2 = netdev_priv(dev);
>  	unsigned idx;
>  
> +	if (unlikely(!netif_running(dev)))
> +		return;
> +
>  	BUG_ON(done >= sky2->tx_ring_size);
>  
>  	for (idx = sky2->tx_cons; idx != done;
> @@ -1828,6 +1835,8 @@ static void sky2_tx_complete(struct sky2
>  		sky2_tx_unmap(sky2->hw->pdev, re);
>  
>  		if (skb) {
> +			re->skb = NULL;
> +
>  			if (unlikely(netif_msg_tx_done(sky2)))
>  				printk(KERN_DEBUG "%s: tx done %u\n",
>  				       dev->name, idx);
> @@ -1836,13 +1845,10 @@ static void sky2_tx_complete(struct sky2
>  			dev->stats.tx_bytes += skb->len;
>  
>  			dev_kfree_skb_any(skb);
> -
> -			sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
>  		}
>  	}
>  
>  	sky2->tx_cons = idx;
> -	smp_mb();
>  
>  	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
>  		netif_wake_queue(dev);
> @@ -1870,6 +1876,21 @@ static void sky2_tx_reset(struct sky2_hw
>  	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
>  }
>  
> +static void sky2_tx_clean(struct sky2_port *sky2)
> +{
> +	u16 idx;
> +
> +	for (idx = 0; idx < sky2->tx_ring_size; idx++) {
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
>  /* Network shutdown */
>  static int sky2_down(struct net_device *dev)
>  {
> @@ -1933,8 +1954,7 @@ static int sky2_down(struct net_device *
>  	sky2_tx_reset(hw, port);
>  
>  	/* Free any pending frames stuck in HW queue */
> -	sky2_tx_complete(sky2, sky2->tx_prod);
> -
> +	sky2_tx_clean(sky2);
>  	sky2_rx_clean(sky2);
>  
>  	sky2_free_buffers(sky2);
> @@ -2411,15 +2431,6 @@ error:
>  	goto resubmit;
>  }
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
>  static inline void sky2_skb_rx(const struct sky2_port *sky2,
>  			       u32 status, struct sk_buff *skb)
>  {
> @@ -3176,9 +3187,9 @@ static void sky2_reset(struct sky2_hw *h
>  static void sky2_detach(struct net_device *dev)
>  {
>  	if (netif_running(dev)) {
> -		netif_tx_lock(dev);
> +		netif_tx_lock_bh(dev);
>  		netif_device_detach(dev);	/* stop txq */
> -		netif_tx_unlock(dev);
> +		netif_tx_unlock_bh(dev);
>  		sky2_down(dev);
>  	}
>  }
> @@ -4201,7 +4212,7 @@ static int sky2_debug_show(struct seq_fi
>  
>  	/* Dump contents of tx ring */
>  	sop = 1;
> -	for (idx = sky2->tx_next; idx != sky2->tx_prod && idx < sky2->tx_ring_size;
> +	for (idx = sky2->tx_cons; idx != sky2->tx_prod && idx < sky2->tx_ring_size;
>  	     idx = RING_NEXT(idx, sky2->tx_ring_size)) {
>  		const struct sky2_tx_le *le = sky2->tx_le + idx;
>  		u32 a = le32_to_cpu(le->addr);
> --- a/drivers/net/sky2.h	2010-01-11 17:29:22.817088617 -0800
> +++ b/drivers/net/sky2.h	2010-01-11 17:29:28.197120484 -0800
> @@ -2187,7 +2187,6 @@ struct sky2_port {
>  	u16		     tx_ring_size;
>  	u16		     tx_cons;		/* next le to check */
>  	u16		     tx_prod;		/* next le to use */
> -	u16		     tx_next;		/* debug only */
>  
>  	u16		     tx_pending;
>  	u16		     tx_last_mss;
