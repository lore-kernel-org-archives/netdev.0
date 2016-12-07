From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v3] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Tue, 6 Dec 2016 16:36:38 -0800
Message-ID: <2c2aaf1d-05a5-d2bc-d04a-79224a4c6b43@gmail.com>
References: <1481070443-15118-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34247 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752018AbcLGAh1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 19:37:27 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so19432834pfb.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 16:36:40 -0800 (PST)
In-Reply-To: <1481070443-15118-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2016 04:27 PM, Timur Tabi wrote:
> Instead of having individual PHY drivers set the SUPPORTED_Pause and
> SUPPORTED_Asym_Pause flags, phylib itself should set those flags,
> unless there is a hardware erratum or other special case.  During
> autonegotiation, the PHYs will determine whether to enable pause
> frame support.
> 
> Pause frames are a feature that is supported by the MAC.  It is the MAC
> that generates the frames and that processes them.  The PHY can only be
> configured to allow them to pass through.
> 
> So the new process is:
> 
> 1) Unless the PHY driver overrides it, phylib sets the SUPPORTED_Pause
> and SUPPORTED_AsymPause bits in phydev->supported.  This indicates that
> the PHY supports pause frames.
> 
> 2) The MAC driver checks phydev->supported before it calls phy_start().
> If (SUPPORTED_Pause | SUPPORTED_AsymPause) is set, then the MAC driver
> sets those bits in phydev->advertising, if it wants to enable pause
> frame support.
> 
> 3) When the link state changes, the MAC driver checks phydev->pause and
> phydev->asym_pause,  If the bits are set, then it enables the corresponding
> features in the MAC.  The algorithm is:
> 
> 	if (phydev->pause)
> 		The MAC should be programmed to receive and honor
>                 pause frames it receives, i.e. enable receive flow control.
> 
> 	if (phydev->pause != phydev->asym_pause)
> 		The MAC should be programmed to transmit pause
> 		frames when needed, i.e. enable transmit flow control.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---

> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 49a1c98..fe36eeb 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1598,6 +1598,27 @@ static int phy_probe(struct device *dev)
>  	of_set_phy_supported(phydev);
>  	phydev->advertising = phydev->supported;
>  
> +	/* The Pause Frame bits indicate that the PHY can support passing
> +	 * pause frames. During autonegotiation, the PHYs will determine if
> +	 * they should allow pause frames to pass.  The MAC driver should then
> +	 * use that result to determine whether to enable flow control via
> +	 * pause frames.
> +	 *
> +	 * Normally, PHY drivers should not set the Pause bits, and instead
> +	 * allow phylib to do that.  However, there may be some situations
> +	 * (e.g. hardware erratum) where the driver wants to set only one
> +	 * of these bits.
> +	 */
> +	if (phydrv->features & (SUPPORTED_Pause | SUPPORTED_Asym_Pause)) {
> +		phydev->supported &= ~(SUPPORTED_Pause | SUPPORTED_Asym_Pause);
> +		phydev->supported |= phydrv->features &
> +				     (SUPPORTED_Pause | SUPPORTED_Asym_Pause);

Is not the & (SUPPORTED_Pause | SUPPORTED_Asym_Pause) redundant here anyway?

> +	} else {
> +		phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;

that part looks good.

> +	}
> +
> +	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;

but this one basically "undoes" what the if () clause did where we
checked if either, or one of the two bits was already set?
-- 
Florian
