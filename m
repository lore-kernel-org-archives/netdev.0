From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next patch 3/12] bnx2x: Add support for 4-tupple UDP RSS
Date: Wed, 13 Jun 2012 19:20:32 +0100
Message-ID: <1339611632.2612.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
	 <1339591464-10554-4-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eilong@broadcom.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28469 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752254Ab2FMSUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 14:20:35 -0400
In-Reply-To: <1339591464-10554-4-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 15:44 +0300, Merav Sicron wrote:
> This change enables to control via ethtool whether to do UDP RSS on 2-tupple
> (IP source / destination only) or on 4-tupple (include UDP source / destination
> port). It also enables to read back the RSS configuration.
[...]
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> @@ -2600,6 +2600,52 @@ static int bnx2x_set_phys_id(struct net_device *dev,
>  	return 0;
>  }
>  
> +static int bnx2x_get_rss_flags(struct bnx2x *bp, struct ethtool_rxnfc *info)
> +{
> +
> +	switch (info->flow_type) {
> +	case TCP_V4_FLOW:
> +	case TCP_V6_FLOW:
> +		info->data = RXH_IP_SRC | RXH_IP_DST |
> +			     RXH_L4_B_0_1 | RXH_L4_B_2_3;
> +		break;
> +	case UDP_V4_FLOW:
> +		if (bp->rss_conf_obj.udp_rss_v4)
> +			info->data = RXH_IP_SRC | RXH_IP_DST |
> +				     RXH_L4_B_0_1 | RXH_L4_B_2_3;
> +		else
> +			info->data = RXH_IP_SRC | RXH_IP_DST;
> +		break;
> +	case UDP_V6_FLOW:
> +		if (bp->rss_conf_obj.udp_rss_v6)
> +			info->data = RXH_IP_SRC | RXH_IP_DST |
> +				     RXH_L4_B_0_1 | RXH_L4_B_2_3;
> +		else
> +			info->data = RXH_IP_SRC | RXH_IP_DST;
> +		break;
> +	case IPV4_FLOW:
> +	case IPV6_FLOW:
> +		info->data = RXH_IP_SRC | RXH_IP_DST;
> +		break;
> +	case SCTP_V4_FLOW:
> +	case AH_ESP_V4_FLOW:
> +	case AH_V4_FLOW:
> +	case ESP_V4_FLOW:
> +	case SCTP_V6_FLOW:
> +	case AH_ESP_V6_FLOW:
> +	case AH_V6_FLOW:
> +	case ESP_V6_FLOW:
> +	case IP_USER_FLOW:
> +	case ETHER_FLOW:
> +		info->data = 0;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
[...]

Don't try to enumerate all flow types; we may add others in future.  You
should set info->data = 0 for any type for which RSS is not supported.

Otherwise I think the ethtool bits are fine.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
