From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 08/22] e1000: Fix all manageability workarounds
Date: Fri, 08 Dec 2006 15:03:02 -0800
Message-ID: <20061208230302.30109.69865.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4384 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761259AbWLHWxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:02 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several bugs existed in how we handle various manageability issues and
workarounds. We consolidate all release and init code in two single
functions and call them from appropriate locations. This fixes several
BMC packet redirect issues and powerup/down hiccups.

Add 3 extra packet redirect counters for tracking purposes to make sure
we can test that all packets arrive properly.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    3 +
 drivers/net/e1000/e1000_hw.c      |    5 +
 drivers/net/e1000/e1000_hw.h      |    1 
 drivers/net/e1000/e1000_main.c    |  135 +++++++++++++++++++++----------------
 4 files changed, 83 insertions(+), 61 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index da459f7..fb96c87 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -100,6 +100,9 @@ static const struct e1000_stats e1000_gs
 	{ "rx_csum_offload_errors", E1000_STAT(hw_csum_err) },
 	{ "rx_header_split", E1000_STAT(rx_hdr_split) },
 	{ "alloc_rx_buff_failed", E1000_STAT(alloc_rx_buff_failed) },
+	{ "tx_smbus", E1000_STAT(stats.mgptc) },
+	{ "rx_smbus", E1000_STAT(stats.mgprc) },
+	{ "dropped_smbus", E1000_STAT(stats.mgpdc) },
 };
 
 #define E1000_QUEUE_STATS_LEN 0
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 3655d90..23826c7 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
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
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 3321fb1..fd15f62 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1301,6 +1301,7 @@ struct e1000_ffvt_entry {
 #define E1000_82542_RSSIR       E1000_RSSIR
 #define E1000_82542_KUMCTRLSTA E1000_KUMCTRLSTA
 #define E1000_82542_SW_FW_SYNC E1000_SW_FW_SYNC
+#define E1000_82542_MANC2H      E1000_MANC2H
 
 /* Statistics counters collected by the MAC */
 struct e1000_hw_stats {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7639b4d..0d8fd01 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -464,6 +464,53 @@ e1000_get_hw_control(struct e1000_adapte
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
+		/* XXX stop the hardware watchdog ? */
+
+		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+	}
+}
+
 int
 e1000_up(struct e1000_adapter *adapter)
 {
@@ -475,6 +522,7 @@ e1000_up(struct e1000_adapter *adapter)
 	e1000_set_multi(netdev);
 
 	e1000_restore_vlan(adapter);
+	e1000_init_manageability(adapter);
 
 	e1000_configure_tx(adapter);
 	e1000_setup_rctl(adapter);
@@ -705,14 +753,7 @@ e1000_reset(struct e1000_adapter *adapte
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
@@ -1078,22 +1119,13 @@ e1000_remove(struct pci_dev *pdev)
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
@@ -3615,6 +3647,14 @@ e1000_update_stats(struct e1000_adapter 
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
 
+	/* Management Stats */
+	if (adapter->hw.mac_type > e1000_82544) {
+		adapter->stats.mgptc += E1000_READ_REG(hw, MGTPTC);
+		adapter->stats.mgprc += E1000_READ_REG(hw, MGTPRC);
+		adapter->stats.mgpdc += E1000_READ_REG(hw, MGTPDC);
+	}
+
+
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 #ifdef CONFIG_PCI_MSI
@@ -5027,7 +5067,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, ctrl_ext, rctl, manc, status;
+	uint32_t ctrl, ctrl_ext, rctl, status;
 	uint32_t wufc = adapter->wol;
 #ifdef CONFIG_PM
 	int retval = 0;
@@ -5096,16 +5136,12 @@ e1000_suspend(struct pci_dev *pdev, pm_m
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
@@ -5131,7 +5167,7 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t manc, err;
+	uint32_t err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	e1000_pci_restore_state(adapter);
@@ -5151,19 +5187,13 @@ e1000_resume(struct pci_dev *pdev)
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
@@ -5264,7 +5294,8 @@ static void e1000_io_resume(struct pci_d
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
-	uint32_t manc, swsm;
+
+	e1000_init_manageability(adapter);
 
 	if (netif_running(netdev)) {
 		if (e1000_up(adapter)) {
@@ -5275,26 +5306,14 @@ static void e1000_io_resume(struct pci_d
 
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



---
Auke Kok <auke-jan.h.kok@intel.com>
