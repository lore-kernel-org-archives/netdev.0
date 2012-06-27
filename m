From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 4/4 (v8)] phy: add the EEE support and the way to
 access to the MMD registers.
Date: Wed, 27 Jun 2012 17:15:37 +0100
Message-ID: <1340813737.2591.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340258599-3083-1-git-send-email-peppe.cavallaro@st.com>
	 <1340258599-3083-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<rayagond@vayavyalabs.com>, <davem@davemloft.net>,
	<yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9534 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750887Ab2F0QPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 12:15:41 -0400
In-Reply-To: <1340258599-3083-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-21 at 08:03 +0200, Giuseppe CAVALLARO wrote:
[...]
> v8: fixed a problem in the phy_init_eee return value erroneously added
>     when included the phy_read_status call.

Almost there. :-/

[...]
> +int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
> +{
> +	int ret = -EPROTONOSUPPORT;
> +
> +	/* According to 802.3az,the EEE is supported only in full duplex-mode.
> +	 * Also EEE feature is active when core is operating with MII, GMII
> +	 * or RGMII.
> +	 */
> +	if ((phydev->duplex == DUPLEX_FULL) &&
> +	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
> +	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII))) {
> +		u16 eee_lp, eee_cap, eee_adv;
> +		u32 lp, cap, adv;
> +		int idx, status;
> +
> +		/* Read phy status to properly get the right settings */
> +		status = phy_read_status(phydev);
> +		if (status)
> +			return status;
> +
> +		/* First check if the EEE ability is supported */
> +		eee_cap = phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_ABLE,
> +						MDIO_MMD_PCS, phydev->addr);
> +		if (eee_cap < 0)
> +			return eee_cap;
> +
> +		cap = phy_eee_to_supported(eee_cap);
> +		if (!cap)
> +			goto eee_exit;
> +
> +		/* Check which link settings negotiated and verify it in
> +		 * the EEE advertising registers.
> +		 */
> +		eee_lp = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
> +					       MDIO_MMD_AN, phydev->addr);
> +		if (eee_lp < 0)
> +			return eee_lp;
> +
> +		eee_adv = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV,
> +						MDIO_MMD_AN, phydev->addr);
> +		if (eee_adv < 0)
> +			return eee_adv;

You check for eee_{cap,lp,adv} < 0 but that's impossible since the
variables are declared unsigned (u16).  (I wonder what compiler you are
using, as I would expect this to result in a warning.)  I think they
need to be declared int.

> +		adv = phy_eee_to_adv(eee_adv);
> +		lp = phy_eee_to_adv(eee_lp);
> +		idx = phy_find_setting(phydev->speed, phydev->duplex);
> +		if ((lp & adv & settings[idx].setting))
> +			goto eee_exit;
> +
> +		if (clk_stop_enable) {
> +			/* Configure the PHY to stop receiving xMII
> +			 * clock while it is signaling LPI.
> +			 */
> +			u32 val = phy_read_mmd_indirect(phydev->bus, MDIO_CTRL1,
> +							MDIO_MMD_PCS,
> +							phydev->addr);
> +			if (val < 0)
> +				return val;

Same problem here.

[...]
> --- a/include/linux/mdio.h
> +++ b/include/linux/mdio.h
[...]
> @@ -237,9 +241,18 @@
>  #define MDIO_AN_10GBT_STAT_MS		0x4000	/* Master/slave config */
>  #define MDIO_AN_10GBT_STAT_MSFLT	0x8000	/* Master/slave config fault */
>  
> -/* AN EEE Advertisement register. */
> -#define MDIO_AN_EEE_ADV_100TX		0x0002	/* Advertise 100TX EEE cap */
> -#define MDIO_AN_EEE_ADV_1000T		0x0004	/* Advertise 1000T EEE cap */
[...]

This header is exported to userland so I don't think these definitions
can be removed.  But you could comment that they're redundant with the
following MDIO_EEE_* definitions.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
