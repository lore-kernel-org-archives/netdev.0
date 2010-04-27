From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/sb1250: register mdio bus in probe
Date: Tue, 27 Apr 2010 15:52:15 -0700 (PDT)
Message-ID: <20100427.155215.228945283.davem@davemloft.net>
References: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35844
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755088Ab0D0WwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:52:09 -0400
In-Reply-To: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Sun, 25 Apr 2010 23:02:27 +0200

> @@ -2389,9 +2387,23 @@ static int sbmac_init(struct platform_device *pldev, long long base)
>  		sc->mii_bus->irq[i] = SBMAC_PHY_INT;
>  
>  	sc->mii_bus->parent = &pldev->dev;
> +	/*
> +	 * Probe PHY address
> +	 */
> +	err = mdiobus_register(sc->mii_bus);
> +	if (err) {
> +		printk(KERN_ERR "%s: unable to register MDIO bus\n",
> +		       dev->name);
> +		goto free_mdio;
> +	}
>  	dev_set_drvdata(&pldev->dev, sc->mii_bus);
> -
>  	return 0;
> +
> +free_mdio:
> +	mdiobus_free(sc->mii_bus);
> +uninit_ctx:
> +	sbmac_uninitctx(sc);
> +	return err;

This is buggy, you're leaving the netdev registered in the
mdiobus_register() error path.

Furthermore, you really can't make any fail'able calls after
register_netdev() in your probe function.  So you'll have to see if
you can do the mdiobus probe before that call.

Once the netdev is registered, it shows up in sysfs, udev can notice
it, and therefore code will try to bring the device up by calling the
device's open method, etc.  Therefore, it really is a point of no
return.
