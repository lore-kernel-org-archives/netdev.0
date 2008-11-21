From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] igb: do not use phy ops in ethtool test cleanup for
	non-copper parts
Date: Fri, 21 Nov 2008 15:59:12 -0800
Message-ID: <20081121235912.2150.53268.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:48858 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753299AbYKUX7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 18:59:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Currently the igb driver is experiencing a panic due to a null function
pointer being used during the cleanup of the ethtool looback test on
fiber/serdes parts.  This patch prevents that and adds a check prior to
calling any phy function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |   32 ++++++++++++++++++++++++++++++++
 drivers/net/igb/igb_ethtool.c |   20 ++++++++++----------
 drivers/net/igb/igb_main.c    |   20 ++++++++------------
 3 files changed, 50 insertions(+), 22 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index acf2569..2121b8b 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -332,4 +332,36 @@ extern void igb_free_rx_resources(struct igb_ring *);
 extern void igb_update_stats(struct igb_adapter *);
 extern void igb_set_ethtool_ops(struct net_device *);
 
+static inline s32 igb_reset_phy(struct e1000_hw *hw)
+{
+	if (hw->phy.ops.reset_phy)
+		return hw->phy.ops.reset_phy(hw);
+
+	return 0;
+}
+
+static inline s32 igb_read_phy_reg(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	if (hw->phy.ops.read_phy_reg)
+		return hw->phy.ops.read_phy_reg(hw, offset, data);
+
+	return 0;
+}
+
+static inline s32 igb_write_phy_reg(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	if (hw->phy.ops.write_phy_reg)
+		return hw->phy.ops.write_phy_reg(hw, offset, data);
+
+	return 0;
+}
+
+static inline s32 igb_get_phy_info(struct e1000_hw *hw)
+{
+	if (hw->phy.ops.get_phy_info)
+		return hw->phy.ops.get_phy_info(hw);
+
+	return 0;
+}
+
 #endif /* _IGB_H_ */
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index a661159..8e9d295 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1376,10 +1376,10 @@ static void igb_phy_disable_receiver(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	/* Write out to PHY registers 29 and 30 to disable the Receiver. */
-	hw->phy.ops.write_phy_reg(hw, 29, 0x001F);
-	hw->phy.ops.write_phy_reg(hw, 30, 0x8FFC);
-	hw->phy.ops.write_phy_reg(hw, 29, 0x001A);
-	hw->phy.ops.write_phy_reg(hw, 30, 0x8FF0);
+	igb_write_phy_reg(hw, 29, 0x001F);
+	igb_write_phy_reg(hw, 30, 0x8FFC);
+	igb_write_phy_reg(hw, 29, 0x001A);
+	igb_write_phy_reg(hw, 30, 0x8FF0);
 }
 
 static int igb_integrated_phy_loopback(struct igb_adapter *adapter)
@@ -1392,17 +1392,17 @@ static int igb_integrated_phy_loopback(struct igb_adapter *adapter)
 
 	if (hw->phy.type == e1000_phy_m88) {
 		/* Auto-MDI/MDIX Off */
-		hw->phy.ops.write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, 0x0808);
+		igb_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, 0x0808);
 		/* reset to update Auto-MDI/MDIX */
-		hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, 0x9140);
+		igb_write_phy_reg(hw, PHY_CONTROL, 0x9140);
 		/* autoneg off */
-		hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, 0x8140);
+		igb_write_phy_reg(hw, PHY_CONTROL, 0x8140);
 	}
 
 	ctrl_reg = rd32(E1000_CTRL);
 
 	/* force 1000, set loopback */
-	hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, 0x4140);
+	igb_write_phy_reg(hw, PHY_CONTROL, 0x4140);
 
 	/* Now set up the MAC to the same speed/duplex as the PHY. */
 	ctrl_reg = rd32(E1000_CTRL);
@@ -1496,10 +1496,10 @@ static void igb_loopback_cleanup(struct igb_adapter *adapter)
 	wr32(E1000_RCTL, rctl);
 
 	hw->mac.autoneg = true;
-	hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &phy_reg);
+	igb_read_phy_reg(hw, PHY_CONTROL, &phy_reg);
 	if (phy_reg & MII_CR_LOOPBACK) {
 		phy_reg &= ~MII_CR_LOOPBACK;
-		hw->phy.ops.write_phy_reg(hw, PHY_CONTROL, phy_reg);
+		igb_write_phy_reg(hw, PHY_CONTROL, phy_reg);
 		igb_phy_sw_reset(hw);
 	}
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index eca5684..b64c41a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -931,8 +931,7 @@ void igb_reset(struct igb_adapter *adapter)
 	wr32(E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	igb_reset_adaptive(&adapter->hw);
-	if (adapter->hw.phy.ops.get_phy_info)
-		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	igb_get_phy_info(&adapter->hw);
 }
 
 /**
@@ -1305,7 +1304,7 @@ err_register:
 	igb_release_hw_control(adapter);
 err_eeprom:
 	if (!igb_check_reset_block(hw))
-		hw->phy.ops.reset_phy(hw);
+		igb_reset_phy(hw);
 
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
@@ -1365,9 +1364,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
-	if (adapter->hw.phy.ops.reset_phy &&
-	    !igb_check_reset_block(&adapter->hw))
-		adapter->hw.phy.ops.reset_phy(&adapter->hw);
+	if (!igb_check_reset_block(&adapter->hw))
+		igb_reset_phy(&adapter->hw);
 
 	igb_remove_device(&adapter->hw);
 	igb_reset_interrupt_capability(adapter);
@@ -2283,8 +2281,7 @@ static void igb_set_multi(struct net_device *netdev)
 static void igb_update_phy_info(unsigned long data)
 {
 	struct igb_adapter *adapter = (struct igb_adapter *) data;
-	if (adapter->hw.phy.ops.get_phy_info)
-		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	igb_get_phy_info(&adapter->hw);
 }
 
 /**
@@ -3258,7 +3255,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	/* Phy Stats */
 	if (hw->phy.media_type == e1000_media_type_copper) {
 		if ((adapter->link_speed == SPEED_1000) &&
-		   (!hw->phy.ops.read_phy_reg(hw, PHY_1000T_STATUS,
+		   (!igb_read_phy_reg(hw, PHY_1000T_STATUS,
 					      &phy_tmp))) {
 			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
 			adapter->phy_stats.idle_errors += phy_tmp;
@@ -4111,9 +4108,8 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (adapter->hw.phy.ops.read_phy_reg(&adapter->hw,
-						     data->reg_num
-						     & 0x1F, &data->val_out))
+		if (igb_read_phy_reg(&adapter->hw, data->reg_num & 0x1F,
+		                     &data->val_out))
 			return -EIO;
 		break;
 	case SIOCSMIIREG:

