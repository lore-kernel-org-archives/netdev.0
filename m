From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] NET/e1000: Fix powering off during shutdown
Date: Wed, 15 Apr 2009 20:43:24 -0700
Message-ID: <20090416034323.14634.30701.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:55603 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752579AbZDPDnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 23:43:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Impact: Fix

Prevent e1000 from putting the adapter into D3 during shutdown except when
we're going to power off the system, since doing that may generally cause
problems with kexec to happen (such problems were observed for igb and
forcedeth).  For this purpose seperate e1000_shutdown() from e1000_suspend()
and use the appropriate PCI PM callbacks in both of them.

Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   46 +++++++++++++++++++++++++++++-----------
 1 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4cd8b25..ef12931 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -156,8 +156,8 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
 
-static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
 #ifdef CONFIG_PM
+static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
 static int e1000_resume(struct pci_dev *pdev);
 #endif
 static void e1000_shutdown(struct pci_dev *pdev);
@@ -4601,7 +4601,7 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 	return 0;
 }
 
-static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -4664,22 +4664,18 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
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
 
 	e1000_release_manageability(adapter);
 
+	*enable_wake = !!wufc;
+
 	/* make sure adapter isn't asleep if manageability is enabled */
-	if (adapter->en_mng_pt) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	}
+	if (adapter->en_mng_pt)
+		*enable_wake = true;
 
 	if (hw->phy_type == e1000_phy_igp_3)
 		e1000_phy_powerdown_workaround(hw);
@@ -4693,12 +4689,29 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
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
@@ -4753,7 +4766,14 @@ static int e1000_resume(struct pci_dev *pdev)
 
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

