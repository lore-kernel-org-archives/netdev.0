From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next 2/13]bnx2x: Adding bnx2x_link
Date: Sun, 01 Jun 2008 22:50:11 +0200
Message-ID: <87tzgc283g.fsf@basil.nowhere.org>
References: <1212333127.6967.121.camel@ubuntu804desktop.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net, "Eliezer Tamir" <eliezert@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:40399 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbYFAUuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 16:50:16 -0400
In-Reply-To: <1212333127.6967.121.camel@ubuntu804desktop.localdomain> (Eilon Greenstein's message of "Sun, 01 Jun 2008 11:12:07 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Eilon Greenstein" <eilong@broadcom.com> writes:

Just quick general review. Logic is pretty much unscrutinizable without
a datasheet.

In general your code would be much easier readable if you shortened
some of the defines and names a bit.

> +++ b/drivers/net/bnx2x_link.c
> @@ -0,0 +1,4456 @@
> +/*  Copyright 2008 Broadcom Corporation
> + * 
> + *  Unless you and Broadcom execute a separate written software license
> + *  agreement governing use of this software, this software is licensed to you
> + *  under the terms of the GNU General Public License version 2, available
> + *  at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL").
> + * 
> + *  Notwithstanding the above, under no circumstances may you combine this
> + *  software in any way with any other Broadcom software provided under a
> + *  license other than the GPL, without Broadcom's express prior written
> + *  consent.

Not a lawyer, but doesn't that conflict with the GPL as additional
restriction in case Broadcom ever released anything else e.g. under 
a BSD license which can be normally combined with GPL?

> + *  Written by Yaniv Rosner

And shouldn't that person be in Signed-off-by? 


A high level comment what this file is supposed to do at the beginning
of the file would be good.

> +static u8 bnx2x_reset_unicore(struct link_params *params)
> +{
> +	struct bnx2x *bp = params->bp;
> +	u16 mii_control;
> +	u16 i;
> +
> +	CL45_RD_OVER_CL22(bp, params->port,
> +			      params->phy_addr,
> +			      MDIO_REG_BANK_COMBO_IEEE0,
> +			      MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
> +
> +	/* reset the unicore */
> +	CL45_WR_OVER_CL22(bp, params->port,
> +			      params->phy_addr,
> +			      MDIO_REG_BANK_COMBO_IEEE0,
> +			      MDIO_COMBO_IEEE0_MII_CONTROL,
> +			      (mii_control |
> +			       MDIO_COMBO_IEEO_MII_CONTROL_RESET));

Your macro naming is certainly "interesting".

> +
> +	/* wait for the reset to self clear */
> +	for (i = 0; i < MDIO_ACCESS_TIMEOUT; i++) {
> +		udelay(5);

Hopefully that doesn't loop too often. Could tie down the machine
for a long time.


> +	if (rx_lane_swap != 0x1b) {
> +		CL45_WR_OVER_CL22(bp, params->port,
> +				      params->phy_addr,
> +				    MDIO_REG_BANK_XGXS_BLOCK2,
> +				    MDIO_XGXS_BLOCK2_RX_LN_SWAP,
> +				    (rx_lane_swap |
> +				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_ENABLE |
> +				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE));
> +	} else {
> +		CL45_WR_OVER_CL22(bp, params->port,
> +				      params->phy_addr,
> +				      MDIO_REG_BANK_XGXS_BLOCK2,
> +				      MDIO_XGXS_BLOCK2_RX_LN_SWAP, 0);
> +	}

That could be written much shorter with two variables.

> +
> +	if (tx_lane_swap != 0x1b) {
> +		CL45_WR_OVER_CL22(bp, params->port,
> +				      params->phy_addr,
> +				      MDIO_REG_BANK_XGXS_BLOCK2,
> +				      MDIO_XGXS_BLOCK2_TX_LN_SWAP,
> +				      (tx_lane_swap |
> +				       MDIO_XGXS_BLOCK2_TX_LN_SWAP_ENABLE));
> +	} else {
> +		CL45_WR_OVER_CL22(bp, params->port,
> +				      params->phy_addr,
> +				      MDIO_REG_BANK_XGXS_BLOCK2,
> +				      MDIO_XGXS_BLOCK2_TX_LN_SWAP, 0);

Same.


> +			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
> +				/* Disable 2.5Ghz */
> +				bnx2x_cl45_read(bp, params->port,
> +					      ext_phy_type,
> +					      ext_phy_addr,
> +					      MDIO_AN_DEVAD,
> +					      0x8329, &tmp1);
> +/* SUPPORT_SPEED_CAPABILITY
> +				if (params->speed_cap_mask &
> +				PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G)
> +*/

You seem to have a lot of commented out code like this. Remove it all? 

> +u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
> +{
> +	struct bnx2x *bp = params->bp;
> +
> +	u32 val;
> +	DP(NETIF_MSG_LINK, "Phy Initialization started\n");
> +	DP(NETIF_MSG_LINK, "req_speed = %d, req_flowctrl=%d\n",
> +		  params->req_line_speed, params->req_flow_ctrl);
> +	vars->link_status = 0;
> +	if (params->switch_cfg ==  SWITCH_CFG_1G)
> +		vars->phy_flags = PHY_SERDES_FLAG;
> +	else
> +		vars->phy_flags = PHY_XGXS_FLAG;
> +
> +	/* disable attentions */
> +	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
> +		       (NIG_MASK_XGXS0_LINK_STATUS |
> +			NIG_MASK_XGXS0_LINK10G |
> +			NIG_MASK_SERDES0_LINK_STATUS |
> +			NIG_MASK_MI_INT));
> +
> +	bnx2x_emac_init(params, vars);
> +
> +	if (CHIP_REV_IS_FPGA(bp)) {

Do the FPGA and IS_EMUL cases really need to be in a production driver?


> +u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars)
> +{
> +
> +	struct bnx2x *bp = params->bp;
> +	u32 ext_phy_config = params->ext_phy_config;
> +	u16 hw_led_mode = params->hw_led_mode;
> +	u32 chip_id = params->chip_id;
> +	u8 port = params->port;
> +	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
> +	/* disable attentions */
> +
> +	vars->link_status = 0;
> +	bnx2x_update_mng(params, vars->link_status);
> +	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
> +		     (NIG_MASK_XGXS0_LINK_STATUS |
> +		      NIG_MASK_XGXS0_LINK10G |
> +		      NIG_MASK_SERDES0_LINK_STATUS |
> +		      NIG_MASK_MI_INT));
> +
> +	/* activate nig drain */
> +	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
> +
> +	/* disable nig egress interface */
> +	REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0);
> +	REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
> +
> +	/* Stop BigMac rx */
> +	bnx2x_bmac_rx_disable(bp, port);
> +
> +	/* disable emac */
> +	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
> +
> +	msleep(10);

Didn't see the caller, but hopefully that's not a standard shared workqueue.
Tieing those up for 10ms would be quite nasty.

There are more such long sleeps that should be double checked.

> +	/* avoid fast toggling */
> +	for (i = 0; i < 10; i++) {
> +		msleep(10);
> +		CL45_RD_OVER_CL22(bp, port, params->phy_addr,
> +				      MDIO_REG_BANK_GP_STATUS,
> +				      MDIO_GP_STATUS_TOP_AN_STATUS1,
> +				      &gp_status);
> +	}

... like this. 

> +	for (cnt = 0; cnt < 10; cnt++) {
> +		msleep(50);

or this

> +/* Programs an image to DSP's flash via the SPI port*/
> +static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
> +				     u8 ext_phy_addr,
> +				     char data[], u32 size)

Hmm does the driver really need a flash updater as standard
functionality? That could be a separate program.

> +	/* wait 0.5 sec to allow it to run */
> +	for (cnt = 0; cnt < 100; cnt++)
> +		msleep(5);
> +
> +	bnx2x_hw_reset(bp);
> +
> +	for (cnt = 0; cnt < 100; cnt++)
> +		msleep(5);

Especially when it contains long delays like this.


-Andi
