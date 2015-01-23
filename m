From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 2/5] swdevice: add new api to set and del
 bridge port attributes
Date: Fri, 23 Jan 2015 07:58:57 -0800
Message-ID: <54C26FC1.70605@cumulusnetworks.com>
References: <1421987606-10884-3-git-send-email-roopa@cumulusnetworks.com> <20150123104127.GC2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	vyasevic@redhat.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39711 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722AbbAWP7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:59:00 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so4786226pad.4
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:59:00 -0800 (PST)
In-Reply-To: <20150123104127.GC2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/15, 2:41 AM, Jiri Pirko wrote:

<snip..>
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index d162b21..bf0be98 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -50,3 +50,73 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
> 	return ops->ndo_switch_port_stp_update(dev, state);
> }
> EXPORT_SYMBOL(netdev_switch_port_stp_update);
> +
> +/**
> + *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
> + *	port attributes
> + *
> + *	@dev: port device
> + *	@nlh: netlink msg with bridge port attributes
> + *
> + *	Notify switch device port of bridge port attributes
> + */
> +int netdev_switch_port_bridge_setlink(struct net_device *dev,
> +				      struct nlmsghdr *nlh, u16 flags)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +	struct net_device *lower_dev;
> +	struct list_head *iter;
> +	int ret = 0, err = 0;
> +
> +	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
> +		return err;
> +
> +	if (ops->ndo_bridge_setlink) {
> +		WARN_ON(!ops->ndo_switch_parent_id_get);
> +		return ops->ndo_bridge_setlink(dev, nlh, flags);
> +	}
> +
> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
> +		if (err)
> +			ret = err;
> +	}
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(netdev_switch_port_bridge_setlink);
> +
> +/**
> + *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
> + *	attribute delete
> + *
> + *	@dev: port device
> + *	@nlh: netlink msg with bridge port attributes
> + *
> + *	Notify switch device port of bridge port attribute delete
> + */
> +int netdev_switch_port_bridge_dellink(struct net_device *dev,
> +				      struct nlmsghdr *nlh, u16 flags)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +	struct net_device *lower_dev;
> +	struct list_head *iter;
> +	int ret = 0, err = 0;
> +
> +	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
> +		return err;
> +
> +	if (ops->ndo_bridge_dellink) {
> +		WARN_ON(!ops->ndo_switch_parent_id_get);
> +		return ops->ndo_bridge_dellink(dev, nlh, flags);
> +	}
> +
> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
> +		if (err)
> +			ret = err;
> +	}
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
> -- 
> 1.7.10.4
>
> Is there any other place, other than bridge code, this functions are
> suppored to be called from?
No other place today. Its usually the master that implements 
ndo_bridge_setlink/dellink.

> If not, which I consider likely, it would
> make more sense to me to:
>
> - move netdev_for_each_lower_dev iterations directly to bridge code
> - let the masters (bond, team, ..) implement ndo_bridge_*link and do
>    the traversing there (can be in a form of pre-prepared default
>    ndo callback (ndo_dflt_netdev_switch_port_bridge_*link)
But, i am still not understanding why i would modify bond, team and 
other slaves
to offload bridge attributes. They could independently do so in the 
future if they
want to do something more than what this default api provides.
The api's setlink/dellink provided by this patch are the default api's.
The drivers can override them if needed in the future (which aligns with 
what you want as well).

Thanks,
Roopa
