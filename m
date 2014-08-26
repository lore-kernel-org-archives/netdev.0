From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH (net.git)] phy: fix EEE checks inside the phy_init_eee.
Date: Tue, 26 Aug 2014 09:55:11 -0700
Message-ID: <53FCBBEF.7010906@gmail.com>
References: <1409038012-11574-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nandini Sharma <nandini.sharma@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:61352 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbaHZQzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 12:55:42 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so23461843pad.8
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:55:42 -0700 (PDT)
In-Reply-To: <1409038012-11574-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 12:26 AM, Giuseppe Cavallaro wrote:
> According to the Std 802.3az if the EEE Adv (Reg 7.60), Link partner ability
> (Reg 7.61) and EEE capability (Register 3.20) bits return 0 this  means no EEE
> is supported. So this patch fixes the checks inside the phy_init_eee function.
> 
> Signed-off-by: Nandini Sharma <nandini.sharma@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/phy.c |   18 +++++++++---------
>  1 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index c94e2a2..a854d38 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1036,31 +1036,31 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>  		/* First check if the EEE ability is supported */
>  		eee_cap = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
>  						MDIO_MMD_PCS, phydev->addr);
> -		if (eee_cap < 0)
> -			return eee_cap;
> +		if (eee_cap <= 0)
> +			goto eee_exit_err;
>  
>  		cap = mmd_eee_cap_to_ethtool_sup_t(eee_cap);
>  		if (!cap)
> -			return -EPROTONOSUPPORT;
> +			goto eee_exit_err;

!cap is most likely not possible anymore now that you are checking that
eee_cap <= 0

>  
>  		/* Check which link settings negotiated and verify it in
>  		 * the EEE advertising registers.
>  		 */
>  		eee_lp = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
>  					       MDIO_MMD_AN, phydev->addr);
> -		if (eee_lp < 0)
> -			return eee_lp;
> +		if (eee_lp <= 0)
> +			goto eee_exit_err;
>  
>  		eee_adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
>  						MDIO_MMD_AN, phydev->addr);
> -		if (eee_adv < 0)
> -			return eee_adv;
> +		if (eee_adv <= 0)
> +			goto eee_exit_err;
>  
>  		adv = mmd_eee_adv_to_ethtool_adv_t(eee_adv);
>  		lp = mmd_eee_adv_to_ethtool_adv_t(eee_lp);
>  		idx = phy_find_setting(phydev->speed, phydev->duplex);
>  		if (!(lp & adv & settings[idx].setting))
> -			return -EPROTONOSUPPORT;
> +			goto eee_exit_err;
>  
>  		if (clk_stop_enable) {
>  			/* Configure the PHY to stop receiving xMII
> @@ -1080,7 +1080,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>  
>  		return 0; /* EEE supported */
>  	}
> -
> +eee_exit_err:
>  	return -EPROTONOSUPPORT;
>  }
>  EXPORT_SYMBOL(phy_init_eee);
> 
