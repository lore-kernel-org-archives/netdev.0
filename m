From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] NAPI as kobject proposal
Date: Wed, 03 Feb 2010 21:23:36 +0000
Message-ID: <1265232216.2116.46.camel@achroite.uk.solarflarecom.com>
References: <20100129101839.36944ba5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33548 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755952Ab0BCVXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 16:23:39 -0500
In-Reply-To: <20100129101839.36944ba5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-29 at 10:18 -0800, Stephen Hemminger wrote:
> The NAPI interface structure in current kernels is managed by the driver.
> As part of receive packet steering there is a requirement to add an
> additional parameter to this for the CPU map. And this map needs to
> have an API to set it.
> 
> The right way to do this in the kernel model is to make NAPI into
> a kobject and associate it back with the network device (parent).
> This isn't wildly difficult but does change some of the API for
> network device drivers because:
>   1. They need to handle another possible error on setup
>   2. NAPI object needs to be dynamically allocated
>      separately (not as part of netdev_priv)
>   3. Driver should pass index that can be uses as part of
>      name (easier than scanning)
> 
> Eventually, there will be:
>   /sys/class/net/eth0/napi0/
>                             weight
>                             cpumap

I think the NAPI objects should be created as children of a bus device
and then linked from the net device directories, e.g.

/sys/devices/.../ net/eth0/
                           napi0 -> ../../napi/napi0
                      eth1/
                           napi0 -> ../../napi/napi0
                  napi/napi0/
                             weight
                             cpumap

I also think it might be helpful to use a more descriptive name here
than 'napi', e.g. 'channel'.  But maybe that can be left to management
tools.

> So here is a starting point patch that shows how the API might look like.
> 
> 
> ---
>  include/linux/netdevice.h |   20 ++++++++++++++------
>  net/core/dev.c            |   28 ++++++++++++++++++++++++++--
>  2 files changed, 40 insertions(+), 8 deletions(-)
> 
> --- a/include/linux/netdevice.h	2010-01-29 10:00:55.820739116 -0800
> +++ b/include/linux/netdevice.h	2010-01-29 10:15:33.098863437 -0800
> @@ -378,6 +378,8 @@ struct napi_struct {
>  	struct list_head	dev_list;
>  	struct sk_buff		*gro_list;
>  	struct sk_buff		*skb;
> +
> +	struct kobject		kobj;
>  };
>  
>  enum {
> @@ -1037,25 +1039,31 @@ static inline void *netdev_priv(const st
>  #define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
>  
>  /**
> - *	netif_napi_add - initialize a napi context
> + *	netif_napi_init - initialize a napi context
>   *	@dev:  network device
>   *	@napi: napi context
> + *	@index: queue number
>   *	@poll: polling function
>   *	@weight: default weight
>   *
> - * netif_napi_add() must be used to initialize a napi context prior to calling
> + * netif_napi_init() must be used to create a napi context prior to calling
>   * *any* of the other napi related functions.
> + *
> + * in case of error, the context is not left in napi_list so it can
> + * be cleaned up by free_netdev, but is not valid for use.
>   */
> -void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
> -		    int (*poll)(struct napi_struct *, int), int weight);
> +extern int netif_napi_init(struct net_device *dev, struct napi_struct *napi,
> +			   unsigned index,
> +			   int (*poll)(struct napi_struct *, int), int weight);
[...
> --- a/net/core/dev.c	2010-01-29 10:00:55.810739850 -0800
> +++ b/net/core/dev.c	2010-01-29 10:14:53.388864572 -0800
> @@ -2926,9 +2926,24 @@ void napi_complete(struct napi_struct *n
>  }
>  EXPORT_SYMBOL(napi_complete);
>  
> -void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
> +static void release_napi(struct kobject *kobj)
> +{
> +	struct napi_struct *napi
> +		= container_of(kobj, struct napi_struct, kobj);
> +	kfree(napi);
> +}
[...]

This means the napi_struct can no longer be embedded in a larger struct.
So I think netif_napi_init() should actually allocate the napi_struct
and be named netif_napi_create().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

