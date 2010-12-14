From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ixgb: Convert to new vlan model.
Date: Tue, 14 Dec 2010 16:31:55 +0000
Message-ID: <1292344315.20458.6.camel@bwh-desktop>
References: <1292298163-30343-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57375 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757308Ab0LNQb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 11:31:59 -0500
In-Reply-To: <1292298163-30343-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-13 at 19:42 -0800, Jesse Gross wrote:
> This switches the ixgb driver to use the new vlan interfaces.
> In doing this, it completes the work begun in
> ae54496f9e8d40c89e5668205c181dccfa9ecda1 allowing the use of
> hardware vlan insertion without having a vlan group configured.
[...]
> diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
> index 43994c1..0e4c527 100644
> --- a/drivers/net/ixgb/ixgb_ethtool.c
> +++ b/drivers/net/ixgb/ixgb_ethtool.c
> @@ -706,6 +706,45 @@ ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
>  	}
>  }
>  
> +static int ixgb_set_flags(struct net_device *netdev, u32 data)
> +{
> +	struct ixgb_adapter *adapter = netdev_priv(netdev);
> +	bool need_reset;
> +	int rc;
> +
> +	/* The hardware requires that RX vlan stripping and TX vlan insertion
> +	 * be configured together.  Therefore, if one setting changes adjust the
> +	 * other one to match.
> +	 */
> +	if (!!(data & ETH_FLAG_RXVLAN) != !!(data & ETH_FLAG_TXVLAN)) {
> +		if ((data & ETH_FLAG_RXVLAN) !=
> +		    (netdev->features & NETIF_F_HW_VLAN_RX))
> +			data ^= ETH_FLAG_TXVLAN;
> +		else if ((data & ETH_FLAG_TXVLAN) !=
> +		    (netdev->features & NETIF_F_HW_VLAN_TX))
> +			data ^= ETH_FLAG_RXVLAN;
> +	}
[...]

I think this should reject attempts to change just one flag with
-EINVAL, rather than quietly 'fixing' the setting.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

