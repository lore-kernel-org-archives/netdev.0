From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 08/11] netpoll: NETPOLL_TRAP configuration change
Date: Sat, 03 Nov 2007 11:43:22 -0700
Message-ID: <20071103184338.873309086@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42207 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757863AbXKCXgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:37 -0400
Content-Disposition: inline; filename=netpoll-trap-stub.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NETPOLL_TRAP is actually not used by any in-tree code.
Rather than exposing it in kernel configuration, make it a selectable
option and make sure API is stubbed properly. I.e: if not configured
then netpoll_set_trap is not available.


Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
P.s: netpoll stuff should really be EXPORT_SYMBOL_GPL??


--- a/include/linux/netdevice.h	2007-11-03 11:30:57.000000000 -0700
+++ b/include/linux/netdevice.h	2007-11-03 11:30:59.000000000 -0700
@@ -837,8 +837,14 @@ extern int call_netdevice_notifiers(unsi
 extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
 extern int		dev_restart(struct net_device *dev);
+
 #ifdef CONFIG_NETPOLL_TRAP
 extern int		netpoll_trap(void);
+extern void		netpoll_set_trap(int trap);
+#else
+static inline int netpoll_trap(void) {
+	return 0;
+}
 #endif
 
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
@@ -918,12 +924,11 @@ static inline void netif_start_queue(str
  */
 static inline void netif_wake_queue(struct net_device *dev)
 {
-#ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap()) {
 		clear_bit(__LINK_STATE_XOFF, &dev->state);
 		return;
 	}
-#endif
+
 	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
 		__netif_schedule(dev);
 }
@@ -993,10 +998,8 @@ static inline void netif_start_subqueue(
 static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-#ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap())
 		return;
-#endif
 	set_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
 #endif
 }
@@ -1035,10 +1038,8 @@ static inline int netif_subqueue_stopped
 static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
-#ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap())
 		return;
-#endif
 	if (test_and_clear_bit(__LINK_STATE_XOFF,
 			       &dev->egress_subqueue[queue_index].state))
 		__netif_schedule(dev);
--- a/drivers/net/Kconfig	2007-11-03 11:30:57.000000000 -0700
+++ b/drivers/net/Kconfig	2007-11-03 11:30:59.000000000 -0700
@@ -3118,8 +3118,8 @@ config NETCONSOLE_DYNAMIC
 config NETPOLL
 	def_bool NETCONSOLE
 
+# If needed use select to enable
 config NETPOLL_TRAP
-	bool "Netpoll traffic trapping"
 	default n
 	depends on NETPOLL
 
--- a/net/core/netpoll.c	2007-11-03 11:30:57.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 11:31:45.000000000 -0700
@@ -803,6 +803,7 @@ void netpoll_cleanup(struct netpoll *np)
 	np->dev = NULL;
 }
 
+#ifdef CONFIG_NETPOLL_TRAP
 int netpoll_trap(void)
 {
 	return atomic_read(&trapped);
@@ -818,6 +819,8 @@ void netpoll_set_trap(int trap)
 
 EXPORT_SYMBOL(netpoll_set_trap);
 EXPORT_SYMBOL(netpoll_trap);
+#endif
+
 EXPORT_SYMBOL(netpoll_print_options);
 EXPORT_SYMBOL(netpoll_parse_options);
 EXPORT_SYMBOL(netpoll_setup);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

