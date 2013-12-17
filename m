From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net 6/6] e1000e: fix overrun of PHY RAR array
Date: Tue, 17 Dec 2013 15:13:45 +0800
Message-ID: <52AFF9A9.3050307@redhat.com>
References: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com> <1379106730-14994-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shawn Rader <shawn.t.rader@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	David Ertman <davidx.m.ertman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752083Ab3LQHN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 02:13:57 -0500
In-Reply-To: <1379106730-14994-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2013 05:12 AM, Jeff Kirsher wrote:
> From: David Ertman <davidx.m.ertman@intel.com>
>
> When copying the MAC RAR registers to PHY there is an error in the
> calculation of the rar_entry_count, which causes a write of unknown/
> undefined register space in the MAC to unknown/undefined register space in
> the PHY.
>
> This patch fixes the overrun with writing to the PHY RAR and also fixes the
> ethtool offline register tests so that the correctly addressed registers
> have the appropriate bitmasks for R/W and RO bits for affected parts.
>
> Shawn Rader gets credit for finding and fixing the register overrun.
>
> Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
> CC: Shawn Rader <shawn.t.rader@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ethtool.c |  8 ++++++++
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 13 ++++++++-----
>  drivers/net/ethernet/intel/e1000e/ich8lan.h |  2 +-
>  3 files changed, 17 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
> index a8633b8..d14c8f5 100644
> --- a/drivers/net/ethernet/intel/e1000e/ethtool.c
> +++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
> @@ -922,6 +922,14 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
>  			else
>  				mask &= ~(1 << 30);
>  		}
> +		if (mac->type == e1000_pch2lan) {
> +			/* SHRAH[0,1,2] different than previous */
> +			if (i == 7)
> +				mask &= 0xFFF4FFFF;
> +			/* SHRAH[3] different than SHRAH[0,1,2] */
> +			if (i == 10)
> +				mask |= (1 << 30);
> +		}
>  
>  		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1), mask,
>  				       0xFFFFFFFF);
> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> index af08188..42f0f67 100644
> --- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
> +++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> @@ -1371,7 +1371,10 @@ static void e1000_rar_set_pch2lan(struct e1000_hw *hw, u8 *addr, u32 index)
>  		return;
>  	}
>  
> -	if (index < hw->mac.rar_entry_count) {
> +	/* RAR[1-6] are owned by manageability.  Skip those and program the
> +	 * next address into the SHRA register array.
> +	 */
> +	if (index < (u32)(hw->mac.rar_entry_count - 6)) {
>  		s32 ret_val;

This looks wrong. The caller writes the addresses in the reverse order,
so the first index we get here is E1000_PCH2_RAR_ENTRIES - 1 which
obviously fails the check. So nothing were write to RAR/SHA.

This breaks macvtap guest, and after I revert this patch, it works.

Also the comment above looks confused, it said the RAR[1-6] should be
skipped, but E1000_PCH2_RAR_ENTRIES takes it into account which may need
some explanation.
>  
>  		ret_val = e1000_acquire_swflag_ich8lan(hw);
> @@ -1962,8 +1965,8 @@ void e1000_copy_rx_addrs_to_phy_ich8lan(struct e1000_hw *hw)
>  	if (ret_val)
>  		goto release;
>  
> -	/* Copy both RAL/H (rar_entry_count) and SHRAL/H (+4) to PHY */
> -	for (i = 0; i < (hw->mac.rar_entry_count + 4); i++) {
> +	/* Copy both RAL/H (rar_entry_count) and SHRAL/H to PHY */
> +	for (i = 0; i < (hw->mac.rar_entry_count); i++) {
>  		mac_reg = er32(RAL(i));
>  		hw->phy.ops.write_reg_page(hw, BM_RAR_L(i),
>  					   (u16)(mac_reg & 0xFFFF));
> @@ -2007,10 +2010,10 @@ s32 e1000_lv_jumbo_workaround_ich8lan(struct e1000_hw *hw, bool enable)
>  		return ret_val;
>  
>  	if (enable) {
> -		/* Write Rx addresses (rar_entry_count for RAL/H, +4 for
> +		/* Write Rx addresses (rar_entry_count for RAL/H, and
>  		 * SHRAL/H) and initial CRC values to the MAC
>  		 */
> -		for (i = 0; i < (hw->mac.rar_entry_count + 4); i++) {
> +		for (i = 0; i < hw->mac.rar_entry_count; i++) {
>  			u8 mac_addr[ETH_ALEN] = { 0 };
>  			u32 addr_high, addr_low;
>  
> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
> index 5986569..217090d 100644
> --- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
> +++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
> @@ -98,7 +98,7 @@
>  #define PCIE_ICH8_SNOOP_ALL	PCIE_NO_SNOOP_ALL
>  
>  #define E1000_ICH_RAR_ENTRIES	7
> -#define E1000_PCH2_RAR_ENTRIES	5	/* RAR[0], SHRA[0-3] */
> +#define E1000_PCH2_RAR_ENTRIES	11      /* RAR[0-6], SHRA[0-3] */
>  #define E1000_PCH_LPT_RAR_ENTRIES	12	/* RAR[0], SHRA[0-10] */
>  
>  #define PHY_PAGE_SHIFT		5
