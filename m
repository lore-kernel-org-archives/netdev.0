From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 09/26] e1000: unify WoL capability detection code
Date: Tue, 29 Aug 2006 09:44:34 -0700
Message-ID: <20060829164434.6872.82138.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:36618 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965073AbWH2QgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:21 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


WoL is constantly giving problems and needed a rewrite. Consolidates
all WoL capabilities into a single function, and disables WoL for all
other ports on the device except for port A.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    3 -
 drivers/net/e1000/e1000_ethtool.c |  164 ++++++++++++++++++++-----------------
 drivers/net/e1000/e1000_main.c    |   47 ++++++++---
 3 files changed, 126 insertions(+), 88 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 70ba378..98afa9c 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -246,7 +246,6 @@ struct e1000_adapter {
 	uint32_t bd_number;
 	uint32_t rx_buffer_len;
 	uint32_t wol;
-	uint32_t ksp3_port_a;
 	uint32_t smartspeed;
 	uint32_t en_mng_pt;
 	uint16_t link_speed;
@@ -341,7 +340,9 @@ struct e1000_adapter {
 	boolean_t tso_force;
 #endif
 	boolean_t smart_power_down;	/* phy smart power down */
+	boolean_t quad_port_a;
 	unsigned long flags;
+	uint32_t eeprom_wol;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index ab2f153..0403072 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1675,14 +1675,12 @@ e1000_diag_test(struct net_device *netde
 	msleep_interruptible(4 * 1000);
 }
 
-static void
-e1000_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wolinfo *wol)
 {
-	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int retval = 1; /* fail by default */
 
-	switch (adapter->hw.device_id) {
-	case E1000_DEV_ID_82542:
+	switch (hw->device_id) {
 	case E1000_DEV_ID_82543GC_FIBER:
 	case E1000_DEV_ID_82543GC_COPPER:
 	case E1000_DEV_ID_82544EI_FIBER:
@@ -1690,52 +1688,86 @@ e1000_get_wol(struct net_device *netdev,
 	case E1000_DEV_ID_82545EM_FIBER:
 	case E1000_DEV_ID_82545EM_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER:
+	case E1000_DEV_ID_82546GB_PCIE:
+		/* these don't support WoL at all */
 		wol->supported = 0;
-		wol->wolopts   = 0;
-		return;
-
-	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
-		/* device id 10B5 port-A supports wol */
-		if (!adapter->ksp3_port_a) {
-			wol->supported = 0;
-			return;
-		}
-		/* KSP3 does not suppport UCAST wake-ups for any interface */
-		wol->supported = WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
-
-		if (adapter->wol & E1000_WUFC_EX)
-			DPRINTK(DRV, ERR, "Interface does not support "
-		        "directed (unicast) frame wake-up packets\n");
-		wol->wolopts = 0;
-		goto do_defaults;
-
+		break;
 	case E1000_DEV_ID_82546EB_FIBER:
 	case E1000_DEV_ID_82546GB_FIBER:
 	case E1000_DEV_ID_82571EB_FIBER:
-		/* Wake events only supported on port A for dual fiber */
+	case E1000_DEV_ID_82571EB_SERDES:
+	case E1000_DEV_ID_82571EB_COPPER:
+		/* Wake events not supported on port B */
 		if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1) {
 			wol->supported = 0;
-			wol->wolopts   = 0;
-			return;
+			break;
 		}
-		/* Fall Through */
-
+		/* return success for non excluded adapter ports */
+		retval = 0;
+		break;
+	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
+		/* quad port adapters only support WoL on port A */
+		if (!adapter->quad_port_a) {
+			wol->supported = 0;
+			break;
+		}
+		/* return success for non excluded adapter ports */
+		retval = 0;
+		break;
 	default:
-		wol->supported = WAKE_UCAST | WAKE_MCAST |
-				 WAKE_BCAST | WAKE_MAGIC;
-		wol->wolopts = 0;
+		/* dual port cards only support WoL on port A from now on
+		 * unless it was enabled in the eeprom for port B
+		 * so exclude FUNC_1 ports from having WoL enabled */
+		if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1 &&
+		    !adapter->eeprom_wol) {
+			wol->supported = 0;
+			break;
+		}
 
-do_defaults:
-		if (adapter->wol & E1000_WUFC_EX)
-			wol->wolopts |= WAKE_UCAST;
-		if (adapter->wol & E1000_WUFC_MC)
-			wol->wolopts |= WAKE_MCAST;
-		if (adapter->wol & E1000_WUFC_BC)
-			wol->wolopts |= WAKE_BCAST;
-		if (adapter->wol & E1000_WUFC_MAG)
-			wol->wolopts |= WAKE_MAGIC;
+		retval = 0;
+	}
+
+	return retval;
+}
+
+static void
+e1000_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	wol->supported = WAKE_UCAST | WAKE_MCAST |
+	                 WAKE_BCAST | WAKE_MAGIC;
+	wol->wolopts = 0;
+
+	/* this function will set ->supported = 0 and return 1 if wol is not
+	 * supported by this hardware */
+	if (e1000_wol_exclusion(adapter, wol))
 		return;
+
+	/* apply any specific unsupported masks here */
+	switch (adapter->hw.device_id) {
+	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
+		/* KSP3 does not suppport UCAST wake-ups */
+		wol->supported &= ~WAKE_UCAST;
+
+		if (adapter->wol & E1000_WUFC_EX)
+			DPRINTK(DRV, ERR, "Interface does not support "
+		        "directed (unicast) frame wake-up packets\n");
+		break;
+	default:
+		break;
 	}
+
+	if (adapter->wol & E1000_WUFC_EX)
+		wol->wolopts |= WAKE_UCAST;
+	if (adapter->wol & E1000_WUFC_MC)
+		wol->wolopts |= WAKE_MCAST;
+	if (adapter->wol & E1000_WUFC_BC)
+		wol->wolopts |= WAKE_BCAST;
+	if (adapter->wol & E1000_WUFC_MAG)
+		wol->wolopts |= WAKE_MAGIC;
+
+	return;
 }
 
 static int
@@ -1744,51 +1776,35 @@ e1000_set_wol(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	switch (adapter->hw.device_id) {
-	case E1000_DEV_ID_82542:
-	case E1000_DEV_ID_82543GC_FIBER:
-	case E1000_DEV_ID_82543GC_COPPER:
-	case E1000_DEV_ID_82544EI_FIBER:
-	case E1000_DEV_ID_82546EB_QUAD_COPPER:
-	case E1000_DEV_ID_82546GB_QUAD_COPPER:
-	case E1000_DEV_ID_82545EM_FIBER:
-	case E1000_DEV_ID_82545EM_COPPER:
+	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+		return -EOPNOTSUPP;
+
+	if (e1000_wol_exclusion(adapter, wol))
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
+	switch (hw->device_id) {
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
-		/* device id 10B5 port-A supports wol */
-		if (!adapter->ksp3_port_a)
-			return wol->wolopts ? -EOPNOTSUPP : 0;
-
 		if (wol->wolopts & WAKE_UCAST) {
 			DPRINTK(DRV, ERR, "Interface does not support "
 		        "directed (unicast) frame wake-up packets\n");
 			return -EOPNOTSUPP;
 		}
-
-	case E1000_DEV_ID_82546EB_FIBER:
-	case E1000_DEV_ID_82546GB_FIBER:
-	case E1000_DEV_ID_82571EB_FIBER:
-		/* Wake events only supported on port A for dual fiber */
-		if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)
-			return wol->wolopts ? -EOPNOTSUPP : 0;
-		/* Fall Through */
-
+		break;
 	default:
-		if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
-			return -EOPNOTSUPP;
+		break;
+	}
 
-		adapter->wol = 0;
+	/* these settings will always override what we currently have */
+	adapter->wol = 0;
 
-		if (wol->wolopts & WAKE_UCAST)
-			adapter->wol |= E1000_WUFC_EX;
-		if (wol->wolopts & WAKE_MCAST)
-			adapter->wol |= E1000_WUFC_MC;
-		if (wol->wolopts & WAKE_BCAST)
-			adapter->wol |= E1000_WUFC_BC;
-		if (wol->wolopts & WAKE_MAGIC)
-			adapter->wol |= E1000_WUFC_MAG;
-	}
+	if (wol->wolopts & WAKE_UCAST)
+		adapter->wol |= E1000_WUFC_EX;
+	if (wol->wolopts & WAKE_MCAST)
+		adapter->wol |= E1000_WUFC_MC;
+	if (wol->wolopts & WAKE_BCAST)
+		adapter->wol |= E1000_WUFC_BC;
+	if (wol->wolopts & WAKE_MAGIC)
+		adapter->wol |= E1000_WUFC_MAG;
 
 	return 0;
 }
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 70d0acd..6dbafb1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -681,9 +681,9 @@ e1000_probe(struct pci_dev *pdev,
 	unsigned long flash_start, flash_len;
 
 	static int cards_found = 0;
-	static int e1000_ksp3_port_a = 0; /* global ksp3 port a indication */
+	static int global_quad_port_a = 0; /* global ksp3 port a indication */
 	int i, err, pci_using_dac;
-	uint16_t eeprom_data;
+	uint16_t eeprom_data = 0;
 	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
 	if ((err = pci_enable_device(pdev)))
 		return err;
@@ -786,15 +786,6 @@ e1000_probe(struct pci_dev *pdev,
 	if (e1000_check_phy_reset_block(&adapter->hw))
 		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
-	/* if ksp3, indicate if it's port a being setup */
-	if (pdev->device == E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 &&
-			e1000_ksp3_port_a == 0)
-		adapter->ksp3_port_a = 1;
-	e1000_ksp3_port_a++;
-	/* Reset for multiple KP3 adapters */
-	if (e1000_ksp3_port_a == 4)
-		e1000_ksp3_port_a = 0;
-
 	if (adapter->hw.mac_type >= e1000_82543) {
 		netdev->features = NETIF_F_SG |
 				   NETIF_F_HW_CSUM |
@@ -913,7 +904,37 @@ e1000_probe(struct pci_dev *pdev,
 		break;
 	}
 	if (eeprom_data & eeprom_apme_mask)
-		adapter->wol |= E1000_WUFC_MAG;
+		adapter->eeprom_wol |= E1000_WUFC_MAG;
+
+	/* now that we have the eeprom settings, apply the special cases
+	 * where the eeprom may be wrong or the board simply won't support
+	 * wake on lan on a particular port */
+	switch (pdev->device) {
+	case E1000_DEV_ID_82546GB_PCIE:
+		adapter->eeprom_wol = 0;
+		break;
+	case E1000_DEV_ID_82546EB_FIBER:
+	case E1000_DEV_ID_82546GB_FIBER:
+	case E1000_DEV_ID_82571EB_FIBER:
+		/* Wake events only supported on port A for dual fiber
+		 * regardless of eeprom setting */
+		if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1)
+			adapter->eeprom_wol = 0;
+		break;
+	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
+		/* if quad port adapter, disable WoL on all but port A */
+		if (global_quad_port_a != 0)
+			adapter->eeprom_wol = 0;
+		else
+			adapter->quad_port_a = 1;
+		/* Reset for multiple quad port adapters */
+		if (++global_quad_port_a == 4)
+			global_quad_port_a = 0;
+		break;
+	}
+
+	/* initialize the wol settings based on the eeprom settings */
+	adapter->wol = adapter->eeprom_wol;
 
 	/* print bus type/speed/width info */
 	{
@@ -4566,7 +4587,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 		e1000_set_multi(netdev);
 
 		/* turn on all-multi mode if wake on multicast is enabled */
-		if (adapter->wol & E1000_WUFC_MC) {
+		if (wufc & E1000_WUFC_MC) {
 			rctl = E1000_READ_REG(&adapter->hw, RCTL);
 			rctl |= E1000_RCTL_MPE;
 			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);



---
Auke Kok <auke-jan.h.kok@intel.com>
