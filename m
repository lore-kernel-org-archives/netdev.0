From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net/smsc911x: Move interrupt allocation to open/stop
Date: Thu, 1 Sep 2016 19:06:17 +0200
Message-ID: <20160901170617.GD10951@lunn.ch>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
 <1472747141-15886-3-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757200AbcIAVXz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:23:55 -0400
Content-Disposition: inline
In-Reply-To: <1472747141-15886-3-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeremy 

Please don't add forward references. Move the function earlier in the
file.

>  static inline u32 __smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
>  {
>  	if (pdata->config.flags & SMSC911X_USE_32BIT)
> @@ -1514,6 +1516,7 @@ static int smsc911x_open(struct net_device *dev)
>  	unsigned int temp;
>  	unsigned int intcfg;
>  	int retval;
> +	int irq_flags;
>  
>  	/* find and start the given phy */
>  	if (!dev->phydev) {
> @@ -1584,6 +1587,14 @@ static int smsc911x_open(struct net_device *dev)
>  	pdata->software_irq_signal = 0;
>  	smp_wmb();
>  
> +	irq_flags = irq_get_trigger_type(dev->irq);
> +	if (request_irq(dev->irq, smsc911x_irqhandler,
> +			irq_flags | IRQF_SHARED, dev->name, dev)) {
> +		SMSC_WARN(pdata, probe,
> +			  "Unable to claim requested irq: %d", dev->irq);
> +		goto mii_free_out;
> +	}
> +
>  	temp = smsc911x_reg_read(pdata, INT_EN);
>  	temp |= INT_EN_SW_INT_EN_;
>  	smsc911x_reg_write(pdata, INT_EN, temp);
> @@ -1599,7 +1610,7 @@ static int smsc911x_open(struct net_device *dev)
>  		netdev_warn(dev, "ISR failed signaling test (IRQ %d)\n",
>  			    dev->irq);
>  		retval = -ENODEV;
> -		goto mii_free_out;
> +		goto irq_stop_out;
>  	}
>  	SMSC_TRACE(pdata, ifup, "IRQ handler passed test using IRQ %d",
>  		   dev->irq);
> @@ -1645,7 +1656,8 @@ static int smsc911x_open(struct net_device *dev)
>  
>  	netif_start_queue(dev);
>  	return 0;
> -
> +irq_stop_out:
> +	free_irq(dev->irq, dev);
>  mii_free_out:
>  	phy_disconnect(dev->phydev);
>  	dev->phydev = NULL;
> @@ -1672,12 +1684,15 @@ static int smsc911x_stop(struct net_device *dev)
>  	dev->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
>  	smsc911x_tx_update_txcounters(dev);
>  
> +	free_irq(dev->irq, dev);
> +
>  	/* Bring the PHY down */
>  	if (dev->phydev) {
>  		phy_stop(dev->phydev);
>  		phy_disconnect(dev->phydev);
>  		dev->phydev = NULL;
>  	}
> +	netif_carrier_off(dev);

What has this change got to do with interrupt handling?

> @@ -2479,38 +2491,18 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>  	if (retval < 0)
>  		goto out_disable_resources;
>  
> -	/* configure irq polarity and type before connecting isr */
> -	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
> -		intcfg |= INT_CFG_IRQ_POL_;
> -
> -	if (pdata->config.irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
> -		intcfg |= INT_CFG_IRQ_TYPE_;
> -
> -	smsc911x_reg_write(pdata, INT_CFG, intcfg);


I see these removes, but where are the adds?

  Andrew
