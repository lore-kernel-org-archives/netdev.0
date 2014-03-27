From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC v2 4/6] net: introduce switchdev API
Date: Thu, 27 Mar 2014 11:23:39 +0000
Message-ID: <20140327112339.GB1615@casper.infradead.org>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-5-git-send-email-jiri@resnulli.us>
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
	linville@tuxdriver.com, dev@openvswitch.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44773 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594AbaC0LXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 07:23:42 -0400
Content-Disposition: inline
In-Reply-To: <1395851472-10524-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 at 05:31pm, Jiri Pirko wrote:
> switchdev API is designed to allow kernel support for various switch
> chips.
> 
> It is the responsibility of a driver to create netdevice instances which
> represents every port and for the switch master itself. Driver uses
> swdev_register and swportdev_register functions to make the core aware
> of the fact these netdevices are representing switch and switch ports.

I like this even more than the previous approach.

> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

> +int __swdev_register(struct net_device *dev)
> +{
> +	if (dev->priv_flags & IFF_SWITCH) {
> +		netdev_err(dev, "Device is already registered as a switch device\n");
> +		return -EBUSY;
> +	}
> +	dev->priv_flags |= IFF_SWITCH;
> +	netdev_info(dev, "Switch device registered\n");

Perhaps include name of device here?

> +	return 0;
> +}
> +EXPORT_SYMBOL(__swdev_register);
> +
> +int swdev_register(struct net_device *dev)
> +{
> +	int err;
> +
> +	rtnl_lock();
> +	err = __swdev_register(dev);
> +	rtnl_unlock();
> +	return err;
> +}
> +EXPORT_SYMBOL(swdev_register);
> +
> +void __swdev_unregister(struct net_device *dev)
> +{
> +	dev->priv_flags |= IFF_SWITCH;
> +	netdev_info(dev, "Switch device unregistered\n");

Same here

> +}
> +EXPORT_SYMBOL(__swdev_unregister);
> +
> +void swdev_unregister(struct net_device *dev)
> +{
> +	rtnl_lock();
> +	__swdev_unregister(dev);
> +	rtnl_unlock();
> +}
> +EXPORT_SYMBOL(swdev_unregister);
> +
> +
> +bool swportdev_dev_check(const struct net_device *port_dev)
> +{
> +	return port_dev->priv_flags & IFF_SWITCH_PORT;
> +}
> +EXPORT_SYMBOL(swportdev_dev_check);
> +
> +static rx_handler_result_t swportdev_handle_frame(struct sk_buff **pskb)
> +{
> +	struct sk_buff *skb = *pskb;
> +
> +	/* We don't care what comes from port device into rx path.
> +	 * If there's something there, it is destined to ETH_P_ALL
> +	 * handlers. So just consume it.
> +	 */
> +	dev_kfree_skb(skb);
> +	return RX_HANDLER_CONSUMED;
> +}
> +
> +int __swportdev_register(struct net_device *port_dev, struct net_device *dev)
> +{
> +	int err;
> +
> +	if (!(dev->priv_flags & IFF_SWITCH)) {
> +		netdev_err(dev, "Device is not a switch device\n");
> +		return -EINVAL;
> +	}
> +	if (port_dev->priv_flags & IFF_SWITCH_PORT) {
> +		netdev_err(port_dev, "Device is already registered as a switch port\n");
> +		return -EBUSY;
> +	}
> +	err = netdev_master_upper_dev_link(port_dev, dev);
> +	if (err) {
> +		netdev_err(dev, "Device %s failed to set upper link\n",
> +			   port_dev->name);
> +		return err;
> +	}
> +	err = netdev_rx_handler_register(port_dev, swportdev_handle_frame, NULL);
> +	if (err) {
> +		netdev_err(dev, "Device %s failed to register rx_handler\n",
> +			   port_dev->name);
> +		goto err_handler_register;
> +	}
> +	port_dev->priv_flags |= IFF_SWITCH_PORT;
> +	netdev_info(port_dev, "Switch port device registered\n");

and here

> +	return 0;
> +
> +err_handler_register:
> +	netdev_upper_dev_unlink(port_dev, dev);
> +	return err;
> +}
> +EXPORT_SYMBOL(__swportdev_register);
> +
> +int swportdev_register(struct net_device *port_dev, struct net_device *dev)

Maybe rename dev to switch_dev just to make it clear?

> +{
> +	int err;
> +
> +	rtnl_lock();
> +	err = __swportdev_register(port_dev, dev);
> +	rtnl_unlock();
> +	return err;
> +}
> +EXPORT_SYMBOL(swportdev_register);
> +
> +void __swportdev_unregister(struct net_device *port_dev)
> +{
> +	struct net_device *dev;
> +
> +	dev = netdev_master_upper_dev_get(port_dev);
> +	BUG_ON(!dev);
> +	port_dev->priv_flags &= ~IFF_SWITCH_PORT;
> +	netdev_rx_handler_unregister(port_dev);
> +	netdev_upper_dev_unlink(port_dev, dev);
> +	netdev_info(port_dev, "Switch port device unregistered\n");
> +}
> +EXPORT_SYMBOL(__swportdev_unregister);
> +
> +void swportdev_unregister(struct net_device *port_dev)
> +{
> +	rtnl_lock();
> +	__swportdev_unregister(port_dev);
> +	rtnl_unlock();
> +}
> +EXPORT_SYMBOL(swportdev_unregister);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
> +MODULE_DESCRIPTION("Switch device API");
> -- 
> 1.8.5.3
> 
