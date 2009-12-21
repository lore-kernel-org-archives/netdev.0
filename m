From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH v2 02/12] ixgbevf: 82599 Virtual Function core
 functions and header
Date: Mon, 21 Dec 2009 16:03:42 +1100
Message-ID: <20091221050341.GA22037@verge.net.au>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
 <20091218225123.10698.8625.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58743 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbZLUFDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 00:03:44 -0500
Content-Disposition: inline
In-Reply-To: <20091218225123.10698.8625.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2009 at 02:51:23PM -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> This module and header file contain the core functions for the 82599
> virtual function device.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbevf/vf.c |  410 ++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ixgbevf/vf.h |  168 +++++++++++++++++++
>  2 files changed, 578 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/ixgbevf/vf.c
>  create mode 100644 drivers/net/ixgbevf/vf.h
> 
> diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
> new file mode 100644
> index 0000000..38784eb
> --- /dev/null
> +++ b/drivers/net/ixgbevf/vf.c
> @@ -0,0 +1,410 @@

[snip]

> +
> +#include "vf.h"
> +
> +static s32 ixgbevf_init_hw_vf(struct ixgbe_hw *hw);
> +static s32 ixgbevf_start_hw_vf(struct ixgbe_hw *hw);
> +static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw);
> +static s32 ixgbevf_stop_hw_vf(struct ixgbe_hw *hw);
> +static s32 ixgbevf_get_mac_addr_vf(struct ixgbe_hw *hw, u8 *mac_addr);
> +static s32 ixgbevf_setup_mac_link_vf(struct ixgbe_hw *hw,
> +				   ixgbe_link_speed speed, bool autoneg,
> +				   bool autoneg_wait_to_complete);
> +static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
> +				   ixgbe_link_speed *speed,
> +				   bool *link_up,
> +				   bool autoneg_wait_to_complete);
> +static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
> +			      u32 vmdq);
> +static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw, u8 *mc_addr_list,
> +					u32 mc_addr_count, ixgbe_mc_addr_itr);
> +static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
> +			     bool vlan_on);

It seems that if the definition of ixgbevf_get_mac_addr_vf() was moved to
before ixgbevf_set_rar_vf() then all of the above static declarations could
be removed.

[snip]

> +/**
> + *  ixgbevf_reset_hw_vf - Performs hardware reset
> + *  @hw: pointer to hardware structure
> + *
> + *  Resets the hardware by reseting the transmit and receive units, masks and
> + *  clears all interrupts.
> + **/
> +static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
> +{
> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
> +	u32 timeout = IXGBE_VF_INIT_TIMEOUT;
> +	s32 ret_val = IXGBE_ERR_INVALID_MAC_ADDR;
> +	u32 msgbuf[IXGBE_VF_PERMADDR_MSG_LEN];
> +	u8 *addr = (u8 *)(&msgbuf[1]);
> +
> +	/* Call adapter stop to disable tx/rx and clear interrupts */
> +	hw->mac.ops.stop_adapter(hw);
> +
> +	IXGBE_WRITE_REG(hw, IXGBE_VFCTRL, IXGBE_CTRL_RST);
> +	IXGBE_WRITE_FLUSH(hw);
> +
> +	/* we cannot reset while the RSTI / RSTD bits are asserted */
> +	while (!mbx->ops.check_for_rst(hw) && timeout) {
> +		timeout--;
> +		udelay(5);
> +	}
> +
> +	if (timeout) {
> +		/* mailbox timeout can now become active */
> +		mbx->timeout = IXGBE_VF_MBX_INIT_TIMEOUT;
> +
> +		msgbuf[0] = IXGBE_VF_RESET;
> +		mbx->ops.write_posted(hw, msgbuf, 1);
> +
> +		msleep(10);
> +
> +		/* set our "perm_addr" based on info provided by PF */
> +		/* also set up the mc_filter_type which is piggy backed
> +		 * on the mac address in word 3 */
> +		ret_val = mbx->ops.read_posted(hw, msgbuf,
> +					       IXGBE_VF_PERMADDR_MSG_LEN);
> +		if (!ret_val) {
> +			if (msgbuf[0] == (IXGBE_VF_RESET |
> +					  IXGBE_VT_MSGTYPE_ACK)) {
> +				memcpy(hw->mac.perm_addr, addr,
> +				       IXGBE_ETH_LENGTH_OF_ADDRESS);
> +				hw->mac.mc_filter_type =
> +					msgbuf[IXGBE_VF_MC_TYPE_WORD];
> +			} else {
> +				ret_val = IXGBE_ERR_INVALID_MAC_ADDR;
> +			}
> +		}
> +	}
> +
> +	return ret_val;
> +}

I wonder if it would be easier to follow the flow of ixgbevf_reset_hw_vf()
if it was written as:

static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
{
	struct ixgbe_mbx_info *mbx = &hw->mbx;
	u32 timeout = IXGBE_VF_INIT_TIMEOUT;
	s32 ret_val;
	u32 msgbuf[IXGBE_VF_PERMADDR_MSG_LEN];
	u8 *addr = (u8 *)(&msgbuf[1]);

	/* Call adapter stop to disable tx/rx and clear interrupts */
	hw->mac.ops.stop_adapter(hw);

	IXGBE_WRITE_REG(hw, IXGBE_VFCTRL, IXGBE_CTRL_RST);
	IXGBE_WRITE_FLUSH(hw);

	/* we cannot reset while the RSTI / RSTD bits are asserted */
	while (!mbx->ops.check_for_rst(hw) && timeout) {
		timeout--;
		udelay(5);
	}

	if (!timeout)
		return IXGBE_ERR_INVALID_MAC_ADDR;

	/* mailbox timeout can now become active */
	mbx->timeout = IXGBE_VF_MBX_INIT_TIMEOUT;

	msgbuf[0] = IXGBE_VF_RESET;
	mbx->ops.write_posted(hw, msgbuf, 1);

	msleep(10);

	/* Set our "perm_addr" based on info provided by PF.
	 * Also set up the mc_filter_type which is piggy backed
	 * on the mac address in word 3
	 */
	ret_val = mbx->ops.read_posted(hw, msgbuf, IXGBE_VF_PERMADDR_MSG_LEN);
	if (ret_val)
		return ret_val;

	if (msgbuf[0] != (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK))
		return IXGBE_ERR_INVALID_MAC_ADDR;

	memcpy(hw->mac.perm_addr, addr, IXGBE_ETH_LENGTH_OF_ADDRESS);
	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];

	return 0;
}

