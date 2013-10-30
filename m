From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH 3/3] e1000e: PTP: provide hardware features
Date: Wed, 30 Oct 2013 19:50:34 -0200
Message-ID: <20131030215034.GA13373@plex.lan>
References: <1383159637-8165-1-git-send-email-fbl@redhat.com>
 <1383159637-8165-4-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linuxptp-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239Ab3J3WjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 18:39:11 -0400
Content-Disposition: inline
In-Reply-To: <1383159637-8165-4-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding CC to netdev.

The first patch [1/3] is the userlevel linuxptp patch, so
I am not forwarding to netdev.

This is just an example which I used for testing locally. If
the idea is acceptable, this patch must be replaced since the
card does support more features than what is listed below.

fbl

On Wed, Oct 30, 2013 at 05:00:37PM -0200, Flavio Leitner wrote:
> Provide the modes and transports supported by the hardware.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 4ef7867..8bcf167 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -3498,10 +3498,6 @@ static int e1000e_config_hwtstamp(struct e1000_adapter *adapter)
>  	if (!(adapter->flags & FLAG_HAS_HW_TIMESTAMP))
>  		return -EINVAL;
>  
> -	/* flags reserved for future extensions - must be zero */
> -	if (config->flags)
> -		return -EINVAL;
> -
>  	switch (config->tx_type) {
>  	case HWTSTAMP_TX_OFF:
>  		tsync_tx_ctl = 0;
> @@ -5772,6 +5768,9 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
>  	return 0;
>  }
>  
> +#define E1000E_HWSTAMP_FLAGS_MASK (HWTSTAMP_DM_E2E | HWTSTAMP_DM_P2P |\
> +				   HWTSTAMP_TRANS_IEEE_802_3 |\
> +				   HWTSTAMP_TRANS_UDP_IPV4)
>  /**
>   * e1000e_hwtstamp_ioctl - control hardware time stamping
>   * @netdev: network interface device structure
> @@ -5792,11 +5791,23 @@ static int e1000e_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
>  {
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  	struct hwtstamp_config config;
> +	int flags_req;
> +	int flags_unsup;
>  	int ret_val;
>  
>  	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
>  		return -EFAULT;
>  
> +	if (config.flags & ~HWTSTAMP_FEATURE_FLAGS_MASK)
> +		return -EINVAL;
> +
> +	flags_req = config.flags & HWTSTAMP_FEATURE_FLAGS_MASK;
> +	flags_unsup = flags_req & ~E1000E_HWSTAMP_FLAGS_MASK;
> +	if (flags_unsup) {
> +		config.flags &= ~flags_unsup;
> +		goto out;
> +	}
> +
>  	adapter->hwtstamp_config = config;
>  
>  	ret_val = e1000e_config_hwtstamp(adapter);
> @@ -5823,6 +5834,7 @@ static int e1000e_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
>  		break;
>  	}
>  
> +out:
>  	return copy_to_user(ifr->ifr_data, &config,
>  			    sizeof(config)) ? -EFAULT : 0;
>  }
> -- 
> 1.8.3.1
> 
