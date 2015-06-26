From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3] net/phy: tune get_phy_c45_ids to support more c45
 phy
Date: Fri, 26 Jun 2015 11:17:01 -0700
Message-ID: <558D971D.5090500@gmail.com>
References: <1435312732-24890-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Shengzhou Liu <Shengzhou.Liu@freescale.com>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34788 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbFZSSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 14:18:36 -0400
Received: by pabvl15 with SMTP id vl15so72628778pab.1
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 11:18:36 -0700 (PDT)
In-Reply-To: <1435312732-24890-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/06/15 02:58, Shengzhou Liu wrote:
> As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
> zero Devices In package, current driver can't get correct
> devices_in_package value by non-zero Devices In package.
> so let's probe more with zero Devices In package to support
> more C45 PHYs.

This looks better to me now:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
> ---
> v3: restructure the loop to probe naturally.  
> v2: use MDIO_DEVS1 and MDIO_DEVS2 instead of constant '6', '5'
> 
>  drivers/net/phy/phy_device.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index bdfe51f..3e90037 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -230,7 +230,7 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
>  	for (i = 1;
>  	     i < num_ids && c45_ids->devices_in_package == 0;
>  	     i++) {
> -		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
> +retry:		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
>  		phy_reg = mdiobus_read(bus, addr, reg_addr);
>  		if (phy_reg < 0)
>  			return -EIO;
> @@ -242,12 +242,20 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
>  			return -EIO;
>  		c45_ids->devices_in_package |= (phy_reg & 0xffff);
>  
> -		/* If mostly Fs, there is no device there,
> -		 * let's get out of here.
> -		 */
>  		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
> -			*phy_id = 0xffffffff;
> -			return 0;
> +			if (i) {
> +				/*  If mostly Fs, there is no device there,
> +				 *  then let's continue to probe more, as some
> +				 *  10G PHYs have zero Devices In package,
> +				 *  e.g. Cortina CS4315/CS4340 PHY.
> +				 */
> +				i = 0;
> +				goto retry;
> +			} else {
> +				/* no device there, let's get out of here */
> +				*phy_id = 0xffffffff;
> +				return 0;
> +			}
>  		}
>  	}
>  
> 


-- 
Florian
