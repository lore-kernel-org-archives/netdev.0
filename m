From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 5/5] net: make mpc5200 fec driver use of_mdio
	infrastructure
Date: Tue, 10 Mar 2009 22:16:38 +0300
Message-ID: <20090310191638.GA8539@oksana.dev.rtsoft.ru>
References: <20090310150751.12455.70598.stgit@localhost.localdomain> <20090310152224.12455.99348.stgit@localhost.localdomain>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:1831 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752674AbZCJTQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 15:16:43 -0400
Content-Disposition: inline
In-Reply-To: <20090310152224.12455.99348.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 09:22:24AM -0600, Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
[...]
> +static int mpc52xx_fec_notifier_phy_add(struct notifier_block *nb,
> +					unsigned long event, void *_dev)
> +{
[...]
> +	rc = phy_connect_direct(priv->ndev, priv->phydev,
> +				mpc52xx_fec_adjust_link, 0, 0);
> +	if (rc) {
> +		dev_err(dev, "phy_connect_direct() failed\n");
> +		return 0;
> +	}
> +
> +	rc = register_netdev(priv->ndev);
> +	if (rc) {
> +		phy_disconnect(priv->phydev);
> +		dev_err(dev, "register_netdev() failed\n");
> +	}
> +
> +	return 0;
> +}
[...]
>  static int __devinit
>  mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
> @@ -896,7 +874,6 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
[...]
> +	/* Register the new network device immediately if we don't need
> +	 * to wait for a phy_device first. */
> +	if (!priv->phy_node) {
> +		if (priv->seven_wire_mode)
> +			dev_info(&ndev->dev, "using 7-wire PHY mode\n");
> +		else
> +			dev_info(&ndev->dev, "Fixed speed MII link: %i%cD\n",
> +				 priv->speed, priv->duplex ? 'F' : 'H');
> +		rv = register_netdev(ndev);
> +		if (rv < 0)
> +			goto probe_error;
>  	}
[...]

Two registration points for the netdev... That's ugly. :-/

What problem are you trying to solve w/ these patches, btw?

`ifconfig ethX up` is safe even w/o PHY attached.

All the (user-visible) changes is that we no longer have "ethX"
until PHY is registered, and I can't say that this is good either.

Previously you'd have ethX all the time, and `ifconfig ethX up`
would report user-friendly "PHY not attached" error. Now we have
to guess why ethX isn't there.

I can't say that the probing code is much prettier or easier to
understand... But maybe there are some other problems that you're
solving, which I don't see so far?

That is, can you explain why the changes are needed? Did you
consider other solutions?


Thanks!

p.s.
> eliminates the assumption that the PHY for the FEC is always
> attached to the FEC's own MDIO bus. With this patch, the FEC can
> use a PHY attached to any MDIO bus if it is described in the device
> tree.

AFAIK, Gianfar and UCC Geth drivers can do this too, so I'm assuming
that this isn't the cause for these major changes.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
