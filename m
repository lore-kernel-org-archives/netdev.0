From: Stefan Rompf <srompf@isg.de>
Subject: Patch resubmission: RFC2863 operstatus for 2.5.49
Date: Tue, 26 Nov 2002 10:22:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE33D6D.25B9C9B4@isg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------BF3F091FE7191BF1D86D3A26"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------BF3F091FE7191BF1D86D3A26
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi David,

I've updated my RFC2863 operstatus and userspace forwarding patch to
2.5.49. As discussion on netdev seems to be complete, I need some
comment from your side.

Stefan
--------------BF3F091FE7191BF1D86D3A26
Content-Type: text/plain; charset=us-ascii;
 name="patch-rfc2863-2.5.49"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-rfc2863-2.5.49"

diff -uprNX dontdiff linux-2.5.49/include/linux/netdevice.h linux-2.5.49-lw/include/linux/netdevice.h
--- linux-2.5.49/include/linux/netdevice.h	2002-11-22 22:41:08.000000000 +0100
+++ linux-2.5.49-lw/include/linux/netdevice.h	2002-11-25 22:52:29.000000000 +0100
@@ -204,10 +204,23 @@ enum netdev_state_t
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
 
 
@@ -308,6 +321,10 @@ struct net_device
 					  * which this device is member of.
 					  */
 
+	/* Operative state, access semaphore */
+	rwlock_t                operstate_lock;
+	unsigned char           operstate;
+
 	/* Interface address info. */
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address	*/
@@ -631,34 +648,76 @@ static inline void dev_put(struct net_de
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
@@ -666,7 +725,7 @@ static inline void netif_device_detach(s
 
 static inline void netif_device_attach(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
+	if (netif_set_operstate(dev, NETDEV_OPER_UNKNOWN) == NETDEV_OPER_NOTPRESENT &&
 	    netif_running(dev)) {
 		netif_wake_queue(dev);
  		__netdev_watchdog_up(dev);
diff -uprNX dontdiff linux-2.5.49/net/Kconfig linux-2.5.49-lw/net/Kconfig
--- linux-2.5.49/net/Kconfig	2002-11-22 22:40:16.000000000 +0100
+++ linux-2.5.49-lw/net/Kconfig	2002-11-25 22:58:39.000000000 +0100
@@ -265,6 +265,20 @@ config ATM_MPOA
 config VLAN_8021Q
 	tristate "802.1Q VLAN Support"
 
+config LINKWATCH
+	bool "Device link state notification (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	help
+	  When this option is enabled, the kernel will forward changes in the
+	  operative ("RUNNING") state of an interface via the netlink socket.
+	  This is most useful when running linux as a router.
+	
+	  Note that currently not many drivers support this, compliant ones
+	  can be found by watching the the RUNNING flag in ifconfig output
+	  that should follow operative state.
+	
+	  If unsure, say 'N'.
+
 config LLC
 	tristate "ANSI/IEEE 802.2 - aka LLC (IPX, Appletalk, Token Ring)"
 	help
diff -uprNX dontdiff linux-2.5.49/net/core/Makefile linux-2.5.49-lw/net/core/Makefile
--- linux-2.5.49/net/core/Makefile	2002-11-22 22:41:08.000000000 +0100
+++ linux-2.5.49-lw/net/core/Makefile	2002-11-25 22:52:33.000000000 +0100
@@ -22,4 +22,6 @@ obj-$(CONFIG_NET_RADIO) += wireless.o
 # Ugly. I wish all wireless drivers were moved in drivers/net/wireless
 obj-$(CONFIG_NET_PCMCIA_RADIO) += wireless.o
 
+obj-$(CONFIG_LINKWATCH) += link_watch.o
+
 include $(TOPDIR)/Rules.make
diff -uprNX dontdiff linux-2.5.49/net/core/dev.c linux-2.5.49-lw/net/core/dev.c
--- linux-2.5.49/net/core/dev.c	2002-11-22 22:40:43.000000000 +0100
+++ linux-2.5.49-lw/net/core/dev.c	2002-11-25 22:52:33.000000000 +0100
@@ -199,7 +199,6 @@ int netdev_fastroute;
 int netdev_fastroute_obstacles;
 #endif
 
-
 /*******************************************************************************
 
 		Protocol management and registration routines
@@ -262,6 +261,9 @@ void dev_add_pack(struct packet_type *pt
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 }
 
+#ifdef CONFIG_LINKWATCH
+void linkwatch_run_queue(void);
+#endif
 
 /**
  *	dev_remove_pack	 - remove packet handler
@@ -2018,7 +2020,7 @@ static int dev_ifsioc(struct ifreq *ifr,
 							 IFF_RUNNING)) | 
 					 (dev->gflags & (IFF_PROMISC |
 							 IFF_ALLMULTI));
-			if (netif_running(dev) && netif_carrier_ok(dev))
+			if (netif_running(dev) && netif_operstate_to_iff_running(dev))
 				ifr->ifr_flags |= IFF_RUNNING;
 			return 0;
 
@@ -2433,6 +2435,10 @@ int register_netdevice(struct net_device
 		goto out;
 #endif /* CONFIG_NET_DIVERT */
 
+	/* Initial operstate */
+	dev->operstate_lock = RW_LOCK_UNLOCKED;
+	dev->operstate = NETDEV_OPER_UNKNOWN;
+
 	dev->iflink = -1;
 
 	/* Init, if this function is available */
@@ -2458,13 +2464,6 @@ int register_netdevice(struct net_device
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
@@ -2642,6 +2641,17 @@ int unregister_netdevice(struct net_devi
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
@@ -2736,6 +2746,8 @@ static int __init net_dev_init(void)
 #ifdef CONFIG_NET_FASTROUTE
 		dev->fastpath_lock = RW_LOCK_UNLOCKED;
 #endif
+		dev->operstate_lock = RW_LOCK_UNLOCKED;
+		dev->operstate = NETDEV_OPER_UNKNOWN;
 		dev->xmit_lock_owner = -1;
 		dev->iflink = -1;
 		dev_hold(dev);
@@ -2768,7 +2780,6 @@ static int __init net_dev_init(void)
 			if (!dev->rebuild_header)
 				dev->rebuild_header = default_rebuild_header;
 			dev_init_scheduler(dev);
-			set_bit(__LINK_STATE_PRESENT, &dev->state);
 		}
 	}
 
@@ -2849,3 +2860,5 @@ static int net_run_sbin_hotplug(struct n
 	return call_usermodehelper(argv [0], argv, envp);
 }
 #endif
+
+
diff -uprNX dontdiff linux-2.5.49/net/core/link_watch.c linux-2.5.49-lw/net/core/link_watch.c
--- linux-2.5.49/net/core/link_watch.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.5.49-lw/net/core/link_watch.c	2002-11-25 22:52:33.000000000 +0100
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
diff -uprNX dontdiff linux-2.5.49/net/core/rtnetlink.c linux-2.5.49-lw/net/core/rtnetlink.c
--- linux-2.5.49/net/core/rtnetlink.c	2002-11-22 22:41:13.000000000 +0100
+++ linux-2.5.49-lw/net/core/rtnetlink.c	2002-11-25 22:52:33.000000000 +0100
@@ -165,7 +165,7 @@ static int rtnetlink_fill_ifinfo(struct 
 	r->ifi_flags = dev->flags;
 	r->ifi_change = change;
 
-	if (!netif_running(dev) || !netif_carrier_ok(dev))
+	if (!netif_running(dev) || !netif_operstate_to_iff_running(dev))
 		r->ifi_flags &= ~IFF_RUNNING;
 	else
 		r->ifi_flags |= IFF_RUNNING;
diff -uprNX dontdiff linux-2.5.49/net/netsyms.c linux-2.5.49-lw/net/netsyms.c
--- linux-2.5.49/net/netsyms.c	2002-11-22 22:40:39.000000000 +0100
+++ linux-2.5.49-lw/net/netsyms.c	2002-11-25 22:52:33.000000000 +0100
@@ -632,4 +632,8 @@ extern void wireless_send_event(struct n
 EXPORT_SYMBOL(wireless_send_event);
 #endif	/* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
 
+#ifdef CONFIG_LINKWATCH
+EXPORT_SYMBOL(linkwatch_fire_event);
+#endif
+
 #endif  /* CONFIG_NET */


--------------BF3F091FE7191BF1D86D3A26--
