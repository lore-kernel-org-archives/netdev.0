From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC 1/2] net:  Support getting/setting RX-FCS in drivers.
Date: Fri, 17 Jun 2011 13:20:12 +0100
Message-ID: <1308313212.11457.62.camel@localhost>
References: <1308285007-11302-1-git-send-email-greearb@candelatech.com>
	 <1308285007-11302-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18948 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567Ab1FQMUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 08:20:15 -0400
In-Reply-To: <1308285007-11302-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-16 at 21:30 -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> This will allow us to enable/disable having the Ethernet
> frame checksum appended to the skb.  Enabling this is
> useful when sniffing packets.
> 
> In particular, this can be used to test logic that allows
> a NIC to receive all frames, even ones with bad checksums.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 439b173... e5e8747... M	include/linux/ethtool.h
> :100644 100644 fd14116... b36bac7... M	net/core/ethtool.c
>  include/linux/ethtool.h |    5 +++++
>  net/core/ethtool.c      |   38 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 43 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 439b173..e5e8747 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -955,6 +955,8 @@ struct ethtool_ops {
>  	int	(*get_dump_data)(struct net_device *,
>  				 struct ethtool_dump *, void *);
>  	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
> +	int	(*set_save_fcs)(struct net_device *, u32);
> +	int	(*get_save_fcs)(struct net_device *, u32 *);

These need to be described in the kernel-doc.

Why do these function names use 'save_fcs' whereas the command names use
'RXFCS'?

>  };
>  #endif /* __KERNEL__ */
> @@ -1029,6 +1031,9 @@ struct ethtool_ops {
>  #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
>  #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
>  #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
> +#define ETHTOOL_GETRXFCS	0x00000041 /* Get RX Save Frame Checksum */
> +#define ETHTOOL_SETRXFCS	0x00000042 /* Set RX Save Frame Checksum */
> +
>  
>  /* compatibility with older code */
>  #define SPARC_ETH_GSET		ETHTOOL_GSET
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index fd14116..b36bac7 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1927,6 +1927,38 @@ out:
>  	return ret;
>  }
>  
> +static int ethtool_get_rx_fcs(struct net_device *dev, void __user *useraddr)
> +{
> +	struct ethtool_value edata;
> +	int rv = 0;
> +
> +	if (!dev->ethtool_ops->get_save_fcs)
> +		return -EOPNOTSUPP;
> +
> +	rv = dev->ethtool_ops->get_save_fcs(dev, &edata.data);
> +	if (rv < 0)
> +		return rv;
> +
> +	if (copy_to_user(useraddr, &edata, sizeof(edata)))
> +		return -EFAULT;
> +	return 0;
> +}
> +
> +
> +static int ethtool_set_rx_fcs(struct net_device *dev, void __user *useraddr)
> +{
> +	struct ethtool_value id;
> +
> +	if (!dev->ethtool_ops->set_save_fcs)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&id, useraddr, sizeof(id)))
> +		return -EFAULT;
> +
> +	return dev->ethtool_ops->set_save_fcs(dev, id.data);
> +}
> +
> +
>  /* The main entry point in this file.  Called from net/core/dev.c */
>  
>  int dev_ethtool(struct net *net, struct ifreq *ifr)
> @@ -2152,6 +2184,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>  	case ETHTOOL_GET_DUMP_DATA:
>  		rc = ethtool_get_dump_data(dev, useraddr);
>  		break;
> +	case ETHTOOL_SETRXFCS:
> +		rc = ethtool_set_rx_fcs(dev, useraddr);
> +		break;
> +	case ETHTOOL_GETRXFCS:
> +		rc = ethtool_get_rx_fcs(dev, useraddr);
> +		break;

You can use ethtool_{get,set}_value() rather than adding new trivial
functions.

And as Michal says, this could reasonably be a feature not an entirely
separate flag.  I'm not sure it's that important to have debugging flags
in features, but I also don't want to have 2 commands per flag...

Ben.

>  	default:
>  		rc = -EOPNOTSUPP;
>  	}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

