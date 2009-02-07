From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 06/26] igb: make dev_spec a union and remove dynamic
	allocation
Date: Sat, 07 Feb 2009 01:16:45 -0800
Message-ID: <20090207091645.15697.48924.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:40098
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752483AbZBGJRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:17:07 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch makes dev_spec a union and simplifies it so that it does not
require dynamic allocation and freeing in the driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   34 +++++-----------------------------
 drivers/net/igb/e1000_hw.h    |    9 +++++++--
 drivers/net/igb/e1000_mac.c   |   13 -------------
 drivers/net/igb/e1000_mac.h   |    1 -
 drivers/net/igb/igb_main.c    |    2 --
 5 files changed, 12 insertions(+), 47 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f5e4cad..ed9e8c0 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -62,17 +62,12 @@ static bool igb_sgmii_active_82575(struct e1000_hw *);
 static s32  igb_reset_init_script_82575(struct e1000_hw *);
 static s32  igb_read_mac_addr_82575(struct e1000_hw *);
 
-
-struct e1000_dev_spec_82575 {
-	bool sgmii_active;
-};
-
 static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	struct e1000_mac_info *mac = &hw->mac;
-	struct e1000_dev_spec_82575 *dev_spec;
+	struct e1000_dev_spec_82575 * dev_spec = &hw->dev_spec._82575;
 	u32 eecd;
 	s32 ret_val;
 	u16 size;
@@ -94,17 +89,6 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		break;
 	}
 
-	/* MAC initialization */
-	hw->dev_spec_size = sizeof(struct e1000_dev_spec_82575);
-
-	/* Device-specific structure allocation */
-	hw->dev_spec = kzalloc(hw->dev_spec_size, GFP_KERNEL);
-
-	if (!hw->dev_spec)
-		return -ENOMEM;
-
-	dev_spec = (struct e1000_dev_spec_82575 *)hw->dev_spec;
-
 	/* Set media type */
 	/*
 	 * The 82575 uses bits 22:23 for link mode. The mode can be changed
@@ -1234,20 +1218,12 @@ out:
  **/
 static bool igb_sgmii_active_82575(struct e1000_hw *hw)
 {
-	struct e1000_dev_spec_82575 *dev_spec;
-	bool ret_val;
+	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
 
-	if (hw->mac.type != e1000_82575) {
-		ret_val = false;
-		goto out;
-	}
-
-	dev_spec = (struct e1000_dev_spec_82575 *)hw->dev_spec;
+	if (hw->mac.type != e1000_82575 && hw->mac.type != e1000_82576)
+		return false;
 
-	ret_val = dev_spec->sgmii_active;
-
-out:
-	return ret_val;
+	return dev_spec->sgmii_active;
 }
 
 /**
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 99504a6..06f72ae 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -565,9 +565,12 @@ struct e1000_fc_info {
 	enum e1000_fc_type original_type;
 };
 
+struct e1000_dev_spec_82575 {
+	bool sgmii_active;
+};
+
 struct e1000_hw {
 	void *back;
-	void *dev_spec;
 
 	u8 __iomem *hw_addr;
 	u8 __iomem *flash_address;
@@ -580,7 +583,9 @@ struct e1000_hw {
 	struct e1000_bus_info  bus;
 	struct e1000_host_mng_dhcp_cookie mng_cookie;
 
-	u32 dev_spec_size;
+	union {
+		struct e1000_dev_spec_82575	_82575;
+	} dev_spec;
 
 	u16 device_id;
 	u16 subsystem_vendor_id;
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 97f0049..16fa083 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -37,19 +37,6 @@
 static s32 igb_set_default_fc(struct e1000_hw *hw);
 static s32 igb_set_fc_watermarks(struct e1000_hw *hw);
 
-/**
- *  igb_remove_device - Free device specific structure
- *  @hw: pointer to the HW structure
- *
- *  If a device specific structure was allocated, this function will
- *  free it.
- **/
-void igb_remove_device(struct e1000_hw *hw)
-{
-	/* Freeing the dev_spec member of e1000_hw structure */
-	kfree(hw->dev_spec);
-}
-
 static s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 {
 	struct igb_adapter *adapter = hw->back;
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index cbee6af..4ef40d5 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -63,7 +63,6 @@ void igb_mta_set(struct e1000_hw *hw, u32 hash_value);
 void igb_put_hw_semaphore(struct e1000_hw *hw);
 void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index);
 s32  igb_check_alt_mac_addr(struct e1000_hw *hw);
-void igb_remove_device(struct e1000_hw *hw);
 void igb_reset_adaptive(struct e1000_hw *hw);
 void igb_update_adaptive(struct e1000_hw *hw);
 void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b59088e..cb3ac34 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1329,7 +1329,6 @@ err_eeprom:
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
 
-	igb_remove_device(hw);
 	igb_free_queues(adapter);
 err_sw_init:
 err_hw_init:
@@ -1389,7 +1388,6 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	if (!igb_check_reset_block(&adapter->hw))
 		igb_reset_phy(&adapter->hw);
 
-	igb_remove_device(&adapter->hw);
 	igb_reset_interrupt_capability(adapter);
 
 	igb_free_queues(adapter);

