From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 2/2] net: phy: Add MAC-IF driver for
 Microsemi PHYs.
Date: Thu, 8 Sep 2016 15:27:27 +0200
Message-ID: <20160908132727.GH26445@lunn.ch>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1473326242-4198-3-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38866 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933159AbcIHN13 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 09:27:29 -0400
Content-Disposition: inline
In-Reply-To: <1473326242-4198-3-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 02:47:22PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Used Device Tree to configure the MAC Interface as per review comments and
> re-sending code for review

I don't see anything about device tree in this patch...

> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> ---
>  drivers/net/phy/mscc.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 60 insertions(+)
> 
> diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
> index f0a0e8d..dfbf4f3 100644
> --- a/drivers/net/phy/mscc.c
> +++ b/drivers/net/phy/mscc.c
> @@ -24,6 +24,16 @@ enum rgmii_rx_clock_delay {
>  	RGMII_RX_CLK_DELAY_3_4_NS = 7
>  };
>  
> +/* Microsemi VSC85xx PHY registers */
> +/* IEEE 802. Std Registers */
> +#define MSCC_PHY_EXT_PHY_CNTL_1           23
> +#define MAC_IF_SELECTION_MASK             0x1800
> +#define MAC_IF_SELECTION_GMII             0
> +#define MAC_IF_SELECTION_RMII             1
> +#define MAC_IF_SELECTION_RGMII            2
> +#define MAC_IF_SELECTION_POS              11
> +#define FAR_END_LOOPBACK_MODE_MASK        0x0008
> +
>  #define MII_VSC85XX_INT_MASK		  25
>  #define MII_VSC85XX_INT_MASK_MASK	  0xa000
>  #define MII_VSC85XX_INT_STATUS		  26
> @@ -59,6 +69,52 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
>  	return rc;
>  }
>  
> +static int vsc85xx_soft_reset(struct phy_device *phydev)
> +{
> +	int rc;
> +	u16 reg_val;
> +
> +	reg_val = phy_read(phydev, MII_BMCR);
> +	reg_val |= BMCR_RESET;
> +	rc = phy_write(phydev, MII_BMCR, reg_val);
> +
> +	return rc;
> +}

Do you need to wait for the reset to complete?

Does it make sense to call genphy_soft_reset() which will poll the phy
waiting for the BMCR_RESET bit to clear?

> +
> +static int vsc85xx_mac_if_set(struct phy_device *phydev,
> +			      phy_interface_t   interface)
> +{
> +	int rc;
> +	u16 reg_val;
> +
> +	mutex_lock(&phydev->lock);
> +	reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
> +	reg_val &= ~(MAC_IF_SELECTION_MASK);
> +	switch (interface) {
> +	case PHY_INTERFACE_MODE_RGMII:
> +		reg_val |= (MAC_IF_SELECTION_RGMII << MAC_IF_SELECTION_POS);
> +		break;
> +	case PHY_INTERFACE_MODE_RMII:
> +		reg_val |= (MAC_IF_SELECTION_RMII << MAC_IF_SELECTION_POS);
> +		break;
> +	case PHY_INTERFACE_MODE_MII:
> +	case PHY_INTERFACE_MODE_GMII:
> +	default:

So somebody asks you to configure the phy as PHY_INTERFACE_MODE_NA or
PHY_INTERFACE_MODE_TBI, you are going to use GMII. Maybe returning
-EINVAL would be better?

	Andrew
