From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Sat, 16 Jan 2010 02:26:31 +0000
Message-ID: <1263608791.17815.128.camel@localhost>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42190 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758299Ab0APC0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 21:26:36 -0500
In-Reply-To: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-14 at 13:56 -0800, Tom Herbert wrote:
[...]
> The CPU masks is set on a per device basis in the sysfs variable
> /sys/class/net/<device>/rps_cpus.  This is a set of canonical bit maps for
> each NAPI nstance of the device.  For example:
> 
> echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus
> 
> would set maps for four NAPI instances on eth0.
[...]
> Caveats:
> - The benefits of this patch are dependent on architecture and cache hierarchy.
> Tuning the masks to get best performance is probably necessary.

It seems to me that it would be helpful to provide some kind of sensible
default behaviour.  I'm sure Google has the in-house expertise to do
this at a higher-level, but most end users rely on good defaults rather
than tuning.

[...]
> +/*
> + * Structure that contains the rps maps for various NAPI instances of a device.
> + */
> +struct dev_rps_maps {
> +	int num_maps;
> +	struct rcu_head rcu;
> +	struct rps_map maps[0];

This declaration is a botch. A VLA of structures containing VLAs has an
index operation, but it's broken.  It would be better to remove the maps
member and define an inline function for indexing the following array of
maps, instead of writing the magic formula way over...

[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
> +{
[...]
> +	map = (struct rps_map *)
> +	    ((void *)drmap->maps + (rps_map_size * index));
[...]

...here.

[...]
> @@ -2363,10 +2487,10 @@ void netif_nit_deliver(struct sk_buff *skb)
>   }
> 
>   /**
> - *	netif_receive_skb - process receive buffer from network
> + *	__netif_receive_skb - process receive buffer from network
>    *	@skb: buffer to process
>    *
> - *	netif_receive_skb() is the main receive data processing function.
> + *	__netif_receive_skb() is the main receive data processing function.
>    *	It always succeeds. The buffer may be dropped during processing
>    *	for congestion control or by the protocol layers.
>    *

Surely this kernel-doc should be moved rather than modified, since you
want most callers to continue using netif_receive_skb()?

[...]
> @@ -2475,6 +2599,16 @@ out:
>   }
>   EXPORT_SYMBOL(netif_receive_skb);

This should be moved underneath the new implementation...

> +int netif_receive_skb(struct sk_buff *skb)
> +{
> +	int cpu = get_rps_cpu(skb->dev, skb);
> +
> +	if (cpu < 0)
> +		return __netif_receive_skb(skb);
> +	else
> +		return enqueue_to_backlog(skb, cpu);
> +}
[...]

...here.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

