From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Mon, 26 Jun 2017 15:28:12 +0200
Message-ID: <20170626132812.GA2623@lunn.ch>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35100 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdFZN2S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 09:28:18 -0400
Content-Disposition: inline
In-Reply-To: <1498050286-17141-2-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 04:04:44PM +0300, Gal Pressman wrote:
> Currently, drivers can only tell whether the link is up/down through
> ETHTOOL_GLINK callback, but no additional information is given in case
> of link down.
> This patch provides an infrastructure that allows drivers to hint
> the user with the reason why the link is down, in order to ease the
> debug process.
> 
> Reasons are separated to two types, generic and vendor specific.
> Drivers can reply with a generic reason using the enums provided in this
> patch (and the ones that will be added in the future), which will be
> translated to strings by the userspace ethtool.
> In case of a vendor specific reason (not suitable for most vendors),
> drivers can reply with ETHTOOL_VENDOR_SPECIFIC reason, in this case the
> vendor_reason field should be filled with a vendor specific status code
> which will be parsed by the vendor specific userspace parser if one is
> available.
> 
> This kind of information can save system administrators precious time
> which will not be wasted trying to understand why the link won't go
> up.
> 
> For example, when the cable is unplugged:
> $ ethtool ethXX
> ...
> Link detected: no (Cable unplugged)
> 
> Signed-off-by: Gal Pressman <galp@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  include/linux/ethtool.h      |  2 ++
>  include/uapi/linux/ethtool.h | 33 +++++++++++++++++++++++++++++++++
>  net/core/ethtool.c           | 24 ++++++++++++++++++++++++
>  3 files changed, 59 insertions(+)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 83cc986..d472047 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -374,5 +374,7 @@ struct ethtool_ops {
>  				      struct ethtool_link_ksettings *);
>  	int	(*set_link_ksettings)(struct net_device *,
>  				      const struct ethtool_link_ksettings *);
> +	int	(*get_link_down_reason)(struct net_device *,
> +					struct ethtool_link_down_reason *);
>  };
>  #endif /* _LINUX_ETHTOOL_H */
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 7d4a594..8cf9d2c 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -550,6 +550,13 @@ struct ethtool_pauseparam {
>  
>  #define ETH_GSTRING_LEN		32
>  
> +struct ethtool_link_down_reason {
> +	__u32	cmd;
> +	__u32	reason;
> +	__u32	vendor_reason;
> +	__u32	reserved[4];
> +};

Shouldn't this be a list? The device is over its power budget,
overheating and does not have a cable plugged in. There can be
multiple reasons it is down.

	 Andrew
