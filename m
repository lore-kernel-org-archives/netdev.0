From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] the scheduled shaper removal
Date: Tue, 1 Jan 2008 15:47:35 +0200
Message-ID: <20080101134735.GI2360@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:37059 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860AbYAANrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2008 08:47:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains the scheduled removal of the shaper driver.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 Documentation/feature-removal-schedule.txt |    9 
 Documentation/networking/00-INDEX          |    2 
 Documentation/networking/shaper.txt        |   48 -
 drivers/net/Kconfig                        |   17 
 drivers/net/Makefile                       |    1 
 drivers/net/shaper.c                       |  603 ---------------------
 include/linux/Kbuild                       |    1 
 include/linux/if_shaper.h                  |   51 -
 8 files changed, 732 deletions(-)

307a9184aa372b39b15d7ca941a1302dbd053049 
diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index a9b00f9..75e9c41 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -305,11 +305,2 @@ Who:	Thomas Gleixner <tglx@linutronix.de>
 ---------------------------
-
-What:	shaper network driver
-When:	January 2008
-Files:	drivers/net/shaper.c, include/linux/if_shaper.h
-Why:	This driver has been marked obsolete for many years.
-	It was only designed to work on lower speed links and has design
-	flaws that lead to machine crashes. The qdisc infrastructure in
-	2.4 or later kernels, provides richer features and is more robust.
-Who:	Stephen Hemminger <shemminger@linux-foundation.org>
 
diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 563e442..6196668 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -82,8 +82,6 @@ policy-routing.txt
 	- IP policy-based routing
 ray_cs.txt
 	- Raylink Wireless LAN card driver info.
-shaper.txt
-	- info on the module that can shape/limit transmitted traffic.
 sk98lin.txt
 	- Marvell Yukon Chipset / SysKonnect SK-98xx compliant Gigabit
 	  Ethernet Adapter family driver info
diff --git a/Documentation/networking/shaper.txt b/Documentation/networking/shaper.txt
deleted file mode 100644
index 6c4ebb6..0000000
--- a/Documentation/networking/shaper.txt
+++ /dev/null
@@ -1,48 +0,0 @@
-Traffic Shaper For Linux
-
-This is the current BETA release of the traffic shaper for Linux. It works
-within the following limits:
-
-o	Minimum shaping speed is currently about 9600 baud (it can only
-shape down to 1 byte per clock tick)
-
-o	Maximum is about 256K, it will go above this but get a bit blocky.
-
-o	If you ifconfig the master device that a shaper is attached to down
-then your machine will follow.
-
-o	The shaper must be a module.
-
-
-Setup:
-
-	A shaper device is configured using the shapeconfig program.
-Typically you will do something like this
-
-shapecfg attach shaper0 eth1
-shapecfg speed shaper0 64000
-ifconfig shaper0 myhost netmask 255.255.255.240 broadcast 1.2.3.4.255 up
-route add -net some.network netmask a.b.c.d dev shaper0
-
-The shaper should have the same IP address as the device it is attached to
-for normal use.
-
-Gotchas:
-
-	The shaper shapes transmitted traffic. It's rather impossible to
-shape received traffic except at the end (or a router) transmitting it.
-
-	Gated/routed/rwhod/mrouted all see the shaper as an additional device
-and will treat it as such unless patched. Note that for mrouted you can run
-mrouted tunnels via a traffic shaper to control bandwidth usage.
-
-	The shaper is device/route based. This makes it very easy to use
-with any setup BUT less flexible. You may need to use iproute2 to set up
-multiple route tables to get the flexibility.
-
-	There is no "borrowing" or "sharing" scheme. This is a simple
-traffic limiter. We implement Van Jacobson and Sally Floyd's CBQ
-architecture into Linux 2.2. This is the preferred solution. Shaper is
-for simple or back compatible setups.
-
-Alan
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..1a33b6d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3021,23 +3021,6 @@ config NET_FC
 	  adaptor below. You also should have said Y to "SCSI support" and
 	  "SCSI generic support".
 
-config SHAPER
-	tristate "Traffic Shaper (OBSOLETE)"
-	depends on EXPERIMENTAL
-	---help---
-	  The traffic shaper is a virtual network device that allows you to
-	  limit the rate of outgoing data flow over some other network device.
-	  The traffic that you want to slow down can then be routed through
-	  these virtual devices. See
-	  <file:Documentation/networking/shaper.txt> for more information.
-
-	  An alternative to this traffic shaper are traffic schedulers which
-	  you'll get if you say Y to "QoS and/or fair queuing" in
-	  "Networking options".
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called shaper.  If unsure, say N.
-
 config NETCONSOLE
 	tristate "Network console logging support (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0e5fde4..0d220be 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -92,7 +92,6 @@ obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_MAC8390) += mac8390.o
 obj-$(CONFIG_APNE) += apne.o 8390.o
 obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
-obj-$(CONFIG_SHAPER) += shaper.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_SMC9194) += smc9194.o
 obj-$(CONFIG_FEC) += fec.o
diff --git a/drivers/net/shaper.c b/drivers/net/shaper.c
deleted file mode 100644
index 228f650..0000000
--- a/drivers/net/shaper.c
+++ /dev/null
@@ -1,603 +0,0 @@
-/*
- *			Simple traffic shaper for Linux NET3.
- *
- *	(c) Copyright 1996 Alan Cox <alan@redhat.com>, All Rights Reserved.
- *				http://www.redhat.com
- *
- *	This program is free software; you can redistribute it and/or
- *	modify it under the terms of the GNU General Public License
- *	as published by the Free Software Foundation; either version
- *	2 of the License, or (at your option) any later version.
- *
- *	Neither Alan Cox nor CymruNet Ltd. admit liability nor provide
- *	warranty for any of this software. This material is provided
- *	"AS-IS" and at no charge.
- *
- *
- *	Algorithm:
- *
- *	Queue Frame:
- *		Compute time length of frame at regulated speed
- *		Add frame to queue at appropriate point
- *		Adjust time length computation for followup frames
- *		Any frame that falls outside of its boundaries is freed
- *
- *	We work to the following constants
- *
- *		SHAPER_QLEN	Maximum queued frames
- *		SHAPER_LATENCY	Bounding latency on a frame. Leaving this latency
- *				window drops the frame. This stops us queueing
- *				frames for a long time and confusing a remote
- *				host.
- *		SHAPER_MAXSLIP	Maximum time a priority frame may jump forward.
- *				That bounds the penalty we will inflict on low
- *				priority traffic.
- *		SHAPER_BURST	Time range we call "now" in order to reduce
- *				system load. The more we make this the burstier
- *				the behaviour, the better local performance you
- *				get through packet clustering on routers and the
- *				worse the remote end gets to judge rtts.
- *
- *	This is designed to handle lower speed links ( < 200K/second or so). We
- *	run off a 100-150Hz base clock typically. This gives us a resolution at
- *	200Kbit/second of about 2Kbit or 256 bytes. Above that our timer
- *	resolution may start to cause much more burstiness in the traffic. We
- *	could avoid a lot of that by calling kick_shaper() at the end of the
- *	tied device transmissions. If you run above about 100K second you
- *	may need to tune the supposed speed rate for the right values.
- *
- *	BUGS:
- *		Downing the interface under the shaper before the shaper
- *		will render your machine defunct. Don't for now shape over
- *		PPP or SLIP therefore!
- *		This will be fixed in BETA4
- *
- * Update History :
- *
- *              bh_atomic() SMP races fixes and rewritten the locking code to
- *              be SMP safe and irq-mask friendly.
- *              NOTE: we can't use start_bh_atomic() in kick_shaper()
- *              because it's going to be recalled from an irq handler,
- *              and synchronize_bh() is a nono if called from irq context.
- *						1999  Andrea Arcangeli
- *
- *              Device statistics (tx_pakets, tx_bytes,
- *              tx_drops: queue_over_time and collisions: max_queue_exceded)
- *                               1999/06/18 Jordi Murgo <savage@apostols.org>
- *
- *		Use skb->cb for private data.
- *				 2000/03 Andi Kleen
- */
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/if_arp.h>
-#include <linux/init.h>
-#include <linux/if_shaper.h>
-#include <linux/jiffies.h>
-
-#include <net/dst.h>
-#include <net/arp.h>
-#include <net/net_namespace.h>
-
-struct shaper_cb {
-	unsigned long	shapeclock;		/* Time it should go out */
-	unsigned long	shapestamp;		/* Stamp for shaper    */
-	__u32		shapelatency;		/* Latency on frame */
-	__u32		shapelen;		/* Frame length in clocks */
-	__u16		shapepend;		/* Pending */
-};
-#define SHAPERCB(skb) ((struct shaper_cb *) ((skb)->cb))
-
-static int sh_debug;		/* Debug flag */
-
-#define SHAPER_BANNER	"CymruNet Traffic Shaper BETA 0.04 for Linux 2.1\n"
-
-static void shaper_kick(struct shaper *sh);
-
-/*
- *	Compute clocks on a buffer
- */
-
-static int shaper_clocks(struct shaper *shaper, struct sk_buff *skb)
-{
- 	int t=skb->len/shaper->bytespertick;
- 	return t;
-}
-
-/*
- *	Set the speed of a shaper. We compute this in bytes per tick since
- *	thats how the machine wants to run. Quoted input is in bits per second
- *	as is traditional (note not BAUD). We assume 8 bit bytes.
- */
-
-static void shaper_setspeed(struct shaper *shaper, int bitspersec)
-{
-	shaper->bitspersec=bitspersec;
-	shaper->bytespertick=(bitspersec/HZ)/8;
-	if(!shaper->bytespertick)
-		shaper->bytespertick++;
-}
-
-/*
- *	Throw a frame at a shaper.
- */
-
-
-static int shaper_start_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	struct shaper *shaper = dev->priv;
- 	struct sk_buff *ptr;
-
-	spin_lock(&shaper->lock);
- 	ptr=shaper->sendq.prev;
-
- 	/*
- 	 *	Set up our packet details
- 	 */
-
- 	SHAPERCB(skb)->shapelatency=0;
- 	SHAPERCB(skb)->shapeclock=shaper->recovery;
- 	if(time_before(SHAPERCB(skb)->shapeclock, jiffies))
- 		SHAPERCB(skb)->shapeclock=jiffies;
- 	skb->priority=0;	/* short term bug fix */
- 	SHAPERCB(skb)->shapestamp=jiffies;
-
- 	/*
- 	 *	Time slots for this packet.
- 	 */
-
- 	SHAPERCB(skb)->shapelen= shaper_clocks(shaper,skb);
-
-	{
-		struct sk_buff *tmp;
-		/*
-		 *	Up our shape clock by the time pending on the queue
-		 *	(Should keep this in the shaper as a variable..)
-		 */
-		for(tmp=skb_peek(&shaper->sendq); tmp!=NULL &&
-			tmp!=(struct sk_buff *)&shaper->sendq; tmp=tmp->next)
-			SHAPERCB(skb)->shapeclock+=SHAPERCB(tmp)->shapelen;
-		/*
-		 *	Queue over time. Spill packet.
-		 */
-		if(time_after(SHAPERCB(skb)->shapeclock,jiffies + SHAPER_LATENCY)) {
-			dev_kfree_skb(skb);
-			dev->stats.tx_dropped++;
-		} else
-			skb_queue_tail(&shaper->sendq, skb);
-	}
-
-	if(sh_debug)
- 		printk("Frame queued.\n");
- 	if(skb_queue_len(&shaper->sendq)>SHAPER_QLEN)
- 	{
- 		ptr=skb_dequeue(&shaper->sendq);
-                dev_kfree_skb(ptr);
-                dev->stats.collisions++;
- 	}
-	shaper_kick(shaper);
-	spin_unlock(&shaper->lock);
- 	return 0;
-}
-
-/*
- *	Transmit from a shaper
- */
-
-static void shaper_queue_xmit(struct shaper *shaper, struct sk_buff *skb)
-{
-	struct sk_buff *newskb=skb_clone(skb, GFP_ATOMIC);
-	if(sh_debug)
-		printk("Kick frame on %p\n",newskb);
-	if(newskb)
-	{
-		newskb->dev=shaper->dev;
-		newskb->priority=2;
-		if(sh_debug)
-			printk("Kick new frame to %s, %d\n",
-				shaper->dev->name,newskb->priority);
-		dev_queue_xmit(newskb);
-
-                shaper->dev->stats.tx_bytes += skb->len;
-		shaper->dev->stats.tx_packets++;
-
-                if(sh_debug)
-			printk("Kicked new frame out.\n");
-		dev_kfree_skb(skb);
-	}
-}
-
-/*
- *	Timer handler for shaping clock
- */
-
-static void shaper_timer(unsigned long data)
-{
-	struct shaper *shaper = (struct shaper *)data;
-
-	spin_lock(&shaper->lock);
-	shaper_kick(shaper);
-	spin_unlock(&shaper->lock);
-}
-
-/*
- *	Kick a shaper queue and try and do something sensible with the
- *	queue.
- */
-
-static void shaper_kick(struct shaper *shaper)
-{
-	struct sk_buff *skb;
-
-	/*
-	 *	Walk the list (may be empty)
-	 */
-
-	while((skb=skb_peek(&shaper->sendq))!=NULL)
-	{
-		/*
-		 *	Each packet due to go out by now (within an error
-		 *	of SHAPER_BURST) gets kicked onto the link
-		 */
-
-		if(sh_debug)
-			printk("Clock = %ld, jiffies = %ld\n", SHAPERCB(skb)->shapeclock, jiffies);
-		if(time_before_eq(SHAPERCB(skb)->shapeclock, jiffies + SHAPER_BURST))
-		{
-			/*
-			 *	Pull the frame and get interrupts back on.
-			 */
-
-			skb_unlink(skb, &shaper->sendq);
-			if (shaper->recovery <
-			    SHAPERCB(skb)->shapeclock + SHAPERCB(skb)->shapelen)
-				shaper->recovery = SHAPERCB(skb)->shapeclock + SHAPERCB(skb)->shapelen;
-			/*
-			 *	Pass on to the physical target device via
-			 *	our low level packet thrower.
-			 */
-
-			SHAPERCB(skb)->shapepend=0;
-			shaper_queue_xmit(shaper, skb);	/* Fire */
-		}
-		else
-			break;
-	}
-
-	/*
-	 *	Next kick.
-	 */
-
-	if(skb!=NULL)
-		mod_timer(&shaper->timer, SHAPERCB(skb)->shapeclock);
-}
-
-
-/*
- *	Bring the interface up. We just disallow this until a
- *	bind.
- */
-
-static int shaper_open(struct net_device *dev)
-{
-	struct shaper *shaper=dev->priv;
-
-	/*
-	 *	Can't open until attached.
-	 *	Also can't open until speed is set, or we'll get
-	 *	a division by zero.
-	 */
-
-	if(shaper->dev==NULL)
-		return -ENODEV;
-	if(shaper->bitspersec==0)
-		return -EINVAL;
-	return 0;
-}
-
-/*
- *	Closing a shaper flushes the queues.
- */
-
-static int shaper_close(struct net_device *dev)
-{
-	struct shaper *shaper=dev->priv;
-	struct sk_buff *skb;
-
-	while ((skb = skb_dequeue(&shaper->sendq)) != NULL)
-		dev_kfree_skb(skb);
-
-	spin_lock_bh(&shaper->lock);
-	shaper_kick(shaper);
-	spin_unlock_bh(&shaper->lock);
-
-	del_timer_sync(&shaper->timer);
-	return 0;
-}
-
-/*
- *	Revectored calls. We alter the parameters and call the functions
- *	for our attached device. This enables us to bandwidth allocate after
- *	ARP and other resolutions and not before.
- */
-
-static int shaper_header(struct sk_buff *skb, struct net_device *dev,
-			 unsigned short type,
-			 const void *daddr, const void *saddr, unsigned len)
-{
-	struct shaper *sh=dev->priv;
-	int v;
-	if(sh_debug)
-		printk("Shaper header\n");
-	skb->dev = sh->dev;
-	v = dev_hard_header(skb, sh->dev, type, daddr, saddr, len);
-	skb->dev = dev;
-	return v;
-}
-
-static int shaper_rebuild_header(struct sk_buff *skb)
-{
-	struct shaper *sh=skb->dev->priv;
-	struct net_device *dev=skb->dev;
-	int v;
-	if(sh_debug)
-		printk("Shaper rebuild header\n");
-	skb->dev=sh->dev;
-	v = sh->dev->header_ops->rebuild(skb);
-	skb->dev=dev;
-	return v;
-}
-
-#if 0
-static int shaper_cache(struct neighbour *neigh, struct hh_cache *hh)
-{
-	struct shaper *sh=neigh->dev->priv;
-	struct net_device *tmp;
-	int ret;
-	if(sh_debug)
-		printk("Shaper header cache bind\n");
-	tmp=neigh->dev;
-	neigh->dev=sh->dev;
-	ret=sh->hard_header_cache(neigh,hh);
-	neigh->dev=tmp;
-	return ret;
-}
-
-static void shaper_cache_update(struct hh_cache *hh, struct net_device *dev,
-	unsigned char *haddr)
-{
-	struct shaper *sh=dev->priv;
-	if(sh_debug)
-		printk("Shaper cache update\n");
-	sh->header_cache_update(hh, sh->dev, haddr);
-}
-#endif
-
-#ifdef CONFIG_INET
-
-static int shaper_neigh_setup(struct neighbour *n)
-{
-#ifdef CONFIG_INET
-	if (n->nud_state == NUD_NONE) {
-		n->ops = &arp_broken_ops;
-		n->output = n->ops->output;
-	}
-#endif
-	return 0;
-}
-
-static int shaper_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
-{
-#ifdef CONFIG_INET
-	if (p->tbl->family == AF_INET) {
-		p->neigh_setup = shaper_neigh_setup;
-		p->ucast_probes = 0;
-		p->mcast_probes = 0;
-	}
-#endif
-	return 0;
-}
-
-#else /* !(CONFIG_INET) */
-
-static int shaper_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
-{
-	return 0;
-}
-
-#endif
-
-static const struct header_ops shaper_ops = {
-	.create	 = shaper_header,
-	.rebuild = shaper_rebuild_header,
-};
-
-static int shaper_attach(struct net_device *shdev, struct shaper *sh, struct net_device *dev)
-{
-	sh->dev = dev;
-	sh->get_stats=dev->get_stats;
-
-	shdev->neigh_setup = shaper_neigh_setup_dev;
-	shdev->hard_header_len=dev->hard_header_len;
-	shdev->type=dev->type;
-	shdev->addr_len=dev->addr_len;
-	shdev->mtu=dev->mtu;
-	sh->bitspersec=0;
-	return 0;
-}
-
-static int shaper_ioctl(struct net_device *dev,  struct ifreq *ifr, int cmd)
-{
-	struct shaperconf *ss= (struct shaperconf *)&ifr->ifr_ifru;
-	struct shaper *sh=dev->priv;
-
-	if(ss->ss_cmd == SHAPER_SET_DEV || ss->ss_cmd == SHAPER_SET_SPEED)
-	{
-		if(!capable(CAP_NET_ADMIN))
-			return -EPERM;
-	}
-
-	switch(ss->ss_cmd)
-	{
-		case SHAPER_SET_DEV:
-		{
-			struct net_device *them=__dev_get_by_name(&init_net, ss->ss_name);
-			if(them==NULL)
-				return -ENODEV;
-			if(sh->dev)
-				return -EBUSY;
-			return shaper_attach(dev,dev->priv, them);
-		}
-		case SHAPER_GET_DEV:
-			if(sh->dev==NULL)
-				return -ENODEV;
-			strcpy(ss->ss_name, sh->dev->name);
-			return 0;
-		case SHAPER_SET_SPEED:
-			shaper_setspeed(sh,ss->ss_speed);
-			return 0;
-		case SHAPER_GET_SPEED:
-			ss->ss_speed=sh->bitspersec;
-			return 0;
-		default:
-			return -EINVAL;
-	}
-}
-
-static void shaper_init_priv(struct net_device *dev)
-{
-	struct shaper *sh = dev->priv;
-
-	skb_queue_head_init(&sh->sendq);
-	init_timer(&sh->timer);
-	sh->timer.function=shaper_timer;
-	sh->timer.data=(unsigned long)sh;
-	spin_lock_init(&sh->lock);
-}
-
-/*
- *	Add a shaper device to the system
- */
-
-static void __init shaper_setup(struct net_device *dev)
-{
-	/*
-	 *	Set up the shaper.
-	 */
-
-	shaper_init_priv(dev);
-
-	dev->open		= shaper_open;
-	dev->stop		= shaper_close;
-	dev->hard_start_xmit 	= shaper_start_xmit;
-	dev->set_multicast_list = NULL;
-
-	/*
-	 *	Intialise the packet queues
-	 */
-
-	/*
-	 *	Handlers for when we attach to a device.
-	 */
-
-	dev->neigh_setup	= shaper_neigh_setup_dev;
-	dev->do_ioctl		= shaper_ioctl;
-	dev->hard_header_len	= 0;
-	dev->type		= ARPHRD_ETHER;	/* initially */
-	dev->set_mac_address	= NULL;
-	dev->mtu		= 1500;
-	dev->addr_len		= 0;
-	dev->tx_queue_len	= 10;
-	dev->flags		= 0;
-}
-
-static int shapers = 1;
-#ifdef MODULE
-
-module_param(shapers, int, 0);
-MODULE_PARM_DESC(shapers, "Traffic shaper: maximum number of shapers");
-
-#else /* MODULE */
-
-static int __init set_num_shapers(char *str)
-{
-	shapers = simple_strtol(str, NULL, 0);
-	return 1;
-}
-
-__setup("shapers=", set_num_shapers);
-
-#endif /* MODULE */
-
-static struct net_device **devs;
-
-static unsigned int shapers_registered = 0;
-
-static int __init shaper_init(void)
-{
-	int i;
-	size_t alloc_size;
-	struct net_device *dev;
-	char name[IFNAMSIZ];
-
-	if (shapers < 1)
-		return -ENODEV;
-
-	alloc_size = sizeof(*dev) * shapers;
-	devs = kzalloc(alloc_size, GFP_KERNEL);
-	if (!devs)
-		return -ENOMEM;
-
-	for (i = 0; i < shapers; i++) {
-
-		snprintf(name, IFNAMSIZ, "shaper%d", i);
-		dev = alloc_netdev(sizeof(struct shaper), name,
-				   shaper_setup);
-		if (!dev)
-			break;
-
-		if (register_netdev(dev)) {
-			free_netdev(dev);
-			break;
-		}
-
-		devs[i] = dev;
-		shapers_registered++;
-	}
-
-	if (!shapers_registered) {
-		kfree(devs);
-		devs = NULL;
-	}
-
-	return (shapers_registered ? 0 : -ENODEV);
-}
-
-static void __exit shaper_exit (void)
-{
-	int i;
-
-	for (i = 0; i < shapers_registered; i++) {
-		if (devs[i]) {
-			unregister_netdev(devs[i]);
-			free_netdev(devs[i]);
-		}
-	}
-
-	kfree(devs);
-	devs = NULL;
-}
-
-module_init(shaper_init);
-module_exit(shaper_exit);
-MODULE_LICENSE("GPL");
-
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index f30fa92..363a016 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -228,7 +228,6 @@ unifdef-y += if_ltalk.h
 unifdef-y += if_link.h
 unifdef-y += if_pppol2tp.h
 unifdef-y += if_pppox.h
-unifdef-y += if_shaper.h
 unifdef-y += if_tr.h
 unifdef-y += if_tun.h
 unifdef-y += if_vlan.h
diff --git a/include/linux/if_shaper.h b/include/linux/if_shaper.h
deleted file mode 100644
index 3b1b7ba..0000000
--- a/include/linux/if_shaper.h
+++ /dev/null
@@ -1,51 +0,0 @@
-#ifndef __LINUX_SHAPER_H
-#define __LINUX_SHAPER_H
-
-#ifdef __KERNEL__
-
-#define SHAPER_QLEN	10
-/*
- *	This is a bit speed dependent (read it shouldn't be a constant!)
- *
- *	5 is about right for 28.8 upwards. Below that double for every
- *	halving of speed or so. - ie about 20 for 9600 baud.
- */
-#define SHAPER_LATENCY	(5*HZ)
-#define SHAPER_MAXSLIP	2
-#define SHAPER_BURST	(HZ/50)		/* Good for >128K then */
-
-struct shaper
-{
-	struct sk_buff_head sendq;
-	__u32 bytespertick;
-	__u32 bitspersec;
-	__u32 shapelatency;
-	__u32 shapeclock;
-	unsigned long recovery;	/* Time we can next clock a packet out on
-				   an empty queue */
-	spinlock_t lock;
-	struct net_device *dev;
-	struct net_device_stats* (*get_stats)(struct net_device *dev);
-	struct timer_list timer;
-};
-
-#endif
-
-#define SHAPER_SET_DEV		0x0001
-#define SHAPER_SET_SPEED	0x0002
-#define SHAPER_GET_DEV		0x0003
-#define SHAPER_GET_SPEED	0x0004
-
-struct shaperconf
-{
-	__u16	ss_cmd;
-	union
-	{
-		char 	ssu_name[14];
-		__u32	ssu_speed;
-	} ss_u;
-#define ss_speed ss_u.ssu_speed
-#define ss_name ss_u.ssu_name
-};
-
-#endif

