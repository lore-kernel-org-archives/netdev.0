From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Tue, 03 Dec 2002 23:22:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DED2EA9.D812C881@isg.de>
References: <3DE33D6D.25B9C9B4@isg.de> <20021126.021546.91313706.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------DD5A4FC259A764B48D9E75EC"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------DD5A4FC259A764B48D9E75EC
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi David,

here is an updated version with the following changes:

-split the patch: First adds the userspace notification, the other
(depends on the first) RFC2863 semantics. I am aware that we are well
beyond feature freeze, and it makes the code more readable.
-simplified locking as suggested
-made the notification unconditional. We want it ;-)
-fixed a bug in RFC2863 netif_carrier_ok() emulation (was !=, should be
==)

Can you have a look?

Stefan


"David S. Miller" wrote:
> 
> This locking below achieves nothing.
> 
> +       read_lock_irqsave(&dev->operstate_lock, flags);
> +       state = dev->operstate;
> +       read_unlock_irqrestore(&dev->operstate_lock, flags);
> 
> In fact, the other side, locking when setting this value, can
> be done with a simple spinlock.  Probably something else in
> the device struct can be reused.
> 
> I also don't think this should be conditional, either we want
> it or we don't.
--------------DD5A4FC259A764B48D9E75EC
Content-Type: text/plain; charset=us-ascii;
 name="patch-lw-2.5.50"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-lw-2.5.50"

diff -urN linux-2.5.50/include/linux/netdevice.h linux-2.5.50-lw/include/linux/netdevice.h
--- linux-2.5.50/include/linux/netdevice.h	2002-11-22 22:41:08.000000000 +0100
+++ linux-2.5.50-lw/include/linux/netdevice.h	2002-12-02 22:56:34.000000000 +0100
@@ -207,7 +207,8 @@
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED
+	__LINK_STATE_RX_SCHED,
+	__LINK_STATE_LINKWATCH_PENDING
 };
 
 
@@ -631,6 +632,8 @@
  * who is responsible for serialization of these calls.
  */
 
+extern void linkwatch_fire_event(struct net_device *dev);
+
 static inline int netif_carrier_ok(struct net_device *dev)
 {
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
@@ -640,14 +643,16 @@
 
 static inline void netif_carrier_on(struct net_device *dev)
 {
-	clear_bit(__LINK_STATE_NOCARRIER, &dev->state);
+	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state))
+		linkwatch_fire_event(dev);
 	if (netif_running(dev))
 		__netdev_watchdog_up(dev);
 }
 
 static inline void netif_carrier_off(struct net_device *dev)
 {
-	set_bit(__LINK_STATE_NOCARRIER, &dev->state);
+	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state))
+		linkwatch_fire_event(dev);
 }
 
 /* Hot-plugging. */
diff -urN linux-2.5.50/net/core/Makefile linux-2.5.50-lw/net/core/Makefile
--- linux-2.5.50/net/core/Makefile	2002-12-02 22:37:15.000000000 +0100
+++ linux-2.5.50-lw/net/core/Makefile	2002-12-02 23:16:18.000000000 +0100
@@ -12,7 +12,7 @@
 
 obj-$(CONFIG_FILTER) += filter.o
 
-obj-$(CONFIG_NET) += dev.o dev_mcast.o dst.o neighbour.o rtnetlink.o utils.o
+obj-$(CONFIG_NET) += dev.o dev_mcast.o dst.o neighbour.o rtnetlink.o utils.o link_watch.o
 
 obj-$(CONFIG_NETFILTER) += netfilter.o
 obj-$(CONFIG_NET_DIVERT) += dv.o
diff -urN linux-2.5.50/net/core/dev.c linux-2.5.50-lw/net/core/dev.c
--- linux-2.5.50/net/core/dev.c	2002-11-22 22:40:43.000000000 +0100
+++ linux-2.5.50-lw/net/core/dev.c	2002-12-02 23:08:47.000000000 +0100
@@ -262,6 +262,7 @@
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 }
 
+void linkwatch_run_queue(void);
 
 /**
  *	dev_remove_pack	 - remove packet handler
@@ -2642,6 +2643,15 @@
 			/* Rebroadcast unregister notification */
 			notifier_call_chain(&netdev_chain,
 					    NETDEV_UNREGISTER, dev);
+
+			if (test_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
+				/* We must not have linkwatch events pending
+				 * on unregister. If this happens, we simply
+				 * run the queue unscheduled, resulting in a
+				 * noop for this device
+				 */
+				linkwatch_run_queue();
+			}
 		}
 		current->state = TASK_INTERRUPTIBLE;
 		schedule_timeout(HZ / 4);
diff -urN linux-2.5.50/net/core/link_watch.c linux-2.5.50-lw/net/core/link_watch.c
--- linux-2.5.50/net/core/link_watch.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.5.50-lw/net/core/link_watch.c	2002-12-02 22:35:00.000000000 +0100
@@ -0,0 +1,134 @@
+/*
+ * Linux network device link state notifaction
+ *
+ * Author:
+ *     Stefan Rompf <sux@loplof.de>
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
diff -urN linux-2.5.50/net/netsyms.c linux-2.5.50-lw/net/netsyms.c
--- linux-2.5.50/net/netsyms.c	2002-11-22 22:40:39.000000000 +0100
+++ linux-2.5.50-lw/net/netsyms.c	2002-12-02 23:09:51.000000000 +0100
@@ -632,4 +632,6 @@
 EXPORT_SYMBOL(wireless_send_event);
 #endif	/* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
 
+EXPORT_SYMBOL(linkwatch_fire_event);
+
 #endif  /* CONFIG_NET */

--------------DD5A4FC259A764B48D9E75EC
Content-Type: text/plain; charset=us-ascii;
 name="patch-lw-2.5.50-rfc2863"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-lw-2.5.50-rfc2863"

diff -urN linux-2.5.50-lw/include/linux/netdevice.h linux-2.5.50-lw-rfc2863/include/linux/netdevice.h
--- linux-2.5.50-lw/include/linux/netdevice.h	2002-12-02 22:56:34.000000000 +0100
+++ linux-2.5.50-lw-rfc2863/include/linux/netdevice.h	2002-12-02 22:45:14.000000000 +0100
@@ -204,14 +204,26 @@
 {
 	__LINK_STATE_XOFF=0,
 	__LINK_STATE_START,
-	__LINK_STATE_PRESENT,
+	__LINK_STATE_PRESENT_OBSOLETE,
 	__LINK_STATE_SCHED,
-	__LINK_STATE_NOCARRIER,
+	__LINK_STATE_NOCARRIER_OBSOLETE,
 	__LINK_STATE_RX_SCHED,
 	__LINK_STATE_LINKWATCH_PENDING
 };
 
 
+/* Device operative state as per RFC2863 */
+enum netdev_operstate_t {
+	NETDEV_OPER_UP = 1,
+	NETDEV_OPER_DOWN, /* Obsoletes LINK_STATE_NOCARRIER */
+	NETDEV_OPER_TESTING,
+	NETDEV_OPER_UNKNOWN,
+	NETDEV_OPER_DORMANT,
+	NETDEV_OPER_NOTPRESENT, /* Obsoletes !LINK_STATE_PRESENT */
+	NETDEV_OPER_LOWERDOWN
+};
+
+
 /*
  * This structure holds at boot time configured netdevice settings. They
  * are then used in the device probing. 
@@ -309,6 +321,10 @@
 					  * which this device is member of.
 					  */
 
+	/* Operative state, access semaphore */
+	spinlock_t              operstate_lock;
+	unsigned char           operstate;
+
 	/* Interface address info. */
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address	*/
@@ -634,36 +650,63 @@
 
 extern void linkwatch_fire_event(struct net_device *dev);
 
+static inline unsigned char netif_set_operstate(struct net_device *dev, unsigned char newstate)
+{
+	unsigned long flags;
+	unsigned char oldstate;
+
+	spin_lock_irqsave(&dev->operstate_lock, flags);
+	oldstate = dev->operstate;
+	dev->operstate = newstate;
+	spin_unlock_irqrestore(&dev->operstate_lock, flags);
+
+	if (oldstate != newstate) linkwatch_fire_event(dev);
+
+	return oldstate;
+}
+
+static inline unsigned char netif_get_operstate(struct net_device *dev)
+{
+	return(dev->operstate);
+}
+
 static inline int netif_carrier_ok(struct net_device *dev)
 {
-	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
+	return netif_get_operstate(dev) == NETDEV_OPER_UP;
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
-	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state))
-		linkwatch_fire_event(dev);
+	netif_set_operstate(dev, NETDEV_OPER_UP);
 	if (netif_running(dev))
 		__netdev_watchdog_up(dev);
 }
 
 static inline void netif_carrier_off(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state))
-		linkwatch_fire_event(dev);
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
@@ -671,7 +714,7 @@
 
 static inline void netif_device_attach(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
+	if (netif_set_operstate(dev, NETDEV_OPER_UNKNOWN) == NETDEV_OPER_NOTPRESENT &&
 	    netif_running(dev)) {
 		netif_wake_queue(dev);
  		__netdev_watchdog_up(dev);
diff -urN linux-2.5.50-lw/net/core/dev.c linux-2.5.50-lw-rfc2863/net/core/dev.c
--- linux-2.5.50-lw/net/core/dev.c	2002-12-02 23:08:47.000000000 +0100
+++ linux-2.5.50-lw-rfc2863/net/core/dev.c	2002-12-02 23:22:03.000000000 +0100
@@ -199,7 +199,6 @@
 int netdev_fastroute_obstacles;
 #endif
 
-
 /*******************************************************************************
 
 		Protocol management and registration routines
@@ -2019,7 +2018,7 @@
 							 IFF_RUNNING)) | 
 					 (dev->gflags & (IFF_PROMISC |
 							 IFF_ALLMULTI));
-			if (netif_running(dev) && netif_carrier_ok(dev))
+			if (netif_running(dev) && netif_operstate_to_iff_running(dev))
 				ifr->ifr_flags |= IFF_RUNNING;
 			return 0;
 
@@ -2434,6 +2433,10 @@
 		goto out;
 #endif /* CONFIG_NET_DIVERT */
 
+	/* Initial operstate */
+	spin_lock_init(&dev->operstate_lock);
+	dev->operstate = NETDEV_OPER_UNKNOWN;
+
 	dev->iflink = -1;
 
 	/* Init, if this function is available */
@@ -2459,13 +2462,6 @@
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
@@ -2746,6 +2742,8 @@
 #ifdef CONFIG_NET_FASTROUTE
 		dev->fastpath_lock = RW_LOCK_UNLOCKED;
 #endif
+		spin_lock_init(&dev->operstate_lock);
+		dev->operstate = NETDEV_OPER_UNKNOWN;
 		dev->xmit_lock_owner = -1;
 		dev->iflink = -1;
 		dev_hold(dev);
@@ -2778,7 +2776,6 @@
 			if (!dev->rebuild_header)
 				dev->rebuild_header = default_rebuild_header;
 			dev_init_scheduler(dev);
-			set_bit(__LINK_STATE_PRESENT, &dev->state);
 		}
 	}
 
diff -urN linux-2.5.50-lw/net/core/rtnetlink.c linux-2.5.50-lw-rfc2863/net/core/rtnetlink.c
--- linux-2.5.50-lw/net/core/rtnetlink.c	2002-11-22 22:41:13.000000000 +0100
+++ linux-2.5.50-lw-rfc2863/net/core/rtnetlink.c	2002-12-02 22:35:00.000000000 +0100
@@ -165,7 +165,7 @@
 	r->ifi_flags = dev->flags;
 	r->ifi_change = change;
 
-	if (!netif_running(dev) || !netif_carrier_ok(dev))
+	if (!netif_running(dev) || !netif_operstate_to_iff_running(dev))
 		r->ifi_flags &= ~IFF_RUNNING;
 	else
 		r->ifi_flags |= IFF_RUNNING;

--------------DD5A4FC259A764B48D9E75EC--
