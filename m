From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] Add NAPI support to sungem.c
Date: Tue, 14 Sep 2004 11:56:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41471498.8010107@pobox.com>
References: <20040914153537.GE8434@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@oss.sgi.com,
        linuxppc-dev@lists.linuxppc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040914153537.GE8434@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> Hi Dave!
> 
> Please find the attached patch to add NAPI support to the sungem.c
> driver (I was annoyed by the fact the pktgen could kill my Powerbook).
> 
> Since this is my first hack of a network driver within at least 5 years,
> please be kind with me and point me to all the locking bugs and other
> mistakes ;)
> 
> Any comments welcome,
> 
> 	Harald
> 
> 
> 
> ------------------------------------------------------------------------
> 
> diff -Nru linux-2.6.8.1-davem269_4/drivers/net/Kconfig linux-2.6.8.1-davem269_4-sungem-napi/drivers/net/Kconfig
> --- linux-2.6.8.1-davem269_4/drivers/net/Kconfig	2004-08-14 12:56:00.000000000 +0200
> +++ linux-2.6.8.1-davem269_4-sungem-napi/drivers/net/Kconfig	2004-09-14 11:40:40.000000000 +0200
> @@ -569,6 +569,22 @@
>  	help
>  	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
>  	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/806-3985-10.pdf>.
> +config SUNGEM_NAPI
> +	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
> +	depends on SUNGEM && EXPERIMENTAL
> +	help
> +	  NAPI is a new driver API designed to reduce CPU and interrupt load
> +	  when the driver is receiving lots of packets from the card. It is
> +	  still somewhat experimental and thus not yet enabled by default.
> +
> +	  If your estimated Rx load is 10kpps or more, or if the card will be
> +	  deployed on potentially unfriendly networks (e.g. in a firewall),
> +	  then say Y here.
> +
> +	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
> +	  information.
> +
> +	  If in doubt, say N.
>  
>  config NET_VENDOR_3COM
>  	bool "3COM cards"
> --- linux-2.6.8-rc2-nfpending-tcpwin/drivers/net/sungem.c	2004-07-22 17:48:43.000000000 +0200
> +++ linux-2.6.8-rc2-nfpending-tcpwin-napi/drivers/net/sungem.c	2004-09-13 15:48:17.299866224 +0200
> @@ -5,6 +5,9 @@
>   * 
>   * Support for Apple GMAC and assorted PHYs by
>   * Benjamin Herrenscmidt (benh@kernel.crashing.org)
> + *
> + * Support for NAPI and NETPOLL 
> + * 	(C) 2004 by Harald Welte <laforge@gnumonks.org>
>   * 
>   * TODO: 
>   *  - Get rid of all those nasty mdelay's and replace them
> @@ -187,6 +190,26 @@
>  		printk(KERN_DEBUG "%s: mif interrupt\n", gp->dev->name);
>  }
>  
> +static inline void
> +gem_irq_disable(struct gem *gp)
> +{
> +	/* Make sure we won't get any more interrupts */
> +	writel(0xffffffff, gp->regs + GREG_IMASK);
> +}
> +
> +static inline void
> +gem_irq_enable(struct gem *gp, unsigned int mask)
> +{
> +	/* We don't want TXDONE, but all other interrupts */
> +	writel(mask, gp->regs + GREG_IMASK);
> +}
> +
> +static inline void
> +gem_irq_acknowledge(struct gem *gp, unsigned int mask)
> +{
> +	writel(mask, gp->regs + GREG_IACK);
> +}

PCI posting


>  static int gem_pcs_interrupt(struct net_device *dev, struct gem *gp, u32 gem_status)
>  {
>  	u32 pcs_istat = readl(gp->regs + PCS_ISTAT);
> @@ -537,6 +560,7 @@
>  			printk(KERN_DEBUG "%s: no buffer for rx frame\n",
>  				gp->dev->name);
>  		gp->net_stats.rx_dropped++;
> +		gem_irq_acknowledge(gp, GREG_STAT_RXNOBUF);
>  	}
>  
>  	if (gem_status & GREG_STAT_RXTAGERR) {
> @@ -545,6 +569,7 @@
>  			printk(KERN_DEBUG "%s: corrupt rx tag framing\n",
>  				gp->dev->name);
>  		gp->net_stats.rx_errors++;
> +		gem_irq_acknowledge(gp, GREG_STAT_RXTAGERR);
>  
>  		goto do_reset;
>  	}
> @@ -596,6 +621,8 @@
>  		printk(KERN_DEBUG "%s: tx interrupt, gem_status: 0x%x\n",
>  			gp->dev->name, gem_status);
>  
> +	gem_irq_acknowledge(gp, GREG_STAT_TXALL|GREG_STAT_TXINTME);

Are these in separate functions?  If not, it's usually best to go ahead 
and ACK all the interrupts you are going to handle, in a single IO write 
(usually _before_ you handle the events).


>  	entry = gp->tx_old;
>  	limit = ((gem_status & GREG_STAT_TXNR) >> GREG_STAT_TXNR_SHIFT);
>  	while (entry != limit) {
> @@ -678,7 +705,11 @@
>  	}
>  }
>  
> +#ifdef CONFIG_SUNGEM_NAPI
> +static void gem_rx(struct gem *gp, int *work_done, int work_to_do)
> +#else
>  static void gem_rx(struct gem *gp)
> +#endif
>  {
>  	int entry, drops;
>  	u32 done;
> @@ -687,6 +718,8 @@
>  		printk(KERN_DEBUG "%s: rx interrupt, done: %d, rx_new: %d\n",
>  			gp->dev->name, readl(gp->regs + RXDMA_DONE), gp->rx_new);
>  
> +	gem_irq_acknowledge(gp, GREG_STAT_RXDONE);
> +
>  	entry = gp->rx_new;
>  	drops = 0;
>  	done = readl(gp->regs + RXDMA_DONE);
> @@ -713,6 +746,11 @@
>  				break;
>  		}
>  
> +#ifdef CONFIG_SUNGEM_NAPI
> +		if (*work_done >= work_to_do)
> +			break;
> +
> +#endif
>  		skb = gp->rx_skbs[entry];
>  
>  		len = (status & RXDCTRL_BUFSZ) >> 16;
> @@ -775,7 +813,12 @@
>  		skb->csum = ntohs((status & RXDCTRL_TCPCSUM) ^ 0xffff);
>  		skb->ip_summed = CHECKSUM_HW;
>  		skb->protocol = eth_type_trans(skb, gp->dev);
> +#ifdef CONFIG_SUNGEM_NAPI
> +		netif_receive_skb(skb);
> +		(*work_done)++;

minor nit:  surely it's better code to increment a local variable, then 
store the local to *work_done once all iterations are complete?


> +#else
>  		netif_rx(skb);
> +#endif
>  
>  		gp->net_stats.rx_packets++;
>  		gp->net_stats.rx_bytes += len;
> @@ -798,7 +841,7 @@
>  {
>  	struct net_device *dev = dev_id;
>  	struct gem *gp = dev->priv;
> -	u32 gem_status = readl(gp->regs + GREG_STAT);
> +	u32 gem_status = readl(gp->regs + GREG_STAT2);

what does this do?


>  	/* Swallow interrupts when shutting the chip down */
>  	if (gp->hw_running == 0)
> @@ -810,10 +853,21 @@
>  		if (gem_abnormal_irq(dev, gp, gem_status))
>  			goto out;
>  	}
> +
>  	if (gem_status & (GREG_STAT_TXALL | GREG_STAT_TXINTME))
>  		gem_tx(dev, gp, gem_status);
> -	if (gem_status & GREG_STAT_RXDONE)
> +
> +	if (gem_status & GREG_STAT_RXDONE) {
> +#ifdef CONFIG_SUNGEM_NAPI
> +		if (netif_rx_schedule_prep(dev)) {
> +			/* Disable interrupts and register for poll */
> +			gem_irq_disable(gp);
> +			__netif_rx_schedule(dev);
> +		}
> +#else
>  		gem_rx(gp);
> +#endif
> +	}
>  
>  out:
>  	spin_unlock(&gp->lock);
> @@ -821,6 +875,29 @@
>  	return IRQ_HANDLED;
>  }
>  
> +#ifdef CONFIG_SUNGEM_NAPI
> +static int gem_clean(struct net_device *dev, int *budget)
> +{
> +	struct gem *gp = dev->priv;
> +	int work_to_do = min(*budget, dev->quota);
> +	int work_done = 0;
> +	u32 gem_status = readl(gp->regs + GREG_STAT2);
> +
> +	if (gem_status & GREG_STAT_RXDONE)
> +		gem_rx(gp, &work_done, work_to_do);
> +
> +	*budget -= work_done;
> +	dev->quota -= work_done;
> +
> +	if (work_done < work_to_do || !netif_running(dev)) {
> +		__netif_rx_complete(dev);
> +		gem_irq_enable(gp, GREG_STAT_TXDONE);
> +	}
> +
> +	return (work_done >= work_to_do);
> +}
> +#endif
> +
>  static void gem_tx_timeout(struct net_device *dev)
>  {
>  	struct gem *gp = dev->priv;
> @@ -1018,7 +1096,7 @@
>  	u32 val;
>  
>  	/* Make sure we won't get any more interrupts */
> -	writel(0xffffffff, gp->regs + GREG_IMASK);
> +	gem_irq_disable(gp);
>  
>  	/* Reset the chip */
>  	writel(gp->swrst_base | GREG_SWRST_TXRST | GREG_SWRST_RXRST,
> @@ -1055,7 +1133,7 @@
>  	(void) readl(gp->regs + MAC_RXCFG);
>  	udelay(100);
>  
> -	writel(GREG_STAT_TXDONE, gp->regs + GREG_IMASK);
> +	gem_irq_enable(gp, GREG_STAT_TXDONE);
>  
>  	writel(RX_RING_SIZE - 4, gp->regs + RXDMA_KICK);
>  
> @@ -1323,7 +1401,7 @@
>  		/* Make sure we don't get interrupts or tx packets */
>  		netif_stop_queue(gp->dev);
>  
> -		writel(0xffffffff, gp->regs + GREG_IMASK);
> +		gem_irq_disable(gp);
>  
>  		/* Reset the chip & rings */
>  		gem_stop(gp);
> @@ -2220,7 +2298,7 @@
>  	spin_lock_irq(&gp->lock);
>  
>  	gp->opened = 0;	
> -	writel(0xffffffff, gp->regs + GREG_IMASK);
> +	gem_irq_disable(gp);
>  	netif_stop_queue(dev);
>  
>  	/* Stop chip */
> @@ -2264,7 +2342,7 @@
>  		/* Stop traffic, mark us closed */
>  		netif_device_detach(dev);
>  
> -		writel(0xffffffff, gp->regs + GREG_IMASK);
> +		gem_irq_disable(gp);
>  
>  		/* Stop chip */
>  		gem_stop(gp);

are all these enable/disables inside locks?

	Jeff
