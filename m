From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: smsc911x: Fix register_netdev, phy startup,
 driver unload ordering
Date: Thu, 1 Sep 2016 18:58:06 +0200
Message-ID: <20160901165806.GC10951@lunn.ch>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
 <1472747141-15886-2-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756972AbcIAVX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:23:56 -0400
Content-Disposition: inline
In-Reply-To: <1472747141-15886-2-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -1520,17 +1513,22 @@ static int smsc911x_open(struct net_device *dev)
>  	unsigned int timeout;
>  	unsigned int temp;
>  	unsigned int intcfg;
> +	int retval;
>  
> -	/* if the phy is not yet registered, retry later*/
> +	/* find and start the given phy */
>  	if (!dev->phydev) {
> -		SMSC_WARN(pdata, hw, "phy_dev is NULL");
> -		return -EAGAIN;
> +		if (smsc911x_mii_probe(dev) < 0) {
> +			SMSC_WARN(pdata, probe, "Error starting phy");
> +			retval = -EAGAIN;

smsc911x_mii_probe() returns an error code. It is better to use that,
than -EAGAIN, which is rather odd to start with.

> +			goto out;
> +		}
>  	}
>  
>  	/* Reset the LAN911x */
>  	if (smsc911x_soft_reset(pdata)) {
>  		SMSC_WARN(pdata, hw, "soft reset failed");
> -		return -EIO;
> +		retval = -EIO;
> +		goto mii_free_out;

smsc911x_soft_reset() also returns an error code you should use.

This patch also seems to do quite a few different things. Please can
you break it up into multiple patches.

Thanks
	Andrew
