From: Stefan Rompf <srompf@isg.de>
Subject: Patch: Backport of link state notification to 2.4.20rc1
Date: Wed, 13 Nov 2002 23:28:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DD2D204.C9B7FA2D@isg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------FAD95F720EB083095E631054"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------FAD95F720EB083095E631054
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

having the link state notification stuff in 2.4 is still a major goal
for me. I've taken the 2.5 implementation Jamal and I have worked out,
removed the semantic changes towards RFC2863 and replaced the workqueue
with a combination of timer and kevent.

Different to my previous 2.4.18 version this patch needs neither its own
kernel thread nor does it touch the in kernel IFF_RUNNING flag anymore,
so it is quite non-intrusive: Drivers that implement
netif_carrier_on()/netif_carrier_off() will use the notifications, the
rest won't be harmed.

Even though David and Alexey seem to be busy with ipsec stuff, I don't
want to wait any longer to post the patch for public review. I've done
succesful tests with a hacked starfire (trivial three-liner, coming the
next days) and vlan driver. I was not able to check SMP compatibility.

I know of other people on this list who want to have this feature in
2.4, too. Please be so kind and test the patch on your machines. If no
objections arise, I'm going to submit this for 2.4 inclusion.

Cheers, Stefan
--------------FAD95F720EB083095E631054
Content-Type: text/plain; charset=us-ascii;
 name="patch-linkwatch-2.4.20rc1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-linkwatch-2.4.20rc1"

diff -uNr linux-2.4.20rc1/Documentation/Configure.help linux/Documentation/Configure.help
--- linux-2.4.20rc1/Documentation/Configure.help	2002-11-05 00:31:35.000000000 +0100
+++ linux/Documentation/Configure.help	2002-11-13 22:32:46.000000000 +0100
@@ -26011,6 +26011,18 @@
   would like kernel messages to be formatted into GDB $O packets so
   that GDB prints them as program output, say 'Y'.
 
+Device link state notification
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
 802.1Q VLAN Support
 CONFIG_VLAN_8021Q
   Select this and you will be able to create 802.1Q VLAN interfaces on your
diff -uNr linux-2.4.20rc1/include/linux/netdevice.h linux/include/linux/netdevice.h
--- linux-2.4.20rc1/include/linux/netdevice.h	2002-11-05 00:31:42.000000000 +0100
+++ linux/include/linux/netdevice.h	2002-11-13 22:32:46.000000000 +0100
@@ -207,7 +207,8 @@
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED
+	__LINK_STATE_RX_SCHED,
+	__LINK_STATE_LINKWATCH_PENDING
 };
 
 
@@ -630,6 +631,10 @@
  * who is responsible for serialization of these calls.
  */
 
+#ifdef CONFIG_LINKWATCH
+extern void linkwatch_fire_event(struct net_device *dev);
+#endif
+
 static inline int netif_carrier_ok(struct net_device *dev)
 {
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
@@ -639,14 +644,24 @@
 
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
diff -uNr linux-2.4.20rc1/net/Config.in linux/net/Config.in
--- linux-2.4.20rc1/net/Config.in	2002-08-03 02:39:46.000000000 +0200
+++ linux/net/Config.in	2002-11-13 22:32:46.000000000 +0100
@@ -48,6 +48,7 @@
             bool '    Per-VC IP filter kludge' CONFIG_ATM_BR2684_IPFILTER
       fi
    fi
+   bool 'Device link state notification (EXPERIMENTAL)' CONFIG_LINKWATCH
 fi
 tristate '802.1Q VLAN Support' CONFIG_VLAN_8021Q
 
diff -uNr linux-2.4.20rc1/net/core/Makefile linux/net/core/Makefile
--- linux-2.4.20rc1/net/core/Makefile	2002-08-03 02:39:46.000000000 +0200
+++ linux/net/core/Makefile	2002-11-13 22:33:32.000000000 +0100
@@ -31,4 +31,6 @@
 # Ugly. I wish all wireless drivers were moved in drivers/net/wireless
 obj-$(CONFIG_NET_PCMCIA_RADIO) += wireless.o
 
+obj-$(CONFIG_LINKWATCH) += link_watch.o
+
 include $(TOPDIR)/Rules.make
diff -uNr linux-2.4.20rc1/net/core/dev.c linux/net/core/dev.c
--- linux-2.4.20rc1/net/core/dev.c	2002-11-05 00:31:42.000000000 +0100
+++ linux/net/core/dev.c	2002-11-13 22:32:46.000000000 +0100
@@ -194,6 +194,12 @@
 #endif
 
 
+#ifdef CONFIG_LINKWATCH
+extern void linkwatch_init(void);
+extern void linkwatch_run_queue(void);
+#endif
+
+
 /******************************************************************************************
 
 		Protocol management and registration routines
@@ -2628,6 +2634,18 @@
 			/* Rebroadcast unregister notification */
 			notifier_call_chain(&netdev_chain, NETDEV_UNREGISTER, dev);
 		}
+
+#ifdef CONFIG_LINKWATCH
+		if (test_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
+			/* We must not have linkwatch events pending
+			 * on unregister. If this happens, we simply
+			 * run the queue unscheduled, resulting in a
+			 * noop for this device
+			 */
+			linkwatch_run_queue();
+		}
+#endif
+
 		current->state = TASK_INTERRUPTIBLE;
 		schedule_timeout(HZ/4);
 		current->state = TASK_RUNNING;
@@ -2675,6 +2693,10 @@
 	dv_init();
 #endif /* CONFIG_NET_DIVERT */
 	
+#ifdef CONFIG_LINKWATCH
+	linkwatch_init();
+#endif
+
 	/*
 	 *	Initialise the packet receive queues.
 	 */
diff -uNr linux-2.4.20rc1/net/core/link_watch.c linux/net/core/link_watch.c
--- linux-2.4.20rc1/net/core/link_watch.c	1970-01-01 01:00:00.000000000 +0100
+++ linux/net/core/link_watch.c	2002-11-13 22:36:44.000000000 +0100
@@ -0,0 +1,149 @@
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
+#include <linux/sched.h>
+#include <linux/timer.h>
+#include <linux/config.h>
+#include <linux/netdevice.h>
+#include <linux/if.h>
+#include <linux/rtnetlink.h>
+#include <linux/spinlock.h>
+#include <linux/list.h>
+#include <linux/slab.h>
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
+static void linkwatch_timer(unsigned long dummy);
+
+static struct tq_struct linkwatch_tq;
+static struct timer_list linkwatch_ti;
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
+static struct lw_event singleevent;
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
+static void linkwatch_timer(unsigned long dummy) {
+	(void)schedule_task(&linkwatch_tq);
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
+				(void)schedule_task(&linkwatch_tq);
+			} else {
+				linkwatch_ti.expires = linkwatch_nextevent;
+				add_timer(&linkwatch_ti);
+			}
+		}
+	}
+}
+
+
+void __init linkwatch_init(void) {
+	linkwatch_ti.function = linkwatch_timer;
+	init_timer(&linkwatch_ti);
+	INIT_TQUEUE(&linkwatch_tq, linkwatch_event, NULL);
+}
+
diff -uNr linux-2.4.20rc1/net/netsyms.c linux/net/netsyms.c
--- linux-2.4.20rc1/net/netsyms.c	2002-11-05 00:31:42.000000000 +0100
+++ linux/net/netsyms.c	2002-11-13 22:33:32.000000000 +0100
@@ -591,6 +591,10 @@
 
 EXPORT_SYMBOL(softnet_data);
 
+#ifdef CONFIG_LINKWATCH
+EXPORT_SYMBOL(linkwatch_fire_event);
+#endif
+
 #if defined(CONFIG_NET_RADIO) || defined(CONFIG_NET_PCMCIA_RADIO)
 #include <net/iw_handler.h>
 EXPORT_SYMBOL(wireless_send_event);

--------------FAD95F720EB083095E631054--
