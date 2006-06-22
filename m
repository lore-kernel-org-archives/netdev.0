From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 03/21] e1000: Make PHY powerup/down a function
Date: Wed, 21 Jun 2006 22:20:11 -0700
Message-ID: <20060622052011.25497.89260.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:43528 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932797AbWFVFOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:14 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In relation to the irq work done earlier we also move the PHY powerup
and powerdown functions into separate functions and move the calls to
_close and _open, making the PHY stay in it's power state as long as
the device is _up.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   76 ++++++++++++++++++++++++++--------------
 1 files changed, 49 insertions(+), 27 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 52d698b..813d5e0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -428,14 +428,6 @@ e1000_up(struct e1000_adapter *adapter)
 
 	/* hardware has been reset, we need to reload some things */
 
-	/* Reset the PHY if it was previously powered down */
-	if (adapter->hw.media_type == e1000_media_type_copper) {
-		uint16_t mii_reg;
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
-		if (mii_reg & MII_CR_POWER_DOWN)
-			e1000_phy_hw_reset(&adapter->hw);
-	}
-
 	e1000_set_multi(netdev);
 
 	e1000_restore_vlan(adapter);
@@ -464,12 +456,56 @@ e1000_up(struct e1000_adapter *adapter)
 	return 0;
 }
 
+/**
+ * e1000_power_up_phy - restore link in case the phy was powered down
+ * @adapter: address of board private structure
+ *
+ * The phy may be powered down to save power and turn off link when the
+ * driver is unloaded and wake on lan is not enabled (among others)
+ * *** this routine MUST be followed by a call to e1000_reset ***
+ *
+ **/
+
+static void e1000_power_up_phy(struct e1000_adapter *adapter)
+{
+	uint16_t mii_reg = 0;
+
+	/* Just clear the power down bit to wake the phy back up */
+	if (adapter->hw.media_type == e1000_media_type_copper) {
+		/* according to the manual, the phy will retain its
+		 * settings across a power-down/up cycle */
+		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		mii_reg &= ~MII_CR_POWER_DOWN;
+		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
+	}
+}
+
+static void e1000_power_down_phy(struct e1000_adapter *adapter)
+{
+	boolean_t mng_mode_enabled = (adapter->hw.mac_type >= e1000_82571) &&
+	                              e1000_check_mng_mode(&adapter->hw);
+	/* Power down the PHY so no link is implied when interface is down
+	 * The PHY cannot be powered down if any of the following is TRUE
+	 * (a) WoL is enabled
+	 * (b) AMT is active
+	 * (c) SoL/IDER session is active */
+	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
+	    adapter->hw.media_type == e1000_media_type_copper &&
+	    !(E1000_READ_REG(&adapter->hw, MANC) & E1000_MANC_SMBUS_EN) &&
+	    !mng_mode_enabled &&
+	    !e1000_check_phy_reset_block(&adapter->hw)) {
+		uint16_t mii_reg = 0;
+		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		mii_reg |= MII_CR_POWER_DOWN;
+		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
+		mdelay(1);
+	}
+}
+
 void
 e1000_down(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	boolean_t mng_mode_enabled = (adapter->hw.mac_type >= e1000_82571) &&
-	                              e1000_check_mng_mode(&adapter->hw);
 
 	e1000_irq_disable(adapter);
 
@@ -489,23 +525,6 @@ e1000_down(struct e1000_adapter *adapter
 	e1000_reset(adapter);
 	e1000_clean_all_tx_rings(adapter);
 	e1000_clean_all_rx_rings(adapter);
-
-	/* Power down the PHY so no link is implied when interface is down *
-	 * The PHY cannot be powered down if any of the following is TRUE *
-	 * (a) WoL is enabled
-	 * (b) AMT is active
-	 * (c) SoL/IDER session is active */
-	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
-	   adapter->hw.media_type == e1000_media_type_copper &&
-	   !(E1000_READ_REG(&adapter->hw, MANC) & E1000_MANC_SMBUS_EN) &&
-	   !mng_mode_enabled &&
-	   !e1000_check_phy_reset_block(&adapter->hw)) {
-		uint16_t mii_reg;
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
-		mii_reg |= MII_CR_POWER_DOWN;
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
-		mdelay(1);
-	}
 }
 
 void
@@ -1117,6 +1136,8 @@ e1000_open(struct net_device *netdev)
 	if (err)
 		goto err_up;
 
+	e1000_power_up_phy(adapter);
+
 	if ((err = e1000_up(adapter)))
 		goto err_up;
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
@@ -1162,6 +1183,7 @@ e1000_close(struct net_device *netdev)
 
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
+	e1000_power_down_phy(adapter);
 	e1000_free_irq(adapter);
 
 	e1000_free_all_tx_resources(adapter);



--
Auke Kok <auke-jan.h.kok@intel.com>
