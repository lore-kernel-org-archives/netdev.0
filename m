From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 1/4 (v4)] phy: add the EEE support and the way to
 access to the MMD registers.
Date: Tue, 12 Jun 2012 17:50:20 +0100
Message-ID: <1339519820.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339505153-26731-1-git-send-email-peppe.cavallaro@st.com>
	 <1339505153-26731-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rayagond@vayavyalabs.com>,
	<davem@davemloft.net>, <yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7639 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751074Ab2FLQuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 12:50:23 -0400
In-Reply-To: <1339505153-26731-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 14:45 +0200, Giuseppe CAVALLARO wrote:
> This patch adds the support for the Energy-Efficient Ethernet (EEE)
> to the Physical Abstraction Layer.
> To support the EEE we have to access to the MMD registers 3.20 and
> 7.60/61. So two new functions have been added to read/write the MMD
> registers (clause 45).
> 
> An Ethernet driver (I tested the stmmac) can invoke the phy_init_eee to properly
> check if the EEE is supported by the PHYs and it can also set the clock
> stop enable bit in the 3.0 register.
> The phy_get_eee_err can be used for reporting the number of time where
> the PHY failed to complete its normal wake sequence.
> 
> In the end, this patch also adds the EEE ethtool support implementing:
>  o phy_ethtool_set_eee
>  o phy_ethtool_get_eee
[...]
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
[...]
> +static int phy_eee_to_adv(int eee_adv)
> +{
> +	int adv = 0;
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

The type of 'adv' and the return type should be u32 (per ethtool API);
the type of 'eee_adv' should be u16 (16-bit register).

Similarly in phy_eee_to_supported() and phy_adv_to_eee().

[...]
> --- a/include/linux/mii.h
> +++ b/include/linux/mii.h
[...]
> @@ -141,6 +143,15 @@
>  #define FLOW_CTRL_TX		0x01
>  #define FLOW_CTRL_RX		0x02
>  
> +/* MMD Access Control register fields */
> +#define MII_MMD_CTRL_DEVAD_MASK			0x1f	/* Mask MMD DEVAD*/
> +#define MII_MMD_CTRL_FUNC_ADDR			0x0000	/* Address */
> +#define MII_MMD_CTRL_FUNC_DATA_NOINCR		0x4000	/* no post increment */
> +#define MII_MMD_CTRL_FUNC_DATA_INCR_ON_RDWT	0x8000	/* post increment on
> +							 * reads & writes */
> +#define MII_MMD_CTRL_FUNC_DATA_INCR_ON_WT	0xC000	/* post increment on
> +							 * writes only */
> +
[...]

These names are quite long; could they reasonably be shortened, e.g. by
dropping 'FUNC_' and 'DATA_' parts?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
