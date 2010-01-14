From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 4/4] phy: add RTBI mode for m88e1111
Date: Thu, 14 Jan 2010 10:20:09 -0600
Message-ID: <BC00E67D-5906-4740-A961-84FC1C524A4F@kernel.crashing.org>
References: <1263456799-3306-1-git-send-email-yu.liu@freescale.com> <1263456799-3306-2-git-send-email-yu.liu@freescale.com> <1263456799-3306-3-git-send-email-yu.liu@freescale.com> <1263456799-3306-4-git-send-email-yu.liu@freescale.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Liu Yu <Yu.Liu@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33566 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757055Ab0ANQUV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 11:20:21 -0500
In-Reply-To: <1263456799-3306-4-git-send-email-yu.liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 14, 2010, at 2:13 AM, Liu Yu wrote:

> Signed-off-by: Liu Yu <yu.liu@freescale.com>
> ---
> drivers/net/phy/marvell.c |   38 ++++++++++++++++++++++++++++++++++++++
> 1 files changed, 38 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 6f69b9b..65ed385 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -63,6 +63,7 @@
> #define MII_M1111_HWCFG_MODE_COPPER_RGMII	0xb
> #define MII_M1111_HWCFG_MODE_FIBER_RGMII	0x3
> #define MII_M1111_HWCFG_MODE_SGMII_NO_CLK	0x4
> +#define MII_M1111_HWCFG_MODE_COPPER_RTBI	0x9
> #define MII_M1111_HWCFG_FIBER_COPPER_AUTO	0x8000
> #define MII_M1111_HWCFG_FIBER_COPPER_RES	0x2000
> 
> @@ -269,6 +270,43 @@ static int m88e1111_config_init(struct phy_device *phydev)
> 			return err;
> 	}
> 
> +	if (phydev->interface == PHY_INTERFACE_MODE_RTBI) {
> +		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
> +		if (temp < 0)
> +			return temp;
> +		temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
> +		err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
> +		if (err < 0)
> +			return err;
> +
> +		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
> +		if (temp < 0)
> +			return temp;
> +		temp &= ~(MII_M1111_HWCFG_MODE_MASK | MII_M1111_HWCFG_FIBER_COPPER_RES);
> +		temp |= 0x7 | MII_M1111_HWCFG_FIBER_COPPER_AUTO;

Does this magic 0x7 have some meaning?

> +		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
> +		if (err < 0)
> +			return err;
> +
> +		/* soft reset */
> +		err = phy_write(phydev, MII_BMCR, BMCR_RESET);
> +		if (err < 0)
> +			return err;
> +		do
> +			temp = phy_read(phydev, MII_BMCR);
> +		while (temp & BMCR_RESET);
> +
> +		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
> +		if (temp < 0)
> +			return temp;
> +		temp &= ~(MII_M1111_HWCFG_MODE_MASK | MII_M1111_HWCFG_FIBER_COPPER_RES);
> +		temp |= MII_M1111_HWCFG_MODE_COPPER_RTBI | MII_M1111_HWCFG_FIBER_COPPER_AUTO;
> +		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
> +		if (err < 0)
> +			return err;
> +	}
> +
> +
> 	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
> 	if (err < 0)
> 		return err;
> -- 
> 1.6.4

