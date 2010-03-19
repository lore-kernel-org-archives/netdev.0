From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Fix 82599 multispeed fiber link issues due to
	Tx laser flapping
Date: Thu, 18 Mar 2010 17:34:52 -0700
Message-ID: <20100319003422.8981.79416.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:34553
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752759Ab0CSAfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 20:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Fix 82599 link issues during driver load and unload test using multi-speed
10G & 1G fiber modules. When connected back to back sometime 82599 multispeed
fiber modules would link at 1G speed instead of 10G highest speed, due to a
race condition in autotry process involving Tx laser flapping. Move autotry
autoneg-37 tx laser flapping process from multispeed module init setup
to driver unload. This will alert the link partner to restart its
autotry process when it tries to establish the link with the link partner

Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   78 +++++++++++++++++++++------------------
 drivers/net/ixgbe/ixgbe_main.c  |   11 ++++++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 54 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 1f30e16..b405a00 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -39,6 +39,7 @@
 #define IXGBE_82599_MC_TBL_SIZE   128
 #define IXGBE_82599_VFT_TBL_SIZE  128
 
+void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
 s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
                                           ixgbe_link_speed speed,
                                           bool autoneg,
@@ -68,7 +69,9 @@ static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 	if (hw->phy.multispeed_fiber) {
 		/* Set up dual speed SFP+ support */
 		mac->ops.setup_link = &ixgbe_setup_mac_link_multispeed_fiber;
+		mac->ops.flap_tx_laser = &ixgbe_flap_tx_laser_multispeed_fiber;
 	} else {
+		mac->ops.flap_tx_laser = NULL;
 		if ((mac->ops.get_media_type(hw) ==
 		     ixgbe_media_type_backplane) &&
 		    (hw->phy.smart_speed == ixgbe_smart_speed_auto ||
@@ -413,6 +416,41 @@ s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
 }
 
 /**
+ *  ixgbe_flap_tx_laser_multispeed_fiber - Flap Tx laser
+ *  @hw: pointer to hardware structure
+ *
+ *  When the driver changes the link speeds that it can support,
+ *  it sets autotry_restart to true to indicate that we need to
+ *  initiate a new autotry session with the link partner.  To do
+ *  so, we set the speed then disable and re-enable the tx laser, to
+ *  alert the link partner that it also needs to restart autotry on its
+ *  end.  This is consistent with true clause 37 autoneg, which also
+ *  involves a loss of signal.
+ **/
+void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
+{
+	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
+
+	hw_dbg(hw, "ixgbe_flap_tx_laser_multispeed_fiber\n");
+
+	if (hw->mac.autotry_restart) {
+		/* Disable tx laser; allow 100us to go dark per spec */
+		esdp_reg |= IXGBE_ESDP_SDP3;
+		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+		IXGBE_WRITE_FLUSH(hw);
+		udelay(100);
+
+		/* Enable tx laser; allow 100ms to light up */
+		esdp_reg &= ~IXGBE_ESDP_SDP3;
+		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+		IXGBE_WRITE_FLUSH(hw);
+		msleep(100);
+
+		hw->mac.autotry_restart = false;
+	}
+}
+
+/**
  *  ixgbe_setup_mac_link_multispeed_fiber - Set MAC link speed
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
@@ -440,16 +478,6 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 	speed &= phy_link_speed;
 
 	/*
-	 * When the driver changes the link speeds that it can support,
-	 * it sets autotry_restart to true to indicate that we need to
-	 * initiate a new autotry session with the link partner.  To do
-	 * so, we set the speed then disable and re-enable the tx laser, to
-	 * alert the link partner that it also needs to restart autotry on its
-	 * end.  This is consistent with true clause 37 autoneg, which also
-	 * involves a loss of signal.
-	 */
-
-	/*
 	 * Try each speed one by one, highest priority first.  We do this in
 	 * software because 10gb fiber doesn't support speed autonegotiation.
 	 */
@@ -466,6 +494,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		/* Set the module link speed */
 		esdp_reg |= (IXGBE_ESDP_SDP5_DIR | IXGBE_ESDP_SDP5);
 		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+		IXGBE_WRITE_FLUSH(hw);
 
 		/* Allow module to change analog characteristics (1G->10G) */
 		msleep(40);
@@ -478,19 +507,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 			return status;
 
 		/* Flap the tx laser if it has not already been done */
-		if (hw->mac.autotry_restart) {
-			/* Disable tx laser; allow 100us to go dark per spec */
-			esdp_reg |= IXGBE_ESDP_SDP3;
-			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
-			udelay(100);
-
-			/* Enable tx laser; allow 2ms to light up per spec */
-			esdp_reg &= ~IXGBE_ESDP_SDP3;
-			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
-			msleep(2);
-
-			hw->mac.autotry_restart = false;
-		}
+		hw->mac.ops.flap_tx_laser(hw);
 
 		/*
 		 * Wait for the controller to acquire link.  Per IEEE 802.3ap,
@@ -525,6 +542,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		esdp_reg &= ~IXGBE_ESDP_SDP5;
 		esdp_reg |= IXGBE_ESDP_SDP5_DIR;
 		IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
+		IXGBE_WRITE_FLUSH(hw);
 
 		/* Allow module to change analog characteristics (10G->1G) */
 		msleep(40);
@@ -537,19 +555,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 			return status;
 
 		/* Flap the tx laser if it has not already been done */
-		if (hw->mac.autotry_restart) {
-			/* Disable tx laser; allow 100us to go dark per spec */
-			esdp_reg |= IXGBE_ESDP_SDP3;
-			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
-			udelay(100);
-
-			/* Enable tx laser; allow 2ms to light up per spec */
-			esdp_reg &= ~IXGBE_ESDP_SDP3;
-			IXGBE_WRITE_REG(hw, IXGBE_ESDP, esdp_reg);
-			msleep(2);
-
-			hw->mac.autotry_restart = false;
-		}
+		hw->mac.ops.flap_tx_laser(hw);
 
 		/* Wait for the link partner to also set speed */
 		msleep(100);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 684af37..b858a1a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5018,6 +5018,7 @@ static void ixgbe_multispeed_fiber_task(struct work_struct *work)
 	autoneg = hw->phy.autoneg_advertised;
 	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
 		hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
+	hw->mac.autotry_restart = false;
 	if (hw->mac.ops.setup_link)
 		hw->mac.ops.setup_link(hw, autoneg, negotiation, true);
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
@@ -6380,6 +6381,16 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	del_timer_sync(&adapter->sfp_timer);
 	cancel_work_sync(&adapter->watchdog_task);
 	cancel_work_sync(&adapter->sfp_task);
+	if (adapter->hw.phy.multispeed_fiber) {
+		struct ixgbe_hw *hw = &adapter->hw;
+		/*
+		 * Restart clause 37 autoneg, disable and re-enable
+		 * the tx laser, to clear & alert the link partner
+		 * that it needs to restart autotry
+		 */
+		hw->mac.autotry_restart = true;
+		hw->mac.ops.flap_tx_laser(hw);
+	}
 	cancel_work_sync(&adapter->multispeed_fiber_task);
 	cancel_work_sync(&adapter->sfp_config_module_task);
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 2be9074..0ed5ab3 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2397,6 +2397,7 @@ struct ixgbe_mac_operations {
 	s32 (*enable_rx_dma)(struct ixgbe_hw *, u32);
 
 	/* Link */
+	void (*flap_tx_laser)(struct ixgbe_hw *);
 	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool, bool);
 	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bool);
 	s32 (*get_link_capabilities)(struct ixgbe_hw *, ixgbe_link_speed *,

