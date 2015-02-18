From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Fix verification of EEE support in phy_init_eee
Date: Wed, 18 Feb 2015 11:01:51 -0800
Message-ID: <54E4E19F.2080209@gmail.com>
References: <1424194582-9792-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35231 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbbBRTCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 14:02:06 -0500
Received: by padfa1 with SMTP id fa1so3322821pad.2
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 11:02:05 -0800 (PST)
In-Reply-To: <1424194582-9792-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/15 09:36, Guenter Roeck wrote:
> phy_init_eee uses phy_find_setting(phydev->speed, phydev->duplex)
> to find a valid entry in the settings array for the given speed
> and duplex value. For full duplex 1000baseT, this will return
> the first matching entry, which is the entry for 1000baseKX_Full.
> 
> If the phy eee does not support 1000baseKX_Full, this entry will not
> match, causing phy_init_eee to fail for no good reason.
> 
> Fixes: 9a9c56cb34e6 ("net: phy: fix a bug when verify the EEE support")
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
Fixes: 3e7077067e80c ("phy: Expand phy speed/duplex settings array")

> ---
> I have another version where phy_check_valid() is open coded. It looks a bit
> messy to me, but I don't really mind either way if that is preferred.
> 
>  drivers/net/phy/phy.c | 23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index cdcac6a..52cd8db 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -236,6 +236,25 @@ static inline unsigned int phy_find_valid(unsigned int idx, u32 features)
>  }
>  
>  /**
> + * phy_check_valid - check if there is a valid PHY setting which matches
> + *		     speed, duplex, and feature mask
> + * @speed: speed to match
> + * @duplex: duplex to match
> + * @features: A mask of the valid settings
> + *
> + * Description: Returns true if there is a valid setting, false otherwise.
> + */
> +static inline bool phy_check_valid(int speed, int duplex, u32 features)
> +{
> +	unsigned int idx;
> +
> +	idx = phy_find_valid(phy_find_setting(speed, duplex), features);
> +
> +	return settings[idx].speed == speed && settings[idx].duplex == duplex &&
> +		(settings[idx].setting & features);
> +}
> +
> +/**
>   * phy_sanitize_settings - make sure the PHY is set to supported speed and duplex
>   * @phydev: the target phy_device struct
>   *
> @@ -1045,7 +1064,6 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>  		int eee_lp, eee_cap, eee_adv;
>  		u32 lp, cap, adv;
>  		int status;
> -		unsigned int idx;
>  
>  		/* Read phy status to properly get the right settings */
>  		status = phy_read_status(phydev);
> @@ -1077,8 +1095,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>  
>  		adv = mmd_eee_adv_to_ethtool_adv_t(eee_adv);
>  		lp = mmd_eee_adv_to_ethtool_adv_t(eee_lp);
> -		idx = phy_find_setting(phydev->speed, phydev->duplex);
> -		if (!(lp & adv & settings[idx].setting))
> +		if (!phy_check_valid(phydev->speed, phydev->duplex, lp & adv))
>  			goto eee_exit_err;
>  
>  		if (clk_stop_enable) {
> 


-- 
Florian
