From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Tue, 18 Sep 2007 15:31:41 +0200
Message-ID: <46EFD33D.8030905@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de> <20070917100438.18347.2@janus.isnogud.escape.de>
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
Received: from stinky.trash.net ([213.144.137.162]:37441 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbXIRNi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 09:38:27 -0400
In-Reply-To: <20070917100438.18347.2@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> This patch adds the CAN core functionality but no protocols or drivers.
> No protocol implementations are included here.  They come as separate
> patches.  Protocol numbers are already in include/linux/can.h.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
> 


Looks pretty good, please see below for a few comments (mostly minor
nitpicking, a few things that look like real bugs). Nothing that
couldn't be fixed after merging though.

> +++ net-2.6.24/include/linux/can.h	2007-09-17 10:27:09.000000000 +0200
> @@ -0,0 +1,113 @@
> +/*
> + * linux/can.h
> + *
> + * Definitions for CAN networklayer (socket addr / CAN frame / CAN filter)
> + *
> + * Authors: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> + *          Urs Thuermann   <urs.thuermann@volkswagen.de>
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Send feedback to <socketcan-users@lists.berlios.de>
> + *
> + */
> +
> +#ifndef CAN_H
> +#define CAN_H
> +
> +#include <linux/types.h>
> +#include <linux/socket.h>
> +
> +/* controller area network (CAN) kernel definitions */


Is this file used only from within the kernel? If so you could use
the nicer-to-look-at u8/u16/u32 types instead of the double underscored
ones.

> +++ net-2.6.24/include/linux/can/core.h	2007-09-17 11:08:39.000000000 +0200
> @@ -0,0 +1,78 @@
> +
> +extern int can_proto_register(struct can_proto *cp);
> +extern int can_proto_unregister(struct can_proto *cp);


The callers of the unregister function don't check the return code,
and they can't handle errors anyways since they use it in the
module unload path, so making it void seems more appropriate
(and maybe a WARN_ON for the "not-found" case).

> +extern int can_rx_register(struct net_device *dev, canid_t can_id,
> +			   canid_t mask,
> +			   void (*func)(struct sk_buff *, void *),
> +			   void *data, char *ident);
> +
> +extern int can_rx_unregister(struct net_device *dev, canid_t can_id,
> +			     canid_t mask,
> +			     void (*func)(struct sk_buff *, void *),
> +			     void *data);


Same here, none of the callers check the return value and since
they're all declared as void they can't propagate any errors back.

> +++ net-2.6.24/net/can/af_can.c	2007-09-17 11:06:52.000000000 +0200
> @@ -0,0 +1,1002 @@
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kmod.h>
> +#include <linux/slab.h>
> +#include <linux/list.h>
> +#include <linux/spinlock.h>
> +#include <linux/rcupdate.h>
> +#include <linux/uaccess.h>
> +#include <linux/net.h>
> +#include <linux/netdevice.h>
> +#include <linux/socket.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_arp.h>
> +#include <linux/skbuff.h>
> +#include <linux/can.h>
> +#include <linux/can/core.h>
> +#include <net/net_namespace.h>
> +#include <net/sock.h>
> +
> +#include "af_can.h"


It seems most of the things declared in that file are only used within
af_can.c. Might be easier to read the code if you'd just move it over.

> +
> +#define IDENT "core"
> +static __initdata const char banner[] = KERN_INFO
> +	"can: controller area network core (" CAN_VERSION_STRING ")\n";
> +
> +MODULE_DESCRIPTION("Controller Area Network PF_CAN core");
> +MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>, "
> +	      "Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
> +
> +MODULE_ALIAS_NETPROTO(PF_CAN);
> +
> +int stats_timer = 1; /* default: on */


This seems to be only used in af_can.c, so it could be static.
__read_mostly also seems to be approriate. There are a few
more that look like they could be __read_mostly below, but
I'll skip these since you probably know better than me.

> +module_param(stats_timer, int, S_IRUGO);
> +MODULE_PARM_DESC(stats_timer, "enable timer for statistics (default:on)");
> +
> +#ifdef CONFIG_CAN_DEBUG_CORE
> +static int debug;
> +module_param(debug, int, S_IRUGO);
> +MODULE_PARM_DESC(debug, "debug print mask: 1:debug, 2:frames, 4:skbs");
> +#endif
> +
> +HLIST_HEAD(rx_dev_list);


Same here (static).

> +static struct dev_rcv_lists rx_alldev_list;
> +static DEFINE_SPINLOCK(rcv_lists_lock);
> +
> +static struct kmem_cache *rcv_cache __read_mostly;
> +
> +/* table of registered CAN protocols */
> +static struct can_proto *proto_tab[CAN_NPROTO];
> +
> +struct timer_list stattimer; /* timer for statistics update */
> +struct s_stats  stats;       /* packet statistics */
> +struct s_pstats pstats;      /* receive list statistics */
> +
> +/*
> + * af_can socket functions
> + */
> +
> +static int can_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
> +{
> +	struct sock *sk = sock->sk;
> +
> +	switch (cmd) {
> +
> +	case SIOCGSTAMP:
> +		return sock_get_timestamp(sk, (struct timeval __user *)arg);
> +
> +	default:
> +		return -ENOIOCTLCMD;
> +	}
> +}
> +
> +static void can_sock_destruct(struct sock *sk)
> +{
> +	DBG("called for sock %p\n", sk);
> +
> +	skb_queue_purge(&sk->sk_receive_queue);
> +	if (sk->sk_protinfo)
> +		kfree(sk->sk_protinfo);
> +}
> +
> +static int can_create(struct net *net, struct socket *sock, int protocol)
> +{
> +	struct sock *sk;
> +	struct can_proto *cp;
> +	char module_name[sizeof("can-proto-000")];
> +	int ret = 0;
> +
> +	DBG("socket %p, type %d, proto %d\n", sock, sock->type, protocol);
> +
> +	sock->state = SS_UNCONNECTED;
> +
> +	if (protocol < 0 || protocol >= CAN_NPROTO)
> +		return -EINVAL;
> +
> +	DBG("looking up proto %d in proto_tab[]\n", protocol);
> +
> +	/* try to load protocol module, when CONFIG_KMOD is defined */
> +	if (!proto_tab[protocol]) {
> +		sprintf(module_name, "can-proto-%d", protocol);
> +		ret = request_module(module_name);
> +
> +		/*
> +		 * In case of error we only print a message but don't
> +		 * return the error code immediately.  Below we will
> +		 * return -EPROTONOSUPPORT
> +		 */
> +		if (ret == -ENOSYS)
> +			printk(KERN_INFO "can: request_module(%s) not"
> +			       " implemented.\n", module_name);
> +		else if (ret)
> +			printk(KERN_ERR "can: request_module(%s) failed\n",
> +			       module_name);


Both of these printks seem to be user-triggerable, so they should
be rate-limited (or maybe get removed completely/changed to DBG).

> +	}
> +
> +	/* check for success and correct type */
> +	cp = proto_tab[protocol];


What prevents the module from getting unloaded again (and using
a stale pointer)?

> +	if (!cp || cp->type != sock->type)
> +		return -EPROTONOSUPPORT;
> +
> +	if (net != &init_net)
> +		return -EAFNOSUPPORT;


Shouldn't this be done before attempting the module load?

> +
> +	if (cp->capability >= 0 && !capable(cp->capability))
> +		return -EPERM;
> +
> +	sock->ops = cp->ops;
> +
> +	sk = sk_alloc(net, PF_CAN, GFP_KERNEL, cp->prot, 1);
> +	if (!sk)
> +		return -ENOMEM;
> +
> +	sock_init_data(sock, sk);
> +	sk->sk_destruct = can_sock_destruct;
> +
> +	DBG("created sock: %p\n", sk);
> +
> +	if (sk->sk_prot->init)
> +		ret = sk->sk_prot->init(sk);
> +
> +	if (ret) {
> +		/* release sk on errors */
> +		sock_orphan(sk);
> +		sock_put(sk);
> +	}
> +
> +	return ret;
> +}
> +
> +/*
> + * af_can tx path
> + */
> +
> +/**
> + * can_send - transmit a CAN frame (optional with local loopback)
> + * @skb: pointer to socket buffer with CAN frame in data section
> + * @loop: loopback for listeners on local CAN sockets (recommended default!)
> + *
> + * Return:
> + *  0 on success
> + *  -ENETDOWN when the selected interface is down
> + *  -ENOBUFS on full driver queue (see net_xmit_errno())
> + *  -ENOMEM when local loopback failed at calling skb_clone()
> + */
> +int can_send(struct sk_buff *skb, int loop)
> +{
> +	int err;
> +
> +	if (skb->dev->type != ARPHRD_CAN) {
> +		kfree_skb(skb);
> +		return -EPERM;


EPERM doesn't seem like the best fit, but I don't have a better
suggestion myself at the moment.

> +	}
> +
> +	if (!(skb->dev->flags & IFF_UP)) {
> +		kfree_skb(skb);
> +		return -ENETDOWN;
> +	}
> +
> +	skb->protocol = htons(ETH_P_CAN);
> +
> +	if (loop) {
> +		/* local loopback of sent CAN frames */
> +
> +		/* indication for the CAN driver: do loopback */
> +		skb->pkt_type = PACKET_LOOPBACK;
> +
> +		/*
> +		 * The reference to the originating sock may be required
> +		 * by the receiving socket to check whether the frame is
> +		 * its own. Example: can_raw sockopt CAN_RAW_RECV_OWN_MSGS
> +		 * Therefore we have to ensure that skb->sk remains the
> +		 * reference to the originating sock by restoring skb->sk
> +		 * after each skb_clone() or skb_orphan() usage.
> +		 */
> +
> +		if (!(skb->dev->flags & IFF_LOOPBACK)) {
> +			/*
> +			 * If the interface is not capable to do loopback
> +			 * itself, we do it here.
> +			 */
> +			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
> +
> +			if (!newskb) {
> +				kfree_skb(skb);
> +				return -ENOMEM;
> +			}
> +
> +			newskb->sk = skb->sk;
> +			newskb->ip_summed = CHECKSUM_UNNECESSARY;
> +			newskb->pkt_type = PACKET_BROADCAST;
> +			netif_rx(newskb);


So the intention here is to send the packet to the non-loopback device
and manually loop it, which means sending it twice?

> +		}
> +	} else {
> +		/* indication for the CAN driver: no loopback required */
> +		skb->pkt_type = PACKET_HOST;
> +	}
> +
> +	/* send to netdevice */
> +	err = dev_queue_xmit(skb);
> +	if (err > 0)
> +		err = net_xmit_errno(err);
> +
> +	/* update statistics */
> +	stats.tx_frames++;
> +	stats.tx_frames_delta++;
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(can_send);
> +
> +/*
> + * af_can rx path
> + */
> +
> +static struct dev_rcv_lists *find_dev_rcv_lists(struct net_device *dev)
> +{
> +	struct dev_rcv_lists *d;
> +	struct hlist_node *n;
> +
> +	/*
> +	 * find receive list for this device
> +	 *
> +	 * The hlist_for_each_entry*() macros curse through the list
> +	 * using the pointer variable n and set d to the containing
> +	 * struct in each list iteration.  Therefore, after list
> +	 * iteration, d is unmodified when the list is empty, and it
> +	 * points to last list element, when the list is non-empty
> +	 * but no match in the loop body is found.  I.e. d is *not*
> +	 * NULL when no match is found.  We can, however, use the
> +	 * cursor variable n to decide if a match was found.
> +	 */
> +
> +	hlist_for_each_entry(d, n, &rx_dev_list, list) {


On the receive path you use RCU, so this should be
hlist_for_each_entry_rcu(), no? The bottem half disabling during
addition/removal also seems unnecessary, but I might be missing
something.

> +		if (d->dev == dev)
> +			break;
> +	}
> +
> +	return n ? d : NULL;
> +}
> +
> +static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
> +					struct dev_rcv_lists *d)
> +{
> +	canid_t inv = *can_id & CAN_INV_FILTER; /* save flag before masking */
> +
> +	/* filter error frames */
> +	if (*mask & CAN_ERR_FLAG) {
> +		/* clear CAN_ERR_FLAG in list entry */
> +		*mask &= CAN_ERR_MASK;
> +		return &d->rx[RX_ERR];
> +	}
> +
> +	/* ensure valid values in can_mask */
> +	if (*mask & CAN_EFF_FLAG)
> +		*mask &= (CAN_EFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG);
> +	else
> +		*mask &= (CAN_SFF_MASK | CAN_RTR_FLAG);
> +
> +	/* reduce condition testing at receive time */
> +	*can_id &= *mask;
> +
> +	/* inverse can_id/can_mask filter */
> +	if (inv)
> +		return &d->rx[RX_INV];
> +
> +	/* mask == 0 => no condition testing at receive time */
> +	if (!(*mask))
> +		return &d->rx[RX_ALL];
> +
> +	/* use extra filterset for the subscription of exactly *ONE* can_id */
> +	if (*can_id & CAN_EFF_FLAG) {
> +		if (*mask == (CAN_EFF_MASK | CAN_EFF_FLAG)) {
> +			/* RFC: a use-case for hash-tables in the future? */
> +			return &d->rx[RX_EFF];
> +		}
> +	} else {
> +		if (*mask == CAN_SFF_MASK)
> +			return &d->rx_sff[*can_id];
> +	}
> +
> +	/* default: filter via can_id/can_mask */
> +	return &d->rx[RX_FIL];
> +}
> +
> +/**
> + * can_rx_register - subscribe CAN frames from a specific interface
> + * @dev: pointer to netdevice (NULL => subcribe from 'all' CAN devices list)
> + * @can_id: CAN identifier (see description)
> + * @mask: CAN mask (see description)
> + * @func: callback function on filter match
> + * @data: returned parameter for callback function
> + * @ident: string for calling module indentification
> + *
> + * Description:
> + *  Invokes the callback function with the received sk_buff and the given
> + *  parameter 'data' on a matching receive filter. A filter matches, when
> + *
> + *          <received_can_id> & mask == can_id & mask
> + *
> + *  The filter can be inverted (CAN_INV_FILTER bit set in can_id) or it can
> + *  filter for error frames (CAN_ERR_FLAG bit set in mask).
> + *
> + * Return:
> + *  0 on success
> + *  -ENOMEM on missing cache mem to create subscription entry
> + *  -ENODEV unknown device
> + */
> +int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
> +		    void (*func)(struct sk_buff *, void *), void *data,
> +		    char *ident)
> +{
> +	struct receiver *r;
> +	struct hlist_head *rl;
> +	struct dev_rcv_lists *d;
> +	int ret = 0;
> +
> +	/* insert new receiver  (dev,canid,mask) -> (func,data) */
> +
> +	DBG("dev %p (%s), id %03X, mask %03X, callback %p, data %p, "
> +	    "ident %s\n", dev, DNAME(dev), can_id, mask, func, data, ident);
> +
> +	r = kmem_cache_alloc(rcv_cache, GFP_KERNEL);
> +	if (!r)
> +		return -ENOMEM;
> +
> +	spin_lock_bh(&rcv_lists_lock);
> +
> +	d = find_dev_rcv_lists(dev);
> +	if (d) {
> +		rl = find_rcv_list(&can_id, &mask, d);
> +
> +		r->can_id  = can_id;
> +		r->mask    = mask;
> +		r->matches = 0;
> +		r->func    = func;
> +		r->data    = data;
> +		r->ident   = ident;
> +
> +		hlist_add_head_rcu(&r->list, rl);
> +		d->entries++;
> +
> +		pstats.rcv_entries++;
> +		if (pstats.rcv_entries_max < pstats.rcv_entries)
> +			pstats.rcv_entries_max = pstats.rcv_entries;
> +	} else {
> +		DBG("receive list not found for dev %s, id %03X, mask %03X\n",
> +		    DNAME(dev), can_id, mask);
> +		kmem_cache_free(rcv_cache, r);
> +		ret = -ENODEV;
> +	}
> +
> +	spin_unlock_bh(&rcv_lists_lock);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(can_rx_register);
> +
> +/*
> + * can_rx_delete_device - rcu callback for dev_rcv_lists structure removal
> + */
> +static void can_rx_delete_device(struct rcu_head *rp)
> +{
> +	struct dev_rcv_lists *d = container_of(rp, struct dev_rcv_lists, rcu);
> +
> +	DBG("removing dev_rcv_list at %p\n", d);
> +	kfree(d);
> +}
> +
> +/*
> + * can_rx_delete_receiver - rcu callback for single receiver entry removal
> + */
> +static void can_rx_delete_receiver(struct rcu_head *rp)
> +{
> +	struct receiver *r = container_of(rp, struct receiver, rcu);
> +
> +	DBG("removing receiver at %p\n", r);
> +	kmem_cache_free(rcv_cache, r);
> +}
> +
> +/**
> + * can_rx_unregister - unsubscribe CAN frames from a specific interface
> + * @dev: pointer to netdevice (NULL => unsubcribe from 'all' CAN devices list)
> + * @can_id: CAN identifier
> + * @mask: CAN mask
> + * @func: callback function on filter match
> + * @data: returned parameter for callback function
> + *
> + * Description:
> + *  Removes subscription entry depending on given (subscription) values.
> + *
> + * Return:
> + *  0 on success
> + *  -EINVAL on missing subscription entry
> + *  -ENODEV unknown device
> + */
> +int can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
> +		      void (*func)(struct sk_buff *, void *), void *data)
> +{
> +	struct receiver *r = NULL;
> +	struct hlist_head *rl;
> +	struct hlist_node *next;
> +	struct dev_rcv_lists *d;
> +	int ret = 0;
> +
> +	DBG("dev %p (%s), id %03X, mask %03X, callback %p, data %p\n",
> +	    dev, DNAME(dev), can_id, mask, func, data);
> +
> +	spin_lock_bh(&rcv_lists_lock);
> +
> +	d = find_dev_rcv_lists(dev);
> +	if (!d) {
> +		DBG("receive list not found for dev %s, id %03X, mask %03X\n",
> +		    DNAME(dev), can_id, mask);
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +
> +	rl = find_rcv_list(&can_id, &mask, d);
> +
> +	/*
> +	 * Search the receiver list for the item to delete.  This should
> +	 * exist, since no receiver may be unregistered that hasn't
> +	 * been registered before.
> +	 */
> +
> +	hlist_for_each_entry(r, next, rl, list) {
> +		if (r->can_id == can_id && r->mask == mask
> +		    && r->func == func && r->data == data)
> +			break;
> +	}
> +
> +	/*
> +	 * Check for bug in CAN protocol implementations:
> +	 * If no matching list item was found, the list cursor variable next
> +	 * will be NULL, while r will point to the last item of the list.
> +	 */
> +
> +	if (!next) {
> +		DBG("receive list entry not found for "
> +		    "dev %s, id %03X, mask %03X\n", DNAME(dev), can_id, mask);
> +		ret = -EINVAL;
> +		r = NULL;
> +		d = NULL;
> +		goto out;
> +	}
> +
> +	hlist_del_rcu(&r->list);
> +	d->entries--;
> +
> +	if (pstats.rcv_entries > 0)
> +		pstats.rcv_entries--;
> +
> +	/* remove device structure requested by NETDEV_UNREGISTER */
> +	if (d->remove_on_zero_entries && !d->entries) {
> +		DBG("removing dev_rcv_list for %s on zero entries\n",
> +		    dev->name);
> +		hlist_del_rcu(&d->list);
> +	} else
> +		d = NULL;
> +
> + out:
> +	spin_unlock_bh(&rcv_lists_lock);
> +
> +	/* schedule the receiver item for deletion */
> +	if (r)
> +		call_rcu(&r->rcu, can_rx_delete_receiver);
> +
> +	/* schedule the device structure for deletion */
> +	if (d)
> +		call_rcu(&d->rcu, can_rx_delete_device);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(can_rx_unregister);
> +
> +static inline void deliver(struct sk_buff *skb, struct receiver *r)
> +{
> +	struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
> +
> +	DBG("skbuff %p cloned to %p\n", skb, clone);
> +	if (clone) {
> +		clone->sk = skb->sk;
> +		r->func(clone, r->data);
> +		r->matches++;
> +	}
> +}
> +
> +static int can_rcv_filter(struct dev_rcv_lists *d, struct sk_buff *skb)
> +{
> +	struct receiver *r;
> +	struct hlist_node *n;
> +	int matches = 0;
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	canid_t can_id = cf->can_id;
> +
> +	if (d->entries == 0)
> +		return 0;
> +
> +	if (can_id & CAN_ERR_FLAG) {
> +		/* check for error frame entries only */
> +		hlist_for_each_entry_rcu(r, n, &d->rx[RX_ERR], list) {
> +			if (can_id & r->mask) {
> +				DBG("match on rx_err skbuff %p\n", skb);
> +				deliver(skb, r);
> +				matches++;
> +			}
> +		}
> +		return matches;
> +	}
> +
> +	/* check for unfiltered entries */
> +	hlist_for_each_entry_rcu(r, n, &d->rx[RX_ALL], list) {
> +		DBG("match on rx_all skbuff %p\n", skb);
> +		deliver(skb, r);
> +		matches++;
> +	}
> +
> +	/* check for can_id/mask entries */
> +	hlist_for_each_entry_rcu(r, n, &d->rx[RX_FIL], list) {
> +		if ((can_id & r->mask) == r->can_id) {
> +			DBG("match on rx_fil skbuff %p\n", skb);
> +			deliver(skb, r);
> +			matches++;
> +		}
> +	}
> +
> +	/* check for inverted can_id/mask entries */
> +	hlist_for_each_entry_rcu(r, n, &d->rx[RX_INV], list) {
> +		if ((can_id & r->mask) != r->can_id) {
> +			DBG("match on rx_inv skbuff %p\n", skb);
> +			deliver(skb, r);
> +			matches++;
> +		}
> +	}
> +
> +	/* check CAN_ID specific entries */
> +	if (can_id & CAN_EFF_FLAG) {
> +		hlist_for_each_entry_rcu(r, n, &d->rx[RX_EFF], list) {
> +			if (r->can_id == can_id) {
> +				DBG("match on rx_eff skbuff %p\n", skb);
> +				deliver(skb, r);
> +				matches++;
> +			}
> +		}
> +	} else {
> +		can_id &= CAN_SFF_MASK;
> +		hlist_for_each_entry_rcu(r, n, &d->rx_sff[can_id], list) {
> +			DBG("match on rx_sff skbuff %p\n", skb);
> +			deliver(skb, r);
> +			matches++;
> +		}
> +	}
> +
> +	return matches;
> +}
> +
> +static int can_rcv(struct sk_buff *skb, struct net_device *dev,
> +		   struct packet_type *pt, struct net_device *orig_dev)
> +{
> +	struct dev_rcv_lists *d;
> +	int matches;
> +
> +	DBG("received skbuff on device %s, ptype %04x\n",
> +	    dev->name, ntohs(pt->type));
> +	DBG_SKB(skb);
> +	DBG_FRAME("af_can: can_rcv: received CAN frame",
> +		  (struct can_frame *)skb->data);
> +
> +	if (dev->type != ARPHRD_CAN || dev->nd_net != &init_net) {
> +		kfree_skb(skb);
> +		return 0;
> +	}
> +
> +	/* update statistics */
> +	stats.rx_frames++;
> +	stats.rx_frames_delta++;
> +
> +	rcu_read_lock();
> +
> +	/* deliver the packet to sockets listening on all devices */
> +	matches = can_rcv_filter(&rx_alldev_list, skb);
> +
> +	/* find receive list for this device */
> +	d = find_dev_rcv_lists(dev);
> +	if (d)
> +		matches += can_rcv_filter(d, skb);
> +
> +	rcu_read_unlock();
> +
> +	/* free the skbuff allocated by the netdevice driver */
> +	DBG("freeing skbuff %p\n", skb);
> +	kfree_skb(skb);
> +
> +	if (matches > 0) {
> +		stats.matches++;
> +		stats.matches_delta++;
> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * af_can protocol functions
> + */
> +
> +/**
> + * can_proto_register - register CAN transport protocol
> + * @cp: pointer to CAN protocol structure
> + *
> + * Return:
> + *  0 on success
> + *  -EINVAL invalid (out of range) protocol number
> + *  -EBUSY  protocol already in use
> + *  -ENOBUF if proto_register() fails
> + */
> +int can_proto_register(struct can_proto *cp)
> +{
> +	int proto = cp->protocol;
> +	int err = 0;
> +
> +	if (proto < 0 || proto >= CAN_NPROTO) {
> +		printk(KERN_ERR "can: protocol number %d out of range\n",
> +		       proto);
> +		return -EINVAL;
> +	}
> +	if (proto_tab[proto]) {
> +		printk(KERN_ERR "can: protocol %d already registered\n",
> +		       proto);
> +		return -EBUSY;
> +	}
> +
> +	err = proto_register(cp->prot, 0);
> +	if (err < 0)
> +		return err;
> +
> +	proto_tab[proto] = cp;
> +
> +	/* use generic ioctl function if the module doesn't bring its own */
> +	if (!cp->ops->ioctl)
> +		cp->ops->ioctl = can_ioctl;
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(can_proto_register);
> +
> +/**
> + * can_proto_unregister - unregister CAN transport protocol
> + * @cp: pointer to CAN protocol structure
> + *
> + * Return:
> + *  0 on success
> + *  -ESRCH protocol number was not registered
> + */
> +int can_proto_unregister(struct can_proto *cp)
> +{
> +	int proto = cp->protocol;
> +
> +	if (!proto_tab[proto]) {
> +		printk(KERN_ERR "can: protocol %d is not registered\n", proto);
> +		return -ESRCH;
> +	}
> +	proto_unregister(cp->prot);
> +	proto_tab[proto] = NULL;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(can_proto_unregister);
> +
> +/*
> + * af_can notifier to create/remove CAN netdevice specific structs
> + */
> +static int can_notifier(struct notifier_block *nb, unsigned long msg,
> +			void *data)
> +{
> +	struct net_device *dev = (struct net_device *)data;
> +	struct dev_rcv_lists *d;
> +
> +	DBG("msg %ld for dev %p (%s idx %d)\n",
> +	    msg, dev, dev->name, dev->ifindex);
> +
> +	if (dev->nd_net != &init_net)
> +		return NOTIFY_DONE;
> +
> +	if (dev->type != ARPHRD_CAN)
> +		return NOTIFY_DONE;
> +
> +	switch (msg) {
> +
> +	case NETDEV_REGISTER:
> +
> +		/*
> +		 * create new dev_rcv_lists for this device
> +		 *
> +		 * N.B. zeroing the struct is the correct initialization
> +		 * for the embedded hlist_head structs.
> +		 * Another list type, e.g. list_head, would require
> +		 * explicit initialization.
> +		 */
> +
> +		DBG("creating new dev_rcv_lists for %s\n", dev->name);
> +
> +		d = kzalloc(sizeof(*d),
> +			    in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);


netdevice registration should never happen from interrupt handlers.

> +		if (!d) {
> +			printk(KERN_ERR
> +			       "can: allocation of receive list failed\n");
> +			return NOTIFY_DONE;
> +		}
> +		d->dev = dev;
> +
> +		spin_lock_bh(&rcv_lists_lock);
> +		hlist_add_head_rcu(&d->list, &rx_dev_list);
> +		spin_unlock_bh(&rcv_lists_lock);
> +
> +		break;
> +
> +	case NETDEV_UNREGISTER:
> +		spin_lock_bh(&rcv_lists_lock);
> +
> +		d = find_dev_rcv_lists(dev);
> +		if (d) {
> +			DBG("remove dev_rcv_list for %s (%d entries)\n",
> +			    dev->name, d->entries);
> +
> +			if (d->entries) {
> +				d->remove_on_zero_entries = 1;
> +				d = NULL;
> +			} else
> +				hlist_del_rcu(&d->list);
> +		} else
> +			printk(KERN_ERR "can: notifier: receive list not "
> +			       "found for dev %s\n", dev->name);
> +
> +		spin_unlock_bh(&rcv_lists_lock);
> +
> +		if (d)
> +			call_rcu(&d->rcu, can_rx_delete_device);
> +
> +		break;
> +	}
> +
> +	return NOTIFY_DONE;
> +}
> +
> +/*
> + * af_can debugging stuff
> + */
> +
> +#ifdef CONFIG_CAN_DEBUG_CORE
> +
> +#define DBG_BSIZE 1024
> +
> +/**
> + * can_debug_cframe - print CAN frame
> + * @msg: pointer to message printed before the given CAN frame
> + * @cf: pointer to CAN frame
> + */
> +void can_debug_cframe(const char *msg, struct can_frame *cf, ...)
> +{
> +	va_list ap;
> +	int len;
> +	int dlc, i;
> +	char *buf;
> +
> +	buf = kmalloc(DBG_BSIZE, GFP_ATOMIC);
> +	if (!buf)
> +		return;
> +
> +	len = sprintf(buf, KERN_DEBUG);
> +	va_start(ap, cf);
> +	len += snprintf(buf + len, DBG_BSIZE - 64, msg, ap);
> +	buf[len++] = ':';
> +	buf[len++] = ' ';
> +	va_end(ap);
> +
> +	dlc = cf->can_dlc;
> +	if (dlc > 8)
> +		dlc = 8;
> +
> +	if (cf->can_id & CAN_EFF_FLAG)
> +		len += sprintf(buf + len, "<%08X> [%X] ",
> +			       cf->can_id & CAN_EFF_MASK, dlc);
> +	else
> +		len += sprintf(buf + len, "<%03X> [%X] ",
> +			       cf->can_id & CAN_SFF_MASK, dlc);
> +
> +	for (i = 0; i < dlc; i++)
> +		len += sprintf(buf + len, "%02X ", cf->data[i]);
> +
> +	if (cf->can_id & CAN_RTR_FLAG)
> +		len += sprintf(buf + len, "(RTR)");
> +
> +	buf[len++] = '\n';
> +	buf[len]   = '\0';
> +	printk(buf);
> +	kfree(buf);
> +}
> +EXPORT_SYMBOL(can_debug_cframe);
> +
> +/**
> + * can_debug_skb - print socket buffer content to kernel log
> + * @skb: pointer to socket buffer
> + */
> +void can_debug_skb(struct sk_buff *skb)
> +{
> +	int len, nbytes, i;
> +	char *buf;
> +
> +	buf = kmalloc(DBG_BSIZE, GFP_ATOMIC);
> +	if (!buf)
> +		return;
> +
> +	len = sprintf(buf,
> +		      KERN_DEBUG "  skbuff at %p, dev: %d, proto: %04x\n"
> +		      KERN_DEBUG "  users: %d, dataref: %d, nr_frags: %d, "
> +		      "h,d,t,e,l: %p %+d %+d %+d, %d",
> +		      skb, skb->dev ? skb->dev->ifindex : -1,
> +		      ntohs(skb->protocol),
> +		      atomic_read(&skb->users),
> +		      atomic_read(&(skb_shinfo(skb)->dataref)),
> +		      skb_shinfo(skb)->nr_frags,
> +		      skb->head, skb->data - skb->head,
> +		      skb->tail - skb->head, skb->end - skb->head, skb->len);
> +	nbytes = skb->end - skb->head;
> +	for (i = 0; i < nbytes; i++) {
> +		if (i % 16 == 0)
> +			len += sprintf(buf + len, "\n" KERN_DEBUG "  ");
> +		if (len < DBG_BSIZE - 16) {
> +			len += sprintf(buf + len, " %02x", skb->head[i]);
> +		} else {
> +			len += sprintf(buf + len, "...");
> +			break;
> +		}
> +	}
> +	buf[len++] = '\n';
> +	buf[len]   = '\0';
> +	printk(buf);
> +	kfree(buf);
> +}
> +EXPORT_SYMBOL(can_debug_skb);
> +
> +#endif
> +
> +/*
> + * af_can module init/exit functions
> + */
> +
> +static struct packet_type can_packet = {
> +	.type = __constant_htons(ETH_P_CAN),
> +	.dev  = NULL,
> +	.func = can_rcv,
> +};

__read_mostly (for those below as well)?

> +
> +static struct net_proto_family can_family_ops = {
> +	.family = PF_CAN,
> +	.create = can_create,
> +	.owner  = THIS_MODULE,
> +};
> +
> +/* notifier block for netdevice event */
> +static struct notifier_block can_netdev_notifier = {
> +	.notifier_call = can_notifier,
> +};
> +
> +static __init int can_init(void)
> +{
> +	printk(banner);
> +
> +	rcv_cache = kmem_cache_create("can_receiver", sizeof(struct receiver),
> +				      0, 0, NULL);
> +	if (!rcv_cache)
> +		return -ENOMEM;
> +
> +	/*
> +	 * Insert rx_alldev_list for reception on all devices.
> +	 * This struct is zero initialized which is correct for the
> +	 * embedded hlist heads, the dev pointer, and the entries counter.
> +	 */
> +
> +	spin_lock_bh(&rcv_lists_lock);
> +	hlist_add_head_rcu(&rx_alldev_list.list, &rx_dev_list);
> +	spin_unlock_bh(&rcv_lists_lock);
> +
> +	if (stats_timer) {
> +		/* the statistics are updated every second (timer triggered) */
> +		init_timer(&stattimer);
> +		stattimer.function = can_stat_update;
> +		stattimer.data = 0;
> +		/* update every second */
> +		stattimer.expires = jiffies + HZ;

round_jiffies?

> +		/* start statistics timer */
> +		add_timer(&stattimer);
> +	} else
> +		stattimer.function = NULL;
> +
> +	/* procfs init */
> +	can_init_proc();
> +
> +	/* protocol register */
> +	sock_register(&can_family_ops);
> +	register_netdevice_notifier(&can_netdev_notifier);
> +	dev_add_pack(&can_packet);
> +
> +	return 0;
> +}
> +
> +static __exit void can_exit(void)
> +{
> +	struct dev_rcv_lists *d;
> +	struct hlist_node *n, *next;
> +
> +	if (stats_timer)
> +		del_timer(&stattimer);
> +
> +	/* procfs remove */
> +	can_remove_proc();
> +
> +	/* protocol unregister */
> +	dev_remove_pack(&can_packet);
> +	unregister_netdevice_notifier(&can_netdev_notifier);
> +	sock_unregister(PF_CAN);
> +
> +	/* remove rx_dev_list */
> +	spin_lock_bh(&rcv_lists_lock);
> +	hlist_del(&rx_alldev_list.list);
> +	hlist_for_each_entry_safe(d, n, next, &rx_dev_list, list) {
> +		hlist_del(&d->list);
> +		kfree(d);
> +	}
> +	spin_unlock_bh(&rcv_lists_lock);
> +
> +	kmem_cache_destroy(rcv_cache);
> +}
> +
> +module_init(can_init);
> +module_exit(can_exit);

> +++ net-2.6.24/net/can/proc.c	2007-09-17 11:07:19.000000000 +0200
> @@ -0,0 +1,531 @@
> +#include <linux/module.h>
> +#include <linux/proc_fs.h>
> +#include <linux/list.h>
> +#include <linux/rcupdate.h>
> +#include <linux/can/core.h>
> +
> +#include "af_can.h"
> +
> +/*
> + * proc filenames for the PF_CAN core
> + */
> +
> +#define CAN_PROC_VERSION     "version"
> +#define CAN_PROC_STATS       "stats"
> +#define CAN_PROC_RESET_STATS "reset_stats"
> +#define CAN_PROC_RCVLIST_ALL "rcvlist_all"
> +#define CAN_PROC_RCVLIST_FIL "rcvlist_fil"
> +#define CAN_PROC_RCVLIST_INV "rcvlist_inv"
> +#define CAN_PROC_RCVLIST_SFF "rcvlist_sff"
> +#define CAN_PROC_RCVLIST_EFF "rcvlist_eff"
> +#define CAN_PROC_RCVLIST_ERR "rcvlist_err"
> +
> +static struct proc_dir_entry *can_dir;
> +static struct proc_dir_entry *pde_version;
> +static struct proc_dir_entry *pde_stats;
> +static struct proc_dir_entry *pde_reset_stats;
> +static struct proc_dir_entry *pde_rcvlist_all;
> +static struct proc_dir_entry *pde_rcvlist_fil;
> +static struct proc_dir_entry *pde_rcvlist_inv;
> +static struct proc_dir_entry *pde_rcvlist_sff;
> +static struct proc_dir_entry *pde_rcvlist_eff;
> +static struct proc_dir_entry *pde_rcvlist_err;
> +
> +static int user_reset;
> +
> +static const char *rx_list_name[] = {
> +	[RX_ERR] = "rx_err",
> +	[RX_ALL] = "rx_all",
> +	[RX_FIL] = "rx_fil",
> +	[RX_INV] = "rx_inv",
> +	[RX_EFF] = "rx_eff",
> +};
> +
> +/*
> + * af_can statistics stuff
> + */
> +
> +static void can_init_stats(void)
> +{
> +	/*
> +	 * This memset function is called from a timer context (when
> +	 * stattimer is active which is the default) OR in a process
> +	 * context (reading the proc_fs when stattimer is disabled).
> +	 */
> +	memset(&stats, 0, sizeof(stats));
> +	stats.jiffies_init = jiffies;
> +
> +	pstats.stats_reset++;
> +
> +	if (user_reset) {
> +		user_reset = 0;
> +		pstats.user_reset++;
> +	}
> +}
> +
> +static unsigned long calc_rate(unsigned long oldjif, unsigned long newjif,
> +			       unsigned long count)
> +{
> +	unsigned long ret = 0;
> +
> +	if (oldjif == newjif)
> +		return 0;
> +
> +	/* see can_rcv() - this should NEVER happen! */


If I'm not mistaken this comment is outdated and should refer to
can_stat_update().

> +	if (count > (ULONG_MAX / HZ)) {
> +		printk(KERN_ERR "can: calc_rate: count exceeded! %ld\n",
> +		       count);
> +		return 99999999;
> +	}
> +
> +	ret = (count * HZ) / (newjif - oldjif);
> +
> +	return ret;
> +}
> +
> +void can_stat_update(unsigned long data)
> +{
> +	unsigned long j = jiffies; /* snapshot */
> +
> +	/* restart counting in timer context on user request */
> +	if (user_reset)
> +		can_init_stats();
> +
> +	/* restart counting on jiffies overflow */
> +	if (j < stats.jiffies_init)
> +		can_init_stats();
> +
> +	/* stats.rx_frames is the definitively max. statistic value */
> +
> +	/* prevent overflow in calc_rate() */
> +	if (stats.rx_frames > (ULONG_MAX / HZ))
> +		can_init_stats();
> +
> +	/* matches overflow - very improbable */
> +	if (stats.matches > (ULONG_MAX / 100))
> +		can_init_stats();
> +
> +	/* calc total values */
> +	if (stats.rx_frames)
> +		stats.total_rx_match_ratio = (stats.matches * 100) /
> +						stats.rx_frames;
> +
> +	stats.total_tx_rate = calc_rate(stats.jiffies_init, j,
> +					stats.tx_frames);
> +	stats.total_rx_rate = calc_rate(stats.jiffies_init, j,
> +					stats.rx_frames);
> +
> +	/* calc current values */
> +	if (stats.rx_frames_delta)
> +		stats.current_rx_match_ratio =
> +			(stats.matches_delta * 100) / stats.rx_frames_delta;
> +
> +	stats.current_tx_rate = calc_rate(0, HZ, stats.tx_frames_delta);
> +	stats.current_rx_rate = calc_rate(0, HZ, stats.rx_frames_delta);
> +
> +	/* check / update maximum values */
> +	if (stats.max_tx_rate < stats.current_tx_rate)
> +		stats.max_tx_rate = stats.current_tx_rate;
> +
> +	if (stats.max_rx_rate < stats.current_rx_rate)
> +		stats.max_rx_rate = stats.current_rx_rate;
> +
> +	if (stats.max_rx_match_ratio < stats.current_rx_match_ratio)
> +		stats.max_rx_match_ratio = stats.current_rx_match_ratio;
> +
> +	/* clear values for 'current rate' calculation */
> +	stats.tx_frames_delta = 0;
> +	stats.rx_frames_delta = 0;
> +	stats.matches_delta   = 0;
> +
> +	/* restart timer (one second) */
> +	stattimer.expires = jiffies + HZ;


round_jiffies?

> +	add_timer(&stattimer);
> +}
> +
> +/*
> + * proc read functions
> + *
> + * From known use-cases we expect about 10 entries in a receive list to be
> + * printed in the proc_fs. So PAGE_SIZE is definitely enough space here.


Would be nicer to use seq_file (for all the proc stuff).

> + *
> + */
> +
> +static int can_print_rcvlist(char *page, int len, struct hlist_head *rx_list,
> +			     struct net_device *dev)
> +{
> +	struct receiver *r;
> +	struct hlist_node *n;
> +
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(r, n, rx_list, list) {
> +		char *fmt = (r->can_id & CAN_EFF_FLAG)?
> +			"   %-5s  %08X  %08x  %08x  %08x  %8ld  %s\n" :
> +			"   %-5s     %03X    %08x  %08lx  %08lx  %8ld  %s\n";
> +
> +		len += snprintf(page + len, PAGE_SIZE - len, fmt,
> +				DNAME(dev), r->can_id, r->mask,
> +				(unsigned long)r->func, (unsigned long)r->data,
> +				r->matches, r->ident);
> +
> +		/* does a typical line fit into the current buffer? */
> +
> +		/* 100 Bytes before end of buffer */
> +		if (len > PAGE_SIZE - 100) {
> +			/* mark output cut off */
> +			len += snprintf(page + len, PAGE_SIZE - len,
> +					"   (..)\n");
> +			break;
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	return len;
> +}
> +
> +static int can_print_recv_banner(char *page, int len)
> +{
> +	/*
> +	 *                  can1.  00000000  00000000  00000000
> +	 *                 .......          0  tp20
> +	 */
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			"  device   can_id   can_mask  function"
> +			"  userdata   matches  ident\n");
> +
> +	return len;
> +}
> +
> +static int can_proc_read_stats(char *page, char **start, off_t off,
> +			       int count, int *eof, void *data)
> +{
> +	int len = 0;
> +
> +	len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			" %8ld transmitted frames (TXF)\n", stats.tx_frames);
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			" %8ld received frames (RXF)\n", stats.rx_frames);
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			" %8ld matched frames (RXMF)\n", stats.matches);
> +
> +	len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +
> +	if (stattimer.function == can_stat_update) {
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld %% total match ratio (RXMR)\n",
> +				stats.total_rx_match_ratio);
> +
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld frames/s total tx rate (TXR)\n",
> +				stats.total_tx_rate);
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld frames/s total rx rate (RXR)\n",
> +				stats.total_rx_rate);
> +
> +		len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld %% current match ratio (CRXMR)\n",
> +				stats.current_rx_match_ratio);
> +
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld frames/s current tx rate (CTXR)\n",
> +				stats.current_tx_rate);
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld frames/s current rx rate (CRXR)\n",
> +				stats.current_rx_rate);
> +
> +		len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld %% max match ratio (MRXMR)\n",
> +				stats.max_rx_match_ratio);
> +
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld frames/s max tx rate (MTXR)\n",
> +				stats.max_tx_rate);
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld frames/s max rx rate (MRXR)\n",
> +				stats.max_rx_rate);
> +
> +		len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +	}
> +
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			" %8ld current receive list entries (CRCV)\n",
> +			pstats.rcv_entries);
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			" %8ld maximum receive list entries (MRCV)\n",
> +			pstats.rcv_entries_max);
> +
> +	if (pstats.stats_reset)
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				"\n %8ld statistic resets (STR)\n",
> +				pstats.stats_reset);
> +
> +	if (pstats.user_reset)
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				" %8ld user statistic resets (USTR)\n",
> +				pstats.user_reset);
> +
> +	len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +
> +	*eof = 1;
> +	return len;
> +}
> +
> +static int can_proc_read_reset_stats(char *page, char **start, off_t off,
> +				     int count, int *eof, void *data)
> +{
> +	int len = 0;
> +
> +	user_reset = 1;
> +
> +	if (stattimer.function == can_stat_update) {
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				"Scheduled statistic reset #%ld.\n",
> +				pstats.stats_reset + 1);
> +
> +	} else {
> +		if (stats.jiffies_init != jiffies)
> +			can_init_stats();
> +
> +		len += snprintf(page + len, PAGE_SIZE - len,
> +				"Performed statistic reset #%ld.\n",
> +				pstats.stats_reset);
> +	}
> +
> +	*eof = 1;
> +	return len;
> +}
> +
> +static int can_proc_read_version(char *page, char **start, off_t off,
> +				 int count, int *eof, void *data)
> +{
> +	int len = 0;
> +
> +	len += snprintf(page + len, PAGE_SIZE - len, "%s\n",
> +			CAN_VERSION_STRING);
> +	*eof = 1;
> +	return len;
> +}
> +
> +static int can_proc_read_rcvlist(char *page, char **start, off_t off,
> +				 int count, int *eof, void *data)
> +{
> +	/* double cast to prevent GCC warning */
> +	int idx = (int)(long)data;
> +	int len = 0;
> +	struct dev_rcv_lists *d;
> +	struct hlist_node *n;
> +
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			"\nreceive list '%s':\n", rx_list_name[idx]);
> +
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(d, n, &rx_dev_list, list) {
> +
> +		if (!hlist_empty(&d->rx[idx])) {
> +			len = can_print_recv_banner(page, len);
> +			len = can_print_rcvlist(page, len, &d->rx[idx], d->dev);
> +		} else
> +			len += snprintf(page + len, PAGE_SIZE - len,
> +					"  (%s: no entry)\n", DNAME(d->dev));
> +
> +		/* exit on end of buffer? */
> +		if (len > PAGE_SIZE - 100)
> +			break;
> +	}
> +	rcu_read_unlock();
> +
> +	len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +
> +	*eof = 1;
> +	return len;
> +}
> +
> +static int can_proc_read_rcvlist_sff(char *page, char **start, off_t off,
> +				     int count, int *eof, void *data)
> +{
> +	int len = 0;
> +	struct dev_rcv_lists *d;
> +	struct hlist_node *n;
> +
> +	/* RX_SFF */
> +	len += snprintf(page + len, PAGE_SIZE - len,
> +			"\nreceive list 'rx_sff':\n");
> +
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(d, n, &rx_dev_list, list) {
> +		int i, all_empty = 1;
> +		/* check wether at least one list is non-empty */
> +		for (i = 0; i < 0x800; i++)
> +			if (!hlist_empty(&d->rx_sff[i])) {
> +				all_empty = 0;
> +				break;
> +			}
> +
> +		if (!all_empty) {
> +			len = can_print_recv_banner(page, len);
> +			for (i = 0; i < 0x800; i++) {
> +				if (!hlist_empty(&d->rx_sff[i]) &&
> +				    len < PAGE_SIZE - 100)
> +					len = can_print_rcvlist(page, len,
> +								&d->rx_sff[i],
> +								d->dev);
> +			}
> +		} else
> +			len += snprintf(page + len, PAGE_SIZE - len,
> +					"  (%s: no entry)\n", DNAME(d->dev));
> +
> +		/* exit on end of buffer? */
> +		if (len > PAGE_SIZE - 100)
> +			break;
> +	}
> +	rcu_read_unlock();
> +
> +	len += snprintf(page + len, PAGE_SIZE - len, "\n");
> +
> +	*eof = 1;
> +	return len;
> +}
> +
> +/*
> + * proc utility functions
> + */
> +
> +static struct proc_dir_entry *can_create_proc_readentry(const char *name,
> +							mode_t mode,
> +							read_proc_t *read_proc,
> +							void *data)
> +{
> +	if (can_dir)
> +		return create_proc_read_entry(name, mode, can_dir, read_proc,
> +					      data);
> +	else
> +		return NULL;
> +}
> +
> +static void can_remove_proc_readentry(const char *name)
> +{
> +	if (can_dir)
> +		remove_proc_entry(name, can_dir);
> +}
> +
> +/*
> + * can_init_proc - create main CAN proc directory and procfs entries
> + */
> +void can_init_proc(void)
> +{
> +	/* create /proc/net/can directory */
> +	can_dir = proc_mkdir("can", init_net.proc_net);
> +
> +	if (!can_dir) {
> +		printk(KERN_INFO "can: failed to create /proc/net/can . "
> +		       "CONFIG_PROC_FS missing?\n");
> +		return;
> +	}
> +
> +	can_dir->owner = THIS_MODULE;
> +
> +	/* own procfs entries from the AF_CAN core */
> +	pde_version     = can_create_proc_readentry(CAN_PROC_VERSION, 0644,
> +					can_proc_read_version, NULL);
> +	pde_stats       = can_create_proc_readentry(CAN_PROC_STATS, 0644,
> +					can_proc_read_stats, NULL);
> +	pde_reset_stats = can_create_proc_readentry(CAN_PROC_RESET_STATS, 0644,
> +					can_proc_read_reset_stats, NULL);
> +	pde_rcvlist_err = can_create_proc_readentry(CAN_PROC_RCVLIST_ERR, 0644,
> +					can_proc_read_rcvlist, (void *)RX_ERR);
> +	pde_rcvlist_all = can_create_proc_readentry(CAN_PROC_RCVLIST_ALL, 0644,
> +					can_proc_read_rcvlist, (void *)RX_ALL);
> +	pde_rcvlist_fil = can_create_proc_readentry(CAN_PROC_RCVLIST_FIL, 0644,
> +					can_proc_read_rcvlist, (void *)RX_FIL);
> +	pde_rcvlist_inv = can_create_proc_readentry(CAN_PROC_RCVLIST_INV, 0644,
> +					can_proc_read_rcvlist, (void *)RX_INV);
> +	pde_rcvlist_eff = can_create_proc_readentry(CAN_PROC_RCVLIST_EFF, 0644,
> +					can_proc_read_rcvlist, (void *)RX_EFF);
> +	pde_rcvlist_sff = can_create_proc_readentry(CAN_PROC_RCVLIST_SFF, 0644,
> +					can_proc_read_rcvlist_sff, NULL);
> +}
> +
> +/*
> + * can_remove_proc - remove procfs entries and main CAN proc directory
> + */
> +void can_remove_proc(void)
> +{
> +	if (pde_version)
> +		can_remove_proc_readentry(CAN_PROC_VERSION);
> +
> +	if (pde_stats)
> +		can_remove_proc_readentry(CAN_PROC_STATS);
> +
> +	if (pde_reset_stats)
> +		can_remove_proc_readentry(CAN_PROC_RESET_STATS);
> +
> +	if (pde_rcvlist_err)
> +		can_remove_proc_readentry(CAN_PROC_RCVLIST_ERR);
> +
> +	if (pde_rcvlist_all)
> +		can_remove_proc_readentry(CAN_PROC_RCVLIST_ALL);
> +
> +	if (pde_rcvlist_fil)
> +		can_remove_proc_readentry(CAN_PROC_RCVLIST_FIL);
> +
> +	if (pde_rcvlist_inv)
> +		can_remove_proc_readentry(CAN_PROC_RCVLIST_INV);
> +
> +	if (pde_rcvlist_eff)
> +		can_remove_proc_readentry(CAN_PROC_RCVLIST_EFF);
> +
> +	if (pde_rcvlist_sff)
> +		can_remove_proc_readentry(CAN_PROC_RCVLIST_SFF);
> +
> +	if (can_dir)
> +		proc_net_remove(&init_net, "can");
> +}
> Index: net-2.6.24/include/linux/can/error.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ net-2.6.24/include/linux/can/error.h	2007-09-17 10:27:09.000000000 +0200
> @@ -0,0 +1,93 @@
> +/*
> + * linux/can/error.h
> + *
> + * Definitions of the CAN error frame to be filtered and passed to the user.
> + *
> + * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Send feedback to <socketcan-users@lists.berlios.de>
> + *
> + */
> +
> +#ifndef CAN_ERROR_H
> +#define CAN_ERROR_H
> +
> +#define CAN_ERR_DLC 8 /* dlc for error frames */
> +
> +/* error class (mask) in can_id */
> +#define CAN_ERR_TX_TIMEOUT   0x00000001U /* TX timeout (by netdevice driver) */
> +#define CAN_ERR_LOSTARB      0x00000002U /* lost arbitration    / data[0]    */
> +#define CAN_ERR_CRTL         0x00000004U /* controller problems / data[1]    */
> +#define CAN_ERR_PROT         0x00000008U /* protocol violations / data[2..3] */
> +#define CAN_ERR_TRX          0x00000010U /* transceiver status  / data[4]    */
> +#define CAN_ERR_ACK          0x00000020U /* received no ACK on transmission */
> +#define CAN_ERR_BUSOFF       0x00000040U /* bus off */
> +#define CAN_ERR_BUSERROR     0x00000080U /* bus error (may flood!) */
> +#define CAN_ERR_RESTARTED    0x00000100U /* controller restarted */
> +
> +/* arbitration lost in bit ... / data[0] */
> +#define CAN_ERR_LOSTARB_UNSPEC   0x00 /* unspecified */
> +				      /* else bit number in bitstream */
> +
> +/* error status of CAN-controller / data[1] */
> +#define CAN_ERR_CRTL_UNSPEC      0x00 /* unspecified */
> +#define CAN_ERR_CRTL_RX_OVERFLOW 0x01 /* RX buffer overflow */
> +#define CAN_ERR_CRTL_TX_OVERFLOW 0x02 /* TX buffer overflow */
> +#define CAN_ERR_CRTL_RX_WARNING  0x04 /* reached warning level for RX errors */
> +#define CAN_ERR_CRTL_TX_WARNING  0x08 /* reached warning level for TX errors */
> +#define CAN_ERR_CRTL_RX_PASSIVE  0x10 /* reached error passive status RX */
> +#define CAN_ERR_CRTL_TX_PASSIVE  0x20 /* reached error passive status TX */
> +				      /* (at least one error counter exceeds */
> +				      /* the protocol-defined level of 127)  */
> +
> +/* error in CAN protocol (type) / data[2] */
> +#define CAN_ERR_PROT_UNSPEC      0x00 /* unspecified */
> +#define CAN_ERR_PROT_BIT         0x01 /* single bit error */
> +#define CAN_ERR_PROT_FORM        0x02 /* frame format error */
> +#define CAN_ERR_PROT_STUFF       0x04 /* bit stuffing error */
> +#define CAN_ERR_PROT_BIT0        0x08 /* unable to send dominant bit */
> +#define CAN_ERR_PROT_BIT1        0x10 /* unable to send recessive bit */
> +#define CAN_ERR_PROT_OVERLOAD    0x20 /* bus overload */
> +#define CAN_ERR_PROT_ACTIVE      0x40 /* active error announcement */
> +#define CAN_ERR_PROT_TX          0x80 /* error occured on transmission */
> +
> +/* error in CAN protocol (location) / data[3] */
> +#define CAN_ERR_PROT_LOC_UNSPEC  0x00 /* unspecified */
> +#define CAN_ERR_PROT_LOC_SOF     0x03 /* start of frame */
> +#define CAN_ERR_PROT_LOC_ID28_21 0x02 /* ID bits 28 - 21 (SFF: 10 - 3) */
> +#define CAN_ERR_PROT_LOC_ID20_18 0x06 /* ID bits 20 - 18 (SFF: 2 - 0 )*/
> +#define CAN_ERR_PROT_LOC_SRTR    0x04 /* substitute RTR (SFF: RTR) */
> +#define CAN_ERR_PROT_LOC_IDE     0x05 /* identifier extension */
> +#define CAN_ERR_PROT_LOC_ID17_13 0x07 /* ID bits 17-13 */
> +#define CAN_ERR_PROT_LOC_ID12_05 0x0F /* ID bits 12-5 */
> +#define CAN_ERR_PROT_LOC_ID04_00 0x0E /* ID bits 4-0 */
> +#define CAN_ERR_PROT_LOC_RTR     0x0C /* RTR */
> +#define CAN_ERR_PROT_LOC_RES1    0x0D /* reserved bit 1 */
> +#define CAN_ERR_PROT_LOC_RES0    0x09 /* reserved bit 0 */
> +#define CAN_ERR_PROT_LOC_DLC     0x0B /* data length code */
> +#define CAN_ERR_PROT_LOC_DATA    0x0A /* data section */
> +#define CAN_ERR_PROT_LOC_CRC_SEQ 0x08 /* CRC sequence */
> +#define CAN_ERR_PROT_LOC_CRC_DEL 0x18 /* CRC delimiter */
> +#define CAN_ERR_PROT_LOC_ACK     0x19 /* ACK slot */
> +#define CAN_ERR_PROT_LOC_ACK_DEL 0x1B /* ACK delimiter */
> +#define CAN_ERR_PROT_LOC_EOF     0x1A /* end of frame */
> +#define CAN_ERR_PROT_LOC_INTERM  0x12 /* intermission */
> +
> +/* error status of CAN-transceiver / data[4] */
> +/*                                             CANH CANL */
> +#define CAN_ERR_TRX_UNSPEC             0x00 /* 0000 0000 */
> +#define CAN_ERR_TRX_CANH_NO_WIRE       0x04 /* 0000 0100 */
> +#define CAN_ERR_TRX_CANH_SHORT_TO_BAT  0x05 /* 0000 0101 */
> +#define CAN_ERR_TRX_CANH_SHORT_TO_VCC  0x06 /* 0000 0110 */
> +#define CAN_ERR_TRX_CANH_SHORT_TO_GND  0x07 /* 0000 0111 */
> +#define CAN_ERR_TRX_CANL_NO_WIRE       0x40 /* 0100 0000 */
> +#define CAN_ERR_TRX_CANL_SHORT_TO_BAT  0x50 /* 0101 0000 */
> +#define CAN_ERR_TRX_CANL_SHORT_TO_VCC  0x60 /* 0110 0000 */
> +#define CAN_ERR_TRX_CANL_SHORT_TO_GND  0x70 /* 0111 0000 */
> +#define CAN_ERR_TRX_CANL_SHORT_TO_CANH 0x80 /* 1000 0000 */
> +
> +/* controller specific additional information / data[5..7] */
> +
> +#endif /* CAN_ERROR_H */
> 
> --
> 


