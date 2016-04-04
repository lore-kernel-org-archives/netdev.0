From: Andrew Lunn <andrew@lunn.ch>
Subject: FWD: [PATCH v2] Marvell phy: add fiber status check for some
 components
Date: Mon, 4 Apr 2016 15:25:52 +0200
Message-ID: <20160404132552.GH21828@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	charles-antoine.couret@nexvision.fr
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45798 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755263AbcDDNZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 09:25:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >From 564b767163d19355a3b5efaad195e93796570c71 Mon Sep 17 00:00:00 2001
> From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
> Date: Fri, 1 Apr 2016 16:16:35 +0200
> Subject: [PATCH] Marvell phy: add fiber status check for some components
> 
> Marvell's phy could have two modes: fiber and copper. Currently, the driver
> checks only the copper mode registers to get the status link which could be
> wrong.
> 
> This commit add a handler to check fiber then copper status link.
> If the fiber link is activated, the driver would use this information.
> Else, it would use the copper status.

Hi Florian

What do you think about this?

This works for basic status information. But what about other ethtool
options? Setting the speed and duplex, turning pause on/off, etc.

Do we actually need to stay on page 1 if fibre is in use? How do we
initially change to page 1 when the fibre link is still down?

Should we be using the old mechanism to swap between TP, BNC and AUI
to swap between copper and fibre?

   Andrew

> 
> This patch is not tested with all Marvell's phy.
> The new function is actived only for tested phys.
> 
> Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
> ---
>  drivers/net/phy/marvell.c | 43 +++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 41 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index ab1d0fc..22552ab 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -890,6 +890,45 @@ static int marvell_read_status(struct phy_device *phydev)
>  	return 0;
>  }
>  
> +/* marvell_read_fiber_status
> + *
> + * Some Marvell's phys have two modes: fiber and copper.
> + * Both need status checked.
> + * Description:
> + *   First, check the fiber link and status.
> + *   If the fiber link is down, check the copper link and status which
> + *   will be the default value if both link are down.
> + */
> +static int marvell_read_fiber_status(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* Check the fiber mode first */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> +	if (err < 0)
> +		goto error;
> +
> +	err = marvell_read_status(phydev);
> +	if (err < 0)
> +		goto error;
> +
> +	if (phydev->link) {
> +		phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +		return 0;
> +	}
> +
> +	/* If fiber link is down, check and save copper mode state */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	if (err < 0)
> +		goto error;
> +
> +	return marvell_read_status(phydev);
> +
> +error:
> +	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	return err;
> +}
> +
>  static int marvell_aneg_done(struct phy_device *phydev)
>  {
>  	int retval = phy_read(phydev, MII_M1011_PHY_STATUS);
> @@ -1122,7 +1161,7 @@ static struct phy_driver marvell_drivers[] = {
>  		.probe = marvell_probe,
>  		.config_init = &m88e1111_config_init,
>  		.config_aneg = &marvell_config_aneg,
> -		.read_status = &marvell_read_status,
> +		.read_status = &marvell_read_fiber_status,
>  		.ack_interrupt = &marvell_ack_interrupt,
>  		.config_intr = &marvell_config_intr,
>  		.resume = &genphy_resume,
> @@ -1270,7 +1309,7 @@ static struct phy_driver marvell_drivers[] = {
>  		.probe = marvell_probe,
>  		.config_init = &marvell_config_init,
>  		.config_aneg = &m88e1510_config_aneg,
> -		.read_status = &marvell_read_status,
> +		.read_status = &marvell_read_fiber_status,
>  		.ack_interrupt = &marvell_ack_interrupt,
>  		.config_intr = &marvell_config_intr,
>  		.did_interrupt = &m88e1121_did_interrupt,
> -- 
> 2.5.5
> 
> 
> 
> ----- End forwarded message -----
> 
