From: Stefan Rompf <srompf@isg.de>
Subject: Patch: link state notification for 2.5.41
Date: Sat, 12 Oct 2002 01:51:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA76407.F16521F4@isg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------BBFAC417D0AD1512B229B21A"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------BBFAC417D0AD1512B229B21A
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

some months ago I've sent a patch to the linux kernel list that enabled
notification of network driver link state changes over the netlink
socket. Technically, this has been implemented by a kernel thread that
mirrored dev->state:__LINK_STATE_NO_CARRIER into dev->flags:IFF_RUNNING
and sent netlink messages. Note: The in-kernel-flag IFF_RUNNING is
unused at least since 2.4, it is the LINK_STATE_NO_CARRIER bit that is
seen as RUNNING from user mode.

This was followed by a discussion with Jamal (look at
http://marc.theaimsgroup.com/?t=101751064400001&r=1&w=2), however, it
took ...ahem.. a while until the revised version I attach to this mail.
Don't ask ;-)

I had quite positive feedback from LVS and zebra people, so I tried to
remove most of the objections against the patch.

-Anyway, I wanted to keep the current semantics of
netif_carrier_on()/_off(). The extended states that can be found RFC2863
did not seem to useful to me for linux, mainly because "notPresent" is
already implemented with netif_device_detach()/_attach() and especially
for ethernet drivers there is no real difference between "testing" and
"down".
-Using Ingos workqueue implementation, I removed the need for the first
versions' own kernel thread.
-I changed the simple approach of iterating over all network devices,
now the handler only looks at devices that had an event. This change
also increases compatibility to broken drivers that manipulate
IFF_RUNNING directly, there is a good chance that these drivers will
never generate state notification events. I kept the semantic not to
create a list of events for one device, only the latest state change is
forwarded when the queue is run.

Patch against 2.5.41 is attached for comments, of course with the aim of
kernel inclusion. I have tested it on a UP machine, but hope that I've
got the locking stuff right.

Cheers, Stefan
--------------BBFAC417D0AD1512B229B21A
Content-Type: text/plain; charset=us-ascii;
 name="patch-linkwatch-2.5.41-new"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-linkwatch-2.5.41-new"

diff -uNrX dontdiff linux-2.5.41/include/linux/netdevice.h linux-2.5.41-stefan/include/linux/netdevice.h
--- linux-2.5.41/include/linux/netdevice.h	Tue Oct  8 22:18:50 2002
+++ linux-2.5.41-stefan/include/linux/netdevice.h	Sat Oct 12 00:40:34 2002
@@ -207,7 +207,8 @@
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED
+	__LINK_STATE_RX_SCHED,
+	__LINK_STATE_LINKWATCH_PENDING
 };
 
 
@@ -437,6 +438,9 @@
 	/* this will get initialized at each interface type init routine */
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
+#ifdef CONFIG_LINKWATCH
+	struct net_device       *linkwatch_next;
+#endif
 };
 
 
@@ -480,6 +484,13 @@
 extern struct net_device	*__dev_get_by_index(int ifindex);
 extern int		dev_restart(struct net_device *dev);
 
+/* This gets called by netif_carrier_on()/_off() whenever
+ * state of an interface changes
+ */
+#ifdef CONFIG_LINKWATCH
+extern void linkwatch_fire_event(struct net_device *dev);
+#endif
+
 typedef int gifconf_func_t(struct net_device * dev, char * bufptr, int len);
 extern int		register_gifconf(unsigned int family, gifconf_func_t * gifconf);
 static inline int unregister_gifconf(unsigned int family)
@@ -640,14 +651,24 @@
 
 static inline void netif_carrier_on(struct net_device *dev)
 {
+#ifdef CONFIG_LINKWATCH
+	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state))
+		linkwatch_fire_event(dev);
+#else
 	clear_bit(__LINK_STATE_NOCARRIER, &dev->state);
+#endif
 	if (netif_running(dev))
 		__netdev_watchdog_up(dev);
 }
 
 static inline void netif_carrier_off(struct net_device *dev)
 {
+#ifdef CONFIG_LINKWATCH
+	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state))
+		linkwatch_fire_event(dev);
+#else
 	set_bit(__LINK_STATE_NOCARRIER, &dev->state);
+#endif
 }
 
 /* Hot-plugging. */
diff -uNrX dontdiff linux-2.5.41/net/Config.help linux-2.5.41-stefan/net/Config.help
--- linux-2.5.41/net/Config.help	Tue Oct  1 09:06:18 2002
+++ linux-2.5.41-stefan/net/Config.help	Sat Oct 12 00:56:59 2002
@@ -472,6 +472,17 @@
   However, do not say Y here if you did not experience any serious
   problems.
 
+CONFIG_LINKWATCH
+  When this option is enabled, the kernel will forward changes in the
+  operative ("RUNNING") state of an interface via the netlink socket.
+  This is most useful when running linux as a router.
+
+  Note that currently not many drivers support this, compliant ones
+  can be found by watching the the RUNNING flag in ifconfig output
+  that should follow operative state.
+
+  If unsure, say 'N'.
+
 CONFIG_NET_SCHED
   When the kernel has several packets to send out over a network
   device, it has to decide which ones to send first, which ones to
diff -uNrX dontdiff linux-2.5.41/net/Config.in linux-2.5.41-stefan/net/Config.in
--- linux-2.5.41/net/Config.in	Tue Oct  1 09:06:24 2002
+++ linux-2.5.41-stefan/net/Config.in	Tue Oct  8 22:44:07 2002
@@ -82,6 +82,7 @@
    tristate 'WAN router' CONFIG_WAN_ROUTER
    bool 'Fast switching (read help!)' CONFIG_NET_FASTROUTE
    bool 'Forwarding between high speed interfaces' CONFIG_NET_HW_FLOWCONTROL
+   bool 'Device link state notification (EXPERIMENTAL)' CONFIG_LINKWATCH
 fi
 
 mainmenu_option next_comment
diff -uNrX dontdiff linux-2.5.41/net/core/Makefile linux-2.5.41-stefan/net/core/Makefile
--- linux-2.5.41/net/core/Makefile	Tue Oct  1 09:07:40 2002
+++ linux-2.5.41-stefan/net/core/Makefile	Tue Oct  8 22:58:44 2002
@@ -21,4 +21,6 @@
 # Ugly. I wish all wireless drivers were moved in drivers/net/wireless
 obj-$(CONFIG_NET_PCMCIA_RADIO) += wireless.o
 
+obj-$(CONFIG_LINKWATCH) += link_watch.o
+
 include $(TOPDIR)/Rules.make
diff -uNrX dontdiff linux-2.5.41/net/core/dev.c linux-2.5.41-stefan/net/core/dev.c
--- linux-2.5.41/net/core/dev.c	Tue Oct  8 22:18:51 2002
+++ linux-2.5.41-stefan/net/core/dev.c	Sat Oct 12 00:19:38 2002
@@ -198,6 +198,9 @@
 int netdev_fastroute_obstacles;
 #endif
 
+#ifdef CONFIG_LINKWATCH
+void linkwatch_run_queue(void);
+#endif
 
 /*******************************************************************************
 
@@ -716,6 +719,13 @@
 		 *	Set the flags.
 		 */
 		dev->flags |= IFF_UP;
+#ifdef CONFIG_LINKWATCH
+		if (netif_carrier_ok(dev)) {
+			dev->flags |= IFF_RUNNING;
+		} else {
+			dev->flags &= ~IFF_RUNNING;
+		}
+#endif
 
 		/*
 		 *	Initialize multicasting status
@@ -2590,6 +2600,18 @@
 
 #ifdef CONFIG_NET_DIVERT
 	free_divert_blk(dev);
+#endif
+
+#ifdef CONFIG_LINKWATCH
+	if (test_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
+		/* We must not have linkwatch events pending
+		 * on unregister. If this happens, we simply
+		 * run the queue unscheduled, resulting in a
+		 * noop for this device
+		 */
+		linkwatch_run_queue();
+		BUG_ON(test_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state));
+	}
 #endif
 
 	if (dev->features & NETIF_F_DYNALLOC) {
diff -uNrX dontdiff linux-2.5.41/net/core/link_watch.c linux-2.5.41-stefan/net/core/link_watch.c
--- linux-2.5.41/net/core/link_watch.c	Thu Jan  1 01:00:00 1970
+++ linux-2.5.41-stefan/net/core/link_watch.c	Sat Oct 12 00:48:51 2002
@@ -0,0 +1,113 @@
+/*
+ * Linux network device link state notifaction
+ *
+ * Author:
+ *     Stefan Rompf <sux@isg.de>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ *
+ */
+
+#include <linux/workqueue.h>
+#include <linux/config.h>
+#include <linux/netdevice.h>
+#include <linux/if.h>
+#include <linux/rtnetlink.h>
+#include <linux/jiffies.h>
+#include <linux/spinlock.h>
+#include <asm/bitops.h>
+#include <asm/types.h>
+
+
+static unsigned long linkwatch_nowake = 0;
+static unsigned long linkwatch_nextevent = 0;
+
+static void linkwatch_event(void *dummy);
+DECLARE_WORK(linkwatch_work, linkwatch_event, NULL);
+
+static struct net_device *lw_first = NULL;
+static spinlock_t lw_first_lock = SPIN_LOCK_UNLOCKED;
+
+
+/* Must be called with the rtnl semaphore held */
+void linkwatch_run_queue(void) {
+	struct net_device *dev, *next;
+
+	spin_lock_irq(&lw_first_lock);
+	dev = lw_first;
+	lw_first = NULL;
+	spin_unlock_irq(&lw_first_lock);
+
+	for( ;dev; dev = next) {
+		next = dev->linkwatch_next;
+
+		/* We are about to handle this device,
+		 * so new events can be accepted
+		 */
+		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
+
+		/* State of netif_carrier_ok() is reflected
+		 * into dev_flags, and a netlink message is
+		 * omitted whenever the state changes 
+		 */
+		
+		if (!(dev->flags & IFF_UP)) continue;
+		
+		if (dev->flags & IFF_RUNNING) {
+			if (!netif_carrier_ok(dev)) {
+				write_lock(&dev_base_lock);
+				dev->flags &= ~IFF_RUNNING;
+				write_unlock(&dev_base_lock);
+				netdev_state_change(dev);
+			}
+		} else {
+			if (netif_carrier_ok(dev)) {
+				write_lock(&dev_base_lock);
+				dev->flags |= IFF_RUNNING;
+				write_unlock(&dev_base_lock);
+				netdev_state_change(dev);
+			}
+		}
+	}
+}       
+
+
+static void linkwatch_event(void *dummy)
+{
+	/* Limit the number of linkwatch events to one
+	 * per second so that a runaway driver does not
+	 * cause a storm of messages on the netlink
+	 * socket
+	 */	
+	linkwatch_nextevent = jiffies + HZ;
+	clear_bit(0, &linkwatch_nowake);
+
+	rtnl_lock();
+	linkwatch_run_queue();
+	rtnl_unlock();
+}
+
+
+void linkwatch_fire_event(struct net_device *dev)
+{
+	if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
+		unsigned long flags;
+		spin_lock_irqsave(&lw_first_lock, flags);
+		dev->linkwatch_next = lw_first;
+		lw_first = dev;
+		spin_unlock_irqrestore(&lw_first_lock, flags);
+
+		if (!test_and_set_bit(0, &linkwatch_nowake)) {
+			unsigned long thisevent = jiffies;
+			
+			if (thisevent >= linkwatch_nextevent) {
+				schedule_work(&linkwatch_work);
+			} else {
+				schedule_delayed_work(&linkwatch_work, linkwatch_nextevent - thisevent);
+			}
+		}
+	}
+}
diff -uNrX dontdiff linux-2.5.41/net/netsyms.c linux-2.5.41-stefan/net/netsyms.c
--- linux-2.5.41/net/netsyms.c	Tue Oct  8 22:18:53 2002
+++ linux-2.5.41-stefan/net/netsyms.c	Fri Oct 11 22:38:37 2002
@@ -596,4 +596,8 @@
 EXPORT_SYMBOL(wireless_send_event);
 #endif	/* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
 
+#ifdef CONFIG_LINKWATCH
+EXPORT_SYMBOL(linkwatch_fire_event);
+#endif
+
 #endif  /* CONFIG_NET */

--------------BBFAC417D0AD1512B229B21A--
