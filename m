From: Andreas Henriksson <andreas@fjortis.info>
Subject: Re: fealnx oopses (with [PATCH])
Date: Wed, 31 Mar 2004 21:24:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331192421.GA30048@scream.fjortis.info>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <4068AC87.2030506@pobox.com> <200403300118.55631.vda@port.imtp.ilyichevsk.odessa.ua> <200403311839.33202.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Francois Romieu <romieu@fr.zoreil.com>,
        Andreas Henriksson <andreas@fjortis.info>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200403311839.33202.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2004 at 06:39:33PM +0200, Denis Vlasenko wrote:
> 
> Ok, here is what I have now.
> 
> What we had before:
> original behaviour: Andreas had tx tomeouts, I had fatal oops.

I had tx-related kernel panic with vanilla driver on my p-166.

> francois+jgarzik patch: Andreas happy, I had lockup (endless 'Too much work')
> 

with spin_lock_irqsave in start_tx I haven't been able to trigger the
panic on my p3-600 .. (Although, I don't know if it actually fixed the
problem or if it's just harder to trigger on a faster machine.. but I've
been moving ALOT of data so even if it's 10 or 100 times hard I should
have triggered it by now..)

so jgarzik's patch is enough to make me happy... no more panic but I
still see this which is annoying when trying to do interactive stuff
over the network:

-- snip --
NETDEV WATCHDOG: eth1: transmit timed out
eth1: Transmit timed out, status 00000000, resetting...
NETDEV WATCHDOG: eth1: transmit timed out
eth1: Transmit timed out, status 00000000, resetting...
NETDEV WATCHDOG: eth1: transmit timed out
eth1: Transmit timed out, status 00000000, resetting...
-- snip --

> Now, with the attached patch, I *don't* lock up. I can ctrl-C
> netcat, UDP flood stops and card is alive, tested with pinging.
> 
> I modified 'Too much work in interrupt' code.
> I added code which completely stops rx and tx and schedules
> card reset a-la reset previously used in tx_timeout code path.
> There is 1 second delay.
>

To me it doesn't seem better nor worse then before... so I guess if it
helps you in any way, good.

> 
> In testing, I saw this code triggering a number of times.
> It works as intended.
> 
> I also have seen tx timeout events. (I touched that code a bit,
> factoring out reset code, but without changing logic). They did
> not hang the box, either, but box was unable to do any tx.
> tx timeouts just happened again and again.
> Remote side decided that we are gone and stopped UDP flood,
> starting ARP address resolution instead, but test box could
> not answer even that.
> 
> In this state I can ctrl-C local netcat and box recovers
> after several seconds. Tx is working again, I can ping other
> hosts, etc.
> 
> I conclude that tx timeout logic does not handle situation
> when *local* process generates and submits tons of packets
> at enormous rate.
> 
> Now, the patch itself. It is against 2.4.25.
> Sorry, it contains some debugging stuff and some future work
> (e.g. #defines). I decided to not remove it now to avoid
> brown paper bugs. (I can remove and retest, but testing can
> take another couple of hours...)
>

applies easily to 2.6 too, with some offset and fuzz and 1 reject that
is really easy to fix manually.

> 
> I can code tx timeout similarly to 'Too much work', but I
> retained it 'as is' in hopes of your comments on both
> code paths.
> --
> vda
> 

> --- fealnx.c.original	Fri Nov 28 20:26:20 2003
> +++ fealnx.c	Wed Mar 31 17:26:57 2004
> @@ -210,6 +210,26 @@
>  	BPREMRPSR = 0x5c,	/* bypass & receive error mask and phy status */
>  };
>  
> +//vda: TCRRCR values collected from code: W for writing, R for reading
> +#define CR_W_ENH	0x02000000	/* enhanced mode */
> +#define CR_W_FD		0x00100000	/* full duplex */
> +#define CR_W_PS10	0x00080000	/* 10 mbit */
> +#define CR_W_TXEN	0x00040000	/* tx enable */
> +#define CR_W_PS1000	0x00010000	/* 1000 mbit */
> +#define CR_W_RXMASK	0x000000e0
> +#define CR_W_PROM	0x00000080	/* promiscuous mode */
> +#define CR_W_AB		0x00000040	/* accept broadcast */
> +#define CR_W_AM		0x00000020	/* accept mutlicast */
> +#define CR_W_ARP	0x00000008	/* receive runt pkt */
> +#define CR_W_ALP	0x00000004	/* receive long pkt */
> +#define CR_W_SEP	0x00000002	/* receive error pkt */
> +#define CR_W_RXEN	0x00000001	/* rx enable (unicast?) */
> +
> +#define CR_R_TXSTOP	0x04000000	/* tx stopped */
> +#define CR_R_FD		0x00100000	/* full duplex detected */
> +#define CR_R_PS10	0x00080000	/* 10 mbit detected */
> +#define CR_R_RXSTOP	0x00008000	/* rx stopped */
> +
>  /* Bits in the interrupt status/enable registers. */
>  /* The bits in the Intr Status/Enable registers, mostly interrupt sources. */
>  enum intr_status_bits {
> @@ -401,6 +421,12 @@
>  	/* Media monitoring timer. */
>  	struct timer_list timer;
>  
> +	/* Reset timer */ //vda:
> +	struct timer_list reset_timer;
> +	int reset_timer_armed;
> +	unsigned long crvalue_sv;
> +	unsigned long imrvalue_sv;
> +
>  	/* Frequently used values: keep some adjacent for cache effect. */
>  	int flags;
>  	struct pci_dev *pci_dev;
> @@ -436,6 +462,7 @@
>  static void getlinktype(struct net_device *dev);
>  static void getlinkstatus(struct net_device *dev);
>  static void netdev_timer(unsigned long data);
> +static void reset_timer(unsigned long data); //vda:
>  static void tx_timeout(struct net_device *dev);
>  static void init_ring(struct net_device *dev);
>  static int start_tx(struct sk_buff *skb, struct net_device *dev);
> @@ -478,6 +505,19 @@
>  }
>  
>  
> +void stop_nic_rxtx(long ioaddr, long crvalue) //vda:
> +{
> +	int delay = 0x1000;
> +	writel(crvalue & (~0x40001), ioaddr + TCRRCR);
> +
> +	/* wait for rx and tx stop */
> +	while(delay--) {
> +		int t = readl(ioaddr + TCRRCR);
> +		if( (t & 0x04008000) == 0x04008000 ) break;
> +	}
> +}
> +
> +
>  
>  static int __devinit fealnx_init_one(struct pci_dev *pdev,
>  				     const struct pci_device_id *ent)
> @@ -666,7 +706,7 @@
>  	dev->hard_start_xmit = &start_tx;
>  	dev->stop = &netdev_close;
>  	dev->get_stats = &get_stats;
> -	dev->set_multicast_list = &set_rx_mode;
> +	dev->set_multicast_list = &set_rx_mode;  //vda: hmm... set_rx_mode needs locking? TODO
>  	dev->do_ioctl = &mii_ioctl;
>  	dev->ethtool_ops = &netdev_ethtool_ops;
>  	dev->tx_timeout = tx_timeout;
> @@ -723,7 +763,8 @@
>  
>  unsigned int m80x_read_tick(void)
>  /* function: Reads the Timer tick count register which decrements by 2 from  */
> -/*           65536 to 0 every 1/36.414 of a second. Each 2 decrements of the *//*           count represents 838 nsec's.                                    */
> +/*           65536 to 0 every 1/36.414 of a second. Each 2 decrements of the */
> +/*           count represents 838 nsec's.                                    */
>  /* input   : none.                                                           */
>  /* output  : none.                                                           */
>  {
> @@ -985,6 +1026,11 @@
>  	/* timer handler */
>  	add_timer(&np->timer);
>  
> +	init_timer(&np->reset_timer); //vda:
> +	np->reset_timer.data = (unsigned long) dev;
> +	np->reset_timer.function = &reset_timer;
> +	np->reset_timer_armed = 0;
> +
>  	return 0;
>  }
>  
> @@ -1134,15 +1180,17 @@
>  		struct sk_buff *skb;
>  
>  		skb = dev_alloc_skb(np->rx_buf_sz);
> -		np->lack_rxbuf->skbuff = skb;
> -
>  		if (skb == NULL)
>  			break;	/* Better luck next round. */
>  
> +		while (np->lack_rxbuf->skbuff)
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
> @@ -1156,19 +1204,25 @@
>  	int next_tick = 10 * HZ;
>  	int old_crvalue = np->crvalue;
>  	unsigned int old_linkok = np->linkok;
> +	unsigned long flags;
>  
>  	if (debug)
>  		printk(KERN_DEBUG "%s: Media selection timer tick, status %8.8x "
>  		       "config %8.8x.\n", dev->name, readl(ioaddr + ISR),
>  		       readl(ioaddr + TCRRCR));
>  
> +	spin_lock_irqsave(&np->lock, flags); //vda:
> +	
>  	if (np->flags == HAS_MII_XCVR) {
>  		getlinkstatus(dev);
>  		if ((old_linkok == 0) && (np->linkok == 1)) {	/* we need to detect the media type again */
>  			getlinktype(dev);
>  			if (np->crvalue != old_crvalue) {
> -				stop_nic_tx(ioaddr, np->crvalue);
> -				stop_nic_rx(ioaddr, np->crvalue & (~0x40000));
> +				//vda: stop_nic_tx(ioaddr, np->crvalue);
> +				//stop_nic_rx(ioaddr, np->crvalue & (~0x40000));
> +				/* stop rx,tx and start again, */
> +				/* this switches us to new mode */
> +				stop_nic_rxtx(ioaddr, np->crvalue);
>  				writel(np->crvalue, ioaddr + TCRRCR);
>  			}
>  		}
> @@ -1176,36 +1230,22 @@
>  
>  	allocate_rx_buffers(dev);
>  
> +	spin_unlock_irqrestore(&np->lock, flags);
> +
>  	np->timer.expires = RUN_AT(next_tick);
>  	add_timer(&np->timer);
>  }
>  
> -
> -static void tx_timeout(struct net_device *dev)
> +/* Reinit. Gross */
> +static void vda_reset_disable_rxtx(struct net_device *dev) //vda:
>  {
>  	struct netdev_private *np = dev->priv;
>  	long ioaddr = dev->base_addr;
>  	int i;
>  
> -	printk(KERN_WARNING "%s: Transmit timed out, status %8.8x,"
> -	       " resetting...\n", dev->name, readl(ioaddr + ISR));
> -
> -	{
> -
> -		printk(KERN_DEBUG "  Rx ring %p: ", np->rx_ring);
> -		for (i = 0; i < RX_RING_SIZE; i++)
> -			printk(" %8.8x", (unsigned int) np->rx_ring[i].status);
> -		printk("\n" KERN_DEBUG "  Tx ring %p: ", np->tx_ring);
> -		for (i = 0; i < TX_RING_SIZE; i++)
> -			printk(" %4.4x", np->tx_ring[i].status);
> -		printk("\n");
> -	}
> -
> -	/* Reinit. Gross */
> -
>  	/* Reset the chip's Tx and Rx processes. */
> -	stop_nic_tx(ioaddr, 0);
> -	reset_rx_descriptors(dev);
> +	stop_nic_rxtx(ioaddr, 0);
> +	//reset_rx_descriptors(dev); //moved down: contains stop_nic_rx(ioaddr, np->crvalue)!
>  
>  	/* Disable interrupts by clearing the interrupt mask. */
>  	writel(0x0000, ioaddr + IMR);
> @@ -1219,6 +1259,14 @@
>  		readl(ioaddr + BCR);
>  		rmb();
>  	}
> +}
> +
> +static void vda_enable_rxtx(struct net_device *dev) //vda:
> +{
> +	struct netdev_private *np = dev->priv;
> +	long ioaddr = dev->base_addr;
> +
> +	reset_rx_descriptors(dev); // contains stop_nic_rx(ioaddr, np->crvalue)
>  
>  	writel((np->cur_tx - np->tx_ring)*sizeof(struct fealnx_desc) +
>  		np->tx_ring_dma, ioaddr + TXLBA);
> @@ -1227,18 +1275,66 @@
>  
>  	writel(np->bcrvalue, ioaddr + BCR);
>  
> -	writel(0, dev->base_addr + RXPDR);
> -	set_rx_mode(dev);
> +	writel(0, ioaddr + RXPDR); // is order of these ok?
> +	set_rx_mode(dev); // changes np->crvalue, writes TCRRCR
> +
>  	/* Clear and Enable interrupts by setting the interrupt mask. */
>  	writel(FBE | TUNF | CNTOVF | RBU | TI | RI, ioaddr + ISR);
>  	writel(np->imrvalue, ioaddr + IMR);
>  
> -	writel(0, dev->base_addr + TXPDR);
> +	writel(0, ioaddr + TXPDR);
> +}
> +
> +static void reset_timer(unsigned long data) //vda:
> +{
> +	struct net_device *dev = (struct net_device *) data;
> +	struct netdev_private *np = dev->priv;
> +	unsigned long flags;
> +
> +	printk(KERN_WARNING "%s: resetting tx and rx machinery\n", dev->name);
> +
> +	spin_lock_irqsave(&np->lock, flags);
> +	np->crvalue = np->crvalue_sv;
> +	np->imrvalue = np->imrvalue_sv;
> +
> +	vda_reset_disable_rxtx(dev);
> +	vda_enable_rxtx(dev);
> +	netif_start_queue(dev); // netif_tx_enable(dev) doesn't exist, right?
> +		
> +	np->reset_timer_armed = 0;
> +
> +	spin_unlock_irqrestore(&np->lock, flags);
> +}
> +
> +
> +static void tx_timeout(struct net_device *dev)
> +{
> +	struct netdev_private *np = dev->priv;
> +	long ioaddr = dev->base_addr;
> +	unsigned long flags;
> +	int i;
> +
> +	printk(KERN_WARNING "%s: Transmit timed out, status %8.8x,"
> +	       " resetting...\n", dev->name, readl(ioaddr + ISR));
> +
> +	{
> +
> +		printk(KERN_DEBUG "  Rx ring %p: ", np->rx_ring);
> +		for (i = 0; i < RX_RING_SIZE; i++)
> +			printk(" %8.8x", (unsigned int) np->rx_ring[i].status);
> +		printk("\n" KERN_DEBUG "  Tx ring %p: ", np->tx_ring);
> +		for (i = 0; i < TX_RING_SIZE; i++)
> +			printk(" %4.4x", np->tx_ring[i].status);
> +		printk("\n");
> +	}
> +	
> +	spin_lock_irqsave(&np->lock, flags); //vda:
> +	vda_reset_disable_rxtx(dev);
> +	vda_enable_rxtx(dev);
> +	spin_unlock_irqrestore(&np->lock, flags);
>  
>  	dev->trans_start = jiffies;
>  	np->stats.tx_errors++;
> -
> -	return;
>  }
>  
>  
> @@ -1251,7 +1347,7 @@
>  	/* initialize rx variables */
>  	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
>  	np->cur_rx = &np->rx_ring[0];
> -	np->lack_rxbuf = NULL;
> +	np->lack_rxbuf = np->rx_ring;
>  	np->really_rx_count = 0;
>  
>  	/* initial rx descriptors. */
> @@ -1303,14 +1399,15 @@
>  	/* for the last tx descriptor */
>  	np->tx_ring[i - 1].next_desc = np->tx_ring_dma;
>  	np->tx_ring[i - 1].next_desc_logical = &np->tx_ring[0];
> -
> -	return;
>  }
>  
>  
>  static int start_tx(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct netdev_private *np = dev->priv;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&np->lock, flags);
>  
>  	np->cur_tx_copy->skbuff = skb;
>  
> @@ -1340,7 +1437,7 @@
>  		np->cur_tx_copy->control |= (BPT << TBSShift);	/* buffer size */
>  
>  		/* for the last descriptor */
> -		next = (struct fealnx *) np->cur_tx_copy.next_desc_logical;
> +		next = np->cur_tx_copy.next_desc_logical;
>  		next->skbuff = skb;
>  		next->control = TXIC | TXLD | CRCEnable | PADEnable;
>  		next->control |= (skb->len << PKTSShift);	/* pkt size */
> @@ -1377,36 +1474,26 @@
>  	writel(0, dev->base_addr + TXPDR);
>  	dev->trans_start = jiffies;
>  
> +	spin_unlock_irqrestore(&np->lock, flags);
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
> @@ -1423,6 +1510,8 @@
>  	unsigned int num_tx = 0;
>  	int handled = 0;
>  
> +	spin_lock(&np->lock);
> +
>  	writel(0, dev->base_addr + IMR);
>  
>  	ioaddr = dev->base_addr;
> @@ -1548,6 +1637,23 @@
>  		if (--boguscnt < 0) {
>  			printk(KERN_WARNING "%s: Too much work at interrupt, "
>  			       "status=0x%4.4x.\n", dev->name, intr_status);
> +			if(!np->reset_timer_armed) { //vda:
> +				printk(KERN_WARNING "scheduling card reset\n");
> +				np->reset_timer.expires = RUN_AT(HZ/2);
> +				add_timer(&np->reset_timer);
> +				np->reset_timer_armed = 1;
> +				//taken from reset code:
> +				//stop_nic_tx(ioaddr, 0); //stop tx
> +				
> +				// without this, I've seen one lockup and one 'forever stuck tx' event
> +				stop_nic_rxtx(ioaddr, 0); //stop rx
> +				netif_stop_queue(dev); // or netif_tx_disable(dev);??
> +				/* Prevent other codepaths from enabling tx,rx,intrs */
> +				np->crvalue_sv = np->crvalue;
> +				np->crvalue &= ~(CR_W_TXEN | CR_W_RXEN); // or simply = 0?
> +				np->imrvalue_sv = np->imrvalue;
> +				np->imrvalue = 0;
> +			}
>  			break;
>  		}
>  	} while (1);
> @@ -1564,6 +1670,8 @@
>  		       dev->name, readl(ioaddr + ISR));
>  
>  	writel(np->imrvalue, ioaddr + IMR);
> +out_unlock:
> +	spin_unlock(&np->lock);
>  
>  	return IRQ_RETVAL(handled);
>  }
> @@ -1575,12 +1683,25 @@
>  {
>  	struct netdev_private *np = dev->priv;
>  
> +	//if( ! (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) ) { //vda:
> +	//	printk(KERN_ERR "netdev_rx(): nothing to do?! (np->cur_rx->status & RXOWN) == 0x%04x, np->cur_rx->skbuff == %p\n"
> +	//		,(np->cur_rx->status & RXOWN)
> +	//		,np->cur_rx->skbuff
> +	//	);
> +	//}
> +
> +	//if (np->really_rx_count == 0) { //vda:
> +	//	printk(KERN_ERR "netdev_rx(): np->really_rx_count is 0 before while()\n");
> +	//}
> +	
>  	/* If EOP is set on the next entry, it's a new packet. Send it up. */
> -	while (!(np->cur_rx->status & RXOWN)) {
> +	while (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) {
>  		s32 rx_status = np->cur_rx->status;
>  
> -		if (np->really_rx_count == 0)
> -			break;
> +		//if (np->really_rx_count == 0) {
> +		//	printk(KERN_ERR "netdev_rx(): np->really_rx_count reached 0\n"); //vda:
> +		//	break;
> +		//}
>  
>  		if (debug)
>  			printk(KERN_DEBUG "  netdev_rx() status was %8.8x.\n", rx_status);
> @@ -1628,8 +1749,15 @@
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
> @@ -1671,8 +1799,6 @@
>  			} else {
>  				skb_put(skb = np->cur_rx->skbuff, pkt_len);
>  				np->cur_rx->skbuff = NULL;
> -				if (np->really_rx_count == RX_RING_SIZE)
> -					np->lack_rxbuf = np->cur_rx;
>  				--np->really_rx_count;
>  			}
>  			skb->protocol = eth_type_trans(skb, dev);
> @@ -1682,22 +1808,7 @@
>  			np->stats.rx_bytes += pkt_len;
>  		}

-------------------------------------

this is the part that I got a reject for on 2.6:

pci_map_single's arguments where slit on one row for each argument.

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

------------------------------

>  
>  	/*  allocate skb for rx buffers */
> @@ -1752,8 +1863,10 @@
>  		rx_mode = AB | AM;
>  	}
>  
> -	stop_nic_tx(ioaddr, np->crvalue);
> -	stop_nic_rx(ioaddr, np->crvalue & (~0x40000));
> +	//vda:
> +	//stop_nic_tx(ioaddr, np->crvalue);
> +	//stop_nic_rx(ioaddr, np->crvalue & (~0x40000));
> +	stop_nic_rxtx(ioaddr, np->crvalue);
>  
>  	writel(mc_filter[0], ioaddr + MAR0);
>  	writel(mc_filter[1], ioaddr + MAR1);
