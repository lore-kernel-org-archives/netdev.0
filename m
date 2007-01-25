From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH RFC 31/31] net: Add etun driver
Date: Thu, 25 Jan 2007 11:47:24 -0800
Message-ID: <45B9094C.3030902@candelatech.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com> <11697516404048-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:60335 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030528AbXAYTrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 14:47:25 -0500
In-Reply-To: <11697516404048-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@xmission.com> - unquoted
> 
> etun is a simple two headed tunnel driver that at the link layer
> looks like ethernet.  It's target audience is communicating
> between network namespaces but it is general enough it may
> have other uses as well.
> 

This looks almost identical to my redir-dev module.  Which is
fine..I don't really care which gets into the kernel so long as
one of them does...

Comments and questions are inline below.

> +/*
> + * The higher levels take care of making this non-reentrant (it's
> + * called with bh's disabled).
> + */
> +static int etun_xmit(struct sk_buff *skb, struct net_device *tx_dev)
> +{
> +	struct etun_info *tx_info = tx_dev->priv;
> +	struct net_device *rx_dev = tx_info->rx_dev;
> +	struct etun_info *rx_info = rx_dev->priv;
> +
> +	tx_info->stats.tx_packets++;
> +	tx_info->stats.tx_bytes += skb->len;
> +
> +	/* Drop the skb state that was needed to get here */
> +	skb_orphan(skb);
> +	if (skb->dst)
> +		skb->dst = dst_pop(skb->dst);	/* Allow for smart routing */

I ended up setting dst to NULL.  What does the dst_pop() accomplish?

> +	
> +	/* Switch to the receiving device */
> +	skb->pkt_type = PACKET_HOST;
> +	skb->protocol = eth_type_trans(skb, rx_dev);
> +	skb->dev = rx_dev;
> +	skb->ip_summed = CHECKSUM_NONE;
> +
> +	/* If both halves agree no checksum is needed */
> +	if (tx_dev->features & NETIF_F_NO_CSUM)
> +		skb->ip_summed = rx_info->ip_summed;
> +
> +	rx_dev->last_rx = jiffies; 

Do you need to set tx_dev->trans_start to jiffies as well?
			
> +	rx_info->stats.rx_packets++;
> +	rx_info->stats.rx_bytes += skb->len;

I think you need to zero out the skb->tstamp as well.  This lets it
be re-calculated when the receive logic of the other device is called.

Otherwise this fails:

rx skb on eth1, delay skb for network emulation, bridge onto etun0, rx on etun1
(time-stamp is still what it was when rx'd on eth1, which is too old.)


> +	netif_rx(skb);
> +
> +	return 0;
> +}
> +

> +static int etun_open(struct net_device *tx_dev)
> +{
> +	struct etun_info *tx_info = tx_dev->priv;
> +	struct net_device *rx_dev = tx_info->rx_dev;
> +	if (rx_dev->flags & IFF_UP) {
> +		netif_carrier_on(tx_dev);
> +		netif_carrier_on(rx_dev);
> +	}
> +	netif_start_queue(tx_dev);

Does this carrier logic keep etun0 from transmitting to
etun1 if etun0 is UP but etun1 is not UP yet?

> +	return 0;
> +}
> +
> +static int etun_stop(struct net_device *tx_dev)
> +{
> +	struct etun_info *tx_info = tx_dev->priv;
> +	struct net_device *rx_dev = tx_info->rx_dev;
> +	netif_stop_queue(tx_dev);
> +	if (netif_carrier_ok(tx_dev)) {
> +		netif_carrier_off(tx_dev);
> +		netif_carrier_off(rx_dev);
> +	}
> +	return 0;
> +}
> +
> +static void etun_set_multicast_list(struct net_device *dev)
> +{
> +	/* Nothing sane I can do here */
> +	return;
> +}
> +
> +static int etun_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +/* Only allow letters and numbers in an etun device name */
> +static int is_valid_name(const char *name)
> +{
> +	const char *ptr;
> +	for (ptr = name; *ptr; ptr++) {
> +		if (!isalnum(*ptr))
> +			return 0;
> +	}
> +	return 1;
> +}
> +
> +static struct net_device *etun_alloc(net_t net, const char *name)
> +{
> +	struct net_device *dev;
> +	struct etun_info *info;
> +	int err;
> +
> +	if (!name || !is_valid_name(name))
> +		return ERR_PTR(-EINVAL);
> +
> +	dev = alloc_netdev(sizeof(struct etun_info), name, ether_setup);
> +	if (!dev)
> +		return ERR_PTR(-ENOMEM);
> +	
> +	info = dev->priv;
> +	info->dev = dev;
> +	dev->nd_net = net;
> +
> +	random_ether_addr(dev->dev_addr);
> +	dev->tx_queue_len	= 0; /* A queue is silly for a loopback device */
> +	dev->hard_start_xmit	= etun_xmit;
> +	dev->get_stats		= etun_get_stats;
> +	dev->open		= etun_open;
> +	dev->stop		= etun_stop;
> +	dev->set_multicast_list	= etun_set_multicast_list;
> +	dev->do_ioctl		= etun_ioctl;
> +	dev->features		= NETIF_F_FRAGLIST
> +				  | NETIF_F_HIGHDMA
> +				  | NETIF_F_LLTX;
> +	dev->flags		= IFF_BROADCAST | IFF_MULTICAST |IFF_PROMISC;
> +	dev->ethtool_ops	= &etun_ethtool_ops;
> +	dev->destructor		= free_netdev;

You should add ability to change MTU.  I believe it is as trivial as this:

int redirdev_change_mtu(struct net_device *dev, int new_mtu) {
	dev->mtu = new_mtu;
	return 0;
}


> +	err = register_netdev(dev);
> +	if (err) {
> +		free_netdev(dev);
> +		dev = ERR_PTR(err);
> +		goto out;
> +	}
> +	netif_carrier_off(dev);
> +out:
> +	return dev;
> +}
> +
> +static int etun_alloc_pair(net_t net, const char *name0, const char *name1)
> +{
> +	struct net_device *dev0, *dev1;
> +	struct etun_info *info0, *info1;
> +
> +	dev0 = etun_alloc(net, name0);
> +	if (IS_ERR(dev0)) {
> +		return PTR_ERR(dev0);
> +	}
> +	info0 = dev0->priv;
> +
> +	dev1 = etun_alloc(net, name1);
> +	if (IS_ERR(dev1)) {
> +		unregister_netdev(dev0);
> +		return PTR_ERR(dev1);
> +	}
> +	info1 = dev1->priv;
> +
> +	dev_hold(dev0);
> +	dev_hold(dev1);
> +	info0->rx_dev = dev1;
> +	info1->rx_dev = dev0;

Can this race such that someone could manage to tx on one of these
devices before you assign the rx_dev?  Maybe register-netdev after
this assignment here, instead of in the alloc_etun method above?

> +
> +	/* Only place one member of the pair on the list
> +	 * so I don't confuse list_for_each_entry_safe,
> +	 * by deleting two list entries at once.
> +	 */
> +	rtnl_lock();
> +	list_add(&info0->list, &etun_list);
> +	INIT_LIST_HEAD(&info1->list);
> +	rtnl_unlock();
> +
> +	return 0;
> +}
> +
> +static int etun_unregister_pair(struct net_device *dev0)
> +{
> +	struct etun_info *info0, *info1;
> +	struct net_device *dev1;
> +
> +	ASSERT_RTNL();
> +
> +	if (!dev0)
> +		return -ENODEV;
> +
> +	info0 = dev0->priv;
> +	dev1  = info0->rx_dev;
> +	info1 = dev1->priv;
> +
> +	/* Drop the cross device references */
> +	dev_put(dev0);
> +	dev_put(dev1);

The devices are still potentially transmitting at this point,
since you have not yet called unregister_netdev?

For redir devices, I dropped association in the 'down' logic,
and re-acquired it lazily.  I saved the peer device's name
(not if-index).  I am not certain this is required, but I believe
it made locking simpler.

static int redirdev_open(struct net_device *dev) {
	struct redirdev* rdd = dev->priv;
	rdd->wants_to_run = 1;
	if (!rdd->tx_dev) {
		rdd->tx_dev = dev_get_by_name(rdd->tx_dev_name);
	}
	if (!rdd->tx_dev) {
		printk("redir: %s  Warning:  Could not find tx_dev: %s, will try later in redirdev_xmit.\n",
		       dev->name, rdd->tx_dev_name);
	}

	printk("redirdev:  Starting device: %s\n", dev->name);
	netif_start_queue(dev);
	return 0;
}

> +
> +	/* Remove from the etun list */
> +	if (!list_empty(&info0->list))
> +		list_del_init(&info0->list);
> +	if (!list_empty(&info1->list))
> +		list_del_init(&info1->list);
> +
> +	unregister_netdevice(dev0);
> +	unregister_netdevice(dev1);
> +	return 0;
> +}


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

