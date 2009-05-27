From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] ixgbe: fix driver loading with unsupported
	module on 82598
Date: Tue, 26 May 2009 17:54:24 -0700
Message-ID: <20090527005423.28535.1960.stgit@localhost.localdomain>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:52505
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754658AbZE0Aym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 20:54:42 -0400
In-Reply-To: <20090527005403.28535.8727.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Driver loads even when an unsupported module inserted. This was
caused by mdio45_probe not returning all the information we needed.
The fix is to replace that call with the new
ixgbe_validate_phy_addr().

We will now need to store the phy address which we do in the hw->phy
struct. Likewise we no longer need the mdio struct in hw->phy along
with the mdio functions ixgbe_mdio_write(read) which have been
removed.  ixgbe_ioctl was no longer used and referenced hw->phy.mdio
so it was also removed.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   42 ----------------------------------------
 drivers/net/ixgbe/ixgbe_phy.c  |   32 ++++++++++++++++++++++++------
 drivers/net/ixgbe/ixgbe_phy.h  |    1 +
 drivers/net/ixgbe/ixgbe_type.h |    5 ++++-
 5 files changed, 31 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 05a2405..0f396d2 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -394,6 +394,7 @@ extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_write_eitr(struct ixgbe_adapter *, int, u32);
+extern int ethtool_ioctl(struct ifreq *ifr);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f9223ac..373cdc7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4914,40 +4914,6 @@ static int ixgbe_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
-static int
-ixgbe_mdio_read(struct net_device *netdev, int prtad, int devad, u16 addr)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-	u16 value;
-	int rc;
-
-	if (prtad != hw->phy.mdio.prtad)
-		return -EINVAL;
-	rc = hw->phy.ops.read_reg(hw, addr, devad, &value);
-	if (!rc)
-		rc = value;
-	return rc;
-}
-
-static int ixgbe_mdio_write(struct net_device *netdev, int prtad, int devad,
-			    u16 addr, u16 value)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	if (prtad != hw->phy.mdio.prtad)
-		return -EINVAL;
-	return hw->phy.ops.write_reg(hw, addr, devad, value);
-}
-
-static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
-}
-
 /**
  * ixgbe_add_sanmac_netdev - Add the SAN MAC address to the corresponding
  * netdev->dev_addr_list
@@ -5023,7 +4989,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_vlan_rx_register	= ixgbe_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ixgbe_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbe_vlan_rx_kill_vid,
-	.ndo_do_ioctl		= ixgbe_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
@@ -5146,13 +5111,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* PHY */
 	memcpy(&hw->phy.ops, ii->phy_ops, sizeof(hw->phy.ops));
 	hw->phy.sfp_type = ixgbe_sfp_type_unknown;
-	/* ixgbe_identify_phy_generic will set prtad and mmds properly */
-	hw->phy.mdio.prtad = MDIO_PRTAD_NONE;
-	hw->phy.mdio.mmds = 0;
-	hw->phy.mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
-	hw->phy.mdio.dev = netdev;
-	hw->phy.mdio.mdio_read = ixgbe_mdio_read;
-	hw->phy.mdio.mdio_write = ixgbe_mdio_write;
 
 	/* set up this timer and work struct before calling get_invariants
 	 * which might start the timer
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index e43d624..2e87989 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -60,7 +60,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 
 	if (hw->phy.type == ixgbe_phy_unknown) {
 		for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
-			if (mdio45_probe(&hw->phy.mdio, phy_addr) == 0) {
+			if (ixgbe_validate_phy_addr(hw, phy_addr)) {
 				ixgbe_get_phy_id(hw);
 				hw->phy.type =
 				        ixgbe_get_phy_type_from_id(hw->phy.id);
@@ -76,6 +76,26 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_validate_phy_addr - Determines phy address is valid
+ *  @hw: pointer to hardware structure
+ *
+ **/
+bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr)
+{
+	u16 phy_id = 0;
+	bool valid = false;
+
+	hw->phy.addr = phy_addr;
+	hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_HIGH,
+			     IXGBE_MDIO_PMA_PMD_DEV_TYPE, &phy_id);
+
+	if (phy_id != 0xFFFF && phy_id != 0x0)
+		valid = true;
+
+	return valid;
+}
+
+/**
  *  ixgbe_get_phy_id - Get the phy type
  *  @hw: pointer to hardware structure
  *
@@ -167,7 +187,7 @@ s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-		           (hw->phy.mdio.prtad << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
 		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
@@ -198,8 +218,7 @@ s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			           (hw->phy.mdio.prtad <<
-				    IXGBE_MSCA_PHY_ADDR_SHIFT) |
+				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
 			           (IXGBE_MSCA_READ | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
@@ -268,7 +287,7 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-		           (hw->phy.mdio.prtad << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
 		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
@@ -299,8 +318,7 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			           (hw->phy.mdio.prtad <<
-				    IXGBE_MSCA_PHY_ADDR_SHIFT) |
+				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
 			           (IXGBE_MSCA_WRITE | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 9b700f5..5f76c9c 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -79,6 +79,7 @@
 
 
 s32 ixgbe_init_phy_ops_generic(struct ixgbe_hw *hw);
+bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr);
 s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw);
 s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw);
 s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index ba3ed0f..00c23be 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -915,6 +915,7 @@
 #define IXGBE_CORECTL_WRITE_CMD         0x00010000
 
 /* MDIO definitions */
+#define IXGBE_MDIO_PMA_PMD_DEV_TYPE    0x1
 
 #define IXGBE_MDIO_COMMAND_TIMEOUT     100 /* PHY Timeout for 1 GB mode */
 
@@ -925,6 +926,8 @@
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_10G_SPEED    0x0018
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_1G_SPEED     0x0010
 
+#define IXGBE_MDIO_PHY_ID_HIGH              0x2    /* PHY ID High Reg */
+
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR     0xC30A /* PHY_XS SDA/SCL Addr Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA     0xC30B /* PHY_XS SDA/SCL Data Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_STAT     0xC30C /* PHY_XS SDA/SCL Status Reg */
@@ -2286,8 +2289,8 @@ struct ixgbe_mac_info {
 
 struct ixgbe_phy_info {
 	struct ixgbe_phy_operations     ops;
-	struct mdio_if_info		mdio;
 	enum ixgbe_phy_type             type;
+	u32                             addr;
 	u32                             id;
 	enum ixgbe_sfp_type             sfp_type;
 	bool                            sfp_setup_needed;

