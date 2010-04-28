From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000: Use netdev_<level>,
	pr_<level> and dev_<level>
Date: Tue, 27 Apr 2010 17:02:58 -0700
Message-ID: <20100428000252.27254.91773.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Joe Perches <joe@perches.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:34456 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753371Ab0D1ADS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 20:03:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch is an alternative to similar patch provided by Joe Perches.

Substitute DPRINTK macro for e_<level> that uses netdev_<level> and dev_<level>
similar to e1000e.
- Convert printk to pr_<level> where applicable.
- Use common #define pr_fmt for the driver.
- Use dev_<level> for displaying text in parts of the driver where the interface
  name is not assigned (like e1000_param.c).
- Better align test with the new macros.

CC: Joe Perches <joe@perches.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h         |   37 ++--
 drivers/net/e1000/e1000_ethtool.c |   31 ++-
 drivers/net/e1000/e1000_hw.c      |  356 ++++++++++++++++++-------------------
 drivers/net/e1000/e1000_hw.h      |    1 
 drivers/net/e1000/e1000_main.c    |  239 ++++++++++++-------------
 drivers/net/e1000/e1000_osdep.h   |   14 -
 drivers/net/e1000/e1000_param.c   |   94 ++++------
 7 files changed, 367 insertions(+), 405 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 2f29c21..40b62b4 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -81,23 +81,6 @@ struct e1000_adapter;
 
 #include "e1000_hw.h"
 
-#ifdef DBG
-#define E1000_DBG(args...) printk(KERN_DEBUG "e1000: " args)
-#else
-#define E1000_DBG(args...)
-#endif
-
-#define E1000_ERR(args...) printk(KERN_ERR "e1000: " args)
-
-#define PFX "e1000: "
-
-#define DPRINTK(nlevel, klevel, fmt, args...)				\
-do {									\
-	if (NETIF_MSG_##nlevel & adapter->msg_enable)			\
-		printk(KERN_##klevel PFX "%s: %s: " fmt,		\
-		       adapter->netdev->name, __func__, ##args);	\
-} while (0)
-
 #define E1000_MAX_INTR 10
 
 /* TX/RX descriptor defines */
@@ -335,6 +318,25 @@ enum e1000_state_t {
 	__E1000_DOWN
 };
 
+#undef pr_fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+extern struct net_device *e1000_get_hw_dev(struct e1000_hw *hw);
+#define e_dbg(format, arg...) \
+	netdev_dbg(e1000_get_hw_dev(hw), format, ## arg)
+#define e_err(format, arg...) \
+	netdev_err(adapter->netdev, format, ## arg)
+#define e_info(format, arg...) \
+	netdev_info(adapter->netdev, format, ## arg)
+#define e_warn(format, arg...) \
+	netdev_warn(adapter->netdev, format, ## arg)
+#define e_notice(format, arg...) \
+	netdev_notice(adapter->netdev, format, ## arg)
+#define e_dev_info(format, arg...) \
+	dev_info(&adapter->pdev->dev, format, ## arg)
+#define e_dev_warn(format, arg...) \
+	dev_warn(&adapter->pdev->dev, format, ## arg)
+
 extern char e1000_driver_name[];
 extern const char e1000_driver_version[];
 
@@ -352,5 +354,6 @@ extern bool e1000_has_link(struct e1000_adapter *adapter);
 extern void e1000_power_up_phy(struct e1000_adapter *);
 extern void e1000_set_ethtool_ops(struct net_device *netdev);
 extern void e1000_check_options(struct e1000_adapter *adapter);
+extern char *e1000_get_hw_dev_name(struct e1000_hw *hw);
 
 #endif /* _E1000_H_ */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 616b405..d6931ca 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -346,7 +346,7 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 
 	netdev->features &= ~NETIF_F_TSO6;
 
-	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
+	e_info("TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->tso_force = true;
 	return 0;
 }
@@ -714,9 +714,9 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data, int reg,
 		writel(write & test[i], address);
 		read = readl(address);
 		if (read != (write & test[i] & mask)) {
-			DPRINTK(DRV, ERR, "pattern test reg %04X failed: "
-				"got 0x%08X expected 0x%08X\n",
-				reg, read, (write & test[i] & mask));
+			e_info("pattern test reg %04X failed: "
+			       "got 0x%08X expected 0x%08X\n",
+			       reg, read, (write & test[i] & mask));
 			*data = reg;
 			return true;
 		}
@@ -734,9 +734,9 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data, int reg,
 	writel(write & mask, address);
 	read = readl(address);
 	if ((read & mask) != (write & mask)) {
-		DPRINTK(DRV, ERR, "set/check reg %04X test failed: "
-			"got 0x%08X expected 0x%08X\n",
-			reg, (read & mask), (write & mask));
+		e_err("set/check reg %04X test failed: "
+		      "got 0x%08X expected 0x%08X\n",
+		      reg, (read & mask), (write & mask));
 		*data = reg;
 		return true;
 	}
@@ -779,8 +779,8 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	ew32(STATUS, toggle);
 	after = er32(STATUS) & toggle;
 	if (value != after) {
-		DPRINTK(DRV, ERR, "failed STATUS register test got: "
-		        "0x%08X expected: 0x%08X\n", after, value);
+		e_err("failed STATUS register test got: "
+		      "0x%08X expected: 0x%08X\n", after, value);
 		*data = 1;
 		return 1;
 	}
@@ -894,8 +894,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		*data = 1;
 		return -1;
 	}
-	DPRINTK(HW, INFO, "testing %s interrupt\n",
-	        (shared_int ? "shared" : "unshared"));
+	e_info("testing %s interrupt\n", (shared_int ? "shared" : "unshared"));
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
@@ -1564,7 +1563,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		u8 forced_speed_duplex = hw->forced_speed_duplex;
 		u8 autoneg = hw->autoneg;
 
-		DPRINTK(HW, INFO, "offline testing starting\n");
+		e_info("offline testing starting\n");
 
 		/* Link test performed before hardware reset so autoneg doesn't
 		 * interfere with test result */
@@ -1604,7 +1603,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			dev_open(netdev);
 	} else {
-		DPRINTK(HW, INFO, "online testing starting\n");
+		e_info("online testing starting\n");
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1697,7 +1696,7 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->supported &= ~WAKE_UCAST;
 
 		if (adapter->wol & E1000_WUFC_EX)
-			DPRINTK(DRV, ERR, "Interface does not support "
+			e_err("Interface does not support "
 		        "directed (unicast) frame wake-up packets\n");
 		break;
 	default:
@@ -1731,8 +1730,8 @@ static int e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		if (wol->wolopts & WAKE_UCAST) {
-			DPRINTK(DRV, ERR, "Interface does not support "
-		        "directed (unicast) frame wake-up packets\n");
+			e_err("Interface does not support "
+			      "directed (unicast) frame wake-up packets\n");
 			return -EOPNOTSUPP;
 		}
 		break;
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index e2b6e6e..c7e242b 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -30,7 +30,7 @@
  * Shared functions for accessing and configuring the MAC
  */
 
-#include "e1000_hw.h"
+#include "e1000.h"
 
 static s32 e1000_check_downshift(struct e1000_hw *hw);
 static s32 e1000_check_polarity(struct e1000_hw *hw,
@@ -114,7 +114,7 @@ static DEFINE_SPINLOCK(e1000_eeprom_lock);
  */
 static s32 e1000_set_phy_type(struct e1000_hw *hw)
 {
-	DEBUGFUNC("e1000_set_phy_type");
+	e_dbg("e1000_set_phy_type");
 
 	if (hw->mac_type == e1000_undefined)
 		return -E1000_ERR_PHY_TYPE;
@@ -152,7 +152,7 @@ static void e1000_phy_init_script(struct e1000_hw *hw)
 	u32 ret_val;
 	u16 phy_saved_data;
 
-	DEBUGFUNC("e1000_phy_init_script");
+	e_dbg("e1000_phy_init_script");
 
 	if (hw->phy_init_script) {
 		msleep(20);
@@ -245,7 +245,7 @@ static void e1000_phy_init_script(struct e1000_hw *hw)
  */
 s32 e1000_set_mac_type(struct e1000_hw *hw)
 {
-	DEBUGFUNC("e1000_set_mac_type");
+	e_dbg("e1000_set_mac_type");
 
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82542:
@@ -354,7 +354,7 @@ void e1000_set_media_type(struct e1000_hw *hw)
 {
 	u32 status;
 
-	DEBUGFUNC("e1000_set_media_type");
+	e_dbg("e1000_set_media_type");
 
 	if (hw->mac_type != e1000_82543) {
 		/* tbi_compatibility is only valid on 82543 */
@@ -401,16 +401,16 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 	u32 led_ctrl;
 	s32 ret_val;
 
-	DEBUGFUNC("e1000_reset_hw");
+	e_dbg("e1000_reset_hw");
 
 	/* For 82542 (rev 2.0), disable MWI before issuing a device reset */
 	if (hw->mac_type == e1000_82542_rev2_0) {
-		DEBUGOUT("Disabling MWI on 82542 rev 2.0\n");
+		e_dbg("Disabling MWI on 82542 rev 2.0\n");
 		e1000_pci_clear_mwi(hw);
 	}
 
 	/* Clear interrupt mask to stop board from generating interrupts */
-	DEBUGOUT("Masking off all interrupts\n");
+	e_dbg("Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
 
 	/* Disable the Transmit and Receive units.  Then delay to allow
@@ -442,7 +442,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 	 * the current PCI configuration.  The global reset bit is self-
 	 * clearing, and should clear within a microsecond.
 	 */
-	DEBUGOUT("Issuing a global reset to MAC\n");
+	e_dbg("Issuing a global reset to MAC\n");
 
 	switch (hw->mac_type) {
 	case e1000_82544:
@@ -516,7 +516,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 	}
 
 	/* Clear interrupt mask to stop board from generating interrupts */
-	DEBUGOUT("Masking off all interrupts\n");
+	e_dbg("Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
 
 	/* Clear any pending interrupt events. */
@@ -549,12 +549,12 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 	u32 mta_size;
 	u32 ctrl_ext;
 
-	DEBUGFUNC("e1000_init_hw");
+	e_dbg("e1000_init_hw");
 
 	/* Initialize Identification LED */
 	ret_val = e1000_id_led_init(hw);
 	if (ret_val) {
-		DEBUGOUT("Error Initializing Identification LED\n");
+		e_dbg("Error Initializing Identification LED\n");
 		return ret_val;
 	}
 
@@ -562,14 +562,14 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 	e1000_set_media_type(hw);
 
 	/* Disabling VLAN filtering. */
-	DEBUGOUT("Initializing the IEEE VLAN\n");
+	e_dbg("Initializing the IEEE VLAN\n");
 	if (hw->mac_type < e1000_82545_rev_3)
 		ew32(VET, 0);
 	e1000_clear_vfta(hw);
 
 	/* For 82542 (rev 2.0), disable MWI and put the receiver into reset */
 	if (hw->mac_type == e1000_82542_rev2_0) {
-		DEBUGOUT("Disabling MWI on 82542 rev 2.0\n");
+		e_dbg("Disabling MWI on 82542 rev 2.0\n");
 		e1000_pci_clear_mwi(hw);
 		ew32(RCTL, E1000_RCTL_RST);
 		E1000_WRITE_FLUSH();
@@ -591,7 +591,7 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 	}
 
 	/* Zero out the Multicast HASH table */
-	DEBUGOUT("Zeroing the MTA\n");
+	e_dbg("Zeroing the MTA\n");
 	mta_size = E1000_MC_TBL_SIZE;
 	for (i = 0; i < mta_size; i++) {
 		E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
@@ -662,7 +662,7 @@ static s32 e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
 	u16 eeprom_data;
 	s32 ret_val;
 
-	DEBUGFUNC("e1000_adjust_serdes_amplitude");
+	e_dbg("e1000_adjust_serdes_amplitude");
 
 	if (hw->media_type != e1000_media_type_internal_serdes)
 		return E1000_SUCCESS;
@@ -709,7 +709,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 eeprom_data;
 
-	DEBUGFUNC("e1000_setup_link");
+	e_dbg("e1000_setup_link");
 
 	/* Read and store word 0x0F of the EEPROM. This word contains bits
 	 * that determine the hardware's default PAUSE (flow control) mode,
@@ -723,7 +723,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 		ret_val = e1000_read_eeprom(hw, EEPROM_INIT_CONTROL2_REG,
 					    1, &eeprom_data);
 		if (ret_val) {
-			DEBUGOUT("EEPROM Read Error\n");
+			e_dbg("EEPROM Read Error\n");
 			return -E1000_ERR_EEPROM;
 		}
 		if ((eeprom_data & EEPROM_WORD0F_PAUSE_MASK) == 0)
@@ -747,7 +747,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 
 	hw->original_fc = hw->fc;
 
-	DEBUGOUT1("After fix-ups FlowControl is now = %x\n", hw->fc);
+	e_dbg("After fix-ups FlowControl is now = %x\n", hw->fc);
 
 	/* Take the 4 bits from EEPROM word 0x0F that determine the initial
 	 * polarity value for the SW controlled pins, and setup the
@@ -760,7 +760,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 		ret_val = e1000_read_eeprom(hw, EEPROM_INIT_CONTROL2_REG,
 					    1, &eeprom_data);
 		if (ret_val) {
-			DEBUGOUT("EEPROM Read Error\n");
+			e_dbg("EEPROM Read Error\n");
 			return -E1000_ERR_EEPROM;
 		}
 		ctrl_ext = ((eeprom_data & EEPROM_WORD0F_SWPDIO_EXT) <<
@@ -777,8 +777,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 	 * control is disabled, because it does not hurt anything to
 	 * initialize these registers.
 	 */
-	DEBUGOUT
-	    ("Initializing the Flow Control address, type and timer regs\n");
+	e_dbg("Initializing the Flow Control address, type and timer regs\n");
 
 	ew32(FCT, FLOW_CONTROL_TYPE);
 	ew32(FCAH, FLOW_CONTROL_ADDRESS_HIGH);
@@ -827,7 +826,7 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 	u32 signal = 0;
 	s32 ret_val;
 
-	DEBUGFUNC("e1000_setup_fiber_serdes_link");
+	e_dbg("e1000_setup_fiber_serdes_link");
 
 	/* On adapters with a MAC newer than 82544, SWDP 1 will be
 	 * set when the optics detect a signal. On older adapters, it will be
@@ -893,7 +892,7 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
 		break;
 	default:
-		DEBUGOUT("Flow control param set incorrectly\n");
+		e_dbg("Flow control param set incorrectly\n");
 		return -E1000_ERR_CONFIG;
 		break;
 	}
@@ -904,7 +903,7 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 	 * link-up status bit will be set and the flow control enable bits (RFCE
 	 * and TFCE) will be set according to their negotiated value.
 	 */
-	DEBUGOUT("Auto-negotiation enabled\n");
+	e_dbg("Auto-negotiation enabled\n");
 
 	ew32(TXCW, txcw);
 	ew32(CTRL, ctrl);
@@ -921,7 +920,7 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 	 */
 	if (hw->media_type == e1000_media_type_internal_serdes ||
 	    (er32(CTRL) & E1000_CTRL_SWDPIN1) == signal) {
-		DEBUGOUT("Looking for Link\n");
+		e_dbg("Looking for Link\n");
 		for (i = 0; i < (LINK_UP_TIMEOUT / 10); i++) {
 			msleep(10);
 			status = er32(STATUS);
@@ -929,7 +928,7 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 				break;
 		}
 		if (i == (LINK_UP_TIMEOUT / 10)) {
-			DEBUGOUT("Never got a valid link from auto-neg!!!\n");
+			e_dbg("Never got a valid link from auto-neg!!!\n");
 			hw->autoneg_failed = 1;
 			/* AutoNeg failed to achieve a link, so we'll call
 			 * e1000_check_for_link. This routine will force the link up if
@@ -938,16 +937,16 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 			 */
 			ret_val = e1000_check_for_link(hw);
 			if (ret_val) {
-				DEBUGOUT("Error while checking for link\n");
+				e_dbg("Error while checking for link\n");
 				return ret_val;
 			}
 			hw->autoneg_failed = 0;
 		} else {
 			hw->autoneg_failed = 0;
-			DEBUGOUT("Valid Link Found\n");
+			e_dbg("Valid Link Found\n");
 		}
 	} else {
-		DEBUGOUT("No Signal Detected\n");
+		e_dbg("No Signal Detected\n");
 	}
 	return E1000_SUCCESS;
 }
@@ -964,7 +963,7 @@ static s32 e1000_copper_link_preconfig(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_copper_link_preconfig");
+	e_dbg("e1000_copper_link_preconfig");
 
 	ctrl = er32(CTRL);
 	/* With 82543, we need to force speed and duplex on the MAC equal to what
@@ -987,10 +986,10 @@ static s32 e1000_copper_link_preconfig(struct e1000_hw *hw)
 	/* Make sure we have a valid PHY */
 	ret_val = e1000_detect_gig_phy(hw);
 	if (ret_val) {
-		DEBUGOUT("Error, did not detect valid phy.\n");
+		e_dbg("Error, did not detect valid phy.\n");
 		return ret_val;
 	}
-	DEBUGOUT1("Phy ID = %x\n", hw->phy_id);
+	e_dbg("Phy ID = %x\n", hw->phy_id);
 
 	/* Set PHY to class A mode (if necessary) */
 	ret_val = e1000_set_phy_mode(hw);
@@ -1025,14 +1024,14 @@ static s32 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_copper_link_igp_setup");
+	e_dbg("e1000_copper_link_igp_setup");
 
 	if (hw->phy_reset_disable)
 		return E1000_SUCCESS;
 
 	ret_val = e1000_phy_reset(hw);
 	if (ret_val) {
-		DEBUGOUT("Error Resetting the PHY\n");
+		e_dbg("Error Resetting the PHY\n");
 		return ret_val;
 	}
 
@@ -1049,7 +1048,7 @@ static s32 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 		/* disable lplu d3 during driver init */
 		ret_val = e1000_set_d3_lplu_state(hw, false);
 		if (ret_val) {
-			DEBUGOUT("Error Disabling LPLU D3\n");
+			e_dbg("Error Disabling LPLU D3\n");
 			return ret_val;
 		}
 	}
@@ -1166,7 +1165,7 @@ static s32 e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_copper_link_mgp_setup");
+	e_dbg("e1000_copper_link_mgp_setup");
 
 	if (hw->phy_reset_disable)
 		return E1000_SUCCESS;
@@ -1255,7 +1254,7 @@ static s32 e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 	/* SW Reset the PHY so all changes take effect */
 	ret_val = e1000_phy_reset(hw);
 	if (ret_val) {
-		DEBUGOUT("Error Resetting the PHY\n");
+		e_dbg("Error Resetting the PHY\n");
 		return ret_val;
 	}
 
@@ -1274,7 +1273,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_copper_link_autoneg");
+	e_dbg("e1000_copper_link_autoneg");
 
 	/* Perform some bounds checking on the hw->autoneg_advertised
 	 * parameter.  If this variable is zero, then set it to the default.
@@ -1287,13 +1286,13 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	if (hw->autoneg_advertised == 0)
 		hw->autoneg_advertised = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
-	DEBUGOUT("Reconfiguring auto-neg advertisement params\n");
+	e_dbg("Reconfiguring auto-neg advertisement params\n");
 	ret_val = e1000_phy_setup_autoneg(hw);
 	if (ret_val) {
-		DEBUGOUT("Error Setting up Auto-Negotiation\n");
+		e_dbg("Error Setting up Auto-Negotiation\n");
 		return ret_val;
 	}
-	DEBUGOUT("Restarting Auto-Neg\n");
+	e_dbg("Restarting Auto-Neg\n");
 
 	/* Restart auto-negotiation by setting the Auto Neg Enable bit and
 	 * the Auto Neg Restart bit in the PHY control register.
@@ -1313,7 +1312,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	if (hw->wait_autoneg_complete) {
 		ret_val = e1000_wait_autoneg(hw);
 		if (ret_val) {
-			DEBUGOUT
+			e_dbg
 			    ("Error while waiting for autoneg to complete\n");
 			return ret_val;
 		}
@@ -1340,20 +1339,20 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 static s32 e1000_copper_link_postconfig(struct e1000_hw *hw)
 {
 	s32 ret_val;
-	DEBUGFUNC("e1000_copper_link_postconfig");
+	e_dbg("e1000_copper_link_postconfig");
 
 	if (hw->mac_type >= e1000_82544) {
 		e1000_config_collision_dist(hw);
 	} else {
 		ret_val = e1000_config_mac_to_phy(hw);
 		if (ret_val) {
-			DEBUGOUT("Error configuring MAC to PHY settings\n");
+			e_dbg("Error configuring MAC to PHY settings\n");
 			return ret_val;
 		}
 	}
 	ret_val = e1000_config_fc_after_link_up(hw);
 	if (ret_val) {
-		DEBUGOUT("Error Configuring Flow Control\n");
+		e_dbg("Error Configuring Flow Control\n");
 		return ret_val;
 	}
 
@@ -1361,7 +1360,7 @@ static s32 e1000_copper_link_postconfig(struct e1000_hw *hw)
 	if (hw->phy_type == e1000_phy_igp) {
 		ret_val = e1000_config_dsp_after_link_change(hw, true);
 		if (ret_val) {
-			DEBUGOUT("Error Configuring DSP after link up\n");
+			e_dbg("Error Configuring DSP after link up\n");
 			return ret_val;
 		}
 	}
@@ -1381,7 +1380,7 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
 	u16 i;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_setup_copper_link");
+	e_dbg("e1000_setup_copper_link");
 
 	/* Check if it is a valid PHY and set PHY mode if necessary. */
 	ret_val = e1000_copper_link_preconfig(hw);
@@ -1407,10 +1406,10 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
 	} else {
 		/* PHY will be set to 10H, 10F, 100H,or 100F
 		 * depending on value from forced_speed_duplex. */
-		DEBUGOUT("Forcing speed and duplex\n");
+		e_dbg("Forcing speed and duplex\n");
 		ret_val = e1000_phy_force_speed_duplex(hw);
 		if (ret_val) {
-			DEBUGOUT("Error Forcing Speed and Duplex\n");
+			e_dbg("Error Forcing Speed and Duplex\n");
 			return ret_val;
 		}
 	}
@@ -1432,13 +1431,13 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
 			if (ret_val)
 				return ret_val;
 
-			DEBUGOUT("Valid link established!!!\n");
+			e_dbg("Valid link established!!!\n");
 			return E1000_SUCCESS;
 		}
 		udelay(10);
 	}
 
-	DEBUGOUT("Unable to establish link!!!\n");
+	e_dbg("Unable to establish link!!!\n");
 	return E1000_SUCCESS;
 }
 
@@ -1454,7 +1453,7 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	u16 mii_autoneg_adv_reg;
 	u16 mii_1000t_ctrl_reg;
 
-	DEBUGFUNC("e1000_phy_setup_autoneg");
+	e_dbg("e1000_phy_setup_autoneg");
 
 	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
 	ret_val = e1000_read_phy_reg(hw, PHY_AUTONEG_ADV, &mii_autoneg_adv_reg);
@@ -1481,41 +1480,41 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	mii_autoneg_adv_reg &= ~REG4_SPEED_MASK;
 	mii_1000t_ctrl_reg &= ~REG9_SPEED_MASK;
 
-	DEBUGOUT1("autoneg_advertised %x\n", hw->autoneg_advertised);
+	e_dbg("autoneg_advertised %x\n", hw->autoneg_advertised);
 
 	/* Do we want to advertise 10 Mb Half Duplex? */
 	if (hw->autoneg_advertised & ADVERTISE_10_HALF) {
-		DEBUGOUT("Advertise 10mb Half duplex\n");
+		e_dbg("Advertise 10mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_HD_CAPS;
 	}
 
 	/* Do we want to advertise 10 Mb Full Duplex? */
 	if (hw->autoneg_advertised & ADVERTISE_10_FULL) {
-		DEBUGOUT("Advertise 10mb Full duplex\n");
+		e_dbg("Advertise 10mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_FD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Half Duplex? */
 	if (hw->autoneg_advertised & ADVERTISE_100_HALF) {
-		DEBUGOUT("Advertise 100mb Half duplex\n");
+		e_dbg("Advertise 100mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_HD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Full Duplex? */
 	if (hw->autoneg_advertised & ADVERTISE_100_FULL) {
-		DEBUGOUT("Advertise 100mb Full duplex\n");
+		e_dbg("Advertise 100mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_FD_CAPS;
 	}
 
 	/* We do not allow the Phy to advertise 1000 Mb Half Duplex */
 	if (hw->autoneg_advertised & ADVERTISE_1000_HALF) {
-		DEBUGOUT
+		e_dbg
 		    ("Advertise 1000mb Half duplex requested, request denied!\n");
 	}
 
 	/* Do we want to advertise 1000 Mb Full Duplex? */
 	if (hw->autoneg_advertised & ADVERTISE_1000_FULL) {
-		DEBUGOUT("Advertise 1000mb Full duplex\n");
+		e_dbg("Advertise 1000mb Full duplex\n");
 		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
 	}
 
@@ -1568,7 +1567,7 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	default:
-		DEBUGOUT("Flow control param set incorrectly\n");
+		e_dbg("Flow control param set incorrectly\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -1576,7 +1575,7 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	DEBUGOUT1("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
+	e_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
 	ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
 	if (ret_val)
@@ -1600,12 +1599,12 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 	u16 phy_data;
 	u16 i;
 
-	DEBUGFUNC("e1000_phy_force_speed_duplex");
+	e_dbg("e1000_phy_force_speed_duplex");
 
 	/* Turn off Flow control if we are forcing speed and duplex. */
 	hw->fc = E1000_FC_NONE;
 
-	DEBUGOUT1("hw->fc = %d\n", hw->fc);
+	e_dbg("hw->fc = %d\n", hw->fc);
 
 	/* Read the Device Control Register. */
 	ctrl = er32(CTRL);
@@ -1634,14 +1633,14 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 		 */
 		ctrl |= E1000_CTRL_FD;
 		mii_ctrl_reg |= MII_CR_FULL_DUPLEX;
-		DEBUGOUT("Full Duplex\n");
+		e_dbg("Full Duplex\n");
 	} else {
 		/* We want to force half duplex so we CLEAR the full duplex bits in
 		 * the Device and MII Control Registers.
 		 */
 		ctrl &= ~E1000_CTRL_FD;
 		mii_ctrl_reg &= ~MII_CR_FULL_DUPLEX;
-		DEBUGOUT("Half Duplex\n");
+		e_dbg("Half Duplex\n");
 	}
 
 	/* Are we forcing 100Mbps??? */
@@ -1651,13 +1650,13 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 		ctrl |= E1000_CTRL_SPD_100;
 		mii_ctrl_reg |= MII_CR_SPEED_100;
 		mii_ctrl_reg &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_10);
-		DEBUGOUT("Forcing 100mb ");
+		e_dbg("Forcing 100mb ");
 	} else {
 		/* Set the 10Mb bit and turn off the 1000Mb and 100Mb bits. */
 		ctrl &= ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
 		mii_ctrl_reg |= MII_CR_SPEED_10;
 		mii_ctrl_reg &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_100);
-		DEBUGOUT("Forcing 10mb ");
+		e_dbg("Forcing 10mb ");
 	}
 
 	e1000_config_collision_dist(hw);
@@ -1680,7 +1679,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		DEBUGOUT1("M88E1000 PSCR: %x\n", phy_data);
+		e_dbg("M88E1000 PSCR: %x\n", phy_data);
 
 		/* Need to reset the PHY or these changes will be ignored */
 		mii_ctrl_reg |= MII_CR_RESET;
@@ -1720,7 +1719,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 	 */
 	if (hw->wait_autoneg_complete) {
 		/* We will wait for autoneg to complete. */
-		DEBUGOUT("Waiting for forced speed/duplex link.\n");
+		e_dbg("Waiting for forced speed/duplex link.\n");
 		mii_status_reg = 0;
 
 		/* We will wait for autoneg to complete or 4.5 seconds to expire. */
@@ -1746,7 +1745,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 			/* We didn't get link.  Reset the DSP and wait again for link. */
 			ret_val = e1000_phy_reset_dsp(hw);
 			if (ret_val) {
-				DEBUGOUT("Error Resetting PHY DSP\n");
+				e_dbg("Error Resetting PHY DSP\n");
 				return ret_val;
 			}
 		}
@@ -1826,7 +1825,7 @@ void e1000_config_collision_dist(struct e1000_hw *hw)
 {
 	u32 tctl, coll_dist;
 
-	DEBUGFUNC("e1000_config_collision_dist");
+	e_dbg("e1000_config_collision_dist");
 
 	if (hw->mac_type < e1000_82543)
 		coll_dist = E1000_COLLISION_DISTANCE_82542;
@@ -1857,7 +1856,7 @@ static s32 e1000_config_mac_to_phy(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_config_mac_to_phy");
+	e_dbg("e1000_config_mac_to_phy");
 
 	/* 82544 or newer MAC, Auto Speed Detection takes care of
 	 * MAC speed/duplex configuration.*/
@@ -1913,7 +1912,7 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
 {
 	u32 ctrl;
 
-	DEBUGFUNC("e1000_force_mac_fc");
+	e_dbg("e1000_force_mac_fc");
 
 	/* Get the current configuration of the Device Control Register */
 	ctrl = er32(CTRL);
@@ -1952,7 +1951,7 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
 		ctrl |= (E1000_CTRL_TFCE | E1000_CTRL_RFCE);
 		break;
 	default:
-		DEBUGOUT("Flow control param set incorrectly\n");
+		e_dbg("Flow control param set incorrectly\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -1984,7 +1983,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 	u16 speed;
 	u16 duplex;
 
-	DEBUGFUNC("e1000_config_fc_after_link_up");
+	e_dbg("e1000_config_fc_after_link_up");
 
 	/* Check for the case where we have fiber media and auto-neg failed
 	 * so we had to force link.  In this case, we need to force the
@@ -1997,7 +1996,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 		&& (!hw->autoneg))) {
 		ret_val = e1000_force_mac_fc(hw);
 		if (ret_val) {
-			DEBUGOUT("Error forcing flow control settings\n");
+			e_dbg("Error forcing flow control settings\n");
 			return ret_val;
 		}
 	}
@@ -2079,10 +2078,10 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 				 */
 				if (hw->original_fc == E1000_FC_FULL) {
 					hw->fc = E1000_FC_FULL;
-					DEBUGOUT("Flow Control = FULL.\n");
+					e_dbg("Flow Control = FULL.\n");
 				} else {
 					hw->fc = E1000_FC_RX_PAUSE;
-					DEBUGOUT
+					e_dbg
 					    ("Flow Control = RX PAUSE frames only.\n");
 				}
 			}
@@ -2100,7 +2099,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR))
 			{
 				hw->fc = E1000_FC_TX_PAUSE;
-				DEBUGOUT
+				e_dbg
 				    ("Flow Control = TX PAUSE frames only.\n");
 			}
 			/* For transmitting PAUSE frames ONLY.
@@ -2117,7 +2116,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 				 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR))
 			{
 				hw->fc = E1000_FC_RX_PAUSE;
-				DEBUGOUT
+				e_dbg
 				    ("Flow Control = RX PAUSE frames only.\n");
 			}
 			/* Per the IEEE spec, at this point flow control should be
@@ -2144,10 +2143,10 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 				  hw->original_fc == E1000_FC_TX_PAUSE) ||
 				 hw->fc_strict_ieee) {
 				hw->fc = E1000_FC_NONE;
-				DEBUGOUT("Flow Control = NONE.\n");
+				e_dbg("Flow Control = NONE.\n");
 			} else {
 				hw->fc = E1000_FC_RX_PAUSE;
-				DEBUGOUT
+				e_dbg
 				    ("Flow Control = RX PAUSE frames only.\n");
 			}
 
@@ -2158,7 +2157,7 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 			ret_val =
 			    e1000_get_speed_and_duplex(hw, &speed, &duplex);
 			if (ret_val) {
-				DEBUGOUT
+				e_dbg
 				    ("Error getting link speed and duplex\n");
 				return ret_val;
 			}
@@ -2171,12 +2170,12 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 			 */
 			ret_val = e1000_force_mac_fc(hw);
 			if (ret_val) {
-				DEBUGOUT
+				e_dbg
 				    ("Error forcing flow control settings\n");
 				return ret_val;
 			}
 		} else {
-			DEBUGOUT
+			e_dbg
 			    ("Copper PHY and Auto Neg has not completed.\n");
 		}
 	}
@@ -2197,7 +2196,7 @@ static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
 	u32 status;
 	s32 ret_val = E1000_SUCCESS;
 
-	DEBUGFUNC("e1000_check_for_serdes_link_generic");
+	e_dbg("e1000_check_for_serdes_link_generic");
 
 	ctrl = er32(CTRL);
 	status = er32(STATUS);
@@ -2216,7 +2215,7 @@ static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
 			hw->autoneg_failed = 1;
 			goto out;
 		}
-		DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
+		e_dbg("NOT RXing /C/, disable AutoNeg and force link.\n");
 
 		/* Disable auto-negotiation in the TXCW register */
 		ew32(TXCW, (hw->txcw & ~E1000_TXCW_ANE));
@@ -2229,7 +2228,7 @@ static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
 		/* Configure Flow Control after forcing link up. */
 		ret_val = e1000_config_fc_after_link_up(hw);
 		if (ret_val) {
-			DEBUGOUT("Error configuring flow control\n");
+			e_dbg("Error configuring flow control\n");
 			goto out;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
@@ -2239,7 +2238,7 @@ static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
 		 */
-		DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\n");
+		e_dbg("RXing /C/, enable AutoNeg and stop forcing link.\n");
 		ew32(TXCW, hw->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 
@@ -2256,11 +2255,11 @@ static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
 		if (rxcw & E1000_RXCW_SYNCH) {
 			if (!(rxcw & E1000_RXCW_IV)) {
 				hw->serdes_has_link = true;
-				DEBUGOUT("SERDES: Link up - forced.\n");
+				e_dbg("SERDES: Link up - forced.\n");
 			}
 		} else {
 			hw->serdes_has_link = false;
-			DEBUGOUT("SERDES: Link down - force failed.\n");
+			e_dbg("SERDES: Link down - force failed.\n");
 		}
 	}
 
@@ -2273,20 +2272,20 @@ static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
 			if (rxcw & E1000_RXCW_SYNCH) {
 				if (!(rxcw & E1000_RXCW_IV)) {
 					hw->serdes_has_link = true;
-					DEBUGOUT("SERDES: Link up - autoneg "
+					e_dbg("SERDES: Link up - autoneg "
 						 "completed successfully.\n");
 				} else {
 					hw->serdes_has_link = false;
-					DEBUGOUT("SERDES: Link down - invalid"
+					e_dbg("SERDES: Link down - invalid"
 						 "codewords detected in autoneg.\n");
 				}
 			} else {
 				hw->serdes_has_link = false;
-				DEBUGOUT("SERDES: Link down - no sync.\n");
+				e_dbg("SERDES: Link down - no sync.\n");
 			}
 		} else {
 			hw->serdes_has_link = false;
-			DEBUGOUT("SERDES: Link down - autoneg failed\n");
+			e_dbg("SERDES: Link down - autoneg failed\n");
 		}
 	}
 
@@ -2312,7 +2311,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_check_for_link");
+	e_dbg("e1000_check_for_link");
 
 	ctrl = er32(CTRL);
 	status = er32(STATUS);
@@ -2407,7 +2406,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 		else {
 			ret_val = e1000_config_mac_to_phy(hw);
 			if (ret_val) {
-				DEBUGOUT
+				e_dbg
 				    ("Error configuring MAC to PHY settings\n");
 				return ret_val;
 			}
@@ -2419,7 +2418,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 		 */
 		ret_val = e1000_config_fc_after_link_up(hw);
 		if (ret_val) {
-			DEBUGOUT("Error configuring flow control\n");
+			e_dbg("Error configuring flow control\n");
 			return ret_val;
 		}
 
@@ -2435,7 +2434,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 			ret_val =
 			    e1000_get_speed_and_duplex(hw, &speed, &duplex);
 			if (ret_val) {
-				DEBUGOUT
+				e_dbg
 				    ("Error getting link speed and duplex\n");
 				return ret_val;
 			}
@@ -2487,30 +2486,30 @@ s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_get_speed_and_duplex");
+	e_dbg("e1000_get_speed_and_duplex");
 
 	if (hw->mac_type >= e1000_82543) {
 		status = er32(STATUS);
 		if (status & E1000_STATUS_SPEED_1000) {
 			*speed = SPEED_1000;
-			DEBUGOUT("1000 Mbs, ");
+			e_dbg("1000 Mbs, ");
 		} else if (status & E1000_STATUS_SPEED_100) {
 			*speed = SPEED_100;
-			DEBUGOUT("100 Mbs, ");
+			e_dbg("100 Mbs, ");
 		} else {
 			*speed = SPEED_10;
-			DEBUGOUT("10 Mbs, ");
+			e_dbg("10 Mbs, ");
 		}
 
 		if (status & E1000_STATUS_FD) {
 			*duplex = FULL_DUPLEX;
-			DEBUGOUT("Full Duplex\n");
+			e_dbg("Full Duplex\n");
 		} else {
 			*duplex = HALF_DUPLEX;
-			DEBUGOUT(" Half Duplex\n");
+			e_dbg(" Half Duplex\n");
 		}
 	} else {
-		DEBUGOUT("1000 Mbs, Full Duplex\n");
+		e_dbg("1000 Mbs, Full Duplex\n");
 		*speed = SPEED_1000;
 		*duplex = FULL_DUPLEX;
 	}
@@ -2554,8 +2553,8 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw)
 	u16 i;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_wait_autoneg");
-	DEBUGOUT("Waiting for Auto-Neg to complete.\n");
+	e_dbg("e1000_wait_autoneg");
+	e_dbg("Waiting for Auto-Neg to complete.\n");
 
 	/* We will wait for autoneg to complete or 4.5 seconds to expire. */
 	for (i = PHY_AUTO_NEG_TIME; i > 0; i--) {
@@ -2718,7 +2717,7 @@ s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data)
 {
 	u32 ret_val;
 
-	DEBUGFUNC("e1000_read_phy_reg");
+	e_dbg("e1000_read_phy_reg");
 
 	if ((hw->phy_type == e1000_phy_igp) &&
 	    (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
@@ -2741,10 +2740,10 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 	u32 mdic = 0;
 	const u32 phy_addr = 1;
 
-	DEBUGFUNC("e1000_read_phy_reg_ex");
+	e_dbg("e1000_read_phy_reg_ex");
 
 	if (reg_addr > MAX_PHY_REG_ADDRESS) {
-		DEBUGOUT1("PHY Address %d is out of range\n", reg_addr);
+		e_dbg("PHY Address %d is out of range\n", reg_addr);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -2767,11 +2766,11 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 				break;
 		}
 		if (!(mdic & E1000_MDIC_READY)) {
-			DEBUGOUT("MDI Read did not complete\n");
+			e_dbg("MDI Read did not complete\n");
 			return -E1000_ERR_PHY;
 		}
 		if (mdic & E1000_MDIC_ERROR) {
-			DEBUGOUT("MDI Error\n");
+			e_dbg("MDI Error\n");
 			return -E1000_ERR_PHY;
 		}
 		*phy_data = (u16) mdic;
@@ -2820,7 +2819,7 @@ s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 phy_data)
 {
 	u32 ret_val;
 
-	DEBUGFUNC("e1000_write_phy_reg");
+	e_dbg("e1000_write_phy_reg");
 
 	if ((hw->phy_type == e1000_phy_igp) &&
 	    (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
@@ -2843,10 +2842,10 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 	u32 mdic = 0;
 	const u32 phy_addr = 1;
 
-	DEBUGFUNC("e1000_write_phy_reg_ex");
+	e_dbg("e1000_write_phy_reg_ex");
 
 	if (reg_addr > MAX_PHY_REG_ADDRESS) {
-		DEBUGOUT1("PHY Address %d is out of range\n", reg_addr);
+		e_dbg("PHY Address %d is out of range\n", reg_addr);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -2870,7 +2869,7 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 				break;
 		}
 		if (!(mdic & E1000_MDIC_READY)) {
-			DEBUGOUT("MDI Write did not complete\n");
+			e_dbg("MDI Write did not complete\n");
 			return -E1000_ERR_PHY;
 		}
 	} else {
@@ -2910,9 +2909,9 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 	u32 led_ctrl;
 	s32 ret_val;
 
-	DEBUGFUNC("e1000_phy_hw_reset");
+	e_dbg("e1000_phy_hw_reset");
 
-	DEBUGOUT("Resetting Phy...\n");
+	e_dbg("Resetting Phy...\n");
 
 	if (hw->mac_type > e1000_82543) {
 		/* Read the device control register and assert the E1000_CTRL_PHY_RST
@@ -2973,7 +2972,7 @@ s32 e1000_phy_reset(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_phy_reset");
+	e_dbg("e1000_phy_reset");
 
 	switch (hw->phy_type) {
 	case e1000_phy_igp:
@@ -3013,7 +3012,7 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
 	u16 phy_id_high, phy_id_low;
 	bool match = false;
 
-	DEBUGFUNC("e1000_detect_gig_phy");
+	e_dbg("e1000_detect_gig_phy");
 
 	if (hw->phy_id != 0)
 		return E1000_SUCCESS;
@@ -3057,16 +3056,16 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
 			match = true;
 		break;
 	default:
-		DEBUGOUT1("Invalid MAC type %d\n", hw->mac_type);
+		e_dbg("Invalid MAC type %d\n", hw->mac_type);
 		return -E1000_ERR_CONFIG;
 	}
 	phy_init_status = e1000_set_phy_type(hw);
 
 	if ((match) && (phy_init_status == E1000_SUCCESS)) {
-		DEBUGOUT1("PHY ID 0x%X detected\n", hw->phy_id);
+		e_dbg("PHY ID 0x%X detected\n", hw->phy_id);
 		return E1000_SUCCESS;
 	}
-	DEBUGOUT1("Invalid PHY ID 0x%X\n", hw->phy_id);
+	e_dbg("Invalid PHY ID 0x%X\n", hw->phy_id);
 	return -E1000_ERR_PHY;
 }
 
@@ -3079,7 +3078,7 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
 static s32 e1000_phy_reset_dsp(struct e1000_hw *hw)
 {
 	s32 ret_val;
-	DEBUGFUNC("e1000_phy_reset_dsp");
+	e_dbg("e1000_phy_reset_dsp");
 
 	do {
 		ret_val = e1000_write_phy_reg(hw, 29, 0x001d);
@@ -3111,7 +3110,7 @@ static s32 e1000_phy_igp_get_info(struct e1000_hw *hw,
 	u16 phy_data, min_length, max_length, average;
 	e1000_rev_polarity polarity;
 
-	DEBUGFUNC("e1000_phy_igp_get_info");
+	e_dbg("e1000_phy_igp_get_info");
 
 	/* The downshift status is checked only once, after link is established,
 	 * and it stored in the hw->speed_downgraded parameter. */
@@ -3189,7 +3188,7 @@ static s32 e1000_phy_m88_get_info(struct e1000_hw *hw,
 	u16 phy_data;
 	e1000_rev_polarity polarity;
 
-	DEBUGFUNC("e1000_phy_m88_get_info");
+	e_dbg("e1000_phy_m88_get_info");
 
 	/* The downshift status is checked only once, after link is established,
 	 * and it stored in the hw->speed_downgraded parameter. */
@@ -3261,7 +3260,7 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_phy_get_info");
+	e_dbg("e1000_phy_get_info");
 
 	phy_info->cable_length = e1000_cable_length_undefined;
 	phy_info->extended_10bt_distance = e1000_10bt_ext_dist_enable_undefined;
@@ -3273,7 +3272,7 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
 	phy_info->remote_rx = e1000_1000t_rx_status_undefined;
 
 	if (hw->media_type != e1000_media_type_copper) {
-		DEBUGOUT("PHY info is only valid for copper media\n");
+		e_dbg("PHY info is only valid for copper media\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -3286,7 +3285,7 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
 		return ret_val;
 
 	if ((phy_data & MII_SR_LINK_STATUS) != MII_SR_LINK_STATUS) {
-		DEBUGOUT("PHY info is only valid if link is up\n");
+		e_dbg("PHY info is only valid if link is up\n");
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -3298,10 +3297,10 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
 
 s32 e1000_validate_mdi_setting(struct e1000_hw *hw)
 {
-	DEBUGFUNC("e1000_validate_mdi_settings");
+	e_dbg("e1000_validate_mdi_settings");
 
 	if (!hw->autoneg && (hw->mdix == 0 || hw->mdix == 3)) {
-		DEBUGOUT("Invalid MDI setting detected\n");
+		e_dbg("Invalid MDI setting detected\n");
 		hw->mdix = 1;
 		return -E1000_ERR_CONFIG;
 	}
@@ -3322,7 +3321,7 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
 	s32 ret_val = E1000_SUCCESS;
 	u16 eeprom_size;
 
-	DEBUGFUNC("e1000_init_eeprom_params");
+	e_dbg("e1000_init_eeprom_params");
 
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
@@ -3539,7 +3538,7 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
 	struct e1000_eeprom_info *eeprom = &hw->eeprom;
 	u32 eecd, i = 0;
 
-	DEBUGFUNC("e1000_acquire_eeprom");
+	e_dbg("e1000_acquire_eeprom");
 
 	eecd = er32(EECD);
 
@@ -3557,7 +3556,7 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
 		if (!(eecd & E1000_EECD_GNT)) {
 			eecd &= ~E1000_EECD_REQ;
 			ew32(EECD, eecd);
-			DEBUGOUT("Could not acquire EEPROM grant\n");
+			e_dbg("Could not acquire EEPROM grant\n");
 			return -E1000_ERR_EEPROM;
 		}
 	}
@@ -3639,7 +3638,7 @@ static void e1000_release_eeprom(struct e1000_hw *hw)
 {
 	u32 eecd;
 
-	DEBUGFUNC("e1000_release_eeprom");
+	e_dbg("e1000_release_eeprom");
 
 	eecd = er32(EECD);
 
@@ -3687,7 +3686,7 @@ static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 	u16 retry_count = 0;
 	u8 spi_stat_reg;
 
-	DEBUGFUNC("e1000_spi_eeprom_ready");
+	e_dbg("e1000_spi_eeprom_ready");
 
 	/* Read "Status Register" repeatedly until the LSB is cleared.  The
 	 * EEPROM will signal that the command has been completed by clearing
@@ -3712,7 +3711,7 @@ static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 	 * only 0-5mSec on 5V devices)
 	 */
 	if (retry_count >= EEPROM_MAX_RETRY_SPI) {
-		DEBUGOUT("SPI EEPROM Status error\n");
+		e_dbg("SPI EEPROM Status error\n");
 		return -E1000_ERR_EEPROM;
 	}
 
@@ -3741,7 +3740,7 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 	struct e1000_eeprom_info *eeprom = &hw->eeprom;
 	u32 i = 0;
 
-	DEBUGFUNC("e1000_read_eeprom");
+	e_dbg("e1000_read_eeprom");
 
 	/* If eeprom is not yet detected, do so now */
 	if (eeprom->word_size == 0)
@@ -3752,9 +3751,8 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 	 */
 	if ((offset >= eeprom->word_size)
 	    || (words > eeprom->word_size - offset) || (words == 0)) {
-		DEBUGOUT2
-		    ("\"words\" parameter out of bounds. Words = %d, size = %d\n",
-		     offset, eeprom->word_size);
+		e_dbg("\"words\" parameter out of bounds. Words = %d,"
+		      "size = %d\n", offset, eeprom->word_size);
 		return -E1000_ERR_EEPROM;
 	}
 
@@ -3832,11 +3830,11 @@ s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 	u16 checksum = 0;
 	u16 i, eeprom_data;
 
-	DEBUGFUNC("e1000_validate_eeprom_checksum");
+	e_dbg("e1000_validate_eeprom_checksum");
 
 	for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
 		if (e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
-			DEBUGOUT("EEPROM Read Error\n");
+			e_dbg("EEPROM Read Error\n");
 			return -E1000_ERR_EEPROM;
 		}
 		checksum += eeprom_data;
@@ -3845,7 +3843,7 @@ s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 	if (checksum == (u16) EEPROM_SUM)
 		return E1000_SUCCESS;
 	else {
-		DEBUGOUT("EEPROM Checksum Invalid\n");
+		e_dbg("EEPROM Checksum Invalid\n");
 		return -E1000_ERR_EEPROM;
 	}
 }
@@ -3862,18 +3860,18 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 	u16 checksum = 0;
 	u16 i, eeprom_data;
 
-	DEBUGFUNC("e1000_update_eeprom_checksum");
+	e_dbg("e1000_update_eeprom_checksum");
 
 	for (i = 0; i < EEPROM_CHECKSUM_REG; i++) {
 		if (e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
-			DEBUGOUT("EEPROM Read Error\n");
+			e_dbg("EEPROM Read Error\n");
 			return -E1000_ERR_EEPROM;
 		}
 		checksum += eeprom_data;
 	}
 	checksum = (u16) EEPROM_SUM - checksum;
 	if (e1000_write_eeprom(hw, EEPROM_CHECKSUM_REG, 1, &checksum) < 0) {
-		DEBUGOUT("EEPROM Write Error\n");
+		e_dbg("EEPROM Write Error\n");
 		return -E1000_ERR_EEPROM;
 	}
 	return E1000_SUCCESS;
@@ -3904,7 +3902,7 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 	struct e1000_eeprom_info *eeprom = &hw->eeprom;
 	s32 status = 0;
 
-	DEBUGFUNC("e1000_write_eeprom");
+	e_dbg("e1000_write_eeprom");
 
 	/* If eeprom is not yet detected, do so now */
 	if (eeprom->word_size == 0)
@@ -3915,7 +3913,7 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 	 */
 	if ((offset >= eeprom->word_size)
 	    || (words > eeprom->word_size - offset) || (words == 0)) {
-		DEBUGOUT("\"words\" parameter out of bounds\n");
+		e_dbg("\"words\" parameter out of bounds\n");
 		return -E1000_ERR_EEPROM;
 	}
 
@@ -3949,7 +3947,7 @@ static s32 e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset, u16 words,
 	struct e1000_eeprom_info *eeprom = &hw->eeprom;
 	u16 widx = 0;
 
-	DEBUGFUNC("e1000_write_eeprom_spi");
+	e_dbg("e1000_write_eeprom_spi");
 
 	while (widx < words) {
 		u8 write_opcode = EEPROM_WRITE_OPCODE_SPI;
@@ -4013,7 +4011,7 @@ static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
 	u16 words_written = 0;
 	u16 i = 0;
 
-	DEBUGFUNC("e1000_write_eeprom_microwire");
+	e_dbg("e1000_write_eeprom_microwire");
 
 	/* Send the write enable command to the EEPROM (3-bit opcode plus
 	 * 6/8-bit dummy address beginning with 11).  It's less work to include
@@ -4056,7 +4054,7 @@ static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
 			udelay(50);
 		}
 		if (i == 200) {
-			DEBUGOUT("EEPROM Write did not complete\n");
+			e_dbg("EEPROM Write did not complete\n");
 			return -E1000_ERR_EEPROM;
 		}
 
@@ -4092,12 +4090,12 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
 	u16 offset;
 	u16 eeprom_data, i;
 
-	DEBUGFUNC("e1000_read_mac_addr");
+	e_dbg("e1000_read_mac_addr");
 
 	for (i = 0; i < NODE_ADDRESS_SIZE; i += 2) {
 		offset = i >> 1;
 		if (e1000_read_eeprom(hw, offset, 1, &eeprom_data) < 0) {
-			DEBUGOUT("EEPROM Read Error\n");
+			e_dbg("EEPROM Read Error\n");
 			return -E1000_ERR_EEPROM;
 		}
 		hw->perm_mac_addr[i] = (u8) (eeprom_data & 0x00FF);
@@ -4132,17 +4130,17 @@ static void e1000_init_rx_addrs(struct e1000_hw *hw)
 	u32 i;
 	u32 rar_num;
 
-	DEBUGFUNC("e1000_init_rx_addrs");
+	e_dbg("e1000_init_rx_addrs");
 
 	/* Setup the receive address. */
-	DEBUGOUT("Programming MAC Address into RAR[0]\n");
+	e_dbg("Programming MAC Address into RAR[0]\n");
 
 	e1000_rar_set(hw, hw->mac_addr, 0);
 
 	rar_num = E1000_RAR_ENTRIES;
 
 	/* Zero out the other 15 receive addresses. */
-	DEBUGOUT("Clearing RAR[1-15]\n");
+	e_dbg("Clearing RAR[1-15]\n");
 	for (i = 1; i < rar_num; i++) {
 		E1000_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		E1000_WRITE_FLUSH();
@@ -4290,7 +4288,7 @@ static s32 e1000_id_led_init(struct e1000_hw *hw)
 	u16 eeprom_data, i, temp;
 	const u16 led_mask = 0x0F;
 
-	DEBUGFUNC("e1000_id_led_init");
+	e_dbg("e1000_id_led_init");
 
 	if (hw->mac_type < e1000_82540) {
 		/* Nothing to do */
@@ -4303,7 +4301,7 @@ static s32 e1000_id_led_init(struct e1000_hw *hw)
 	hw->ledctl_mode2 = hw->ledctl_default;
 
 	if (e1000_read_eeprom(hw, EEPROM_ID_LED_SETTINGS, 1, &eeprom_data) < 0) {
-		DEBUGOUT("EEPROM Read Error\n");
+		e_dbg("EEPROM Read Error\n");
 		return -E1000_ERR_EEPROM;
 	}
 
@@ -4363,7 +4361,7 @@ s32 e1000_setup_led(struct e1000_hw *hw)
 	u32 ledctl;
 	s32 ret_val = E1000_SUCCESS;
 
-	DEBUGFUNC("e1000_setup_led");
+	e_dbg("e1000_setup_led");
 
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
@@ -4415,7 +4413,7 @@ s32 e1000_cleanup_led(struct e1000_hw *hw)
 {
 	s32 ret_val = E1000_SUCCESS;
 
-	DEBUGFUNC("e1000_cleanup_led");
+	e_dbg("e1000_cleanup_led");
 
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
@@ -4451,7 +4449,7 @@ s32 e1000_led_on(struct e1000_hw *hw)
 {
 	u32 ctrl = er32(CTRL);
 
-	DEBUGFUNC("e1000_led_on");
+	e_dbg("e1000_led_on");
 
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
@@ -4497,7 +4495,7 @@ s32 e1000_led_off(struct e1000_hw *hw)
 {
 	u32 ctrl = er32(CTRL);
 
-	DEBUGFUNC("e1000_led_off");
+	e_dbg("e1000_led_off");
 
 	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
@@ -4626,7 +4624,7 @@ static void e1000_clear_hw_cntrs(struct e1000_hw *hw)
  */
 void e1000_reset_adaptive(struct e1000_hw *hw)
 {
-	DEBUGFUNC("e1000_reset_adaptive");
+	e_dbg("e1000_reset_adaptive");
 
 	if (hw->adaptive_ifs) {
 		if (!hw->ifs_params_forced) {
@@ -4639,7 +4637,7 @@ void e1000_reset_adaptive(struct e1000_hw *hw)
 		hw->in_ifs_mode = false;
 		ew32(AIT, 0);
 	} else {
-		DEBUGOUT("Not in Adaptive IFS mode!\n");
+		e_dbg("Not in Adaptive IFS mode!\n");
 	}
 }
 
@@ -4654,7 +4652,7 @@ void e1000_reset_adaptive(struct e1000_hw *hw)
  */
 void e1000_update_adaptive(struct e1000_hw *hw)
 {
-	DEBUGFUNC("e1000_update_adaptive");
+	e_dbg("e1000_update_adaptive");
 
 	if (hw->adaptive_ifs) {
 		if ((hw->collision_delta *hw->ifs_ratio) > hw->tx_packet_delta) {
@@ -4679,7 +4677,7 @@ void e1000_update_adaptive(struct e1000_hw *hw)
 			}
 		}
 	} else {
-		DEBUGOUT("Not in Adaptive IFS mode!\n");
+		e_dbg("Not in Adaptive IFS mode!\n");
 	}
 }
 
@@ -4851,7 +4849,7 @@ static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
 	u16 i, phy_data;
 	u16 cable_length;
 
-	DEBUGFUNC("e1000_get_cable_length");
+	e_dbg("e1000_get_cable_length");
 
 	*min_length = *max_length = 0;
 
@@ -4968,7 +4966,7 @@ static s32 e1000_check_polarity(struct e1000_hw *hw,
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_check_polarity");
+	e_dbg("e1000_check_polarity");
 
 	if (hw->phy_type == e1000_phy_m88) {
 		/* return the Polarity bit in the Status register. */
@@ -5034,7 +5032,7 @@ static s32 e1000_check_downshift(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_check_downshift");
+	e_dbg("e1000_check_downshift");
 
 	if (hw->phy_type == e1000_phy_igp) {
 		ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_LINK_HEALTH,
@@ -5081,7 +5079,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 	};
 	u16 min_length, max_length;
 
-	DEBUGFUNC("e1000_config_dsp_after_link_change");
+	e_dbg("e1000_config_dsp_after_link_change");
 
 	if (hw->phy_type != e1000_phy_igp)
 		return E1000_SUCCESS;
@@ -5089,7 +5087,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 	if (link_up) {
 		ret_val = e1000_get_speed_and_duplex(hw, &speed, &duplex);
 		if (ret_val) {
-			DEBUGOUT("Error getting link speed and duplex\n");
+			e_dbg("Error getting link speed and duplex\n");
 			return ret_val;
 		}
 
@@ -5289,7 +5287,7 @@ static s32 e1000_set_phy_mode(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 eeprom_data;
 
-	DEBUGFUNC("e1000_set_phy_mode");
+	e_dbg("e1000_set_phy_mode");
 
 	if ((hw->mac_type == e1000_82545_rev_3) &&
 	    (hw->media_type == e1000_media_type_copper)) {
@@ -5337,7 +5335,7 @@ static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 {
 	s32 ret_val;
 	u16 phy_data;
-	DEBUGFUNC("e1000_set_d3_lplu_state");
+	e_dbg("e1000_set_d3_lplu_state");
 
 	if (hw->phy_type != e1000_phy_igp)
 		return E1000_SUCCESS;
@@ -5440,7 +5438,7 @@ static s32 e1000_set_vco_speed(struct e1000_hw *hw)
 	u16 default_page = 0;
 	u16 phy_data;
 
-	DEBUGFUNC("e1000_set_vco_speed");
+	e_dbg("e1000_set_vco_speed");
 
 	switch (hw->mac_type) {
 	case e1000_82545_rev_3:
@@ -5613,7 +5611,7 @@ static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
  */
 static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 {
-	DEBUGFUNC("e1000_get_auto_rd_done");
+	e_dbg("e1000_get_auto_rd_done");
 	msleep(5);
 	return E1000_SUCCESS;
 }
@@ -5628,7 +5626,7 @@ static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
  */
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
-	DEBUGFUNC("e1000_get_phy_cfg_done");
+	e_dbg("e1000_get_phy_cfg_done");
 	mdelay(10);
 	return E1000_SUCCESS;
 }
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 9acfddb..ecd9f6c 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -35,6 +35,7 @@
 
 #include "e1000_osdep.h"
 
+
 /* Forward declarations of structures used by the shared code */
 struct e1000_hw;
 struct e1000_hw_stats;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0a56e7d..e6ebc22 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -214,6 +214,17 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 /**
+ * e1000_get_hw_dev - return device
+ * used by hardware layer to print debugging information
+ *
+ **/
+struct net_device *e1000_get_hw_dev(struct e1000_hw *hw)
+{
+	struct e1000_adapter *adapter = hw->back;
+	return adapter->netdev;
+}
+
+/**
  * e1000_init_module - Driver Registration Routine
  *
  * e1000_init_module is the first routine called when the driver is
@@ -223,18 +234,17 @@ MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 static int __init e1000_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s - version %s\n",
-	       e1000_driver_string, e1000_driver_version);
+	pr_info("%s - version %s\n", e1000_driver_string, e1000_driver_version);
 
-	printk(KERN_INFO "%s\n", e1000_copyright);
+	pr_info("%s\n", e1000_copyright);
 
 	ret = pci_register_driver(&e1000_driver);
 	if (copybreak != COPYBREAK_DEFAULT) {
 		if (copybreak == 0)
-			printk(KERN_INFO "e1000: copybreak disabled\n");
+			pr_info("copybreak disabled\n");
 		else
-			printk(KERN_INFO "e1000: copybreak enabled for "
-			       "packets <= %u bytes\n", copybreak);
+			pr_info("copybreak enabled for "
+				   "packets <= %u bytes\n", copybreak);
 	}
 	return ret;
 }
@@ -265,8 +275,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 	                  netdev);
 	if (err) {
-		DPRINTK(PROBE, ERR,
-		        "Unable to allocate interrupt Error: %d\n", err);
+		e_err("Unable to allocate interrupt Error: %d\n", err);
 	}
 
 	return err;
@@ -648,7 +657,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 		ew32(WUC, 0);
 
 	if (e1000_init_hw(hw))
-		DPRINTK(PROBE, ERR, "Hardware Error\n");
+		e_err("Hardware Error\n");
 	e1000_update_mng_vlan(adapter);
 
 	/* if (adapter->hwflags & HWFLAGS_PHY_PWR_BIT) { */
@@ -689,8 +698,7 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 
 	data = kmalloc(eeprom.len, GFP_KERNEL);
 	if (!data) {
-		printk(KERN_ERR "Unable to allocate memory to dump EEPROM"
-		       " data\n");
+		pr_err("Unable to allocate memory to dump EEPROM data\n");
 		return;
 	}
 
@@ -702,30 +710,25 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 		csum_new += data[i] + (data[i + 1] << 8);
 	csum_new = EEPROM_SUM - csum_new;
 
-	printk(KERN_ERR "/*********************/\n");
-	printk(KERN_ERR "Current EEPROM Checksum : 0x%04x\n", csum_old);
-	printk(KERN_ERR "Calculated              : 0x%04x\n", csum_new);
+	pr_err("/*********************/\n");
+	pr_err("Current EEPROM Checksum : 0x%04x\n", csum_old);
+	pr_err("Calculated              : 0x%04x\n", csum_new);
 
-	printk(KERN_ERR "Offset    Values\n");
-	printk(KERN_ERR "========  ======\n");
+	pr_err("Offset    Values\n");
+	pr_err("========  ======\n");
 	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1, data, 128, 0);
 
-	printk(KERN_ERR "Include this output when contacting your support "
-	       "provider.\n");
-	printk(KERN_ERR "This is not a software error! Something bad "
-	       "happened to your hardware or\n");
-	printk(KERN_ERR "EEPROM image. Ignoring this "
-	       "problem could result in further problems,\n");
-	printk(KERN_ERR "possibly loss of data, corruption or system hangs!\n");
-	printk(KERN_ERR "The MAC Address will be reset to 00:00:00:00:00:00, "
-	       "which is invalid\n");
-	printk(KERN_ERR "and requires you to set the proper MAC "
-	       "address manually before continuing\n");
-	printk(KERN_ERR "to enable this network device.\n");
-	printk(KERN_ERR "Please inspect the EEPROM dump and report the issue "
-	       "to your hardware vendor\n");
-	printk(KERN_ERR "or Intel Customer Support.\n");
-	printk(KERN_ERR "/*********************/\n");
+	pr_err("Include this output when contacting your support provider.\n");
+	pr_err("This is not a software error! Something bad happened to\n");
+	pr_err("your hardware or EEPROM image. Ignoring this problem could\n");
+	pr_err("result in further problems, possibly loss of data,\n");
+	pr_err("corruption or system hangs!\n");
+	pr_err("The MAC Address will be reset to 00:00:00:00:00:00,\n");
+	pr_err("which is invalid and requires you to set the proper MAC\n");
+	pr_err("address manually before continuing to enable this network\n");
+	pr_err("device. Please inspect the EEPROM dump and report the\n");
+	pr_err("issue to your hardware vendor or Intel Customer Support.\n");
+	pr_err("/*********************/\n");
 
 	kfree(data);
 }
@@ -832,8 +835,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 			err = dma_set_coherent_mask(&pdev->dev,
 						    DMA_BIT_MASK(32));
 			if (err) {
-				E1000_ERR("No usable DMA configuration, "
-					  "aborting\n");
+				pr_err("No usable DMA config, aborting\n");
 				goto err_dma;
 			}
 		}
@@ -923,7 +925,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* initialize eeprom parameters */
 	if (e1000_init_eeprom_params(hw)) {
-		E1000_ERR("EEPROM initialization failed\n");
+		e_err("EEPROM initialization failed\n");
 		goto err_eeprom;
 	}
 
@@ -934,7 +936,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* make sure the EEPROM is good */
 	if (e1000_validate_eeprom_checksum(hw) < 0) {
-		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
+		e_err("The EEPROM Checksum Is Not Valid\n");
 		e1000_dump_eeprom(adapter);
 		/*
 		 * set MAC address to all zeroes to invalidate and temporary
@@ -948,14 +950,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	} else {
 		/* copy the MAC address out of the EEPROM */
 		if (e1000_read_mac_addr(hw))
-			DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
+			e_err("EEPROM Read Error\n");
 	}
 	/* don't block initalization here due to bad MAC address */
 	memcpy(netdev->dev_addr, hw->mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, hw->mac_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr))
-		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
+		e_err("Invalid MAC Address\n");
 
 	e1000_get_bus_info(hw);
 
@@ -1036,8 +1038,16 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->wol = adapter->eeprom_wol;
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
+	/* reset the hardware with the new settings */
+	e1000_reset(adapter);
+
+	strcpy(netdev->name, "eth%d");
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
+
 	/* print bus type/speed/width info */
-	DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
+	e_info("(PCI%s:%s:%s) ",
 		((hw->bus_type == e1000_bus_type_pcix) ? "-X" : ""),
 		((hw->bus_speed == e1000_bus_speed_133) ? "133MHz" :
 		 (hw->bus_speed == e1000_bus_speed_120) ? "120MHz" :
@@ -1045,20 +1055,12 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		 (hw->bus_speed == e1000_bus_speed_66) ? "66MHz" : "33MHz"),
 		((hw->bus_width == e1000_bus_width_64) ? "64-bit" : "32-bit"));
 
-	printk("%pM\n", netdev->dev_addr);
-
-	/* reset the hardware with the new settings */
-	e1000_reset(adapter);
-
-	strcpy(netdev->name, "eth%d");
-	err = register_netdev(netdev);
-	if (err)
-		goto err_register;
+	e_info("%pM\n", netdev->dev_addr);
 
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
-	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
+	e_info("Intel(R) PRO/1000 Network Connection\n");
 
 	cards_found++;
 	return 0;
@@ -1158,7 +1160,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	/* identify the MAC */
 
 	if (e1000_set_mac_type(hw)) {
-		DPRINTK(PROBE, ERR, "Unknown MAC Type\n");
+		e_err("Unknown MAC Type\n");
 		return -EIO;
 	}
 
@@ -1191,7 +1193,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	adapter->num_rx_queues = 1;
 
 	if (e1000_alloc_queues(adapter)) {
-		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
+		e_err("Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
 
@@ -1385,8 +1387,7 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	size = sizeof(struct e1000_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if (!txdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the transmit descriptor ring\n");
+		e_err("Unable to allocate memory for the Tx descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -1401,8 +1402,7 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	if (!txdr->desc) {
 setup_tx_desc_die:
 		vfree(txdr->buffer_info);
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the transmit descriptor ring\n");
+		e_err("Unable to allocate memory for the Tx descriptor ring\n");
 		return -ENOMEM;
 	}
 
@@ -1410,8 +1410,8 @@ setup_tx_desc_die:
 	if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
 		void *olddesc = txdr->desc;
 		dma_addr_t olddma = txdr->dma;
-		DPRINTK(TX_ERR, ERR, "txdr align check failed: %u bytes "
-				     "at %p\n", txdr->size, txdr->desc);
+		e_err("txdr align check failed: %u bytes at %p\n",
+		      txdr->size, txdr->desc);
 		/* Try again, without freeing the previous */
 		txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size,
 						&txdr->dma, GFP_KERNEL);
@@ -1428,9 +1428,8 @@ setup_tx_desc_die:
 					  txdr->dma);
 			dma_free_coherent(&pdev->dev, txdr->size, olddesc,
 					  olddma);
-			DPRINTK(PROBE, ERR,
-				"Unable to allocate aligned memory "
-				"for the transmit descriptor ring\n");
+			e_err("Unable to allocate aligned memory "
+			      "for the transmit descriptor ring\n");
 			vfree(txdr->buffer_info);
 			return -ENOMEM;
 		} else {
@@ -1462,8 +1461,7 @@ int e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = e1000_setup_tx_resources(adapter, &adapter->tx_ring[i]);
 		if (err) {
-			DPRINTK(PROBE, ERR,
-				"Allocation for Tx Queue %u failed\n", i);
+			e_err("Allocation for Tx Queue %u failed\n", i);
 			for (i-- ; i >= 0; i--)
 				e1000_free_tx_resources(adapter,
 							&adapter->tx_ring[i]);
@@ -1583,8 +1581,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	size = sizeof(struct e1000_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if (!rxdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the receive descriptor ring\n");
+		e_err("Unable to allocate memory for the Rx descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -1600,8 +1597,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 					GFP_KERNEL);
 
 	if (!rxdr->desc) {
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the receive descriptor ring\n");
+		e_err("Unable to allocate memory for the Rx descriptor ring\n");
 setup_rx_desc_die:
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
@@ -1611,8 +1607,8 @@ setup_rx_desc_die:
 	if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
 		void *olddesc = rxdr->desc;
 		dma_addr_t olddma = rxdr->dma;
-		DPRINTK(RX_ERR, ERR, "rxdr align check failed: %u bytes "
-				     "at %p\n", rxdr->size, rxdr->desc);
+		e_err("rxdr align check failed: %u bytes at %p\n",
+		      rxdr->size, rxdr->desc);
 		/* Try again, without freeing the previous */
 		rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size,
 						&rxdr->dma, GFP_KERNEL);
@@ -1620,9 +1616,8 @@ setup_rx_desc_die:
 		if (!rxdr->desc) {
 			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
 					  olddma);
-			DPRINTK(PROBE, ERR,
-				"Unable to allocate memory "
-				"for the receive descriptor ring\n");
+			e_err("Unable to allocate memory for the Rx descriptor "
+			      "ring\n");
 			goto setup_rx_desc_die;
 		}
 
@@ -1632,9 +1627,8 @@ setup_rx_desc_die:
 					  rxdr->dma);
 			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
 					  olddma);
-			DPRINTK(PROBE, ERR,
-				"Unable to allocate aligned memory "
-				"for the receive descriptor ring\n");
+			e_err("Unable to allocate aligned memory for the Rx "
+			      "descriptor ring\n");
 			goto setup_rx_desc_die;
 		} else {
 			/* Free old allocation, new allocation was successful */
@@ -1666,8 +1660,7 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		err = e1000_setup_rx_resources(adapter, &adapter->rx_ring[i]);
 		if (err) {
-			DPRINTK(PROBE, ERR,
-				"Allocation for Rx Queue %u failed\n", i);
+			e_err("Allocation for Rx Queue %u failed\n", i);
 			for (i-- ; i >= 0; i--)
 				e1000_free_rx_resources(adapter,
 							&adapter->rx_ring[i]);
@@ -2118,7 +2111,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	u32 *mcarray = kcalloc(mta_reg_count, sizeof(u32), GFP_ATOMIC);
 
 	if (!mcarray) {
-		DPRINTK(PROBE, ERR, "memory allocation failed\n");
+		e_err("memory allocation failed\n");
 		return;
 	}
 
@@ -2314,16 +2307,16 @@ static void e1000_watchdog(unsigned long data)
 			                           &adapter->link_duplex);
 
 			ctrl = er32(CTRL);
-			printk(KERN_INFO "e1000: %s NIC Link is Up %d Mbps %s, "
-			       "Flow Control: %s\n",
-			       netdev->name,
-			       adapter->link_speed,
-			       adapter->link_duplex == FULL_DUPLEX ?
-			        "Full Duplex" : "Half Duplex",
-			        ((ctrl & E1000_CTRL_TFCE) && (ctrl &
-			        E1000_CTRL_RFCE)) ? "RX/TX" : ((ctrl &
-			        E1000_CTRL_RFCE) ? "RX" : ((ctrl &
-			        E1000_CTRL_TFCE) ? "TX" : "None" )));
+			pr_info("%s NIC Link is Up %d Mbps %s, "
+				"Flow Control: %s\n",
+				netdev->name,
+				adapter->link_speed,
+				adapter->link_duplex == FULL_DUPLEX ?
+				"Full Duplex" : "Half Duplex",
+				((ctrl & E1000_CTRL_TFCE) && (ctrl &
+				E1000_CTRL_RFCE)) ? "RX/TX" : ((ctrl &
+				E1000_CTRL_RFCE) ? "RX" : ((ctrl &
+				E1000_CTRL_TFCE) ? "TX" : "None")));
 
 			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
@@ -2353,8 +2346,8 @@ static void e1000_watchdog(unsigned long data)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			printk(KERN_INFO "e1000: %s NIC Link is Down\n",
-			       netdev->name);
+			pr_info("%s NIC Link is Down\n",
+				netdev->name);
 			netif_carrier_off(netdev);
 
 			if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -2644,8 +2637,7 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter,
 		break;
 	default:
 		if (unlikely(net_ratelimit()))
-			DPRINTK(DRV, WARNING,
-			        "checksum_partial proto=%x!\n", skb->protocol);
+			e_warn("checksum_partial proto=%x!\n", skb->protocol);
 		break;
 	}
 
@@ -2989,8 +2981,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				/* fall through */
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
-					DPRINTK(DRV, ERR,
-						"__pskb_pull_tail failed.\n");
+					e_err("__pskb_pull_tail failed.\n");
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;
 				}
@@ -3138,7 +3129,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		DPRINTK(PROBE, ERR, "Invalid MTU setting\n");
+		e_err("Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -3146,7 +3137,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	switch (hw->mac_type) {
 	case e1000_undefined ... e1000_82542_rev2_1:
 		if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
-			DPRINTK(PROBE, ERR, "Jumbo Frames not supported.\n");
+			e_err("Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
 		break;
@@ -3184,8 +3175,8 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))
 		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
-	printk(KERN_INFO "e1000: %s changing MTU from %d to %d\n",
-	       netdev->name, netdev->mtu, new_mtu);
+	pr_info("%s changing MTU from %d to %d\n",
+		netdev->name, netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
 
 	if (netif_running(netdev))
@@ -3498,17 +3489,17 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 
 			/* detected Tx unit hang */
-			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
-					"  Tx Queue             <%lu>\n"
-					"  TDH                  <%x>\n"
-					"  TDT                  <%x>\n"
-					"  next_to_use          <%x>\n"
-					"  next_to_clean        <%x>\n"
-					"buffer_info[next_to_clean]\n"
-					"  time_stamp           <%lx>\n"
-					"  next_to_watch        <%x>\n"
-					"  jiffies              <%lx>\n"
-					"  next_to_watch.status <%x>\n",
+			e_err("Detected Tx Unit Hang\n"
+			      "  Tx Queue             <%lu>\n"
+			      "  TDH                  <%x>\n"
+			      "  TDT                  <%x>\n"
+			      "  next_to_use          <%x>\n"
+			      "  next_to_clean        <%x>\n"
+			      "buffer_info[next_to_clean]\n"
+			      "  time_stamp           <%lx>\n"
+			      "  next_to_watch        <%x>\n"
+			      "  jiffies              <%lx>\n"
+			      "  next_to_watch.status <%x>\n",
 				(unsigned long)((tx_ring - adapter->tx_ring) /
 					sizeof(struct e1000_tx_ring)),
 				readl(hw->hw_addr + tx_ring->tdh),
@@ -3747,7 +3738,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 
 		/* eth type trans needs skb->data to point to something */
 		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			DPRINTK(DRV, ERR, "pskb_may_pull failed.\n");
+			e_err("pskb_may_pull failed.\n");
 			dev_kfree_skb(skb);
 			goto next_desc;
 		}
@@ -3847,8 +3838,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		if (adapter->discarding) {
 			/* All receives must fit into a single buffer */
-			E1000_DBG("%s: Receive packet consumed multiple"
-				  " buffers\n", netdev->name);
+			e_info("Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
 			if (status & E1000_RXD_STAT_EOP)
@@ -3978,8 +3968,8 @@ e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb = skb;
-			DPRINTK(PROBE, ERR, "skb align check failed: %u bytes "
-					     "at %p\n", bufsz, skb->data);
+			e_err("skb align check failed: %u bytes at %p\n",
+			      bufsz, skb->data);
 			/* Try again, without freeing the previous */
 			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
 			/* Failed allocation, critical failure */
@@ -4087,8 +4077,8 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb = skb;
-			DPRINTK(RX_ERR, ERR, "skb align check failed: %u bytes "
-					     "at %p\n", bufsz, skb->data);
+			e_err("skb align check failed: %u bytes at %p\n",
+			      bufsz, skb->data);
 			/* Try again, without freeing the previous */
 			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
 			/* Failed allocation, critical failure */
@@ -4133,10 +4123,9 @@ map_skb:
 		if (!e1000_check_64k_bound(adapter,
 					(void *)(unsigned long)buffer_info->dma,
 					adapter->rx_buffer_len)) {
-			DPRINTK(RX_ERR, ERR,
-				"dma align check failed: %u bytes at %p\n",
-				adapter->rx_buffer_len,
-				(void *)(unsigned long)buffer_info->dma);
+			e_err("dma align check failed: %u bytes at %p\n",
+			      adapter->rx_buffer_len,
+			      (void *)(unsigned long)buffer_info->dma);
 			dev_kfree_skb(skb);
 			buffer_info->skb = NULL;
 
@@ -4348,7 +4337,7 @@ void e1000_pci_set_mwi(struct e1000_hw *hw)
 	int ret_val = pci_set_mwi(adapter->pdev);
 
 	if (ret_val)
-		DPRINTK(PROBE, ERR, "Error in setting MWI\n");
+		e_err("Error in setting MWI\n");
 }
 
 void e1000_pci_clear_mwi(struct e1000_hw *hw)
@@ -4479,7 +4468,7 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((hw->media_type == e1000_media_type_fiber) &&
 		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		DPRINTK(PROBE, ERR, "Unsupported Speed/Duplex configuration\n");
+		e_err("Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 
@@ -4502,7 +4491,7 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		DPRINTK(PROBE, ERR, "Unsupported Speed/Duplex configuration\n");
+		e_err("Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -4625,7 +4614,7 @@ static int e1000_resume(struct pci_dev *pdev)
 	else
 		err = pci_enable_device_mem(pdev);
 	if (err) {
-		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
+		pr_err("Cannot enable PCI device from suspend\n");
 		return err;
 	}
 	pci_set_master(pdev);
@@ -4728,7 +4717,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	else
 		err = pci_enable_device_mem(pdev);
 	if (err) {
-		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n");
+		pr_err("Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -4759,7 +4748,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		if (e1000_up(adapter)) {
-			printk("e1000: can't bring device back up after reset\n");
+			pr_info("can't bring device back up after reset\n");
 			return;
 		}
 	}
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index d929852..edd1c75 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -41,20 +41,6 @@
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 
-#ifdef DBG
-#define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
-#define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)
-#else
-#define DEBUGOUT(S)
-#define DEBUGOUT1(S, A...)
-#endif
-
-#define DEBUGFUNC(F) DEBUGOUT(F "\n")
-#define DEBUGOUT2 DEBUGOUT1
-#define DEBUGOUT3 DEBUGOUT2
-#define DEBUGOUT7 DEBUGOUT3
-
-
 #define er32(reg)							\
 	(readl(hw->hw_addr + ((hw->mac_type >= e1000_82543)		\
 			       ? E1000_##reg : E1000_82542_##reg)))
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 38d2741..543c6d1 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -226,17 +226,16 @@ static int __devinit e1000_validate_option(unsigned int *value,
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			DPRINTK(PROBE, INFO, "%s Enabled\n", opt->name);
+			e_dev_info("%s Enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			DPRINTK(PROBE, INFO, "%s Disabled\n", opt->name);
+			e_dev_info("%s Disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			DPRINTK(PROBE, INFO,
-					"%s set to %i\n", opt->name, *value);
+			e_dev_info("%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
@@ -248,7 +247,7 @@ static int __devinit e1000_validate_option(unsigned int *value,
 			ent = &opt->arg.l.p[i];
 			if (*value == ent->i) {
 				if (ent->str[0] != '\0')
-					DPRINTK(PROBE, INFO, "%s\n", ent->str);
+					e_dev_info("%s\n", ent->str);
 				return 0;
 			}
 		}
@@ -258,7 +257,7 @@ static int __devinit e1000_validate_option(unsigned int *value,
 		BUG();
 	}
 
-	DPRINTK(PROBE, INFO, "Invalid %s value specified (%i) %s\n",
+	e_dev_info("Invalid %s value specified (%i) %s\n",
 	       opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
@@ -283,9 +282,8 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 	int bd = adapter->bd_number;
 
 	if (bd >= E1000_MAX_NIC) {
-		DPRINTK(PROBE, NOTICE,
-		       "Warning: no configuration for board #%i\n", bd);
-		DPRINTK(PROBE, NOTICE, "Using defaults for all values\n");
+		e_dev_warn("Warning: no configuration for board #%i "
+			   "using defaults for all values\n", bd);
 	}
 
 	{ /* Transmit Descriptor Count */
@@ -472,19 +470,17 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 			adapter->itr = InterruptThrottleRate[bd];
 			switch (adapter->itr) {
 			case 0:
-				DPRINTK(PROBE, INFO, "%s turned off\n",
-				        opt.name);
+				e_dev_info("%s turned off\n", opt.name);
 				break;
 			case 1:
-				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
-					opt.name);
+				e_dev_info("%s set to dynamic mode\n",
+					   opt.name);
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
 				break;
 			case 3:
-				DPRINTK(PROBE, INFO,
-				        "%s set to dynamic conservative mode\n",
-					opt.name);
+				e_dev_info("%s set to dynamic conservative "
+					   "mode\n", opt.name);
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
 				break;
@@ -543,19 +539,18 @@ static void __devinit e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (num_Speed > bd) {
-		DPRINTK(PROBE, INFO, "Speed not valid for fiber adapters, "
-		       "parameter ignored\n");
+		e_dev_info("Speed not valid for fiber adapters, parameter "
+			   "ignored\n");
 	}
 
 	if (num_Duplex > bd) {
-		DPRINTK(PROBE, INFO, "Duplex not valid for fiber adapters, "
-		       "parameter ignored\n");
+		e_dev_info("Duplex not valid for fiber adapters, parameter "
+			   "ignored\n");
 	}
 
 	if ((num_AutoNeg > bd) && (AutoNeg[bd] != 0x20)) {
-		DPRINTK(PROBE, INFO, "AutoNeg other than 1000/Full is "
-				 "not valid for fiber adapters, "
-				 "parameter ignored\n");
+		e_dev_info("AutoNeg other than 1000/Full is not valid for fiber"
+			   "adapters, parameter ignored\n");
 	}
 }
 
@@ -619,9 +614,8 @@ static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 	}
 
 	if ((num_AutoNeg > bd) && (speed != 0 || dplx != 0)) {
-		DPRINTK(PROBE, INFO,
-		       "AutoNeg specified along with Speed or Duplex, "
-		       "parameter ignored\n");
+		e_dev_info("AutoNeg specified along with Speed or Duplex, "
+			   "parameter ignored\n");
 		adapter->hw.autoneg_advertised = AUTONEG_ADV_DEFAULT;
 	} else { /* Autoneg */
 		static const struct e1000_opt_list an_list[] =
@@ -680,79 +674,72 @@ static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 	case 0:
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		if ((num_Speed > bd) && (speed != 0 || dplx != 0))
-			DPRINTK(PROBE, INFO,
-			       "Speed and duplex autonegotiation enabled\n");
+			e_dev_info("Speed and duplex autonegotiation "
+				   "enabled\n");
 		break;
 	case HALF_DUPLEX:
-		DPRINTK(PROBE, INFO, "Half Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
-			"Half Duplex only\n");
+		e_dev_info("Half Duplex specified without Speed\n");
+		e_dev_info("Using Autonegotiation at Half Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_100_HALF;
 		break;
 	case FULL_DUPLEX:
-		DPRINTK(PROBE, INFO, "Full Duplex specified without Speed\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
-			"Full Duplex only\n");
+		e_dev_info("Full Duplex specified without Speed\n");
+		e_dev_info("Using Autonegotiation at Full Duplex only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
 		                                 ADVERTISE_100_FULL |
 		                                 ADVERTISE_1000_FULL;
 		break;
 	case SPEED_10:
-		DPRINTK(PROBE, INFO, "10 Mbps Speed specified "
-			"without Duplex\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at 10 Mbps only\n");
+		e_dev_info("10 Mbps Speed specified without Duplex\n");
+		e_dev_info("Using Autonegotiation at 10 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
 		                                 ADVERTISE_10_FULL;
 		break;
 	case SPEED_10 + HALF_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Half Duplex\n");
+		e_dev_info("Forcing to 10 Mbps Half Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_10_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_10 + FULL_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Full Duplex\n");
+		e_dev_info("Forcing to 10 Mbps Full Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_10_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
-		DPRINTK(PROBE, INFO, "100 Mbps Speed specified "
-			"without Duplex\n");
-		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
-			"100 Mbps only\n");
+		e_dev_info("100 Mbps Speed specified without Duplex\n");
+		e_dev_info("Using Autonegotiation at 100 Mbps only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
 		                                 ADVERTISE_100_FULL;
 		break;
 	case SPEED_100 + HALF_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Half Duplex\n");
+		e_dev_info("Forcing to 100 Mbps Half Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_100_half;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_100 + FULL_DUPLEX:
-		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Full Duplex\n");
+		e_dev_info("Forcing to 100 Mbps Full Duplex\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 0;
 		adapter->hw.forced_speed_duplex = e1000_100_full;
 		adapter->hw.autoneg_advertised = 0;
 		break;
 	case SPEED_1000:
-		DPRINTK(PROBE, INFO, "1000 Mbps Speed specified without "
-			"Duplex\n");
+		e_dev_info("1000 Mbps Speed specified without Duplex\n");
 		goto full_duplex_only;
 	case SPEED_1000 + HALF_DUPLEX:
-		DPRINTK(PROBE, INFO,
-			"Half Duplex is not supported at 1000 Mbps\n");
+		e_dev_info("Half Duplex is not supported at 1000 Mbps\n");
 		/* fall through */
 	case SPEED_1000 + FULL_DUPLEX:
 full_duplex_only:
-		DPRINTK(PROBE, INFO,
-		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
+		e_dev_info("Using Autonegotiation at 1000 Mbps Full Duplex "
+			   "only\n");
 		adapter->hw.autoneg = adapter->fc_autoneg = 1;
 		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
@@ -762,9 +749,8 @@ full_duplex_only:
 
 	/* Speed, AutoNeg and MDI/MDI-X must all play nice */
 	if (e1000_validate_mdi_setting(&(adapter->hw)) < 0) {
-		DPRINTK(PROBE, INFO,
-			"Speed, AutoNeg and MDI-X specifications are "
-			"incompatible. Setting MDI-X to a compatible value.\n");
+		e_dev_info("Speed, AutoNeg and MDI-X specs are incompatible. "
+			   "Setting MDI-X to a compatible value.\n");
 	}
 }
 

