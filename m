From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 04/15] e1000e: helper functions for accessing EMI registers
Date: Fri, 11 Jan 2013 10:32:34 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B710A@saturn3.aculab.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com> <1357899831-4168-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allan" <bruce.w.allan@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33379 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752941Ab3AKKeb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 05:34:31 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00642-03 for <netdev@vger.kernel.org>;
 Fri, 11 Jan 2013 10:34:28 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1357899831-4168-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The Extended Management Interface (EMI) registers are accessed by first
> writing the EMI register offset to the EMI_ADDR regiter and then either
> reading or writing the data to/from the EMI_DATA register.  Add helper
> functions for performing these steps and convert existing EMI register
> accesses accordingly.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 84 ++++++++++++++++++++++-------
>  1 file changed, 65 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> index 7d5f6b7..8004d71 100644
> --- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
> +++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> @@ -153,7 +153,7 @@
>  #define I82579_LPI_CTRL_ENABLE_MASK		0x6000
>  #define I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT	0x80
> 
> -/* EMI Registers */
> +/* Extended Management Interface (EMI) Registers */
>  #define I82579_EMI_ADDR         0x10
>  #define I82579_EMI_DATA         0x11
>  #define I82579_LPI_UPDATE_TIMER 0x4805	/* in 40ns units + 40 ns base value */
> @@ -789,6 +789,58 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_hw *hw)
>  }
> 
>  /**
> + *  __e1000_access_emi_reg_locked - Read/write EMI register
> + *  @hw: pointer to the HW structure
> + *  @addr: EMI address to program
> + *  @data: pointer to value to read/write from/to the EMI address
> + *  @read: boolean flag to indicate read or write
> + *
> + *  This helper function assumes the SW/FW/HW Semaphore is already acquired.
> + **/
> +static s32 __e1000_access_emi_reg_locked(struct e1000_hw *hw, u16 address,
> +					 u16 *data, bool read)
> +{
> +	s32 ret_val = 0;
> +
> +	ret_val = e1e_wphy_locked(hw, I82579_EMI_ADDR, address);
> +	if (ret_val)
> +		return ret_val;
> +
> +	if (read)
> +		ret_val = e1e_rphy_locked(hw, I82579_EMI_DATA, data);
> +	else
> +		ret_val = e1e_wphy_locked(hw, I82579_EMI_DATA, *data);
> +
> +	return ret_val;
> +}
> +
> +/**
> + *  e1000_read_emi_reg_locked - Read Extended Management Interface register
> + *  @hw: pointer to the HW structure
> + *  @addr: EMI address to program
> + *  @data: value to be read from the EMI address
> + *
> + *  Assumes the SW/FW/HW Semaphore is already acquired.
> + **/
> +static s32 e1000_read_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 *data)
> +{
> +	return __e1000_access_emi_reg_locked(hw, addr, data, true);
> +}
> +
> +/**
> + *  e1000_write_emi_reg_locked - Write Extended Management Interface register
> + *  @hw: pointer to the HW structure
> + *  @addr: EMI address to program
> + *  @data: value to be written to the EMI address
> + *
> + *  Assumes the SW/FW/HW Semaphore is already acquired.
> + **/
> +static s32 e1000_write_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 data)
> +{
> +	return __e1000_access_emi_reg_locked(hw, addr, &data, false);
> +}
> +
> +/**

I'm not sure it is worth having all three routines.
Personally I'd inline the first into the latter two.

	David
