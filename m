From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 10:19:01 -0800
Message-ID: <56C21695.1030809@gmail.com>
References: <1455558779-15953-1-git-send-email-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Clemens Gruber <clemens.gruber@pqgruber.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455558779-15953-1-git-send-email-clemens.gruber@pqgruber.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/02/2016 09:52, Clemens Gruber wrote:
> For the Marvell 88E1510, marvell_of_reg_init was called too late (in
> m88e1510_config_aneg), which lead to the phy state machine being stuck
> at waiting for interrupts, which are off by default on the 88E1510.
> This further lead to the ethernet link not coming up at boot.
> For some Marvell PHYs, marvell_of_reg_init was not called at all.

You could mention that this became apparent with

> 
> Add a generic marvell_config_init function, which in turn calls
> marvell_of_reg_init and resets the PHY, to get more consistent behavior
> across all Marvell PHYs.

Looks good, just few comments below:

> 
> Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
> ---
>  drivers/net/phy/marvell.c | 65 +++++++++++++++++++++++------------------------
>  1 file changed, 32 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index e3eb964..473beaa 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -153,6 +153,8 @@ struct marvell_priv {
>  	u64 stats[ARRAY_SIZE(marvell_hw_stats)];
>  };
>  
> +static int marvell_of_reg_init(struct phy_device *phydev);

Can we avoid the forward declaration by re-arranging function bodies?

> +
>  static int marvell_ack_interrupt(struct phy_device *phydev)
>  {
>  	int err;
> @@ -215,6 +217,24 @@ static int marvell_set_polarity(struct phy_device *phydev, int polarity)
>  	return 0;
>  }
>  
> +static int marvell_config_init(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* Set page to 0 */
> +	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0);
> +	if (err < 0)
> +		return err;
> +
> +	/* Set registers from marvell,reg-init DT property */
> +	err = marvell_of_reg_init(phydev);
> +	if (err < 0)
> +		return err;
> +
> +	/* Reset the PHY (The page is 0 already) */
> +	return phy_write(phydev, MII_BMCR, BMCR_RESET);

This does not appear to be needed except for the 88E1111, 1118 and 1149,
might be better to check these PHY IDs explicitly here to avoid a
software reset for the other PHYs and make the transformation identical
before and after the change?
