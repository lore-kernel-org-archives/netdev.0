From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: dev->destructor
Date: Tue, 6 May 2003 15:35:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506153555.4e82bc4b.shemminger@osdl.org>
References: <20030505130050.4b9868bb.shemminger@osdl.org>
	<20030506075808.388332C07F@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20030506075808.388332C07F@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 06 May 2003 14:18:36 +1000
Rusty Russell <rusty@rustcorp.com.au> wrote:

> In message <20030505130050.4b9868bb.shemminger@osdl.org> you write:
> > As an experiment, tried acquiring module ref count every time network
> > device is ref counted.
> 
> Brave man 8)
> 
> > The result is discovering that there are cases in the Ethernet
> > module init path where there is a call to dev_hold() without a
> > previous explicit ref count.
> 
> Well caught: this is in fact a false alarm.  Coming, as we do, out of
> module_init(), we actually hold an implicit reference.
> 
> It's logically consistent to make it implicit, and cuts out some code
> in the unload path.
> 
> How's this?
> Rusty.

Thanks, with that change and the following patches, the system does
boot and correctly ref counts the modules.  Still have problems
on unregister and shutdown, but it is a start.

diff -urN -X dontdiff linux-2.5/include/linux/netdevice.h linux-2.5-dev/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-04-14 13:32:21.000000000 -0700
+++ linux-2.5-dev/include/linux/netdevice.h	2003-05-06 15:11:25.000000000 -0700
@@ -29,6 +29,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
 #include <linux/kobject.h>
+#include <linux/module.h>
 
 #include <asm/atomic.h>
 #include <asm/cache.h>
@@ -629,12 +630,32 @@
 
 static inline void dev_put(struct net_device *dev)
 {
+	module_put(dev->owner);
 	if (atomic_dec_and_test(&dev->refcnt))
 		netdev_finish_unregister(dev);
 }
 
-#define __dev_put(dev) atomic_dec(&(dev)->refcnt)
-#define dev_hold(dev) atomic_inc(&(dev)->refcnt)
+static inline void __dev_put(struct net_device *dev)
+{
+	module_put(dev->owner);
+	atomic_dec(&dev->refcnt);
+}
+
+static inline void dev_hold(struct net_device *dev)
+{
+	__module_get(dev->owner);
+	atomic_inc(&dev->refcnt);
+}
+
+static inline int dev_try_hold(struct net_device *dev)
+{
+	int ret = 0;
+	if (try_module_get(dev->owner)){
+		atomic_inc(&dev->refcnt);
+		ret = 1;
+	}
+	return ret;
+}
 
 /* Carrier loss detection, dial on demand. The functions netif_carrier_on
  * and _off may be called from IRQ context, but it is caller
diff -urN -X dontdiff linux-2.5/net/core/dev.c linux-2.5-dev/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-05-05 09:41:03.000000000 -0700
+++ linux-2.5-dev/net/core/dev.c	2003-05-06 15:12:24.000000000 -0700
@@ -1,3 +1,4 @@
+#define NET_REFCNT_DEBUG	1
 /*
  * 	NET3	Protocol independent device support routines.
  *
@@ -440,8 +441,8 @@
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_name(name);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !dev_try_hold(dev))
+		dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -513,8 +514,8 @@
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_index(ifindex);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !dev_try_hold(dev))
+		dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -563,8 +564,8 @@
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_flags(if_flags, mask);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !dev_try_hold(dev))
+	    dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -1312,7 +1313,9 @@
 				goto drop;
 
 enqueue:
-			dev_hold(skb->dev);
+			if (!dev_try_hold(skb->dev)) 
+				goto drop;
+
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
 #ifndef OFFLINE_SAMPLE
 			get_sample_stats(this_cpu);
@@ -1990,9 +1993,8 @@
 	ASSERT_RTNL();
 
 	if (master) {
-		if (old)
+		if (old || !dev_try_hold(master))
 			return -EBUSY;
-		dev_hold(master);
 	}
 
 	br_write_lock_bh(BR_NETPROTO_LOCK);
@@ -2609,10 +2611,11 @@
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 
 	dev->next = NULL;
+	atomic_inc(&dev->refcnt);
 	dev_init_scheduler(dev);
 	write_lock_bh(&dev_base_lock);
 	*dp = dev;
-	dev_hold(dev);
+
 	dev->deadbeaf = 0;
 	write_unlock_bh(&dev_base_lock);
 
@@ -2900,7 +2903,11 @@
 #endif
 		dev->xmit_lock_owner = -1;
 		dev->iflink = -1;
-		dev_hold(dev);
+
+		if (!dev_try_hold(dev)) {
+			dev->deadbeaf = 1;
+			dp = &dev->next;
+		}
 
 		/*
 		 * Allocate name. If the init() fails
diff -urN -X dontdiff linux-2.5/net/ipv4/devinet.c linux-2.5-dev/net/ipv4/devinet.c
--- linux-2.5/net/ipv4/devinet.c	2003-04-14 13:32:26.000000000 -0700
+++ linux-2.5-dev/net/ipv4/devinet.c	2003-05-06 15:16:03.000000000 -0700
@@ -559,6 +559,9 @@
 	if ((dev = __dev_get_by_name(ifr.ifr_name)) == NULL)
 		goto done;
 
+	if (!dev_try_hold(dev))
+		goto done;
+
 	if (colon)
 		*colon = ':';
 
@@ -591,7 +594,7 @@
 
 	ret = -EADDRNOTAVAIL;
 	if (!ifa && cmd != SIOCSIFADDR && cmd != SIOCSIFFLAGS)
-		goto done;
+		goto put;
 
 	switch(cmd) {
 	case SIOCGIFADDR:	/* Get interface address */
@@ -700,12 +703,15 @@
 		}
 		break;
 	}
+put:
+	dev_put(dev);
 done:
 	rtnl_unlock();
 	dev_probe_unlock();
 out:
 	return ret;
 rarok:
+	dev_put(dev);
 	rtnl_unlock();
 	dev_probe_unlock();
 	ret = copy_to_user(arg, &ifr, sizeof(struct ifreq)) ? -EFAULT : 0;
