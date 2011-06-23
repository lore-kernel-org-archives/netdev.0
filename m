From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 07/12] ixgbe: add support for modifying UDP RSS flow
 hash options
Date: Thu, 23 Jun 2011 03:25:00 +0100
Message-ID: <1308795900.3093.713.camel@localhost>
References: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308793476-11596-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51522 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758041Ab1FWCZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 22:25:04 -0400
In-Reply-To: <1308793476-11596-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-22 at 18:44 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch adds the ability to add or remove the UDP source and destination
> ports from the flow hash generated for RSS.  Currently the UDP flow hash is
> always disabled.  By adding support for enabling the UDP flow hash we are
> now providing the option of generating an RSS hash based on the UDP source
> and destination port numbers.
[...]
> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
[...]
> @@ -2681,6 +2726,110 @@ static int ixgbe_del_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
>  	return err;
>  }
>  
> +#define UDP_RSS_FLAGS (IXGBE_FLAG2_RSS_FIELD_IPV4_UDP | \
> +		       IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
> +static int ixgbe_set_rss_hash_opt(struct ixgbe_adapter *adapter,
> +				  struct ethtool_rxnfc *nfc)
> +{
> +	u32 flags2 = adapter->flags2;
> +
> +	/*
> +	 * RSS does not support anything other than hashing
> +	 * to queues on src and dst IPs and ports
> +	 */
> +	if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
> +			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
> +		return -EINVAL;
> +
> +	switch (nfc->flow_type) {
> +	case TCP_V4_FLOW:
> +	case TCP_V6_FLOW:
> +		if (!(nfc->data & RXH_IP_SRC) ||
> +		    !(nfc->data & RXH_IP_DST) ||
> +		    !(nfc->data & RXH_L4_B_0_1) ||
> +		    !(nfc->data & RXH_L4_B_2_3))
> +			return -EINVAL;
> +		break;

This can be written as a simple equality test.

> +	case UDP_V4_FLOW:
> +		if (!(nfc->data & RXH_IP_SRC) ||
> +		    !(nfc->data & RXH_IP_DST))
> +			return -EINVAL;
> +		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {

You could just as well include all flags in the switch.

[...]
> +	case AH_ESP_V4_FLOW:
> +	case AH_V4_FLOW:
> +	case ESP_V4_FLOW:
> +	case SCTP_V4_FLOW:
> +	case AH_ESP_V6_FLOW:
> +	case AH_V6_FLOW:
> +	case ESP_V6_FLOW:
> +	case SCTP_V6_FLOW:
> +		if (!(nfc->data & RXH_IP_SRC) ||
> +		    !(nfc->data & RXH_IP_DST))
> +			return -EINVAL;
> +               break;
[...]

This should be written as an equality test, otherwise you will ignore a
request to include port numbers in the hash for these flow classes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

