From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next PATCH] mdio: translation of MMD EEE registers to/from
 ethtool settings
Date: Tue, 21 Aug 2012 14:47:40 +0200
Message-ID: <5033836C.2010306@st.com>
References: <20120820145529.19390.66175.stgit@bwallan-smackover2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:33619 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753426Ab2HUMsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 08:48:01 -0400
In-Reply-To: <20120820145529.19390.66175.stgit@bwallan-smackover2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/20/2012 4:55 PM, Bruce Allan wrote:
> The helper functions which translate IEEE MDIO Manageable Device (MMD)
> Energy-Efficient Ethernet (EEE) registers 3.20, 7.60 and 7.61 to and from
> the comparable ethtool supported/advertised settings will be needed by
> drivers other than those in PHYLIB (e.g. e1000e in a follow-on patch).
> 
> In the same fashion as similar translation functions in linux/mii.h, move
> these functions from the PHYLIB core to the linux/mdio.h header file so the
> code will not have to be duplicated in each driver needing MMD-to-ethtool
> (and vice-versa) translations.  The function and some variable names have
> been renamed to be more descriptive.
> 
> Not tested on the only hardware that currently calls the related functions,
> stmmac, because I don't have access to any.  Has been compile tested and
> the translations have been tested on a locally modified version of e1000e.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>

I did some tests on my side with the stmmac and I've not seen any issues
on EEE. Also the patch looks fine to me.

Peppe

> ---
> 
>  drivers/net/phy/phy.c |   74 ++++----------------------------------------
>  include/linux/mdio.h  |   83 +++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 90 insertions(+), 67 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 7ca2ff9..ef9ea92 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1035,66 +1035,6 @@ static void phy_write_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
>  	bus->write(bus, addr, MII_MMD_DATA, data);
>  }
>  
> -static u32 phy_eee_to_adv(u16 eee_adv)
> -{
> -	u32 adv = 0;
> -
> -	if (eee_adv & MDIO_EEE_100TX)
> -		adv |= ADVERTISED_100baseT_Full;
> -	if (eee_adv & MDIO_EEE_1000T)
> -		adv |= ADVERTISED_1000baseT_Full;
> -	if (eee_adv & MDIO_EEE_10GT)
> -		adv |= ADVERTISED_10000baseT_Full;
> -	if (eee_adv & MDIO_EEE_1000KX)
> -		adv |= ADVERTISED_1000baseKX_Full;
> -	if (eee_adv & MDIO_EEE_10GKX4)
> -		adv |= ADVERTISED_10000baseKX4_Full;
> -	if (eee_adv & MDIO_EEE_10GKR)
> -		adv |= ADVERTISED_10000baseKR_Full;
> -
> -	return adv;
> -}
> -
> -static u32 phy_eee_to_supported(u16 eee_caported)
> -{
> -	u32 supported = 0;
> -
> -	if (eee_caported & MDIO_EEE_100TX)
> -		supported |= SUPPORTED_100baseT_Full;
> -	if (eee_caported & MDIO_EEE_1000T)
> -		supported |= SUPPORTED_1000baseT_Full;
> -	if (eee_caported & MDIO_EEE_10GT)
> -		supported |= SUPPORTED_10000baseT_Full;
> -	if (eee_caported & MDIO_EEE_1000KX)
> -		supported |= SUPPORTED_1000baseKX_Full;
> -	if (eee_caported & MDIO_EEE_10GKX4)
> -		supported |= SUPPORTED_10000baseKX4_Full;
> -	if (eee_caported & MDIO_EEE_10GKR)
> -		supported |= SUPPORTED_10000baseKR_Full;
> -
> -	return supported;
> -}
> -
> -static u16 phy_adv_to_eee(u32 adv)
> -{
> -	u16 reg = 0;
> -
> -	if (adv & ADVERTISED_100baseT_Full)
> -		reg |= MDIO_EEE_100TX;
> -	if (adv & ADVERTISED_1000baseT_Full)
> -		reg |= MDIO_EEE_1000T;
> -	if (adv & ADVERTISED_10000baseT_Full)
> -		reg |= MDIO_EEE_10GT;
> -	if (adv & ADVERTISED_1000baseKX_Full)
> -		reg |= MDIO_EEE_1000KX;
> -	if (adv & ADVERTISED_10000baseKX4_Full)
> -		reg |= MDIO_EEE_10GKX4;
> -	if (adv & ADVERTISED_10000baseKR_Full)
> -		reg |= MDIO_EEE_10GKR;
> -
> -	return reg;
> -}
> -
>  /**
>   * phy_init_eee - init and check the EEE feature
>   * @phydev: target phy_device struct
> @@ -1132,7 +1072,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>  		if (eee_cap < 0)
>  			return eee_cap;
>  
> -		cap = phy_eee_to_supported(eee_cap);
> +		cap = mmd_eee_cap_to_ethtool_sup_t(eee_cap);
>  		if (!cap)
>  			goto eee_exit;
>  
> @@ -1149,8 +1089,8 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>  		if (eee_adv < 0)
>  			return eee_adv;
>  
> -		adv = phy_eee_to_adv(eee_adv);
> -		lp = phy_eee_to_adv(eee_lp);
> +		adv = mmd_eee_adv_to_ethtool_adv_t(eee_adv);
> +		lp = mmd_eee_adv_to_ethtool_adv_t(eee_lp);
>  		idx = phy_find_setting(phydev->speed, phydev->duplex);
>  		if ((lp & adv & settings[idx].setting))
>  			goto eee_exit;
> @@ -1210,21 +1150,21 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data)
>  				    MDIO_MMD_PCS, phydev->addr);
>  	if (val < 0)
>  		return val;
> -	data->supported = phy_eee_to_supported(val);
> +	data->supported = mmd_eee_cap_to_ethtool_sup_t(val);
>  
>  	/* Get advertisement EEE */
>  	val = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV,
>  				    MDIO_MMD_AN, phydev->addr);
>  	if (val < 0)
>  		return val;
> -	data->advertised = phy_eee_to_adv(val);
> +	data->advertised = mmd_eee_adv_to_ethtool_adv_t(val);
>  
>  	/* Get LP advertisement EEE */
>  	val = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
>  				    MDIO_MMD_AN, phydev->addr);
>  	if (val < 0)
>  		return val;
> -	data->lp_advertised = phy_eee_to_adv(val);
> +	data->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(val);
>  
>  	return 0;
>  }
> @@ -1241,7 +1181,7 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
>  {
>  	int val;
>  
> -	val = phy_adv_to_eee(data->advertised);
> +	val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
>  	phy_write_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
>  			       phydev->addr, val);
>  
> diff --git a/include/linux/mdio.h b/include/linux/mdio.h
> index 7cccafe..6c40684 100644
> --- a/include/linux/mdio.h
> +++ b/include/linux/mdio.h
> @@ -377,5 +377,88 @@ static inline void mdio45_ethtool_gset(const struct mdio_if_info *mdio,
>  extern int mdio_mii_ioctl(const struct mdio_if_info *mdio,
>  			  struct mii_ioctl_data *mii_data, int cmd);
>  
> +/**
> + * mmd_eee_cap_to_ethtool_sup_t
> + * @eee_cap: value of the MMD EEE Capability register
> + *
> + * A small helper function that translates MMD EEE Capability (3.20) bits
> + * to ethtool supported settings.
> + */
> +static inline u32 mmd_eee_cap_to_ethtool_sup_t(u16 eee_cap)
> +{
> +	u32 supported = 0;
> +
> +	if (eee_cap & MDIO_EEE_100TX)
> +		supported |= SUPPORTED_100baseT_Full;
> +	if (eee_cap & MDIO_EEE_1000T)
> +		supported |= SUPPORTED_1000baseT_Full;
> +	if (eee_cap & MDIO_EEE_10GT)
> +		supported |= SUPPORTED_10000baseT_Full;
> +	if (eee_cap & MDIO_EEE_1000KX)
> +		supported |= SUPPORTED_1000baseKX_Full;
> +	if (eee_cap & MDIO_EEE_10GKX4)
> +		supported |= SUPPORTED_10000baseKX4_Full;
> +	if (eee_cap & MDIO_EEE_10GKR)
> +		supported |= SUPPORTED_10000baseKR_Full;
> +
> +	return supported;
> +}
> +
> +/**
> + * mmd_eee_adv_to_ethtool_adv_t
> + * @eee_adv: value of the MMD EEE Advertisement/Link Partner Ability registers
> + *
> + * A small helper function that translates the MMD EEE Advertisment (7.60)
> + * and MMD EEE Link Partner Ability (7.61) bits to ethtool advertisement
> + * settings.
> + */
> +static inline u32 mmd_eee_adv_to_ethtool_adv_t(u16 eee_adv)
> +{
> +	u32 adv = 0;
> +
> +	if (eee_adv & MDIO_EEE_100TX)
> +		adv |= ADVERTISED_100baseT_Full;
> +	if (eee_adv & MDIO_EEE_1000T)
> +		adv |= ADVERTISED_1000baseT_Full;
> +	if (eee_adv & MDIO_EEE_10GT)
> +		adv |= ADVERTISED_10000baseT_Full;
> +	if (eee_adv & MDIO_EEE_1000KX)
> +		adv |= ADVERTISED_1000baseKX_Full;
> +	if (eee_adv & MDIO_EEE_10GKX4)
> +		adv |= ADVERTISED_10000baseKX4_Full;
> +	if (eee_adv & MDIO_EEE_10GKR)
> +		adv |= ADVERTISED_10000baseKR_Full;
> +
> +	return adv;
> +}
> +
> +/**
> + * ethtool_adv_to_mmd_eee_adv_t
> + * @adv: the ethtool advertisement settings
> + *
> + * A small helper function that translates ethtool advertisement settings
> + * to EEE advertisements for the MMD EEE Advertisement (7.60) and
> + * MMD EEE Link Partner Ability (7.61) registers.
> + */
> +static inline u16 ethtool_adv_to_mmd_eee_adv_t(u32 adv)
> +{
> +	u16 reg = 0;
> +
> +	if (adv & ADVERTISED_100baseT_Full)
> +		reg |= MDIO_EEE_100TX;
> +	if (adv & ADVERTISED_1000baseT_Full)
> +		reg |= MDIO_EEE_1000T;
> +	if (adv & ADVERTISED_10000baseT_Full)
> +		reg |= MDIO_EEE_10GT;
> +	if (adv & ADVERTISED_1000baseKX_Full)
> +		reg |= MDIO_EEE_1000KX;
> +	if (adv & ADVERTISED_10000baseKX4_Full)
> +		reg |= MDIO_EEE_10GKX4;
> +	if (adv & ADVERTISED_10000baseKR_Full)
> +		reg |= MDIO_EEE_10GKR;
> +
> +	return reg;
> +}
> +
>  #endif /* __KERNEL__ */
>  #endif /* __LINUX_MDIO_H__ */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
