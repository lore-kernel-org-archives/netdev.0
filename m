From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC v2 4/6] net: introduce switchdev
	API
Date: Thu, 27 Mar 2014 12:26:26 +0100
Message-ID: <20140327112626.GK2845@minipsycho.orion>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-5-git-send-email-jiri@resnulli.us>
 <20140327112339.GB1615@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140327112339.GB1615-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Thu, Mar 27, 2014 at 12:23:39PM CET, tgraf-G/eBtMaohhA@public.gmane.org wrote:
>On 03/26/14 at 05:31pm, Jiri Pirko wrote:
>> switchdev API is designed to allow kernel support for various switch
>> chips.
>> 
>> It is the responsibility of a driver to create netdevice instances which
>> represents every port and for the switch master itself. Driver uses
>> swdev_register and swportdev_register functions to make the core aware
>> of the fact these netdevices are representing switch and switch ports.
>
>I like this even more than the previous approach.
>
>> 
>> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>
>> +int __swdev_register(struct net_device *dev)
>> +{
>> +	if (dev->priv_flags & IFF_SWITCH) {
>> +		netdev_err(dev, "Device is already registered as a switch device\n");
>> +		return -EBUSY;
>> +	}
>> +	dev->priv_flags |= IFF_SWITCH;
>> +	netdev_info(dev, "Switch device registered\n");
>
>Perhaps include name of device here?

netdev_info already does that.


>
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(__swdev_register);
>> +
>> +int swdev_register(struct net_device *dev)
>> +{
>> +	int err;
>> +
>> +	rtnl_lock();
>> +	err = __swdev_register(dev);
>> +	rtnl_unlock();
>> +	return err;
>> +}
>> +EXPORT_SYMBOL(swdev_register);
>> +
>> +void __swdev_unregister(struct net_device *dev)
>> +{
>> +	dev->priv_flags |= IFF_SWITCH;
>> +	netdev_info(dev, "Switch device unregistered\n");
>
>Same here
>
>> +}
>> +EXPORT_SYMBOL(__swdev_unregister);
>> +
>> +void swdev_unregister(struct net_device *dev)
>> +{
>> +	rtnl_lock();
>> +	__swdev_unregister(dev);
>> +	rtnl_unlock();
>> +}
>> +EXPORT_SYMBOL(swdev_unregister);
>> +
>> +
>> +bool swportdev_dev_check(const struct net_device *port_dev)
>> +{
>> +	return port_dev->priv_flags & IFF_SWITCH_PORT;
>> +}
>> +EXPORT_SYMBOL(swportdev_dev_check);
>> +
>> +static rx_handler_result_t swportdev_handle_frame(struct sk_buff **pskb)
>> +{
>> +	struct sk_buff *skb = *pskb;
>> +
>> +	/* We don't care what comes from port device into rx path.
>> +	 * If there's something there, it is destined to ETH_P_ALL
>> +	 * handlers. So just consume it.
>> +	 */
>> +	dev_kfree_skb(skb);
>> +	return RX_HANDLER_CONSUMED;
>> +}
>> +
>> +int __swportdev_register(struct net_device *port_dev, struct net_device *dev)
>> +{
>> +	int err;
>> +
>> +	if (!(dev->priv_flags & IFF_SWITCH)) {
>> +		netdev_err(dev, "Device is not a switch device\n");
>> +		return -EINVAL;
>> +	}
>> +	if (port_dev->priv_flags & IFF_SWITCH_PORT) {
>> +		netdev_err(port_dev, "Device is already registered as a switch port\n");
>> +		return -EBUSY;
>> +	}
>> +	err = netdev_master_upper_dev_link(port_dev, dev);
>> +	if (err) {
>> +		netdev_err(dev, "Device %s failed to set upper link\n",
>> +			   port_dev->name);
>> +		return err;
>> +	}
>> +	err = netdev_rx_handler_register(port_dev, swportdev_handle_frame, NULL);
>> +	if (err) {
>> +		netdev_err(dev, "Device %s failed to register rx_handler\n",
>> +			   port_dev->name);
>> +		goto err_handler_register;
>> +	}
>> +	port_dev->priv_flags |= IFF_SWITCH_PORT;
>> +	netdev_info(port_dev, "Switch port device registered\n");
>
>and here
>
>> +	return 0;
>> +
>> +err_handler_register:
>> +	netdev_upper_dev_unlink(port_dev, dev);
>> +	return err;
>> +}
>> +EXPORT_SYMBOL(__swportdev_register);
>> +
>> +int swportdev_register(struct net_device *port_dev, struct net_device *dev)
>
>Maybe rename dev to switch_dev just to make it clear?


That might be reasonable.


>
>> +{
>> +	int err;
>> +
>> +	rtnl_lock();
>> +	err = __swportdev_register(port_dev, dev);
>> +	rtnl_unlock();
>> +	return err;
>> +}
>> +EXPORT_SYMBOL(swportdev_register);
>> +
>> +void __swportdev_unregister(struct net_device *port_dev)
>> +{
>> +	struct net_device *dev;
>> +
>> +	dev = netdev_master_upper_dev_get(port_dev);
>> +	BUG_ON(!dev);
>> +	port_dev->priv_flags &= ~IFF_SWITCH_PORT;
>> +	netdev_rx_handler_unregister(port_dev);
>> +	netdev_upper_dev_unlink(port_dev, dev);
>> +	netdev_info(port_dev, "Switch port device unregistered\n");
>> +}
>> +EXPORT_SYMBOL(__swportdev_unregister);
>> +
>> +void swportdev_unregister(struct net_device *port_dev)
>> +{
>> +	rtnl_lock();
>> +	__swportdev_unregister(port_dev);
>> +	rtnl_unlock();
>> +}
>> +EXPORT_SYMBOL(swportdev_unregister);
>> +
>> +MODULE_LICENSE("GPL v2");
>> +MODULE_AUTHOR("Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>");
>> +MODULE_DESCRIPTION("Switch device API");
>> -- 
>> 1.8.5.3
>> 
