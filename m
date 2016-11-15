From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] lan78xx: relocate mdix setting to phy driver
Date: Tue, 15 Nov 2016 15:47:25 -0800
Message-ID: <c894a7bd-4062-cb63-6b70-02bb86c874c1@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40965635@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34808 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752194AbcKOXr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 18:47:29 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so8669912pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 15:47:28 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40965635@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2016 01:57 PM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> Relocate mdix code to phy driver to be called at config_init().
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/phy/microchip.c | 43 +++++++++++++++++++++++++-
>  drivers/net/usb/lan78xx.c   | 73 ++-------------------------------------------
>  2 files changed, 45 insertions(+), 71 deletions(-)
> 
> diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
> index 7c00e50..13553df 100644
> --- a/drivers/net/phy/microchip.c
> +++ b/drivers/net/phy/microchip.c
> @@ -106,6 +106,47 @@ static int lan88xx_set_wol(struct phy_device *phydev,
>  	return 0;
>  }
>  
> +static void lan88xx_set_mdix(struct phy_device *phydev)
> +{
> +	int buf;
> +
> +	if (phydev->mdix == ETH_TP_MDI) {
> +		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
> +			  LAN88XX_EXT_PAGE_SPACE_1);

Should you take this write out of the if/else

> +		buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);

And this one too

> +		buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
> +		phy_write(phydev, LAN88XX_EXT_MODE_CTRL,
> +			  buf | LAN88XX_EXT_MODE_CTRL_MDI_);
> +		phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
> +			  LAN88XX_EXT_PAGE_SPACE_0);

And this one too as well

> +	} else if (phydev->mdix == ETH_TP_MDI_X) {

switch/case statement would be more appropriate and it would be easier
to add support for future possible modes.

And once you take the write/read/write out of the switch case, it's just
a matter of translating phydev->mdix into the appropriate mask value to
write.

So essentially, this comes down to:

static void lan88xx_set_mdix(struct phy_device *phydev)
{
	int buf;
	int mask_val;

	switch (phydev->mdix) {
	case ETH_TP_MDI:
		mask_val = LAN88XX_EXT_MODE_CTRL_MDI_;
		break;
	case ETH_TP_MDI_X:
		mask_val = LAN88XX_EXT_MODE_CTRL_MDI_X_;
		break;
	case ETH_TP_MDI_AUTO:
		mask_val = LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_:
		break:
	default:
		return;
	}

	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
		  LAN88XX_EXT_PAGE_SPACE_1);
	buf = phy_read(phydev, LAN88XX_EXT_MODE_CTRL);
	buf &= ~LAN88XX_EXT_MODE_CTRL_MDIX_MASK_;
	buf |= mask_val;
	phy_write(phydev, LAN88XX_EXT_MODE_CTRL, buf);
	phy_write(phydev, LAN88XX_EXT_PAGE_ACCESS,
		  LAN88XX_EXT_PAGE_SPACE_0);
}

I leave it up to you whether you need to do this now, or as a subsequent
clean up patch.
-- 
Florian
