From: Felipe W Damasio <felipewd@terra.com.br>
Subject: Re: ALTPATCH: 8139cp: LinkChg support
Date: 20 Sep 2002 04:09:43 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1032494983.247.70.camel@tank>
References: <1032487254.247.7.camel@tank>
	<3D8ABCEF.9060207@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
In-Reply-To: <3D8ABCEF.9060207@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2002-09-20 at 06:15, Jeff Garzik wrote:
> diff -Nru a/drivers/net/mii.c b/drivers/net/mii.c
> --- a/drivers/net/mii.c	Fri Sep 20 02:13:15 2002
> +++ b/drivers/net/mii.c	Fri Sep 20 02:13:15 2002
> @@ -170,6 +170,75 @@
>  	return r;
>  }
>  
> +void mii_check_link (struct mii_if_info *mii)
> +{
> +	if (mii_link_ok(mii))
> +		netif_carrier_on(mii->dev);
> +	else
> +		netif_carrier_off(mii->dev);
> +}
> +
> +unsigned int mii_check_media (struct mii_if_info *mii, unsigned int ok_to_print)
> +{
> +	unsigned int old_carrier, new_carrier;
> +	int advertise, lpa, media, duplex;

	Shouldn't advertise and lpa be either "unsigned short" or u16?

> +
> +	/* if forced media, go no further */
> +	if (mii->duplex_lock)
> +		return 0; /* duplex did not change */
> +
> +	/* check current and old link status */
> +	old_carrier = netif_carrier_ok(mii->dev) ? 1 : 0;
> +	new_carrier = (unsigned int) mii_link_ok(mii);
> +
> +	/* if carrier state did not change, this is a "bounce",
> +	 * just exit as everything is already set correctly
> +	 */
> +	if (old_carrier == new_carrier)
> +		return 0; /* duplex did not change */
> +
> +	/* no carrier, nothing much to do */
> +	if (!new_carrier) {
> +		netif_carrier_off(mii->dev);
> +		if (ok_to_print)
> +			printk(KERN_INFO "%s: link down\n", mii->dev->name);
> +		return 0; /* duplex did not change */
> +	}
> +
> +	/*
> +	 * we have carrier, see who's on the other end
> +	 */
> +	netif_carrier_on(mii->dev);
> +
> +	/* get MII advertise and LPA values */
> +	if (mii->advertising)
> +		advertise = mii->advertising;
> +	else {
> +		advertise = mii->mdio_read(mii->dev, mii->phy_id, MII_ADVERTISE);
> +		mii->advertising = advertise;
> +	}
> +	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
> +
> +	/* figure out media and duplex from advertise and LPA values */
> +	media = mii_nway_result(lpa & advertise);
        ^^^^^^^^^^^^^^^^^^^^^^^ 

	mii_nway_result returns a "unsigned int", so media also doesn't look
good.

> +	duplex = (media & (ADVERTISE_100FULL | ADVERTISE_10FULL)) ? 1 : 0;

	Or we could do

	duplex = (media & ADVERTISE_FULL) ? 1 : 0;

Felipe
