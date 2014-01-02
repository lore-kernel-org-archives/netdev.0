From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 3/9] ixgbe: Check register reads for adapter removal
Date: Thu, 2 Jan 2014 18:10:49 +0000
Message-ID: <1388686249.9947.12.camel@bwh-desktop.uk.level5networks.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388655221-25428-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Mark Rustad <mark.d.rustad@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8238 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbaABSKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:10:54 -0500
In-Reply-To: <1388655221-25428-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 01:33 -0800, Jeff Kirsher wrote:
> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> When CONFIG_IXGBE_LER is defined, check all register reads for
> adapter removal by checking the status register after any register
> read that returns 0xFFFFFFFF. Since the status register will never
> return 0xFFFFFFFF unless the adapter is removed, such a value from
> a status register read confirms the removal.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 21 +++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 40 ++++++++++++++++++++++---
>  3 files changed, 58 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 9e9b8d0..ad34757 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
[...]
> @@ -141,7 +150,19 @@ static inline void IXGBE_WRITE_REG64(struct ixgbe_hw *hw, u32 reg, u64 value)
>  
>  static inline u32 IXGBE_READ_REG(struct ixgbe_hw *hw, u32 reg)
>  {
> +#ifdef CONFIG_IXGBE_LER
> +	u8 __iomem *reg_addr = hw->hw_addr;

This should have an ACCESS_ONCE() so the compiler definitely won't read
hw->hw_addr a second time after it's been validated.

Ben.

> +	u32 value;
> +
> +	if (IXGBE_REMOVED(reg_addr))
> +		return IXGBE_FAILED_READ_REG;
> +	value = readl(reg_addr + reg);
> +	if (unlikely(value == IXGBE_FAILED_READ_REG))
> +		ixgbe_check_remove(hw, reg);
> +	return value;
> +#else
>  	return readl(hw->hw_addr + reg);
> +#endif /* CONFIG_IXGBE_LER */
>  }
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
