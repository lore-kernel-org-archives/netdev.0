From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 09/13] net-caif: add CAIF netdevice
Date: Thu, 21 Jan 2010 09:03:05 +0100
Message-ID: <4B580A39.3000805@trash.net>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-10-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53943 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667Ab0AUIDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 03:03:10 -0500
In-Reply-To: <1264028130-14364-10-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> +static void ipcaif_net_init(struct net_device *dev)
> +{
> +	struct chnl_net *priv;
> +	dev->netdev_ops = &netdev_ops;
> +	dev->destructor = free_netdev;

These (especially ->destructor) should be set in the setup function.

> +	dev->flags |= IFF_NOARP;
> +	dev->flags |= IFF_POINTOPOINT;
> +	dev->needed_headroom = CAIF_NEEDED_HEADROOM;
> +	dev->needed_tailroom = CAIF_NEEDED_TAILROOM;
> +	dev->mtu = SIZE_MTU;
> +	dev->tx_queue_len = CAIF_NET_DEFAULT_QUEUE_LEN;

These too I guess, its uncommon to reinitialize mtu and tx_queue_len
when setting a device down and up again.

> +
> +	priv = (struct chnl_net *)netdev_priv(dev);
> +	priv->chnl.receive = chnl_recv_cb;
> +	priv->chnl.ctrlcmd = chnl_flowctrl_cb;
> +	priv->netdev = dev;
> +	priv->config.type = CAIF_CHTY_DATAGRAM;
> +	priv->config.phy_pref = CFPHYPREF_HIGH_BW;
> +	priv->config.priority = CAIF_PRIO_LOW;
> +	priv->config.u.dgm.connection_id = -1; /* Insert illegal value */
> +	priv->flowenabled = false;
> +
> +	ASSERT_RTNL();
> +	init_waitqueue_head(&priv->netmgmt_wq);
> +	list_add(&priv->list_field, &chnl_net_list);
> +}

> +static int chnl_net_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)

static netdev_tx_t

> +{
> +	struct chnl_net *priv;
> +	struct cfpkt *pkt = NULL;
> +	int len;
> +	int result = -1;
> +
> +	/* Get our private data. */
> +	priv = (struct chnl_net *)netdev_priv(dev);
> +	if (!priv)
> +		return -ENOSPC;

This is an impossible condition, netdev_priv() will never return NULL.
The cast is also unnecessary.

> +
> +
> +	if (skb->len > priv->netdev->mtu) {
> +		pr_warning("CAIF: %s(): Size of skb exceeded MTU\n", __func__);
> +		return -ENOSPC;
> +	}
> +
> +	if (!priv->flowenabled) {
> +		pr_debug("CAIF: %s(): dropping packets flow off\n", __func__);
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	if (priv->config.type == CAIF_CHTY_DATAGRAM_LOOP) {
> +		struct iphdr *hdr;
> +		__be32 swap;
> +		/* Retrieve IP header. */
> +		hdr = ip_hdr(skb);
> +		/* Change source and destination address. */
> +		swap = hdr->saddr;
> +		hdr->saddr = hdr->daddr;
> +		hdr->daddr = swap;

swap()?

> +	}
> +	/* Store original SKB length. */
> +	len = skb->len;
> +
> +	pkt = cfpkt_fromnative(CAIF_DIR_OUT, (void *) skb);
> +
> +	/* Send the packet down the stack. */
> +	result = priv->chnl.dn->transmit(priv->chnl.dn, pkt);
> +	if (result) {
> +		if (result == CFGLU_ERETRY)
> +			result = NETDEV_TX_BUSY;
> +		return result;
> +	}
> +
> +	/* Update statistics. */
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += len;
> +
> +	return NETDEV_TX_OK;
> +}


> +
> +static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
> +			  struct nlattr *tb[], struct nlattr *data[])
> +{
> +	int err;
> +	struct chnl_net *caifdev;
> +	ASSERT_RTNL();
> +	caifdev = netdev_priv(dev);
> +	caif_netlink_parms(data, &caifdev->config);
> +	err = register_netdevice(dev);
> +	if (err) {
> +		pr_warning("CAIF: %s(): device rtml registration failed\n",
> +			   __func__);
> +		goto out;
> +	}
> +	dev_hold(dev);

What is this reference used for? You don't have a dellink function, so
this looks like a leak.

> +out:
> +	return err;
> +}
> +
> +static int ipcaif_changelink(struct net_device *dev, struct nlattr *tb[],
> +				struct nlattr *data[])
> +{
> +	struct chnl_net *caifdev;
> +	ASSERT_RTNL();
> +	caifdev = netdev_priv(dev);
> +	caif_netlink_parms(data, &caifdev->config);
> +	netdev_state_change(dev);
> +	return 0;
> +}
> +
> +static size_t ipcaif_get_size(const struct net_device *dev)
> +{
> +	return
> +		/* IFLA_CAIF_IPV4_CONNID */
> +		nla_total_size(4) +
> +		/* IFLA_CAIF_IPV6_CONNID */
> +		nla_total_size(4) +
> +		/* IFLA_CAIF_LOOPBACK */
> +		nla_total_size(2) +
> +		0;
> +}
> +
> +static const struct nla_policy ipcaif_policy[IFLA_CAIF_MAX + 1] = {
> +	[IFLA_CAIF_IPV4_CONNID]	      = { .type = NLA_U32 },
> +	[IFLA_CAIF_IPV6_CONNID]	      = { .type = NLA_U32 },
> +	[IFLA_CAIF_LOOPBACK]	      = { .type = NLA_U8 }
> +};
> +
> +
> +static struct rtnl_link_ops ipcaif_link_ops __read_mostly = {
> +	.kind		= "caif",
> +	.priv_size	= (size_t)sizeof(struct chnl_net),

Unnecessary cast.

> +	.setup		= ipcaif_net_init,
> +	.maxtype	= IFLA_CAIF_MAX,
> +	.policy		= ipcaif_policy,
> +	.newlink	= ipcaif_newlink,
> +	.changelink	= ipcaif_changelink,
> +	.get_size	= ipcaif_get_size,
> +	.fill_info	= ipcaif_fill_info,
> +
> +};
> +
> +int chnl_net_ioctl(unsigned int cmd, unsigned long arg, bool from_user_land)
> +{
> +	struct chnl_net *priv;
> +	int result = -1;
> +	struct chnl_net *dev;
> +	struct net_device *netdevptr;
> +	int ret;
> +	struct ifreq ifreq;
> +	struct ifcaif_param param;
> +	rtnl_lock();
> +	if (from_user_land) {
> +		if (copy_from_user(&ifreq, (const void *)arg, sizeof(ifreq)))
> +			return -EFAULT;
> +	} else
> +		memcpy(&ifreq, (void *)arg, sizeof(ifreq));

Why do you need both an ioctl and a netlink interface?

> +
> +	if (cmd == SIOCCAIFNETREMOVE) {
> +		pr_debug("CAIF: %s(): %s\n", __func__, ifreq.ifr_name);
> +		dev = find_device(ifreq.ifr_name);
> +		if (!dev)
> +			ret = -ENODEV;
> +		else
> +			ret = delete_device(dev);
> +		rtnl_unlock();
> +		return ret;
> +	}
> +
> +	if (cmd != SIOCCAIFNETNEW) {
> +		rtnl_unlock();
> +		return -ENOIOCTLCMD;
> +	}
> +	if (ifreq.ifr_ifru.ifru_data != NULL) {
> +		if (from_user_land) {
> +			ret = copy_from_user(&param,
> +					ifreq.ifr_ifru.ifru_data,
> +					sizeof(param));
> +			if (ret) {
> +				rtnl_unlock();
> +				return -EFAULT;
> +			}
> +		} else
> +			memcpy(&param,
> +				ifreq.ifr_ifru.ifru_data,
> +				sizeof(param));
> +		ifreq.ifr_ifru.ifru_data = &param;
> +	}
> +
> +	netdevptr = alloc_netdev(sizeof(struct chnl_net),
> +				 ifreq.ifr_name, ipcaif_net_init);
> +	if (!netdevptr) {
> +		rtnl_unlock();
> +		return	-ENODEV;
> +	}
> +	dev_hold(netdevptr);
> +	priv = (struct chnl_net *)netdev_priv(netdevptr);
> +	priv->config.u.dgm.connection_id = param.ipv4_connid;
> +
> +	if (param.loop)
> +		priv->config.type = CAIF_CHTY_DATAGRAM_LOOP;
> +	else
> +		priv->config.type = CAIF_CHTY_DATAGRAM;
> +
> +	result = register_netdevice(priv->netdev);
> +
> +	if (result < 0) {
> +		pr_warning("CAIF: %s(): can't register netdev %s %d\n",
> +			   __func__, ifreq.ifr_name, result);
> +		dev_put(netdevptr);
> +		rtnl_unlock();
> +		return	-ENODEV;
> +	}
> +	pr_debug("CAIF: %s(): netdev channel open:%s\n", __func__, priv->name);
> +	rtnl_unlock();
> +	return 0;
> +};
> +
> +struct net_device *chnl_net_create(char *name,
> +				   struct caif_channel_config *config)
> +{
> +	struct net_device *dev;
> +	ASSERT_RTNL();
> +	dev = alloc_netdev(sizeof(struct chnl_net), name, ipcaif_net_init);
> +	if (!dev)
> +		return NULL;
> +	((struct chnl_net *)netdev_priv(dev))->config = *config;
> +	dev_hold(dev);
> +	return dev;
> +}
> +EXPORT_SYMBOL(chnl_net_create);
> +
> +static int __init chnl_init_module(void)
> +{
> +	int err = -1;
> +	caif_register_ioctl(chnl_net_ioctl);
> +	err = rtnl_link_register(&ipcaif_link_ops);
> +	if (err < 0) {
> +		rtnl_link_unregister(&ipcaif_link_ops);

You don't need to unregister on error. The ioctl should be unregistered
I guess.

> +		return err;
> +	}
> +	return 0;
> +}
> +
> +static void __exit chnl_exit_module(void)
> +{
> +	struct chnl_net *dev = NULL;
> +	struct list_head *list_node;
> +	struct list_head *_tmp;
> +	rtnl_lock();
> +	list_for_each_safe(list_node, _tmp, &chnl_net_list) {
> +		dev = list_entry(list_node, struct chnl_net, list_field);
> +		delete_device(dev);
> +	}
> +	rtnl_unlock();
> +	rtnl_link_unregister(&ipcaif_link_ops);
> +	caif_register_ioctl(NULL);

This is racy, rtnl_link_unregister() will clean up all CAIF devices,
but the ioctl handler might register new ones after that. I'd suggest
to drop the ioctl interface completely.

> +}
> +
> +module_init(chnl_init_module);
> +module_exit(chnl_exit_module);

