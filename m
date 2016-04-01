From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] Marvell phy: add fiber status check for some components
Date: Fri, 1 Apr 2016 19:08:38 +0200
Message-ID: <20160401170838.GA21633@lunn.ch>
References: <56FE9B5C.6030509@nexvision.fr>
 <56FEA2EC.2030303@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44654 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895AbcDARIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2016 13:08:40 -0400
Content-Disposition: inline
In-Reply-To: <56FEA2EC.2030303@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2016 at 06:33:48PM +0200, Charles-Antoine Couret wrote:

> >From a5a7a9828511ff6a522cf742109768207ff89929 Mon Sep 17 00:00:00 2001
> From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
> Date: Fri, 1 Apr 2016 16:16:35 +0200
> Subject: [PATCH] Marvell phy: add fiber status check for some components
> 
> This patch is not tested with all Marvell's phy. The new function was actived
> only for tested phys.
> 
> Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
> ---
>  drivers/net/phy/marvell.c | 37 +++++++++++++++++++++++++++++++++++--
>  1 file changed, 35 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index ab1d0fc..5ac186e 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -890,6 +890,39 @@ static int marvell_read_status(struct phy_device *phydev)
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
> +		return err;
> +
> +	err = marvell_read_status(phydev);
> +	if (err < 0)
> +		return err;
> +
> +	if (phydev->link)
> +		return 0;
> +
> +	/* If fiber link is down, check and save copper mode state */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
> +	if (err < 0)
> +		return err;
> +
> +	return marvell_read_status(phydev);
> +}

Hi Charles

Shouldn't you return to page 0, i.e. MII_M1111_COPPER, under all
conditions?

	Andrew
