From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/5] net: phy: broadcom: Add BCM54810 phy entry
Date: Thu, 27 Oct 2016 11:15:05 +0200
Message-ID: <20161027091505.GB12841@lunn.ch>
References: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
 <1477510561-17035-2-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Vikas Soni <vsoni@broadcom.com>,
 Rob Herring <robh+dt@kernel.org>, bcm-kernel-feedback-list@broadcom.com,
 rafal@milecki.pl, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1477510561-17035-2-git-send-email-jon.mason@broadcom.com>
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

On Wed, Oct 26, 2016 at 03:35:57PM -0400, Jon Mason wrote:
> From: Vikas Soni <vsoni@broadcom.com>
> 
> Add BCM54810 phy entry

Hi Jon, Vikis

The subject line is a bit misleading. It does more than add a PHY ID
entry.

> Signed-off-by: Vikas Soni <vsoni@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  drivers/net/phy/Kconfig    |  2 +-
>  drivers/net/phy/broadcom.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/brcmphy.h    |  7 +++++
>  3 files changed, 73 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 45f68ea..31967ca 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -217,7 +217,7 @@ config BROADCOM_PHY
>  	select BCM_NET_PHYLIB
>  	---help---
>  	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
> -	  BCM5481 and BCM5482 PHYs.
> +	  BCM5481, BCM54810 and BCM5482 PHYs.
>  
>  config CICADA_PHY
>  	tristate "Cicada PHYs"
> diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
> index 870327e..cdce761 100644
> --- a/drivers/net/phy/broadcom.c
> +++ b/drivers/net/phy/broadcom.c
> @@ -35,6 +35,35 @@ static int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
>  	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
>  }
>  
> +static int bcm54810_config(struct phy_device *phydev)
> +{
> +	int rc;
> +
> +	/* Disable BroadR-Reach */
> +	rc = bcm_phy_write_exp(phydev, BCM54810_EXP_BROADREACH_LRE_MISC_CTL, 0);
> +	if (rc < 0)
> +		return rc;
> +
> +	/* SKEW DISABLE */
> +	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
> +				  0xF0E0);
> +	if (rc < 0)
> +		return rc;
> +
> +	/* DELAY DISABLE */
> +	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
> +				  0x7000);

This driver mostly uses symbolic names, not #defines. Please can you
use #defines here and else were in this patch.


> +	if (rc < 0)
> +		return rc;
> +
> +	/* DELAY DISABLE */
> +	rc = bcm_phy_write_shadow(phydev, BCM54810_SHD_CLK_CTL, 0);
> +	if (rc < 0)
> +		return rc;

Twice the same comment?

> +
> +	return 0;
> +}
> +
>  /* Needs SMDSP clock enabled via bcm54xx_phydsp_config() */
>  static int bcm50610_a0_workaround(struct phy_device *phydev)
>  {
> @@ -207,6 +236,20 @@ static int bcm54xx_config_init(struct phy_device *phydev)
>  	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
>  		bcm54xx_adjust_rxrefclk(phydev);
>  
> +	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810) {
> +		err = bcm54810_config(phydev);
> +		if (err)
> +			return err;
> +
> +		reg = phy_read(phydev, MII_BMCR);
> +		if (reg < 0)
> +			return reg;
> +
> +		err = phy_write(phydev, MII_BMCR, reg & ~BMCR_PDOWN);
> +		if (err)
> +			return err;

This seems a bit odd. I would expect the PHY core correctly handles
the PHY being powered down. Can you explain this a bit more, why it is
needed.

	Thanks
		Andrew
