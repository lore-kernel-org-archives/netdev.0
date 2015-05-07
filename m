From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 net-next 1/2] igb: add PHY support for Broadcom 5461S
Date: Thu, 07 May 2015 11:20:09 -0700
Message-ID: <554BACD9.1010307@gmail.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	shm@cumulusnetworks.com, Alan Liebthal <alanl@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34478 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbbEGSUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 14:20:11 -0400
Received: by pacyx8 with SMTP id yx8so46843507pac.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 11:20:11 -0700 (PDT)
In-Reply-To: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2015 01:23 PM, Jonathan Toppins wrote:
> From: Alan Liebthal <alanl@cumulusnetworks.com>
>
> The Quanta LY8 Ethernet management port uses a Broadcom 5461S chip for
> the PHY layer. This adds support for this PHY to the Intel igb driver.
>
> Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>

Feedback below.  I would say you need to talk to Quanta, and have them 
talk to Intel about getting their EEPROM configuration fixed.  It looks 
like the part you have is lacking some EEPROM configuration since most 
of this patch contains the typical stuff one would do to workaround such 
an issue.

I'm assuming this isn't an SPF pluggable PHY since you are using MDIO 
for the interface, so they really should be doing some of the 
initialization in the EEPROM rather than pushing it off to the driver code.

> ---
>   drivers/net/ethernet/intel/igb/e1000_82575.c   |   20 +++++-
>   drivers/net/ethernet/intel/igb/e1000_defines.h |    1 +
>   drivers/net/ethernet/intel/igb/e1000_hw.h      |    1 +
>   drivers/net/ethernet/intel/igb/e1000_phy.c     |   79 ++++++++++++++++++++++++
>   drivers/net/ethernet/intel/igb/e1000_phy.h     |    2 +
>   5 files changed, 102 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
> index 2dcc808..e222804 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_82575.c
> +++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
> @@ -178,7 +178,7 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
>
>   	ctrl_ext = rd32(E1000_CTRL_EXT);
>
> -	if (igb_sgmii_active_82575(hw)) {
> +	if (igb_sgmii_active_82575(hw) && phy->type != e1000_phy_bcm5461s) {
>   		phy->ops.reset = igb_phy_hw_reset_sgmii_82575;
>   		ctrl_ext |= E1000_CTRL_I2C_ENA;
>   	} else {

This doesn't look right to me.  Why do you need a special exception for 
this part?  It seems like we should probably be using this patch 
assuming you are using an external PHY as the I2C enable is what enables 
external MII or I2C.  Is it possible that the EEPROM is missing the bits 
for setting up external MDIO correct?  You might take a look at the code 
related to igb_sgmii_uses_mdio_82575().

> @@ -289,6 +289,11 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
>   	case BCM54616_E_PHY_ID:
>   		phy->type = e1000_phy_bcm54616;
>   		break;
> +	case BCM5461S_E_PHY_ID:
> +		phy->type                   = e1000_phy_bcm5461s;
> +		phy->ops.get_phy_info       = igb_get_phy_info_5461s;
> +		phy->ops.force_speed_duplex = igb_phy_force_speed_duplex_82580;
> +		break;
>   	default:
>   		ret_val = -E1000_ERR_PHY;
>   		goto out;
> @@ -841,6 +846,15 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
>   			goto out;
>   		}
>   		ret_val = igb_get_phy_id(hw);
> +		if (ret_val && hw->mac.type == e1000_i354) {
> +			/* We do a special check for bcm5461s phy by setting
> +			 * the phy->addr to 5 and doing the phy check again.
> +			 * This call will succeed and retrieve a valid phy
> +			 * id if we have the bcm5461s phy.
> +			 */
> +			phy->addr = 5;
> +			ret_val = igb_get_phy_id(hw);
> +		}
>   		goto out;
>   	}
>

This looks like a bad EEPROM to me.  The phy ID should already be stored 
in the EEPROM or be discoverable.

> @@ -1221,6 +1235,9 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
>   	    (hw->phy.type == e1000_phy_igp_3))
>   		igb_phy_init_script_igp3(hw);
>
> +	if (hw->phy.type == e1000_phy_bcm5461s)
> +		igb_phy_init_script_5461s(hw);
> +
>   	return 0;
>   }
>

Yuck, okay so this platform definitely has an EEPROM issue.  All of this 
init stuff should really be in the EEPROM for the part.  You should 
probably have Quanta talk to Intel about getting the correct EEPROM 
built for this thing.

> @@ -1597,6 +1614,7 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
>   		ret_val = igb_copper_link_setup_82580(hw);
>   		break;
>   	case e1000_phy_bcm54616:
> +	case e1000_phy_bcm5461s:
>   		break;
>   	default:
>   		ret_val = -E1000_ERR_PHY;
> diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
> index 50d51e4..787224d 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_defines.h
> +++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
> @@ -861,6 +861,7 @@
>   #define I210_I_PHY_ID        0x01410C00
>   #define M88E1543_E_PHY_ID    0x01410EA0
>   #define BCM54616_E_PHY_ID    0x03625D10
> +#define BCM5461S_E_PHY_ID    0x002060C0
>
>   /* M88E1000 Specific Registers */
>   #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
> diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
> index d82c96b..408a3e5 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_hw.h
> +++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
> @@ -129,6 +129,7 @@ enum e1000_phy_type {
>   	e1000_phy_82580,
>   	e1000_phy_i210,
>   	e1000_phy_bcm54616,
> +	e1000_phy_bcm5461s,
>   };
>
>   enum e1000_bus_type {
> diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
> index c1bb64d..0f5a55b 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_phy.c
> +++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
> @@ -148,6 +148,13 @@ s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
>   	 * Control register.  The MAC will take care of interfacing with the
>   	 * PHY to retrieve the desired data.
>   	 */
> +	if (phy->type == e1000_phy_bcm5461s) {
> +		mdic = rd32(E1000_MDICNFG);
> +		mdic &= ~E1000_MDICNFG_PHY_MASK;
> +		mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
> +		wr32(E1000_MDICNFG, mdic);
> +	}
> +
>   	mdic = ((offset << E1000_MDIC_REG_SHIFT) |
>   		(phy->addr << E1000_MDIC_PHY_SHIFT) |
>   		(E1000_MDIC_OP_READ));
> @@ -204,6 +211,13 @@ s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
>   	 * Control register.  The MAC will take care of interfacing with the
>   	 * PHY to retrieve the desired data.
>   	 */
> +	if (phy->type == e1000_phy_bcm5461s) {
> +		mdic = rd32(E1000_MDICNFG);
> +		mdic &= ~E1000_MDICNFG_PHY_MASK;
> +		mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
> +		wr32(E1000_MDICNFG, mdic);
> +	}
> +
>   	mdic = (((u32)data) |
>   		(offset << E1000_MDIC_REG_SHIFT) |
>   		(phy->addr << E1000_MDIC_PHY_SHIFT) |

This bit is already done for you if you have a valid EEPROM.

> @@ -2509,3 +2523,68 @@ static s32 igb_set_master_slave_mode(struct e1000_hw *hw)
>
>   	return hw->phy.ops.write_reg(hw, PHY_1000T_CTRL, phy_data);
>   }
> +
> +/**
> + *  igb_phy_init_script_5461s - Inits the BCM5461S PHY
> + *  @hw: pointer to the HW structure
> + *
> + *  Initializes a Broadcom Gigabit PHY.
> + **/
> +s32 igb_phy_init_script_5461s(struct e1000_hw *hw)
> +{
> +	u16 mii_reg_led = 0;
> +
> +	/* 1. Speed LED (Set the Link LED mode), Shadow 00010, 0x1C.bit2=1 */
> +	hw->phy.ops.write_reg(hw, 0x1C, 0x0800);
> +	hw->phy.ops.read_reg(hw, 0x1C, &mii_reg_led);
> +	mii_reg_led |= 0x0004;
> +	hw->phy.ops.write_reg(hw, 0x1C, mii_reg_led | 0x8000);
> +
> +	/* 2. Active LED (Set the Link LED mode), Shadow 01001, 0x1C.bit4=1,
> +	 *    0x10.bit5=0
> +	 */
> +	hw->phy.ops.write_reg(hw, 0x1C, 0x2400);
> +	hw->phy.ops.read_reg(hw, 0x1C, &mii_reg_led);
> +	mii_reg_led |= 0x0010;
> +	hw->phy.ops.write_reg(hw, 0x1C, mii_reg_led | 0x8000);
> +	hw->phy.ops.read_reg(hw, 0x10, &mii_reg_led);
> +	mii_reg_led &= 0xffdf;
> +	hw->phy.ops.write_reg(hw, 0x10, mii_reg_led);
> +
> +	return 0;
> +}
> +

This belongs in the device EEPROM, not in the driver.  This is why Jeff 
is suggesting PHYlib.  At least if it is there then there only needs to 
be one copy per device this is attached to while lacking an EEPROM 
configuration.
