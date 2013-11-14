From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH net 1/6] tg3: Validate hwtstamp_config completely
 before applying it
Date: Wed, 13 Nov 2013 16:55:59 -0800
Message-ID: <52841F9F.2040907@broadcom.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
 <1384389656.29151.7.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Richard Cochran" <richardcochran@gmail.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4417 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab3KNA4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 19:56:38 -0500
In-Reply-To: <1384389656.29151.7.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/13/2013 04:40 PM, Ben Hutchings wrote:
> tg3_hwtstamp_ioctl() should validate all fields of hwtstamp_config
> before making any changes.  Currently it sets the TX configuration
> before validating the rx_filter field.
>
> Compile-tested only.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>   drivers/net/ethernet/broadcom/tg3.c | 16 +++++++---------
>   1 file changed, 7 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 12d961c4ebca..d3a700f86f1a 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -13598,16 +13598,9 @@ static int tg3_hwtstamp_ioctl(struct net_device *dev,
>   	if (stmpconf.flags)
>   		return -EINVAL;
>
> -	switch (stmpconf.tx_type) {
> -	case HWTSTAMP_TX_ON:
> -		tg3_flag_set(tp, TX_TSTAMP_EN);
> -		break;
> -	case HWTSTAMP_TX_OFF:
> -		tg3_flag_clear(tp, TX_TSTAMP_EN);
> -		break;
> -	default:
> +	if (stmpconf.tx_type != HWTSTAMP_TX_ON &&
> +	    stmpconf.tx_type != HWTSTAMP_TX_OFF)
>   		return -ERANGE;
> -	}
>
>   	switch (stmpconf.rx_filter) {
>   	case HWTSTAMP_FILTER_NONE:
> @@ -13669,6 +13662,11 @@ static int tg3_hwtstamp_ioctl(struct net_device *dev,
>   		tw32(TG3_RX_PTP_CTL,
>   		     tp->rxptpctl | TG3_RX_PTP_CTL_HWTS_INTERLOCK);
>
> +	if (stmpconf.tx_type == HWTSTAMP_TX_ON)
> +		tg3_flag_set(tp, TX_TSTAMP_EN);
> +	else
> +		tg3_flag_clear(tp, TX_TSTAMP_EN);
> +
>   	return copy_to_user(ifr->ifr_data, &stmpconf, sizeof(stmpconf)) ?
>   		-EFAULT : 0;
>   }
>
>

Thanks Ben.

Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>
