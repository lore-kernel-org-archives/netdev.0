From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix for link failure on SFP+ DA
 cables
Date: Wed, 01 Dec 2010 23:41:41 -0800
Message-ID: <1291275701.1761.40.camel@Joe-Laptop>
References: <20101202065921.13413.91380.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Don Skidmore <donald.c.skidmore@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2138 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab0LBHlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 02:41:42 -0500
In-Reply-To: <20101202065921.13413.91380.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-01 at 22:59 -0800, Jeff Kirsher wrote:
> This patch helps prevent FW/SW semaphore collision from leading
> to link establishment failure.  The collision might mess up the
> PHY registers so we reset the PHY.  However there are SFI/KR areas
> in the PHY that are not reset with a Reset_AN so we need to change
> LMS to reset it.  Also wait until AN state machine is AN_GOOD
[]
>  drivers/net/ixgbe/ixgbe_82599.c |   28 +++++++++++++++++++++++++---
> diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
[]
> @@ -116,14 +118,34 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
>  			IXGBE_WRITE_FLUSH(hw);
>  			hw->eeprom.ops.read(hw, ++data_offset, &data_value);
>  		}
> -		/* Now restart DSP by setting Restart_AN */
> -		IXGBE_WRITE_REG(hw, IXGBE_AUTOC,
> -		    (IXGBE_READ_REG(hw, IXGBE_AUTOC) | IXGBE_AUTOC_AN_RESTART));
>  
>  		/* Release the semaphore */
>  		ixgbe_release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
>  		/* Delay obtaining semaphore again to allow FW access */
>  		msleep(hw->eeprom.semaphore_delay);

might these msleeps be usleep_range?

[]

> +		/* Wait for AN to leave state 0 */
> +		for (i = 0; i < 10; i++) {
> +			msleep(4);

Perhaps usleep_range?

Maybe all the msleep uses < 20ms in the intel drivers?

$ grep -nPr --include=*.[ch] "msleep\s*\(\s*1?\d\s*\)" drivers/net/ig* drivers/net/ixg* drivers/net/e100* | wc -l
123

Maybe something like doubling the sleep value
for the upper bound range?

Here's a little script that does that.

$ grep -nPrl --include=*.[ch] "msleep\s*\(\s*1?\d\s*\)" \
	drivers/net/ig* drivers/net/ixg* drivers/net/e100* | \
xargs perl -p -i -e 's/msleep\s*\(\s*(1?\d)\s*\)/"usleep_range\(${1}000, " . scalar($1) * 2 . "000\)"/ge'


