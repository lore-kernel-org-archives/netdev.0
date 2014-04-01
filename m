From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] net: sxgbe: sxgbe_mdio_register() frees the bus
Date: Tue, 01 Apr 2014 16:23:22 -0400 (EDT)
Message-ID: <20140401.162322.2243641448457002118.davem@davemloft.net>
References: <20140401133844.GA11536@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbaDAUXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:23:24 -0400
In-Reply-To: <20140401133844.GA11536@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 1 Apr 2014 16:38:44 +0300

> @@ -219,13 +219,6 @@ int sxgbe_mdio_register(struct net_device *ndev)
>  		}
>  	}
>  
> -	if (!err) {
> -		netdev_err(ndev, "PHY not found\n");
> -		mdiobus_unregister(mdio_bus);
> -		mdiobus_free(mdio_bus);
> -		goto mdiobus_err;
> -	}
> -
...
> @@ -93,9 +93,9 @@ static void sxgbe_core_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
>  {
>  	u32 high_word, low_word;
>  
> -	high_word = (addr[5] << 8) || (addr[4]);
> -	low_word = ((addr[3] << 24) || (addr[2] << 16) ||
> -		    (addr[1] << 8) || (addr[0]));
> +	high_word = (addr[5] << 8) | (addr[4]);
> +	low_word = (addr[3] << 24) | (addr[2] << 16) |
> +		   (addr[1] << 8) | (addr[0]);
>  	writel(high_word, ioaddr + SXGBE_CORE_ADD_HIGHOFFSET(reg_n));
>  	writel(low_word, ioaddr + SXGBE_CORE_ADD_LOWOFFSET(reg_n));
>  }

Nothing says "DRIVER NOT TESTED" like these two bugs.

The MDIO bus is always freed, and the MAC address is corrupted
into a boolean value before being programmed into the hardware.

Frankly, this kind of stuff is unacceptable.

I cannot see how this driver can function successfully with
these two errors, it looks simply impossible.

I'm not going to hide my feelings, this was a truly terrible driver
submission.  The amount of reviewing resources consumed during all
of these iterations was huge, and it still went in with bugs like
this.

It probably should have gone into staging.
