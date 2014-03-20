From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 2/4] net: introduce switchdev API
Date: Thu, 20 Mar 2014 13:59:01 +0000
Message-ID: <20140320135901.GG16640@casper.infradead.org>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <1395243232-32630-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45704 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbaCTN7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 09:59:04 -0400
Content-Disposition: inline
In-Reply-To: <1395243232-32630-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/14 at 04:33pm, Jiri Pirko wrote:
> +struct swdev_linked_ops {
> +};

I've been trying to think of better names for this to make
it absolutely clear which is which (linked ops vs. ops).

What do you think about the following?

    sw_api       -> sw_api_ops / sw_api_port_ops 
       | 
   sw_device
       |
   sw_driver     -> sw_driver_ops / sw_driver_port_ops

> +bool swdev_dev_check(const struct net_device *dev);
> +void swdev_link(struct net_device *dev,
> +		const struct swdev_linked_ops *linked_ops,
> +		void *linked_priv);
> +void swdev_unlink(struct net_device *dev);
> +void *swdev_linked_priv(const struct net_device *dev);
> +bool swdev_is_linked(const struct net_device *dev);
> +int swdev_flow_insert(struct net_device *dev, struct sw_flow *flow);
> +int swdev_flow_remove(struct net_device *dev, struct sw_flow *flow);
> +int swdev_packet_upcall(struct net_device *dev, struct sk_buff *skb);
> +
> +struct swdev_ops {
> +	const char *kind;
> +	int (*flow_insert)(struct net_device *dev, struct sw_flow *flow);
> +	int (*flow_remove)(struct net_device *dev, struct sw_flow *flow);

I think this API should be made more extendable. Flags might be
needed at some point or even switch specific configuration
blobs. How about adding a struct sw_flow_opts early on to avoid
cluttering the function parameter list later on?

> +int swdev_flow_insert(struct net_device *dev, struct sw_flow *flow)
> +{
> +	struct swdev *sw = netdev_priv(dev);
> +
> +	BUG_ON(!swdev_dev_check(dev));

How about taking the swdev struct instead to make it clear that
all these swdev_ functions are only supposed to be used with
swdev instances? We can translate the swdev pointer to a net_device.

> +bool swportdev_dev_check(const struct net_device *port_dev)
> +{
> +	return port_dev->netdev_ops == &swportdev_netdev_ops;
> +}
> +EXPORT_SYMBOL(swportdev_dev_check);

Same as above

> +struct net_device *swportdev_create(struct net_device *dev,
> +				    const struct swportdev_ops *ops)
> +{
> +	struct net_device *port_dev;
> +	char name[IFNAMSIZ];
> +	struct swportdev *swp;
> +	int err;


Needs a check that dev is of the same family as the provided
port ops.

> +	err = snprintf(name, IFNAMSIZ, "%sp%%d", dev->name);
> +	if (err >= IFNAMSIZ)
> +		return ERR_PTR(-EINVAL);
> +
> +	port_dev = alloc_netdev(sizeof(struct swportdev), name, swportdev_setup);
> +	if (!port_dev)
> +		return ERR_PTR(-ENOMEM);
> +
> +	err = register_netdevice(port_dev);
> +	if (err)
> +		goto err_register_netdevice;
> +
> +	err = netdev_master_upper_dev_link(port_dev, dev);
> +	if (err) {
> +		netdev_err(dev, "Device %s failed to set upper link\n",
> +			   port_dev->name);
> +		goto err_set_upper_link;
> +	}
> +	swp = netdev_priv(port_dev);
> +	err = netdev_rx_handler_register(port_dev, swportdev_handle_frame, swp);
> +	if (err) {
> +		netdev_err(dev, "Device %s failed to register rx_handler\n",
> +			   port_dev->name);
> +		goto err_handler_register;
> +	}
> +
> +	swp = netdev_priv(port_dev);
> +	swp->ops = ops;
> +	netif_carrier_off(port_dev);
> +	netdev_info(port_dev, "Switch port device created (%s)\n", swp->ops->kind);
> +	return port_dev;
> +
> +err_handler_register:
> +	netdev_upper_dev_unlink(port_dev, dev);
> +err_set_upper_link:
> +	unregister_netdevice(port_dev);
> +err_register_netdevice:
> +	free_netdev(port_dev);
> +	return ERR_PTR(err);
> +}
> +EXPORT_SYMBOL(swportdev_create);
