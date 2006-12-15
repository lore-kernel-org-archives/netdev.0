From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 04/14] e1000: consolidate managability enabling/disabling
Date: Fri, 15 Dec 2006 10:32:51 +0100
Message-ID: <1166175176.3365.118.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751535AbWLOKBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:01:16 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gmIW006147
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:49 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9gmR7006146
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:48 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: consolidate managability enabling/disabling
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Several bugs existed in how we handle manageability issues all over the driver.
This patch consolidates all the managability release and init code in two single
functions and call them from appropriate locations. This fixes several
BMC packet redirect issues and powerup/down hiccups.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_hw.c   |    5 -
 drivers/net/e1000/e1000_hw.h   |    1 
 drivers/net/e1000/e1000_main.c |  127 +++++++++++++++++++++--------------------
 3 files changed, 71 insertions(+), 62 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_hw.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_hw.c
+++ linux-2.6/drivers/net/e1000/e1000_hw.c
@@ -7817,9 +7817,8 @@ e1000_enable_mng_pass_thru(struct e1000_
             fwsm = E1000_READ_REG(hw, FWSM);
             factps = E1000_READ_REG(hw, FACTPS);
 
-            if (((fwsm & E1000_FWSM_MODE_MASK) ==
-                (e1000_mng_mode_pt << E1000_FWSM_MODE_SHIFT)) &&
-                (factps & E1000_FACTPS_MNGCG))
+            if ((((fwsm & E1000_FWSM_MODE_MASK) >> E1000_FWSM_MODE_SHIFT) ==
+                   e1000_mng_mode_pt) && !(factps & E1000_FACTPS_MNGCG))
                 return TRUE;
         } else
             if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
Index: linux-2.6/drivers/net/e1000/e1000_hw.h
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_hw.h
+++ linux-2.6/drivers/net/e1000/e1000_hw.h
@@ -1301,6 +1301,7 @@ struct e1000_ffvt_entry {
 #define E1000_82542_RSSIR       E1000_RSSIR
 #define E1000_82542_KUMCTRLSTA E1000_KUMCTRLSTA
 #define E1000_82542_SW_FW_SYNC E1000_SW_FW_SYNC
+#define E1000_82542_MANC2H      E1000_MANC2H
 
 /* Statistics counters collected by the MAC */
 struct e1000_hw_stats {
Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -464,6 +464,51 @@ e1000_get_hw_control(struct e1000_adapte
 	}
 }
 
+static void
+e1000_init_manageability(struct e1000_adapter *adapter)
+{
+	if (adapter->en_mng_pt) {
+		uint32_t manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
+		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+
+		/* disable hardware interception of ARP */
+		manc &= ~(E1000_MANC_ARP_EN);
+
+		/* enable receiving management packets to the host */
+		/* this will probably generate destination unreachable messages
+		 * from the host OS, but the packets will be handled on SMBUS */
+		if (adapter->hw.mac_type >= e1000_82571) {
+			manc |= E1000_MANC_EN_MNG2HOST;
+#define E1000_MNG2HOST_PORT_623 (1 << 5)
+#define E1000_MNG2HOST_PORT_664 (1 << 6)
+			manc2h |= E1000_MNG2HOST_PORT_623;
+			manc2h |= E1000_MNG2HOST_PORT_664;
+			E1000_WRITE_REG(&adapter->hw, MANC2H, manc2h);
+		}
+
+		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+	}
+}
+
+static void
+e1000_release_manageability(struct e1000_adapter *adapter)
+{
+	if (adapter->en_mng_pt) {
+		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+
+		/* re-enable hardware interception of ARP */
+		manc |= E1000_MANC_ARP_EN;
+
+		if (adapter->hw.mac_type >= e1000_82571)
+			manc &= ~E1000_MANC_EN_MNG2HOST;
+
+		/* don't explicitly have to mess with MANC2H since
+		 * MANC has an enable disable that gates MANC2H */
+
+		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+	}
+}
+
 int
 e1000_up(struct e1000_adapter *adapter)
 {
@@ -475,6 +520,7 @@ e1000_up(struct e1000_adapter *adapter)
 	e1000_set_multi(netdev);
 
 	e1000_restore_vlan(adapter);
+	e1000_init_manageability(adapter);
 
 	e1000_configure_tx(adapter);
 	e1000_setup_rctl(adapter);
@@ -614,7 +660,7 @@ e1000_reinit_locked(struct e1000_adapter
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba, manc;
+	uint32_t pba;
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
 
 	/* Repartition Pba for greater than 9k mtu
@@ -705,14 +751,7 @@ e1000_reset(struct e1000_adapter *adapte
 		                    phy_data);
 	}
 
-	if ((adapter->en_mng_pt) &&
-	    (adapter->hw.mac_type >= e1000_82540) &&
-	    (adapter->hw.mac_type < e1000_82571) &&
-	    (adapter->hw.media_type == e1000_media_type_copper)) {
-		manc = E1000_READ_REG(&adapter->hw, MANC);
-		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
-	}
+	e1000_release_manageability(adapter);
 }
 
 /**
@@ -1078,22 +1117,13 @@ e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t manc;
 #ifdef CONFIG_E1000_NAPI
 	int i;
 #endif
 
 	flush_scheduled_work();
 
-	if (adapter->hw.mac_type >= e1000_82540 &&
-	    adapter->hw.mac_type < e1000_82571 &&
-	    adapter->hw.media_type == e1000_media_type_copper) {
-		manc = E1000_READ_REG(&adapter->hw, MANC);
-		if (manc & E1000_MANC_SMBUS_EN) {
-			manc |= E1000_MANC_ARP_EN;
-			E1000_WRITE_REG(&adapter->hw, MANC, manc);
-		}
-	}
+	e1000_release_manageability(adapter);
 
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
@@ -5014,7 +5044,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, ctrl_ext, rctl, manc, status;
+	uint32_t ctrl, ctrl_ext, rctl, status;
 	uint32_t wufc = adapter->wol;
 #ifdef CONFIG_PM
 	int retval = 0;
@@ -5083,16 +5113,12 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	if (adapter->hw.mac_type >= e1000_82540 &&
-	    adapter->hw.mac_type < e1000_82571 &&
-	    adapter->hw.media_type == e1000_media_type_copper) {
-		manc = E1000_READ_REG(&adapter->hw, MANC);
-		if (manc & E1000_MANC_SMBUS_EN) {
-			manc |= E1000_MANC_ARP_EN;
-			E1000_WRITE_REG(&adapter->hw, MANC, manc);
-			pci_enable_wake(pdev, PCI_D3hot, 1);
-			pci_enable_wake(pdev, PCI_D3cold, 1);
-		}
+	e1000_release_manageability(adapter);
+
+	/* make sure adapter isn't asleep if manageability is enabled */
+	if (adapter->en_mng_pt) {
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
 	}
 
 	if (adapter->hw.phy_type == e1000_phy_igp_3)
@@ -5118,7 +5144,7 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t manc, err;
+	uint32_t err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	e1000_pci_restore_state(adapter);
@@ -5138,19 +5164,13 @@ e1000_resume(struct pci_dev *pdev)
 	e1000_reset(adapter);
 	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
 
+	e1000_init_manageability(adapter);
+
 	if (netif_running(netdev))
 		e1000_up(adapter);
 
 	netif_device_attach(netdev);
 
-	if (adapter->hw.mac_type >= e1000_82540 &&
-	    adapter->hw.mac_type < e1000_82571 &&
-	    adapter->hw.media_type == e1000_media_type_copper) {
-		manc = E1000_READ_REG(&adapter->hw, MANC);
-		manc &= ~(E1000_MANC_ARP_EN);
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
-	}
-
 	/* If the controller is 82573 and f/w is AMT, do not set
 	 * DRV_LOAD until the interface is up.  For all other cases,
 	 * let the f/w know that the h/w is now under the control
@@ -5251,7 +5271,8 @@ static void e1000_io_resume(struct pci_d
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
-	uint32_t manc, swsm;
+
+	e1000_init_manageability(adapter);
 
 	if (netif_running(netdev)) {
 		if (e1000_up(adapter)) {
@@ -5262,26 +5283,14 @@ static void e1000_io_resume(struct pci_d
 
 	netif_device_attach(netdev);
 
-	if (adapter->hw.mac_type >= e1000_82540 &&
-	    adapter->hw.mac_type < e1000_82571 &&
-	    adapter->hw.media_type == e1000_media_type_copper) {
-		manc = E1000_READ_REG(&adapter->hw, MANC);
-		manc &= ~(E1000_MANC_ARP_EN);
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
-	}
-
-	switch (adapter->hw.mac_type) {
-	case e1000_82573:
-		swsm = E1000_READ_REG(&adapter->hw, SWSM);
-		E1000_WRITE_REG(&adapter->hw, SWSM,
-				swsm | E1000_SWSM_DRV_LOAD);
-		break;
-	default:
-		break;
-	}
+	/* If the controller is 82573 and f/w is AMT, do not set
+	 * DRV_LOAD until the interface is up.  For all other cases,
+	 * let the f/w know that the h/w is now under the control
+	 * of the driver. */
+	if (adapter->hw.mac_type != e1000_82573 ||
+	    !e1000_check_mng_mode(&adapter->hw))
+		e1000_get_hw_control(adapter);
 
-	if (netif_running(netdev))
-		mod_timer(&adapter->watchdog_timer, jiffies);
 }
 
 /* e1000_main.c */

