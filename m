From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 18 Sep 2007 17:02:53 +0200
Message-ID: <46EFE89D.7050006@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de> <20070917100440.18347.5@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39449 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757100AbXIRPJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 11:09:33 -0400
In-Reply-To: <20070917100440.18347.5@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> This patch adds the virtual CAN bus (vcan) network driver.
> The vcan device is just a loopback device for CAN frames, no
> real CAN hardware is involved.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
> 

Also looks mostly fine, a few comments below.

> +++ net-2.6.24/drivers/net/can/vcan.c	2007-09-17 11:17:45.000000000 +0200
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/can.h>
> +#include <net/rtnetlink.h>
> +
> +static __initdata const char banner[] =
> +	KERN_INFO "vcan: Virtual CAN interface driver\n";
> +
> +MODULE_DESCRIPTION("virtual CAN interface");
> +MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
> +
> +#ifdef CONFIG_CAN_DEBUG_DEVICES
> +static int debug;
> +module_param(debug, int, S_IRUGO);
> +#endif
> +
> +/* To be moved to linux/can/dev.h */
> +#ifdef CONFIG_CAN_DEBUG_DEVICES
> +#define DBG(args...)       (debug & 1 ? \
> +			       (printk(KERN_DEBUG "vcan %s: ", __func__), \
> +				printk(args)) : 0)
> +#else
> +#define DBG(args...)
> +#endif
> +
> +
> +/*
> + * CAN test feature:
> + * Enable the loopback on driver level for testing the CAN core loopback modes.
> + * See Documentation/networking/can.txt for details.
> + */
> +
> +static int loopback; /* loopback testing. Default: 0 (Off) */
> +module_param(loopback, int, S_IRUGO);
> +MODULE_PARM_DESC(loopback, "Loop back frames (for testing). Default: 0 (Off)");


I would still prefer to have this on a per-device level configured
through netlink, but since we currently don't support specifying
flags for new devices anyways, I won't argue about it anymore
(OTOH, if you'd agree I could send a patch to add this feature
to the rtnl_link API).

> +
> +struct vcan_priv {
> +	struct net_device *dev;
> +	struct list_head list;
> +};


This is not needed anymore. The rtnl_link_unregister function calls
the ->dellink function for each device of this type. Check out the
current dummy.c driver.

> +static LIST_HEAD(vcan_devs);
> +
> +static int vcan_open(struct net_device *dev)
> +{
> +	DBG("%s: interface up\n", dev->name);
> +
> +	netif_start_queue(dev);
> +	return 0;
> +}
> +
> +static int vcan_stop(struct net_device *dev)
> +{
> +	DBG("%s: interface down\n", dev->name);
> +
> +	netif_stop_queue(dev);
> +	return 0;
> +}
> +
> +static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct net_device_stats *stats = &dev->stats;
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes += skb->len;
> +
> +	skb->protocol  = htons(ETH_P_CAN);
> +	skb->pkt_type  = PACKET_BROADCAST;
> +	skb->dev       = dev;
> +	skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
> +	DBG("received skbuff on interface %d\n", dev->ifindex);
> +
> +	netif_rx(skb);
> +}
> +
> +static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct net_device_stats *stats = &dev->stats;
> +	int loop;
> +
> +	DBG("sending skbuff on interface %s\n", dev->name);
> +
> +	stats->tx_packets++;
> +	stats->tx_bytes += skb->len;
> +
> +	/* set flag whether this packet has to be looped back */
> +	loop = skb->pkt_type == PACKET_LOOPBACK;
> +
> +	if (!loopback) {
> +		/* no loopback handling available inside this driver */
> +
> +		if (loop) {
> +			/*
> +			 * only count the packets here, because the
> +			 * CAN core already did the loopback for us
> +			 */
> +			stats->rx_packets++;
> +			stats->rx_bytes += skb->len;
> +		}
> +		kfree_skb(skb);
> +		return 0;
> +	}
> +
> +	/* perform standard loopback handling for CAN network interfaces */
> +
> +	if (loop) {
> +		struct sock *srcsk = skb->sk;
> +
> +		if (atomic_read(&skb->users) != 1) {
> +			struct sk_buff *old_skb = skb;
> +
> +			skb = skb_clone(old_skb, GFP_ATOMIC);
> +			DBG(KERN_INFO "%s: %s: freeing old skbuff %p, "
> +			    "using new skbuff %p\n",
> +			    dev->name, __FUNCTION__, old_skb, skb);
> +			kfree_skb(old_skb);

skb_share_check()?

> +			if (!skb)
> +				return 0;
> +		} else
> +			skb_orphan(skb);
> +
> +		/* receive with packet counting */
> +		skb->sk = srcsk;


Where is the socket used and what makes sure it still exists?

> +		vcan_rx(skb, dev);
> +	} else {
> +		/* no looped packets => no counting */
> +		kfree_skb(skb);
> +	}
> +	return 0;
> +}
> +
> +static void vcan_setup(struct net_device *dev)
> +{
> +	DBG("dev %s\n", dev->name);
> +
> +	dev->type              = ARPHRD_CAN;
> +	dev->mtu               = sizeof(struct can_frame);
> +	dev->hard_header_len   = 0;
> +	dev->addr_len          = 0;
> +	dev->tx_queue_len      = 0;
> +	dev->flags             = IFF_NOARP;
> +
> +	/* set flags according to driver capabilities */
> +	if (loopback)
> +		dev->flags |= IFF_LOOPBACK;
> +
> +	dev->open              = vcan_open;
> +	dev->stop              = vcan_stop;
> +	dev->hard_start_xmit   = vcan_tx;
> +	dev->destructor        = free_netdev;
> +
> +}
> +
> +static int vcan_newlink(struct net_device *dev,
> +			struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct vcan_priv *priv = netdev_priv(dev);
> +	int err;
> +
> +	err = register_netdevice(dev);
> +	if (err < 0)
> +		return err;
> +
> +	priv->dev = dev;
> +	list_add_tail(&priv->list, &vcan_devs);
> +	return 0;
> +}
> +
> +static void vcan_dellink(struct net_device *dev)
> +{
> +	struct vcan_priv *priv = netdev_priv(dev);
> +
> +	list_del(&priv->list);
> +	unregister_netdevice(dev);
> +}


Both the addlink and dellink function can be removed, the default
for addlink is register_netdevice, the default for unregister
is unregister_netdevice (and the list is not needed anymore as
mentioned above).

> +
> +static struct rtnl_link_ops vcan_link_ops __read_mostly = {
> +       .kind           = "vcan",
> +       .priv_size      = sizeof(struct vcan_priv),
> +       .setup          = vcan_setup,
> +       .newlink        = vcan_newlink,
> +       .dellink        = vcan_dellink,
> +};
> +
> +static __init int vcan_init_module(void)
> +{
> +	int err;
> +
> +	printk(banner);
> +
> +	if (loopback)
> +		printk(KERN_INFO "vcan: enabled loopback on driver level.\n");
> +
> +	rtnl_lock();
> +	err = __rtnl_link_register(&vcan_link_ops);
> +	rtnl_unlock();


Just using rtnl_link_register here is fine.

> +	return err;
> +}
> +
> +static __exit void vcan_cleanup_module(void)
> +{
> +	struct vcan_priv *priv, *n;
> +
> +	rtnl_lock();
> +	list_for_each_entry_safe(priv, n, &vcan_devs, list)
> +		vcan_dellink(priv->dev);
> +	__rtnl_link_unregister(&vcan_link_ops);
> +	rtnl_unlock();


and rtnl_link_unregister (without manual cleanup) here.
