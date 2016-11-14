From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v2] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Mon, 14 Nov 2016 10:35:27 -0800
Message-ID: <cf18464c-e225-af5d-9251-f2553b93b9ff@gmail.com>
References: <1478821561-26498-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35753 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932414AbcKNSfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 13:35:30 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so6535375pfk.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 10:35:29 -0800 (PST)
In-Reply-To: <1478821561-26498-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2016 03:46 PM, Timur Tabi wrote:
> Instead of having individual PHY drivers set the SUPPORTED_Pause and
> SUPPORTED_Asym_Pause flags, phylib itself should set those flags.
> During autonegotiation, the PHYs will determine whether to enable
> pause frame support.
> 
> Pause frames are a feature that is supported by the MAC.  It is the MAC
> that generates the frames and that processes them.  The PHY can only be
> configured to allow them to pass through.
> 
> So the new process is:
> 
> 1) Phylib sets the SUPPORTED_Pause and SUPPORTED_AsymPause bits in
> phydev->supported.  This indicates that the PHY supports pause frames.
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

> diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
> index e741bf6..5e9922e 100644
> --- a/drivers/net/phy/bcm63xx.c
> +++ b/drivers/net/phy/bcm63xx.c
> @@ -48,8 +48,7 @@ static int bcm63xx_config_init(struct phy_device *phydev)
>  	.phy_id		= 0x00406000,
>  	.phy_id_mask	= 0xfffffc00,
>  	.name		= "Broadcom BCM63XX (1)",
> -	/* ASYM_PAUSE bit is marked RO in datasheet, so don't cheat */
> -	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
> +	.features	= PHY_BASIC_FEATURES,

Humm that's actually a pretty important piece of information here that
we are going to lose if we unconditionally move the setting of the
SUPPORTED_Pause/Asym_Pause settings into the core. I don't have the HW
in a state where I could try a mainline kernel, but I suspect that the
following could happen though:

- we would try to set the SUPPORTED_AsymPause bit, and it would not be
taken into account, since the bit is RO
- the auto-negotiation results should still show up as symmetric pause
being supported only
- the driver would properly react to that

NB: this also applies to drivers/net/phy/ste10Xp.c.

So maybe, for theses drivers specifically, what we can do, is preserve
the entry as-is, to convey that only symmetric Pause frames can be
advertised, and have the logic in PHYLIB do something like this
(pseudo-code):

if (!(drv->features & (SUPPORTED_Pause | SUPPORTED_AsymPause))
	phydev->supported |= SUPPORTED_Pause | SUPPORTED_AsymPause;
else if ((drv->features & (SUPPORTED_Pause) && (!(drv->features &
(SUPPORTED_AsymPause)))
	phydev->supported |= SUPPORTED_Pause;

(there may be more efficient ways to do this of course).
-- 
Florian
