From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] e1000e: provide MAC-family-specific function
	to set LAN ID
Date: Wed, 13 Jan 2010 04:05:18 -0800
Message-ID: <20100113120516.23715.960.stgit@localhost.localdomain>
References: <20100113120416.23715.64354.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:45136
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752192Ab0AMMFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 07:05:37 -0500
In-Reply-To: <20100113120416.23715.64354.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Provide MAC-specific function pointer to determine the LAN ID (PCI func).
The LAN ID is used internally by the driver to determine which h/w lock
to use to protect accessing the PHY on ESB2 as well as help to determine
the alternate MAC address on some parts.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    7 ++++++
 drivers/net/e1000e/e1000.h   |    2 ++
 drivers/net/e1000e/es2lan.c  |    4 ++++
 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |    1 +
 drivers/net/e1000e/lib.c     |   48 ++++++++++++++++++++++++++++++++----------
 6 files changed, 52 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index d1a4514..7674a91 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -267,8 +267,14 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	}
 
 	switch (hw->mac.type) {
+	case e1000_82573:
+		func->set_lan_id = e1000_set_lan_id_single_port;
+		func->check_mng_mode = e1000e_check_mng_mode_generic;
+		func->led_on = e1000e_led_on_generic;
+		break;
 	case e1000_82574:
 	case e1000_82583:
+		func->set_lan_id = e1000_set_lan_id_single_port;
 		func->check_mng_mode = e1000_check_mng_mode_82574;
 		func->led_on = e1000_led_on_82574;
 		break;
@@ -1721,6 +1727,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
 	.cleanup_led		= e1000e_cleanup_led_generic,
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_82571,
 	.get_bus_info		= e1000e_get_bus_info_pcie,
+	.set_lan_id		= e1000_set_lan_id_multi_port_pcie,
 	/* .get_link_up_info: media type dependent */
 	/* .led_on: mac type dependent */
 	.led_off		= e1000e_led_off_generic,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index f0cdf35..8e6251e 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -502,6 +502,8 @@ extern s32 e1000e_cleanup_led_generic(struct e1000_hw *hw);
 extern s32 e1000e_led_on_generic(struct e1000_hw *hw);
 extern s32 e1000e_led_off_generic(struct e1000_hw *hw);
 extern s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw);
+extern void e1000_set_lan_id_multi_port_pcie(struct e1000_hw *hw);
+extern void e1000_set_lan_id_single_port(struct e1000_hw *hw);
 extern s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex);
 extern s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex);
 extern s32 e1000e_disable_pcie_master(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 4bb9d88..27d2158 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -246,6 +246,9 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 		break;
 	}
 
+	/* set lan id for port to determine which phy lock to use */
+	hw->mac.ops.set_lan_id(hw);
+
 	return 0;
 }
 
@@ -1435,6 +1438,7 @@ static struct e1000_mac_operations es2_mac_ops = {
 	.cleanup_led		= e1000e_cleanup_led_generic,
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_80003es2lan,
 	.get_bus_info		= e1000e_get_bus_info_pcie,
+	.set_lan_id		= e1000_set_lan_id_multi_port_pcie,
 	.get_link_up_info	= e1000_get_link_up_info_80003es2lan,
 	.led_on			= e1000e_led_on_generic,
 	.led_off		= e1000e_led_off_generic,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 127e6a2..9cac5d9 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -749,6 +749,7 @@ struct e1000_mac_operations {
 	void (*clear_hw_cntrs)(struct e1000_hw *);
 	void (*clear_vfta)(struct e1000_hw *);
 	s32  (*get_bus_info)(struct e1000_hw *);
+	void (*set_lan_id)(struct e1000_hw *);
 	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
 	s32  (*led_on)(struct e1000_hw *);
 	s32  (*led_off)(struct e1000_hw *);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8b6ecd1..54d03a0 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3368,6 +3368,7 @@ static struct e1000_mac_operations ich8_mac_ops = {
 	/* cleanup_led dependent on mac type */
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_ich8lan,
 	.get_bus_info		= e1000_get_bus_info_ich8lan,
+	.set_lan_id		= e1000_set_lan_id_single_port,
 	.get_link_up_info	= e1000_get_link_up_info_ich8lan,
 	/* led_on dependent on mac type */
 	/* led_off dependent on mac type */
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 5475424..5f6b171 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -51,10 +51,10 @@ enum e1000_mng_mode {
  **/
 s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw)
 {
+	struct e1000_mac_info *mac = &hw->mac;
 	struct e1000_bus_info *bus = &hw->bus;
 	struct e1000_adapter *adapter = hw->adapter;
-	u32 status;
-	u16 pcie_link_status, pci_header_type, cap_offset;
+	u16 pcie_link_status, cap_offset;
 
 	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
 	if (!cap_offset) {
@@ -68,20 +68,46 @@ s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw)
 						    PCIE_LINK_WIDTH_SHIFT);
 	}
 
-	pci_read_config_word(adapter->pdev, PCI_HEADER_TYPE_REGISTER,
-			     &pci_header_type);
-	if (pci_header_type & PCI_HEADER_TYPE_MULTIFUNC) {
-		status = er32(STATUS);
-		bus->func = (status & E1000_STATUS_FUNC_MASK)
-			    >> E1000_STATUS_FUNC_SHIFT;
-	} else {
-		bus->func = 0;
-	}
+	mac->ops.set_lan_id(hw);
 
 	return 0;
 }
 
 /**
+ *  e1000_set_lan_id_multi_port_pcie - Set LAN id for PCIe multiple port devices
+ *
+ *  @hw: pointer to the HW structure
+ *
+ *  Determines the LAN function id by reading memory-mapped registers
+ *  and swaps the port value if requested.
+ **/
+void e1000_set_lan_id_multi_port_pcie(struct e1000_hw *hw)
+{
+	struct e1000_bus_info *bus = &hw->bus;
+	u32 reg;
+
+	/*
+	 * The status register reports the correct function number
+	 * for the device regardless of function swap state.
+	 */
+	reg = er32(STATUS);
+	bus->func = (reg & E1000_STATUS_FUNC_MASK) >> E1000_STATUS_FUNC_SHIFT;
+}
+
+/**
+ *  e1000_set_lan_id_single_port - Set LAN id for a single port device
+ *  @hw: pointer to the HW structure
+ *
+ *  Sets the LAN function id to zero for a single port device.
+ **/
+void e1000_set_lan_id_single_port(struct e1000_hw *hw)
+{
+	struct e1000_bus_info *bus = &hw->bus;
+
+	bus->func = 0;
+}
+
+/**
  *  e1000_clear_vfta_generic - Clear VLAN filter table
  *  @hw: pointer to the HW structure
  *

