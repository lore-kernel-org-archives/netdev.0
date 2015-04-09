From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3 net-next] net_device: Reorder members to fill holes
Date: Fri, 10 Apr 2015 01:43:27 +0200
Message-ID: <68f97175f41297dca5cb1e2092890c9d1da0d16a.1428622095.git.tgraf@suug.ch>
References: <cover.1428622095.git.tgraf@suug.ch>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56814 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754239AbbDIXnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 19:43:40 -0400
In-Reply-To: <cover.1428622095.git.tgraf@suug.ch>
In-Reply-To: <cover.1428622095.git.tgraf@suug.ch>
References: <cover.1428622095.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some trivial reorders while preserving the RX/TX cache lines
split to fill a couple of holes.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/netdevice.h | 39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4653422..af8e9b0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1305,6 +1305,8 @@ enum netdev_priv_flags {
  *	@base_addr:	Device I/O address
  *	@irq:		Device IRQ number
  *
+ *	@carrier_changes:	Stats to monitor carrier on<->off transitions
+ *
  *	@state:		Generic network queuing layer state, see netdev_state_t
  *	@dev_list:	The global list of network devices
  *	@napi_list:	List entry, that is used for polling napi devices
@@ -1338,8 +1340,6 @@ enum netdev_priv_flags {
  *	@tx_dropped:	Dropped packets by core network,
  *			do not use this in drivers
  *
- *	@carrier_changes:	Stats to monitor carrier on<->off transitions
- *
  *	@wireless_handlers:	List of functions to handle Wireless Extensions,
  *				instead of ioctl,
  *				see <net/iw_handler.h> for details.
@@ -1382,14 +1382,14 @@ enum netdev_priv_flags {
  * 	@dev_port:		Used to differentiate devices that share
  * 				the same function
  *	@addr_list_lock:	XXX: need comments on this one
- *	@uc:			unicast mac addresses
- *	@mc:			multicast mac addresses
- *	@dev_addrs:		list of device hw addresses
- *	@queues_kset:		Group of all Kobjects in the Tx and RX queues
  *	@uc_promisc:		Counter, that indicates, that promiscuous mode
  *				has been enabled due to the need to listen to
  *				additional unicast addresses in a device that
  *				does not implement ndo_set_rx_mode()
+ *	@uc:			unicast mac addresses
+ *	@mc:			multicast mac addresses
+ *	@dev_addrs:		list of device hw addresses
+ *	@queues_kset:		Group of all Kobjects in the Tx and RX queues
  *	@promiscuity:		Number of times, the NIC is told to work in
  *				Promiscuous mode, if it becomes 0 the NIC will
  *				exit from working in Promiscuous mode
@@ -1419,6 +1419,11 @@ enum netdev_priv_flags {
  *	@ingress_queue:		XXX: need comments on this one
  *	@broadcast:		hw bcast address
  *
+ *	@rx_cpu_rmap:	CPU reverse-mapping for RX completion interrupts,
+ *			indexed by RX queue number. Assigned by driver.
+ *			This must only be set if the ndo_rx_flow_steer
+ *			operation is defined
+ *
  *	@_tx:			Array of TX queues
  *	@num_tx_queues:		Number of TX queues allocated at alloc_netdev_mq() time
  *	@real_num_tx_queues: 	Number of TX queues currently active in device
@@ -1428,11 +1433,6 @@ enum netdev_priv_flags {
  *
  *	@xps_maps:	XXX: need comments on this one
  *
- *	@rx_cpu_rmap:	CPU reverse-mapping for RX completion interrupts,
- *			indexed by RX queue number. Assigned by driver.
- *			This must only be set if the ndo_rx_flow_steer
- *			operation is defined
- *
  *	@trans_start:		Time (in jiffies) of last Tx
  *	@watchdog_timeo:	Represents the timeout that is used by
  *				the watchdog ( see dev_watchdog() )
@@ -1507,6 +1507,8 @@ struct net_device {
 	unsigned long		base_addr;
 	int			irq;
 
+	atomic_t		carrier_changes;
+
 	/*
 	 *	Some hardware also needs these fields (state,dev_list,
 	 *	napi_list,unreg_list,close_list) but they are not
@@ -1547,8 +1549,6 @@ struct net_device {
 	atomic_long_t		rx_dropped;
 	atomic_long_t		tx_dropped;
 
-	atomic_t		carrier_changes;
-
 #ifdef CONFIG_WIRELESS_EXT
 	const struct iw_handler_def *	wireless_handlers;
 	struct iw_public_data *	wireless_data;
@@ -1588,6 +1588,8 @@ struct net_device {
 	unsigned short          dev_id;
 	unsigned short          dev_port;
 	spinlock_t		addr_list_lock;
+	unsigned char		name_assign_type;
+	bool			uc_promisc;
 	struct netdev_hw_addr_list	uc;
 	struct netdev_hw_addr_list	mc;
 	struct netdev_hw_addr_list	dev_addrs;
@@ -1595,10 +1597,6 @@ struct net_device {
 #ifdef CONFIG_SYSFS
 	struct kset		*queues_kset;
 #endif
-
-	unsigned char		name_assign_type;
-
-	bool			uc_promisc;
 	unsigned int		promiscuity;
 	unsigned int		allmulti;
 
@@ -1645,7 +1643,9 @@ struct net_device {
 
 	struct netdev_queue __rcu *ingress_queue;
 	unsigned char		broadcast[MAX_ADDR_LEN];
-
+#ifdef CONFIG_RFS_ACCEL
+	struct cpu_rmap		*rx_cpu_rmap;
+#endif
 
 /*
  * Cache lines mostly used on transmit path
@@ -1660,9 +1660,6 @@ struct net_device {
 #ifdef CONFIG_XPS
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
-#ifdef CONFIG_RFS_ACCEL
-	struct cpu_rmap		*rx_cpu_rmap;
-#endif
 
 	/* These may be needed for future network-power-down code. */
 
-- 
1.9.3
