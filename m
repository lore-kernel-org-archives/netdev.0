From: Brandon Philips <brandon@ifup.org>
Subject: Re: [PATCH][2.6.32.y] igb: change how we handle alternate mac
 addresses
Date: Tue, 27 Jul 2010 12:47:30 -0700
Message-ID: <20100727194730.GF14377@mmm.home.ifup.org>
References: <20100727164825.GH16596@mmm.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: stable@kernel.org, Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ifup.org ([198.145.64.140]:38915 "EHLO ifup.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815Ab0G0Trh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 15:47:37 -0400
Content-Disposition: inline
In-Reply-To: <20100727164825.GH16596@mmm.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09:48 Tue 27 Jul 2010, bphilips@suse.de wrote:
> Without this patch bonding with igb doesn't work correctly. Applies to
> 2.6.32.y.

Sorry, I missed the CCing netdev. -stable patch proposal for 2.6.32.y

Thanks, Brandon

> From 22896639af98ebc721a94ed71fc3acf2fb4a24dc Mon Sep 17 00:00:00 2001
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Mon, 5 Oct 2009 06:34:25 +0000
> Subject: [PATCH] igb: change how we handle alternate mac addresses
> 
> This patch allows us to treat the alternate mac address as though it is the
> physical address on the adapter.  This is accomplished by letting the
> alt_mac_address function to only fail on an NVM error.  If no errors occur
> and the alternate mac address is not present then RAR0 is read as the
> default mac address.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/igb/e1000_82575.c |   13 +++++++++++--
>  drivers/net/igb/e1000_hw.h    |    2 ++
>  drivers/net/igb/e1000_mac.c   |   17 +++++++++--------
>  3 files changed, 22 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
> index e07f66c..45063c2 100644
> --- a/drivers/net/igb/e1000_82575.c
> +++ b/drivers/net/igb/e1000_82575.c
> @@ -1152,9 +1152,18 @@ static s32 igb_read_mac_addr_82575(struct e1000_hw *hw)
>  {
>  	s32 ret_val = 0;
>  
> -	if (igb_check_alt_mac_addr(hw))
> -		ret_val = igb_read_mac_addr(hw);
> +	/*
> +	 * If there's an alternate MAC address place it in RAR0
> +	 * so that it will override the Si installed default perm
> +	 * address.
> +	 */
> +	ret_val = igb_check_alt_mac_addr(hw);
> +	if (ret_val)
> +		goto out;
> +
> +	ret_val = igb_read_mac_addr(hw);
>  
> +out:
>  	return ret_val;
>  }
>  
> diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
> index 4e7850d..fad7cf5 100644
> --- a/drivers/net/igb/e1000_hw.h
> +++ b/drivers/net/igb/e1000_hw.h
> @@ -54,6 +54,8 @@ struct e1000_hw;
>  #define E1000_FUNC_0     0
>  #define E1000_FUNC_1     1
>  
> +#define E1000_ALT_MAC_ADDRESS_OFFSET_LAN1   3
> +
>  enum e1000_mac_type {
>  	e1000_undefined = 0,
>  	e1000_82575,
> diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
> index 986aa90..4969a5b 100644
> --- a/drivers/net/igb/e1000_mac.c
> +++ b/drivers/net/igb/e1000_mac.c
> @@ -185,13 +185,12 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
>  	}
>  
>  	if (nvm_alt_mac_addr_offset == 0xFFFF) {
> -		ret_val = -(E1000_NOT_IMPLEMENTED);
> +		/* There is no Alternate MAC Address */
>  		goto out;
>  	}
>  
>  	if (hw->bus.func == E1000_FUNC_1)
> -		nvm_alt_mac_addr_offset += ETH_ALEN/sizeof(u16);
> -
> +		nvm_alt_mac_addr_offset += E1000_ALT_MAC_ADDRESS_OFFSET_LAN1;
>  	for (i = 0; i < ETH_ALEN; i += 2) {
>  		offset = nvm_alt_mac_addr_offset + (i >> 1);
>  		ret_val = hw->nvm.ops.read(hw, offset, 1, &nvm_data);
> @@ -206,14 +205,16 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
>  
>  	/* if multicast bit is set, the alternate address will not be used */
>  	if (alt_mac_addr[0] & 0x01) {
> -		ret_val = -(E1000_NOT_IMPLEMENTED);
> +		hw_dbg("Ignoring Alternate Mac Address with MC bit set\n");
>  		goto out;
>  	}
>  
> -	for (i = 0; i < ETH_ALEN; i++)
> -		hw->mac.addr[i] = hw->mac.perm_addr[i] = alt_mac_addr[i];
> -
> -	hw->mac.ops.rar_set(hw, hw->mac.perm_addr, 0);
> +	/*
> +	 * We have a valid alternate MAC address, and we want to treat it the
> +	 * same as the normal permanent MAC address stored by the HW into the
> +	 * RAR. Do this by mapping this address into RAR0.
> +	 */
> +	hw->mac.ops.rar_set(hw, alt_mac_addr, 0);
>  
>  out:
>  	return ret_val;
> -- 
> 1.7.1
> 
