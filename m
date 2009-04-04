From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFT][PATCH 1/3] NET/e1000: Fix powering off during shutdown
Date: Sat, 4 Apr 2009 23:39:18 +0200
Message-ID: <200904042339.19074.rjw@sisk.pl>
References: <200904042337.31706.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Yinghai Lu <yinghai@kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:38430 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755096AbZDDVlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Apr 2009 17:41:20 -0400
In-Reply-To: <200904042337.31706.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Impact: Fix

Prevent e1000 from putting the adapter into D3 during shutdown
except when we're going to power off the system, since doing that may
generally cause problems with kexec to happen (such problems were
observed for igb and forcedeth).  For this purpose seperate
e1000_shutdown() from e1000_suspend() and use the appropriate PCI
PM callbacks in both of them.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/e1000/e1000_main.c |   44 +++++++++++++++++++++++++++++------------
 1 file changed, 32 insertions(+), 12 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -4583,7 +4583,7 @@ int e1000_set_spd_dplx(struct e1000_adap
 	return 0;
 }
 
-static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -4646,22 +4646,18 @@ static int e1000_suspend(struct pci_dev 
 
 		ew32(WUC, E1000_WUC_PME_EN);
 		ew32(WUFC, wufc);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
 		ew32(WUC, 0);
 		ew32(WUFC, 0);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
+	*enable_wake = !!wufc;
+
 	e1000_release_manageability(adapter);
 
 	/* make sure adapter isn't asleep if manageability is enabled */
-	if (adapter->en_mng_pt) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	}
+	if (adapter->en_mng_pt)
+		*enable_wake = true;
 
 	if (hw->phy_type == e1000_phy_igp_3)
 		e1000_phy_powerdown_workaround(hw);
@@ -4675,12 +4671,29 @@ static int e1000_suspend(struct pci_dev 
 
 	pci_disable_device(pdev);
 
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
 	return 0;
 }
 
 #ifdef CONFIG_PM
+static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int retval;
+	bool wake;
+
+	retval = __e1000_shutdown(pdev, &wake);
+	if (retval)
+		return retval;
+
+	if (wake) {
+		pci_prepare_to_sleep(pdev);
+	} else {
+		pci_wake_from_d3(pdev, false);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
+
+	return 0;
+}
+
 static int e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4735,7 +4748,14 @@ static int e1000_resume(struct pci_dev *
 
 static void e1000_shutdown(struct pci_dev *pdev)
 {
-	e1000_suspend(pdev, PMSG_SUSPEND);
+	bool wake;
+
+	__e1000_shutdown(pdev, &wake);
+
+	if (system_state == SYSTEM_POWER_OFF) {
+		pci_wake_from_d3(pdev, wake);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
