From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 07/15] ixgbe: fix SFF data dumps of SFP+ modules
Date: Fri, 2 Aug 2013 11:08:37 +0200
Message-ID: <1375434517.24371.24.camel@deadeye.wl.decadent.org.uk>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1375102331-23905-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Emil Tantilov <emil.s.tantilov@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34050 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758048Ab3HBJIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 05:08:44 -0400
In-Reply-To: <1375102331-23905-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-29 at 05:52 -0700, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch fixes several issues with the previous implementation of the
> SFF data dump of SFP+ modules:
> 
> - removed the __IXGBE_READ_I2C flag - I2C access locking is handled in the
>   HW specific routines
> 
> - fixed the read loop to read data from ee->offset to ee->len
> 
> - the reads fail if __IXGBE_IN_SFP_INIT is set in the process - this is
>   needed because on some HW I2C operations can take long time and disrupt
>   the SFP and link detection process
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Reported-by: Ben Hutchings <bhutchings@solarflare.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]
> @@ -2969,48 +2955,25 @@ static int ixgbe_get_module_eeprom(struct net_device *dev,
>  	int i = 0;
>  	int ret_val = 0;
>  
> -	/* ixgbe_get_module_info is called before this function in all
> -	 * cases, so we do not need any checks we already do above,
> -	 * and can trust ee->len to be a known value.
> -	 */
> +	if (ee->len == 0)
> +		return -EINVAL;
>  
> -	while (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
> -		msleep(100);
> -	set_bit(__IXGBE_READ_I2C, &adapter->state);
> +	for (i = ee->offset; i < ee->len; i++) {

                               i < ee->offset + ee->len

> +		/* I2C reads can take long time */
> +		if (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
> +			return -EBUSY;
>  
> -	/* Read the first block, SFF-8079 */
> -	for (i = 0; i < ETH_MODULE_SFF_8079_LEN; i++) {
> -		status = hw->phy.ops.read_i2c_eeprom(hw, i, &databyte);
> -		if (status != 0) {
> -			/* Error occured while reading module */
> +		if (i < ETH_MODULE_SFF_8079_LEN)
> +			status  = hw->phy.ops.read_i2c_eeprom(hw, i, &databyte);
> +		else
> +			status = hw->phy.ops.read_i2c_sff8472(hw, i, &databyte);
[...]
                                                     i - ETH_MODULE_SFF_8079_LEN ?

But this works anyway because the address is truncated to u8.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
