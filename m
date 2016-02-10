From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/3] lan78xx: setting phy features in phy driver
Date: Wed, 10 Feb 2016 14:59:07 -0800
Message-ID: <56BBC0BB.3010100@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D404AB9F9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33444 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbcBJXAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 18:00:13 -0500
Received: by mail-pf0-f193.google.com with SMTP id c10so1627087pfc.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 15:00:13 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404AB9F9@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/16 13:13, Woojung.Huh@microchip.com wrote:
> 
> Update to set default phy supported & advertising features from phy device
> structure and remove unnecessary code in the nic driver.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/phy/microchip.c | 10 +++++++++-
>  drivers/net/usb/lan78xx.c   |  7 +------
>  2 files changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
> index 15f8206..7a457a4 100644
> --- a/drivers/net/phy/microchip.c
> +++ b/drivers/net/phy/microchip.c
> @@ -106,6 +106,14 @@ static int lan88xx_set_wol(struct phy_device *phydev,
>  	return 0;
>  }
>  
> +static int lan88xx_config_init(struct phy_device *phydev)
> +{
> +	phydev->supported &= phydev->drv->features;
> +	phydev->advertising &= phydev->drv->features;

This looks suspicious, phy_probe() takes the driver supported features
and assigns it to phydev->supported, and phydev->advertising, is not
that working somehow?

genphy_config_init() does look at the current MII_BMRS value to
determine what is supported by the PHY, and masks it in
phydev->supported, so that could indeed be an issue if we had not had a
change to mask with the supported modes before.

I think we need more explanation here as to what kind of bug you may
have been observing, there could be one.

> +
> +	return 0;
> +}
> +
>  static struct phy_driver microchip_phy_driver[] = {
>  {
>  	.phy_id		= 0x0007c130,
> @@ -119,7 +127,7 @@ static struct phy_driver microchip_phy_driver[] = {
>  	.probe		= lan88xx_probe,
>  	.remove		= lan88xx_remove,
>  
> -	.config_init	= genphy_config_init,
> +	.config_init	= lan88xx_config_init,
>  	.config_aneg	= genphy_config_aneg,
>  	.read_status	= genphy_read_status,
>  
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index b14b22d..1fd8072 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -1623,12 +1623,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
>  
>  	/* MAC doesn't support 1000T Half */
>  	phydev->supported &= ~SUPPORTED_1000baseT_Half;
> -	phydev->supported |= (SUPPORTED_10baseT_Half |
> -			      SUPPORTED_10baseT_Full |
> -			      SUPPORTED_100baseT_Half |
> -			      SUPPORTED_100baseT_Full |
> -			      SUPPORTED_1000baseT_Full |
> -			      SUPPORTED_Pause | SUPPORTED_Asym_Pause);



> +
>  	genphy_config_aneg(phydev);
>  
>  	phy_start(phydev);
> 


-- 
Florian
