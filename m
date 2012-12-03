From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/4 net-next] tg3: PTP - Add the hardware timestamp
 ioctl
Date: Mon, 3 Dec 2012 20:41:51 +0100
Message-ID: <20121203194151.GA5324@netboy.at.omicron.at>
References: <1354506171-1646-1-git-send-email-mchan@broadcom.com>
 <1354506171-1646-2-git-send-email-mchan@broadcom.com>
 <1354506171-1646-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nsujir@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46432 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab2LCTmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 14:42:04 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1810415eek.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 11:42:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1354506171-1646-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2012 at 07:42:50PM -0800, Michael Chan wrote:
> From: Matt Carlson <mcarlson@broadcom.com>
> 
> This patch implements the SIOCSHWTSTAMP ioctl as described in
> Documentation/networking/timestamping.txt
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |   99 +++++++++++++++++++++++++++++++++++
>  1 files changed, 99 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index a54d194..f6e956c 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -12755,6 +12755,102 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
>  
>  }
>  
> +static int tg3_hwtstamp_ioctl(struct net_device *dev,
> +			      struct ifreq *ifr, int cmd)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +	struct hwtstamp_config stmpconf;
> +
> +	if (!tg3_flag(tp, PTP_CAPABLE))
> +		return -EINVAL;
> +
> +	if (copy_from_user(&stmpconf, ifr->ifr_data, sizeof(stmpconf)))
> +		return -EFAULT;
> +
> +	if (stmpconf.flags)
> +		return -EINVAL;
> +
> +	switch (stmpconf.tx_type) {
> +	case HWTSTAMP_TX_ON:
> +		tg3_flag_set(tp, TX_TSTAMP_EN);
> +		break;
> +	case HWTSTAMP_TX_OFF:
> +		tg3_flag_clear(tp, TX_TSTAMP_EN);
> +		break;
> +	default:
> +		return -ERANGE;
> +	}
> +
> +	switch (stmpconf.rx_filter) {
> +	case HWTSTAMP_FILTER_NONE:
> +		tp->rxptpctl = 0;
> +		break;
> +	case HWTSTAMP_FILTER_ALL:

This filter code means that all packets are stamped, not just all PTP
packets. I guess that you should return ERANGE here.

Thanks,
Richard
