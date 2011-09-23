From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/02] ixgb: eliminate checkstack warnings
Date: Fri, 23 Sep 2011 05:11:29 -0700
Message-ID: <1316779890-32436-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28387 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605Ab1IWMLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 08:11:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Really trivial fix, use kmalloc/kfree instead of stack space.
use static const instead of const to further reduce stack usage.

V2: reflect changes suggested by Joe Perches

before:
[jbrandeb@jbrandeb-mobl2 linux-2.6]$ make checkstack|grep '\[ixgb\]'
0x00000fc1 ixgb_set_multi [ixgb]:                       768
0x00001031 ixgb_set_multi [ixgb]:                       768
0x000010f2 ixgb_set_multi [ixgb]:                       768
0x061c ixgb_check_options [ixgb]:                       448
0x09c3 ixgb_check_options [ixgb]:                       448
0x0000649e ixgb_set_ringparam [ixgb]:                   192
0x0000130d ixgb_xmit_frame [ixgb]:                      184
0x000019e0 ixgb_xmit_frame [ixgb]:                      184
0x00002267 ixgb_clean [ixgb]:                           152
0x00002673 ixgb_clean [ixgb]:                           152

after:
0x000064ee ixgb_set_ringparam [ixgb]:                   192
0x0000135d ixgb_xmit_frame [ixgb]:                      184
0x00001a30 ixgb_xmit_frame [ixgb]:                      184
0x000022b7 ixgb_clean [ixgb]:                           152
0x000026c3 ixgb_clean [ixgb]:                           152

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_ee.c    |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_ee.h    |    4 +---
 drivers/net/ethernet/intel/ixgb/ixgb_hw.c    |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_hw.h    |    4 +---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c  |   21 ++++++++++++++-------
 drivers/net/ethernet/intel/ixgb/ixgb_osdep.h |    1 +
 drivers/net/ethernet/intel/ixgb/ixgb_param.c |   18 +++++++++---------
 7 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ee.c b/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
index 38b362b..2ed925f 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
@@ -559,7 +559,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 	ENTER();
 
 	if (ixgb_check_and_get_eeprom_data(hw) == true) {
-		for (i = 0; i < IXGB_ETH_LENGTH_OF_ADDRESS; i++) {
+		for (i = 0; i < ETH_ALEN; i++) {
 			mac_addr[i] = ee_map->mac_addr[i];
 		}
 		pr_debug("eeprom mac address = %pM\n", mac_addr);
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ee.h b/drivers/net/ethernet/intel/ixgb/ixgb_ee.h
index 7ea1265..5680f64 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ee.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ee.h
@@ -31,8 +31,6 @@
 
 #define IXGB_EEPROM_SIZE    64	/* Size in words */
 
-#define IXGB_ETH_LENGTH_OF_ADDRESS   6
-
 /* EEPROM Commands */
 #define EEPROM_READ_OPCODE  0x6	/* EEPROM read opcode */
 #define EEPROM_WRITE_OPCODE 0x5	/* EEPROM write opcode */
@@ -75,7 +73,7 @@
 
 /* EEPROM structure */
 struct ixgb_ee_map_type {
-	u8 mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];
+	u8 mac_addr[ETH_ALEN];
 	__le16 compatibility;
 	__le16 reserved1[4];
 	__le32 pba_number;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
index 3d61a9e..99b69ad 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
@@ -478,7 +478,7 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 			ixgb_mta_set(hw, hash_value);
 		}
 
-		mca += IXGB_ETH_LENGTH_OF_ADDRESS + pad;
+		mca += ETH_ALEN + pad;
 	}
 
 	pr_debug("MC Update Complete\n");
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_hw.h b/drivers/net/ethernet/intel/ixgb/ixgb_hw.h
index 873d32b..2a99a35 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_hw.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_hw.h
@@ -97,8 +97,6 @@ typedef enum {
 	ixgb_bus_width_64
 } ixgb_bus_width;
 
-#define IXGB_ETH_LENGTH_OF_ADDRESS   6
-
 #define IXGB_EEPROM_SIZE    64	/* Size in words */
 
 #define SPEED_10000  10000
@@ -674,7 +672,7 @@ struct ixgb_hw {
 	u32 max_frame_size;	/* Maximum frame size supported     */
 	u32 mc_filter_type;	/* Multicast filter hash type       */
 	u32 num_mc_addrs;	/* Number of current Multicast addrs */
-	u8 curr_mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];	/* Individual address currently programmed in MAC */
+	u8 curr_mac_addr[ETH_ALEN];	/* Individual address currently programmed in MAC */
 	u32 num_tx_desc;	/* Number of Transmit descriptors   */
 	u32 num_rx_desc;	/* Number of Receive descriptors    */
 	u32 rx_buffer_size;	/* Size of Receive buffer           */
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index b8fb163..ca3ab4a 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1093,7 +1093,6 @@ ixgb_set_multi(struct net_device *netdev)
 	struct ixgb_hw *hw = &adapter->hw;
 	struct netdev_hw_addr *ha;
 	u32 rctl;
-	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
 
@@ -1120,19 +1119,27 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
-		u8 mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
-			    IXGB_ETH_LENGTH_OF_ADDRESS];
+		u8 *mta = kmalloc(IXGB_MAX_NUM_MULTICAST_ADDRESSES *
+			      ETH_ALEN, GFP_ATOMIC);
+		u8 *addr;
+		if (!mta) {
+			pr_err("allocation of multicast memory failed\n");
+			goto alloc_failed;
+		}
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
-		i = 0;
-		netdev_for_each_mc_addr(ha, netdev)
-			memcpy(&mta[i++ * IXGB_ETH_LENGTH_OF_ADDRESS],
-			       ha->addr, IXGB_ETH_LENGTH_OF_ADDRESS);
+		addr = mta;
+		netdev_for_each_mc_addr(ha, netdev) {
+			memcpy(addr, ha->addr, ETH_ALEN);
+			addr += ETH_ALEN;
+		}
 
 		ixgb_mc_addr_list_update(hw, mta, netdev_mc_count(netdev), 0);
+		kfree(mta);
 	}
 
+alloc_failed:
 	if (netdev->features & NETIF_F_HW_VLAN_RX)
 		ixgb_vlan_strip_enable(adapter);
 	else
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_osdep.h b/drivers/net/ethernet/intel/ixgb/ixgb_osdep.h
index e361185..8fc9051 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_osdep.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_osdep.h
@@ -38,6 +38,7 @@
 #include <asm/io.h>
 #include <linux/interrupt.h>
 #include <linux/sched.h>
+#include <linux/if_ether.h>
 
 #undef ASSERT
 #define ASSERT(x)	BUG_ON(!(x))
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_param.c b/drivers/net/ethernet/intel/ixgb/ixgb_param.c
index dd7fbeb..07d83ab 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_param.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_param.c
@@ -267,7 +267,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 	}
 
 	{ /* Transmit Descriptor Count */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Descriptors",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TXD),
@@ -286,7 +286,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		tx_ring->count = ALIGN(tx_ring->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Descriptor Count */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Descriptors",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RXD),
@@ -305,7 +305,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		rx_ring->count = ALIGN(rx_ring->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Checksum Offload Enable */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Receive Checksum Offload",
 			.err  = "defaulting to Enabled",
@@ -348,7 +348,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		}
 	}
 	{ /* Receive Flow Control High Threshold */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control High Threshold",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTH),
@@ -367,7 +367,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			pr_info("Ignoring RxFCHighThresh when no RxFC\n");
 	}
 	{ /* Receive Flow Control Low Threshold */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control Low Threshold",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_FCRTL),
@@ -386,7 +386,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			pr_info("Ignoring RxFCLowThresh when no RxFC\n");
 	}
 	{ /* Flow Control Pause Time Request*/
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Flow Control Pause Time Request",
 			.err  = "using default of "__MODULE_STRING(DEFAULT_FCPAUSE),
@@ -416,7 +416,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		}
 	}
 	{ /* Receive Interrupt Delay */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
@@ -433,7 +433,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		}
 	}
 	{ /* Transmit Interrupt Delay */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
@@ -451,7 +451,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 	}
 
 	{ /* Transmit Interrupt Delay Enable */
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Tx Interrupt Delay Enable",
 			.err  = "defaulting to Enabled",
-- 
1.7.6.2
