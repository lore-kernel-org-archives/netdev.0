From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next 11/11 v2] ixgbe: allow eeprom writes via ethtool
Date: Sat, 1 Oct 2011 11:31:05 +0200
Message-ID: <20111001093105.GA9885@electric-eye.fr.zoreil.com>
References: <1317444771-13962-1-git-send-email-jeffrey.t.kirsher@intel.com> <1317444771-13962-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44870 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab1JAJcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2011 05:32:54 -0400
Content-Disposition: inline
In-Reply-To: <1317444771-13962-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> index 10ea29f..fb47abb 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -812,6 +812,66 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
[...]
> +	ptr = (void *)eeprom_buff;

(nit) useless cast to void *.

> +
> +	if (eeprom->offset & 1) {
[...]
> +		ret_val = hw->eeprom.ops.read(hw, first_word, &eeprom_buff[0]);
> +		ptr++;
> +	}
> +	if (((eeprom->offset + eeprom->len) & 1) && (ret_val == 0)) {
[...]
> +		ret_val = hw->eeprom.ops.read(hw, last_word,
> +					  &eeprom_buff[last_word - first_word]);
> +	}

I guess that the code tries to do its best to write something even when the
reads or writes partially fail but this one should imho be :

	if ((eeprom->offset + eeprom->len) & 1) {
[...]
		ret_val |= hw->eeprom.ops.read(hw, last_word,

> +
> +	/* Device's eeprom is always little-endian, word addressable */
> +	for (i = 0; i < last_word - first_word + 1; i++)
> +		le16_to_cpus(&eeprom_buff[i]);

Shouldn't there be (drivers/net/ethernet/intel/ixgbe/ixgbe_type.h):

struct ixgbe_eeprom_operations {
[...]
        s32 (*read)(struct ixgbe_hw *, u16, __le16 *);

instead of :

struct ixgbe_eeprom_operations {
[...]
        s32 (*read)(struct ixgbe_hw *, u16, u16 *);

[...]
> +	/* Update the checksum */
> +	hw->eeprom.ops.update_checksum(hw);

The returned status code is ignored.

-- 
Ueimor
