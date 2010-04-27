From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Power down PHY during driver resets
Date: Tue, 27 Apr 2010 03:38:15 -0700
Message-ID: <20100427103814.23338.47637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:46636
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754349Ab0D0Kid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 06:38:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The PHY laser is still on during driver init.  It's allowing
garbage to hit our FIFO, which eventually can cause the entire
device to die.  Power down the laser while setting up the device,
and re-enable the laser before getting link.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   62 ++++++++++++++++++++++++++++++---------
 drivers/net/ixgbe/ixgbe_main.c  |   22 ++++++++------
 drivers/net/ixgbe/ixgbe_type.h  |    2 +
 3 files changed, 62 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 217237c..78da45d 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -39,6 +39,8 @@
 #define IXGBE_82599_MC_TBL_SIZE   128
 #define IXGBE_82599_VFT_TBL_SIZE  128
 
+void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
+void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
 void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
 s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
                                           ixgbe_link_speed speed,
@@ -69,8 +71,14 @@ static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 	if (hw->phy.multispeed_fiber) {
 		/* Set up dual speed SFP+ support */
 		mac->ops.setup_link = &ixgbe_setup_mac_link_multispeed_fiber;
+		mac->ops.disable_tx_laser =
+		                       &ixgbe_disable_tx_laser_multispeed_fiber;
+		mac->ops.enable_tx_laser =
+		                        &ixgbe_enable_tx_laser_multispeed_fiber;
 		mac->ops.flap_tx_laser = &ixgbe_flap_tx_laser_multispeed_fiber;
 	} else {
+		mac->ops.disable_tx_laser = NULL;
+		mac->ops.enable_tx_laser = NULL;
 		mac->ops.flap_tx_laser = NULL;
 		if ((mac->ops.get_media_type(hw) ==
 		     ixgbe_media_type_backplane) &&
@@ -415,6 +423,44 @@ s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
 	return status;
 }
 
+ /**
+  *  ixgbe_disable_tx_laser_multispeed_fiber - Disable Tx laser
+  *  @hw: pointer to hardware structure
+  *
+  *  The base drivers may require better control over SFP+ module
+  *  PHY states.  This includes selectively shutting down the Tx
+  *  laser on the PHY, effectively halting physical link.
+  **/
+void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
+{
+	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
+
+	/* Disable tx laser; allow 100us to go dark per spec */
+	esdp_reg |= IXGBE_ESDP_SDP3;
+	IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(100);
+}
+
+/**
+ *  ixgbe_enable_tx_laser_multispeed_fiber - Enable Tx laser
+ *  @hw: pointer to hardware structure
+ *
+ *  The base drivers may require better control over SFP+ module
+ *  PHY states.  This includes selectively turning on the Tx
+ *  laser on the PHY, effectively starting physical link.
+ **/
+void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
+{
+	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
+
+	/* Enable tx laser; allow 100ms to light up */
+	esdp_reg &= ~IXGBE_ESDP_SDP3;
+	IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+	IXGBE_WRITE_FLUSH(hw);
+	msleep(100);
+}
+
 /**
  *  ixgbe_flap_tx_laser_multispeed_fiber - Flap Tx laser
  *  @hw: pointer to hardware structure
@@ -429,23 +475,11 @@ s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
  **/
 void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
 {
-	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
-
 	hw_dbg(hw, "ixgbe_flap_tx_laser_multispeed_fiber\n");
 
 	if (hw->mac.autotry_restart) {
-		/* Disable tx laser; allow 100us to go dark per spec */
-		esdp_reg |= IXGBE_ESDP_SDP3;
-		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
-		IXGBE_WRITE_FLUSH(hw);
-		udelay(100);
-
-		/* Enable tx laser; allow 100ms to light up */
-		esdp_reg &= ~IXGBE_ESDP_SDP3;
-		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
-		IXGBE_WRITE_FLUSH(hw);
-		msleep(100);
-
+		ixgbe_disable_tx_laser_multispeed_fiber(hw);
+		ixgbe_enable_tx_laser_multispeed_fiber(hw);
 		hw->mac.autotry_restart = false;
 	}
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8f677cb..6c00ee4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2982,6 +2982,10 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	else
 		ixgbe_configure_msi_and_legacy(adapter);
 
+	/* enable the optics */
+	if (hw->phy.multispeed_fiber)
+		hw->mac.ops.enable_tx_laser(hw);
+
 	clear_bit(__IXGBE_DOWN, &adapter->state);
 	ixgbe_napi_enable_all(adapter);
 
@@ -3243,6 +3247,10 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
+	/* power down the optics */
+	if (hw->phy.multispeed_fiber)
+		hw->mac.ops.disable_tx_laser(hw);
+
 	/* disable receive for all VFs and wait one second */
 	if (adapter->num_vfs) {
 		/* ping all the active vfs to let them know we are going down */
@@ -6253,6 +6261,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
+	/* power down the optics */
+	if (hw->phy.multispeed_fiber)
+		hw->mac.ops.disable_tx_laser(hw);
+
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &ixgbe_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
@@ -6400,16 +6412,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	del_timer_sync(&adapter->sfp_timer);
 	cancel_work_sync(&adapter->watchdog_task);
 	cancel_work_sync(&adapter->sfp_task);
-	if (adapter->hw.phy.multispeed_fiber) {
-		struct ixgbe_hw *hw = &adapter->hw;
-		/*
-		 * Restart clause 37 autoneg, disable and re-enable
-		 * the tx laser, to clear & alert the link partner
-		 * that it needs to restart autotry
-		 */
-		hw->mac.autotry_restart = true;
-		hw->mac.ops.flap_tx_laser(hw);
-	}
 	cancel_work_sync(&adapter->multispeed_fiber_task);
 	cancel_work_sync(&adapter->sfp_config_module_task);
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 4ec6dc1..534affc 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2398,6 +2398,8 @@ struct ixgbe_mac_operations {
 	s32 (*enable_rx_dma)(struct ixgbe_hw *, u32);
 
 	/* Link */
+	void (*disable_tx_laser)(struct ixgbe_hw *);
+	void (*enable_tx_laser)(struct ixgbe_hw *);
 	void (*flap_tx_laser)(struct ixgbe_hw *);
 	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool, bool);
 	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bool);

