From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [7/9][PATCH 2.6] Media mode rewrite
Date: Sat, 19 Jun 2004 17:24:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D4AF10.50801@pobox.com>
References: <20040615174942.GA11319@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040615174942.GA11319@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Roger Luethi wrote:
> Remove rhine_check_duplex, rhine_timer and related data structures
> 
> Add rhine_check_media: wrapper for generic mii_check_media, sets duplex
> bit in MAC
> 
> Add rhine_enable_linkmon, rhine_disable_linkmon to enable hardware link
> status monitoring
> 
> Update mdio_read, mdio_write accordingly
> 
> Remove get_intr_status check in rhine_start_tx because we are not racing
> anymore
> 
> Signed-off-by: Roger Luethi <rl@hellgate.ch>
> 
> --- orig/drivers/net/via-rhine.c
> +++ mod/drivers/net/via-rhine.c
> @@ -485,7 +485,6 @@
>  
>  	struct pci_dev *pdev;
>  	struct net_device_stats stats;
> -	struct timer_list timer;	/* Media monitoring timer. */
>  	spinlock_t lock;
>  
>  	/* Frequently used values: keep some adjacent for cache effect. */
> @@ -498,16 +497,12 @@
>  	/* These values are keep track of the transceiver/media in use. */
>  	u8 tx_thresh, rx_thresh;
>  
> -	/* MII transceiver section. */
> -	u16 mii_status;			/* last read MII status */
>  	struct mii_if_info mii_if;
>  };
>  
>  static int  mdio_read(struct net_device *dev, int phy_id, int location);
>  static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
>  static int  rhine_open(struct net_device *dev);
> -static void rhine_check_duplex(struct net_device *dev);
> -static void rhine_timer(unsigned long data);
>  static void rhine_tx_timeout(struct net_device *dev);
>  static int  rhine_start_tx(struct sk_buff *skb, struct net_device *dev);
>  static irqreturn_t rhine_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
> @@ -1032,6 +1027,21 @@
>  	}
>  }
>  
> +static void rhine_check_media(struct net_device *dev, unsigned int init_media)
> +{
> +	struct rhine_private *rp = netdev_priv(dev);
> +	long ioaddr = dev->base_addr;
> +
> +	mii_check_media(&rp->mii_if, debug, init_media);
> +
> +	if (rp->mii_if.full_duplex)
> +	    writeb(readb(ioaddr + ChipCmd1) | Cmd1FDuplex,
> +		   ioaddr + ChipCmd1);
> +	else
> +	    writeb(readb(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
> +		   ioaddr + ChipCmd1);
> +}
> +
>  static void init_registers(struct net_device *dev)
>  {
>  	struct rhine_private *rp = netdev_priv(dev);
> @@ -1047,7 +1057,6 @@
>  	writeb(0x20, ioaddr + TxConfig);
>  	rp->tx_thresh = 0x20;
>  	rp->rx_thresh = 0x60;		/* Written in rhine_set_rx_mode(). */
> -	rp->mii_if.full_duplex = 0;
>  
>  	writel(rp->rx_ring_dma, ioaddr + RxRingPtr);
>  	writel(rp->tx_ring_dma, ioaddr + TxRingPtr);
> @@ -1063,14 +1072,42 @@
>  
>  	writew(CmdStart|CmdTxOn|CmdRxOn|(Cmd1NoTxPoll << 8),
>  	       ioaddr + ChipCmd);
> -	if (rp->mii_if.force_media)
> -		writeb(readb(ioaddr + ChipCmd1) | Cmd1FDuplex,
> -		       ioaddr + ChipCmd1);
> -	else
> -		writeb(readb(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
> -		       ioaddr + ChipCmd1);
> +	rhine_check_media(dev, 1);
> +}
> +
> +/* Enable MII link status auto-polling (required for IntrLinkChange) */
> +static void rhine_enable_linkmon(long ioaddr)
> +{
> +	writeb(0, ioaddr + MIICmd);
> +	writeb(MII_BMSR, ioaddr + MIIRegAddr);
> +	writeb(0x80, ioaddr + MIICmd);
>  
> -	rhine_check_duplex(dev);
> +	RHINE_WAIT_FOR((readb(ioaddr + MIIRegAddr) & 0x20));
> +
> +	writeb(MII_BMSR | 0x40, ioaddr + MIIRegAddr);
> +}
> +
> +/* Disable MII link status auto-polling (required for MDIO access) */
> +static void rhine_disable_linkmon(long ioaddr, u32 quirks)
> +{
> +	writeb(0, ioaddr + MIICmd);
> +
> +	if (quirks & rqRhineI) {
> +		writeb(0x01, ioaddr + MIIRegAddr);	// MII_BMSR
> +
> +		/* Can be called from ISR. Evil. */
> +		mdelay(1);


Net drivers are slowly moving towards schedule_work()/queue_work() for 
doing "slow path" stuff like chip reset or MII phy stuff.

	Jeff
