From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: Re: [PATCH net-next 07/16] tg3: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 16:14:56 -0800
Message-ID: <52A11700.6090600@broadcom.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com> <1386287352.1516.132.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Michael Chan <mchan@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:57122 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab3LFAYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 19:24:43 -0500
In-Reply-To: <1386287352.1516.132.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/05/2013 03:49 PM, Ben Hutchings wrote:
> While we're doing this, fix the error code for SIOCSHWTSTAMP ioctl on
> non-timestamping hardware.
>
> Compile-tested only.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>   drivers/net/ethernet/broadcom/tg3.c | 71 ++++++++++++++++++++++++++++++++++---
>   1 file changed, 67 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index a9e068423ba0..539c6ace1706 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -13603,14 +13603,13 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
>
>   }
>
> -static int tg3_hwtstamp_ioctl(struct net_device *dev,
> -			      struct ifreq *ifr, int cmd)
> +static int tg3_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
>   {
>   	struct tg3 *tp = netdev_priv(dev);
>   	struct hwtstamp_config stmpconf;
>
>   	if (!tg3_flag(tp, PTP_CAPABLE))
> -		return -EINVAL;
> +		return -EOPNOTSUPP;
>
>   	if (copy_from_user(&stmpconf, ifr->ifr_data, sizeof(stmpconf)))
>   		return -EFAULT;
> @@ -13691,6 +13690,67 @@ static int tg3_hwtstamp_ioctl(struct net_device *dev,
>   		-EFAULT : 0;
>   }
>
> +static int tg3_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +	struct hwtstamp_config stmpconf;
> +
> +	if (!tg3_flag(tp, PTP_CAPABLE))
> +		return -EOPNOTSUPP;
> +
> +	stmpconf.flags = 0;
> +	stmpconf.tx_type = (tg3_flag(tp, TX_TSTAMP_EN) ?
> +			    HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF);
> +
> +	switch (tp->rxptpctl) {
> +	case 0:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_NONE;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V1_EN | TG3_RX_PTP_CTL_ALL_V1_EVENTS:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V1_EN | TG3_RX_PTP_CTL_SYNC_EVNT:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_SYNC;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V1_EN | TG3_RX_PTP_CTL_DELAY_REQ:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_EN | TG3_RX_PTP_CTL_ALL_V2_EVENTS:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN | TG3_RX_PTP_CTL_ALL_V2_EVENTS:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN | TG3_RX_PTP_CTL_ALL_V2_EVENTS:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_EN | TG3_RX_PTP_CTL_SYNC_EVNT:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_SYNC;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN | TG3_RX_PTP_CTL_SYNC_EVNT:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_SYNC;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN | TG3_RX_PTP_CTL_SYNC_EVNT:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_SYNC;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_EN | TG3_RX_PTP_CTL_DELAY_REQ:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_DELAY_REQ;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN | TG3_RX_PTP_CTL_DELAY_REQ:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ;
> +		break;
> +	case TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN | TG3_RX_PTP_CTL_DELAY_REQ:
> +		stmpconf.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ;
> +		break;
> +	default:
> +		WARN_ON_ONCE(1);
> +		return -ERANGE;
> +	}
> +
> +	return copy_to_user(ifr->ifr_data, &stmpconf, sizeof(stmpconf)) ?
> +		-EFAULT : 0;
> +}
> +
>   static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>   {
>   	struct mii_ioctl_data *data = if_mii(ifr);
> @@ -13744,7 +13804,10 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>   		return err;
>
>   	case SIOCSHWTSTAMP:
> -		return tg3_hwtstamp_ioctl(dev, ifr, cmd);
> +		return tg3_hwtstamp_set(dev, ifr);
> +
> +	case SIOCGHWTSTAMP:
> +		return tg3_hwtstamp_get(dev, ifr);
>
>   	default:
>   		/* do nothing */
>
>

Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>
