From: Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v1 1/6] drivers: net: xgene: MAC and PHY configuration
 changes
Date: Fri, 27 May 2016 19:07:26 +0200
Message-ID: <57487ECE.7010309@gmail.com>
References: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
 <1464333768-26150-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464333768-26150-2-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 27/05/16 09:22, Iyappan Subramanian wrote:
> This patch fixes MAC configuration to support 10/100GbE for SGMII and
> link_state call back. It also sets pdata->mdio_driver flag based on
> ethernet mdio subnode and prepare for MDIO driver support.
>
> In summary, following are the changes,
>
> - Added set_speed function pointer in mac_ops
> - Changed link_state to call the set_speed
> - Add 10/100 support for SGMII based 1G
> - Fixed mac_init for 1G
>
> - Call mac_ops rx_enable/disable and tx_enable/disable function pointers

This is just a code clean-up, right? If so, this should be a patch apart.

> - Add acpi_phy_find_device to find PHY using phy-handle reference object
> - Changing phy_start and phy_stop calls based on phy_dev object existence
> - Calling phy_connect based on pdata->mdio_driver flag
>
> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
> Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
> ---
>   drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 189 +++++++++++++---------
>   drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |   4 +
>   drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  40 +++--
>   drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |   2 +
>   drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 106 +++++++++++-
>   drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |   8 +
>   drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |   4 +
>   7 files changed, 256 insertions(+), 97 deletions(-)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> index 2f5638f..6bc8360 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> @@ -512,14 +512,11 @@ static void xgene_enet_configure_clock(struct xgene_enet_pdata *pdata)

[...]

>   static void xgene_sgmac_init(struct xgene_enet_pdata *p)
>   {
>   	u32 data, loop = 10;
> -	u32 offset = p->port_id * 4;
> +	u32 offset = 0;
>   	u32 enet_spare_cfg_reg, rsif_config_reg;
>   	u32 cfg_bypass_reg, rx_dv_gate_reg;
>
>   	xgene_sgmac_reset(p);
>
>   	/* Enable auto-negotiation */
> -	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_CONTROL_ADDR >> 2, 0x1000);
> +	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_TBI_CONTROL_ADDR >> 2,
> +			    0x8000);
> +	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_CONTROL_ADDR >> 2, 0x9000);
>   	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_TBI_CONTROL_ADDR >> 2, 0);
>
>   	while (loop--) {
> @@ -256,16 +343,14 @@ static void xgene_sgmac_init(struct xgene_enet_pdata *p)
>   	if (!(data & AUTO_NEG_COMPLETE) || !(data & LINK_STATUS))
>   		netdev_err(p->ndev, "Auto-negotiation failed\n");
>
> -	data = xgene_enet_rd_mac(p, MAC_CONFIG_2_ADDR);
> -	ENET_INTERFACE_MODE2_SET(&data, 2);
> -	xgene_enet_wr_mac(p, MAC_CONFIG_2_ADDR, data | FULL_DUPLEX2);
> -	xgene_enet_wr_mac(p, INTERFACE_CONTROL_ADDR, ENET_GHD_MODE);
> +	xgene_sgmac_set_speed(p);
>
>   	if (p->enet_id == XGENE_ENET1) {
>   		enet_spare_cfg_reg = ENET_SPARE_CFG_REG_ADDR;
>   		rsif_config_reg = RSIF_CONFIG_REG_ADDR;
>   		cfg_bypass_reg = CFG_BYPASS_ADDR;
>   		rx_dv_gate_reg = SG_RX_DV_GATE_REG_0_ADDR;
> +		offset = p->port_id * 4;

At least for me it is not clear where the "4" comes from. Maybe you can 
add a comment or declare a constant for that.
Anyway this looks like it fixes the driver for xgene2-sgnet and therefor 
should go into a separate patch, or am I wrong?

Regards,
Matthias

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
