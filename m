From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Thu, 12 Jul 2007 14:31:29 +0200
Message-ID: <46961F21.7030409@trash.net>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46048 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762301AbXGLMbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 08:31:51 -0400
In-Reply-To: <4695F214.6020401@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> +static int veth_newlink(struct net_device *dev,
> +			 struct nlattr *tb[], struct nlattr *data[])
> +{
> +	int err;
> +	struct net_device *peer;
> +	struct veth_priv *priv;
> +	char ifname[IFNAMSIZ];
> +
> +	/*
> +	 * prepare the devices info
> +	 */
> +
> +	if (tb[IFLA_ADDRESS] == NULL)
> +		random_ether_addr(dev->dev_addr);
> +
> +	if (data != NULL && data[VETH_INFO_PEER] != NULL) {
> +		err = nla_parse_nested(tb, IFLA_INFO_MAX,
> +				data[VETH_INFO_PEER], ifla_policy);
> +		if (err < 0)
> +			return err;
> +	}


Not having a peer should be an error, no?

> +
> +	if (tb[IFLA_IFNAME])
> +		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
> +	else
> +		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");


Does this work? The other device is not registered at this time, so I
think the allocated names could clash ..

If it does work you could also perform name allocation in the
rtnl_create_link function.


> +
> +	peer = rtnl_create_link(ifname, &veth_link_ops, tb);
> +	if (IS_ERR(peer))
> +		return PTR_ERR(peer);
> +
> +	if (tb[IFLA_ADDRESS] == NULL)
> +		random_ether_addr(peer->dev_addr);
> +
> +	/*
> +	 * register devices
> +	 */
> +
> +	err = register_netdevice(peer);
> +	if (err < 0)
> +		goto err_register_peer;
> +
> +	err = register_netdevice(dev);
> +	if (err < 0)
> +		goto err_register_dev;
> +
> +	/*
> +	 * tie the deviced together
> +	 */
> +
> +	priv = netdev_priv(dev);
> +	priv->dev = dev;
> +	priv->peer = peer;
> +	list_add(&priv->list, &veth_list);
> +
> +	priv = netdev_priv(peer);
> +	priv->dev = peer;
> +	priv->peer = dev;
> +	INIT_LIST_HEAD(&priv->list);
> +	return 0;
> +
> +err_register_dev:
> +	unregister_netdevice(peer);
> +	return err;
> +
> +err_register_peer:
> +	free_netdev(peer);
> +	return err;
> +}

> +static __exit void veth_exit(void)
> +{
> +	struct veth_priv *priv, *next;
> +
> +	rtnl_lock();
> +	__rtnl_link_unregister(&veth_link_ops);
> +
> +	list_for_each_entry_safe(priv, next, &veth_list, list)
> +		veth_dellink(priv->dev);
> +	rtnl_unlock();


Devices are unregistered automatically through the dellink function,
rtnl_link_unregister(..) is enough.
