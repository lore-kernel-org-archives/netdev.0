From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Tue, 15 Oct 2002 11:53:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DABE5A2.71542192@isg.de>
References: <Pine.GSO.4.30.0210130957150.25992-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------471682B4692DE518292CF7DC"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------471682B4692DE518292CF7DC
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi Jamal,

attached is the latest version of the patch. Changes:

-Try to use a static struct lw_event for an event. For systems without
slave devices, this will avoid memory allocation in most cases. But,
adding code and data it permanently takes as much memory as about ten of
the additional pointers you didn't want to have in the net_device
structure ;-)

-moved the event queue flushing in unregister_netdev() down some lines
so that it is not attempted for new style devices with destructor.

According to Alexey not wanting to expand the netlink message, the only
result of this patch visible to userspace is the IFF_RUNNING emulation.

Cheers, Stefan
--------------471682B4692DE518292CF7DC
Content-Type: text/plain; charset=us-ascii;
 name="patch-rfc2863-2.5.41-3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-rfc2863-2.5.41-3"

diff -uNrX dontdiff linux-2.5.41/include/linux/netdevice.h linux-2.5.41-stefan/include/linux/netdevice.h
--- linux-2.5.41/include/linux/netdevice.h	Tue Oct  8 22:18:50 2002
+++ linux-2.5.41-stefan/include/linux/netdevice.h	Sun Oct 13 12:47:13 2002
@@ -204,10 +204,23 @@
 {
 	__LINK_STATE_XOFF=0,
 	__LINK_STATE_START,
-	__LINK_STATE_PRESENT,
+	__LINK_STATE_PRESENT_OBSOLETE,
 	__LINK_STATE_SCHED,
-	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED
+	__LINK_STATE_NOCARRIER_OBSOLETE,
+	__LINK_STATE_RX_SCHED,
+	__LINK_STATE_LINKWATCH_PENDING
+};
+
+
+/* Device operative state as per RFC2863 */
+enum netdev_operstate_t {
+	NETDEV_OPER_UP = 1,
+	NETDEV_OPER_DOWN, /* Obsoletes LINK_STATE_NOCARRIER */
+	NETDEV_OPER_TESTING,
+	NETDEV_OPER_UNKNOWN,
+	NETDEV_OPER_DORMANT,
+	NETDEV_OPER_NOTPRESENT, /* Obsoletes !LINK_STATE_PRESENT */
+	NETDEV_OPER_LOWERDOWN
 };
 
 
@@ -308,6 +321,10 @@
 					  * which this device is member of.
 					  */
 
+	/* Operative state, access semaphore */
+	rwlock_t                operstate_lock;
+	unsigned char           operstate;
+
 	/* Interface address info. */
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address	*/
@@ -631,34 +648,76 @@
  * who is responsible for serialization of these calls.
  */
 
+#ifdef CONFIG_LINKWATCH
+extern void linkwatch_fire_event(struct net_device *dev);
+#endif
+
+static inline unsigned char netif_set_operstate(struct net_device *dev, unsigned char newstate)
+{
+	unsigned long flags;
+	unsigned char oldstate;
+
+	write_lock_irqsave(&dev->operstate_lock, flags);
+	oldstate = dev->operstate;
+	dev->operstate = newstate;
+	write_unlock_irqrestore(&dev->operstate_lock, flags);
+
+#ifdef CONFIG_LINKWATCH
+	if (oldstate != newstate) linkwatch_fire_event(dev);
+#endif
+
+	return oldstate;
+}
+
+static inline unsigned char netif_get_operstate(struct net_device *dev)
+{
+	unsigned long flags;
+	unsigned char state;
+
+	read_lock_irqsave(&dev->operstate_lock, flags);
+	state = dev->operstate;
+	read_unlock_irqrestore(&dev->operstate_lock, flags);
+
+	return state;
+}
+
 static inline int netif_carrier_ok(struct net_device *dev)
 {
-	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
+	return netif_get_operstate(dev) != NETDEV_OPER_UP;
+}
+
+static inline int netif_operstate_to_iff_running(struct net_device *dev)
+{
+	unsigned char state = netif_get_operstate(dev);
+
+	return((1 << state) &
+	       (1 << NETDEV_OPER_UP | 1 << NETDEV_OPER_UNKNOWN));
 }
 
 extern void __netdev_watchdog_up(struct net_device *dev);
 
+
 static inline void netif_carrier_on(struct net_device *dev)
 {
-	clear_bit(__LINK_STATE_NOCARRIER, &dev->state);
+	netif_set_operstate(dev, NETDEV_OPER_UP);
 	if (netif_running(dev))
 		__netdev_watchdog_up(dev);
 }
 
 static inline void netif_carrier_off(struct net_device *dev)
 {
-	set_bit(__LINK_STATE_NOCARRIER, &dev->state);
+	netif_set_operstate(dev, NETDEV_OPER_DOWN);
 }
 
 /* Hot-plugging. */
 static inline int netif_device_present(struct net_device *dev)
 {
-	return test_bit(__LINK_STATE_PRESENT, &dev->state);
+	return netif_get_operstate(dev) != NETDEV_OPER_NOTPRESENT;
 }
 
 static inline void netif_device_detach(struct net_device *dev)
 {
-	if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
+	if (netif_set_operstate(dev, NETDEV_OPER_NOTPRESENT) != NETDEV_OPER_NOTPRESENT &&
 	    netif_running(dev)) {
 		netif_stop_queue(dev);
 	}
@@ -666,7 +725,7 @@
 
 static inline void netif_device_attach(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
+	if (netif_set_operstate(dev, NETDEV_OPER_UNKNOWN) == NETDEV_OPER_NOTPRESENT &&
 	    netif_running(dev)) {
 		netif_wake_queue(dev);
  		__netdev_watchdog_up(dev);
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
+++ linux-2.5.41-stefan/net/core/Makefile	Sun Oct 13 12:37:08 2002
@@ -21,4 +21,6 @@
 # Ugly. I wish all wireless drivers were moved in drivers/net/wireless
 obj-$(CONFIG_NET_PCMCIA_RADIO) += wireless.o
 
+obj-$(CONFIG_LINKWATCH) += link_watch.o
+
 include $(TOPDIR)/Rules.make
diff -uNrX dontdiff linux-2.5.41/net/core/dev.c linux-2.5.41-stefan/net/core/dev.c
--- linux-2.5.41/net/core/dev.c	Tue Oct  8 22:18:51 2002
+++ linux-2.5.41-stefan/net/core/dev.c	Mon Oct 14 23:00:00 2002
@@ -198,7 +198,6 @@
 int netdev_fastroute_obstacles;
 #endif
 
-
 /*******************************************************************************
 
 		Protocol management and registration routines
@@ -261,6 +260,9 @@
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 }
 
+#ifdef CONFIG_LINKWATCH
+void linkwatch_run_queue(void);
+#endif
 
 /**
  *	dev_remove_pack	 - remove packet handler
@@ -2017,7 +2019,7 @@
 							 IFF_RUNNING)) | 
 					 (dev->gflags & (IFF_PROMISC |
 							 IFF_ALLMULTI));
-			if (netif_running(dev) && netif_carrier_ok(dev))
+			if (netif_running(dev) && netif_operstate_to_iff_running(dev))
 				ifr->ifr_flags |= IFF_RUNNING;
 			return 0;
 
@@ -2432,6 +2434,10 @@
 		goto out;
 #endif /* CONFIG_NET_DIVERT */
 
+	/* Initial operstate */
+	dev->operstate_lock = RW_LOCK_UNLOCKED;
+	dev->operstate = NETDEV_OPER_UNKNOWN;
+
 	dev->iflink = -1;
 
 	/* Init, if this function is available */
@@ -2457,13 +2463,6 @@
 	if (!dev->rebuild_header)
 		dev->rebuild_header = default_rebuild_header;
 
-	/*
-	 *	Default initial state at registry is that the
-	 *	device is present.
-	 */
-
-	set_bit(__LINK_STATE_PRESENT, &dev->state);
-
 	dev->next = NULL;
 	dev_init_scheduler(dev);
 	write_lock_bh(&dev_base_lock);
@@ -2641,6 +2640,17 @@
 			/* Rebroadcast unregister notification */
 			notifier_call_chain(&netdev_chain,
 					    NETDEV_UNREGISTER, dev);
+
+#ifdef CONFIG_LINKWATCH
+			if (test_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
+				/* We must not have linkwatch events pending
+				 * on unregister. If this happens, we simply
+				 * run the queue unscheduled, resulting in a
+				 * noop for this device
+				 */
+				linkwatch_run_queue();
+			}
+#endif
 		}
 		current->state = TASK_INTERRUPTIBLE;
 		schedule_timeout(HZ / 4);
@@ -2735,6 +2745,8 @@
 #ifdef CONFIG_NET_FASTROUTE
 		dev->fastpath_lock = RW_LOCK_UNLOCKED;
 #endif
+		dev->operstate_lock = RW_LOCK_UNLOCKED;
+		dev->operstate = NETDEV_OPER_UNKNOWN;
 		dev->xmit_lock_owner = -1;
 		dev->iflink = -1;
 		dev_hold(dev);
@@ -2767,7 +2779,6 @@
 			if (!dev->rebuild_header)
 				dev->rebuild_header = default_rebuild_header;
 			dev_init_scheduler(dev);
-			set_bit(__LINK_STATE_PRESENT, &dev->state);
 		}
 	}
 
@@ -2848,3 +2859,5 @@
 	return call_usermodehelper(argv [0], argv, envp);
 }
 #endif
+
+
diff -uNrX dontdiff linux-2.5.41/net/core/link_watch.c linux-2.5.41-stefan/net/core/link_watch.c
--- linux-2.5.41/net/core/link_watch.c	Thu Jan  1 01:00:00 1970
+++ linux-2.5.41-stefan/net/core/link_watch.c	Mon Oct 14 22:51:02 2002
@@ -0,0 +1,134 @@
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
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/workqueue.h>
+#include <asm/bitops.h>
+#include <asm/types.h>
+
+
+enum lw_bits {
+	LW_RUNNING = 0,
+	LW_SE_USED
+};
+
+static unsigned long linkwatch_flags = 0;
+static unsigned long linkwatch_nextevent = 0;
+
+static void linkwatch_event(void *dummy);
+static DECLARE_WORK(linkwatch_work, linkwatch_event, NULL);
+
+static LIST_HEAD(lweventlist);
+static spinlock_t lweventlist_lock = SPIN_LOCK_UNLOCKED;
+
+struct lw_event {
+	struct list_head list;
+	struct net_device *dev;
+};
+
+/* Avoid kmalloc() for most systems */
+struct lw_event singleevent;
+
+/* Must be called with the rtnl semaphore held */
+void linkwatch_run_queue(void) {
+	LIST_HEAD(head);
+	struct list_head *n, *next;
+
+	spin_lock_irq(&lweventlist_lock);
+	list_splice_init(&lweventlist, &head);
+	spin_unlock_irq(&lweventlist_lock);
+
+	list_for_each_safe(n, next, &head) {
+		struct lw_event *event = list_entry(n, struct lw_event, list);
+		struct net_device *dev = event->dev;
+
+		if (event == &singleevent) {
+			clear_bit(LW_SE_USED, &linkwatch_flags);
+		} else {
+			kfree(event);
+		}
+
+		/* We are about to handle this device,
+		 * so new events can be accepted
+		 */
+		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
+
+		if (dev->flags & IFF_UP) {
+			netdev_state_change(dev);
+		}
+
+		dev_put(dev);
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
+	clear_bit(LW_RUNNING, &linkwatch_flags);
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
+		struct lw_event *event;
+
+		if (test_and_set_bit(LW_SE_USED, &linkwatch_flags)) {
+			event = kmalloc(sizeof(struct lw_event), GFP_ATOMIC);
+
+			if (unlikely(event == NULL)) {
+				clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
+				return;
+			}
+		} else {
+			event = &singleevent;
+		}
+
+		dev_hold(dev);
+		event->dev = dev;
+
+		spin_lock_irqsave(&lweventlist_lock, flags);
+		list_add_tail(&event->list, &lweventlist);
+		spin_unlock_irqrestore(&lweventlist_lock, flags);
+
+		if (!test_and_set_bit(LW_RUNNING, &linkwatch_flags)) {
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
+
diff -uNrX dontdiff linux-2.5.41/net/core/rtnetlink.c linux-2.5.41-stefan/net/core/rtnetlink.c
--- linux-2.5.41/net/core/rtnetlink.c	Tue Oct  1 09:07:57 2002
+++ linux-2.5.41-stefan/net/core/rtnetlink.c	Sat Oct 12 14:27:43 2002
@@ -165,7 +165,7 @@
 	r->ifi_flags = dev->flags;
 	r->ifi_change = change;
 
-	if (!netif_running(dev) || !netif_carrier_ok(dev))
+	if (!netif_running(dev) || !netif_operstate_to_iff_running(dev))
 		r->ifi_flags &= ~IFF_RUNNING;
 	else
 		r->ifi_flags |= IFF_RUNNING;
diff -uNrX dontdiff linux-2.5.41/net/netsyms.c linux-2.5.41-stefan/net/netsyms.c
--- linux-2.5.41/net/netsyms.c	Tue Oct  8 22:18:53 2002
+++ linux-2.5.41-stefan/net/netsyms.c	Sun Oct 13 13:27:40 2002
@@ -596,4 +596,8 @@
 EXPORT_SYMBOL(wireless_send_event);
 #endif	/* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
 
+#ifdef CONFIG_LINKWATCH
+EXPORT_SYMBOL(linkwatch_fire_event);
+#endif
+
 #endif  /* CONFIG_NET */

--------------471682B4692DE518292CF7DC--
