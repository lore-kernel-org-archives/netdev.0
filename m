From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 4/4 (v7)] phy: add the EEE support and the way to
 access to the MMD registers.
Date: Wed, 20 Jun 2012 18:22:20 +0100
Message-ID: <1340212940.2576.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340172774-27443-1-git-send-email-peppe.cavallaro@st.com>
	 <1340172774-27443-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<rayagond@vayavyalabs.com>, <davem@davemloft.net>,
	<yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9104 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757306Ab2FTRW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 13:22:27 -0400
In-Reply-To: <1340172774-27443-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 08:12 +0200, Giuseppe CAVALLARO wrote:
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
> +		int idx;
> +
> +		/* Read phy status to properly get the right settings */
> +		ret = phy_read_status(phydev);
> +		if (ret)
> +			return ret;
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

But this now means returning 0 since you added the call to
phy_read_status() above.  Maybe you should just return -EPROTONOSUPPORT
directly instead of relying on the assumed value of ret?

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
> +
> +		adv = phy_eee_to_adv(eee_adv);
> +		lp = phy_eee_to_adv(eee_lp);
> +		idx = phy_find_setting(phydev->speed, phydev->duplex);
> +		if ((lp & adv & settings[idx].setting))
> +			goto eee_exit;
[...]

Same problem here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
