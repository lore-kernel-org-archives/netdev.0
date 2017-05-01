From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Allow BCM5481x PHYs to setup internal TX/RX
 clock delay
Date: Sun, 30 Apr 2017 17:53:36 -0700
Message-ID: <5e7e1410-ede2-9a38-084d-bf866c91d790@gmail.com>
References: <1493530461-11935-1-git-send-email-abhishek.shah@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Andrew Lunn <andrew@lunn.ch>
To: Abhishek Shah <abhishek.shah@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1493530461-11935-1-git-send-email-abhishek.shah@broadcom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 04/29/2017 10:34 PM, Abhishek Shah wrote:
> This patch allows users to enable/disable internal TX and/or RX
> clock delay for BCM5481x series PHYs so as to satisfy RGMII timing
> specifications.
> 
> On a particular platform, whether TX and/or RX clock delay is required
> depends on how PHY connected to the MAC IP. This requirement can be
> specified through "phy-mode" property in the platform device tree.
> 
> Signed-off-by: Abhishek Shah <abhishek.shah@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/broadcom.c | 69 ++++++++++++++++++++++------------------------
>  1 file changed, 33 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
> index 9cd8b27..a32dc5d 100644
> --- a/drivers/net/phy/broadcom.c
> +++ b/drivers/net/phy/broadcom.c
> @@ -74,27 +74,40 @@ static int bcm54612e_config_init(struct phy_device *phydev)
>  	return 0;
>  }
>  
> -static int bcm54810_config(struct phy_device *phydev)
> +static int bcm5481x_config(struct phy_device *phydev)
>  {
>  	int rc, val;
>  
> -	val = bcm_phy_read_exp(phydev, BCM54810_EXP_BROADREACH_LRE_MISC_CTL);
> -	val &= ~BCM54810_EXP_BROADREACH_LRE_MISC_CTL_EN;
> -	rc = bcm_phy_write_exp(phydev, BCM54810_EXP_BROADREACH_LRE_MISC_CTL,
> -			       val);
> -	if (rc < 0)
> -		return rc;
> -
> +	/* handling PHY's internal RX clock delay */
>  	val = bcm54xx_auxctl_read(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
> -	val &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
>  	val |= MII_BCM54XX_AUXCTL_MISC_WREN;
> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII ||
> +	    phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
> +		/* Disable RGMII RXC-RXD skew */
> +		val &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
> +	}
> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
> +	    phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
> +		/* Enable RGMII RXC-RXD skew */
> +		val |= MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
> +	}
>  	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
>  				  val);
>  	if (rc < 0)
>  		return rc;
>  
> +	/* handling PHY's internal TX clock delay */
>  	val = bcm_phy_read_shadow(phydev, BCM54810_SHD_CLK_CTL);
> -	val &= ~BCM54810_SHD_CLK_CTL_GTXCLK_EN;
> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII ||
> +	    phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
> +		/* Disable internal TX clock delay */
> +		val &= ~BCM54810_SHD_CLK_CTL_GTXCLK_EN;
> +	}
> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
> +	    phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
> +		/* Enable internal TX clock delay */
> +		val |= BCM54810_SHD_CLK_CTL_GTXCLK_EN;
> +	}
>  	rc = bcm_phy_write_shadow(phydev, BCM54810_SHD_CLK_CTL, val);
>  	if (rc < 0)
>  		return rc;
> @@ -244,7 +257,7 @@ static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
>  
>  static int bcm54xx_config_init(struct phy_device *phydev)
>  {
> -	int reg, err;
> +	int reg, err, val;
>  
>  	reg = phy_read(phydev, MII_BCM54XX_ECR);
>  	if (reg < 0)
> @@ -283,8 +296,14 @@ static int bcm54xx_config_init(struct phy_device *phydev)
>  		if (err)
>  			return err;
>  	} else if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810) {
> -		err = bcm54810_config(phydev);
> -		if (err)
> +		/* For BCM54810, we need to disable BroadR-Reach function */
> +		val = bcm_phy_read_exp(phydev,
> +				       BCM54810_EXP_BROADREACH_LRE_MISC_CTL);
> +		val &= ~BCM54810_EXP_BROADREACH_LRE_MISC_CTL_EN;
> +		err = bcm_phy_write_exp(phydev,
> +					BCM54810_EXP_BROADREACH_LRE_MISC_CTL,
> +					val);
> +		if (err < 0)
>  			return err;
>  	}
>  
> @@ -392,29 +411,7 @@ static int bcm5481_config_aneg(struct phy_device *phydev)
>  	ret = genphy_config_aneg(phydev);
>  
>  	/* Then we can set up the delay. */
> -	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
> -		u16 reg;
> -
> -		/*
> -		 * There is no BCM5481 specification available, so down
> -		 * here is everything we know about "register 0x18". This
> -		 * at least helps BCM5481 to successfully receive packets
> -		 * on MPC8360E-RDK board. Peter Barada <peterb@logicpd.com>
> -		 * says: "This sets delay between the RXD and RXC signals
> -		 * instead of using trace lengths to achieve timing".
> -		 */
> -
> -		/* Set RDX clk delay. */
> -		reg = 0x7 | (0x7 << 12);
> -		phy_write(phydev, 0x18, reg);
> -
> -		reg = phy_read(phydev, 0x18);
> -		/* Set RDX-RXC skew. */
> -		reg |= (1 << 8);
> -		/* Write bits 14:0. */
> -		reg |= (1 << 15);
> -		phy_write(phydev, 0x18, reg);
> -	}
> +	bcm5481x_config(phydev);
>  
>  	if (of_property_read_bool(np, "enet-phy-lane-swap")) {
>  		/* Lane Swap - Undocumented register...magic! */
> 

-- 
Florian
