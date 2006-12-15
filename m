From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 04/14] e1000: consolidate managability enabling/disabling
Date: Fri, 15 Dec 2006 10:57:38 -0500
Message-ID: <4582C5F2.6090205@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175176.3365.118.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070006040008050004010905"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55800 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752773AbWLOP5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 10:57:41 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175176.3365.118.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070006040008050004010905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Arjan van de Ven wrote:
> Subject: e1000: consolidate managability enabling/disabling
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Several bugs existed in how we handle manageability issues all over the driver.
> This patch consolidates all the managability release and init code in two single
> functions and call them from appropriate locations. This fixes several
> BMC packet redirect issues and powerup/down hiccups.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

The revisions for this patch were "major revisions", as you had warned. 
  See attached.

	Jeff



--------------070006040008050004010905
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

commit fa359ae5b1c4ddbd5a5ba3bc72d4276efbc6654a
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Dec 15 10:56:10 2006 -0500

    e1000: consolidate managability enabling/disabling
    
    Several bugs existed in how we handle manageability issues all
    over the driver.  This patch consolidates all the managability
    release and init code in two single functions and call them from
    appropriate locations. This fixes several BMC packet redirect issues
    and powerup/down hiccups.
    
    Originally from Jesse Brandeburg <jesse.brandeburg@intel.com>, rewritten
    to use feature flags by me.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

fa359ae5b1c4ddbd5a5ba3bc72d4276efbc6654a
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index ce82eb5..1ea556e 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -448,6 +448,10 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	if (hw->mac_type == e1000_82543)
 		hw->bad_tx_carr_stats_fd = TRUE;
 
+	/* capable of receiving management packets to the host */
+	if (hw->mac_type >= e1000_82571)
+		hw->has_manc2h = TRUE;
+
 	return E1000_SUCCESS;
 }
 
@@ -7823,9 +7827,8 @@ e1000_enable_mng_pass_thru(struct e1000_hw *hw)
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
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index fef1f7b..18a4ae4 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1301,6 +1301,7 @@ struct e1000_ffvt_entry {
 #define E1000_82542_RSSIR       E1000_RSSIR
 #define E1000_82542_KUMCTRLSTA E1000_KUMCTRLSTA
 #define E1000_82542_SW_FW_SYNC E1000_SW_FW_SYNC
+#define E1000_82542_MANC2H      E1000_MANC2H
 
 /* Statistics counters collected by the MAC */
 struct e1000_hw_stats {
@@ -1461,6 +1462,7 @@ struct e1000_hw {
 	boolean_t		leave_av_bit_off;
 	boolean_t		kmrn_lock_loss_workaround_disabled;
 	boolean_t		bad_tx_carr_stats_fd;
+	boolean_t		has_manc2h;
 };
 
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0816de2..7a51283 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -464,6 +464,52 @@ e1000_get_hw_control(struct e1000_adapter *adapter)
 	}
 }
 
+static void
+e1000_init_manageability(struct e1000_adapter *adapter)
+{
+	if (adapter->en_mng_pt) {
+		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+
+		/* disable hardware interception of ARP */
+		manc &= ~(E1000_MANC_ARP_EN);
+
+		/* enable receiving management packets to the host */
+		/* this will probably generate destination unreachable messages
+		 * from the host OS, but the packets will be handled on SMBUS */
+		if (adapter->hw.has_manc2h) {
+			uint32_t manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
+
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
+		if (adapter->hw.has_manc2h)
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
@@ -475,6 +521,7 @@ e1000_up(struct e1000_adapter *adapter)
 	e1000_set_multi(netdev);
 
 	e1000_restore_vlan(adapter);
+	e1000_init_manageability(adapter);
 
 	e1000_configure_tx(adapter);
 	e1000_setup_rctl(adapter);
@@ -614,7 +661,7 @@ e1000_reinit_locked(struct e1000_adapter *adapter)
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba, manc;
+	uint32_t pba;
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
 
 	/* Repartition Pba for greater than 9k mtu
@@ -705,14 +752,7 @@ e1000_reset(struct e1000_adapter *adapter)
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
@@ -1078,22 +1118,13 @@ e1000_remove(struct pci_dev *pdev)
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
@@ -5011,7 +5042,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, ctrl_ext, rctl, manc, status;
+	uint32_t ctrl, ctrl_ext, rctl, status;
 	uint32_t wufc = adapter->wol;
 #ifdef CONFIG_PM
 	int retval = 0;
@@ -5080,16 +5111,12 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
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
@@ -5115,7 +5142,7 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t manc, err;
+	uint32_t err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	e1000_pci_restore_state(adapter);
@@ -5135,19 +5162,13 @@ e1000_resume(struct pci_dev *pdev)
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
@@ -5248,7 +5269,8 @@ static void e1000_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
-	uint32_t manc, swsm;
+
+	e1000_init_manageability(adapter);
 
 	if (netif_running(netdev)) {
 		if (e1000_up(adapter)) {
@@ -5259,26 +5281,14 @@ static void e1000_io_resume(struct pci_dev *pdev)
 
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

--------------070006040008050004010905--
