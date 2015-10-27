From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [PATCH] ixgbe: check Master Disable bit after setting
Date: Tue, 27 Oct 2015 17:14:50 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF22286646913C0D10@ORSMSX110.amr.corp.intel.com>
References: <1445905192-9959-1-git-send-email-dan.streetman@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dan Streetman <ddstreet@ieee.org>
To: "dan.streetman@canonical.com" <dan.streetman@canonical.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445905192-9959-1-git-send-email-dan.streetman@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: dan.streetman@canonical.com
> [mailto:dan.streetman@canonical.com]
> Sent: Monday, October 26, 2015 5:20 PM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore,
> Donald C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> Dan Streetman; Dan Streetman
> Subject: [PATCH] ixgbe: check Master Disable bit after setting
> 
> From: Dan Streetman <dan.streetman@canonical.com>
> 
> Spec section 8.2.4.1.1 notes that after setting the PCIe Master Disable bit, it
> must be read to verify it was set before polling the Master Enable status bit.
> 
> This adds the check to verify the Master Disable bit was set.
> 
> This also corrects the spec section number reference - the Master Disable
> section is 5.2.4.3.2, not 5.2.5.3.2.
> 
> Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> index 3f56a80..abfada7 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> @@ -2453,6 +2453,16 @@ static s32 ixgbe_disable_pcie_master(struct
> ixgbe_hw *hw)
>  	/* Always set this bit to ensure any future transactions are blocked */
>  	IXGBE_WRITE_REG(hw, IXGBE_CTRL, IXGBE_CTRL_GIO_DIS);
> 
> +	/* Spec sec 8.2.4.1.1, Master Disable bit :
> +	 * "After doing any change to this bit the host must read that
> +	 *  the bit has been modified as expected before reading
> +	 *  STATUS.PCIe Master Enable Status bit."
> +	 */
> +	if (!(IXGBE_READ_REG(hw, IXGBE_CTRL) & IXGBE_CTRL_GIO_DIS)) {
> +		hw_err(hw, "GIO Master Disable bit didn't set\n");
> +		goto gio_dis_fail;
> +	}
> +
>  	/* Exit if master requests are blocked */
>  	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO) ||
>  	    ixgbe_removed(hw->hw_addr))
> @@ -2467,13 +2477,14 @@ static s32 ixgbe_disable_pcie_master(struct
> ixgbe_hw *hw)
> 
>  	/*
>  	 * Two consecutive resets are required via CTRL.RST per datasheet
> -	 * 5.2.5.3.2 Master Disable.  We set a flag to inform the reset routine
> +	 * 5.2.4.3.2 Master Disable.  We set a flag to inform the reset
> +routine
>  	 * of this need.  The first reset prevents new master requests from
>  	 * being issued by our device.  We then must wait 1usec or more for
> any
>  	 * remaining completions from the PCIe bus to trickle in, and then
> reset
>  	 * again to clear out any effects they may have had on our device.
>  	 */
>  	hw_dbg(hw, "GIO Master Disable bit didn't clear - requesting
> resets\n");
> +gio_dis_fail:
>  	hw->mac.flags |= IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
> 
>  	/*
> --
> 2.5.0

Is this patch correcting some issue you're running in to?
I ask as I don't believe this check is necessary, since right below setting CTLR. PCIE_MASTER_DISABLE we loop waiting for  STATUS. PCIE_MASTER_ENABLE_STATUS to clear.   This should have the same effect as verify that the write to CTLR. PCIE_MASTER_DISABLE has cleared.

Thanks,
Don Skidmore <donald.c.skidmore@intel.com>
