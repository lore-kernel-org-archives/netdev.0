From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: Re: [PATCH] net: axienet: add of_phy_connect call for
 XAE_PHY_TYPE_MII case
Date: Wed, 5 Jul 2017 16:43:29 +0200
Message-ID: <20170705144328.6zxqtlfneredmn6c@collins.gmr.ssr.upm.es>
References: <20170630092541.27234-1-alvaro.gamez@hazent.com>
 <425aed84-a1b6-b8da-5989-3bef5a03ead4@gmail.com>
 <20170702101914.5nk27r2h754qzthe@collins.gmr.ssr.upm.es>
 <6A2BD6D6-9CBB-4BDD-BF28-F0BF10DB454C@gmail.com>
 <20170705101344.jlx5ju2x46szmuu7@collins.gmr.ssr.upm.es>
 <20170705143436.GD19749@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170705143436.GD19749@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 05, 2017 at 04:34:36PM +0200, Andrew Lunn wrote:
> So the only property which is currently wrong is xlnx,phy-type. As you
> said, all the others are garbage. So i would suggest something like:
> 
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 33c595f4691d..34a514d3288a 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -1539,7 +1539,38 @@ static int axienet_probe(struct platform_device *pdev)
>          * the device-tree and accordingly set flags.
>          */
>         of_property_read_u32(pdev->dev.of_node, "xlnx,rxmem", &lp->rxmem);
> -       of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type);
> +
> +       /* Start with the proprietary, and broken phy_type */
> +       err = of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &phy_type);
> +       if (!err) {
> +               netdev_warn(ndev, "Please upgrade your device tree binary blob to use phy-mode");
> +               switch (phy_type) {
> +               case XAE_PHY_TYPE_MII:
> +                       lp->phy_mode = PHY_INTERFACE_MODE_MII;
> +                       break;
> +               case XAE_PHY_TYPE_GMII:
> +                       lp->phy_mode = PHY_INTERFACE_MODE_GMII;
> +                       break;
> +               case XAE_PHY_TYPE_RGMII_2_0:
> +                       lp->phy_mode = PHY_INTERFACE_MODE_RGMII;
> +                       break;
> +               case XAE_PHY_TYPE_SGMII:
> +                       lp->pht_mode = PHY_INTERFACE_MODE_SGMII;
> +                       break;
> +               case XAE_PHY_TYPE_1000BASE_X:
> +                       lp->pht_mode = PHY_INTERFACE_MODE_1000BASEX;
> +                       break;
> +               default:
> +                       ret = -EINVAL;
> +                       goto free_netdev;
> +               }
> +       } else {
> +               lp->phy_mode = of_get_phy_mode(pdev->dev.of_node);
> +               if (lp->phy_mode < 0) {
> +                       ret = -EINVAL;
> +                       goto free_netdev;
> +               }
> +       }
>  
>         /* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
>         np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
> 
> 	Andrew

That sounds really respectful with current users and sets the basis for a
future removal of that proprietary parameter without causing more harm than
needed, so I like that a lot.

-- 
Alvaro G. M.
