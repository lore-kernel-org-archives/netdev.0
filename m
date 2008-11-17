From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/33] netdev: network device operations infrastructure
Date: Mon, 17 Nov 2008 15:42:08 -0800
Message-ID: <20081117234354.864259203@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55034 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbYKQX74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:59:56 -0500
Content-Disposition: inline; filename=netdevice-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the network device internal API to move adminstrative
operations out of the network device structure and into a separate structure.

This patch involves some hackery to maintain compatablity between the
new and old model, so all 300+ drivers don't have to be changed at once.
For drivers that aren't converted yet, the netdevice_ops virt function list
still resides in the net_device structure. For old protocols, the new
net_device_ops are copied out to the old net_device pointers.

After the transistion is completed the nag message can be changed to
an WARN_ON, and the compatiablity code can be made configurable.

Some function pointers aren't moved:
* destructor can't be in net_device_ops because 
  it may need to be referenced after the module is unloaded.
* neighbor setup is manipulated in a couple of places that need special
  consideration
* hard_start_xmit is in the fast path for transmit.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---

---
 include/linux/netdevice.h |  232 +++++++++++++++++++++++++++++++++-------------
 net/Kconfig               |    3 
 net/core/dev.c            |  107 ++++++++++++++-------
 net/core/netpoll.c        |    7 -
 net/core/rtnetlink.c      |    9 -
 net/sched/sch_generic.c   |    4 
 6 files changed, 257 insertions(+), 105 deletions(-)

--- a/include/linux/netdevice.h	2008-11-17 14:53:09.000000000 -0800
+++ b/include/linux/netdevice.h	2008-11-17 15:15:40.000000000 -0800
@@ -451,6 +451,131 @@ struct netdev_queue {
 	struct Qdisc		*qdisc_sleeping;
 } ____cacheline_aligned_in_smp;
 
+
+/*
+ * This structure defines the management hooks for network devices.
+ * The following hooks can bed defined and are optonal (can be null)
+ * unless otherwise noted.
+ *
+ * int (*init)(struct net_device *dev);
+ *     This function is called once when network device is registered.
+ *     The network device can use this to any late stage initializaton
+ *     or semantic validattion. It can fail with an error code which will
+ *     be propogated back to register_netdev
+ *
+ * void (*uninit)(struct net_device *dev);
+ *     This function is called when device is unregistered or when registration
+ *     fails. It is not called if init fails.
+ *
+ * int (*open)(struct net_device *dev);
+ *     This function is called when network device transistions to the up
+ *     state.
+ *
+ * int (*stop)(struct net_device *dev);
+ *     This function is called when network device transistions to the down
+ *     state.
+ *
+ * void (*change_rx_flags)(struct net_device *dev, int flags);
+ *	This function is called to allow device receiver to make
+ *	changes to configuration when multicast or promiscious is enabled.
+ *
+ * void (*set_rx_mode)(struct net_device *dev);
+ *	This function is called device changes address list filtering.
+ *
+ * void (*set_multicast_list)(struct net_device *dev);
+ *	This function is called when the multicast address list changes.
+ *
+ * int (*set_mac_address)(struct net_device *dev, void *addr);
+ *	This function  is called when the Media Access Control address
+ *	needs to be changed. If not this interface is not defined, the
+ *	mac address can not be changed.
+ *
+ * int (*validate_addr)(struct net_device *dev);
+ *	Test if Media Access Control address is valid for the device.
+ *
+ * int (*do_ioctl)(struct net_device *dev, struct ifreq *ifr, int cmd);
+ *	Called when a user request an ioctl which can't be handled by
+ *	the generic interface code. If not defined ioctl's return
+ *	not supported error code.
+ *
+ * int (*set_config)(struct net_device *dev, struct ifmap *map);
+ *	Used to set network devices bus interface parameters. This interface
+ *	is retained for legacy reason, new devices should use the bus
+ *	interface (PCI) for low level management.
+ *
+ * int (*change_mtu)(struct net_device *dev, int new_mtu);
+ *	Called when a user wants to change the Maximum Transfer Unit
+ *	of a device. If not defined, any request to change MTU will
+ *	will return an error.
+ *
+ * void (*tx_timeout) (struct net_device *dev);
+ *	Callback uses when the transmitter has not made any progress
+ *	for dev->watchdog ticks.
+ *
+ * struct net_device_stats* (*get_stats)(struct net_device *dev);
+ *	Called when a user wants to get the network device usage
+ *	statistics. If not defined, the counters in dev->stats will
+ *	be used.
+ *
+ * void (*vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
+ *	If device support VLAN receive accleration
+ *	(ie. dev->features & NETIF_F_HW_VLAN_RX), then this function is called
+ *	when vlan groups for the device changes.  Note: grp is NULL
+ *	if no vlan's groups are being used.
+ *
+ * void (*vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
+ *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
+ *	this function is called when a VLAN id is registered.
+ *
+ * void (*vlan_rx_kill_vid)(struct net_device *dev, unsigned short vid);
+ *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
+ *	this function is called when a VLAN id is unregistered.
+ *
+ * void (*poll_controller)(struct net_device *dev);
+ */
+struct net_device_ops {
+	int			(*init)(struct net_device *dev);
+	void			(*uninit)(struct net_device *dev);
+	int			(*open)(struct net_device *dev);
+	int			(*stop)(struct net_device *dev);
+#define HAVE_CHANGE_RX_FLAGS
+	void			(*change_rx_flags)(struct net_device *dev,
+						   int flags);
+#define HAVE_SET_RX_MODE
+	void			(*set_rx_mode)(struct net_device *dev);
+#define HAVE_MULTICAST
+	void			(*set_multicast_list)(struct net_device *dev);
+#define HAVE_SET_MAC_ADDR
+	int			(*set_mac_address)(struct net_device *dev,
+						   void *addr);
+#define HAVE_VALIDATE_ADDR
+	int			(*validate_addr)(struct net_device *dev);
+#define HAVE_PRIVATE_IOCTL
+	int			(*do_ioctl)(struct net_device *dev,
+					    struct ifreq *ifr, int cmd);
+#define HAVE_SET_CONFIG
+	int			(*set_config)(struct net_device *dev,
+					      struct ifmap *map);
+#define HAVE_CHANGE_MTU
+	int			(*change_mtu)(struct net_device *dev, int new_mtu);
+
+#define HAVE_TX_TIMEOUT
+	void			(*tx_timeout) (struct net_device *dev);
+
+	struct net_device_stats* (*get_stats)(struct net_device *dev);
+
+	void			(*vlan_rx_register)(struct net_device *dev,
+						    struct vlan_group *grp);
+	void			(*vlan_rx_add_vid)(struct net_device *dev,
+						   unsigned short vid);
+	void			(*vlan_rx_kill_vid)(struct net_device *dev,
+						    unsigned short vid);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+#define HAVE_NETDEV_POLL
+	void                    (*poll_controller)(struct net_device *dev);
+#endif
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -498,11 +623,6 @@ struct net_device
 #ifdef CONFIG_NETPOLL
 	struct list_head	napi_list;
 #endif
-	
-	/* The device initialization function. Called only once. */
-	int			(*init)(struct net_device *dev);
-
-	/* ------- Fields preinitialized in Space.c finish here ------- */
 
 	/* Net device features */
 	unsigned long		features;
@@ -546,15 +666,13 @@ struct net_device
 	 * for all in netdev_increment_features.
 	 */
 #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
-				 NETIF_F_SG | NETIF_F_HIGHDMA | \
+				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
 				 NETIF_F_FRAGLIST)
 
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
 
-
-	struct net_device_stats* (*get_stats)(struct net_device *dev);
 	struct net_device_stats	stats;
 
 #ifdef CONFIG_WIRELESS_EXT
@@ -564,18 +682,13 @@ struct net_device
 	/* Instance data managed by the core of Wireless Extensions. */
 	struct iw_public_data *	wireless_data;
 #endif
+	/* Management operations */
+	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
 
 	/* Hardware header description */
 	const struct header_ops *header_ops;
 
-	/*
-	 * This marks the end of the "visible" part of the structure. All
-	 * fields hereafter are internal to the system, and may change at
-	 * will (read: may be cleaned up at will).
-	 */
-
-
 	unsigned int		flags;	/* interface flags (a la BSD)	*/
 	unsigned short		gflags;
         unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
@@ -634,7 +747,7 @@ struct net_device
 	unsigned long		last_rx;	/* Time of last Rx	*/
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast 
-							because most packets are unicast) */
+							   because most packets are unicast) */
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
@@ -648,6 +761,10 @@ struct net_device
 	/* Number of TX queues currently active in device  */
 	unsigned int		real_num_tx_queues;
 
+	/* Map buffer to appropriate transmit queue */
+	u16			(*select_queue)(struct net_device *dev,
+						struct sk_buff *skb);
+
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
 /*
@@ -662,9 +779,6 @@ struct net_device
 	int			watchdog_timeo; /* used by dev_watchdog() */
 	struct timer_list	watchdog_timer;
 
-/*
- * refcnt is a very hot point, so align it on SMP
- */
 	/* Number of references to this device */
 	atomic_t		refcnt ____cacheline_aligned_in_smp;
 
@@ -683,56 +797,14 @@ struct net_device
 	       NETREG_RELEASED,		/* called free_netdev */
 	} reg_state;
 
-	/* Called after device is detached from network. */
-	void			(*uninit)(struct net_device *dev);
-	/* Called after last user reference disappears. */
-	void			(*destructor)(struct net_device *dev);
-
-	/* Pointers to interface service routines.	*/
-	int			(*open)(struct net_device *dev);
-	int			(*stop)(struct net_device *dev);
-#define HAVE_NETDEV_POLL
-#define HAVE_CHANGE_RX_FLAGS
-	void			(*change_rx_flags)(struct net_device *dev,
-						   int flags);
-#define HAVE_SET_RX_MODE
-	void			(*set_rx_mode)(struct net_device *dev);
-#define HAVE_MULTICAST			 
-	void			(*set_multicast_list)(struct net_device *dev);
-#define HAVE_SET_MAC_ADDR  		 
-	int			(*set_mac_address)(struct net_device *dev,
-						   void *addr);
-#define HAVE_VALIDATE_ADDR
-	int			(*validate_addr)(struct net_device *dev);
-#define HAVE_PRIVATE_IOCTL
-	int			(*do_ioctl)(struct net_device *dev,
-					    struct ifreq *ifr, int cmd);
-#define HAVE_SET_CONFIG
-	int			(*set_config)(struct net_device *dev,
-					      struct ifmap *map);
-#define HAVE_CHANGE_MTU
-	int			(*change_mtu)(struct net_device *dev, int new_mtu);
-
-#define HAVE_TX_TIMEOUT
-	void			(*tx_timeout) (struct net_device *dev);
+	/* Called from unregister, can be used to call free_netdev */
+	void (*destructor)(struct net_device *dev);
 
-	void			(*vlan_rx_register)(struct net_device *dev,
-						    struct vlan_group *grp);
-	void			(*vlan_rx_add_vid)(struct net_device *dev,
-						   unsigned short vid);
-	void			(*vlan_rx_kill_vid)(struct net_device *dev,
-						    unsigned short vid);
+	int (*neigh_setup)(struct net_device *dev, struct neigh_parms *);
 
-	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
 #ifdef CONFIG_NETPOLL
 	struct netpoll_info	*npinfo;
 #endif
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	void                    (*poll_controller)(struct net_device *dev);
-#endif
-
-	u16			(*select_queue)(struct net_device *dev,
-						struct sk_buff *skb);
 
 #ifdef CONFIG_NET_NS
 	/* Network namespace this network device is inside */
@@ -763,6 +835,38 @@ struct net_device
 	/* for setting kernel sock attribute on TCP connection setup */
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
+
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	struct {
+		int			(*init)(struct net_device *dev);
+		void			(*uninit)(struct net_device *dev);
+		int			(*open)(struct net_device *dev);
+		int			(*stop)(struct net_device *dev);
+		void			(*change_rx_flags)(struct net_device *dev,
+							   int flags);
+		void			(*set_rx_mode)(struct net_device *dev);
+		void			(*set_multicast_list)(struct net_device *dev);
+		int			(*set_mac_address)(struct net_device *dev,
+							   void *addr);
+		int			(*validate_addr)(struct net_device *dev);
+		int			(*do_ioctl)(struct net_device *dev,
+						    struct ifreq *ifr, int cmd);
+		int			(*set_config)(struct net_device *dev,
+						      struct ifmap *map);
+		int			(*change_mtu)(struct net_device *dev, int new_mtu);
+		void			(*tx_timeout) (struct net_device *dev);
+		struct net_device_stats* (*get_stats)(struct net_device *dev);
+		void			(*vlan_rx_register)(struct net_device *dev,
+							    struct vlan_group *grp);
+		void			(*vlan_rx_add_vid)(struct net_device *dev,
+							   unsigned short vid);
+		void			(*vlan_rx_kill_vid)(struct net_device *dev,
+							    unsigned short vid);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+		void                    (*poll_controller)(struct net_device *dev);
+#endif
+#endif
+	};
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
--- a/net/Kconfig	2008-11-17 14:53:09.000000000 -0800
+++ b/net/Kconfig	2008-11-17 14:53:24.000000000 -0800
@@ -32,6 +32,9 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config COMPAT_NET_DEV_OPS
+       def_bool y
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
--- a/net/core/dev.c	2008-11-17 14:53:09.000000000 -0800
+++ b/net/core/dev.c	2008-11-17 15:15:40.000000000 -0800
@@ -1059,6 +1059,7 @@ void dev_load(struct net *net, const cha
  */
 int dev_open(struct net_device *dev)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	int ret = 0;
 
 	ASSERT_RTNL();
@@ -1081,11 +1082,11 @@ int dev_open(struct net_device *dev)
 	 */
 	set_bit(__LINK_STATE_START, &dev->state);
 
-	if (dev->validate_addr)
-		ret = dev->validate_addr(dev);
+	if (ops->validate_addr)
+		ret = ops->validate_addr(dev);
 
-	if (!ret && dev->open)
-		ret = dev->open(dev);
+	if (!ret && ops->open)
+		ret = ops->open(dev);
 
 	/*
 	 *	If it went open OK then:
@@ -1129,6 +1130,7 @@ int dev_open(struct net_device *dev)
  */
 int dev_close(struct net_device *dev)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	ASSERT_RTNL();
 
 	might_sleep();
@@ -1161,8 +1163,8 @@ int dev_close(struct net_device *dev)
 	 *	We allow it to be called even after a DETACH hot-plug
 	 *	event.
 	 */
-	if (dev->stop)
-		dev->stop(dev);
+	if (ops->stop)
+		ops->stop(dev);
 
 	/*
 	 *	Device is now down.
@@ -2930,8 +2932,10 @@ int netdev_set_master(struct net_device 
 
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
-	if (dev->flags & IFF_UP && dev->change_rx_flags)
-		dev->change_rx_flags(dev, flags);
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if ((dev->flags & IFF_UP) && ops->change_rx_flags)
+		ops->change_rx_flags(dev, flags);
 }
 
 static int __dev_set_promiscuity(struct net_device *dev, int inc)
@@ -3051,6 +3055,8 @@ int dev_set_allmulti(struct net_device *
  */
 void __dev_set_rx_mode(struct net_device *dev)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
+
 	/* dev_open will call this function so the list will stay sane. */
 	if (!(dev->flags&IFF_UP))
 		return;
@@ -3058,8 +3064,8 @@ void __dev_set_rx_mode(struct net_device
 	if (!netif_device_present(dev))
 		return;
 
-	if (dev->set_rx_mode)
-		dev->set_rx_mode(dev);
+	if (ops->set_rx_mode)
+		ops->set_rx_mode(dev);
 	else {
 		/* Unicast addresses changes may only happen under the rtnl,
 		 * therefore calling __dev_set_promiscuity here is safe.
@@ -3072,8 +3078,8 @@ void __dev_set_rx_mode(struct net_device
 			dev->uc_promisc = 0;
 		}
 
-		if (dev->set_multicast_list)
-			dev->set_multicast_list(dev);
+		if (ops->set_multicast_list)
+			ops->set_multicast_list(dev);
 	}
 }
 
@@ -3432,6 +3438,7 @@ int dev_change_flags(struct net_device *
  */
 int dev_set_mtu(struct net_device *dev, int new_mtu)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	int err;
 
 	if (new_mtu == dev->mtu)
@@ -3445,10 +3452,11 @@ int dev_set_mtu(struct net_device *dev, 
 		return -ENODEV;
 
 	err = 0;
-	if (dev->change_mtu)
-		err = dev->change_mtu(dev, new_mtu);
+	if (ops->change_mtu)
+		err = ops->change_mtu(dev, new_mtu);
 	else
 		dev->mtu = new_mtu;
+
 	if (!err && dev->flags & IFF_UP)
 		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
 	return err;
@@ -3463,15 +3471,16 @@ int dev_set_mtu(struct net_device *dev, 
  */
 int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	int err;
 
-	if (!dev->set_mac_address)
+	if (!ops->set_mac_address)
 		return -EOPNOTSUPP;
 	if (sa->sa_family != dev->type)
 		return -EINVAL;
 	if (!netif_device_present(dev))
 		return -ENODEV;
-	err = dev->set_mac_address(dev, sa);
+	err = ops->set_mac_address(dev, sa);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	return err;
@@ -3551,6 +3560,7 @@ static int dev_ifsioc(struct net *net, s
 {
 	int err;
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
+	const struct net_device_ops *ops = dev->netdev_ops;
 
 	if (!dev)
 		return -ENODEV;
@@ -3578,15 +3588,15 @@ static int dev_ifsioc(struct net *net, s
 			return 0;
 
 		case SIOCSIFMAP:
-			if (dev->set_config) {
+			if (ops->set_config) {
 				if (!netif_device_present(dev))
 					return -ENODEV;
-				return dev->set_config(dev, &ifr->ifr_map);
+				return ops->set_config(dev, &ifr->ifr_map);
 			}
 			return -EOPNOTSUPP;
 
 		case SIOCADDMULTI:
-			if ((!dev->set_multicast_list && !dev->set_rx_mode) ||
+			if ((!ops->set_multicast_list && !ops->set_rx_mode) ||
 			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 				return -EINVAL;
 			if (!netif_device_present(dev))
@@ -3595,7 +3605,7 @@ static int dev_ifsioc(struct net *net, s
 					  dev->addr_len, 1);
 
 		case SIOCDELMULTI:
-			if ((!dev->set_multicast_list && !dev->set_rx_mode) ||
+			if ((!ops->set_multicast_list && !ops->set_rx_mode) ||
 			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 				return -EINVAL;
 			if (!netif_device_present(dev))
@@ -3633,10 +3643,9 @@ static int dev_ifsioc(struct net *net, s
 			    cmd == SIOCBRDELIF ||
 			    cmd == SIOCWANDEV) {
 				err = -EOPNOTSUPP;
-				if (dev->do_ioctl) {
+				if (ops->do_ioctl) {
 					if (netif_device_present(dev))
-						err = dev->do_ioctl(dev, ifr,
-								    cmd);
+						err = ops->do_ioctl(dev, ifr, cmd);
 					else
 						err = -ENODEV;
 				}
@@ -3897,8 +3906,8 @@ static void rollback_registered(struct n
 	 */
 	dev_addr_discard(dev);
 
-	if (dev->uninit)
-		dev->uninit(dev);
+	if (dev->netdev_ops->uninit)
+		dev->netdev_ops->uninit(dev);
 
 	/* Notifier chain MUST detach us from master device. */
 	WARN_ON(dev->master);
@@ -3988,7 +3997,7 @@ int register_netdevice(struct net_device
 	struct hlist_head *head;
 	struct hlist_node *p;
 	int ret;
-	struct net *net;
+	struct net *net = dev_net(dev);
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -3997,8 +4006,7 @@ int register_netdevice(struct net_device
 
 	/* When net_device's are persistent, this will be fatal. */
 	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
-	BUG_ON(!dev_net(dev));
-	net = dev_net(dev);
+	BUG_ON(!net);
 
 	spin_lock_init(&dev->addr_list_lock);
 	netdev_set_addr_lockdep_class(dev);
@@ -4006,9 +4014,44 @@ int register_netdevice(struct net_device
 
 	dev->iflink = -1;
 
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	/* Netdevice_ops API compatiability support.
+	 * This is temporary until all network devices are converted.
+	 */
+	if (dev->netdev_ops) {
+		const struct net_device_ops *ops = dev->netdev_ops;
+
+		dev->init = ops->init;
+		dev->uninit = ops->uninit;
+		dev->open = ops->open;
+		dev->change_rx_flags = ops->change_rx_flags;
+		dev->set_rx_mode = ops->set_rx_mode;
+		dev->set_multicast_list = ops->set_multicast_list;
+		dev->set_mac_address = ops->set_mac_address;
+		dev->validate_addr = ops->validate_addr;
+		dev->do_ioctl = ops->do_ioctl;
+		dev->set_config = ops->set_config;
+		dev->change_mtu = ops->change_mtu;
+		dev->tx_timeout = ops->tx_timeout;
+		dev->get_stats = ops->get_stats;
+		dev->vlan_rx_register = ops->vlan_rx_register;
+		dev->vlan_rx_add_vid = ops->vlan_rx_add_vid;
+		dev->vlan_rx_kill_vid = ops->vlan_rx_kill_vid;
+		dev->poll_controller = ops->poll_controller;
+	} else {
+		char drivername[64];
+		pr_info("%s (%s): not using net_device_ops yet\n",
+			dev->name, netdev_drivername(dev, drivername, 64));
+
+		/* This works only because net_device_ops and the
+		   compatiablity structure are the same. */
+		dev->netdev_ops = (void *) &(dev->init);
+	}
+#endif
+
 	/* Init, if this function is available */
-	if (dev->init) {
-		ret = dev->init(dev);
+	if (dev->netdev_ops->init) {
+		ret = dev->netdev_ops->init(dev);
 		if (ret) {
 			if (ret > 0)
 				ret = -EIO;
@@ -4086,8 +4129,8 @@ out:
 	return ret;
 
 err_uninit:
-	if (dev->uninit)
-		dev->uninit(dev);
+	if (dev->netdev_ops->uninit)
+		dev->netdev_ops->uninit(dev);
 	goto out;
 }
 
--- a/net/core/netpoll.c	2008-11-17 14:53:09.000000000 -0800
+++ b/net/core/netpoll.c	2008-11-17 14:53:24.000000000 -0800
@@ -172,12 +172,13 @@ static void service_arp_queue(struct net
 void netpoll_poll(struct netpoll *np)
 {
 	struct net_device *dev = np->dev;
+	const struct net_device_ops *ops = dev->netdev_ops;
 
-	if (!dev || !netif_running(dev) || !dev->poll_controller)
+	if (!dev || !netif_running(dev) || !ops->poll_controller)
 		return;
 
 	/* Process pending work on NIC */
-	dev->poll_controller(dev);
+	ops->poll_controller(dev);
 
 	poll_napi(dev);
 
@@ -694,7 +695,7 @@ int netpoll_setup(struct netpoll *np)
 		atomic_inc(&npinfo->refcnt);
 	}
 
-	if (!ndev->poll_controller) {
+	if (!ndev->netdev_ops->poll_controller) {
 		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
 		       np->name, np->dev_name);
 		err = -ENOTSUPP;
--- a/net/sched/sch_generic.c	2008-11-17 14:53:09.000000000 -0800
+++ b/net/sched/sch_generic.c	2008-11-17 14:53:24.000000000 -0800
@@ -224,7 +224,7 @@ static void dev_watchdog(unsigned long a
 				char drivername[64];
 				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
 				       dev->name, netdev_drivername(dev, drivername, 64));
-				dev->tx_timeout(dev);
+				dev->netdev_ops->tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
 				       round_jiffies(jiffies +
@@ -239,7 +239,7 @@ static void dev_watchdog(unsigned long a
 
 void __netdev_watchdog_up(struct net_device *dev)
 {
-	if (dev->tx_timeout) {
+	if (dev->netdev_ops->tx_timeout) {
 		if (dev->watchdog_timeo <= 0)
 			dev->watchdog_timeo = 5*HZ;
 		if (!mod_timer(&dev->watchdog_timer,
--- a/net/core/rtnetlink.c	2008-11-17 14:53:09.000000000 -0800
+++ b/net/core/rtnetlink.c	2008-11-17 15:15:40.000000000 -0800
@@ -762,6 +762,7 @@ static int validate_linkmsg(struct net_d
 static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		      struct nlattr **tb, char *ifname, int modified)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	int send_addr_notify = 0;
 	int err;
 
@@ -783,7 +784,7 @@ static int do_setlink(struct net_device 
 		struct rtnl_link_ifmap *u_map;
 		struct ifmap k_map;
 
-		if (!dev->set_config) {
+		if (!ops->set_config) {
 			err = -EOPNOTSUPP;
 			goto errout;
 		}
@@ -801,7 +802,7 @@ static int do_setlink(struct net_device 
 		k_map.dma = (unsigned char) u_map->dma;
 		k_map.port = (unsigned char) u_map->port;
 
-		err = dev->set_config(dev, &k_map);
+		err = ops->set_config(dev, &k_map);
 		if (err < 0)
 			goto errout;
 
@@ -812,7 +813,7 @@ static int do_setlink(struct net_device 
 		struct sockaddr *sa;
 		int len;
 
-		if (!dev->set_mac_address) {
+		if (!ops->set_mac_address) {
 			err = -EOPNOTSUPP;
 			goto errout;
 		}
@@ -831,7 +832,7 @@ static int do_setlink(struct net_device 
 		sa->sa_family = dev->type;
 		memcpy(sa->sa_data, nla_data(tb[IFLA_ADDRESS]),
 		       dev->addr_len);
-		err = dev->set_mac_address(dev, sa);
+		err = ops->set_mac_address(dev, sa);
 		kfree(sa);
 		if (err)
 			goto errout;

-- 

