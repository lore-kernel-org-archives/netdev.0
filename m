From: Andre Correa <andre.correa@pobox.com>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 14:27:03 -0200
Message-ID: <41FE5C57.2020201@pobox.com>
References: <1107123123.8021.80.camel@jzny.localdomain>
Reply-To: andre.correa@pobox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, andre.correa@pobox.com,
        Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1107123123.8021.80.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi all,

it turned an year since we (me and some cool folks) got the original IMQ 
from "death". During this year we updated kernel and iptables patches 
for every available version, created some new features (like hooking 
after and before NAT, multiple IMQ devices, solved modules problems, 
etc), and helped lots of users in our mailling list. The wish list grew, 
we created a site/FAQ/WiKi. We are still missing "dumb device" 
functionality. Our site is www.linuximq.net

Complicated or not, clean or not, its being working in some interresting 
scenarios with lots of load on it. I feel fine for being able to help 
the community somehow with it. Found no time yet to check Jamal's new 
patches but we would use dummy as the base for "real device" 
functionality development.

At least its nice to find we are discussing how to do it, not anymore if 
IMQ functionality is needed, cause it really is.

Going one way or another we should not let users alone again with nobody 
taking care of this like it happened before. I plan keeping IMQ updated 
with new kernel versions as usual.

Jamal, when you say "to replace" you mean it may get into vanila kernel? 
Do you plan keeping it updated from now on?

Either way, can we call this new thing something else, because actual 
users may not want to migrate, so both should work together. A user 
should be able to patch a kernel with both.

We (at linuximq.net) would be more then happy to help with it.

Andre



Jamal Hadi Salim wrote:
> This is in relation to providing functionality that IMQ was intending
> to using the dummy device and tc actions. Ive copied as many people as i
> could dig who i know may have interest in this.
> Please forward this to any other list which may have interest
> in the subject. It still needs some cleaning up; however, i dont wanna
> sit on it for another year - and now that mirred is out there, this is a
> good time.
> 
> Advantage over current IMQ; cleaner in particular in in SMP;
> with a _lot_ less code.
> Old Dummy device functionality is preserved while new one only
> kicks in if you use actions. Didnt have to write a new device and finaly
> made a real dumb device to be a little smarter ;->
> 
> IMQ USES
> --------
> As far as i know the reasons listed below is why people use IMQ. 
> It would be nice to know of anything else that i missed because this
> is the requirements list i used.
> 
> 1) qdiscs/policies that are per device as opposed to system wide.
> IMQ allows for sharing across multiple devices.
> 
> 2) Allows for queueing incoming traffic for shaping instead of
> dropping. I am not aware of any study that shows policing is 
> worse than shaping in achieving the end goal of rate control.
> I would be interested if anyone is experimenting. Nevertheless,
> this is still an alternative as opposed to making a system wide
> ingress change.
> 
> 3) Very interesting use: if you are serving p2p you may wanna give 
> preference to your own localy originated traffic (when responses come
> back) vs someone using your system to do bittorent. So QoSing based on
> state comes in as the solution. What people did to achive this was stick
> the IMQ somewhere prelocal hook.
> I think this is a pretty neat feature to have in Linux in general.
> (i.e not just for IMQ).
> But i wont go back to putting netfilter hooks in the device to satisfy
> this.  I also dont think its worth it hacking dummy some more to be 
> aware of say L3 info and play ip rule tricks to achieve this.
> --> Instead the plan is to have a contrack related action. This action
> will selectively either query/create contrack state on incoming packets.
> Packets could then be redirected to dummy based on what happens -> eg 
> on incoming packets; if we find they are of known state we could send to
> a different queue than one which didnt have existing state. This
> all however is dependent on whatever rules the admin enters.
> 
> What you can do with dummy currently with actions
> --------------------------------------------------
> 
> Lets say you are policing packets from alias 192.168.200.200/32
> you dont want those to exceed 100kbps going out.
> 
> tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
> match ip src 192.168.200.200/32 flowid 1:2 \
> action police rate 100kbit burst 90k drop
> 
> If you run tcpdump on eth0 you will see all packets going out
> with src 192.168.200.200/32 dropped or not
> Extend the rule a little to see only the ones that made it out:
> 
> tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
> match ip src 192.168.200.200/32 flowid 1:2 \
> action police rate 10kbit burst 90k drop \
> action mirred egress mirror dev dummy0 
> 
> Now fire tcpdump on dummy0 to see only those packets ..
> tcpdump -n -i dummy0 -x -e -t 
> 
> Essentially a good debugging/logging interface.
> 
> If you replace mirror with redirect, those packets will be
> blackholed and will never make it out. This redirect behavior
> changes with new patch (but not the mirror). 
> 
> 
> What you can do with dummy and attached patch
> ----------------------------------------------
> 
> Essentially provide functionality that most people use IMQ;
> sample below:
> 
> --------
> export TC="/sbin/tc"
> 
> $TC qdisc add dev dummy0 root handle 1: prio 
> $TC qdisc add dev dummy0 parent 1:1 handle 10: sfq
> $TC qdisc add dev dummy0 parent 1:2 handle 20: tbf rate 20kbit buffer
> 1600 limit 3000
> $TC qdisc add dev dummy0 parent 1:3 handle 30:
> sfq                                
> $TC filter add dev dummy0 protocol ip pref 1 parent 1: handle 1 fw
> classid 1:1
> $TC filter add dev dummy0 protocol ip pref 2 parent 1: handle 2 fw
> classid 1:2
> 
> ifconfig dummy0 up
> 
> $TC qdisc add dev eth0 ingress
> 
> # redirect all IP packets arriving in eth0 to dummy0 
> # use mark 1 --> puts them onto class 1:1
> $TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
> match u32 0 0 flowid 1:1 \
> action ipt -j MARK --set-mark 1 \
> action mirred egress redirect dev dummy0
> 
> --------
> 
> 
> Run A Little test:
> 
> from another machine ping so that you have packets going into the box:
> -----
> [root@jzny action-tests]# ping 10.22
> PING 10.22 (10.0.0.22): 56 data bytes
> 64 bytes from 10.0.0.22: icmp_seq=0 ttl=64 time=2.8 ms
> 64 bytes from 10.0.0.22: icmp_seq=1 ttl=64 time=0.6 ms
> 64 bytes from 10.0.0.22: icmp_seq=2 ttl=64 time=0.6 ms
> 
> --- 10.22 ping statistics ---
> 3 packets transmitted, 3 packets received, 0% packet loss
> round-trip min/avg/max = 0.6/1.3/2.8 ms
> [root@jzny action-tests]# 
> -----
> Now look at some stats:
> 
> ---
> [root@jmandrake]:~# $TC -s filter show parent ffff: dev eth0
> filter protocol ip pref 10 u32 
> filter protocol ip pref 10 u32 fh 800: ht divisor 1 
> filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0
> flowid 1:1 
>   match 00000000/00000000 at 0
>         action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING 
>         target MARK set 0x1  
>         index 1 ref 1 bind 1 installed 4195sec  used 27sec 
>          Sent 252 bytes 3 pkts (dropped 0, overlimits 0) 
> 
>         action order 2: mirred (Egress Redirect to device dummy0) stolen
>         index 1 ref 1 bind 1 installed 165 sec used 27 sec
>          Sent 252 bytes 3 pkts (dropped 0, overlimits 0) 
> 
> [root@jmandrake]:~# $TC -s qdisc
> qdisc sfq 30: dev dummy0 limit 128p quantum 1514b 
>  Sent 0 bytes 0 pkts (dropped 0, overlimits 0) 
> qdisc tbf 20: dev dummy0 rate 20Kbit burst 1575b lat 2147.5s 
>  Sent 210 bytes 3 pkts (dropped 0, overlimits 0) 
> qdisc sfq 10: dev dummy0 limit 128p quantum 1514b 
>  Sent 294 bytes 3 pkts (dropped 0, overlimits 0) 
> qdisc prio 1: dev dummy0 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1
> 1
>  Sent 504 bytes 6 pkts (dropped 0, overlimits 0) 
> qdisc ingress ffff: dev eth0 ---------------- 
>  Sent 308 bytes 5 pkts (dropped 0, overlimits 0) 
> 
> [root@jmandrake]:~# ifconfig dummy0
> dummy0    Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
>           inet6 addr: fe80::200:ff:fe00:0/64 Scope:Link
>           UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1
>           RX packets:6 errors:0 dropped:3 overruns:0 frame:0
>           TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:32 
>           RX bytes:504 (504.0 b)  TX bytes:252 (252.0 b)
> -----
> 
> Dummy continues to behave like it always did.
> You send it any packet not originating from the actions it will drop
> them.
> [In this case the three dropped packets were ipv6 ndisc].
> 
> My goal here is to start a discussion to see if people agree this is
> a good replacement for IMQ or whether to go another path.
> Clearly i would prefer to have this change in, but I am not religious 
> and would listen to reason about how it should be done as long as no 
> uneccessary clutter happens. 
> 
> Patch attached.
> 
> cheers,
> jamal
> 
> 
> 
> 
> 
> ------------------------------------------------------------------------
> 
> --- a/drivers/net/dummy.c.orig	2004-12-24 16:34:33.000000000 -0500
> +++ b/drivers/net/dummy.c	2005-01-18 06:43:47.000000000 -0500
> @@ -26,7 +26,14 @@
>  			Nick Holloway, 27th May 1994
>  	[I tweaked this explanation a little but that's all]
>  			Alan Cox, 30th May 1994
> +
>  */
> +/*
> +	* This driver isnt abused enough ;->
> +	* Here to add only _just_ a _feeew more_ features,
> +	* 10 years after AC added comment above ;-> hehe - JHS
> +*/
> +
>  
>  #include <linux/config.h>
>  #include <linux/module.h>
> @@ -35,11 +42,128 @@
>  #include <linux/etherdevice.h>
>  #include <linux/init.h>
>  #include <linux/moduleparam.h>
> +#ifdef CONFIG_NET_CLS_ACT
> +#include <net/pkt_sched.h> 
> +#endif
> +
> +#define TX_TIMEOUT  (2*HZ)
> +                                                                                
> +#define TX_Q_LIMIT    32
> +struct dummy_private {
> +	struct net_device_stats stats;
> +#ifdef CONFIG_NET_CLS_ACT
> +	struct tasklet_struct   dummy_tasklet;
> +	int     tasklet_pending;
> +	/* mostly debug stats leave in for now */
> +	unsigned long   stat_r1;
> +	unsigned long   stat_r2;
> +	unsigned long   stat_r3;
> +	unsigned long   stat_r4;
> +	unsigned long   stat_r5;
> +	unsigned long   stat_r6;
> +	unsigned long   stat_r7;
> +	unsigned long   stat_r8;
> +	struct sk_buff_head     rq;
> +	struct sk_buff_head     tq;
> +#endif
> +};
> +
> +#ifdef CONFIG_NET_CLS_ACT
> +static void ri_tasklet(unsigned long dev);
> +#endif
> +
>  
>  static int numdummies = 1;
>  
>  static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
>  static struct net_device_stats *dummy_get_stats(struct net_device *dev);
> +static void dummy_timeout(struct net_device *dev);
> +static int dummy_open(struct net_device *dev);
> +static int dummy_close(struct net_device *dev);
> +
> +static void dummy_timeout(struct net_device *dev) {
> +
> +	int cpu = smp_processor_id();
> +
> +	dev->trans_start = jiffies;
> +	printk("%s: BUG tx timeout on CPU %d\n",dev->name,cpu);
> +	if (spin_is_locked((&dev->xmit_lock)))
> +		printk("xmit lock grabbed already\n");
> +	if (spin_is_locked((&dev->queue_lock)))
> +		printk("queue lock grabbed already\n");
> +}
> +
> +#ifdef CONFIG_NET_CLS_ACT
> +static void ri_tasklet(unsigned long dev) {
> +
> +	struct net_device *dv = (struct net_device *)dev;
> +	struct dummy_private *dp = ((struct net_device *)dev)->priv;
> +	struct net_device_stats *stats = &dp->stats;
> +	struct sk_buff *skb = NULL;
> +
> +	dp->stat_r4 +=1;
> +	if (NULL == (skb = skb_peek(&dp->tq))) {
> +		dp->stat_r5 +=1;
> +		if (spin_trylock(&dv->xmit_lock)) {
> +			dp->stat_r8 +=1;
> +			while (NULL != (skb = skb_dequeue(&dp->rq))) {
> +				skb_queue_tail(&dp->tq, skb);
> +			}
> +			spin_unlock(&dv->xmit_lock);
> +		} else {
> +	/* reschedule */
> +			dp->stat_r1 +=1;
> +			goto resched;
> +		}
> +	}
> +
> +	while (NULL != (skb = skb_dequeue(&dp->tq))) {
> +		__u32 from = G_TC_FROM(skb->tc_verd);
> +
> +		skb->tc_verd = 0;
> +		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
> +		stats->tx_packets++;
> +		stats->tx_bytes+=skb->len;
> +		if (from & AT_EGRESS) {
> +			dp->stat_r6 +=1;
> +			dev_queue_xmit(skb);
> +		} else if (from & AT_INGRESS) {
> +
> +			dp->stat_r7 +=1;
> +			netif_rx(skb);
> +		} else {
> +			/* if netfilt is compiled in and packet is
> +			tagged, we could reinject the packet back
> +			this would make it do remaining 10%
> +			of what current IMQ does  
> +			if someone really really insists then
> +			this is the spot .. jhs */
> +			dev_kfree_skb(skb);
> +			stats->tx_dropped++;
> +		}
> +	}
> +
> +	if (spin_trylock(&dv->xmit_lock)) {
> +		dp->stat_r3 +=1;
> +		if (NULL == (skb = skb_peek(&dp->rq))) {
> +			dp->tasklet_pending = 0;
> +		if (netif_queue_stopped(dv))
> +			//netif_start_queue(dv);
> +			netif_wake_queue(dv);
> +		} else {
> +			dp->stat_r2 +=1;
> +			spin_unlock(&dv->xmit_lock);
> +			goto resched;
> +		}
> +		spin_unlock(&dv->xmit_lock);
> +		} else {
> +resched:
> +			dp->tasklet_pending = 1;
> +			tasklet_schedule(&dp->dummy_tasklet);
> +		}
> +
> +}
> +#endif
>  
>  static int dummy_set_address(struct net_device *dev, void *p)
>  {
> @@ -62,12 +186,17 @@
>  	/* Initialize the device structure. */
>  	dev->get_stats = dummy_get_stats;
>  	dev->hard_start_xmit = dummy_xmit;
> +	dev->tx_timeout = &dummy_timeout;
> +	dev->watchdog_timeo = TX_TIMEOUT;
> +	dev->open = &dummy_open;
> +	dev->stop = &dummy_close;
> +
>  	dev->set_multicast_list = set_multicast_list;
>  	dev->set_mac_address = dummy_set_address;
>  
>  	/* Fill in device structure with ethernet-generic values. */
>  	ether_setup(dev);
> -	dev->tx_queue_len = 0;
> +	dev->tx_queue_len = TX_Q_LIMIT;
>  	dev->change_mtu = NULL;
>  	dev->flags |= IFF_NOARP;
>  	dev->flags &= ~IFF_MULTICAST;
> @@ -77,18 +206,64 @@
>  
>  static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> -	struct net_device_stats *stats = netdev_priv(dev);
> +	struct dummy_private *dp = ((struct net_device *)dev)->priv;
> +	struct net_device_stats *stats = &dp->stats;
> +	int ret = 0;
>  
> +	{
>  	stats->tx_packets++;
>  	stats->tx_bytes+=skb->len;
> +	}
> +#ifdef CONFIG_NET_CLS_ACT
> +	__u32 from = G_TC_FROM(skb->tc_verd);
> +	if (!from || !skb->input_dev ) {
> +dropped:
> +		 dev_kfree_skb(skb);
> +		 stats->rx_dropped++;
> +		 return ret;
> +	} else {
> +		if (skb->input_dev)
> +			skb->dev = skb->input_dev;
> +		else
> +			printk("warning!!! no idev %s\n",skb->dev->name);
>  
> +		skb->input_dev = dev;
> +		if (from & AT_INGRESS) {
> +			skb_pull(skb, skb->dev->hard_header_len);
> +		} else {
> +			if (!(from & AT_EGRESS)) {
> +				goto dropped;
> +			}
> +		}
> +	}
> +	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len) {
> +		netif_stop_queue(dev);
> +	}
> +	dev->trans_start = jiffies;
> +	skb_queue_tail(&dp->rq, skb);
> +	if (!dp->tasklet_pending) {
> +		dp->tasklet_pending = 1;
> +		tasklet_schedule(&dp->dummy_tasklet);
> +	}
> +
> +#else
> +	stats->rx_dropped++;
>  	dev_kfree_skb(skb);
> -	return 0;
> +#endif
> +	return ret;
>  }
>  
>  static struct net_device_stats *dummy_get_stats(struct net_device *dev)
>  {
> -	return netdev_priv(dev);
> +	struct dummy_private *dp = ((struct net_device *)dev)->priv;
> +	struct net_device_stats *stats = &dp->stats;
> +#ifdef CONFIG_NET_CLS_ACT_DEB
> +	printk("tasklets stats %ld:%ld:%ld:%ld:%ld:%ld:%ld:%ld \n",
> +		dp->stat_r1,dp->stat_r2,dp->stat_r3,dp->stat_r4,
> +		dp->stat_r5,dp->stat_r6,dp->stat_r7,dp->stat_r8);
> +#endif
> +
> +	return stats;
>  }
>  
>  static struct net_device **dummies;
> @@ -97,12 +272,41 @@
>  module_param(numdummies, int, 0);
>  MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
>  
> +static int dummy_close(struct net_device *dev)
> +{
> +
> +#ifdef CONFIG_NET_CLS_ACT
> +	struct dummy_private *dp = ((struct net_device *)dev)->priv;
> +
> +	tasklet_kill(&dp->dummy_tasklet);
> +	skb_queue_purge(&dp->rq);
> +	skb_queue_purge(&dp->tq);
> +#endif
> +	netif_stop_queue(dev);
> +	return 0;
> +}
> +
> +static int dummy_open(struct net_device *dev)
> +{
> +
> +#ifdef CONFIG_NET_CLS_ACT
> +	struct dummy_private *dp = ((struct net_device *)dev)->priv;
> +
> +	tasklet_init(&dp->dummy_tasklet, ri_tasklet, (unsigned long)dev);
> +	skb_queue_head_init(&dp->rq);
> +	skb_queue_head_init(&dp->tq);
> +#endif
> +	netif_start_queue(dev);
> +	return 0;
> +}
> +
> +
>  static int __init dummy_init_one(int index)
>  {
>  	struct net_device *dev_dummy;
>  	int err;
>  
> -	dev_dummy = alloc_netdev(sizeof(struct net_device_stats),
> +	dev_dummy = alloc_netdev(sizeof(struct dummy_private),
>  				 "dummy%d", dummy_setup);
>  
>  	if (!dev_dummy)



-----------------------------------------------------------------------
Confidentiality Notice: This e-mail communication and any attachments 
may contain confidential and privileged information for the use of the 
designated recipients named above. If you are not the intended 
recipient, you are hereby notified that you have received this 
communication in error and that any review, disclosure, dissemination, 
distribution or copying of it or its contents is prohibited. If you have 
received this communication in error, please notify me immediately by 
replying to this message and deleting it from your computer.

Thank you.
