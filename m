From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] network device ops phase 1
Date: Fri, 7 Nov 2008 15:50:23 -0800
Message-ID: <20081107155023.2dea5e0f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37546 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118AbYKGXu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 18:50:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This early work on a series of patches to separate the management portions
of the network device (immutable function pointers) from the data
structure part of the network device.

This patch involves some hackery to maintain compatablity between the
new and old model, so all 300+ drivers don't have to be changed at once.
There are two copies of the same function pointers during the transistional
step. As the transistion is completed the nag message can be changed to
an WARN_ON, and the compatiablity code can be made configurable.

A couple function pointers aren't moved:
* destructor can't be in net_device_ops because it may need to be referenced after
   the module is unloaded.
* hard_start_xmit is in the fast path for transmit.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/if.h        |    3 +
 include/linux/netdevice.h |  213 +++++++++++++++++++++++++++++++++------------
 net/Kconfig               |    3 +
 net/core/dev.c            |  109 +++++++++++++++++-------
 net/core/neighbour.c      |    3 +-
 net/core/netpoll.c        |    7 +-
 net/sched/sch_generic.c   |    4 +-
 7 files changed, 250 insertions(+), 92 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index 2a6e296..4286deb 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -67,6 +67,8 @@
 #define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
 #define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
 
+#define IFF_NETDEV_OPS  0x8000		/* network devices ops allocated */
+
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
 
@@ -94,6 +96,7 @@
 #define IF_PROTO_FR_ETH_PVC 0x200B
 #define IF_PROTO_RAW    0x200C          /* RAW Socket                   */
 
+
 /* RFC 2863 operational status */
 enum {
 	IF_OPER_UNKNOWN,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 12d7f44..5d94afd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -451,6 +451,113 @@ struct netdev_queue {
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
+ *
+ * int (*do_ioctl)(struct net_device *dev, struct ifreq *ifr, int cmd);
+ *
+ * int (*set_config)(struct net_device *dev, struct ifmap *map);
+ *
+ * int (*change_mtu)(struct net_device *dev, int new_mtu);
+ *
+ * void (*tx_timeout) (struct net_device *dev);
+ *
+ * struct net_device_stats* (*get_stats)(struct net_device *dev);
+ *
+ * int (*neigh_setup)(struct net_device *dev, struct neigh_parms *);
+ *
+ * void(*vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
+ *
+ * void (*vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
+ *
+ * void (*vlan_rx_kill_vid)(struct net_device *dev, unsigned short vid);
+ *
+ * void (*poll_controller)(struct net_device *dev);
+ *
+ * For transistional compatiablity (for a few releases), the old pointer
+ * info is copied.
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
+	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
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
@@ -498,11 +605,6 @@ struct net_device
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
@@ -553,8 +655,6 @@ struct net_device
 	int			ifindex;
 	int			iflink;
 
-
-	struct net_device_stats* (*get_stats)(struct net_device *dev);
 	struct net_device_stats	stats;
 
 #ifdef CONFIG_WIRELESS_EXT
@@ -564,18 +664,13 @@ struct net_device
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
@@ -648,6 +743,10 @@ struct net_device
 	/* Number of TX queues currently active in device  */
 	unsigned int		real_num_tx_queues;
 
+	/* Map buffer to appropriate transmit queue */
+	u16			(*select_queue)(struct net_device *dev,
+						struct sk_buff *skb);
+
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
 /*
@@ -662,9 +761,6 @@ struct net_device
 	int			watchdog_timeo; /* used by dev_watchdog() */
 	struct timer_list	watchdog_timer;
 
-/*
- * refcnt is a very hot point, so align it on SMP
- */
 	/* Number of references to this device */
 	atomic_t		refcnt ____cacheline_aligned_in_smp;
 
@@ -683,10 +779,49 @@ struct net_device
 	       NETREG_RELEASED,		/* called free_netdev */
 	} reg_state;
 
+	/* Called from unregister, can be used to call free_netdev */
+	void (*destructor)(struct net_device *dev);
+
+#ifdef CONFIG_NETPOLL
+	struct netpoll_info	*npinfo;
+#endif
+
+#ifdef CONFIG_NET_NS
+	/* Network namespace this network device is inside */
+	struct net		*nd_net;
+#endif
+
+	/* mid-layer private */
+	void			*ml_priv;
+
+	/* bridge stuff */
+	struct net_bridge_port	*br_port;
+	/* macvlan */
+	struct macvlan_port	*macvlan_port;
+	/* GARP */
+	struct garp_port	*garp_port;
+
+	/* class/net/name entry */
+	struct device		dev;
+	/* space for optional statistics and wireless sysfs groups */
+	struct attribute_group  *sysfs_groups[3];
+
+	/* rtnetlink link ops */
+	const struct rtnl_link_ops *rtnl_link_ops;
+
+	/* VLAN feature mask */
+	unsigned long vlan_features;
+
+	/* for setting kernel sock attribute on TCP connection setup */
+#define GSO_MAX_SIZE		65536
+	unsigned int		gso_max_size;
+
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	/* The device initialization function. Called only once. */
+	int			(*init)(struct net_device *dev);
+
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
-	/* Called after last user reference disappears. */
-	void			(*destructor)(struct net_device *dev);
 
 	/* Pointers to interface service routines.	*/
 	int			(*open)(struct net_device *dev);
@@ -716,53 +851,19 @@ struct net_device
 #define HAVE_TX_TIMEOUT
 	void			(*tx_timeout) (struct net_device *dev);
 
+	struct net_device_stats* (*get_stats)(struct net_device *dev);
+
+	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
 	void			(*vlan_rx_register)(struct net_device *dev,
 						    struct vlan_group *grp);
 	void			(*vlan_rx_add_vid)(struct net_device *dev,
 						   unsigned short vid);
 	void			(*vlan_rx_kill_vid)(struct net_device *dev,
 						    unsigned short vid);
-
-	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
-#ifdef CONFIG_NETPOLL
-	struct netpoll_info	*npinfo;
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
-
-	u16			(*select_queue)(struct net_device *dev,
-						struct sk_buff *skb);
-
-#ifdef CONFIG_NET_NS
-	/* Network namespace this network device is inside */
-	struct net		*nd_net;
 #endif
-
-	/* mid-layer private */
-	void			*ml_priv;
-
-	/* bridge stuff */
-	struct net_bridge_port	*br_port;
-	/* macvlan */
-	struct macvlan_port	*macvlan_port;
-	/* GARP */
-	struct garp_port	*garp_port;
-
-	/* class/net/name entry */
-	struct device		dev;
-	/* space for optional statistics and wireless sysfs groups */
-	struct attribute_group  *sysfs_groups[3];
-
-	/* rtnetlink link ops */
-	const struct rtnl_link_ops *rtnl_link_ops;
-
-	/* VLAN feature mask */
-	unsigned long vlan_features;
-
-	/* for setting kernel sock attribute on TCP connection setup */
-#define GSO_MAX_SIZE		65536
-	unsigned int		gso_max_size;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/net/Kconfig b/net/Kconfig
index 8c3d97c..4e2e40b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -32,6 +32,9 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config COMPAT_NET_DEV_OPS
+       def_bool y
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
diff --git a/net/core/dev.c b/net/core/dev.c
index a0c6060..1ab06ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1060,6 +1060,7 @@ void dev_load(struct net *net, const char *name)
  */
 int dev_open(struct net_device *dev)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	int ret = 0;
 
 	ASSERT_RTNL();
@@ -1082,11 +1083,11 @@ int dev_open(struct net_device *dev)
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
@@ -1130,6 +1131,7 @@ int dev_open(struct net_device *dev)
  */
 int dev_close(struct net_device *dev)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	ASSERT_RTNL();
 
 	might_sleep();
@@ -1162,8 +1164,8 @@ int dev_close(struct net_device *dev)
 	 *	We allow it to be called even after a DETACH hot-plug
 	 *	event.
 	 */
-	if (dev->stop)
-		dev->stop(dev);
+	if (ops->stop)
+		ops->stop(dev);
 
 	/*
 	 *	Device is now down.
@@ -2955,8 +2957,10 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 
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
@@ -3076,6 +3080,8 @@ int dev_set_allmulti(struct net_device *dev, int inc)
  */
 void __dev_set_rx_mode(struct net_device *dev)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
+
 	/* dev_open will call this function so the list will stay sane. */
 	if (!(dev->flags&IFF_UP))
 		return;
@@ -3083,8 +3089,8 @@ void __dev_set_rx_mode(struct net_device *dev)
 	if (!netif_device_present(dev))
 		return;
 
-	if (dev->set_rx_mode)
-		dev->set_rx_mode(dev);
+	if (ops->set_rx_mode)
+		ops->set_rx_mode(dev);
 	else {
 		/* Unicast addresses changes may only happen under the rtnl,
 		 * therefore calling __dev_set_promiscuity here is safe.
@@ -3097,8 +3103,8 @@ void __dev_set_rx_mode(struct net_device *dev)
 			dev->uc_promisc = 0;
 		}
 
-		if (dev->set_multicast_list)
-			dev->set_multicast_list(dev);
+		if (ops->set_multicast_list)
+			ops->set_multicast_list(dev);
 	}
 }
 
@@ -3457,6 +3463,7 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
  */
 int dev_set_mtu(struct net_device *dev, int new_mtu)
 {
+	const struct net_device_ops *ops = dev->netdev_ops;
 	int err;
 
 	if (new_mtu == dev->mtu)
@@ -3470,10 +3477,11 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
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
@@ -3488,15 +3496,16 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
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
@@ -3576,6 +3585,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 {
 	int err;
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
+	const struct net_device_ops *ops = dev->netdev_ops;
 
 	if (!dev)
 		return -ENODEV;
@@ -3603,15 +3613,15 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
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
@@ -3620,7 +3630,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 					  dev->addr_len, 1);
 
 		case SIOCDELMULTI:
-			if ((!dev->set_multicast_list && !dev->set_rx_mode) ||
+			if ((!ops->set_multicast_list && !ops->set_rx_mode) ||
 			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 				return -EINVAL;
 			if (!netif_device_present(dev))
@@ -3658,10 +3668,9 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
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
@@ -4013,7 +4022,7 @@ int register_netdevice(struct net_device *dev)
 	struct hlist_head *head;
 	struct hlist_node *p;
 	int ret;
-	struct net *net;
+	struct net *net = dev_net(dev);
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -4022,8 +4031,7 @@ int register_netdevice(struct net_device *dev)
 
 	/* When net_device's are persistent, this will be fatal. */
 	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
-	BUG_ON(!dev_net(dev));
-	net = dev_net(dev);
+	BUG_ON(!net);
 
 	spin_lock_init(&dev->addr_list_lock);
 	netdev_set_addr_lockdep_class(dev);
@@ -4031,9 +4039,46 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	/* Netdevice_ops API compatiability hack */
+	if (!dev->netdev_ops) {
+		struct net_device_ops *ops;
+		char drivername[64];
+		pr_info("%s (%s): not using net_device_ops yet\n",
+			dev->name, netdev_drivername(dev, drivername, 64));
+
+		ops = kmalloc(sizeof(struct net_device_ops), GFP_ATOMIC);
+		if (!ops)
+			return -ENOMEM;
+
+		ops->init = dev->init;
+		ops->uninit = dev->uninit;
+		ops->open = dev->open;
+		ops->stop = dev->stop;
+		ops->change_rx_flags = dev->change_rx_flags;
+		ops->set_rx_mode = dev->set_rx_mode;
+		ops->set_multicast_list = dev->set_multicast_list;
+		ops->set_mac_address = dev->set_mac_address;
+		ops->validate_addr = dev->validate_addr;
+		ops->do_ioctl = dev->do_ioctl;
+		ops->set_config = dev->set_config;
+		ops->change_mtu = dev->change_mtu;
+		ops->tx_timeout = dev->tx_timeout;
+		ops->get_stats = dev->get_stats;
+		ops->neigh_setup = dev->neigh_setup;
+		ops->vlan_rx_register = dev->vlan_rx_register;
+		ops->vlan_rx_add_vid = dev->vlan_rx_add_vid;
+		ops->vlan_rx_kill_vid = dev->vlan_rx_kill_vid;
+		ops->poll_controller = dev->poll_controller;
+
+		dev->netdev_ops = ops;
+		dev->priv_flags |= IFF_NETDEV_OPS;
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
@@ -4111,8 +4156,8 @@ out:
 	return ret;
 
 err_uninit:
-	if (dev->uninit)
-		dev->uninit(dev);
+	if (dev->netdev_ops->uninit)
+		dev->netdev_ops->uninit(dev);
 	goto out;
 }
 
@@ -4378,6 +4423,10 @@ void free_netdev(struct net_device *dev)
 		return;
 	}
 
+	if (dev->priv_flags & IFF_NETDEV_OPS) {
+		kfree(dev->netdev_ops);
+	}
+
 	BUG_ON(dev->reg_state != NETREG_UNREGISTERED);
 	dev->reg_state = NETREG_RELEASED;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d9bbe01..96c84a1 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1330,6 +1330,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 {
 	struct neigh_parms *p, *ref;
 	struct net *net;
+	const struct net_device_ops *ops = dev->netdev_ops;
 
 	net = dev_net(dev);
 	ref = lookup_neigh_params(tbl, net, 0);
@@ -1343,7 +1344,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
 
-		if (dev->neigh_setup && dev->neigh_setup(dev, p)) {
+		if (ops->neigh_setup && ops->neigh_setup(dev, p)) {
 			kfree(p);
 			return NULL;
 		}
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 34f5d07..e0e43b9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -172,12 +172,13 @@ static void service_arp_queue(struct netpoll_info *npi)
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
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 1192da2..b906d76 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -224,7 +224,7 @@ static void dev_watchdog(unsigned long arg)
 				char drivername[64];
 				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
 				       dev->name, netdev_drivername(dev, drivername, 64));
-				dev->tx_timeout(dev);
+				dev->netdev_ops->tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
 				       round_jiffies(jiffies +
@@ -239,7 +239,7 @@ static void dev_watchdog(unsigned long arg)
 
 void __netdev_watchdog_up(struct net_device *dev)
 {
-	if (dev->tx_timeout) {
+	if (dev->netdev_ops->tx_timeout) {
 		if (dev->watchdog_timeo <= 0)
 			dev->watchdog_timeo = 5*HZ;
 		if (!mod_timer(&dev->watchdog_timer,
-- 
1.5.4.3

