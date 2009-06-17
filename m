From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next] net: group address list and its count
Date: Wed, 17 Jun 2009 13:12:19 +0200
Message-ID: <20090617111218.GB3834@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57656 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757071AbZFQLM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 07:12:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next] net: group address list and its count

This patch is inspired by patch recently posted by Johannes Berg. Basically what
my patch does is to group list and a count of addresses into newly introduced
structure netdev_hw_addr_list. This brings us two benefits:
1) struct net_device becames a bit nicer.
2) in the future there will be a possibility to operate with lists independently
   on netdevices (with exporting right functions).
I wanted to introduce this patch before I'll post a multicast lists conversion.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bnx2.c              |    4 +-
 drivers/net/e1000/e1000_main.c  |    4 +-
 drivers/net/ixgbe/ixgbe_main.c  |    6 +-
 drivers/net/mv643xx_eth.c       |    2 +-
 drivers/net/niu.c               |    4 +-
 drivers/net/virtio_net.c        |   10 ++--
 drivers/s390/net/qeth_l2_main.c |    2 +-
 include/linux/netdevice.h       |   17 +++--
 net/core/dev.c                  |  130 ++++++++++++++++++--------------------
 9 files changed, 89 insertions(+), 90 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7e37381..38f1c33 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3552,14 +3552,14 @@ bnx2_set_rx_mode(struct net_device *dev)
 		sort_mode |= BNX2_RPM_SORT_USER0_MC_HSH_EN;
 	}
 
-	if (dev->uc_count > BNX2_MAX_UNICAST_ADDRESSES) {
+	if (dev->uc.count > BNX2_MAX_UNICAST_ADDRESSES) {
 		rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
 		sort_mode |= BNX2_RPM_SORT_USER0_PROM_EN |
 			     BNX2_RPM_SORT_USER0_PROM_VLAN;
 	} else if (!(dev->flags & IFF_PROMISC)) {
 		/* Add all entries into to the match filter list */
 		i = 0;
-		list_for_each_entry(ha, &dev->uc_list, list) {
+		list_for_each_entry(ha, &dev->uc.list, list) {
 			bnx2_set_mac_addr(bp, ha->addr,
 					  i + BNX2_START_UNICAST_ADDRESS_INDEX);
 			sort_mode |= (1 <<
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8d36743..5e3356f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2370,7 +2370,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			rctl |= E1000_RCTL_VFE;
 	}
 
-	if (netdev->uc_count > rar_entries - 1) {
+	if (netdev->uc.count > rar_entries - 1) {
 		rctl |= E1000_RCTL_UPE;
 	} else if (!(netdev->flags & IFF_PROMISC)) {
 		rctl &= ~E1000_RCTL_UPE;
@@ -2394,7 +2394,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	 */
 	i = 1;
 	if (use_uc)
-		list_for_each_entry(ha, &netdev->uc_list, list) {
+		list_for_each_entry(ha, &netdev->uc.list, list) {
 			if (i == rar_entries)
 				break;
 			e1000_rar_set(hw, ha->addr, i++);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a551a96..e756e22 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2321,7 +2321,7 @@ static void ixgbe_set_rx_mode(struct net_device *netdev)
 	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
 	/* reprogram secondary unicast list */
-	hw->mac.ops.update_uc_addr_list(hw, &netdev->uc_list);
+	hw->mac.ops.update_uc_addr_list(hw, &netdev->uc.list);
 
 	/* reprogram multicast list */
 	addr_count = netdev->mc_count;
@@ -5261,7 +5261,7 @@ static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
 
 /**
  * ixgbe_add_sanmac_netdev - Add the SAN MAC address to the corresponding
- * netdev->dev_addr_list
+ * netdev->dev_addrs
  * @netdev: network interface device structure
  *
  * Returns non-zero on failure
@@ -5282,7 +5282,7 @@ static int ixgbe_add_sanmac_netdev(struct net_device *dev)
 
 /**
  * ixgbe_del_sanmac_netdev - Removes the SAN MAC address to the corresponding
- * netdev->dev_addr_list
+ * netdev->dev_addrs
  * @netdev: network interface device structure
  *
  * Returns non-zero on failure
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b4e18a5..745ae8b 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1729,7 +1729,7 @@ static u32 uc_addr_filter_mask(struct net_device *dev)
 		return 0;
 
 	nibbles = 1 << (dev->dev_addr[5] & 0x0f);
-	list_for_each_entry(ha, &dev->uc_list, list) {
+	list_for_each_entry(ha, &dev->uc.list, list) {
 		if (memcmp(dev->dev_addr, ha->addr, 5))
 			return 0;
 		if ((dev->dev_addr[5] ^ ha->addr[5]) & 0xf0)
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index fa61a12..d2146d4 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6376,7 +6376,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 0))
 		np->flags |= NIU_FLAGS_MCAST;
 
-	alt_cnt = dev->uc_count;
+	alt_cnt = dev->uc.count;
 	if (alt_cnt > niu_num_alt_addr(np)) {
 		alt_cnt = 0;
 		np->flags |= NIU_FLAGS_PROMISC;
@@ -6385,7 +6385,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	if (alt_cnt) {
 		int index = 0;
 
-		list_for_each_entry(ha, &dev->uc_list, list) {
+		list_for_each_entry(ha, &dev->uc.list, list) {
 			err = niu_set_alt_mac(np, index, ha->addr);
 			if (err)
 				printk(KERN_WARNING PFX "%s: Error %d "
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 52198f6..2a6e81d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -709,7 +709,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 			 allmulti ? "en" : "dis");
 
 	/* MAC filter - use one buffer for both lists */
-	mac_data = buf = kzalloc(((dev->uc_count + dev->mc_count) * ETH_ALEN) +
+	mac_data = buf = kzalloc(((dev->uc.count + dev->mc_count) * ETH_ALEN) +
 				 (2 * sizeof(mac_data->entries)), GFP_ATOMIC);
 	if (!buf) {
 		dev_warn(&dev->dev, "No memory for MAC address buffer\n");
@@ -719,16 +719,16 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	sg_init_table(sg, 2);
 
 	/* Store the unicast list and count in the front of the buffer */
-	mac_data->entries = dev->uc_count;
+	mac_data->entries = dev->uc.count;
 	i = 0;
-	list_for_each_entry(ha, &dev->uc_list, list)
+	list_for_each_entry(ha, &dev->uc.list, list)
 		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
 
 	sg_set_buf(&sg[0], mac_data,
-		   sizeof(mac_data->entries) + (dev->uc_count * ETH_ALEN));
+		   sizeof(mac_data->entries) + (dev->uc.count * ETH_ALEN));
 
 	/* multicast list and count fill the end */
-	mac_data = (void *)&mac_data->macs[dev->uc_count][0];
+	mac_data = (void *)&mac_data->macs[dev->uc.count][0];
 
 	mac_data->entries = dev->mc_count;
 	addr = dev->mc_list;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index ecd3d06..3607d10 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -655,7 +655,7 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 	for (dm = dev->mc_list; dm; dm = dm->next)
 		qeth_l2_add_mc(card, dm->da_addr, 0);
 
-	list_for_each_entry(ha, &dev->uc_list, list)
+	list_for_each_entry(ha, &dev->uc.list, list)
 		qeth_l2_add_mc(card, ha->addr, 1);
 
 	spin_unlock_bh(&card->mclock);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9ea8d6d..d4a4d98 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -224,6 +224,11 @@ struct netdev_hw_addr {
 	struct rcu_head		rcu_head;
 };
 
+struct netdev_hw_addr_list {
+	struct list_head	list;
+	int			count;
+};
+
 struct hh_cache
 {
 	struct hh_cache *hh_next;	/* Next entry			     */
@@ -776,9 +781,8 @@ struct net_device
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */
 
-	struct list_head	uc_list;	/* Secondary unicast mac
-						   addresses */
-	int			uc_count;	/* Number of installed ucasts	*/
+	struct netdev_hw_addr_list	uc;	/* Secondary unicast
+						   mac addresses */
 	int			uc_promisc;
 	spinlock_t		addr_list_lock;
 	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
@@ -810,7 +814,8 @@ struct net_device
 						   because most packets are
 						   unicast) */
 
-	struct list_head	dev_addr_list; /* list of device hw addresses */
+	struct netdev_hw_addr_list	dev_addrs; /* list of device
+						      hw addresses */
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
@@ -1806,11 +1811,11 @@ static inline void netif_addr_unlock_bh(struct net_device *dev)
 }
 
 /*
- * dev_addr_list walker. Should be used only for read access. Call with
+ * dev_addrs walker. Should be used only for read access. Call with
  * rcu_read_lock held.
  */
 #define for_each_dev_addr(dev, ha) \
-		list_for_each_entry_rcu(ha, &dev->dev_addr_list, list)
+		list_for_each_entry_rcu(ha, &dev->dev_addrs.list, list)
 
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 576a615..baf2dc1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3461,10 +3461,10 @@ void __dev_set_rx_mode(struct net_device *dev)
 		/* Unicast addresses changes may only happen under the rtnl,
 		 * therefore calling __dev_set_promiscuity here is safe.
 		 */
-		if (dev->uc_count > 0 && !dev->uc_promisc) {
+		if (dev->uc.count > 0 && !dev->uc_promisc) {
 			__dev_set_promiscuity(dev, 1);
 			dev->uc_promisc = 1;
-		} else if (dev->uc_count == 0 && dev->uc_promisc) {
+		} else if (dev->uc.count == 0 && dev->uc_promisc) {
 			__dev_set_promiscuity(dev, -1);
 			dev->uc_promisc = 0;
 		}
@@ -3483,9 +3483,8 @@ void dev_set_rx_mode(struct net_device *dev)
 
 /* hw addresses list handling functions */
 
-static int __hw_addr_add(struct list_head *list, int *delta,
-			 unsigned char *addr, int addr_len,
-			 unsigned char addr_type)
+static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
+			 int addr_len, unsigned char addr_type)
 {
 	struct netdev_hw_addr *ha;
 	int alloc_size;
@@ -3493,7 +3492,7 @@ static int __hw_addr_add(struct list_head *list, int *delta,
 	if (addr_len > MAX_ADDR_LEN)
 		return -EINVAL;
 
-	list_for_each_entry(ha, list, list) {
+	list_for_each_entry(ha, &list->list, list) {
 		if (!memcmp(ha->addr, addr, addr_len) &&
 		    ha->type == addr_type) {
 			ha->refcount++;
@@ -3512,9 +3511,8 @@ static int __hw_addr_add(struct list_head *list, int *delta,
 	ha->type = addr_type;
 	ha->refcount = 1;
 	ha->synced = false;
-	list_add_tail_rcu(&ha->list, list);
-	if (delta)
-		(*delta)++;
+	list_add_tail_rcu(&ha->list, &list->list);
+	list->count++;
 	return 0;
 }
 
@@ -3526,120 +3524,121 @@ static void ha_rcu_free(struct rcu_head *head)
 	kfree(ha);
 }
 
-static int __hw_addr_del(struct list_head *list, int *delta,
-			 unsigned char *addr, int addr_len,
-			 unsigned char addr_type)
+static int __hw_addr_del(struct netdev_hw_addr_list *list, unsigned char *addr,
+			 int addr_len, unsigned char addr_type)
 {
 	struct netdev_hw_addr *ha;
 
-	list_for_each_entry(ha, list, list) {
+	list_for_each_entry(ha, &list->list, list) {
 		if (!memcmp(ha->addr, addr, addr_len) &&
 		    (ha->type == addr_type || !addr_type)) {
 			if (--ha->refcount)
 				return 0;
 			list_del_rcu(&ha->list);
 			call_rcu(&ha->rcu_head, ha_rcu_free);
-			if (delta)
-				(*delta)--;
+			list->count--;
 			return 0;
 		}
 	}
 	return -ENOENT;
 }
 
-static int __hw_addr_add_multiple(struct list_head *to_list, int *to_delta,
-				  struct list_head *from_list, int addr_len,
+static int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
+				  struct netdev_hw_addr_list *from_list,
+				  int addr_len,
 				  unsigned char addr_type)
 {
 	int err;
 	struct netdev_hw_addr *ha, *ha2;
 	unsigned char type;
 
-	list_for_each_entry(ha, from_list, list) {
+	list_for_each_entry(ha, &from_list->list, list) {
 		type = addr_type ? addr_type : ha->type;
-		err = __hw_addr_add(to_list, to_delta, ha->addr,
-				    addr_len, type);
+		err = __hw_addr_add(to_list, ha->addr, addr_len, type);
 		if (err)
 			goto unroll;
 	}
 	return 0;
 
 unroll:
-	list_for_each_entry(ha2, from_list, list) {
+	list_for_each_entry(ha2, &from_list->list, list) {
 		if (ha2 == ha)
 			break;
 		type = addr_type ? addr_type : ha2->type;
-		__hw_addr_del(to_list, to_delta, ha2->addr,
-			      addr_len, type);
+		__hw_addr_del(to_list, ha2->addr, addr_len, type);
 	}
 	return err;
 }
 
-static void __hw_addr_del_multiple(struct list_head *to_list, int *to_delta,
-				   struct list_head *from_list, int addr_len,
+static void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
+				   struct netdev_hw_addr_list *from_list,
+				   int addr_len,
 				   unsigned char addr_type)
 {
 	struct netdev_hw_addr *ha;
 	unsigned char type;
 
-	list_for_each_entry(ha, from_list, list) {
+	list_for_each_entry(ha, &from_list->list, list) {
 		type = addr_type ? addr_type : ha->type;
-		__hw_addr_del(to_list, to_delta, ha->addr,
-			      addr_len, addr_type);
+		__hw_addr_del(to_list, ha->addr, addr_len, addr_type);
 	}
 }
 
-static int __hw_addr_sync(struct list_head *to_list, int *to_delta,
-			  struct list_head *from_list, int *from_delta,
+static int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
+			  struct netdev_hw_addr_list *from_list,
 			  int addr_len)
 {
 	int err = 0;
 	struct netdev_hw_addr *ha, *tmp;
 
-	list_for_each_entry_safe(ha, tmp, from_list, list) {
+	list_for_each_entry_safe(ha, tmp, &from_list->list, list) {
 		if (!ha->synced) {
-			err = __hw_addr_add(to_list, to_delta, ha->addr,
+			err = __hw_addr_add(to_list, ha->addr,
 					    addr_len, ha->type);
 			if (err)
 				break;
 			ha->synced = true;
 			ha->refcount++;
 		} else if (ha->refcount == 1) {
-			__hw_addr_del(to_list, to_delta, ha->addr,
-				      addr_len, ha->type);
-			__hw_addr_del(from_list, from_delta, ha->addr,
-				      addr_len, ha->type);
+			__hw_addr_del(to_list, ha->addr, addr_len, ha->type);
+			__hw_addr_del(from_list, ha->addr, addr_len, ha->type);
 		}
 	}
 	return err;
 }
 
-static void __hw_addr_unsync(struct list_head *to_list, int *to_delta,
-			     struct list_head *from_list, int *from_delta,
+static void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
+			     struct netdev_hw_addr_list *from_list,
 			     int addr_len)
 {
 	struct netdev_hw_addr *ha, *tmp;
 
-	list_for_each_entry_safe(ha, tmp, from_list, list) {
+	list_for_each_entry_safe(ha, tmp, &from_list->list, list) {
 		if (ha->synced) {
-			__hw_addr_del(to_list, to_delta, ha->addr,
+			__hw_addr_del(to_list, ha->addr,
 				      addr_len, ha->type);
 			ha->synced = false;
-			__hw_addr_del(from_list, from_delta, ha->addr,
+			__hw_addr_del(from_list, ha->addr,
 				      addr_len, ha->type);
 		}
 	}
 }
 
-
-static void __hw_addr_flush(struct list_head *list)
+static void __hw_addr_flush(struct netdev_hw_addr_list *list)
 {
 	struct netdev_hw_addr *ha, *tmp;
 
-	list_for_each_entry_safe(ha, tmp, list, list) {
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
 		list_del_rcu(&ha->list);
 		call_rcu(&ha->rcu_head, ha_rcu_free);
 	}
+	list->count = 0;
+}
+
+static void __hw_addr_init(struct netdev_hw_addr_list *list)
+{
+	INIT_LIST_HEAD(&list->list);
+	list->count = 0;
 }
 
 /* Device addresses handling functions */
@@ -3648,7 +3647,7 @@ static void dev_addr_flush(struct net_device *dev)
 {
 	/* rtnl_mutex must be held here */
 
-	__hw_addr_flush(&dev->dev_addr_list);
+	__hw_addr_flush(&dev->dev_addrs);
 	dev->dev_addr = NULL;
 }
 
@@ -3660,16 +3659,16 @@ static int dev_addr_init(struct net_device *dev)
 
 	/* rtnl_mutex must be held here */
 
-	INIT_LIST_HEAD(&dev->dev_addr_list);
+	__hw_addr_init(&dev->dev_addrs);
 	memset(addr, 0, sizeof(addr));
-	err = __hw_addr_add(&dev->dev_addr_list, NULL, addr, sizeof(addr),
+	err = __hw_addr_add(&dev->dev_addrs, addr, sizeof(addr),
 			    NETDEV_HW_ADDR_T_LAN);
 	if (!err) {
 		/*
 		 * Get the first (previously created) address from the list
 		 * and set dev_addr pointer to this location.
 		 */
-		ha = list_first_entry(&dev->dev_addr_list,
+		ha = list_first_entry(&dev->dev_addrs.list,
 				      struct netdev_hw_addr, list);
 		dev->dev_addr = ha->addr;
 	}
@@ -3694,8 +3693,7 @@ int dev_addr_add(struct net_device *dev, unsigned char *addr,
 
 	ASSERT_RTNL();
 
-	err = __hw_addr_add(&dev->dev_addr_list, NULL, addr, dev->addr_len,
-			    addr_type);
+	err = __hw_addr_add(&dev->dev_addrs, addr, dev->addr_len, addr_type);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	return err;
@@ -3725,11 +3723,12 @@ int dev_addr_del(struct net_device *dev, unsigned char *addr,
 	 * We can not remove the first address from the list because
 	 * dev->dev_addr points to that.
 	 */
-	ha = list_first_entry(&dev->dev_addr_list, struct netdev_hw_addr, list);
+	ha = list_first_entry(&dev->dev_addrs.list,
+			      struct netdev_hw_addr, list);
 	if (ha->addr == dev->dev_addr && ha->refcount == 1)
 		return -ENOENT;
 
-	err = __hw_addr_del(&dev->dev_addr_list, NULL, addr, dev->addr_len,
+	err = __hw_addr_del(&dev->dev_addrs, addr, dev->addr_len,
 			    addr_type);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
@@ -3757,8 +3756,7 @@ int dev_addr_add_multiple(struct net_device *to_dev,
 
 	if (from_dev->addr_len != to_dev->addr_len)
 		return -EINVAL;
-	err = __hw_addr_add_multiple(&to_dev->dev_addr_list, NULL,
-				     &from_dev->dev_addr_list,
+	err = __hw_addr_add_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
 				     to_dev->addr_len, addr_type);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
@@ -3784,15 +3782,14 @@ int dev_addr_del_multiple(struct net_device *to_dev,
 
 	if (from_dev->addr_len != to_dev->addr_len)
 		return -EINVAL;
-	__hw_addr_del_multiple(&to_dev->dev_addr_list, NULL,
-			       &from_dev->dev_addr_list,
+	__hw_addr_del_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
 			       to_dev->addr_len, addr_type);
 	call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
 	return 0;
 }
 EXPORT_SYMBOL(dev_addr_del_multiple);
 
-/* unicast and multicast addresses handling functions */
+/* multicast addresses handling functions */
 
 int __dev_addr_delete(struct dev_addr_list **list, int *count,
 		      void *addr, int alen, int glbl)
@@ -3868,8 +3865,8 @@ int dev_unicast_delete(struct net_device *dev, void *addr)
 
 	ASSERT_RTNL();
 
-	err = __hw_addr_del(&dev->uc_list, &dev->uc_count, addr,
-			    dev->addr_len, NETDEV_HW_ADDR_T_UNICAST);
+	err = __hw_addr_del(&dev->uc, addr, dev->addr_len,
+			    NETDEV_HW_ADDR_T_UNICAST);
 	if (!err)
 		__dev_set_rx_mode(dev);
 	return err;
@@ -3892,8 +3889,8 @@ int dev_unicast_add(struct net_device *dev, void *addr)
 
 	ASSERT_RTNL();
 
-	err = __hw_addr_add(&dev->uc_list, &dev->uc_count, addr,
-			    dev->addr_len, NETDEV_HW_ADDR_T_UNICAST);
+	err = __hw_addr_add(&dev->uc, addr, dev->addr_len,
+			    NETDEV_HW_ADDR_T_UNICAST);
 	if (!err)
 		__dev_set_rx_mode(dev);
 	return err;
@@ -3966,8 +3963,7 @@ int dev_unicast_sync(struct net_device *to, struct net_device *from)
 	if (to->addr_len != from->addr_len)
 		return -EINVAL;
 
-	err = __hw_addr_sync(&to->uc_list, &to->uc_count,
-			     &from->uc_list, &from->uc_count, to->addr_len);
+	err = __hw_addr_sync(&to->uc, &from->uc, to->addr_len);
 	if (!err)
 		__dev_set_rx_mode(to);
 	return err;
@@ -3990,8 +3986,7 @@ void dev_unicast_unsync(struct net_device *to, struct net_device *from)
 	if (to->addr_len != from->addr_len)
 		return;
 
-	__hw_addr_unsync(&to->uc_list, &to->uc_count,
-			 &from->uc_list, &from->uc_count, to->addr_len);
+	__hw_addr_unsync(&to->uc, &from->uc, to->addr_len);
 	__dev_set_rx_mode(to);
 }
 EXPORT_SYMBOL(dev_unicast_unsync);
@@ -4000,15 +3995,14 @@ static void dev_unicast_flush(struct net_device *dev)
 {
 	/* rtnl_mutex must be held here */
 
-	__hw_addr_flush(&dev->uc_list);
-	dev->uc_count = 0;
+	__hw_addr_flush(&dev->uc);
 }
 
 static void dev_unicast_init(struct net_device *dev)
 {
 	/* rtnl_mutex must be held here */
 
-	INIT_LIST_HEAD(&dev->uc_list);
+	__hw_addr_init(&dev->uc);
 }
 
 
