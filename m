From: jamal <hadi@cyberus.ca>
Subject: Re: patch: tunnels not setting inputdev
Date: 03 Jan 2005 09:46:18 -0500
Message-ID: <1104763578.1047.553.camel@jzny.localdomain>
References: <1104513392.1048.316.camel@jzny.localdomain>
	 <41D5941C.8060001@trash.net> <1104523892.1047.338.camel@jzny.localdomain>
	 <41D6CB87.8040205@trash.net> <1104622406.1049.450.camel@jzny.localdomain>
	 <41D73F28.3090206@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fHTulGJembddNxbTRWt5"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Wichert Akkerman <wichert@wiggy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D73F28.3090206@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-fHTulGJembddNxbTRWt5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 2005-01-01 at 19:24, Patrick McHardy wrote:
> jamal wrote:
> > I want to understand the repurcasssions instead of blindly setting. Let
> > users complain, thats why the printk exists. For example what does
> > input_dev mean for netbios or a 802.3ad interface? You already saw one,
> > xfrm, where there was no need to reset.
> 
> What's special about netbios ? For 802.3ad, I would expect input_dev
> to hold the virtual device through which the packet entered the stack,
> just what iptables -i would match. For xfrm - there is no need but its
> also not wrong.

This is exactly why i am not just setting things arbitraliy at input.
Different _types_ of devices that need different _types_
of treatment (with dependency of where they are in the path as well).
Tunnels are not the same as ethernet are not the same as atm devices are
not the same as ppp-based devices. Heck some of these things dont even
use netdevices. 
Note, one could claim that if you remove the printk there is already
a central place to set things. However, I need to know when people use
this path what the circumstances are - at some point we will get rid of
the printk. At some point it may be you are right, lets just put it all
in one spot - but for now just leave it as is. 
 
> > in some cases the pointers are swapped. You cant just blindly
> > set skb->input_dev = skb->dev at the input - that would be violating the
> > intent; think reinjecting packets (and look at mirred as a sample of
> > apps to come that do this).
> 
> I don't know your intent, but I assumed it was to match the incoming
> interface as the networking stack sees it. Why would the pointers be
> swapped ? Please give me an example. mirred does:
> 
>          skb2->dev = dev;
>          skb2->input_dev = skb->dev;
>
> So on input input_dev is the incoming interface of the original packet,
> on output it is the outgoing interface of the original packet. Doesn't
> make much sense to me, the original packet came the same way both times.

The current mirred does only egress redirection - it doesnt do ingress
redirection, nor socket redirection yet. The TODO list in the file says
it will at some point. I have some code - but its not clean enough to
include - those for example will matter in this case. I dont want to 
rule it out to be specific just for those few apps i have.
The architecture allows arbitrary  loops between arbitrary number of
actions and netdevices in a policy topology. The input could appear more
than once in such a topology at arbitrary points.

I am attaching an old version of the dummy device, which i am hoping to 
propose as a replacement for IMQ at some point; its has an example of
such usage. I havent really added any hooks for contracking action in
the path in which dummy is to be found etc, but I hope it helps make my
point. At some point i will document all the features.

An example policy:
on eth0: match filter at ingress/egress then
action mirred egress redirect dev dummy0.
dummy0 reinjects at ingress/egress.
More complex: on dummy0 add more interesting rules to do further
redirection.

cheers,
jamal

--=-fHTulGJembddNxbTRWt5
Content-Disposition: attachment; filename=dummy.c
Content-Type: text/x-c; name=dummy.c; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

/* dummy.c: a dummy net driver

	The purpose of this driver is to provide a device to point a
	route through, but not to actually transmit packets.

	Why?  If you have a machine whose only connection is an occasional
	PPP/SLIP/PLIP link, you can only connect to your own hostname
	when the link is up.  Otherwise you have to use localhost.
	This isn't very consistent.

	One solution is to set up a dummy link using PPP/SLIP/PLIP,
	but this seems (to me) too much overhead for too little gain.
	This driver provides a small alternative. Thus you can do
	
	[when not running slip]
		ifconfig dummy slip.addr.ess.here up
	[to go to slip]
		ifconfig dummy down
		dip whatever

	This was written by looking at Donald Becker's skeleton driver
	and the loopback driver.  I then threw away anything that didn't
	apply!	Thanks to Alan Cox for the key clue on what to do with
	misguided packets.

			Nick Holloway, 27th May 1994
	[I tweaked this explanation a little but that's all]
			Alan Cox, 30th May 1994

*/
/*
	* This driver isnt abused enough ;->
	* Here to add only a _feeew more_ features,
	* 10 years after AC added comment above ;-> hehe - JHS
*/


#include <linux/config.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/init.h>
#include <linux/moduleparam.h>
#ifdef CONFIG_NET_CLS_ACT
#include <net/pkt_sched.h>
#endif

#define TX_TIMEOUT  (2*HZ)
                                                                                
#define TX_Q_LIMIT    32
struct dummy_private {
	struct net_device_stats stats;
#ifdef CONFIG_NET_CLS_ACT
	struct tasklet_struct   dummy_tasklet;
	int     tasklet_pending;
	/* mostly debug stats leave in for now */
	unsigned long   stat_r1;
	unsigned long   stat_r2;
	unsigned long   stat_r3;
	unsigned long   stat_r4;
	unsigned long   stat_r5;
	unsigned long   stat_r6;
	unsigned long   stat_r7;
	unsigned long   stat_r8;
	struct sk_buff_head     rq;
	struct sk_buff_head     tq;
#endif
};

#ifdef CONFIG_NET_CLS_ACT
static void ri_tasklet(unsigned long dev);
#endif


static int numdummies = 1;

static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
static struct net_device_stats *dummy_get_stats(struct net_device *dev);
static void dummy_timeout(struct net_device *dev);
static int dummy_open(struct net_device *dev);
static int dummy_close(struct net_device *dev);

static void dummy_timeout(struct net_device *dev) {

	int cpu = smp_processor_id();

	dev->trans_start = jiffies;
	printk("%s: BUG tx timeout on CPU %d\n",dev->name,cpu);
	if (spin_is_locked((&dev->xmit_lock)))
		printk("xmit lock grabbed already\n");
	if (spin_is_locked((&dev->queue_lock)))
		printk("queue lock grabbed already\n");
}

#ifdef CONFIG_NET_CLS_ACT
static void ri_tasklet(unsigned long dev) {

	struct net_device *dv = (struct net_device *)dev;
	struct dummy_private *dp = ((struct net_device *)dev)->priv;
	struct net_device_stats *stats = &dp->stats;
	struct sk_buff *skb = NULL;

	dp->stat_r4 +=1;
	if (NULL == (skb = skb_peek(&dp->tq))) {
		dp->stat_r5 +=1;
		if (spin_trylock(&dv->xmit_lock)) {
			dp->stat_r8 +=1;
			while (NULL != (skb = skb_dequeue(&dp->rq))) {
				skb_queue_tail(&dp->tq, skb);
			}
			spin_unlock(&dv->xmit_lock);
		} else {
	/* reschedule */
			dp->stat_r1 +=1;
			goto resched;
		}
	}

	while (NULL != (skb = skb_dequeue(&dp->tq))) {
		__u32 from = G_TC_FROM(skb->tc_verd);

		skb->tc_verd = 0;
		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
		stats->tx_packets++;
		stats->tx_bytes+=skb->len;
		if (from & AT_EGRESS) {
			dp->stat_r6 +=1;
			dev_queue_xmit(skb);
		} else if (from & AT_INGRESS) {
			dp->stat_r7 +=1;
			netif_rx(skb);
		} else {
			/* if netfilt is compiled in and packet is
			tagged, we could reinject the packet back
			this would make it do what current IMQ does
			+ more; if someone really really insists then
			this is the spot .. jhs */
			dev_kfree_skb(skb);
			stats->tx_dropped++;
		}
	}

	if (spin_trylock(&dv->xmit_lock)) {
		dp->stat_r3 +=1;
		if (NULL == (skb = skb_peek(&dp->rq))) {
			dp->tasklet_pending = 0;
		if (netif_queue_stopped(dv))
			netif_start_queue(dv);
		} else {
			dp->stat_r2 +=1;
			spin_unlock(&dv->xmit_lock);
			goto resched;
		}
		spin_unlock(&dv->xmit_lock);
		} else {
resched:
			dp->tasklet_pending = 1;
			tasklet_schedule(&dp->dummy_tasklet);
		}

}
#endif


static int dummy_set_address(struct net_device *dev, void *p)
{
	struct sockaddr *sa = p;

	if (!is_valid_ether_addr(sa->sa_data)) 
		return -EADDRNOTAVAIL;
		
	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
	return 0;
}

/* fake multicast ability */
static void set_multicast_list(struct net_device *dev)
{
}

#ifdef CONFIG_NET_FASTROUTE
static int dummy_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
{
	return -1;
}
#endif

static void __init dummy_setup(struct net_device *dev)
{
	/* Initialize the device structure. */
	dev->get_stats = dummy_get_stats;
	dev->hard_start_xmit = dummy_xmit;
	dev->tx_timeout = &dummy_timeout;
	dev->watchdog_timeo = TX_TIMEOUT;
	dev->open = &dummy_open;
	dev->stop = &dummy_close;

	dev->set_multicast_list = set_multicast_list;
	dev->set_mac_address = dummy_set_address;
#ifdef CONFIG_NET_FASTROUTE
	dev->accept_fastpath = dummy_accept_fastpath;
#endif

	/* Fill in device structure with ethernet-generic values. */
	ether_setup(dev);
	dev->tx_queue_len = TX_Q_LIMIT;
	dev->flags |= IFF_NOARP;
	dev->flags &= ~IFF_MULTICAST;
	SET_MODULE_OWNER(dev);
	random_ether_addr(dev->dev_addr);
}

static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
{
	struct dummy_private *dp = ((struct net_device *)dev)->priv;
	struct net_device_stats *stats = &dp->stats;
#ifdef CONFIG_NET_CLS_ACT
	__u32 from = G_TC_FROM(skb->tc_verd);
#endif
	int ret = 0;

	stats->rx_packets++;
	stats->rx_bytes+=skb->len;
#ifdef CONFIG_NET_CLS_ACT
	if ( !from || !skb->input_dev ) {
dropped:
		dev_kfree_skb(skb);
		stats->rx_dropped++;
		return ret;
	} else {
		if (skb->input_dev)
			skb->dev = skb->input_dev;
		else
			printk("warning!!! no idev %s\n",skb->dev->name);

		skb->input_dev = dev;
		if (from & AT_INGRESS) {
			skb_pull(skb,  skb->dev->hard_header_len);
		} else {
			if (!(from & AT_EGRESS)) {
				goto dropped;
			}
		}
	}
	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len) {
		netif_stop_queue(dev);
	}

	dev->trans_start = jiffies;
	skb_queue_tail(&dp->rq, skb);
	if (!dp->tasklet_pending) {
		dp->tasklet_pending = 1;
		tasklet_schedule(&dp->dummy_tasklet);
	}
#else
	dev_kfree_skb(skb);
#endif

	return ret;
}

static struct net_device_stats *dummy_get_stats(struct net_device *dev)
{
	struct dummy_private *dp = ((struct net_device *)dev)->priv;
	struct net_device_stats *stats = &dp->stats;
#ifdef CONFIG_NET_CLS_ACT_DEB
	printk("tasklets stats %ld:%ld:%ld:%ld:%ld:%ld:%ld:%ld \n",
		dp->stat_r1,dp->stat_r2,dp->stat_r3,dp->stat_r4,
		dp->stat_r5,dp->stat_r6,dp->stat_r7,dp->stat_r8);
#endif
	return stats;
}

static struct net_device **dummies;

/* Number of dummy devices to be set up by this module. */
module_param(numdummies, int, 0);
MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");

static int dummy_close(struct net_device *dev)
{

#ifdef CONFIG_NET_CLS_ACT
	struct dummy_private *dp = ((struct net_device *)dev)->priv;

	tasklet_kill(&dp->dummy_tasklet);
	skb_queue_purge(&dp->rq);
	skb_queue_purge(&dp->tq);
#endif
	netif_stop_queue(dev);
	return 0;
}

static int dummy_open(struct net_device *dev)
{

#ifdef CONFIG_NET_CLS_ACT
	struct dummy_private *dp = ((struct net_device *)dev)->priv;

	tasklet_init(&dp->dummy_tasklet, ri_tasklet, (unsigned long)dev);
	skb_queue_head_init(&dp->rq);
	skb_queue_head_init(&dp->tq);
	#endif
	netif_start_queue(dev);
	return 0;
}


static int __init dummy_init_one(int index)
{
	struct net_device *dev_dummy;
	int err;

	dev_dummy = alloc_netdev(sizeof(struct dummy_private),
				 "dummy%d", dummy_setup);

	if (!dev_dummy)
		return -ENOMEM;

	if ((err = register_netdev(dev_dummy))) {
		free_netdev(dev_dummy);
		dev_dummy = NULL;
	} else {
		dummies[index] = dev_dummy; 
	}

	return err;
}

static void dummy_free_one(int index)
{
	unregister_netdev(dummies[index]);
	free_netdev(dummies[index]);
} 

static int __init dummy_init_module(void)
{ 
	int i, err = 0;
	dummies = kmalloc(numdummies * sizeof(void *), GFP_KERNEL); 
	if (!dummies)
		return -ENOMEM; 
	for (i = 0; i < numdummies && !err; i++)
		err = dummy_init_one(i); 
	if (err) { 
		while (--i >= 0)
			dummy_free_one(i);
	}
	return err;
} 

static void __exit dummy_cleanup_module(void)
{
	int i;
	for (i = 0; i < numdummies; i++) 
		dummy_free_one(i); 
	kfree(dummies);	
}

module_init(dummy_init_module);
module_exit(dummy_cleanup_module);
MODULE_LICENSE("GPL");

--=-fHTulGJembddNxbTRWt5--
