From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 05/13] igb: Support to read and export SFF-8472/8079
 data
Date: Thu, 4 Apr 2013 20:07:51 +0100
Message-ID: <1365102471.2735.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1365075480-20183-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	"Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	=?ISO-8859-1?Q?Aur=E9lien?= Guillaume <footplus@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50457 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764364Ab3DDTH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 15:07:59 -0400
In-Reply-To: <1365075480-20183-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 04:37 -0700, Jeff Kirsher wrote:
> From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
> 
> This patch adds support to read and export SFF-8472/8079 (SFP data)
> over i2c, through Ethtool.
[...]
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
[...]
> +static int igb_get_module_eeprom(struct net_device *netdev,
> +				 struct ethtool_eeprom *ee, u8 *data)
> +{
> +	struct igb_adapter *adapter = netdev_priv(netdev);
> +	struct e1000_hw *hw = &adapter->hw;
> +	u32 status = E1000_SUCCESS;
> +	u16 dataword = 0xFF;
> +	int i = 0;
> +
> +	/* Read the first block, SFF-8079, 2 bytes at a time */
> +	for (i = 0; i < ETH_MODULE_SFF_8079_LEN; i += 2) {
> +		status = igb_read_phy_reg_i2c(hw, i, &dataword);
> +		if (status != E1000_SUCCESS)
> +			/* Error occurred while reading module */
> +			return -EIO;
> +
> +		data[i] = (dataword >> 8) & 0xFF;
> +		data[i+1] = dataword & 0xFF;
> +	}

What if ee->offset != 0 or ee->len < ETH_MODULE_SFF_8079_LEN?

> +	/* If the second block is requested, check if SFF-8472 is supported. */
> +	if (ee->len == ETH_MODULE_SFF_8472_LEN) {
> +		if (data[IGB_SFF_8472_COMP] == IGB_SFF_8472_UNSUP)
> +			return -EOPNOTSUPP;
> +
> +		/* Read the second block, SFF-8472, 2 bytes at a time */
> +		for (i = ETH_MODULE_SFF_8079_LEN;
> +		     i < ETH_MODULE_SFF_8472_LEN; i += 2) {
> +			status = igb_read_phy_reg_i2c(hw, i, &dataword);
> +			if (status != E1000_SUCCESS)
> +				return -EIO;
> +
> +			data[i] = (dataword >> 8) & 0xFF;
> +			data[i+1] = dataword & 0xFF;
> +		}
> +	}
[...]

What if ee->offset != 0 or ETH_MODULE_SFF_8079_LEN < ee->len <
ETH_MODULE_SFF_8472_LEN?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
