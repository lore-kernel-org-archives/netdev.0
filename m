From: Flavio Leitner <fbl@redhat.com>
Subject: Re: RFC [PATCH 2/3] PTP: use flags to request HW features
Date: Wed, 30 Oct 2013 19:48:41 -0200
Message-ID: <20131030214841.GZ13373@plex.lan>
References: <1383159637-8165-1-git-send-email-fbl@redhat.com>
 <1383159637-8165-3-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linuxptp-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754191Ab3J3Vse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 17:48:34 -0400
Content-Disposition: inline
In-Reply-To: <1383159637-8165-3-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding CC to netdev.

On Wed, Oct 30, 2013 at 05:00:36PM -0200, Flavio Leitner wrote:
> Currently the user space can't tell which delay mechanism
> (E2E/P2P) or transport is needed in the ioctl(). Therefore,
> PTP silently fails when the hardware doesn't support a
> certain delay mechanism or transport.
> 
> This patch uses the ioctl flags field to pass that information
> from the user space to kernel. If the hardware supports all
> the desired features, the ioctl continues as before, otherwise
> the unsupported bits are reseted to 0 and this information is
> returned to user space.
> 
> It's backwards compatible. If an older PTP applications calls
> the ioctl(), the flags field will be zero and no feature is
> checked.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  include/uapi/linux/net_tstamp.h | 21 +++++++++++++++++++++
>  net/core/dev_ioctl.c            |  3 ---
>  2 files changed, 21 insertions(+), 3 deletions(-)
> 
> diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
> index ae5df12..d63f8e9 100644
> --- a/include/uapi/linux/net_tstamp.h
> +++ b/include/uapi/linux/net_tstamp.h
> @@ -44,6 +44,27 @@ struct hwtstamp_config {
>  	int rx_filter;
>  };
>  
> +/* possible values for hwtstamp_config->flags */
> +#define HWTSTAMP_FEATURE_FLAGS_MASK 0xFFFF
> +enum hwtstamp_feature_flags {
> +	/* End-to-End Delay Mechanism */
> +	HWTSTAMP_DM_E2E = (1<<0),
> +	/* Peer-to-Peer Delay Mechanism */
> +	HWTSTAMP_DM_P2P = (1<<1),
> +	/* hole: 3 bits for additional mechanisms */
> +
> +	HWTSTAMP_TRANS_UDS = (1<<5),
> +	/* Message Transport: UDP over IPv4 */
> +	HWTSTAMP_TRANS_UDP_IPV4 = (1<<6),
> +	/* Message Transport: UDP over IPv6 */
> +	HWTSTAMP_TRANS_UDP_IPV6 = (1<<7),
> +	/* Message Transport: IEEE 802.3 Ethernet */
> +	HWTSTAMP_TRANS_IEEE_802_3 = (1<<8),
> +	HWTSTAMP_TRANS_DEVICENET = (1<<9),
> +	HWTSTAMP_TRANS_CONTROLNET = (1<<10),
> +	HWTSTAMP_TRANS_PROFINET = (1<<11),
> +};
> +
>  /* possible values for hwtstamp_config->tx_type */
>  enum hwtstamp_tx_types {
>  	/*
> diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
> index 5b7d0e1..9e2407e 100644
> --- a/net/core/dev_ioctl.c
> +++ b/net/core/dev_ioctl.c
> @@ -193,9 +193,6 @@ static int net_hwtstamp_validate(struct ifreq *ifr)
>  	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
>  		return -EFAULT;
>  
> -	if (cfg.flags) /* reserved for future extensions */
> -		return -EINVAL;
> -
>  	tx_type = cfg.tx_type;
>  	rx_filter = cfg.rx_filter;
>  
> -- 
> 1.8.3.1
> 
