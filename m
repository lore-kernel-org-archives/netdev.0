From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RESEND [PATCH 1/2] net-driver: Drivers don't set IFF_* flag
Date: Thu, 07 Aug 2008 02:24:41 -0400
Message-ID: <489A9529.5010909@pobox.com>
References: <48856C68.2020205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53848 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122AbYHGGYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:24:46 -0400
In-Reply-To: <48856C68.2020205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Some hardware set promisc when they are requested to set IFF_ALLMULTI flag.
> It's ok, but if drivers set IFF_PROMISC flag when they set promisc,
> it will broken upper layer handle for promisc and allmulti.
> In addition, drivers can use their own hardware programming to make it.
> So do not allow drivers to set IFF_* flags.
> 
> This is a general driver fix, so I didn't split it to pieces and send
> to specific driver maintainers.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
> diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
> index dc6e474..e2ce41d 100644
> --- a/drivers/net/3c523.c
> +++ b/drivers/net/3c523.c
> @@ -640,10 +640,8 @@ static int init586(struct net_device *dev)
>  	cfg_cmd->time_low = 0x00;
>  	cfg_cmd->time_high = 0xf2;
>  	cfg_cmd->promisc = 0;
> -	if (dev->flags & (IFF_ALLMULTI | IFF_PROMISC)) {
> +	if (dev->flags & (IFF_ALLMULTI | IFF_PROMISC))
>  		cfg_cmd->promisc = 1;
> -		dev->flags |= IFF_PROMISC;
> -	}
>  	cfg_cmd->carr_coll = 0x00;
>  
>  	p->scb->cbl_offset = make16(cfg_cmd);
> diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
> index 6aca0c6..abc84f7 100644
> --- a/drivers/net/3c527.c
> +++ b/drivers/net/3c527.c
> @@ -1521,14 +1521,11 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
>  	struct mc32_local *lp = netdev_priv(dev);
>  	u16 filt = (1<<2); /* Save Bad Packets, for stats purposes */
>  
> -	if (dev->flags&IFF_PROMISC)
> +	if ((dev->flags&IFF_PROMISC) ||
> +	    (dev->flags&IFF_ALLMULTI) ||
> +	    dev->mc_count > 10)
>  		/* Enable promiscuous mode */
>  		filt |= 1;
> -	else if((dev->flags&IFF_ALLMULTI) || dev->mc_count > 10)
> -	{
> -		dev->flags|=IFF_PROMISC;
> -		filt |= 1;
> -	}
>  	else if(dev->mc_count)
>  	{
>  		unsigned char block[62];
> diff --git a/drivers/net/atp.c b/drivers/net/atp.c
> index 3d44333..c10cd80 100644
> --- a/drivers/net/atp.c
> +++ b/drivers/net/atp.c
> @@ -854,14 +854,9 @@ static void set_rx_mode_8002(struct net_device *dev)
>  	struct net_local *lp = netdev_priv(dev);
>  	long ioaddr = dev->base_addr;
>  
> -	if ( dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC))) {
> -		/* We must make the kernel realise we had to move
> -		 *	into promisc mode or we start all out war on
> -		 *	the cable. - AC
> -		 */
> -		dev->flags|=IFF_PROMISC;
> +	if (dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC)))
>  		lp->addr_mode = CMR2h_PROMISC;
> -	} else
> +	else
>  		lp->addr_mode = CMR2h_Normal;
>  	write_reg_high(ioaddr, CMR2, lp->addr_mode);
>  }
> diff --git a/drivers/net/de620.c b/drivers/net/de620.c
> index 3f5190c..d454e14 100644
> --- a/drivers/net/de620.c
> +++ b/drivers/net/de620.c
> @@ -488,13 +488,6 @@ static void de620_set_multicast_list(struct net_device *dev)
>  {
>  	if (dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
>  	{ /* Enable promiscuous mode */
> -		/*
> -		 *	We must make the kernel realise we had to move
> -		 *	into promisc mode or we start all out war on
> -		 *	the cable. - AC
> -		 */
> -		dev->flags|=IFF_PROMISC;
> -
>  		de620_set_register(dev, W_TCR, (TCR_DEF & ~RXPBM) | RXALL);
>  	}
>  	else
> diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
> index 56f5049..1f11350 100644
> --- a/drivers/net/eepro.c
> +++ b/drivers/net/eepro.c
> @@ -1283,14 +1283,6 @@ set_multicast_list(struct net_device *dev)
>  
>  	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || dev->mc_count > 63)
>  	{
> -		/*
> -		 *	We must make the kernel realise we had to move
> -		 *	into promisc mode or we start all out war on
> -		 *	the cable. If it was a promisc request the
> -		 *	flag is already set. If not we assert it.
> -		 */
> -		dev->flags|=IFF_PROMISC;
> -
>  		eepro_sw2bank2(ioaddr); /* be CAREFUL, BANK 2 now */
>  		mode = inb(ioaddr + REG2);
>  		outb(mode | PRMSC_Mode, ioaddr + REG2);
> diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
> index e3dd8b1..bee8b3f 100644
> --- a/drivers/net/eth16i.c
> +++ b/drivers/net/eth16i.c
> @@ -1356,7 +1356,6 @@ static void eth16i_multicast(struct net_device *dev)
>  
>  	if(dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
>  	{
> -		dev->flags|=IFF_PROMISC;	/* Must do this */
>  		outb(3, ioaddr + RECEIVE_MODE_REG);
>  	} else {
>  		outb(2, ioaddr + RECEIVE_MODE_REG);
> diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
> index 591a7e4..83fa9d8 100644
> --- a/drivers/net/lp486e.c
> +++ b/drivers/net/lp486e.c
> @@ -1272,8 +1272,6 @@ static void set_multicast_list(struct net_device *dev) {
>  			return;
>  		}
>  		if (dev->mc_count == 0 && !(dev->flags & (IFF_PROMISC | IFF_ALLMULTI))) {
> -			if (dev->flags & IFF_ALLMULTI)
> -				dev->flags |= IFF_PROMISC;
>  			lp->i596_config[8] &= ~0x01;
>  		} else {
>  			lp->i596_config[8] |= 0x01;
> diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
> index a20005c..8e0ca9f 100644
> --- a/drivers/net/ni5010.c
> +++ b/drivers/net/ni5010.c
> @@ -648,7 +648,6 @@ static void ni5010_set_multicast_list(struct net_device *dev)
>  	PRINTK2((KERN_DEBUG "%s: entering set_multicast_list\n", dev->name));
>  
>  	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI || dev->mc_list) {
> -		dev->flags |= IFF_PROMISC;
>  		outb(RMD_PROMISC, EDLC_RMODE); /* Enable promiscuous mode */
>  		PRINTK((KERN_DEBUG "%s: Entering promiscuous mode\n", dev->name));
>  	} else {
> diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
> index a316dcc..b9a882d 100644
> --- a/drivers/net/ni52.c
> +++ b/drivers/net/ni52.c
> @@ -621,7 +621,7 @@ static int init586(struct net_device *dev)
>  		if (num_addrs > len) {
>  			printk(KERN_ERR "%s: switching to promisc. mode\n",
>  				dev->name);
> -			dev->flags |= IFF_PROMISC;
> +			writeb(0x01, &cfg_cmd->promisc);
>  		}
>  	}
>  	if (dev->flags & IFF_PROMISC)
> diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
> index 9b2a7f7..e531302 100644
> --- a/drivers/net/sun3_82586.c
> +++ b/drivers/net/sun3_82586.c
> @@ -425,14 +425,11 @@ static int init586(struct net_device *dev)
>  		int len = ((char *) p->iscp - (char *) ptr - 8) / 6;
>  		if(num_addrs > len)	{
>  			printk("%s: switching to promisc. mode\n",dev->name);
> -			dev->flags|=IFF_PROMISC;
> +			cfg_cmd->promisc = 1;
>  		}
>  	}
>  	if(dev->flags&IFF_PROMISC)
> -	{
> -			 cfg_cmd->promisc=1;
> -			 dev->flags|=IFF_PROMISC;
> -	}
> +		cfg_cmd->promisc = 1;
>  	cfg_cmd->carr_coll	= 0x00;
>  
>  	p->scb->cbl_offset	= make16(cfg_cmd);
> diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
> index b047306..1ebcafe 100644
> --- a/drivers/net/wireless/orinoco.c
> +++ b/drivers/net/wireless/orinoco.c
> @@ -1998,13 +1998,6 @@ __orinoco_set_multicast_list(struct net_device *dev)
>  		else
>  			priv->mc_count = mc_count;
>  	}
> -
> -	/* Since we can set the promiscuous flag when it wasn't asked
> -	   for, make sure the net_device knows about it. */
> -	if (priv->promiscuous)
> -		dev->flags |= IFF_PROMISC;
> -	else
> -		dev->flags &= ~IFF_PROMISC;
>  }
>  
>  /* This must be called from user context, without locks held - use
> diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
> index 49ae970..136220b 100644
> --- a/drivers/net/wireless/wavelan.c
> +++ b/drivers/net/wireless/wavelan.c
> @@ -1409,9 +1409,6 @@ static void wavelan_set_multicast_list(struct net_device * dev)
>  			lp->mc_count = 0;
>  
>  			wv_82586_reconfig(dev);
> -
> -			/* Tell the kernel that we are doing a really bad job. */
> -			dev->flags |= IFF_PROMISC;
>  		}
>  	} else
>  		/* Are there multicast addresses to send? */
> diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
> index b584c0e..00a3559 100644
> --- a/drivers/net/wireless/wavelan_cs.c
> +++ b/drivers/net/wireless/wavelan_cs.c
> @@ -1412,9 +1412,6 @@ wavelan_set_multicast_list(struct net_device *	dev)
>  	  lp->mc_count = 0;
>  
>  	  wv_82593_reconfig(dev);
> -
> -	  /* Tell the kernel that we are doing a really bad job... */
> -	  dev->flags |= IFF_PROMISC;
>  	}
>      }
>    else
> @@ -1433,9 +1430,6 @@ wavelan_set_multicast_list(struct net_device *	dev)
>  	    lp->mc_count = 0;
>  
>  	    wv_82593_reconfig(dev);
> -
> -	    /* Tell the kernel that we are doing a really bad job... */
> -	    dev->flags |= IFF_ALLMULTI;

applied


