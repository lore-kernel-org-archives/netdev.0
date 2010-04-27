From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgb: Use pr_<level> and netdev_<level>
Date: Tue, 27 Apr 2010 03:50:58 -0700
Message-ID: <20100427104952.23637.6317.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:45843 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396Ab0D0KvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 06:51:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Convert DEBUGOUTx to pr_debug
Convert DEBUGFUNC to more commonly used ENTER
Convert mac address output to %pM
Use #define pr_fmt
Convert a few printks to pr_<level>
Improve ixgb_mc_addr_list_update: use a temporary for current mc address
Use etherdevice.h functions for mac address testing

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb.h       |    8 ++
 drivers/net/ixgb/ixgb_ee.c    |   14 ++--
 drivers/net/ixgb/ixgb_hw.c    |  147 +++++++++++++++++------------------------
 drivers/net/ixgb/ixgb_hw.h    |   12 ---
 drivers/net/ixgb/ixgb_main.c  |   33 ++++-----
 drivers/net/ixgb/ixgb_osdep.h |   16 +---
 drivers/net/ixgb/ixgb_param.c |   31 ++++-----
 7 files changed, 105 insertions(+), 156 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 92d2e71..521c0c7 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -78,9 +78,13 @@ struct ixgb_adapter;
 #define PFX "ixgb: "
 
 #ifdef _DEBUG_DRIVER_
-#define IXGB_DBG(args...) printk(KERN_DEBUG PFX args)
+#define IXGB_DBG(fmt, args...) printk(KERN_DEBUG PFX fmt, ##args)
 #else
-#define IXGB_DBG(args...)
+#define IXGB_DBG(fmt, args...)				\
+do {							\
+	if (0)						\
+		printk(KERN_DEBUG PFX fmt, ##args);	\
+} while (0)
 #endif
 
 /* TX/RX descriptor defines */
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 89ffa72..06303a3 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ixgb_hw.h"
 #include "ixgb_ee.h"
 /* Local prototypes */
@@ -467,11 +469,11 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 	u16 checksum = 0;
 	struct ixgb_ee_map_type *ee_map;
 
-	DEBUGFUNC("ixgb_get_eeprom_data");
+	ENTER();
 
 	ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	DEBUGOUT("ixgb_ee: Reading eeprom data\n");
+	pr_debug("Reading eeprom data\n");
 	for (i = 0; i < IXGB_EEPROM_SIZE ; i++) {
 		u16 ee_data;
 		ee_data = ixgb_read_eeprom(hw, i);
@@ -480,7 +482,7 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 	}
 
 	if (checksum != (u16) EEPROM_SUM) {
-		DEBUGOUT("ixgb_ee: Checksum invalid.\n");
+		pr_debug("Checksum invalid\n");
 		/* clear the init_ctrl_reg_1 to signify that the cache is
 		 * invalidated */
 		ee_map->init_ctrl_reg_1 = cpu_to_le16(EEPROM_ICW1_SIGNATURE_CLEAR);
@@ -489,7 +491,7 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 
 	if ((ee_map->init_ctrl_reg_1 & cpu_to_le16(EEPROM_ICW1_SIGNATURE_MASK))
 		 != cpu_to_le16(EEPROM_ICW1_SIGNATURE_VALID)) {
-		DEBUGOUT("ixgb_ee: Signature invalid.\n");
+		pr_debug("Signature invalid\n");
 		return(false);
 	}
 
@@ -555,13 +557,13 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 	int i;
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	DEBUGFUNC("ixgb_get_ee_mac_addr");
+	ENTER();
 
 	if (ixgb_check_and_get_eeprom_data(hw) == true) {
 		for (i = 0; i < IXGB_ETH_LENGTH_OF_ADDRESS; i++) {
 			mac_addr[i] = ee_map->mac_addr[i];
-			DEBUGOUT2("mac(%d) = %.2X\n", i, mac_addr[i]);
 		}
+		pr_debug("eeprom mac address = %pM\n", mac_addr);
 	}
 }
 
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index ff67a84..cd247b8 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -30,9 +30,13 @@
  * Shared functions for accessing and configuring the adapter
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ixgb_hw.h"
 #include "ixgb_ids.h"
 
+#include <linux/etherdevice.h>
+
 /*  Local function prototypes */
 
 static u32 ixgb_hash_mc_addr(struct ixgb_hw *hw, u8 * mc_addr);
@@ -120,13 +124,13 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	u32 ctrl_reg;
 	u32 icr_reg;
 
-	DEBUGFUNC("ixgb_adapter_stop");
+	ENTER();
 
 	/* If we are stopped or resetting exit gracefully and wait to be
 	 * started again before accessing the hardware.
 	 */
 	if (hw->adapter_stopped) {
-		DEBUGOUT("Exiting because the adapter is already stopped!!!\n");
+		pr_debug("Exiting because the adapter is already stopped!!!\n");
 		return false;
 	}
 
@@ -136,7 +140,7 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	hw->adapter_stopped = true;
 
 	/* Clear interrupt mask to stop board from generating interrupts */
-	DEBUGOUT("Masking off all interrupts\n");
+	pr_debug("Masking off all interrupts\n");
 	IXGB_WRITE_REG(hw, IMC, 0xFFFFFFFF);
 
 	/* Disable the Transmit and Receive units.  Then delay to allow
@@ -152,12 +156,12 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	 * the current PCI configuration.  The global reset bit is self-
 	 * clearing, and should clear within a microsecond.
 	 */
-	DEBUGOUT("Issuing a global reset to MAC\n");
+	pr_debug("Issuing a global reset to MAC\n");
 
 	ctrl_reg = ixgb_mac_reset(hw);
 
 	/* Clear interrupt mask to stop board from generating interrupts */
-	DEBUGOUT("Masking off all interrupts\n");
+	pr_debug("Masking off all interrupts\n");
 	IXGB_WRITE_REG(hw, IMC, 0xffffffff);
 
 	/* Clear any pending interrupt events. */
@@ -183,7 +187,7 @@ ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 	u16 vendor_name[5];
 	ixgb_xpak_vendor xpak_vendor;
 
-	DEBUGFUNC("ixgb_identify_xpak_vendor");
+	ENTER();
 
 	/* Read the first few bytes of the vendor string from the XPAK NVR
 	 * registers.  These are standard XENPAK/XPAK registers, so all XPAK
@@ -222,12 +226,12 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 	ixgb_phy_type phy_type;
 	ixgb_xpak_vendor xpak_vendor;
 
-	DEBUGFUNC("ixgb_identify_phy");
+	ENTER();
 
 	/* Infer the transceiver/phy type from the device id */
 	switch (hw->device_id) {
 	case IXGB_DEVICE_ID_82597EX:
-		DEBUGOUT("Identified TXN17401 optics\n");
+		pr_debug("Identified TXN17401 optics\n");
 		phy_type = ixgb_phy_type_txn17401;
 		break;
 
@@ -237,30 +241,30 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 		 * type of optics. */
 		xpak_vendor = ixgb_identify_xpak_vendor(hw);
 		if (xpak_vendor == ixgb_xpak_vendor_intel) {
-			DEBUGOUT("Identified TXN17201 optics\n");
+			pr_debug("Identified TXN17201 optics\n");
 			phy_type = ixgb_phy_type_txn17201;
 		} else {
-			DEBUGOUT("Identified G6005 optics\n");
+			pr_debug("Identified G6005 optics\n");
 			phy_type = ixgb_phy_type_g6005;
 		}
 		break;
 	case IXGB_DEVICE_ID_82597EX_LR:
-		DEBUGOUT("Identified G6104 optics\n");
+		pr_debug("Identified G6104 optics\n");
 		phy_type = ixgb_phy_type_g6104;
 		break;
 	case IXGB_DEVICE_ID_82597EX_CX4:
-		DEBUGOUT("Identified CX4\n");
+		pr_debug("Identified CX4\n");
 		xpak_vendor = ixgb_identify_xpak_vendor(hw);
 		if (xpak_vendor == ixgb_xpak_vendor_intel) {
-			DEBUGOUT("Identified TXN17201 optics\n");
+			pr_debug("Identified TXN17201 optics\n");
 			phy_type = ixgb_phy_type_txn17201;
 		} else {
-			DEBUGOUT("Identified G6005 optics\n");
+			pr_debug("Identified G6005 optics\n");
 			phy_type = ixgb_phy_type_g6005;
 		}
 		break;
 	default:
-		DEBUGOUT("Unknown physical layer module\n");
+		pr_debug("Unknown physical layer module\n");
 		phy_type = ixgb_phy_type_unknown;
 		break;
 	}
@@ -296,18 +300,18 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	u32 ctrl_reg;
 	bool status;
 
-	DEBUGFUNC("ixgb_init_hw");
+	ENTER();
 
 	/* Issue a global reset to the MAC.  This will reset the chip's
 	 * transmit, receive, DMA, and link units.  It will not effect
 	 * the current PCI configuration.  The global reset bit is self-
 	 * clearing, and should clear within a microsecond.
 	 */
-	DEBUGOUT("Issuing a global reset to MAC\n");
+	pr_debug("Issuing a global reset to MAC\n");
 
 	ctrl_reg = ixgb_mac_reset(hw);
 
-	DEBUGOUT("Issuing an EE reset to MAC\n");
+	pr_debug("Issuing an EE reset to MAC\n");
 #ifdef HP_ZX1
 	/* Workaround for 82597EX reset errata */
 	IXGB_WRITE_REG_IO(hw, CTRL1, IXGB_CTRL1_EE_RST);
@@ -335,7 +339,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	 * If it is not valid, we fail hardware init.
 	 */
 	if (!mac_addr_valid(hw->curr_mac_addr)) {
-		DEBUGOUT("MAC address invalid after ixgb_init_rx_addrs\n");
+		pr_debug("MAC address invalid after ixgb_init_rx_addrs\n");
 		return(false);
 	}
 
@@ -346,7 +350,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	ixgb_get_bus_info(hw);
 
 	/* Zero out the Multicast HASH table */
-	DEBUGOUT("Zeroing the MTA\n");
+	pr_debug("Zeroing the MTA\n");
 	for (i = 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
 
@@ -379,7 +383,7 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
 {
 	u32 i;
 
-	DEBUGFUNC("ixgb_init_rx_addrs");
+	ENTER();
 
 	/*
 	 * If the current mac address is valid, assume it is a software override
@@ -391,28 +395,19 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
 		/* Get the MAC address from the eeprom for later reference */
 		ixgb_get_ee_mac_addr(hw, hw->curr_mac_addr);
 
-		DEBUGOUT3(" Keeping Permanent MAC Addr =%.2X %.2X %.2X ",
-			  hw->curr_mac_addr[0],
-			  hw->curr_mac_addr[1], hw->curr_mac_addr[2]);
-		DEBUGOUT3("%.2X %.2X %.2X\n",
-			  hw->curr_mac_addr[3],
-			  hw->curr_mac_addr[4], hw->curr_mac_addr[5]);
+		pr_debug("Keeping Permanent MAC Addr = %pM\n",
+			 hw->curr_mac_addr);
 	} else {
 
 		/* Setup the receive address. */
-		DEBUGOUT("Overriding MAC Address in RAR[0]\n");
-		DEBUGOUT3(" New MAC Addr =%.2X %.2X %.2X ",
-			  hw->curr_mac_addr[0],
-			  hw->curr_mac_addr[1], hw->curr_mac_addr[2]);
-		DEBUGOUT3("%.2X %.2X %.2X\n",
-			  hw->curr_mac_addr[3],
-			  hw->curr_mac_addr[4], hw->curr_mac_addr[5]);
+		pr_debug("Overriding MAC Address in RAR[0]\n");
+		pr_debug("New MAC Addr = %pM\n", hw->curr_mac_addr);
 
 		ixgb_rar_set(hw, hw->curr_mac_addr, 0);
 	}
 
 	/* Zero out the other 15 receive addresses. */
-	DEBUGOUT("Clearing RAR[1-15]\n");
+	pr_debug("Clearing RAR[1-15]\n");
 	for (i = 1; i < IXGB_RAR_ENTRIES; i++) {
 		/* Write high reg first to disable the AV bit first */
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
@@ -444,64 +439,50 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 	u32 hash_value;
 	u32 i;
 	u32 rar_used_count = 1;		/* RAR[0] is used for our MAC address */
+	u8 *mca;
 
-	DEBUGFUNC("ixgb_mc_addr_list_update");
+	ENTER();
 
 	/* Set the new number of MC addresses that we are being requested to use. */
 	hw->num_mc_addrs = mc_addr_count;
 
 	/* Clear RAR[1-15] */
-	DEBUGOUT(" Clearing RAR[1-15]\n");
+	pr_debug("Clearing RAR[1-15]\n");
 	for (i = rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 	}
 
 	/* Clear the MTA */
-	DEBUGOUT(" Clearing MTA\n");
+	pr_debug("Clearing MTA\n");
 	for (i = 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
 
 	/* Add the new addresses */
+	mca = mc_addr_list;
 	for (i = 0; i < mc_addr_count; i++) {
-		DEBUGOUT(" Adding the multicast addresses:\n");
-		DEBUGOUT7(" MC Addr #%d =%.2X %.2X %.2X %.2X %.2X %.2X\n", i,
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       1],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       2],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       3],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       4],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       5]);
+		pr_debug("Adding the multicast addresses:\n");
+		pr_debug("MC Addr #%d = %pM\n", i, mca);
 
 		/* Place this multicast address in the RAR if there is room, *
 		 * else put it in the MTA
 		 */
 		if (rar_used_count < IXGB_RAR_ENTRIES) {
-			ixgb_rar_set(hw,
-				     mc_addr_list +
-				     (i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)),
-				     rar_used_count);
-			DEBUGOUT1("Added a multicast address to RAR[%d]\n", i);
+			ixgb_rar_set(hw, mca, rar_used_count);
+			pr_debug("Added a multicast address to RAR[%d]\n", i);
 			rar_used_count++;
 		} else {
-			hash_value = ixgb_hash_mc_addr(hw,
-						       mc_addr_list +
-						       (i *
-							(IXGB_ETH_LENGTH_OF_ADDRESS
-							 + pad)));
+			hash_value = ixgb_hash_mc_addr(hw, mca);
 
-			DEBUGOUT1(" Hash value = 0x%03X\n", hash_value);
+			pr_debug("Hash value = 0x%03X\n", hash_value);
 
 			ixgb_mta_set(hw, hash_value);
 		}
+
+		mca += IXGB_ETH_LENGTH_OF_ADDRESS + pad;
 	}
 
-	DEBUGOUT("MC Update Complete\n");
+	pr_debug("MC Update Complete\n");
 	return;
 }
 
@@ -520,7 +501,7 @@ ixgb_hash_mc_addr(struct ixgb_hw *hw,
 {
 	u32 hash_value = 0;
 
-	DEBUGFUNC("ixgb_hash_mc_addr");
+	ENTER();
 
 	/* The portion of the address that is used for the hash table is
 	 * determined by the mc_filter_type setting.
@@ -547,7 +528,7 @@ ixgb_hash_mc_addr(struct ixgb_hw *hw,
 		break;
 	default:
 		/* Invalid mc_filter_type, what should we do? */
-		DEBUGOUT("MC filter type param set incorrectly\n");
+		pr_debug("MC filter type param set incorrectly\n");
 		ASSERT(0);
 		break;
 	}
@@ -603,7 +584,7 @@ ixgb_rar_set(struct ixgb_hw *hw,
 {
 	u32 rar_low, rar_high;
 
-	DEBUGFUNC("ixgb_rar_set");
+	ENTER();
 
 	/* HW expects these in little endian so we reverse the byte order
 	 * from network order (big endian) to little endian
@@ -666,7 +647,7 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 	u32 pap_reg = 0;   /* by default, assume no pause time */
 	bool status = true;
 
-	DEBUGFUNC("ixgb_setup_fc");
+	ENTER();
 
 	/* Get the current control reg 0 settings */
 	ctrl_reg = IXGB_READ_REG(hw, CTRL0);
@@ -710,7 +691,7 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 		break;
 	default:
 		/* We should never get here.  The value should be 0-3. */
-		DEBUGOUT("Flow control param set incorrectly\n");
+		pr_debug("Flow control param set incorrectly\n");
 		ASSERT(0);
 		break;
 	}
@@ -940,7 +921,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
 	u32 status_reg;
 	u32 xpcss_reg;
 
-	DEBUGFUNC("ixgb_check_for_link");
+	ENTER();
 
 	xpcss_reg = IXGB_READ_REG(hw, XPCSS);
 	status_reg = IXGB_READ_REG(hw, STATUS);
@@ -950,7 +931,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
 		hw->link_up = true;
 	} else if (!(xpcss_reg & IXGB_XPCSS_ALIGN_STATUS) &&
 		   (status_reg & IXGB_STATUS_LU)) {
-		DEBUGOUT("XPCSS Not Aligned while Status:LU is set.\n");
+		pr_debug("XPCSS Not Aligned while Status:LU is set\n");
 		hw->link_up = ixgb_link_reset(hw);
 	} else {
 		/*
@@ -981,8 +962,7 @@ bool ixgb_check_for_bad_link(struct ixgb_hw *hw)
 		newRFC = IXGB_READ_REG(hw, RFC);
 		if ((hw->lastLFC + 250 < newLFC)
 		    || (hw->lastRFC + 250 < newRFC)) {
-			DEBUGOUT
-			    ("BAD LINK! too many LFC/RFC since last check\n");
+			pr_debug("BAD LINK! too many LFC/RFC since last check\n");
 			bad_link_returncode = true;
 		}
 		hw->lastLFC = newLFC;
@@ -1002,11 +982,11 @@ ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 {
 	volatile u32 temp_reg;
 
-	DEBUGFUNC("ixgb_clear_hw_cntrs");
+	ENTER();
 
 	/* if we are stopped or resetting exit gracefully */
 	if (hw->adapter_stopped) {
-		DEBUGOUT("Exiting because the adapter is stopped!!!\n");
+		pr_debug("Exiting because the adapter is stopped!!!\n");
 		return;
 	}
 
@@ -1156,26 +1136,21 @@ static bool
 mac_addr_valid(u8 *mac_addr)
 {
 	bool is_valid = true;
-	DEBUGFUNC("mac_addr_valid");
+	ENTER();
 
 	/* Make sure it is not a multicast address */
-	if (IS_MULTICAST(mac_addr)) {
-		DEBUGOUT("MAC address is multicast\n");
+	if (is_multicast_ether_addr(mac_addr)) {
+		pr_debug("MAC address is multicast\n");
 		is_valid = false;
 	}
 	/* Not a broadcast address */
-	else if (IS_BROADCAST(mac_addr)) {
-		DEBUGOUT("MAC address is broadcast\n");
+	else if (is_broadcast_ether_addr(mac_addr)) {
+		pr_debug("MAC address is broadcast\n");
 		is_valid = false;
 	}
 	/* Reject the zero address */
-	else if (mac_addr[0] == 0 &&
-			 mac_addr[1] == 0 &&
-			 mac_addr[2] == 0 &&
-			 mac_addr[3] == 0 &&
-			 mac_addr[4] == 0 &&
-			 mac_addr[5] == 0) {
-		DEBUGOUT("MAC address is all zeros\n");
+	else if (is_zero_ether_addr(mac_addr)) {
+		pr_debug("MAC address is all zeros\n");
 		is_valid = false;
 	}
 	return (is_valid);
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index af6ca3a..873d32b 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -636,18 +636,6 @@ struct ixgb_flash_buffer {
 	u8 filler3[0xAAAA];
 };
 
-/*
- * This is a little-endian specific check.
- */
-#define IS_MULTICAST(Address) \
-    (bool)(((u8 *)(Address))[0] & ((u8)0x01))
-
-/*
- * Check whether an address is broadcast.
- */
-#define IS_BROADCAST(Address)               \
-    ((((u8 *)(Address))[0] == ((u8)0xff)) && (((u8 *)(Address))[1] == ((u8)0xff)))
-
 /* Flow control parameters */
 struct ixgb_fc {
 	u32 high_water;	/* Flow Control High-water          */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 912dd1d..3cf7951 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ixgb.h"
 
 char ixgb_driver_name[] = "ixgb";
@@ -146,10 +148,8 @@ MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 static int __init
 ixgb_init_module(void)
 {
-	printk(KERN_INFO "%s - version %s\n",
-	       ixgb_driver_string, ixgb_driver_version);
-
-	printk(KERN_INFO "%s\n", ixgb_copyright);
+	pr_info("%s - version %s\n", ixgb_driver_string, ixgb_driver_version);
+	pr_info("%s\n", ixgb_copyright);
 
 	return pci_register_driver(&ixgb_driver);
 }
@@ -374,8 +374,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-			printk(KERN_ERR
-			 "ixgb: No usable DMA configuration, aborting\n");
+			pr_err("No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
 		}
 		pci_using_dac = 0;
@@ -1118,15 +1117,14 @@ ixgb_watchdog(unsigned long data)
 
 	if (adapter->hw.link_up) {
 		if (!netif_carrier_ok(netdev)) {
-			printk(KERN_INFO "ixgb: %s NIC Link is Up 10 Gbps "
-			       "Full Duplex, Flow Control: %s\n",
-			       netdev->name,
-			       (adapter->hw.fc.type == ixgb_fc_full) ?
-			        "RX/TX" :
-			        ((adapter->hw.fc.type == ixgb_fc_rx_pause) ?
-			         "RX" :
-			         ((adapter->hw.fc.type == ixgb_fc_tx_pause) ?
-			          "TX" : "None")));
+			netdev_info(netdev,
+				    "NIC Link is Up 10 Gbps Full Duplex, Flow Control: %s\n",
+				    (adapter->hw.fc.type == ixgb_fc_full) ?
+				    "RX/TX" :
+				    (adapter->hw.fc.type == ixgb_fc_rx_pause) ?
+				     "RX" :
+				    (adapter->hw.fc.type == ixgb_fc_tx_pause) ?
+				    "TX" : "None");
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
 			netif_carrier_on(netdev);
@@ -1135,8 +1133,7 @@ ixgb_watchdog(unsigned long data)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			printk(KERN_INFO "ixgb: %s NIC Link is Down\n",
-			       netdev->name);
+			netdev_info(netdev, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 		}
 	}
@@ -2322,7 +2319,7 @@ static void ixgb_io_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		if (ixgb_up(adapter)) {
-			printk ("ixgb: can't bring device back up after reset\n");
+			pr_err("can't bring device back up after reset\n");
 			return;
 		}
 	}
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index 371a6be..e361185 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -41,20 +41,8 @@
 
 #undef ASSERT
 #define ASSERT(x)	BUG_ON(!(x))
-#define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
-
-#ifdef DBG
-#define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
-#define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)
-#else
-#define DEBUGOUT(S)
-#define DEBUGOUT1(S, A...)
-#endif
-
-#define DEBUGFUNC(F) DEBUGOUT(F)
-#define DEBUGOUT2 DEBUGOUT1
-#define DEBUGOUT3 DEBUGOUT2
-#define DEBUGOUT7 DEBUGOUT3
+
+#define ENTER() pr_debug("%s\n", __func__);
 
 #define IXGB_WRITE_REG(a, reg, value) ( \
 	writel((value), ((a)->hw_addr + IXGB_##reg)))
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index af35e1d..88a08f0 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ixgb.h"
 
 /* This is the only thing that needs to be changed to adjust the
@@ -209,16 +211,16 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			printk(KERN_INFO "%s Enabled\n", opt->name);
+			pr_info("%s Enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			printk(KERN_INFO "%s Disabled\n", opt->name);
+			pr_info("%s Disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			printk(KERN_INFO "%s set to %i\n", opt->name, *value);
+			pr_info("%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
@@ -230,7 +232,7 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 			ent = &opt->arg.l.p[i];
 			if (*value == ent->i) {
 				if (ent->str[0] != '\0')
-					printk(KERN_INFO "%s\n", ent->str);
+					pr_info("%s\n", ent->str);
 				return 0;
 			}
 		}
@@ -240,8 +242,7 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 		BUG();
 	}
 
-	printk(KERN_INFO "Invalid %s specified (%i) %s\n",
-		   opt->name, *value, opt->err);
+	pr_info("Invalid %s specified (%i) %s\n", opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -261,9 +262,8 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (bd >= IXGB_MAX_NIC) {
-		printk(KERN_NOTICE
-			   "Warning: no configuration for board #%i\n", bd);
-		printk(KERN_NOTICE "Using defaults for all values\n");
+		pr_notice("Warning: no configuration for board #%i\n", bd);
+		pr_notice("Using defaults for all values\n");
 	}
 
 	{ /* Transmit Descriptor Count */
@@ -363,8 +363,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			adapter->hw.fc.high_water = opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk(KERN_INFO
-				"Ignoring RxFCHighThresh when no RxFC\n");
+			pr_info("Ignoring RxFCHighThresh when no RxFC\n");
 	}
 	{ /* Receive Flow Control Low Threshold */
 		const struct ixgb_option opt = {
@@ -383,8 +382,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			adapter->hw.fc.low_water = opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk(KERN_INFO
-				"Ignoring RxFCLowThresh when no RxFC\n");
+			pr_info("Ignoring RxFCLowThresh when no RxFC\n");
 	}
 	{ /* Flow Control Pause Time Request*/
 		const struct ixgb_option opt = {
@@ -404,17 +402,14 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			adapter->hw.fc.pause_time = opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk(KERN_INFO
-				"Ignoring FCReqTimeout when no RxFC\n");
+			pr_info("Ignoring FCReqTimeout when no RxFC\n");
 	}
 	/* high low and spacing check for rx flow control thresholds */
 	if (adapter->hw.fc.type & ixgb_fc_tx_pause) {
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */
-			printk(KERN_INFO
-				"RxFCHighThresh must be >= (RxFCLowThresh + 8), "
-				"Using Defaults\n");
+			pr_info("RxFCHighThresh must be >= (RxFCLowThresh + 8), Using Defaults\n");
 			adapter->hw.fc.high_water = DEFAULT_FCRTH;
 			adapter->hw.fc.low_water  = DEFAULT_FCRTL;
 		}

