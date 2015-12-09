From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 4/4] stmmac: socfpga: Provide dt node to config ptp
 clk source.
Date: Tue, 8 Dec 2015 22:13:33 -0600
Message-ID: <20151209041333.GA6992@rob-hp-laptop>
References: <1449625269-46078-1-git-send-email-preid@electromag.com.au>
 <1449625269-46078-5-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	vbridger@opensource.altera.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:42076 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753092AbbLIENi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 23:13:38 -0500
Content-Disposition: inline
In-Reply-To: <1449625269-46078-5-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2015 at 09:41:09AM +0800, Phil Reid wrote:
> Provides an options to use the ptp clock routed from the Altera FPGA
> fabric. Instead of the defalt eosc1 clock connected to the ARM HPS core.
> This setting affects all emacs in the core as the ptp clock is common.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>

Acked-by: Rob Herring <robh@kernel.org>

> ---
>  Documentation/devicetree/bindings/net/socfpga-dwmac.txt | 2 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c     | 9 +++++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index 3a9d679..72d82d6 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -11,6 +11,8 @@ Required properties:
>  		  designware version numbers documented in stmmac.txt
>   - altr,sysmgr-syscon : Should be the phandle to the system manager node that
>     encompasses the glue register, the register offset, and the register shift.
> + - altr,f2h_ptp_ref_clk use f2h_ptp_ref_clk instead of default eosc1 clock
> +   for ptp ref clk. This affects all emacs as the clock is common.
>  
>  Optional properties:
>  altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> index 401383b..f0d797a 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> @@ -32,6 +32,7 @@
>  #define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RMII 0x2
>  #define SYSMGR_EMACGRP_CTRL_PHYSEL_WIDTH 2
>  #define SYSMGR_EMACGRP_CTRL_PHYSEL_MASK 0x00000003
> +#define SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK 0x00000010
>  
>  #define EMAC_SPLITTER_CTRL_REG			0x0
>  #define EMAC_SPLITTER_CTRL_SPEED_MASK		0x3
> @@ -47,6 +48,7 @@ struct socfpga_dwmac {
>  	struct regmap *sys_mgr_base_addr;
>  	struct reset_control *stmmac_rst;
>  	void __iomem *splitter_base;
> +	bool f2h_ptp_ref_clk;
>  };
>  
>  static void socfpga_dwmac_fix_mac_speed(void *priv, unsigned int speed)
> @@ -116,6 +118,8 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>  		return -EINVAL;
>  	}
>  
> +	dwmac->f2h_ptp_ref_clk = of_property_read_bool(np, "altr,f2h_ptp_ref_clk");
> +
>  	np_splitter = of_parse_phandle(np, "altr,emac-splitter", 0);
>  	if (np_splitter) {
>  		if (of_address_to_resource(np_splitter, 0, &res_splitter)) {
> @@ -171,6 +175,11 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
>  	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << reg_shift);
>  	ctrl |= val << reg_shift;
>  
> +	if (dwmac->f2h_ptp_ref_clk)
> +		ctrl |= SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK << (reg_shift / 2);
> +	else
> +		ctrl &= ~(SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK << (reg_shift / 2));
> +
>  	regmap_write(sys_mgr_base_addr, reg_offset, ctrl);
>  	return 0;
>  }
> -- 
> 1.8.3.1
> 
