From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 4/9] ixgbe: Check for adapter removal on register
 writes
Date: Thu, 2 Jan 2014 18:12:01 +0000
Message-ID: <1388686321.9947.13.camel@bwh-desktop.uk.level5networks.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388655221-25428-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Mark Rustad <mark.d.rustad@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8257 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbaABSMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:12:05 -0500
In-Reply-To: <1388655221-25428-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 01:33 -0800, Jeff Kirsher wrote:
> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> Prevent writes to an adapter that has been detected as removed
> by a previous failing read. This also fixes some include file
> ordering confusion that this patch revealed.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
[...]
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> @@ -135,7 +135,11 @@ void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
>  
>  static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
>  {
> -	writel(value, hw->hw_addr + reg);
> +	u8 __iomem *reg_addr = hw->hw_addr;
> +
> +	if (IXGBE_REMOVED(reg_addr))
> +		return;
> +	writel(value, reg_addr + reg);
>  }
>  
>  #ifndef writeq
> @@ -145,7 +149,11 @@ static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
>  
>  static inline void IXGBE_WRITE_REG64(struct ixgbe_hw *hw, u32 reg, u64 value)
>  {
> -	writeq(value, hw->hw_addr + reg);
> +	u8 __iomem *reg_addr = hw->hw_addr;
> +
> +	if (IXGBE_REMOVED(reg_addr))
> +		return;
> +	writeq(value, reg_addr + reg);
>  }
[...] 

These should also use ACCESS_ONCE() to read hw->hw_addr.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
