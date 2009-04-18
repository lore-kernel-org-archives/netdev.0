From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH 1/3] net: introduce a list of device addresses
	dev_addr_list (v4)
Date: Sat, 18 Apr 2009 10:58:49 +0200
Message-ID: <20090418085848.GC3370@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415081819.GB21342@psychotron.englab.brq.redhat.com> <20090415180215.GA22540@psychotron.englab.brq.redhat.com> <20090417115723.GE9556@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com,
	ivecera@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54853 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876AbZDRJA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 05:00:58 -0400
Content-Disposition: inline
In-Reply-To: <20090417115723.GE9556@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3 -> v4 (current):
-changed kzalloc to kmalloc in __hw_addr_add_ii()
-ASSERT_RTNL() avoided in dev_addr_flush() and dev_addr_init()

v2 -> v3:
-removed unnecessary rcu read locking
-moved dev_addr_flush() calling to ensure no null dereference of dev_addr

v1 -> v2:
-added forgotten ASSERT_RTNL to dev_addr_init and dev_addr_flush
-removed unnecessary rcu_read locking in dev_addr_init
-use compare_ether_addr_64bits instead of compare_ether_addr
-use L1_CACHE_BYTES as size for allocating struct netdev_hw_addr
-use call_rcu instead of rcu_synchronize
-moved is_etherdev_addr into __KERNEL__ ifdef

This patch introduces a new list in struct net_device and brings a set of
functions to handle the work with device address list. The list is a replacement
for the original dev_addr field and because in some situations there is need to
carry several device addresses with the net device. To be backward compatible,
dev_addr is made to point to the first member of the list so original drivers
sees no difference.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/etherdevice.h |   27 +++++
 include/linux/netdevice.h   |   32 +++++-
 net/core/dev.c              |  261 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 318 insertions(+), 2 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index a1f17ab..3d7a668 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -182,6 +182,33 @@ static inline unsigned compare_ether_addr_64bits(const u8 addr1[6+2],
 	return compare_ether_addr(addr1, addr2);
 #endif
 }
+
+/**
+ * is_etherdev_addr - Tell if given Ethernet address belongs to the device.
+ * @dev: Pointer to a device structure
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Compare passed address with all addresses of the device. Return true if the
+ * address if one of the device addresses.
+ *
+ * Note that this function calls compare_ether_addr_64bits() so take care of
+ * the right padding.
+ */
+static inline bool is_etherdev_addr(const struct net_device *dev,
+				    const u8 addr[6 + 2])
+{
+	struct netdev_hw_addr *ha;
+	int res = 1;
+
+	rcu_read_lock();
+	for_each_dev_addr(dev, ha) {
+		res = compare_ether_addr_64bits(addr, ha->addr);
+		if (!res)
+			break;
+	}
+	rcu_read_unlock();
+	return !res;
+}
 #endif	/* __KERNEL__ */
 
 /**
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..89ad6d2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -210,6 +210,13 @@ struct dev_addr_list
 #define dmi_users	da_users
 #define dmi_gusers	da_gusers
 
+struct netdev_hw_addr {
+	struct list_head	list;
+	unsigned char		addr[MAX_ADDR_LEN];
+	int			refcount;
+	struct rcu_head		rcu_head;
+};
+
 struct hh_cache
 {
 	struct hh_cache *hh_next;	/* Next entry			     */
@@ -776,8 +783,11 @@ struct net_device
  */
 	unsigned long		last_rx;	/* Time of last Rx	*/
 	/* Interface address info used in eth_type_trans() */
-	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast
-							   because most packets are unicast) */
+	unsigned char		*dev_addr;	/* hw address, (before bcast
+						   because most packets are
+						   unicast) */
+
+	struct list_head	dev_addr_list; /* list of device hw addresses */
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
@@ -1778,6 +1788,13 @@ static inline void netif_addr_unlock_bh(struct net_device *dev)
 	spin_unlock_bh(&dev->addr_list_lock);
 }
 
+/*
+ * dev_addr_list walker. Should be used only for read access. Call with
+ * rcu_read_lock held.
+ */
+#define for_each_dev_addr(dev, ha) \
+		list_for_each_entry_rcu(ha, &dev->dev_addr_list, list)
+
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
 
 extern void		ether_setup(struct net_device *dev);
@@ -1790,6 +1807,17 @@ extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	alloc_netdev_mq(sizeof_priv, name, setup, 1)
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
+
+/* Functions used for device addresses handling */
+extern int		dev_addr_add(struct net_device *dev,
+				     unsigned char *addr);
+extern int		dev_addr_del(struct net_device *dev,
+				     unsigned char *addr);
+extern int		dev_addr_add_multiple(struct net_device *to_dev,
+					      struct net_device *from_dev);
+extern int		dev_addr_del_multiple(struct net_device *to_dev,
+					      struct net_device *from_dev);
+
 /* Functions used for secondary unicast and multicast support */
 extern void		dev_set_rx_mode(struct net_device *dev);
 extern void		__dev_set_rx_mode(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 343883f..2274294 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3438,6 +3438,263 @@ void dev_set_rx_mode(struct net_device *dev)
 	netif_addr_unlock_bh(dev);
 }
 
+/* hw addresses list handling functions */
+
+static int __hw_addr_add_ii(struct list_head *list, unsigned char *addr,
+			    int addr_len, int ignore_index)
+{
+	struct netdev_hw_addr *ha;
+	int i = 0;
+
+	if (addr_len > MAX_ADDR_LEN)
+		return -EINVAL;
+
+	list_for_each_entry(ha, list, list) {
+		if (i++ != ignore_index &&
+		    !memcmp(ha->addr, addr, addr_len)) {
+			ha->refcount++;
+			return 0;
+		}
+	}
+
+	ha = kmalloc(max(sizeof(*ha), L1_CACHE_BYTES), GFP_ATOMIC);
+	if (!ha)
+		return -ENOMEM;
+	memcpy(ha->addr, addr, addr_len);
+	ha->refcount = 1;
+	list_add_tail_rcu(&ha->list, list);
+	return 0;
+}
+
+static int __hw_addr_add(struct list_head *list, unsigned char *addr,
+			 int addr_len)
+{
+	return __hw_addr_add_ii(list, addr, addr_len, -1);
+}
+
+static void ha_rcu_free(struct rcu_head *head)
+{
+	struct netdev_hw_addr *ha;
+
+	ha = container_of(head, struct netdev_hw_addr, rcu_head);
+	kfree(ha);
+}
+
+static int __hw_addr_del_ii(struct list_head *list, unsigned char *addr,
+			    int addr_len, int ignore_index)
+{
+	struct netdev_hw_addr *ha;
+	int i = 0;
+
+	list_for_each_entry(ha, list, list) {
+		if (i++ != ignore_index &&
+		    !memcmp(ha->addr, addr, addr_len)) {
+			if (--ha->refcount)
+				return 0;
+			list_del_rcu(&ha->list);
+			call_rcu(&ha->rcu_head, ha_rcu_free);
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
+static int __hw_addr_del(struct list_head *list, unsigned char *addr,
+			 int addr_len)
+{
+	return __hw_addr_del_ii(list, addr, addr_len, -1);
+}
+
+static int __hw_addr_add_multiple_ii(struct list_head *to_list,
+				     struct list_head *from_list,
+				     int addr_len, int ignore_index)
+{
+	int err;
+	struct netdev_hw_addr *ha, *ha2;
+
+	list_for_each_entry(ha, from_list, list) {
+		err = __hw_addr_add_ii(to_list, ha->addr, addr_len, 0);
+		if (err)
+			goto unroll;
+	}
+	return 0;
+
+unroll:
+	list_for_each_entry(ha2, from_list, list) {
+		if (ha2 == ha)
+			break;
+		__hw_addr_del_ii(to_list, ha2->addr, addr_len, 0);
+	}
+	return err;
+}
+
+static int __hw_addr_add_multiple(struct list_head *to_list,
+					 struct list_head *from_list,
+					 int addr_len)
+{
+	return __hw_addr_add_multiple_ii(to_list, from_list, addr_len, -1);
+}
+
+static void __hw_addr_del_multiple_ii(struct list_head *to_list,
+				      struct list_head *from_list,
+				      int addr_len, int ignore_index)
+{
+	struct netdev_hw_addr *ha;
+
+	list_for_each_entry(ha, from_list, list) {
+		__hw_addr_del_ii(to_list, ha->addr, addr_len, 0);
+	}
+}
+
+static void __hw_addr_del_multiple(struct list_head *to_list,
+					 struct list_head *from_list,
+					 int addr_len)
+{
+	__hw_addr_del_multiple_ii(to_list, from_list, addr_len, -1);
+}
+
+static void __hw_addr_flush(struct list_head *list)
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, list, list) {
+		list_del_rcu(&ha->list);
+		call_rcu(&ha->rcu_head, ha_rcu_free);
+	}
+}
+
+/* Device addresses handling functions */
+
+static void dev_addr_flush(struct net_device *dev)
+{
+	/* rtnl_mutex must be held here */
+
+	__hw_addr_flush(&dev->dev_addr_list);
+	dev->dev_addr = NULL;
+}
+
+static int dev_addr_init(struct net_device *dev)
+{
+	unsigned char addr[MAX_ADDR_LEN];
+	struct netdev_hw_addr *ha;
+	int err;
+
+	/* rtnl_mutex must be held here */
+
+	INIT_LIST_HEAD(&dev->dev_addr_list);
+	memset(addr, 0, sizeof(*addr));
+	err = __hw_addr_add(&dev->dev_addr_list, addr, sizeof(*addr));
+	if (!err) {
+		/*
+		 * Get the first (previously created) address from the list
+		 * and set dev_addr pointer to this location.
+		 */
+		ha = list_first_entry(&dev->dev_addr_list,
+				      struct netdev_hw_addr, list);
+		dev->dev_addr = ha->addr;
+	}
+	return err;
+}
+
+/**
+ *	dev_addr_add	- Add a device address
+ *	@dev: device
+ *	@addr: address to add
+ *
+ *	Add a device address to the device or increase the reference count if
+ *	it already exists.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_add(struct net_device *dev, unsigned char *addr)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	err = __hw_addr_add_ii(&dev->dev_addr_list, addr, dev->addr_len, 0);
+	if (!err)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_add);
+
+/**
+ *	dev_addr_del	- Release a device address.
+ *	@dev: device
+ *	@addr: address to delete
+ *
+ *	Release reference to a device address and remove it from the device
+ *	if the reference count drops to zero.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_del(struct net_device *dev, unsigned char *addr)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	err = __hw_addr_del_ii(&dev->dev_addr_list, addr, dev->addr_len, 0);
+	if (!err)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_del);
+
+/**
+ *	dev_addr_add_multiple	- Add device addresses from another device
+ *	@to_dev: device to which addresses will be added
+ *	@from_dev: device from which addresses will be added
+ *
+ *	Add device addresses of the one device to another.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_add_multiple(struct net_device *to_dev,
+			  struct net_device *from_dev)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	if (from_dev->addr_len != to_dev->addr_len)
+		return -EINVAL;
+	err = __hw_addr_add_multiple_ii(&to_dev->dev_addr_list,
+					&from_dev->dev_addr_list,
+					to_dev->addr_len, 0);
+	if (!err)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_add_multiple);
+
+/**
+ *	dev_addr_del_multiple	- Delete device addresses by another device
+ *	@to_dev: device where the addresses will be deleted
+ *	@from_dev: device by which addresses the addresses will be deleted
+ *
+ *	Deletes addresses in to device by the list of addresses in from device.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_del_multiple(struct net_device *to_dev,
+			  struct net_device *from_dev)
+{
+	ASSERT_RTNL();
+
+	if (from_dev->addr_len != to_dev->addr_len)
+		return -EINVAL;
+	__hw_addr_add_multiple_ii(&to_dev->dev_addr_list,
+				  &from_dev->dev_addr_list,
+				  to_dev->addr_len, 0);
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
+	return 0;
+}
+EXPORT_SYMBOL(dev_addr_del_multiple);
+
+/* unicast and multicast addresses handling functions */
+
 int __dev_addr_delete(struct dev_addr_list **list, int *count,
 		      void *addr, int alen, int glbl)
 {
@@ -4780,6 +5037,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
+	dev_addr_init(dev);
 	netdev_init_queues(dev);
 
 	INIT_LIST_HEAD(&dev->napi_list);
@@ -4805,6 +5063,9 @@ void free_netdev(struct net_device *dev)
 
 	kfree(dev->_tx);
 
+	/* Flush device addresses */
+	dev_addr_flush(dev);
+
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);
 
-- 
1.6.0.6

