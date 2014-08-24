From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic switch devices
 support
Date: Sun, 24 Aug 2014 12:46:05 +0100
Message-ID: <20140824114605.GC32741@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37552 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbaHXLqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 07:46:10 -0400
Content-Disposition: inline
In-Reply-To: <1408637945-10390-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/14 at 06:18pm, Jiri Pirko wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 39294b9..8b5d14c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -49,6 +49,8 @@
>  
>  #include <linux/netdev_features.h>
>  #include <linux/neighbour.h>
> +#include <linux/sw_flow.h>
> +
>  #include <uapi/linux/netdevice.h>
>  
>  struct netpoll_info;
> @@ -997,6 +999,24 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
> + * int (*ndo_swdev_flow_insert)(struct net_device *dev,
> + *				const struct sw_flow *flow);
> + *	Called to insert a flow into switch device. If driver does
> + *	not implement this, it is assumed that the hw does not have
> + *	a capability to work with flows.

I asume you are planning to add an additional expandable struct
paramter to handle insertion parameters when the first is introduced
to avoid requiring to touch every driver every time.

> +/**
> + *	swdev_flow_insert - Insert a flow into switch
> + *	@dev: port device
> + *	@flow: flow descriptor
> + *
> + *	Insert a flow into switch this port is part of.
> + */
> +int swdev_flow_insert(struct net_device *dev, const struct sw_flow *flow)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	print_flow(flow, dev, "insert");
> +	if (!ops->ndo_swdev_flow_insert)
> +		return -EOPNOTSUPP;
> +	WARN_ON(!ops->ndo_swdev_get_id);
> +	BUG_ON(!flow->actions);
> +	return ops->ndo_swdev_flow_insert(dev, flow);
> +}
> +EXPORT_SYMBOL(swdev_flow_insert);

Splitting the flow specific API into a separate file (maybe
swdev_flow.c?) might help resolve some of the concerns around the
focus on flows. It would make it clear that it's one of multiple
models to be supported.
