From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] netdevice: kernel docbook addition
Date: Wed, 22 Aug 2007 12:33:14 -0700
Message-ID: <20070822123314.785dea2a@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59085 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753623AbXHVTdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 15:33:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add more kernel doc's for part of the network device API.
This is only a start, and needs more work.

Applies against net-2.6.24

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/Documentation/DocBook/kernel-api.tmpl	2007-08-21 15:43:37.000000000 -0700
+++ b/Documentation/DocBook/kernel-api.tmpl	2007-08-22 12:30:33.000000000 -0700
@@ -240,17 +240,23 @@ X!Ilib/string.c
      <sect1><title>Driver Support</title>
 !Enet/core/dev.c
 !Enet/ethernet/eth.c
+!Enet/sched/sch_generic.c
 !Iinclude/linux/etherdevice.h
+!Iinclude/linux/netdevice.h
+     </sect1>
+     <sect1><title>PHY Support</title>
 !Edrivers/net/phy/phy.c
 !Idrivers/net/phy/phy.c
 !Edrivers/net/phy/phy_device.c
 !Idrivers/net/phy/phy_device.c
 !Edrivers/net/phy/mdio_bus.c
 !Idrivers/net/phy/mdio_bus.c
+     </sect1>
 <!-- FIXME: Removed for now since no structured comments in source
+     <sect1><title>Wireless</title>
 X!Enet/core/wireless.c
--->
      </sect1>
+-->
      <sect1><title>Synchronous PPP</title>
 !Edrivers/net/wan/syncppp.c
      </sect1>
--- a/include/linux/netdevice.h	2007-08-21 15:44:00.000000000 -0700
+++ b/include/linux/netdevice.h	2007-08-22 12:00:16.000000000 -0700
@@ -302,17 +302,38 @@ enum
 
 extern void FASTCALL(__napi_schedule(struct napi_struct *n));
 
+/**
+ *	napi_schedule_prep - check if napi can be scheduled
+ *	@n: napi context
+ *
+ * Test if NAPI routine is already running, and if not mark
+ * it as running.  This is used as a condition variable
+ * insure only one NAPI poll instance runs
+ */
 static inline int napi_schedule_prep(struct napi_struct *n)
 {
 	return !test_and_set_bit(NAPI_STATE_SCHED, &n->state);
 }
 
+/**
+ *	napi_schedule - schedule NAPI poll
+ *	@n: napi context
+ *
+ * Schedule NAPI poll routine to be called if it is not already
+ * running.
+ */
 static inline void napi_schedule(struct napi_struct *n)
 {
 	if (napi_schedule_prep(n))
 		__napi_schedule(n);
 }
 
+/**
+ *	napi_complete - NAPI processing complete
+ *	@n: napi context
+ *
+ * Mark NAPI processing as complete.
+ */
 static inline void napi_complete(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
@@ -320,12 +341,26 @@ static inline void napi_complete(struct 
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
 
+/**
+ *	napi_disable - prevent NAPI from scheduling
+ *	@n: napi context
+ *
+ * Stop NAPI from being scheduled on this context.
+ * Waits till any outstanding processing completes.
+ */
 static inline void napi_disable(struct napi_struct *n)
 {
 	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
 		msleep_interruptible(1);
 }
 
+/**
+ *	napi_disable - prevent NAPI from scheduling
+ *	@n: napi context
+ *
+ * Resume NAPI from being scheduled on this context.
+ * Must be paired with napi_disable.
+ */
 static inline void napi_enable(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
@@ -636,6 +671,12 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
+/**
+ *	netdev_priv - access network device private data
+ *	@dev: network device
+ *
+ * Get network device private data
+ */
 static inline void *netdev_priv(const struct net_device *dev)
 {
 	return dev->priv;
@@ -773,11 +814,24 @@ static inline void netif_schedule(struct
 		__netif_schedule(dev);
 }
 
+/**
+ *	netif_start_queue - allow transmit
+ *	@dev: network device
+ *
+ *	Allow upper layers to call the device hard_start_xmit routine.
+ */
 static inline void netif_start_queue(struct net_device *dev)
 {
 	clear_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
+/**
+ *	netif_wake_queue - restart transmit
+ *	@dev: network device
+ *
+ *	Allow upper layers to call the device hard_start_xmit routine.
+ *	Used for flow control when transmit resources are available.
+ */
 static inline void netif_wake_queue(struct net_device *dev)
 {
 #ifdef CONFIG_NETPOLL_TRAP
@@ -790,16 +844,35 @@ static inline void netif_wake_queue(stru
 		__netif_schedule(dev);
 }
 
+/**
+ *	netif_stop_queue - stop transmitted packets
+ *	@dev: network device
+ *
+ *	Stop upper layers calling the device hard_start_xmit routine.
+ *	Used for flow control when transmit resources are unavailable.
+ */
 static inline void netif_stop_queue(struct net_device *dev)
 {
 	set_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
+/**
+ *	netif_queue_stopped - test if transmit queue is flowblocked
+ *	@dev: network device
+ *
+ *	Test if transmit queue on device is currently unable to send.
+ */
 static inline int netif_queue_stopped(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
+/**
+ *	netif_running - test if up
+ *	@dev: network device
+ *
+ *	Test if the device has been brought up.
+ */
 static inline int netif_running(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_START, &dev->state);
@@ -811,6 +884,14 @@ static inline int netif_running(const st
  * done at the overall netdevice level.
  * Also test the device if we're multiqueue.
  */
+
+/**
+ *	netif_start_subqueue - allow sending packets on subqueue
+ *	@dev: network device
+ *	@queue_index: sub queue index
+ *
+ * Start individual transmit queue of a device with multiple transmit queues.
+ */
 static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
@@ -818,6 +899,13 @@ static inline void netif_start_subqueue(
 #endif
 }
 
+/**
+ *	netif_stop_subqueue - stop sending packets on subqueue
+ *	@dev: network device
+ *	@queue_index: sub queue index
+ *
+ * Stop individual transmit queue of a device with multiple transmit queues.
+ */
 static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
@@ -829,6 +917,13 @@ static inline void netif_stop_subqueue(s
 #endif
 }
 
+/**
+ *	netif_subqueue_stopped - test status of subqueue
+ *	@dev: network device
+ *	@queue_index: sub queue index
+ *
+ * Check individual transmit queue of a device with multiple transmit queues.
+ */
 static inline int netif_subqueue_stopped(const struct net_device *dev,
 					 u16 queue_index)
 {
@@ -840,6 +935,14 @@ static inline int netif_subqueue_stopped
 #endif
 }
 
+
+/**
+ *	netif_wake_subqueue - allow sending packets on subqueue
+ *	@dev: network device
+ *	@queue_index: sub queue index
+ *
+ * Resume individual transmit queue of a device with multiple transmit queues.
+ */
 static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
@@ -853,6 +956,13 @@ static inline void netif_wake_subqueue(s
 #endif
 }
 
+/**
+ *	netif_is_multiqueue - test if device has multiple transmit queues
+ *	@dev: network device
+ *
+ * Check if device has multiple transmit queues
+ * Always falls if NETDEVICE_MULTIQUEUE is not configured
+ */
 static inline int netif_is_multiqueue(const struct net_device *dev)
 {
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
@@ -889,18 +999,28 @@ extern int		dev_set_mac_address(struct n
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
 
-extern void		dev_init(void);
-
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
 extern void netdev_run_todo(void);
 
+/**
+ *	dev_put - get reference to device
+ *	@dev: network device
+ *
+ * Hold reference to device to keep it from being freed.
+ */
 static inline void dev_put(struct net_device *dev)
 {
 	atomic_dec(&dev->refcnt);
 }
 
+/**
+ *	dev_hold - release reference to device
+ *	@dev: network device
+ *
+ * Release reference to device to allow it to be freed.
+ */
 static inline void dev_hold(struct net_device *dev)
 {
 	atomic_inc(&dev->refcnt);
@@ -917,6 +1037,12 @@ static inline void dev_hold(struct net_d
 
 extern void linkwatch_fire_event(struct net_device *dev);
 
+/**
+ *	netif_carrier_ok - test if carrier present
+ *	@dev: network device
+ *
+ * Check if carrier is present on device
+ */
 static inline int netif_carrier_ok(const struct net_device *dev)
 {
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
@@ -928,30 +1054,66 @@ extern void netif_carrier_on(struct net_
 
 extern void netif_carrier_off(struct net_device *dev);
 
+/**
+ *	netif_dormant_on - mark device as dormant.
+ *	@dev: network device
+ *
+ * Mark device as dormant (as per RFC2863).
+ *
+ * The dormant state indicates that the relevant interface is not
+ * actually in a condition to pass packets (i.e., it is not 'up') but is
+ * in a "pending" state, waiting for some external event.  For "on-
+ * demand" interfaces, this new state identifies the situation where the
+ * interface is waiting for events to place it in the up state.
+ *
+ */
 static inline void netif_dormant_on(struct net_device *dev)
 {
 	if (!test_and_set_bit(__LINK_STATE_DORMANT, &dev->state))
 		linkwatch_fire_event(dev);
 }
 
+/**
+ *	netif_dormant_off - set device as not dormant.
+ *	@dev: network device
+ *
+ * Device is not in dormant state.
+ */
 static inline void netif_dormant_off(struct net_device *dev)
 {
 	if (test_and_clear_bit(__LINK_STATE_DORMANT, &dev->state))
 		linkwatch_fire_event(dev);
 }
 
+/**
+ *	netif_dormant - test if carrier present
+ *	@dev: network device
+ *
+ * Check if carrier is present on device
+ */
 static inline int netif_dormant(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_DORMANT, &dev->state);
 }
 
 
+/**
+ *	netif_oper_up - test if device is operational
+ *	@dev: network device
+ *
+ * Check if carrier is operational
+ */
 static inline int netif_oper_up(const struct net_device *dev) {
 	return (dev->operstate == IF_OPER_UP ||
 		dev->operstate == IF_OPER_UNKNOWN /* backward compat */);
 }
 
-/* Hot-plugging. */
+/**
+ *	netif_device_present - is device available or removed
+ *	@dev: network device
+ *
+ * Check if device has not been removed from system.
+ */
 static inline int netif_device_present(struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_PRESENT, &dev->state);
@@ -1080,6 +1242,12 @@ static inline void netif_rx_complete(str
 	local_irq_restore(flags);
 }
 
+/**
+ *	netif_tx_lock - grab network device transmit lock
+ *	@dev: network device
+ *
+ * Get network device transmit lock
+ */
 static inline void netif_tx_lock(struct net_device *dev)
 {
 	spin_lock(&dev->_xmit_lock);
--- a/net/core/dev.c	2007-08-21 15:44:04.000000000 -0700
+++ b/net/core/dev.c	2007-08-22 11:51:53.000000000 -0700
@@ -1256,7 +1256,12 @@ void dev_kfree_skb_any(struct sk_buff *s
 EXPORT_SYMBOL(dev_kfree_skb_any);
 
 
-/* Hot-plugging. */
+/**
+ * netif_device_detach - mark device as removed
+ * @dev: network device
+ *
+ * Mark device as removed from system and therefore no longer available.
+ */
 void netif_device_detach(struct net_device *dev)
 {
 	if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
@@ -1266,6 +1271,12 @@ void netif_device_detach(struct net_devi
 }
 EXPORT_SYMBOL(netif_device_detach);
 
+/**
+ * netif_device_attach - mark device as attached
+ * @dev: network device
+ *
+ * Mark device as attached from system and restart if needed.
+ */
 void netif_device_attach(struct net_device *dev)
 {
 	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
--- a/net/sched/sch_generic.c	2007-08-21 15:44:05.000000000 -0700
+++ b/net/sched/sch_generic.c	2007-08-22 11:51:53.000000000 -0700
@@ -256,6 +256,12 @@ static void dev_watchdog_down(struct net
 	netif_tx_unlock_bh(dev);
 }
 
+/**
+ *	netif_carrier_on - set carrier
+ *	@dev: network device
+ *
+ * Device has detected that carrier.
+ */
 void netif_carrier_on(struct net_device *dev)
 {
 	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state))
@@ -264,6 +270,12 @@ void netif_carrier_on(struct net_device 
 		__netdev_watchdog_up(dev);
 }
 
+/**
+ *	netif_carrier_off - clear carrier
+ *	@dev: network device
+ *
+ * Device has detected loss of carrier.
+ */
 void netif_carrier_off(struct net_device *dev)
 {
 	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state))
