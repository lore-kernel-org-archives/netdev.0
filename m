From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: Tue, 18 Sep 2007 16:13:09 +0200
Message-ID: <46EFDCF5.3020609@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de> <20070917100439.18347.3@janus.isnogud.escape.de>
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
Received: from stinky.trash.net ([213.144.137.162]:38409 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbXIROTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 10:19:48 -0400
In-Reply-To: <20070917100439.18347.3@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> This patch adds the CAN raw protocol.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>


Also looks good, a few minor comments below.

> Index: net-2.6.24/net/can/Kconfig
> ===================================================================
> --- net-2.6.24.orig/net/can/Kconfig	2007-09-17 10:30:35.000000000 +0200
> +++ net-2.6.24/net/can/Kconfig	2007-09-17 11:10:10.000000000 +0200
> @@ -16,6 +16,32 @@
> +config CAN_RAW_USER
> +	bool "Allow non-root users to access Raw CAN Protocol sockets"
> +	depends on CAN_RAW
> +	default N
> +	---help---
> +	  The Controller Area Network is a local field bus transmitting only
> +	  broadcast messages without any routing and security concepts.
> +	  In the majority of cases the user application has to deal with
> +	  raw CAN frames. Therefore it might be reasonable NOT to restrict
> +	  the CAN access only to the user root


Would it be much more trouble for userspace to use capabilities for
this? This would allow userspace to always know what to expect, I
don't think distributions will enable this option (which might again
not matter since they're probably rarely used in cars :)).

> +++ net-2.6.24/net/can/raw.c	2007-09-17 11:11:10.000000000 +0200
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/uio.h>
> +#include <linux/poll.h>
> +#include <linux/net.h>
> +#include <linux/netdevice.h>
> +#include <linux/socket.h>
> +#include <linux/if_arp.h>
> +#include <linux/skbuff.h>
> +#include <linux/can.h>
> +#include <linux/can/core.h>
> +#include <linux/can/raw.h>
> +#include <net/sock.h>
> +#include <net/net_namespace.h>
> +
> +#define IDENT "raw"
> +#define CAN_RAW_VERSION CAN_VERSION
> +static __initdata const char banner[] =
> +	KERN_INFO "can: raw protocol (rev " CAN_RAW_VERSION ")\n";
> +
> +MODULE_DESCRIPTION("PF_CAN raw protocol");
> +MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
> +
> +#ifdef CONFIG_CAN_DEBUG_CORE
> +static int debug;
> +module_param(debug, int, S_IRUGO);
> +MODULE_PARM_DESC(debug, "debug print mask: 1:debug, 2:frames, 4:skbs");
> +#endif
> +
> +#ifdef CONFIG_CAN_RAW_USER
> +#define RAW_CAP (-1)
> +#else
> +#define RAW_CAP CAP_NET_RAW
> +#endif
> +
> +#define MASK_ALL 0
> +
> +/*
> + * A raw socket has a list of can_filters attached to it, each receiving
> + * the CAN frames matching that filter.  If the filter list is empty,
> + * no CAN frames will be received by the socket.  The default after
> + * opening the socket, is to have one filter which receives all frames.
> + * The filter list is allocated dynamically with the exception of the
> + * list containing only one item.  This common case is optimized by
> + * storing the single filter in dfilter, to avoid using dynamic memory.
> + */
> +
> +struct raw_sock {
> +	struct sock sk;
> +	int bound;
> +	int ifindex;
> +	struct notifier_block notifier;
> +	int loopback;
> +	int recv_own_msgs;
> +	int count;                 /* number of active filters */
> +	struct can_filter dfilter; /* default/single filter */
> +	struct can_filter *filter; /* pointer to filter(s) */
> +	can_err_mask_t err_mask;
> +};
> +
> +static inline struct raw_sock *raw_sk(const struct sock *sk)
> +{
> +	return (struct raw_sock *)sk;
> +}
> +
> +static void raw_rcv(struct sk_buff *skb, void *data)
> +{
> +	struct sock *sk = (struct sock *)data;
> +	struct raw_sock *ro = raw_sk(sk);
> +	struct sockaddr_can *addr;
> +	int error;
> +
> +	DBG("received skbuff %p, sk %p\n", skb, sk);
> +	DBG_SKB(skb);
> +
> +	if (!ro->recv_own_msgs) {
> +		/* check the received tx sock reference */
> +		if (skb->sk == sk) {
> +			DBG("trashed own tx msg\n");
> +			kfree_skb(skb);
> +			return;
> +		}
> +	}
> +
> +	addr = (struct sockaddr_can *)skb->cb;
> +	memset(addr, 0, sizeof(*addr));
> +	addr->can_family  = AF_CAN;
> +	addr->can_ifindex = skb->dev->ifindex;


>From a quick look it looks like there's more than enough space, but
I guess a BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct sockaddr_can))
in the module init path wouldn't hurt.

> +
> +	error = sock_queue_rcv_skb(sk, skb);
> +	if (error < 0) {
> +		DBG("sock_queue_rcv_skb failed: %d\n", error);
> +		DBG("freeing skbuff %p\n", skb);
> +		kfree_skb(skb);
> +	}
> +}
> +
> +static void raw_enable_filters(struct net_device *dev, struct sock *sk)
> +{
> +	struct raw_sock *ro = raw_sk(sk);
> +	struct can_filter *filter = ro->filter;
> +	int i;
> +
> +	for (i = 0; i < ro->count; i++) {
> +		DBG("filter can_id %08X, can_mask %08X%s, sk %p\n",
> +		    filter[i].can_id, filter[i].can_mask,
> +		    filter[i].can_id & CAN_INV_FILTER ? " (inv)" : "", sk);
> +
> +		can_rx_register(dev, filter[i].can_id, filter[i].can_mask,
> +				raw_rcv, sk, IDENT);


Shouldn't this check for errors?

> +	}
> +}
> +
> +static void raw_enable_errfilter(struct net_device *dev, struct sock *sk)
> +{
> +	struct raw_sock *ro = raw_sk(sk);
> +
> +	if (ro->err_mask)
> +		can_rx_register(dev, 0, ro->err_mask | CAN_ERR_FLAG,
> +				raw_rcv, sk, IDENT);


Same question here ..

> +}
> +
> +static void raw_disable_filters(struct net_device *dev, struct sock *sk)
> +{
> +	struct raw_sock *ro = raw_sk(sk);
> +	struct can_filter *filter = ro->filter;
> +	int i;
> +
> +	for (i = 0; i < ro->count; i++) {
> +		DBG("filter can_id %08X, can_mask %08X%s, sk %p\n",
> +		    filter[i].can_id, filter[i].can_mask,
> +		    filter[i].can_id & CAN_INV_FILTER ? " (inv)" : "", sk);
> +
> +		can_rx_unregister(dev, filter[i].can_id, filter[i].can_mask,
> +				  raw_rcv, sk);
> +	}
> +}
> +
> +static void raw_disable_errfilter(struct net_device *dev, struct sock *sk)
> +{
> +	struct raw_sock *ro = raw_sk(sk);
> +
> +	if (ro->err_mask)
> +		can_rx_unregister(dev, 0, ro->err_mask | CAN_ERR_FLAG,
> +				  raw_rcv, sk);
> +}
> +
> +static int raw_notifier(struct notifier_block *nb,
> +			unsigned long msg, void *data)
> +{
> +	struct net_device *dev = (struct net_device *)data;
> +	struct raw_sock *ro = container_of(nb, struct raw_sock, notifier);
> +	struct sock *sk = &ro->sk;
> +
> +	DBG("msg %ld for dev %p (%s idx %d) sk %p ro->ifindex %d\n",
> +	    msg, dev, dev->name, dev->ifindex, sk, ro->ifindex);
> +
> +	if (dev->nd_net != &init_net)
> +		return NOTIFY_DONE;
> +
> +	if (dev->type != ARPHRD_CAN)
> +		return NOTIFY_DONE;
> +
> +	if (ro->ifindex != dev->ifindex)
> +		return NOTIFY_DONE;


Wouldn't that be a BUG()?
