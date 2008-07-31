From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 11:40:05 +0100
Message-ID: <20080731104004.GN10471@solarflare.com>
References: <20080731092703.661994657@free-electrons.com> <20080731093221.236840420@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, Matt Mackall <mpm@selenic.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:40669 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751997AbYGaKkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:40:24 -0400
Content-Disposition: inline
In-Reply-To: <20080731093221.236840420@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Petazzoni wrote:
[...]
> --- linuxdev.orig/include/linux/ethtool.h
> +++ linuxdev/include/linux/ethtool.h
> @@ -283,6 +283,7 @@
>  struct net_device;
>  
>  /* Some generic methods drivers may use in their ethtool_ops */
> +#ifdef CONFIG_ETHTOOL
>  u32 ethtool_op_get_link(struct net_device *dev);
>  u32 ethtool_op_get_tx_csum(struct net_device *dev);
>  int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
> @@ -296,6 +297,21 @@
>  int ethtool_op_set_ufo(struct net_device *dev, u32 data);
>  u32 ethtool_op_get_flags(struct net_device *dev);
>  int ethtool_op_set_flags(struct net_device *dev, u32 data);
> +#else
> +static inline u32 ethtool_op_get_link(struct net_device *dev) { return 0; }
> +static inline u32 ethtool_op_get_tx_csum(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_tx_csum(struct net_device *dev, u32 data) { return 0; }
> +static inline int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data) { return 0; }
> +static inline int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_sg(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_sg(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_tso(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_tso(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_ufo(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_ufo(struct net_device *dev, u32 data) { return 0; }
> +static inline u32 ethtool_op_get_flags(struct net_device *dev) { return 0; }
> +static inline int ethtool_op_set_flags(struct net_device *dev, u32 data) { return 0; }

The dummy setter functions should return -EOPNOTSUPP.  The getter functions
just read device feature flags and could be made inline.  They have no way
of returning failure.

[...]
> ===================================================================
> --- linuxdev.orig/net/core/dev.c
> +++ linuxdev/net/core/dev.c
> @@ -3669,6 +3669,7 @@
>  			return ret;
>  
>  		case SIOCETHTOOL:
> +#ifdef CONFIG_ETHTOOL
>  			dev_load(net, ifr.ifr_name);
>  			rtnl_lock();
>  			ret = dev_ethtool(net, &ifr);
> @@ -3681,6 +3682,9 @@
>  					ret = -EFAULT;
>  			}
>  			return ret;
> +#else
> +			return -EINVAL;
> +#endif
>  
>  		/*
>  		 *	These ioctl calls:

You also need to conditionalise dev_disable_lro().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
