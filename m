From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: use helpers to access uc list V2
Date: Mon, 25 Jan 2010 22:05:45 +0100
Message-ID: <20100125210543.GB6746@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850Ab0AYVFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 16:05:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces three macros to work with uc list from net drivers.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d83512d..a7b6b12 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -48,7 +48,6 @@
 #include <linux/cache.h>
 #include <linux/firmware.h>
 #include <linux/log2.h>
-#include <linux/list.h>
 
 #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
 #define BCM_CNIC 1
@@ -3579,14 +3578,14 @@ bnx2_set_rx_mode(struct net_device *dev)
 		sort_mode |= BNX2_RPM_SORT_USER0_MC_HSH_EN;
 	}
 
-	if (dev->uc.count > BNX2_MAX_UNICAST_ADDRESSES) {
+	if (netdev_uc_count(dev) > BNX2_MAX_UNICAST_ADDRESSES) {
 		rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
 		sort_mode |= BNX2_RPM_SORT_USER0_PROM_EN |
 			     BNX2_RPM_SORT_USER0_PROM_VLAN;
 	} else if (!(dev->flags & IFF_PROMISC)) {
 		/* Add all entries into to the match filter list */
 		i = 0;
-		list_for_each_entry(ha, &dev->uc.list, list) {
+		netdev_for_each_uc_addr(ha, dev) {
 			bnx2_set_mac_addr(bp, ha->addr,
 					  i + BNX2_START_UNICAST_ADDRESS_INDEX);
 			sort_mode |= (1 <<
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 87f575c..2ce88c5 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2139,7 +2139,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			rctl |= E1000_RCTL_VFE;
 	}
 
-	if (netdev->uc.count > rar_entries - 1) {
+	if (netdev_uc_count(netdev) > rar_entries - 1) {
 		rctl |= E1000_RCTL_UPE;
 	} else if (!(netdev->flags & IFF_PROMISC)) {
 		rctl &= ~E1000_RCTL_UPE;
@@ -2162,7 +2162,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	 */
 	i = 1;
 	if (use_uc)
-		list_for_each_entry(ha, &netdev->uc.list, list) {
+		netdev_for_each_uc_addr(ha, netdev) {
 			if (i == rar_entries)
 				break;
 			e1000_rar_set(hw, ha->addr, i++);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d967949..01cc294 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2905,12 +2905,13 @@ static int igb_write_uc_addr_list(struct net_device *netdev)
 	int count = 0;
 
 	/* return ENOMEM indicating insufficient memory for addresses */
-	if (netdev->uc.count > rar_entries)
+	if (netdev_uc_count(netdev) > rar_entries)
 		return -ENOMEM;
 
-	if (netdev->uc.count && rar_entries) {
+	if (!netdev_uc_empty(netdev) && rar_entries) {
 		struct netdev_hw_addr *ha;
-		list_for_each_entry(ha, &netdev->uc.list, list) {
+
+		netdev_for_each_uc_addr(ha, netdev) {
 			if (!rar_entries)
 				break;
 			igb_rar_set_qsel(adapter, ha->addr,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 276c2aa..eb49020 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -28,7 +28,6 @@
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
-#include <linux/list.h>
 #include <linux/netdevice.h>
 
 #include "ixgbe.h"
@@ -1347,7 +1346,7 @@ static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
 /**
  *  ixgbe_update_uc_addr_list_generic - Updates MAC list of secondary addresses
  *  @hw: pointer to hardware structure
- *  @uc_list: the list of new addresses
+ *  @netdev: pointer to net device structure
  *
  *  The given list replaces any existing list.  Clears the secondary addrs from
  *  receive address registers.  Uses unused receive address registers for the
@@ -1357,7 +1356,7 @@ static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
  *  manually putting the device into promiscuous mode.
  **/
 s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
-				      struct list_head *uc_list)
+				      struct net_device *netdev)
 {
 	u32 i;
 	u32 old_promisc_setting = hw->addr_ctrl.overflow_promisc;
@@ -1381,7 +1380,7 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 	}
 
 	/* Add the new addresses */
-	list_for_each_entry(ha, uc_list, list) {
+	netdev_for_each_uc_addr(ha, netdev) {
 		hw_dbg(hw, " Adding the secondary addresses:\n");
 		ixgbe_add_uc_addr(hw, ha->addr, 0);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index dfff0ff..13606d4 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -60,7 +60,7 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw, u8 *mc_addr_list,
                                       u32 mc_addr_count,
                                       ixgbe_mc_addr_itr func);
 s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
-				      struct list_head *uc_list);
+				      struct net_device *netdev);
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ee41d33..439645d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2568,7 +2568,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
 	/* reprogram secondary unicast list */
-	hw->mac.ops.update_uc_addr_list(hw, &netdev->uc.list);
+	hw->mac.ops.update_uc_addr_list(hw, netdev);
 
 	/* reprogram multicast list */
 	addr_count = netdev->mc_count;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index b4caa70..0db67c1 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -30,7 +30,7 @@
 
 #include <linux/types.h>
 #include <linux/mdio.h>
-#include <linux/list.h>
+#include <linux/netdevice.h>
 
 /* Vendor ID */
 #define IXGBE_INTEL_VENDOR_ID   0x8086
@@ -2405,7 +2405,7 @@ struct ixgbe_mac_operations {
 	s32 (*set_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*clear_vmdq)(struct ixgbe_hw *, u32, u32);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
-	s32 (*update_uc_addr_list)(struct ixgbe_hw *, struct list_head *);
+	s32 (*update_uc_addr_list)(struct ixgbe_hw *, struct net_device *);
 	s32 (*update_mc_addr_list)(struct ixgbe_hw *, u8 *, u32,
 	                           ixgbe_mc_addr_itr);
 	s32 (*enable_mc)(struct ixgbe_hw *);
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index af67af5..e24072a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -55,7 +55,6 @@
 #include <linux/types.h>
 #include <linux/inet_lro.h>
 #include <asm/system.h>
-#include <linux/list.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.4";
@@ -1697,7 +1696,7 @@ static u32 uc_addr_filter_mask(struct net_device *dev)
 		return 0;
 
 	nibbles = 1 << (dev->dev_addr[5] & 0x0f);
-	list_for_each_entry(ha, &dev->uc.list, list) {
+	netdev_for_each_uc_addr(ha, dev) {
 		if (memcmp(dev->dev_addr, ha->addr, 5))
 			return 0;
 		if ((dev->dev_addr[5] ^ ha->addr[5]) & 0xf0)
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0e260cf..af9a864 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6372,7 +6372,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 0))
 		np->flags |= NIU_FLAGS_MCAST;
 
-	alt_cnt = dev->uc.count;
+	alt_cnt = netdev_uc_count(dev);
 	if (alt_cnt > niu_num_alt_addr(np)) {
 		alt_cnt = 0;
 		np->flags |= NIU_FLAGS_PROMISC;
@@ -6381,7 +6381,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	if (alt_cnt) {
 		int index = 0;
 
-		list_for_each_entry(ha, &dev->uc.list, list) {
+		netdev_for_each_uc_addr(ha, dev) {
 			err = niu_set_alt_mac(np, index, ha->addr);
 			if (err)
 				printk(KERN_WARNING PFX "%s: Error %d "
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 928eac0..d812e9c 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -83,7 +83,7 @@ static void dwmac1000_set_filter(struct net_device *dev)
 	unsigned int value = 0;
 
 	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
-	    __func__, dev->mc_count, dev->uc.count);
+	    __func__, dev->mc_count, netdev_uc_count(dev));
 
 	if (dev->flags & IFF_PROMISC)
 		value = GMAC_FRAME_FILTER_PR;
@@ -117,7 +117,7 @@ static void dwmac1000_set_filter(struct net_device *dev)
 	}
 
 	/* Handle multiple unicast addresses (perfect filtering)*/
-	if (dev->uc.count > GMAC_MAX_UNICAST_ADDRESSES)
+	if (netdev_uc_count(dev) > GMAC_MAX_UNICAST_ADDRESSES)
 		/* Switch to promiscuous mode is more than 16 addrs
 		   are required */
 		value |= GMAC_FRAME_FILTER_PR;
@@ -125,9 +125,9 @@ static void dwmac1000_set_filter(struct net_device *dev)
 		int reg = 1;
 		struct netdev_hw_addr *ha;
 
-			list_for_each_entry(ha, &dev->uc.list, list) {
-				dwmac1000_set_umac_addr(ioaddr, ha->addr, reg);
-				reg++;
+		netdev_for_each_uc_addr(ha, dev) {
+			dwmac1000_set_umac_addr(ioaddr, ha->addr, reg);
+			reg++;
 		}
 	}
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c708ecc..088332a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -675,6 +675,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	struct virtio_net_ctrl_mac *mac_data;
 	struct dev_addr_list *addr;
 	struct netdev_hw_addr *ha;
+	int uc_count;
 	void *buf;
 	int i;
 
@@ -701,8 +702,9 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 		dev_warn(&dev->dev, "Failed to %sable allmulti mode.\n",
 			 allmulti ? "en" : "dis");
 
+	uc_count = netdev_uc_count(dev);
 	/* MAC filter - use one buffer for both lists */
-	mac_data = buf = kzalloc(((dev->uc.count + dev->mc_count) * ETH_ALEN) +
+	mac_data = buf = kzalloc(((uc_count + dev->mc_count) * ETH_ALEN) +
 				 (2 * sizeof(mac_data->entries)), GFP_ATOMIC);
 	if (!buf) {
 		dev_warn(&dev->dev, "No memory for MAC address buffer\n");
@@ -712,16 +714,16 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	sg_init_table(sg, 2);
 
 	/* Store the unicast list and count in the front of the buffer */
-	mac_data->entries = dev->uc.count;
+	mac_data->entries = uc_count;
 	i = 0;
-	list_for_each_entry(ha, &dev->uc.list, list)
+	netdev_for_each_uc_addr(ha, dev)
 		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
 
 	sg_set_buf(&sg[0], mac_data,
-		   sizeof(mac_data->entries) + (dev->uc.count * ETH_ALEN));
+		   sizeof(mac_data->entries) + (uc_count * ETH_ALEN));
 
 	/* multicast list and count fill the end */
-	mac_data = (void *)&mac_data->macs[dev->uc.count][0];
+	mac_data = (void *)&mac_data->macs[uc_count][0];
 
 	mac_data->entries = dev->mc_count;
 	addr = dev->mc_list;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index c3258b0..51fde6f 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -622,7 +622,7 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 	for (dm = dev->mc_list; dm; dm = dm->next)
 		qeth_l2_add_mc(card, dm->da_addr, 0);
 
-	list_for_each_entry(ha, &dev->uc.list, list)
+	netdev_for_each_uc_addr(ha, dev)
 		qeth_l2_add_mc(card, ha->addr, 1);
 
 	spin_unlock_bh(&card->mclock);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b5fb51d..93a32a5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -263,6 +263,11 @@ struct netdev_hw_addr_list {
 	int			count;
 };
 
+#define netdev_uc_count(dev) ((dev)->uc.count)
+#define netdev_uc_empty(dev) ((dev)->uc.count == 0)
+#define netdev_for_each_uc_addr(ha, dev) \
+	list_for_each_entry(ha, &dev->uc.list, list)
+
 struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
diff --git a/net/core/dev.c b/net/core/dev.c
index 4fad9db..2cba5c5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3665,10 +3665,10 @@ void __dev_set_rx_mode(struct net_device *dev)
 		/* Unicast addresses changes may only happen under the rtnl,
 		 * therefore calling __dev_set_promiscuity here is safe.
 		 */
-		if (dev->uc.count > 0 && !dev->uc_promisc) {
+		if (!netdev_uc_empty(dev) && !dev->uc_promisc) {
 			__dev_set_promiscuity(dev, 1);
 			dev->uc_promisc = 1;
-		} else if (dev->uc.count == 0 && dev->uc_promisc) {
+		} else if (netdev_uc_empty(dev) && dev->uc_promisc) {
 			__dev_set_promiscuity(dev, -1);
 			dev->uc_promisc = 0;
 		}
