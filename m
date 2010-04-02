From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 1/2] net: move address list functions to a
 separate file
Date: Fri, 2 Apr 2010 09:22:09 +0200
Message-ID: <20100402072207.GB3100@psychotron.redhat.com>
References: <20100402072126.GA3100@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759257Ab0DBHWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 03:22:12 -0400
Content-Disposition: inline
In-Reply-To: <20100402072126.GA3100@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+little renaming of unicast functions to be smooth with multicast ones

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 drivers/net/macvlan.c           |   10 +-
 drivers/scsi/fcoe/fcoe.c        |   14 +-
 include/linux/netdevice.h       |   15 +-
 net/8021q/vlan.c                |    4 +-
 net/8021q/vlan_dev.c            |   14 +-
 net/core/Makefile               |    3 +-
 net/core/dev.c                  |  430 +----------------------------------
 net/core/dev_addr_lists.c       |  478 +++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c                 |   14 +-
 net/packet/af_packet.c          |    4 +-
 11 files changed, 524 insertions(+), 464 deletions(-)
 create mode 100644 net/core/dev_addr_lists.c

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f8ab60b..d6ae63b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1491,7 +1491,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			}
 
 			/* Flush unicast and multicast addresses */
-			dev_unicast_flush(bond_dev);
+			dev_uc_flush(bond_dev);
 			dev_addr_discard(bond_dev);
 
 			if (slave_dev->type != ARPHRD_ETHER)
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 445e73c..9a939d8 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -282,7 +282,7 @@ static int macvlan_open(struct net_device *dev)
 	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
 		goto out;
 
-	err = dev_unicast_add(lowerdev, dev->dev_addr);
+	err = dev_uc_add(lowerdev, dev->dev_addr);
 	if (err < 0)
 		goto out;
 	if (dev->flags & IFF_ALLMULTI) {
@@ -294,7 +294,7 @@ static int macvlan_open(struct net_device *dev)
 	return 0;
 
 del_unicast:
-	dev_unicast_delete(lowerdev, dev->dev_addr);
+	dev_uc_del(lowerdev, dev->dev_addr);
 out:
 	return err;
 }
@@ -308,7 +308,7 @@ static int macvlan_stop(struct net_device *dev)
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, -1);
 
-	dev_unicast_delete(lowerdev, dev->dev_addr);
+	dev_uc_del(lowerdev, dev->dev_addr);
 
 	macvlan_hash_del(vlan);
 	return 0;
@@ -332,11 +332,11 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 		if (macvlan_addr_busy(vlan->port, addr->sa_data))
 			return -EBUSY;
 
-		err = dev_unicast_add(lowerdev, addr->sa_data);
+		err = dev_uc_add(lowerdev, addr->sa_data);
 		if (err)
 			return err;
 
-		dev_unicast_delete(lowerdev, dev->dev_addr);
+		dev_uc_del(lowerdev, dev->dev_addr);
 
 		macvlan_hash_change_addr(vlan, addr->sa_data);
 	}
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 2f47ae7..de33e38 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -308,9 +308,9 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
 	 * for multiple unicast MACs.
 	 */
 	memcpy(flogi_maddr, (u8[6]) FC_FCOE_FLOGI_MAC, ETH_ALEN);
-	dev_unicast_add(netdev, flogi_maddr);
+	dev_uc_add(netdev, flogi_maddr);
 	if (fip->spma)
-		dev_unicast_add(netdev, fip->ctl_src_addr);
+		dev_uc_add(netdev, fip->ctl_src_addr);
 	dev_mc_add(netdev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
 
 	/*
@@ -394,9 +394,9 @@ void fcoe_interface_cleanup(struct fcoe_interface *fcoe)
 
 	/* Delete secondary MAC addresses */
 	memcpy(flogi_maddr, (u8[6]) FC_FCOE_FLOGI_MAC, ETH_ALEN);
-	dev_unicast_delete(netdev, flogi_maddr);
+	dev_uc_del(netdev, flogi_maddr);
 	if (fip->spma)
-		dev_unicast_delete(netdev, fip->ctl_src_addr);
+		dev_uc_del(netdev, fip->ctl_src_addr);
 	dev_mc_delete(netdev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
 
 	/* Tell the LLD we are done w/ FCoE */
@@ -490,9 +490,9 @@ static void fcoe_update_src_mac(struct fc_lport *lport, u8 *addr)
 
 	rtnl_lock();
 	if (!is_zero_ether_addr(port->data_src_addr))
-		dev_unicast_delete(fcoe->netdev, port->data_src_addr);
+		dev_uc_del(fcoe->netdev, port->data_src_addr);
 	if (!is_zero_ether_addr(addr))
-		dev_unicast_add(fcoe->netdev, addr);
+		dev_uc_add(fcoe->netdev, addr);
 	memcpy(port->data_src_addr, addr, ETH_ALEN);
 	rtnl_unlock();
 }
@@ -819,7 +819,7 @@ static void fcoe_if_destroy(struct fc_lport *lport)
 
 	rtnl_lock();
 	if (!is_zero_ether_addr(port->data_src_addr))
-		dev_unicast_delete(netdev, port->data_src_addr);
+		dev_uc_del(netdev, port->data_src_addr);
 	rtnl_unlock();
 
 	/* receives may not be stopped until after this */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b5670ab..60f0c83 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1991,15 +1991,20 @@ extern int dev_addr_add_multiple(struct net_device *to_dev,
 extern int dev_addr_del_multiple(struct net_device *to_dev,
 				 struct net_device *from_dev,
 				 unsigned char addr_type);
+extern void dev_addr_flush(struct net_device *dev);
+extern int dev_addr_init(struct net_device *dev);
+
+/* Functions used for unicast addresses handling */
+extern int dev_uc_add(struct net_device *dev, unsigned char *addr);
+extern int dev_uc_del(struct net_device *dev, unsigned char *addr);
+extern int dev_uc_sync(struct net_device *to, struct net_device *from);
+extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
+extern void dev_uc_flush(struct net_device *dev);
+extern void dev_uc_init(struct net_device *dev);
 
 /* Functions used for secondary unicast and multicast support */
 extern void		dev_set_rx_mode(struct net_device *dev);
 extern void		__dev_set_rx_mode(struct net_device *dev);
-extern int		dev_unicast_delete(struct net_device *dev, void *addr);
-extern int		dev_unicast_add(struct net_device *dev, void *addr);
-extern int		dev_unicast_sync(struct net_device *to, struct net_device *from);
-extern void		dev_unicast_unsync(struct net_device *to, struct net_device *from);
-extern void		dev_unicast_flush(struct net_device *dev);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index c39a5f4..bd33f02 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -356,13 +356,13 @@ static void vlan_sync_address(struct net_device *dev,
 	 * the new address */
 	if (compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
 	    !compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
-		dev_unicast_delete(dev, vlandev->dev_addr);
+		dev_uc_del(dev, vlandev->dev_addr);
 
 	/* vlan address was equal to the old address and is different from
 	 * the new address */
 	if (!compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
 	    compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
-		dev_unicast_add(dev, vlandev->dev_addr);
+		dev_uc_add(dev, vlandev->dev_addr);
 
 	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9e83272..7f4d247 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -461,7 +461,7 @@ static int vlan_dev_open(struct net_device *dev)
 		return -ENETDOWN;
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr)) {
-		err = dev_unicast_add(real_dev, dev->dev_addr);
+		err = dev_uc_add(real_dev, dev->dev_addr);
 		if (err < 0)
 			goto out;
 	}
@@ -490,7 +490,7 @@ clear_allmulti:
 		dev_set_allmulti(real_dev, -1);
 del_unicast:
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
-		dev_unicast_delete(real_dev, dev->dev_addr);
+		dev_uc_del(real_dev, dev->dev_addr);
 out:
 	netif_carrier_off(dev);
 	return err;
@@ -505,14 +505,14 @@ static int vlan_dev_stop(struct net_device *dev)
 		vlan_gvrp_request_leave(dev);
 
 	dev_mc_unsync(real_dev, dev);
-	dev_unicast_unsync(real_dev, dev);
+	dev_uc_unsync(real_dev, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(real_dev, -1);
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(real_dev, -1);
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
-		dev_unicast_delete(real_dev, dev->dev_addr);
+		dev_uc_del(real_dev, dev->dev_addr);
 
 	netif_carrier_off(dev);
 	return 0;
@@ -531,13 +531,13 @@ static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 		goto out;
 
 	if (compare_ether_addr(addr->sa_data, real_dev->dev_addr)) {
-		err = dev_unicast_add(real_dev, addr->sa_data);
+		err = dev_uc_add(real_dev, addr->sa_data);
 		if (err < 0)
 			return err;
 	}
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
-		dev_unicast_delete(real_dev, dev->dev_addr);
+		dev_uc_del(real_dev, dev->dev_addr);
 
 out:
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
@@ -654,7 +654,7 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
 {
 	dev_mc_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
-	dev_unicast_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
+	dev_uc_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
 }
 
 /*
diff --git a/net/core/Makefile b/net/core/Makefile
index 08791ac..0a899f1 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -8,7 +8,8 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
-			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
+			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
+			dev_addr_lists.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/dev.c b/net/core/dev.c
index e19cdae..d80cc20 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3966,314 +3966,6 @@ void dev_set_rx_mode(struct net_device *dev)
 	netif_addr_unlock_bh(dev);
 }
 
-/* hw addresses list handling functions */
-
-static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
-			 int addr_len, unsigned char addr_type)
-{
-	struct netdev_hw_addr *ha;
-	int alloc_size;
-
-	if (addr_len > MAX_ADDR_LEN)
-		return -EINVAL;
-
-	list_for_each_entry(ha, &list->list, list) {
-		if (!memcmp(ha->addr, addr, addr_len) &&
-		    ha->type == addr_type) {
-			ha->refcount++;
-			return 0;
-		}
-	}
-
-
-	alloc_size = sizeof(*ha);
-	if (alloc_size < L1_CACHE_BYTES)
-		alloc_size = L1_CACHE_BYTES;
-	ha = kmalloc(alloc_size, GFP_ATOMIC);
-	if (!ha)
-		return -ENOMEM;
-	memcpy(ha->addr, addr, addr_len);
-	ha->type = addr_type;
-	ha->refcount = 1;
-	ha->synced = false;
-	list_add_tail_rcu(&ha->list, &list->list);
-	list->count++;
-	return 0;
-}
-
-static void ha_rcu_free(struct rcu_head *head)
-{
-	struct netdev_hw_addr *ha;
-
-	ha = container_of(head, struct netdev_hw_addr, rcu_head);
-	kfree(ha);
-}
-
-static int __hw_addr_del(struct netdev_hw_addr_list *list, unsigned char *addr,
-			 int addr_len, unsigned char addr_type)
-{
-	struct netdev_hw_addr *ha;
-
-	list_for_each_entry(ha, &list->list, list) {
-		if (!memcmp(ha->addr, addr, addr_len) &&
-		    (ha->type == addr_type || !addr_type)) {
-			if (--ha->refcount)
-				return 0;
-			list_del_rcu(&ha->list);
-			call_rcu(&ha->rcu_head, ha_rcu_free);
-			list->count--;
-			return 0;
-		}
-	}
-	return -ENOENT;
-}
-
-static int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
-				  struct netdev_hw_addr_list *from_list,
-				  int addr_len,
-				  unsigned char addr_type)
-{
-	int err;
-	struct netdev_hw_addr *ha, *ha2;
-	unsigned char type;
-
-	list_for_each_entry(ha, &from_list->list, list) {
-		type = addr_type ? addr_type : ha->type;
-		err = __hw_addr_add(to_list, ha->addr, addr_len, type);
-		if (err)
-			goto unroll;
-	}
-	return 0;
-
-unroll:
-	list_for_each_entry(ha2, &from_list->list, list) {
-		if (ha2 == ha)
-			break;
-		type = addr_type ? addr_type : ha2->type;
-		__hw_addr_del(to_list, ha2->addr, addr_len, type);
-	}
-	return err;
-}
-
-static void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
-				   struct netdev_hw_addr_list *from_list,
-				   int addr_len,
-				   unsigned char addr_type)
-{
-	struct netdev_hw_addr *ha;
-	unsigned char type;
-
-	list_for_each_entry(ha, &from_list->list, list) {
-		type = addr_type ? addr_type : ha->type;
-		__hw_addr_del(to_list, ha->addr, addr_len, addr_type);
-	}
-}
-
-static int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
-			  struct netdev_hw_addr_list *from_list,
-			  int addr_len)
-{
-	int err = 0;
-	struct netdev_hw_addr *ha, *tmp;
-
-	list_for_each_entry_safe(ha, tmp, &from_list->list, list) {
-		if (!ha->synced) {
-			err = __hw_addr_add(to_list, ha->addr,
-					    addr_len, ha->type);
-			if (err)
-				break;
-			ha->synced = true;
-			ha->refcount++;
-		} else if (ha->refcount == 1) {
-			__hw_addr_del(to_list, ha->addr, addr_len, ha->type);
-			__hw_addr_del(from_list, ha->addr, addr_len, ha->type);
-		}
-	}
-	return err;
-}
-
-static void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
-			     struct netdev_hw_addr_list *from_list,
-			     int addr_len)
-{
-	struct netdev_hw_addr *ha, *tmp;
-
-	list_for_each_entry_safe(ha, tmp, &from_list->list, list) {
-		if (ha->synced) {
-			__hw_addr_del(to_list, ha->addr,
-				      addr_len, ha->type);
-			ha->synced = false;
-			__hw_addr_del(from_list, ha->addr,
-				      addr_len, ha->type);
-		}
-	}
-}
-
-static void __hw_addr_flush(struct netdev_hw_addr_list *list)
-{
-	struct netdev_hw_addr *ha, *tmp;
-
-	list_for_each_entry_safe(ha, tmp, &list->list, list) {
-		list_del_rcu(&ha->list);
-		call_rcu(&ha->rcu_head, ha_rcu_free);
-	}
-	list->count = 0;
-}
-
-static void __hw_addr_init(struct netdev_hw_addr_list *list)
-{
-	INIT_LIST_HEAD(&list->list);
-	list->count = 0;
-}
-
-/* Device addresses handling functions */
-
-static void dev_addr_flush(struct net_device *dev)
-{
-	/* rtnl_mutex must be held here */
-
-	__hw_addr_flush(&dev->dev_addrs);
-	dev->dev_addr = NULL;
-}
-
-static int dev_addr_init(struct net_device *dev)
-{
-	unsigned char addr[MAX_ADDR_LEN];
-	struct netdev_hw_addr *ha;
-	int err;
-
-	/* rtnl_mutex must be held here */
-
-	__hw_addr_init(&dev->dev_addrs);
-	memset(addr, 0, sizeof(addr));
-	err = __hw_addr_add(&dev->dev_addrs, addr, sizeof(addr),
-			    NETDEV_HW_ADDR_T_LAN);
-	if (!err) {
-		/*
-		 * Get the first (previously created) address from the list
-		 * and set dev_addr pointer to this location.
-		 */
-		ha = list_first_entry(&dev->dev_addrs.list,
-				      struct netdev_hw_addr, list);
-		dev->dev_addr = ha->addr;
-	}
-	return err;
-}
-
-/**
- *	dev_addr_add	- Add a device address
- *	@dev: device
- *	@addr: address to add
- *	@addr_type: address type
- *
- *	Add a device address to the device or increase the reference count if
- *	it already exists.
- *
- *	The caller must hold the rtnl_mutex.
- */
-int dev_addr_add(struct net_device *dev, unsigned char *addr,
-		 unsigned char addr_type)
-{
-	int err;
-
-	ASSERT_RTNL();
-
-	err = __hw_addr_add(&dev->dev_addrs, addr, dev->addr_len, addr_type);
-	if (!err)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-	return err;
-}
-EXPORT_SYMBOL(dev_addr_add);
-
-/**
- *	dev_addr_del	- Release a device address.
- *	@dev: device
- *	@addr: address to delete
- *	@addr_type: address type
- *
- *	Release reference to a device address and remove it from the device
- *	if the reference count drops to zero.
- *
- *	The caller must hold the rtnl_mutex.
- */
-int dev_addr_del(struct net_device *dev, unsigned char *addr,
-		 unsigned char addr_type)
-{
-	int err;
-	struct netdev_hw_addr *ha;
-
-	ASSERT_RTNL();
-
-	/*
-	 * We can not remove the first address from the list because
-	 * dev->dev_addr points to that.
-	 */
-	ha = list_first_entry(&dev->dev_addrs.list,
-			      struct netdev_hw_addr, list);
-	if (ha->addr == dev->dev_addr && ha->refcount == 1)
-		return -ENOENT;
-
-	err = __hw_addr_del(&dev->dev_addrs, addr, dev->addr_len,
-			    addr_type);
-	if (!err)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-	return err;
-}
-EXPORT_SYMBOL(dev_addr_del);
-
-/**
- *	dev_addr_add_multiple	- Add device addresses from another device
- *	@to_dev: device to which addresses will be added
- *	@from_dev: device from which addresses will be added
- *	@addr_type: address type - 0 means type will be used from from_dev
- *
- *	Add device addresses of the one device to another.
- **
- *	The caller must hold the rtnl_mutex.
- */
-int dev_addr_add_multiple(struct net_device *to_dev,
-			  struct net_device *from_dev,
-			  unsigned char addr_type)
-{
-	int err;
-
-	ASSERT_RTNL();
-
-	if (from_dev->addr_len != to_dev->addr_len)
-		return -EINVAL;
-	err = __hw_addr_add_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
-				     to_dev->addr_len, addr_type);
-	if (!err)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
-	return err;
-}
-EXPORT_SYMBOL(dev_addr_add_multiple);
-
-/**
- *	dev_addr_del_multiple	- Delete device addresses by another device
- *	@to_dev: device where the addresses will be deleted
- *	@from_dev: device by which addresses the addresses will be deleted
- *	@addr_type: address type - 0 means type will used from from_dev
- *
- *	Deletes addresses in to device by the list of addresses in from device.
- *
- *	The caller must hold the rtnl_mutex.
- */
-int dev_addr_del_multiple(struct net_device *to_dev,
-			  struct net_device *from_dev,
-			  unsigned char addr_type)
-{
-	ASSERT_RTNL();
-
-	if (from_dev->addr_len != to_dev->addr_len)
-		return -EINVAL;
-	__hw_addr_del_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
-			       to_dev->addr_len, addr_type);
-	call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
-	return 0;
-}
-EXPORT_SYMBOL(dev_addr_del_multiple);
-
 /* multicast addresses handling functions */
 
 int __dev_addr_delete(struct dev_addr_list **list, int *count,
@@ -4334,57 +4026,6 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
 	return 0;
 }
 
-/**
- *	dev_unicast_delete	- Release secondary unicast address.
- *	@dev: device
- *	@addr: address to delete
- *
- *	Release reference to a secondary unicast address and remove it
- *	from the device if the reference count drops to zero.
- *
- * 	The caller must hold the rtnl_mutex.
- */
-int dev_unicast_delete(struct net_device *dev, void *addr)
-{
-	int err;
-
-	ASSERT_RTNL();
-
-	netif_addr_lock_bh(dev);
-	err = __hw_addr_del(&dev->uc, addr, dev->addr_len,
-			    NETDEV_HW_ADDR_T_UNICAST);
-	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_addr_unlock_bh(dev);
-	return err;
-}
-EXPORT_SYMBOL(dev_unicast_delete);
-
-/**
- *	dev_unicast_add		- add a secondary unicast address
- *	@dev: device
- *	@addr: address to add
- *
- *	Add a secondary unicast address to the device or increase
- *	the reference count if it already exists.
- *
- *	The caller must hold the rtnl_mutex.
- */
-int dev_unicast_add(struct net_device *dev, void *addr)
-{
-	int err;
-
-	ASSERT_RTNL();
-
-	netif_addr_lock_bh(dev);
-	err = __hw_addr_add(&dev->uc, addr, dev->addr_len,
-			    NETDEV_HW_ADDR_T_UNICAST);
-	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_addr_unlock_bh(dev);
-	return err;
-}
-EXPORT_SYMBOL(dev_unicast_add);
 
 int __dev_addr_sync(struct dev_addr_list **to, int *to_count,
 		    struct dev_addr_list **from, int *from_count)
@@ -4434,71 +4075,6 @@ void __dev_addr_unsync(struct dev_addr_list **to, int *to_count,
 }
 EXPORT_SYMBOL_GPL(__dev_addr_unsync);
 
-/**
- *	dev_unicast_sync - Synchronize device's unicast list to another device
- *	@to: destination device
- *	@from: source device
- *
- *	Add newly added addresses to the destination device and release
- *	addresses that have no users left. The source device must be
- *	locked by netif_tx_lock_bh.
- *
- *	This function is intended to be called from the dev->set_rx_mode
- *	function of layered software devices.
- */
-int dev_unicast_sync(struct net_device *to, struct net_device *from)
-{
-	int err = 0;
-
-	if (to->addr_len != from->addr_len)
-		return -EINVAL;
-
-	netif_addr_lock_bh(to);
-	err = __hw_addr_sync(&to->uc, &from->uc, to->addr_len);
-	if (!err)
-		__dev_set_rx_mode(to);
-	netif_addr_unlock_bh(to);
-	return err;
-}
-EXPORT_SYMBOL(dev_unicast_sync);
-
-/**
- *	dev_unicast_unsync - Remove synchronized addresses from the destination device
- *	@to: destination device
- *	@from: source device
- *
- *	Remove all addresses that were added to the destination device by
- *	dev_unicast_sync(). This function is intended to be called from the
- *	dev->stop function of layered software devices.
- */
-void dev_unicast_unsync(struct net_device *to, struct net_device *from)
-{
-	if (to->addr_len != from->addr_len)
-		return;
-
-	netif_addr_lock_bh(from);
-	netif_addr_lock(to);
-	__hw_addr_unsync(&to->uc, &from->uc, to->addr_len);
-	__dev_set_rx_mode(to);
-	netif_addr_unlock(to);
-	netif_addr_unlock_bh(from);
-}
-EXPORT_SYMBOL(dev_unicast_unsync);
-
-void dev_unicast_flush(struct net_device *dev)
-{
-	netif_addr_lock_bh(dev);
-	__hw_addr_flush(&dev->uc);
-	netif_addr_unlock_bh(dev);
-}
-EXPORT_SYMBOL(dev_unicast_flush);
-
-static void dev_unicast_init(struct net_device *dev)
-{
-	__hw_addr_init(&dev->uc);
-}
-
-
 static void __dev_addr_discard(struct dev_addr_list **list)
 {
 	struct dev_addr_list *tmp;
@@ -5151,7 +4727,7 @@ static void rollback_registered_many(struct list_head *head)
 		/*
 		 *	Flush the unicast and multicast chains
 		 */
-		dev_unicast_flush(dev);
+		dev_uc_flush(dev);
 		dev_addr_discard(dev);
 
 		if (dev->netdev_ops->ndo_uninit)
@@ -5732,7 +5308,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	if (dev_addr_init(dev))
 		goto free_rx;
 
-	dev_unicast_init(dev);
+	dev_uc_init(dev);
 
 	dev_net_set(dev, &init_net);
 
@@ -5966,7 +5542,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	/*
 	 *	Flush the unicast and multicast chains
 	 */
-	dev_unicast_flush(dev);
+	dev_uc_flush(dev);
 	dev_addr_discard(dev);
 
 	netdev_unregister_kobject(dev);
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
new file mode 100644
index 0000000..7e52b6d
--- /dev/null
+++ b/net/core/dev_addr_lists.c
@@ -0,0 +1,478 @@
+/*
+ * net/core/dev_addr_lists.c - Functions for handling net device lists
+ * Copyright (c) 2010 Jiri Pirko <jpirko@redhat.com>
+ *
+ * This file contains functions for working with unicast, multicast and device
+ * addresses lists.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/list.h>
+
+/*
+ * General list handling functions
+ */
+
+static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
+			 int addr_len, unsigned char addr_type)
+{
+	struct netdev_hw_addr *ha;
+	int alloc_size;
+
+	if (addr_len > MAX_ADDR_LEN)
+		return -EINVAL;
+
+	list_for_each_entry(ha, &list->list, list) {
+		if (!memcmp(ha->addr, addr, addr_len) &&
+		    ha->type == addr_type) {
+			ha->refcount++;
+			return 0;
+		}
+	}
+
+
+	alloc_size = sizeof(*ha);
+	if (alloc_size < L1_CACHE_BYTES)
+		alloc_size = L1_CACHE_BYTES;
+	ha = kmalloc(alloc_size, GFP_ATOMIC);
+	if (!ha)
+		return -ENOMEM;
+	memcpy(ha->addr, addr, addr_len);
+	ha->type = addr_type;
+	ha->refcount = 1;
+	ha->synced = false;
+	list_add_tail_rcu(&ha->list, &list->list);
+	list->count++;
+	return 0;
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
+static int __hw_addr_del(struct netdev_hw_addr_list *list, unsigned char *addr,
+			 int addr_len, unsigned char addr_type)
+{
+	struct netdev_hw_addr *ha;
+
+	list_for_each_entry(ha, &list->list, list) {
+		if (!memcmp(ha->addr, addr, addr_len) &&
+		    (ha->type == addr_type || !addr_type)) {
+			if (--ha->refcount)
+				return 0;
+			list_del_rcu(&ha->list);
+			call_rcu(&ha->rcu_head, ha_rcu_free);
+			list->count--;
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
+static int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
+				  struct netdev_hw_addr_list *from_list,
+				  int addr_len,
+				  unsigned char addr_type)
+{
+	int err;
+	struct netdev_hw_addr *ha, *ha2;
+	unsigned char type;
+
+	list_for_each_entry(ha, &from_list->list, list) {
+		type = addr_type ? addr_type : ha->type;
+		err = __hw_addr_add(to_list, ha->addr, addr_len, type);
+		if (err)
+			goto unroll;
+	}
+	return 0;
+
+unroll:
+	list_for_each_entry(ha2, &from_list->list, list) {
+		if (ha2 == ha)
+			break;
+		type = addr_type ? addr_type : ha2->type;
+		__hw_addr_del(to_list, ha2->addr, addr_len, type);
+	}
+	return err;
+}
+
+static void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
+				   struct netdev_hw_addr_list *from_list,
+				   int addr_len,
+				   unsigned char addr_type)
+{
+	struct netdev_hw_addr *ha;
+	unsigned char type;
+
+	list_for_each_entry(ha, &from_list->list, list) {
+		type = addr_type ? addr_type : ha->type;
+		__hw_addr_del(to_list, ha->addr, addr_len, addr_type);
+	}
+}
+
+static int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
+			  struct netdev_hw_addr_list *from_list,
+			  int addr_len)
+{
+	int err = 0;
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &from_list->list, list) {
+		if (!ha->synced) {
+			err = __hw_addr_add(to_list, ha->addr,
+					    addr_len, ha->type);
+			if (err)
+				break;
+			ha->synced = true;
+			ha->refcount++;
+		} else if (ha->refcount == 1) {
+			__hw_addr_del(to_list, ha->addr, addr_len, ha->type);
+			__hw_addr_del(from_list, ha->addr, addr_len, ha->type);
+		}
+	}
+	return err;
+}
+
+static void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
+			     struct netdev_hw_addr_list *from_list,
+			     int addr_len)
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &from_list->list, list) {
+		if (ha->synced) {
+			__hw_addr_del(to_list, ha->addr,
+				      addr_len, ha->type);
+			ha->synced = false;
+			__hw_addr_del(from_list, ha->addr,
+				      addr_len, ha->type);
+		}
+	}
+}
+
+static void __hw_addr_flush(struct netdev_hw_addr_list *list)
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		list_del_rcu(&ha->list);
+		call_rcu(&ha->rcu_head, ha_rcu_free);
+	}
+	list->count = 0;
+}
+
+static void __hw_addr_init(struct netdev_hw_addr_list *list)
+{
+	INIT_LIST_HEAD(&list->list);
+	list->count = 0;
+}
+
+/*
+ * Device addresses handling functions
+ */
+
+/**
+ *	dev_addr_flush - Flush device address list
+ *	@dev: device
+ *
+ *	Flush device address list and reset ->dev_addr.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+void dev_addr_flush(struct net_device *dev)
+{
+	/* rtnl_mutex must be held here */
+
+	__hw_addr_flush(&dev->dev_addrs);
+	dev->dev_addr = NULL;
+}
+EXPORT_SYMBOL(dev_addr_flush);
+
+/**
+ *	dev_addr_init - Init device address list
+ *	@dev: device
+ *
+ *	Init device address list and create the first element,
+ *	used by ->dev_addr.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_init(struct net_device *dev)
+{
+	unsigned char addr[MAX_ADDR_LEN];
+	struct netdev_hw_addr *ha;
+	int err;
+
+	/* rtnl_mutex must be held here */
+
+	__hw_addr_init(&dev->dev_addrs);
+	memset(addr, 0, sizeof(addr));
+	err = __hw_addr_add(&dev->dev_addrs, addr, sizeof(addr),
+			    NETDEV_HW_ADDR_T_LAN);
+	if (!err) {
+		/*
+		 * Get the first (previously created) address from the list
+		 * and set dev_addr pointer to this location.
+		 */
+		ha = list_first_entry(&dev->dev_addrs.list,
+				      struct netdev_hw_addr, list);
+		dev->dev_addr = ha->addr;
+	}
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_init);
+
+/**
+ *	dev_addr_add - Add a device address
+ *	@dev: device
+ *	@addr: address to add
+ *	@addr_type: address type
+ *
+ *	Add a device address to the device or increase the reference count if
+ *	it already exists.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_add(struct net_device *dev, unsigned char *addr,
+		 unsigned char addr_type)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	err = __hw_addr_add(&dev->dev_addrs, addr, dev->addr_len, addr_type);
+	if (!err)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_add);
+
+/**
+ *	dev_addr_del - Release a device address.
+ *	@dev: device
+ *	@addr: address to delete
+ *	@addr_type: address type
+ *
+ *	Release reference to a device address and remove it from the device
+ *	if the reference count drops to zero.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_del(struct net_device *dev, unsigned char *addr,
+		 unsigned char addr_type)
+{
+	int err;
+	struct netdev_hw_addr *ha;
+
+	ASSERT_RTNL();
+
+	/*
+	 * We can not remove the first address from the list because
+	 * dev->dev_addr points to that.
+	 */
+	ha = list_first_entry(&dev->dev_addrs.list,
+			      struct netdev_hw_addr, list);
+	if (ha->addr == dev->dev_addr && ha->refcount == 1)
+		return -ENOENT;
+
+	err = __hw_addr_del(&dev->dev_addrs, addr, dev->addr_len,
+			    addr_type);
+	if (!err)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_del);
+
+/**
+ *	dev_addr_add_multiple - Add device addresses from another device
+ *	@to_dev: device to which addresses will be added
+ *	@from_dev: device from which addresses will be added
+ *	@addr_type: address type - 0 means type will be used from from_dev
+ *
+ *	Add device addresses of the one device to another.
+ **
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_add_multiple(struct net_device *to_dev,
+			  struct net_device *from_dev,
+			  unsigned char addr_type)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	if (from_dev->addr_len != to_dev->addr_len)
+		return -EINVAL;
+	err = __hw_addr_add_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
+				     to_dev->addr_len, addr_type);
+	if (!err)
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_addr_add_multiple);
+
+/**
+ *	dev_addr_del_multiple - Delete device addresses by another device
+ *	@to_dev: device where the addresses will be deleted
+ *	@from_dev: device by which addresses the addresses will be deleted
+ *	@addr_type: address type - 0 means type will used from from_dev
+ *
+ *	Deletes addresses in to device by the list of addresses in from device.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int dev_addr_del_multiple(struct net_device *to_dev,
+			  struct net_device *from_dev,
+			  unsigned char addr_type)
+{
+	ASSERT_RTNL();
+
+	if (from_dev->addr_len != to_dev->addr_len)
+		return -EINVAL;
+	__hw_addr_del_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
+			       to_dev->addr_len, addr_type);
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
+	return 0;
+}
+EXPORT_SYMBOL(dev_addr_del_multiple);
+
+/*
+ * Unicast list handling functions
+ */
+
+/**
+ *	dev_uc_add - Add a secondary unicast address
+ *	@dev: device
+ *	@addr: address to add
+ *
+ *	Add a secondary unicast address to the device or increase
+ *	the reference count if it already exists.
+ */
+int dev_uc_add(struct net_device *dev, unsigned char *addr)
+{
+	int err;
+
+	netif_addr_lock_bh(dev);
+	err = __hw_addr_add(&dev->uc, addr, dev->addr_len,
+			    NETDEV_HW_ADDR_T_UNICAST);
+	if (!err)
+		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_uc_add);
+
+/**
+ *	dev_uc_del - Release secondary unicast address.
+ *	@dev: device
+ *	@addr: address to delete
+ *
+ *	Release reference to a secondary unicast address and remove it
+ *	from the device if the reference count drops to zero.
+ */
+int dev_uc_del(struct net_device *dev, unsigned char *addr)
+{
+	int err;
+
+	netif_addr_lock_bh(dev);
+	err = __hw_addr_del(&dev->uc, addr, dev->addr_len,
+			    NETDEV_HW_ADDR_T_UNICAST);
+	if (!err)
+		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_uc_del);
+
+/**
+ *	dev_uc_sync - Synchronize device's unicast list to another device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Add newly added addresses to the destination device and release
+ *	addresses that have no users left. The source device must be
+ *	locked by netif_tx_lock_bh.
+ *
+ *	This function is intended to be called from the dev->set_rx_mode
+ *	function of layered software devices.
+ */
+int dev_uc_sync(struct net_device *to, struct net_device *from)
+{
+	int err = 0;
+
+	if (to->addr_len != from->addr_len)
+		return -EINVAL;
+
+	netif_addr_lock_bh(to);
+	err = __hw_addr_sync(&to->uc, &from->uc, to->addr_len);
+	if (!err)
+		__dev_set_rx_mode(to);
+	netif_addr_unlock_bh(to);
+	return err;
+}
+EXPORT_SYMBOL(dev_uc_sync);
+
+/**
+ *	dev_uc_unsync - Remove synchronized addresses from the destination device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Remove all addresses that were added to the destination device by
+ *	dev_uc_sync(). This function is intended to be called from the
+ *	dev->stop function of layered software devices.
+ */
+void dev_uc_unsync(struct net_device *to, struct net_device *from)
+{
+	if (to->addr_len != from->addr_len)
+		return;
+
+	netif_addr_lock_bh(from);
+	netif_addr_lock(to);
+	__hw_addr_unsync(&to->uc, &from->uc, to->addr_len);
+	__dev_set_rx_mode(to);
+	netif_addr_unlock(to);
+	netif_addr_unlock_bh(from);
+}
+EXPORT_SYMBOL(dev_uc_unsync);
+
+/**
+ *	dev_uc_flush - Flush unicast addresses
+ *	@dev: device
+ *
+ *	Flush unicast addresses.
+ */
+void dev_uc_flush(struct net_device *dev)
+{
+	netif_addr_lock_bh(dev);
+	__hw_addr_flush(&dev->uc);
+	netif_addr_unlock_bh(dev);
+}
+EXPORT_SYMBOL(dev_uc_flush);
+
+/**
+ *	dev_uc_flush - Init unicast address list
+ *	@dev: device
+ *
+ *	Init unicast address list.
+ */
+void dev_uc_init(struct net_device *dev)
+{
+	__hw_addr_init(&dev->uc);
+}
+EXPORT_SYMBOL(dev_uc_init);
+
+/*
+ * Multicast list handling functions
+ */
+
+/* To be filled here */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2175e6d..8fdca56 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -67,7 +67,7 @@ static int dsa_slave_open(struct net_device *dev)
 		return -ENETDOWN;
 
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr)) {
-		err = dev_unicast_add(master, dev->dev_addr);
+		err = dev_uc_add(master, dev->dev_addr);
 		if (err < 0)
 			goto out;
 	}
@@ -90,7 +90,7 @@ clear_allmulti:
 		dev_set_allmulti(master, -1);
 del_unicast:
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
-		dev_unicast_delete(master, dev->dev_addr);
+		dev_uc_del(master, dev->dev_addr);
 out:
 	return err;
 }
@@ -101,14 +101,14 @@ static int dsa_slave_close(struct net_device *dev)
 	struct net_device *master = p->parent->dst->master_netdev;
 
 	dev_mc_unsync(master, dev);
-	dev_unicast_unsync(master, dev);
+	dev_uc_unsync(master, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(master, -1);
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(master, -1);
 
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
-		dev_unicast_delete(master, dev->dev_addr);
+		dev_uc_del(master, dev->dev_addr);
 
 	return 0;
 }
@@ -130,7 +130,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 	struct net_device *master = p->parent->dst->master_netdev;
 
 	dev_mc_sync(master, dev);
-	dev_unicast_sync(master, dev);
+	dev_uc_sync(master, dev);
 }
 
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
@@ -147,13 +147,13 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 		goto out;
 
 	if (compare_ether_addr(addr->sa_data, master->dev_addr)) {
-		err = dev_unicast_add(master, addr->sa_data);
+		err = dev_uc_add(master, addr->sa_data);
 		if (err < 0)
 			return err;
 	}
 
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
-		dev_unicast_delete(master, dev->dev_addr);
+		dev_uc_del(master, dev->dev_addr);
 
 out:
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1612d41..48c1e0a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1705,9 +1705,9 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 		if (i->alen != dev->addr_len)
 			return -EINVAL;
 		if (what > 0)
-			return dev_unicast_add(dev, i->addr);
+			return dev_uc_add(dev, i->addr);
 		else
-			return dev_unicast_delete(dev, i->addr);
+			return dev_uc_del(dev, i->addr);
 		break;
 	default:
 		break;
-- 
1.6.6.1

