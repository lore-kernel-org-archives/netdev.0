From: Stefan Rompf <srompf@isg.de>
Subject: Patch: Idea for RFC2863 conform OperStatus
Date: Sat, 12 Oct 2002 15:23:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA82269.CBB65E89@isg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------398A509A5E7D7721460CBE29"
Cc: hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------398A509A5E7D7721460CBE29
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

coming back to Jamals idea of RFC2863 conform operative state, I've made
up a short patch on how an implementation could look like. It also takes
Tims idea of one struct workstruct per device for link state
notification (slightly modified). I know it's incomplete, it doesn't
event contain the needed fix on unregister_netdev I critised on Tim's
patch, but I want to put it to discussion early. May be it breaks the
hotplugging stuff.

If we decide to go this way, we'll also need an extension to rtnetlink
and a new ioctl to transport the information to userspace.

Stefan
--------------398A509A5E7D7721460CBE29
Content-Type: text/plain; charset=us-ascii;
 name="patch-rfc2863-2.5.41"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-rfc2863-2.5.41"

diff -rNuX dontdiff linux-2.5.41/include/linux/netdevice.h linux-2.5.41-stefan/include/linux/netdevice.h
--- linux-2.5.41/include/linux/netdevice.h	Tue Oct  8 22:18:50 2002
+++ linux-2.5.41-stefan/include/linux/netdevice.h	Sat Oct 12 14:33:20 2002
@@ -39,6 +39,10 @@
 #include <net/profile.h>
 #endif
 
+#ifdef CONFIG_LINKWATCH
+#include <linux/workqueue.h>
+#endif
+
 struct divert_blk;
 struct vlan_group;
 
@@ -204,13 +208,25 @@
 {
 	__LINK_STATE_XOFF=0,
 	__LINK_STATE_START,
-	__LINK_STATE_PRESENT,
+	__LINK_STATE_PRESENT_OBSOLETE,
 	__LINK_STATE_SCHED,
-	__LINK_STATE_NOCARRIER,
+	__LINK_STATE_NOCARRIER_OBSOLETE,
 	__LINK_STATE_RX_SCHED
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
@@ -308,6 +324,15 @@
 					  * which this device is member of.
 					  */
 
+	/* Operative state, semaphore and work_struct for
+	 * userspace notification
+	 */
+#ifdef CONFIG_LINKWATCH
+	struct work_struct      linkwatch_work;
+#endif
+	rwlock_t                operstate_lock;
+	unsigned short          operstate;
+
 	/* Interface address info. */
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address	*/
@@ -631,34 +656,77 @@
  * who is responsible for serialization of these calls.
  */
 
+#ifdef CONFIG_LINKWATCH
+extern void netdev_fire_linkwatch_event(struct net_device *dev);
+#endif
+
+static inline unsigned short netif_set_operstate(struct net_device *dev, unsigned short newstate)
+{
+	unsigned long flags;
+	unsigned short oldstate;
+
+	write_lock_irqsave(&dev->operstate_lock, flags);
+	oldstate = dev->operstate;
+	dev->operstate = newstate;
+	write_unlock_irqrestore(&dev->operstate_lock, flags);
+
+#ifdef CONFIG_LINKWATCH
+	if (oldstate != newstate) netdev_fire_linkwatch_event(dev);
+#endif
+
+	return oldstate;
+}
+
+static inline unsigned short netif_get_operstate(struct net_device *dev)
+{
+	unsigned long flags;
+	unsigned short state;
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
+	return netif_get_operstate(dev) == NETDEV_OPER_UP;
+}
+
+static inline int netif_operstate_to_iff_running(struct net_device *dev)
+{
+	unsigned short state = netif_get_operstate(dev);
+
+	return((1 << state) &
+	       (1 << NETDEV_OPER_UP | 1 << NETDEV_OPER_TESTING |
+		1 << NETDEV_OPER_UNKNOWN));
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
@@ -666,7 +734,7 @@
 
 static inline void netif_device_attach(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
+	if (netif_set_operstate(dev, NETDEV_OPER_UNKNOWN) == NETDEV_OPER_NOTPRESENT &&
 	    netif_running(dev)) {
 		netif_wake_queue(dev);
  		__netdev_watchdog_up(dev);
diff -rNuX dontdiff linux-2.5.41/net/Config.help linux-2.5.41-stefan/net/Config.help
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
diff -rNuX dontdiff linux-2.5.41/net/Config.in linux-2.5.41-stefan/net/Config.in
--- linux-2.5.41/net/Config.in	Tue Oct  1 09:06:24 2002
+++ linux-2.5.41-stefan/net/Config.in	Tue Oct  8 22:44:07 2002
@@ -82,6 +82,7 @@
    tristate 'WAN router' CONFIG_WAN_ROUTER
    bool 'Fast switching (read help!)' CONFIG_NET_FASTROUTE
    bool 'Forwarding between high speed interfaces' CONFIG_NET_HW_FLOWCONTROL
+   bool 'Device link state notification (EXPERIMENTAL)' CONFIG_LINKWATCH
 fi
 
 mainmenu_option next_comment
diff -rNuX dontdiff linux-2.5.41/net/core/dev.c linux-2.5.41-stefan/net/core/dev.c
--- linux-2.5.41/net/core/dev.c	Tue Oct  8 22:18:51 2002
+++ linux-2.5.41-stefan/net/core/dev.c	Sat Oct 12 14:54:25 2002
@@ -198,6 +198,9 @@
 int netdev_fastroute_obstacles;
 #endif
 
+#ifdef CONFIG_LINKWATCH
+static void netdev_linkwatch_event(void *data);
+#endif
 
 /*******************************************************************************
 
@@ -716,6 +719,8 @@
 		 *	Set the flags.
 		 */
 		dev->flags |= IFF_UP;
+		if (netif_operstate_to_iff_running(dev))
+			dev->flags |= IFF_RUNNING;
 
 		/*
 		 *	Initialize multicasting status
@@ -2017,7 +2022,7 @@
 							 IFF_RUNNING)) | 
 					 (dev->gflags & (IFF_PROMISC |
 							 IFF_ALLMULTI));
-			if (netif_running(dev) && netif_carrier_ok(dev))
+			if (netif_running(dev) && netif_operstate_to_iff_running(dev))
 				ifr->ifr_flags |= IFF_RUNNING;
 			return 0;
 
@@ -2432,6 +2437,13 @@
 		goto out;
 #endif /* CONFIG_NET_DIVERT */
 
+	/* Initial operstate */
+	dev->operstate_lock = RW_LOCK_UNLOCKED;
+	dev->operstate = NETDEV_OPER_UNKNOWN;
+#ifdef CONFIG_LINKWATCH
+	INIT_WORK(&dev->linkwatch_work, netdev_linkwatch_event, dev); // FIXME
+#endif
+
 	dev->iflink = -1;
 
 	/* Init, if this function is available */
@@ -2457,13 +2469,6 @@
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
@@ -2735,6 +2740,11 @@
 #ifdef CONFIG_NET_FASTROUTE
 		dev->fastpath_lock = RW_LOCK_UNLOCKED;
 #endif
+		dev->operstate_lock = RW_LOCK_UNLOCKED;
+		dev->operstate = NETDEV_OPER_UNKNOWN;
+#ifdef CONFIG_LINKWATCH
+		INIT_WORK(&dev->linkwatch_work, netdev_linkwatch_event, dev); // FIXME
+#endif
 		dev->xmit_lock_owner = -1;
 		dev->iflink = -1;
 		dev_hold(dev);
@@ -2767,7 +2777,6 @@
 			if (!dev->rebuild_header)
 				dev->rebuild_header = default_rebuild_header;
 			dev_init_scheduler(dev);
-			set_bit(__LINK_STATE_PRESENT, &dev->state);
 		}
 	}
 
@@ -2848,3 +2857,32 @@
 	return call_usermodehelper(argv [0], argv, envp);
 }
 #endif
+
+
+#ifdef CONFIG_LINKWATCH
+static void netdev_linkwatch_event(void *data) {
+	struct net_device *dev = data;
+	unsigned int iff_running = netif_operstate_to_iff_running(dev);
+
+	rtnl_lock();
+	if (dev->flags & IFF_RUNNING && !iff_running) {
+		write_lock(&dev_base_lock);
+		dev->flags &= ~IFF_RUNNING;
+		write_unlock(&dev_base_lock);
+		netdev_state_change(dev);
+	} else if (!(dev->flags & IFF_RUNNING)) {
+		write_lock(&dev_base_lock);
+		dev->flags |= IFF_RUNNING;
+		write_unlock(&dev_base_lock);
+		netdev_state_change(dev);
+	}
+	rtnl_unlock();
+}
+
+
+void netdev_fire_linkwatch_event(struct net_device *dev) {
+	schedule_delayed_work(&dev->linkwatch_work, HZ / 4);
+}
+
+#endif
+
diff -rNuX dontdiff linux-2.5.41/net/core/rtnetlink.c linux-2.5.41-stefan/net/core/rtnetlink.c
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
diff -rNuX dontdiff linux-2.5.41/net/netsyms.c linux-2.5.41-stefan/net/netsyms.c
--- linux-2.5.41/net/netsyms.c	Tue Oct  8 22:18:53 2002
+++ linux-2.5.41-stefan/net/netsyms.c	Sat Oct 12 14:34:38 2002
@@ -596,4 +596,8 @@
 EXPORT_SYMBOL(wireless_send_event);
 #endif	/* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
 
+#ifdef CONFIG_LINKWATCH
+EXPORT_SYMBOL(netdev_fire_linkwatch_event);
+#endif
+
 #endif  /* CONFIG_NET */


--------------398A509A5E7D7721460CBE29--
