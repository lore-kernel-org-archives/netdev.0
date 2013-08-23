From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v4 4/5] net: ethernet: cpsw: add support for hardware
 interface mode config
Date: Fri, 23 Aug 2013 22:20:02 +0530
Message-ID: <521792BA.7000009@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-5-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bcousson@baylibre.com>,
	<nsekhar@ti.com>, <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<vaibhav.bedia@ti.com>, <d-gerlach@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:46298 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625Ab3HWQuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 12:50:37 -0400
In-Reply-To: <1377267365-24057-5-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 August 2013 07:46 PM, Daniel Mack wrote:
> The cpsw currently lacks code to properly set up the hardware interface
> mode on AM33xx. Other platforms might be equally affected.
>
> Usually, the bootloader will configure the control module register, so
> probably that's why such support wasn't needed in the past. In suspend
> mode though, this register is modified, and so it needs reprogramming
> after resume.
>
> This patch adds code that makes use of the previously added and optional
> support for passing the control mode register, and configures the
> correct register bits when the slave is opened.
>
> The AM33xx also has a bit for each slave to configure the RMII reference
> clock direction. Setting it is now supported by a per-slave DT property.
>
> This code path introducted by this patch is currently exclusive for
> am33xx.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>  Documentation/devicetree/bindings/net/cpsw.txt |  2 +
>  drivers/net/ethernet/ti/cpsw.c                 | 61 ++++++++++++++++++++++++++
>  drivers/net/ethernet/ti/cpsw.h                 |  1 +
>  3 files changed, 64 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
> index b717458..0895a51 100644
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> @@ -34,6 +34,8 @@ Required properties:
>  - phy_id		: Specifies slave phy id
>  - phy-mode		: The interface between the SoC and the PHY (a string
>  			  that of_get_phy_mode() can understand)
> +- ti,rmii-clock-ext	: If present, the driver will configure the RMII
> +			  interface to external clock usage
>  - mac-address		: Specifies slave MAC address
>  
>  Optional properties:
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 73c44cb6..86b8f7a 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -138,6 +138,13 @@ do {								\
>  #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
>  #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
>  
> +#define AM33XX_GMII_SEL_MODE_MII	(0)
> +#define AM33XX_GMII_SEL_MODE_RMII	(1)
> +#define AM33XX_GMII_SEL_MODE_RGMII	(2)
> +
> +#define AM33XX_GMII_SEL_RMII2_IO_CLK_EN	BIT(7)
> +#define AM33XX_GMII_SEL_RMII1_IO_CLK_EN	BIT(6)

These defined can go into cpsw.h so that we can maintain platform
defines in one file.


> +
>  #define cpsw_enable_irq(priv)	\
>  	do {			\
>  		u32 i;		\
> @@ -980,6 +987,56 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
>  		priv->host_port, ALE_VLAN, slave->port_vlan);
>  }
>  
> +static void cpsw_set_phy_interface_mode(struct cpsw_slave *slave,
> +					struct cpsw_priv *priv)
> +{
> +	u32 reg, mask, mode = 0;

Please define each variable in separate line to make it clean.
Please check for IS_ERR(gmii_sel_reg) and return if gmii register is not
specified in DT then the below code will crash when trying to access
gmii_sel_reg.


> +
> +	switch (priv->data.hw_type) {
> +	case CPSW_TYPE_AM33XX:
> +		if (!priv->gmii_sel_reg)
> +			break;
> +
> +		reg = readl(priv->gmii_sel_reg);
> +
> +		if (slave->phy) {
> +			switch (slave->phy->interface) {
> +			case PHY_INTERFACE_MODE_MII:
> +			default:
> +				mode = AM33XX_GMII_SEL_MODE_MII;
> +				break;
> +			case PHY_INTERFACE_MODE_RMII:
> +				mode = AM33XX_GMII_SEL_MODE_RMII;
> +				break;
> +			case PHY_INTERFACE_MODE_RGMII:

You need to take care of other RGMII modes as well, for your info
AM335xevm phy mode is "rgmii-txid"

Regards
Mugunthan V N
