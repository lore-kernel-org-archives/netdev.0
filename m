From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next] net: convert unicast addr list
Date: Sat, 23 May 2009 11:22:17 +0200
Message-ID: <20090523092215.GA3386@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53480 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509AbZEWJWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 05:22:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next] net: convert unicast addr list

This patch converts unicast address list to standard list_head using previously
introduced struct netdev_hw_addr. It also relaxes the locking. Original spinlock
(still used for multicast addresses) is not needed and is no longer used for a
protection of this list. All reading and writing takes place under rtnl (with no
changes).

I also removed a possibility to specify the length of the address while adding
or deleting unicast address. It's always dev->addr_len.

The convertion touched especially e1000 and ixgbe codes when the change is not
so trivial.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bnx2.c               |   13 +--
 drivers/net/e1000/e1000_main.c   |   24 +++--
 drivers/net/ixgbe/ixgbe_common.c |   14 ++--
 drivers/net/ixgbe/ixgbe_common.h |    4 +-
 drivers/net/ixgbe/ixgbe_main.c   |    6 +-
 drivers/net/ixgbe/ixgbe_type.h   |    4 +-
 drivers/net/macvlan.c            |   11 +-
 drivers/net/mv643xx_eth.c        |   11 +-
 drivers/net/niu.c                |    7 +-
 drivers/net/virtio_net.c         |    7 +-
 drivers/s390/net/qeth_l2_main.c  |    6 +-
 drivers/scsi/fcoe/fcoe.c         |   16 ++--
 include/linux/netdevice.h        |   18 ++--
 net/8021q/vlan.c                 |    4 +-
 net/8021q/vlan_dev.c             |   10 +-
 net/core/dev.c                   |  195 +++++++++++++++++++++++++++-----------
 net/dsa/slave.c                  |   10 +-
 net/packet/af_packet.c           |    4 +-
 18 files changed, 227 insertions(+), 137 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c37acc1..8bc5d18 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -48,6 +48,7 @@
 #include <linux/cache.h>
 #include <linux/firmware.h>
 #include <linux/log2.h>
+#include <linux/list.h>
 
 #include "bnx2.h"
 #include "bnx2_fw.h"
@@ -3310,7 +3311,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 	u32 rx_mode, sort_mode;
-	struct dev_addr_list *uc_ptr;
+	struct netdev_hw_addr *ha;
 	int i;
 
 	if (!netif_running(dev))
@@ -3369,21 +3370,19 @@ bnx2_set_rx_mode(struct net_device *dev)
 		sort_mode |= BNX2_RPM_SORT_USER0_MC_HSH_EN;
 	}
 
-	uc_ptr = NULL;
 	if (dev->uc_count > BNX2_MAX_UNICAST_ADDRESSES) {
 		rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
 		sort_mode |= BNX2_RPM_SORT_USER0_PROM_EN |
 			     BNX2_RPM_SORT_USER0_PROM_VLAN;
 	} else if (!(dev->flags & IFF_PROMISC)) {
-		uc_ptr = dev->uc_list;
-
 		/* Add all entries into to the match filter list */
-		for (i = 0; i < dev->uc_count; i++) {
-			bnx2_set_mac_addr(bp, uc_ptr->da_addr,
+		i = 0;
+		list_for_each_entry(ha, &dev->uc_list, list) {
+			bnx2_set_mac_addr(bp, ha->addr,
 					  i + BNX2_START_UNICAST_ADDRESS_INDEX);
 			sort_mode |= (1 <<
 				      (i + BNX2_START_UNICAST_ADDRESS_INDEX));
-			uc_ptr = uc_ptr->next;
+			i++;
 		}
 
 	}
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9a32d0c..f6346c8 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2330,7 +2330,8 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_addr_list *uc_ptr;
+	struct netdev_hw_addr *ha;
+	bool use_uc = false;
 	struct dev_addr_list *mc_ptr;
 	u32 rctl;
 	u32 hash_value;
@@ -2369,12 +2370,11 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			rctl |= E1000_RCTL_VFE;
 	}
 
-	uc_ptr = NULL;
 	if (netdev->uc_count > rar_entries - 1) {
 		rctl |= E1000_RCTL_UPE;
 	} else if (!(netdev->flags & IFF_PROMISC)) {
 		rctl &= ~E1000_RCTL_UPE;
-		uc_ptr = netdev->uc_list;
+		use_uc = true;
 	}
 
 	ew32(RCTL, rctl);
@@ -2392,13 +2392,20 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	 * if there are not 14 addresses, go ahead and clear the filters
 	 * -- with 82571 controllers only 0-13 entries are filled here
 	 */
+	i = 1;
+	if (use_uc)
+		list_for_each_entry(ha, &netdev->uc_list, list) {
+			if (i == rar_entries)
+				break;
+			e1000_rar_set(hw, ha->addr, i++);
+		}
+
+	WARN_ON(i == rar_entries);
+
 	mc_ptr = netdev->mc_list;
 
-	for (i = 1; i < rar_entries; i++) {
-		if (uc_ptr) {
-			e1000_rar_set(hw, uc_ptr->da_addr, i);
-			uc_ptr = uc_ptr->next;
-		} else if (mc_ptr) {
+	for (; i < rar_entries; i++) {
+		if (mc_ptr) {
 			e1000_rar_set(hw, mc_ptr->da_addr, i);
 			mc_ptr = mc_ptr->next;
 		} else {
@@ -2408,7 +2415,6 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			E1000_WRITE_FLUSH();
 		}
 	}
-	WARN_ON(uc_ptr != NULL);
 
 	/* load any remaining addresses into the hash table */
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 0cc3c47..6f79409 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -28,6 +28,8 @@
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -1356,15 +1358,14 @@ static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
  *  Drivers using secondary unicast addresses must set user_set_promisc when
  *  manually putting the device into promiscuous mode.
  **/
-s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
-                              u32 addr_count, ixgbe_mc_addr_itr next)
+s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
+				      struct list_head *uc_list)
 {
-	u8 *addr;
 	u32 i;
 	u32 old_promisc_setting = hw->addr_ctrl.overflow_promisc;
 	u32 uc_addr_in_use;
 	u32 fctrl;
-	u32 vmdq;
+	struct netdev_hw_addr *ha;
 
 	/*
 	 * Clear accounting of old secondary address list,
@@ -1382,10 +1383,9 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
 	}
 
 	/* Add the new addresses */
-	for (i = 0; i < addr_count; i++) {
+	list_for_each_entry(ha, uc_list, list) {
 		hw_dbg(hw, " Adding the secondary addresses:\n");
-		addr = next(hw, &addr_list, &vmdq);
-		ixgbe_add_uc_addr(hw, addr, vmdq);
+		ixgbe_add_uc_addr(hw, ha->addr, 0);
 	}
 
 	if (hw->addr_ctrl.overflow_promisc) {
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index dd26089..b2a4b2c 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -59,8 +59,8 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw);
 s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
                                       u32 mc_addr_count,
                                       ixgbe_mc_addr_itr func);
-s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw, u8 *addr_list,
-                                      u32 addr_count, ixgbe_mc_addr_itr func);
+s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
+				      struct list_head *uc_list);
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e52798c..4908c66 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2181,11 +2181,7 @@ static void ixgbe_set_rx_mode(struct net_device *netdev)
 	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
 	/* reprogram secondary unicast list */
-	addr_count = netdev->uc_count;
-	if (addr_count)
-		addr_list = netdev->uc_list->dmi_addr;
-	hw->mac.ops.update_uc_addr_list(hw, addr_list, addr_count,
-	                                  ixgbe_addr_list_itr);
+	hw->mac.ops.update_uc_addr_list(hw, &netdev->uc_list);
 
 	/* reprogram multicast list */
 	addr_count = netdev->mc_count;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index ba3ed0f..12225d7 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -30,6 +30,7 @@
 
 #include <linux/types.h>
 #include <linux/mdio.h>
+#include <linux/list.h>
 
 /* Vendor ID */
 #define IXGBE_INTEL_VENDOR_ID   0x8086
@@ -2224,8 +2225,7 @@ struct ixgbe_mac_operations {
 	s32 (*set_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*clear_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
-	s32 (*update_uc_addr_list)(struct ixgbe_hw *, u8 *, u32,
-	                           ixgbe_mc_addr_itr);
+	s32 (*update_uc_addr_list)(struct ixgbe_hw *, struct list_head *);
 	s32 (*update_mc_addr_list)(struct ixgbe_hw *, u8 *, u32,
 	                           ixgbe_mc_addr_itr);
 	s32 (*enable_mc)(struct ixgbe_hw *);
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d5334b4..021d994 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -232,7 +232,7 @@ static int macvlan_open(struct net_device *dev)
 	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
 		goto out;
 
-	err = dev_unicast_add(lowerdev, dev->dev_addr, ETH_ALEN);
+	err = dev_unicast_add(lowerdev, dev->dev_addr);
 	if (err < 0)
 		goto out;
 	if (dev->flags & IFF_ALLMULTI) {
@@ -244,7 +244,7 @@ static int macvlan_open(struct net_device *dev)
 	return 0;
 
 del_unicast:
-	dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+	dev_unicast_delete(lowerdev, dev->dev_addr);
 out:
 	return err;
 }
@@ -258,7 +258,7 @@ static int macvlan_stop(struct net_device *dev)
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, -1);
 
-	dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+	dev_unicast_delete(lowerdev, dev->dev_addr);
 
 	macvlan_hash_del(vlan);
 	return 0;
@@ -282,10 +282,11 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 		if (macvlan_addr_busy(vlan->port, addr->sa_data))
 			return -EBUSY;
 
-		if ((err = dev_unicast_add(lowerdev, addr->sa_data, ETH_ALEN)))
+		err = dev_unicast_add(lowerdev, addr->sa_data);
+		if (err)
 			return err;
 
-		dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+		dev_unicast_delete(lowerdev, dev->dev_addr);
 
 		macvlan_hash_change_addr(vlan, addr->sa_data);
 	}
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1361ddc..b4e18a5 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -55,6 +55,7 @@
 #include <linux/types.h>
 #include <linux/inet_lro.h>
 #include <asm/system.h>
+#include <linux/list.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.4";
@@ -1721,20 +1722,20 @@ static void uc_addr_set(struct mv643xx_eth_private *mp, unsigned char *addr)
 
 static u32 uc_addr_filter_mask(struct net_device *dev)
 {
-	struct dev_addr_list *uc_ptr;
+	struct netdev_hw_addr *ha;
 	u32 nibbles;
 
 	if (dev->flags & IFF_PROMISC)
 		return 0;
 
 	nibbles = 1 << (dev->dev_addr[5] & 0x0f);
-	for (uc_ptr = dev->uc_list; uc_ptr != NULL; uc_ptr = uc_ptr->next) {
-		if (memcmp(dev->dev_addr, uc_ptr->da_addr, 5))
+	list_for_each_entry(ha, &dev->uc_list, list) {
+		if (memcmp(dev->dev_addr, ha->addr, 5))
 			return 0;
-		if ((dev->dev_addr[5] ^ uc_ptr->da_addr[5]) & 0xf0)
+		if ((dev->dev_addr[5] ^ ha->addr[5]) & 0xf0)
 			return 0;
 
-		nibbles |= 1 << (uc_ptr->da_addr[5] & 0x0f);
+		nibbles |= 1 << (ha->addr[5] & 0x0f);
 	}
 
 	return nibbles;
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..34e468b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -22,6 +22,7 @@
 #include <linux/log2.h>
 #include <linux/jiffies.h>
 #include <linux/crc32.h>
+#include <linux/list.h>
 
 #include <linux/io.h>
 
@@ -6330,6 +6331,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	struct niu *np = netdev_priv(dev);
 	int i, alt_cnt, err;
 	struct dev_addr_list *addr;
+	struct netdev_hw_addr *ha;
 	unsigned long flags;
 	u16 hash[16] = { 0, };
 
@@ -6351,9 +6353,8 @@ static void niu_set_rx_mode(struct net_device *dev)
 	if (alt_cnt) {
 		int index = 0;
 
-		for (addr = dev->uc_list; addr; addr = addr->next) {
-			err = niu_set_alt_mac(np, index,
-					      addr->da_addr);
+		list_for_each_entry(ha, &dev->uc_list, list) {
+			err = niu_set_alt_mac(np, index, ha->addr);
 			if (err)
 				printk(KERN_WARNING PFX "%s: Error %d "
 				       "adding alt mac %d\n",
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 6cc5bcd..0c9ca67 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -680,6 +680,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	u8 promisc, allmulti;
 	struct virtio_net_ctrl_mac *mac_data;
 	struct dev_addr_list *addr;
+	struct netdev_hw_addr *ha;
 	void *buf;
 	int i;
 
@@ -718,9 +719,9 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 
 	/* Store the unicast list and count in the front of the buffer */
 	mac_data->entries = dev->uc_count;
-	addr = dev->uc_list;
-	for (i = 0; i < dev->uc_count; i++, addr = addr->next)
-		memcpy(&mac_data->macs[i][0], addr->da_addr, ETH_ALEN);
+	i = 0;
+	list_for_each_entry(ha, &dev->uc_list, list)
+		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
 
 	sg_set_buf(&sg[0], mac_data,
 		   sizeof(mac_data->entries) + (dev->uc_count * ETH_ALEN));
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 9ca6bab..ecd3d06 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -19,6 +19,7 @@
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
 #include <linux/ip.h>
+#include <linux/list.h>
 
 #include "qeth_core.h"
 
@@ -640,6 +641,7 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
 	struct dev_addr_list *dm;
+	struct netdev_hw_addr *ha;
 
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		return ;
@@ -653,8 +655,8 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 	for (dm = dev->mc_list; dm; dm = dm->next)
 		qeth_l2_add_mc(card, dm->da_addr, 0);
 
-	for (dm = dev->uc_list; dm; dm = dm->next)
-		qeth_l2_add_mc(card, dm->da_addr, 1);
+	list_for_each_entry(ha, &dev->uc_list, list)
+		qeth_l2_add_mc(card, ha->addr, 1);
 
 	spin_unlock_bh(&card->mclock);
 	if (!qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index ce33f10..f791348 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -182,8 +182,8 @@ static void fcoe_update_src_mac(struct fcoe_ctlr *fip, u8 *old, u8 *new)
 	fc = fcoe_from_ctlr(fip);
 	rtnl_lock();
 	if (!is_zero_ether_addr(old))
-		dev_unicast_delete(fc->real_dev, old, ETH_ALEN);
-	dev_unicast_add(fc->real_dev, new, ETH_ALEN);
+		dev_unicast_delete(fc->real_dev, old);
+	dev_unicast_add(fc->real_dev, new);
 	rtnl_unlock();
 }
 
@@ -233,13 +233,11 @@ void fcoe_netdev_cleanup(struct fcoe_softc *fc)
 	/* Delete secondary MAC addresses */
 	rtnl_lock();
 	memcpy(flogi_maddr, (u8[6]) FC_FCOE_FLOGI_MAC, ETH_ALEN);
-	dev_unicast_delete(fc->real_dev, flogi_maddr, ETH_ALEN);
+	dev_unicast_delete(fc->real_dev, flogi_maddr);
 	if (!is_zero_ether_addr(fc->ctlr.data_src_addr))
-		dev_unicast_delete(fc->real_dev,
-				   fc->ctlr.data_src_addr, ETH_ALEN);
+		dev_unicast_delete(fc->real_dev, fc->ctlr.data_src_addr);
 	if (fc->ctlr.spma)
-		dev_unicast_delete(fc->real_dev,
-				   fc->ctlr.ctl_src_addr, ETH_ALEN);
+		dev_unicast_delete(fc->real_dev, fc->ctlr.ctl_src_addr);
 	dev_mc_delete(fc->real_dev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
 	rtnl_unlock();
 }
@@ -347,9 +345,9 @@ static int fcoe_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	 */
 	rtnl_lock();
 	memcpy(flogi_maddr, (u8[6]) FC_FCOE_FLOGI_MAC, ETH_ALEN);
-	dev_unicast_add(fc->real_dev, flogi_maddr, ETH_ALEN);
+	dev_unicast_add(fc->real_dev, flogi_maddr);
 	if (fc->ctlr.spma)
-		dev_unicast_add(fc->real_dev, fc->ctlr.ctl_src_addr, ETH_ALEN);
+		dev_unicast_add(fc->real_dev, fc->ctlr.ctl_src_addr);
 	dev_mc_add(fc->real_dev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
 	rtnl_unlock();
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8574e7..9d96cd6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -215,9 +215,12 @@ struct netdev_hw_addr {
 	struct list_head	list;
 	unsigned char		addr[MAX_ADDR_LEN];
 	unsigned char		type;
-#define NETDEV_HW_ADDR_T_LAN	1
-#define NETDEV_HW_ADDR_T_SAN	2
-#define NETDEV_HW_ADDR_T_SLAVE	3
+#define NETDEV_HW_ADDR_T_LAN		1
+#define NETDEV_HW_ADDR_T_SAN		2
+#define NETDEV_HW_ADDR_T_SLAVE		3
+#define NETDEV_HW_ADDR_T_UNICAST	4
+	int			refcount;
+	bool			synced;
 	struct rcu_head		rcu_head;
 };
 
@@ -773,10 +776,11 @@ struct net_device
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */
 
-	spinlock_t		addr_list_lock;
-	struct dev_addr_list	*uc_list;	/* Secondary unicast mac addresses */
+	struct list_head	uc_list;	/* Secondary unicast mac
+						   addresses */
 	int			uc_count;	/* Number of installed ucasts	*/
 	int			uc_promisc;
+	spinlock_t		addr_list_lock;
 	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
 	int			mc_count;	/* Number of installed mcasts	*/
 	unsigned int		promiscuity;
@@ -1854,8 +1858,8 @@ extern int dev_addr_del_multiple(struct net_device *to_dev,
 /* Functions used for secondary unicast and multicast support */
 extern void		dev_set_rx_mode(struct net_device *dev);
 extern void		__dev_set_rx_mode(struct net_device *dev);
-extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
-extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
+extern int		dev_unicast_delete(struct net_device *dev, void *addr);
+extern int		dev_unicast_add(struct net_device *dev, void *addr);
 extern int		dev_unicast_sync(struct net_device *to, struct net_device *from);
 extern void		dev_unicast_unsync(struct net_device *to, struct net_device *from);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d1e1054..714e1c3 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -378,13 +378,13 @@ static void vlan_sync_address(struct net_device *dev,
 	 * the new address */
 	if (compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
 	    !compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
-		dev_unicast_delete(dev, vlandev->dev_addr, ETH_ALEN);
+		dev_unicast_delete(dev, vlandev->dev_addr);
 
 	/* vlan address was equal to the old address and is different from
 	 * the new address */
 	if (!compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
 	    compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
-		dev_unicast_add(dev, vlandev->dev_addr, ETH_ALEN);
+		dev_unicast_add(dev, vlandev->dev_addr);
 
 	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ff7572a..c94354f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -441,7 +441,7 @@ static int vlan_dev_open(struct net_device *dev)
 		return -ENETDOWN;
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr)) {
-		err = dev_unicast_add(real_dev, dev->dev_addr, ETH_ALEN);
+		err = dev_unicast_add(real_dev, dev->dev_addr);
 		if (err < 0)
 			goto out;
 	}
@@ -470,7 +470,7 @@ clear_allmulti:
 		dev_set_allmulti(real_dev, -1);
 del_unicast:
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
-		dev_unicast_delete(real_dev, dev->dev_addr, ETH_ALEN);
+		dev_unicast_delete(real_dev, dev->dev_addr);
 out:
 	netif_carrier_off(dev);
 	return err;
@@ -492,7 +492,7 @@ static int vlan_dev_stop(struct net_device *dev)
 		dev_set_promiscuity(real_dev, -1);
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
-		dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
+		dev_unicast_delete(real_dev, dev->dev_addr);
 
 	netif_carrier_off(dev);
 	return 0;
@@ -511,13 +511,13 @@ static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 		goto out;
 
 	if (compare_ether_addr(addr->sa_data, real_dev->dev_addr)) {
-		err = dev_unicast_add(real_dev, addr->sa_data, ETH_ALEN);
+		err = dev_unicast_add(real_dev, addr->sa_data);
 		if (err < 0)
 			return err;
 	}
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
-		dev_unicast_delete(real_dev, dev->dev_addr, ETH_ALEN);
+		dev_unicast_delete(real_dev, dev->dev_addr);
 
 out:
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3942266..ba0e160 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3447,8 +3447,9 @@ void dev_set_rx_mode(struct net_device *dev)
 
 /* hw addresses list handling functions */
 
-static int __hw_addr_add(struct list_head *list, unsigned char *addr,
-			 int addr_len, unsigned char addr_type)
+static int __hw_addr_add(struct list_head *list, int *delta,
+			 unsigned char *addr, int addr_len,
+			 unsigned char addr_type)
 {
 	struct netdev_hw_addr *ha;
 	int alloc_size;
@@ -3456,6 +3457,15 @@ static int __hw_addr_add(struct list_head *list, unsigned char *addr,
 	if (addr_len > MAX_ADDR_LEN)
 		return -EINVAL;
 
+	list_for_each_entry(ha, list, list) {
+		if (!memcmp(ha->addr, addr, addr_len) &&
+		    ha->type == addr_type) {
+			ha->refcount++;
+			return 0;
+		}
+	}
+
+
 	alloc_size = sizeof(*ha);
 	if (alloc_size < L1_CACHE_BYTES)
 		alloc_size = L1_CACHE_BYTES;
@@ -3464,7 +3474,11 @@ static int __hw_addr_add(struct list_head *list, unsigned char *addr,
 		return -ENOMEM;
 	memcpy(ha->addr, addr, addr_len);
 	ha->type = addr_type;
+	ha->refcount = 1;
+	ha->synced = false;
 	list_add_tail_rcu(&ha->list, list);
+	if (delta)
+		(*delta)++;
 	return 0;
 }
 
@@ -3476,29 +3490,30 @@ static void ha_rcu_free(struct rcu_head *head)
 	kfree(ha);
 }
 
-static int __hw_addr_del_ii(struct list_head *list, unsigned char *addr,
-			    int addr_len, unsigned char addr_type,
-			    int ignore_index)
+static int __hw_addr_del(struct list_head *list, int *delta,
+			 unsigned char *addr, int addr_len,
+			 unsigned char addr_type)
 {
 	struct netdev_hw_addr *ha;
-	int i = 0;
 
 	list_for_each_entry(ha, list, list) {
-		if (i++ != ignore_index &&
-		    !memcmp(ha->addr, addr, addr_len) &&
+		if (!memcmp(ha->addr, addr, addr_len) &&
 		    (ha->type == addr_type || !addr_type)) {
+			if (--ha->refcount)
+				return 0;
 			list_del_rcu(&ha->list);
 			call_rcu(&ha->rcu_head, ha_rcu_free);
+			if (delta)
+				(*delta)--;
 			return 0;
 		}
 	}
 	return -ENOENT;
 }
 
-static int __hw_addr_add_multiple_ii(struct list_head *to_list,
-				     struct list_head *from_list,
-				     int addr_len, unsigned char addr_type,
-				     int ignore_index)
+static int __hw_addr_add_multiple(struct list_head *to_list, int *to_delta,
+				  struct list_head *from_list, int addr_len,
+				  unsigned char addr_type)
 {
 	int err;
 	struct netdev_hw_addr *ha, *ha2;
@@ -3506,7 +3521,8 @@ static int __hw_addr_add_multiple_ii(struct list_head *to_list,
 
 	list_for_each_entry(ha, from_list, list) {
 		type = addr_type ? addr_type : ha->type;
-		err = __hw_addr_add(to_list, ha->addr, addr_len, type);
+		err = __hw_addr_add(to_list, to_delta, ha->addr,
+				    addr_len, type);
 		if (err)
 			goto unroll;
 	}
@@ -3517,27 +3533,69 @@ unroll:
 		if (ha2 == ha)
 			break;
 		type = addr_type ? addr_type : ha2->type;
-		__hw_addr_del_ii(to_list, ha2->addr, addr_len, type,
-				 ignore_index);
+		__hw_addr_del(to_list, to_delta, ha2->addr,
+			      addr_len, type);
 	}
 	return err;
 }
 
-static void __hw_addr_del_multiple_ii(struct list_head *to_list,
-				      struct list_head *from_list,
-				      int addr_len, unsigned char addr_type,
-				      int ignore_index)
+static void __hw_addr_del_multiple(struct list_head *to_list, int *to_delta,
+				   struct list_head *from_list, int addr_len,
+				   unsigned char addr_type)
 {
 	struct netdev_hw_addr *ha;
 	unsigned char type;
 
 	list_for_each_entry(ha, from_list, list) {
 		type = addr_type ? addr_type : ha->type;
-		__hw_addr_del_ii(to_list, ha->addr, addr_len, addr_type,
-				 ignore_index);
+		__hw_addr_del(to_list, to_delta, ha->addr,
+			      addr_len, addr_type);
+	}
+}
+
+static int __hw_addr_sync(struct list_head *to_list, int *to_delta,
+			  struct list_head *from_list, int *from_delta,
+			  int addr_len)
+{
+	int err = 0;
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, from_list, list) {
+		if (!ha->synced) {
+			err = __hw_addr_add(to_list, to_delta, ha->addr,
+					    addr_len, ha->type);
+			if (err)
+				break;
+			ha->synced = true;
+			ha->refcount++;
+		} else if (ha->refcount == 1) {
+			__hw_addr_del(to_list, to_delta, ha->addr,
+				      addr_len, ha->type);
+			__hw_addr_del(from_list, from_delta, ha->addr,
+				      addr_len, ha->type);
+		}
 	}
+	return err;
 }
 
+static void __hw_addr_unsync(struct list_head *to_list, int *to_delta,
+			     struct list_head *from_list, int *from_delta,
+			     int addr_len)
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, from_list, list) {
+		if (ha->synced) {
+			__hw_addr_del(to_list, to_delta, ha->addr,
+				      addr_len, ha->type);
+			ha->synced = false;
+			__hw_addr_del(from_list, from_delta, ha->addr,
+				      addr_len, ha->type);
+		}
+	}
+}
+
+
 static void __hw_addr_flush(struct list_head *list)
 {
 	struct netdev_hw_addr *ha, *tmp;
@@ -3568,7 +3626,7 @@ static int dev_addr_init(struct net_device *dev)
 
 	INIT_LIST_HEAD(&dev->dev_addr_list);
 	memset(addr, 0, sizeof(*addr));
-	err = __hw_addr_add(&dev->dev_addr_list, addr, sizeof(*addr),
+	err = __hw_addr_add(&dev->dev_addr_list, NULL, addr, sizeof(*addr),
 			    NETDEV_HW_ADDR_T_LAN);
 	if (!err) {
 		/*
@@ -3600,7 +3658,7 @@ int dev_addr_add(struct net_device *dev, unsigned char *addr,
 
 	ASSERT_RTNL();
 
-	err = __hw_addr_add(&dev->dev_addr_list, addr, dev->addr_len,
+	err = __hw_addr_add(&dev->dev_addr_list, NULL, addr, dev->addr_len,
 			    addr_type);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
@@ -3623,11 +3681,20 @@ int dev_addr_del(struct net_device *dev, unsigned char *addr,
 		 unsigned char addr_type)
 {
 	int err;
+	struct netdev_hw_addr *ha;
 
 	ASSERT_RTNL();
 
-	err = __hw_addr_del_ii(&dev->dev_addr_list, addr, dev->addr_len,
-			       addr_type, 0);
+	/*
+	 * We can not remove the first address from the list because
+	 * dev->dev_addr points to that.
+	 */
+	ha = list_first_entry(&dev->dev_addr_list, struct netdev_hw_addr, list);
+	if (ha->addr == dev->dev_addr && ha->refcount == 1)
+		return -ENOENT;
+
+	err = __hw_addr_del(&dev->dev_addr_list, NULL, addr, dev->addr_len,
+			    addr_type);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	return err;
@@ -3654,9 +3721,9 @@ int dev_addr_add_multiple(struct net_device *to_dev,
 
 	if (from_dev->addr_len != to_dev->addr_len)
 		return -EINVAL;
-	err = __hw_addr_add_multiple_ii(&to_dev->dev_addr_list,
-					&from_dev->dev_addr_list,
-					to_dev->addr_len, addr_type, 0);
+	err = __hw_addr_add_multiple(&to_dev->dev_addr_list, NULL,
+				     &from_dev->dev_addr_list,
+				     to_dev->addr_len, addr_type);
 	if (!err)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
 	return err;
@@ -3681,9 +3748,9 @@ int dev_addr_del_multiple(struct net_device *to_dev,
 
 	if (from_dev->addr_len != to_dev->addr_len)
 		return -EINVAL;
-	__hw_addr_del_multiple_ii(&to_dev->dev_addr_list,
-				  &from_dev->dev_addr_list,
-				  to_dev->addr_len, addr_type, 0);
+	__hw_addr_del_multiple(&to_dev->dev_addr_list, NULL,
+			       &from_dev->dev_addr_list,
+			       to_dev->addr_len, addr_type);
 	call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
 	return 0;
 }
@@ -3753,24 +3820,22 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
  *	dev_unicast_delete	- Release secondary unicast address.
  *	@dev: device
  *	@addr: address to delete
- *	@alen: length of @addr
  *
  *	Release reference to a secondary unicast address and remove it
  *	from the device if the reference count drops to zero.
  *
  * 	The caller must hold the rtnl_mutex.
  */
-int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
+int dev_unicast_delete(struct net_device *dev, void *addr)
 {
 	int err;
 
 	ASSERT_RTNL();
 
-	netif_addr_lock_bh(dev);
-	err = __dev_addr_delete(&dev->uc_list, &dev->uc_count, addr, alen, 0);
+	err = __hw_addr_del(&dev->uc_list, &dev->uc_count, addr,
+			    dev->addr_len, NETDEV_HW_ADDR_T_UNICAST);
 	if (!err)
 		__dev_set_rx_mode(dev);
-	netif_addr_unlock_bh(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_delete);
@@ -3779,24 +3844,22 @@ EXPORT_SYMBOL(dev_unicast_delete);
  *	dev_unicast_add		- add a secondary unicast address
  *	@dev: device
  *	@addr: address to add
- *	@alen: length of @addr
  *
  *	Add a secondary unicast address to the device or increase
  *	the reference count if it already exists.
  *
  *	The caller must hold the rtnl_mutex.
  */
-int dev_unicast_add(struct net_device *dev, void *addr, int alen)
+int dev_unicast_add(struct net_device *dev, void *addr)
 {
 	int err;
 
 	ASSERT_RTNL();
 
-	netif_addr_lock_bh(dev);
-	err = __dev_addr_add(&dev->uc_list, &dev->uc_count, addr, alen, 0);
+	err = __hw_addr_add(&dev->uc_list, &dev->uc_count, addr,
+			    dev->addr_len, NETDEV_HW_ADDR_T_UNICAST);
 	if (!err)
 		__dev_set_rx_mode(dev);
-	netif_addr_unlock_bh(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_add);
@@ -3853,8 +3916,7 @@ void __dev_addr_unsync(struct dev_addr_list **to, int *to_count,
  *	@from: source device
  *
  *	Add newly added addresses to the destination device and release
- *	addresses that have no users left. The source device must be
- *	locked by netif_tx_lock_bh.
+ *	addresses that have no users left.
  *
  *	This function is intended to be called from the dev->set_rx_mode
  *	function of layered software devices.
@@ -3863,12 +3925,15 @@ int dev_unicast_sync(struct net_device *to, struct net_device *from)
 {
 	int err = 0;
 
-	netif_addr_lock_bh(to);
-	err = __dev_addr_sync(&to->uc_list, &to->uc_count,
-			      &from->uc_list, &from->uc_count);
+	ASSERT_RTNL();
+
+	if (to->addr_len != from->addr_len)
+		return -EINVAL;
+
+	err = __hw_addr_sync(&to->uc_list, &to->uc_count,
+			     &from->uc_list, &from->uc_count, to->addr_len);
 	if (!err)
 		__dev_set_rx_mode(to);
-	netif_addr_unlock_bh(to);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_sync);
@@ -3884,18 +3949,33 @@ EXPORT_SYMBOL(dev_unicast_sync);
  */
 void dev_unicast_unsync(struct net_device *to, struct net_device *from)
 {
-	netif_addr_lock_bh(from);
-	netif_addr_lock(to);
+	ASSERT_RTNL();
 
-	__dev_addr_unsync(&to->uc_list, &to->uc_count,
-			  &from->uc_list, &from->uc_count);
-	__dev_set_rx_mode(to);
+	if (to->addr_len != from->addr_len)
+		return;
 
-	netif_addr_unlock(to);
-	netif_addr_unlock_bh(from);
+	__hw_addr_unsync(&to->uc_list, &to->uc_count,
+			 &from->uc_list, &from->uc_count, to->addr_len);
+	__dev_set_rx_mode(to);
 }
 EXPORT_SYMBOL(dev_unicast_unsync);
 
+static void dev_unicast_flush(struct net_device *dev)
+{
+	/* rtnl_mutex must be held here */
+
+	__hw_addr_flush(&dev->uc_list);
+	dev->uc_count = 0;
+}
+
+static void dev_unicast_init(struct net_device *dev)
+{
+	/* rtnl_mutex must be held here */
+
+	INIT_LIST_HEAD(&dev->uc_list);
+}
+
+
 static void __dev_addr_discard(struct dev_addr_list **list)
 {
 	struct dev_addr_list *tmp;
@@ -3914,9 +3994,6 @@ static void dev_addr_discard(struct net_device *dev)
 {
 	netif_addr_lock_bh(dev);
 
-	__dev_addr_discard(&dev->uc_list);
-	dev->uc_count = 0;
-
 	__dev_addr_discard(&dev->mc_list);
 	dev->mc_count = 0;
 
@@ -4509,6 +4586,7 @@ static void rollback_registered(struct net_device *dev)
 	/*
 	 *	Flush the unicast and multicast chains
 	 */
+	dev_unicast_flush(dev);
 	dev_addr_discard(dev);
 
 	if (dev->netdev_ops->ndo_uninit)
@@ -5045,6 +5123,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	if (dev_addr_init(dev))
 		goto free_tx;
 
+	dev_unicast_init(dev);
+
 	dev_net_set(dev, &init_net);
 
 	dev->_tx = tx;
@@ -5248,6 +5328,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	/*
 	 *	Flush the unicast and multicast chains
 	 */
+	dev_unicast_flush(dev);
 	dev_addr_discard(dev);
 
 	netdev_unregister_kobject(dev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ed13118..2175e6d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -67,7 +67,7 @@ static int dsa_slave_open(struct net_device *dev)
 		return -ENETDOWN;
 
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr)) {
-		err = dev_unicast_add(master, dev->dev_addr, ETH_ALEN);
+		err = dev_unicast_add(master, dev->dev_addr);
 		if (err < 0)
 			goto out;
 	}
@@ -90,7 +90,7 @@ clear_allmulti:
 		dev_set_allmulti(master, -1);
 del_unicast:
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
-		dev_unicast_delete(master, dev->dev_addr, ETH_ALEN);
+		dev_unicast_delete(master, dev->dev_addr);
 out:
 	return err;
 }
@@ -108,7 +108,7 @@ static int dsa_slave_close(struct net_device *dev)
 		dev_set_promiscuity(master, -1);
 
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
-		dev_unicast_delete(master, dev->dev_addr, ETH_ALEN);
+		dev_unicast_delete(master, dev->dev_addr);
 
 	return 0;
 }
@@ -147,13 +147,13 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 		goto out;
 
 	if (compare_ether_addr(addr->sa_data, master->dev_addr)) {
-		err = dev_unicast_add(master, addr->sa_data, ETH_ALEN);
+		err = dev_unicast_add(master, addr->sa_data);
 		if (err < 0)
 			return err;
 	}
 
 	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
-		dev_unicast_delete(master, dev->dev_addr, ETH_ALEN);
+		dev_unicast_delete(master, dev->dev_addr);
 
 out:
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c7c5d52..6da9f38 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1582,9 +1582,9 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 		break;
 	case PACKET_MR_UNICAST:
 		if (what > 0)
-			return dev_unicast_add(dev, i->addr, i->alen);
+			return dev_unicast_add(dev, i->addr);
 		else
-			return dev_unicast_delete(dev, i->addr, i->alen);
+			return dev_unicast_delete(dev, i->addr);
 		break;
 	default:;
 	}
