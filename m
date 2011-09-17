From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/13] ixgb: eliminate checkstack warnings
Date: Sat, 17 Sep 2011 01:43:26 -0700
Message-ID: <1316249007.1610.13.camel@Joe-Laptop>
References: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316246677-8830-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51897 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751737Ab1IQIn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Sep 2011 04:43:27 -0400
In-Reply-To: <1316246677-8830-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-09-17 at 01:04 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Really trivial fix, use kzalloc/kree instead of stack space.

Some more trivialities...

> diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c\
[]
> @@ -1120,8 +1120,12 @@ ixgb_set_multi(struct net_device *netdev)
>  		rctl |= IXGB_RCTL_MPE;
>  		IXGB_WRITE_REG(hw, RCTL, rctl);
>  	} else {
> -		u8 mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
> -			    IXGB_ETH_LENGTH_OF_ADDRESS];
> +		u8 *mta = kzalloc(IXGB_MAX_NUM_MULTICAST_ADDRESSES *
> +			      IXGB_ETH_LENGTH_OF_ADDRESS, GFP_KERNEL);

This doesn't need to be kzalloc as every byte is overwritten.
It should be kmalloc.

Maybe delete the #define IXGB_ETH_LENGTH_OF_ADDRESS and
sed 's/\bIXGB_ETH_LENGTH_OF_ADDRESS\b/ETH_ALEN/g' ?

Perhaps this loop could be clearer without the multiply:

		i = 0;
		netdev_for_each_mc_addr(ha, netdev)
			memcpy(&mta[i++ * IXGB_ETH_LENGTH_OF_ADDRESS],
			       ha->addr, IXGB_ETH_LENGTH_OF_ADDRESS);

Perhaps:

		u8 *addr = mta;
		netdev_for_each_mc_addr(ha, netdev) {
			memcpy(addr, ha->addr, ETH_ALEN);
			addr += ETH_ALEN;
		}
