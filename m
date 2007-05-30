From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 19:13:26 +0200
Message-ID: <465DB0B6.109@trash.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44028 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbXE3ROL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 13:14:11 -0400
In-Reply-To: <20070530131204.10843.5@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> +static int numdev = 4; /* default number of virtual CAN interfaces */
> +module_param(numdev, int, S_IRUGO);
> +MODULE_PARM_DESC(numdev, "Number of virtual CAN devices");


I have a set of patches coming up that introduce a rtnetlink API
for adding/modifying/deleting software network devices. I would
prefer if you could switch this driver over instead of doing the
"create N devices during loading" that many current drivers do,
leaving you with 20 unused devices after boot.

> +static int loopback = 0; /* vcan default: no loopback, just free the skb */
> +module_param(loopback, int, S_IRUGO);
> +MODULE_PARM_DESC(loopback, "Loop back sent frames. vcan default: 0 (Off)");


And it allows you have both loopback and non-loopback devices
in case that would be useful.

I'll send the patches by Friday.

> +static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct net_device_stats *stats = netdev_priv(dev);
> +	int loop;
> +
> +	DBG("sending skbuff on interface %s\n", dev->name);
> +
> +	stats->tx_packets++;
> +	stats->tx_bytes += skb->len;
> +
> +	/* tx socket reference pointer: Loopback required if not NULL */
> +	loop = *(struct sock **)skb->cb != NULL;


Qdiscs might change skb->cb. Maybe use skb->sk?


> +static int vcan_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	return -EOPNOTSUPP;
> +}

Not needed.

> +
> +static int vcan_rebuild_header(struct sk_buff *skb)
> +{
> +	DBG("skbuff %p\n", skb);
> +	return 0;
> +}

Also not needed.

> +
> +static int vcan_header(struct sk_buff *skb, struct net_device *dev,
> +		       unsigned short type, void *daddr, void *saddr,
> +		       unsigned int len)
> +{
> +	DBG("skbuff %p, device %p\n", skb, dev);
> +	return 0;
> +}

Also not needed.

> +static struct net_device_stats *vcan_get_stats(struct net_device *dev)
> +{
> +	struct net_device_stats *stats = netdev_priv(dev);
> +
> +	return stats;
> +}

Not needed if you just use dev->stats.

> +static __init int vcan_init_module(void)
> +{
> +	int i, result;
> +
> +	printk(banner);
> +
> +	/* register at least one interface */
> +	if (numdev < 1)
> +		numdev = 1;
> +
> +	printk(KERN_INFO
> +	       "vcan: registering %d virtual CAN interfaces. (loopback %s)\n",
> +	       numdev, loopback ? "enabled" : "disabled");
> +
> +	vcan_devs = kzalloc(numdev * sizeof(struct net_device *), GFP_KERNEL);
> +	if (!vcan_devs) {
> +		printk(KERN_ERR "vcan: Can't allocate vcan devices array!\n");
> +		return -ENOMEM;
> +	}
> +
> +	for (i = 0; i < numdev; i++) {
> +		vcan_devs[i] = alloc_netdev(STATSIZE, "vcan%d", vcan_init);
> +		if (!vcan_devs[i]) {
> +			printk(KERN_ERR "vcan: error allocating net_device\n");
> +			result = -ENOMEM;
> +			goto out;
> +		}
> +
> +		result = register_netdev(vcan_devs[i]);
> +		if (result < 0) {
> +			printk(KERN_ERR
> +			       "vcan: error %d registering interface %s\n",
> +			       result, vcan_devs[i]->name);
> +			free_netdev(vcan_devs[i]);
> +			vcan_devs[i] = NULL;
> +			goto out;
> +
> +		} else {
> +			DBG("successfully registered interface %s\n",
> +			    vcan_devs[i]->name);
> +		}
> +	}
> +
> +	return 0;
> +
> + out:
> +	for (i = 0; i < numdev; i++) {
> +		if (vcan_devs[i]) {
> +			unregister_netdev(vcan_devs[i]);
> +			free_netdev(vcan_devs[i]);
> +		}
> +	}
> +
> +	kfree(vcan_devs);
> +
> +	return result;
> +}


Looks quite large for such a simple task. Should get a lot
simpler by switching to the rtnetlink API.

