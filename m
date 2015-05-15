From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Make sure PHY_RESUMING state change is always
 processed
Date: Fri, 15 May 2015 14:25:49 -0700
Message-ID: <5556645D.4050202@gmail.com>
References: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tim Beale <tim.beale@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36024 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946310AbbEOV0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:26:12 -0400
Received: by iepk2 with SMTP id k2so131221250iep.3
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 14:26:11 -0700 (PDT)
In-Reply-To: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 18:55, Tim Beale wrote:
> If phy_start_aneg() was called while the phydev is in the PHY_RESUMING
> state, then its state would immediately transition to PHY_AN (or
> PHY_FORCING). This meant the phy_state_machine() never processed the
> PHY_RESUMING state change, which meant interrupts weren't enabled for the
> PHY. If the PHY used low-power mode (i.e. using BMCR_PDOWN), then the
> physical link wouldn't get powered up again.
> 
> There seems no point for phy_start_aneg() to make the PHY_RESUMING -->
> PHY_AN transition, as the state machine will do this anyway. I'm not sure
> about the case where autoneg is disabled, as my patch will change
> behaviour so that the PHY goes to PHY_NOLINK instead of PHY_FORCING. An
> alternative solution would be to move the phy_config_interrupt() and
> phy_resume() work out of the state machine and into phy_start().

Could you prepare a patch which does that? I do not have a setup where
the PHY IRQ is a dedicated interrupt line, but I might be able to test
something with a hack.

> 
> The background behind this: we're running linux v3.16.7 and from user-space
> we want to enable the eth port (i.e. do a SIOCSIFFLAGS ioctl with the
> IFF_UP flag) and immediately afterward set the interface's speed/duplex.
> Enabling the interface calls .ndo_open() then phy_start() and the PHY
> transitions PHY_HALTED --> PHY_RESUMING. Setting the speed/duplex ends up
> calling phy_ethtool_sset(), which calls phy_start_aneg() (meanwhile the
> phy_state_machine() hasn't processed the PHY_RESUMING state change yet).
> 
> Signed-off-by: Tim Beale <tim.beale@alliedtelesis.co.nz>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/phy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 52cd8db..9855b96 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -465,7 +465,7 @@ int phy_start_aneg(struct phy_device *phydev)
>  	if (err < 0)
>  		goto out_unlock;
>  
> -	if (phydev->state != PHY_HALTED) {
> +	if (phydev->state != PHY_HALTED && phydev->state != PHY_RESUMING) {
>  		if (AUTONEG_ENABLE == phydev->autoneg) {
>  			phydev->state = PHY_AN;
>  			phydev->link_timeout = PHY_AN_TIMEOUT;
> 


-- 
Florian
