From: Andreas Henriksson <andreas@fjortis.info>
Subject: Re: fealnx oopses
Date: Mon, 29 Mar 2004 01:27:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040328232707.GA17524@scream.fjortis.info>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403272328.51291.vda@port.imtp.ilyichevsk.odessa.ua> <20040328005533.A6117@electric-eye.fr.zoreil.com> <200403282219.56799.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jeff Garzik <jgarzik@pobox.com>,
        Andreas Henriksson <andreas@fjortis.info>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200403282219.56799.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 28, 2004 at 10:19:56PM +0200, Denis Vlasenko wrote:
> I tested on 2.4.25, patch applied with minimal manual correction
> in last hunk (rediffed patch attached).

I tested on 2.6.5-rc2-bk7 ... with both jeffs (which was exactly the
same patch I had except for removing the return at the end of the void
function) and francis patches...

Btw. I haven't seen any panics at all because of rx, just tx, and that
problem seems solved. But I thought testing additional patches that
is supposed to cure other problems won't hurt me.. ;)

> 
> Patched driver oopses in allocate_rx_buffers() shortly after boot,

It oops as soon as the first packet is sent out....


> --- fealnx.c.orig	Fri Nov 28 20:26:20 2003
> +++ fealnx.c	Sun Mar 28 21:32:56 2004
> @@ -1134,15 +1134,17 @@
>  		struct sk_buff *skb;
>  
>  		skb = dev_alloc_skb(np->rx_buf_sz);
> -		np->lack_rxbuf->skbuff = skb;
> -
>  		if (skb == NULL)
>  			break;	/* Better luck next round. */
>  

np->lack_rxbuf == NULL here....

(verified by inserting a "BUG_ON(np->lack_rxbuf==NULL);"...)

> +		while (np->lack_rxbuf->skbuff)

and now we are dead.. ;(

> +			np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
> +		np->lack_rxbuf->skbuff = skb;
> +
>  		skb->dev = dev;	/* Mark as being used by this device. */
>  		np->lack_rxbuf->buffer = pci_map_single(np->pci_dev, skb->tail,
>  			np->rx_buf_sz, PCI_DMA_FROMDEVICE);
> -		np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
> +		np->lack_rxbuf->status = RXOWN;
>  		++np->really_rx_count;
>  	}
>  }
> @@ -1380,33 +1382,22 @@
>  	return 0;
>  }
>  
> -
> -void free_one_rx_descriptor(struct netdev_private *np)
> -{
> -	if (np->really_rx_count == RX_RING_SIZE)
> -		np->cur_rx->status = RXOWN;
> -	else {
> -		np->lack_rxbuf->skbuff = np->cur_rx->skbuff;
> -		np->lack_rxbuf->buffer = np->cur_rx->buffer;
> -		np->lack_rxbuf->status = RXOWN;
> -		++np->really_rx_count;
> -		np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
> -	}
> -	np->cur_rx = np->cur_rx->next_desc_logical;
> -}
> -
> -
>  void reset_rx_descriptors(struct net_device *dev)
>  {
>  	struct netdev_private *np = dev->priv;
> +	struct fealnx_desc *cur = np->cur_rx;
> +	int i;
>  
>  	stop_nic_rx(dev->base_addr, np->crvalue);
>  
> -	while (!(np->cur_rx->status & RXOWN))
> -		free_one_rx_descriptor(np);
> -
>  	allocate_rx_buffers(dev);
>  
> +	for (i = 0; i < RX_RING_SIZE; i++) {
> +		if (cur->skbuff)
> +			cur->status = RXOWN;
> +		cur = cur->next_desc_logical;
> +	}
> +
>  	writel(np->rx_ring_dma + (np->cur_rx - np->rx_ring),
>  		dev->base_addr + RXLBA);
>  	writel(np->crvalue, dev->base_addr + TCRRCR);
> @@ -1576,7 +1567,7 @@
>  	struct netdev_private *np = dev->priv;
>  
>  	/* If EOP is set on the next entry, it's a new packet. Send it up. */
> -	while (!(np->cur_rx->status & RXOWN)) {
> +	while (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) {
>  		s32 rx_status = np->cur_rx->status;
>  
>  		if (np->really_rx_count == 0)
> @@ -1628,8 +1619,15 @@
>  					np->stats.rx_length_errors++;
>  
>  					/* free all rx descriptors related this long pkt */
> -					for (i = 0; i < desno; ++i)
> -						free_one_rx_descriptor(np);
> +					for (i = 0; i < desno; ++i) {
> +						if (!np->cur_rx->skbuff) {
> +							printk(KERN_DEBUG
> +								"%s: I'm scared\n", dev->name);
> +							break;
> +						}
> +						np->cur_rx->status = RXOWN;
> +						np->cur_rx = np->cur_rx->next_desc_logical;
> +					}
>  					continue;
>  				} else {	/* something error, need to reset this chip */
>  					reset_rx_descriptors(dev);
> @@ -1671,8 +1669,6 @@
>  			} else {
>  				skb_put(skb = np->cur_rx->skbuff, pkt_len);
>  				np->cur_rx->skbuff = NULL;
> -				if (np->really_rx_count == RX_RING_SIZE)
> -					np->lack_rxbuf = np->cur_rx;
>  				--np->really_rx_count;
>  			}
>  			skb->protocol = eth_type_trans(skb, dev);
> @@ -1682,22 +1678,7 @@
>  			np->stats.rx_bytes += pkt_len;
>  		}
>  
> -		if (np->cur_rx->skbuff == NULL) {
> -			struct sk_buff *skb;
> -
> -			skb = dev_alloc_skb(np->rx_buf_sz);
> -
> -			if (skb != NULL) {
> -				skb->dev = dev;	/* Mark as being used by this device. */
> -				np->cur_rx->buffer = pci_map_single(np->pci_dev, skb->tail,
> -					np->rx_buf_sz, PCI_DMA_FROMDEVICE);
> -				np->cur_rx->skbuff = skb;
> -				++np->really_rx_count;
> -			}
> -		}
> -
> -		if (np->cur_rx->skbuff != NULL)
> -			free_one_rx_descriptor(np);
> +		np->cur_rx = np->cur_rx->next_desc_logical;
>  	}			/* end of while loop */
>  
>  	/*  allocate skb for rx buffers */


Regards,
Andreas Henriksson
