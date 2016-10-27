From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Thu, 27 Oct 2016 15:12:54 -0700
Message-ID: <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        zefir.kurtisi@neratec.com, scampbel@codeaurora.org,
        alokc@codeaurora.org, shankerd@codeaurora.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36048 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030461AbcJ0WM6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 18:12:58 -0400
Received: by mail-pf0-f193.google.com with SMTP id n85so3675540pfi.3
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 15:12:57 -0700 (PDT)
In-Reply-To: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2016 03:05 PM, Timur Tabi wrote:
> The Atheros 8031 PHY supports the 802.3 extension for symmetric and
> asymmetric pause frames, so set that to the list of features supported
> by the phy.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> Without this patch, my NIC (the Qualcomm EMAC) receives a lot of frame
> check sequence (aka CRC) errors, resulting in about 10% packet loss.

Hu? In my experience that should not come from supporting Pause frames
or not, but rather properly configuring a (RG)MII delay, but your
mileage may vary.

> Can someone help me understand why?  Because of this patch, I can't use
> the generic phy driver in phylib.  Why would a MAC controller require
> its PHY to support pause frames?

It does not, support for Pause frames is a MAC-level feature, yet,
PHYLIB (and that's been on my todo for a while now) insists on reporting
the confusing phydev->pause and phydev->asym_pause, which really is what
has been determined from auto-negotiating with your partner, as opposed
to being a supported thing or not. The PHY has absolutely not business
in that.

Your change should probably be in the Ethernet MAC driver, when you have
successfully connected to the PHY, update phydev->supported to include
SUPPORTED_Pause | SUPPORTED_Asym_pause.

> 
>  drivers/net/phy/at803x.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index a52b560..fb80413 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -440,7 +440,8 @@ static struct phy_driver at803x_driver[] = {
>  	.get_wol		= at803x_get_wol,
>  	.suspend		= at803x_suspend,
>  	.resume			= at803x_resume,
> -	.features		= PHY_GBIT_FEATURES,
> +	.features		= PHY_GBIT_FEATURES |
> +				  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags			= PHY_HAS_INTERRUPT,
>  	.config_aneg		= genphy_config_aneg,
>  	.read_status		= genphy_read_status,
> 


-- 
Florian
