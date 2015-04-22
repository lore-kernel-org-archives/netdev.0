From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy: refactor RTL8211F initialization
Date: Wed, 22 Apr 2015 09:57:20 -0700
Message-ID: <5537D2F0.9050903@gmail.com>
References: <1429698120-17882-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Shengzhou Liu <Shengzhou.Liu@freescale.com>,
	netdev@vger.kernel.org, joe.hershberger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34442 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965529AbbDVQ6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 12:58:30 -0400
Received: by pacyx8 with SMTP id yx8so277883594pac.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 09:58:29 -0700 (PDT)
In-Reply-To: <1429698120-17882-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/04/15 03:22, Shengzhou Liu wrote:
> RTL8211F needs to enalbe TXDLY for RGMII during
> phy initialization, so move it to rtl8211f_config
> for early initialization.
> 
> Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
> cc: Joe Hershberger <joe.hershberger@gmail.com>
> ---
>  drivers/net/phy/realtek.c | 25 +++++++++++++++++--------
>  1 file changed, 17 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
> index 3917c82..d48095b 100644
> --- a/drivers/net/phy/realtek.c
> +++ b/drivers/net/phy/realtek.c
> @@ -43,6 +43,22 @@ static int rtl8211x_config(struct phy_device *phydev)
>  	return 0;
>  }
>  
> +static int rtl8211f_config(struct phy_device *phydev)
> +{
> +	phy_write(phydev, MDIO_DEVAD_NONE, MII_BMCR, BMCR_RESET);

That part of the change is not documented but has to be, and you should
use genphy_soft_reset() which also takes care of waiting the required
amount of time before BMCR_RESET is cleared.

> +
> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
> +		/* enable TXDLY */
> +		phy_write(phydev, MDIO_DEVAD_NONE,
> +			  MIIM_RTL8211F_PAGE_SELECT, 0xd08);
> +		phy_write(phydev, MDIO_DEVAD_NONE, 0x11, 0x109);

Do you need to reset the page selector somehow after this write?

> +	}
> +
> +	genphy_config_aneg(phydev);
> +
> +	return 0;
> +}
> +
>  static int rtl8211x_parse_status(struct phy_device *phydev)
>  {
>  	unsigned int speed;
> @@ -142,13 +158,6 @@ static int rtl8211f_parse_status(struct phy_device *phydev)
>  		phydev->speed = SPEED_10;
>  	}
>  
> -	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
> -		/* enable TXDLY */
> -		phy_write(phydev, MDIO_DEVAD_NONE,
> -			  MIIM_RTL8211F_PAGE_SELECT, 0xd08);
> -		phy_write(phydev, MDIO_DEVAD_NONE, 0x11, 0x109);
> -	}
> -
>  	return 0;
>  }
>  
> @@ -209,7 +218,7 @@ static struct phy_driver RTL8211F_driver = {
>  	.uid = 0x1cc916,
>  	.mask = 0xffffff,
>  	.features = PHY_GBIT_FEATURES,
> -	.config = &rtl8211x_config,
> +	.config = &rtl8211f_config,
>  	.startup = &rtl8211f_startup,
>  	.shutdown = &genphy_shutdown,
>  };
> 


-- 
Florian
