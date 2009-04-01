From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 5/5] net/igb: Fix kexec with igb (rev. 3)
Date: Wed, 01 Apr 2009 00:23:50 -0700
Message-ID: <20090401072250.3461.90483.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:55398 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753249AbZDAHYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:24:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Impact: Fix

Yinghai Lu found one system with 82575EB where, in the kernel that is
kexeced, probe igb failed with -2, the reason being that the adapter
could not be brought back from D3 by the kexec kernel, most probably
due to quirky hardware (it looks like the same behavior happened on
forcedeth).

Prevent igb from putting the adapter into D3 during shutdown except
when we going to power off the system.  For this purpose, seperate
igb_shutdown() from igb_suspend() and use the appropriate PCI PM
callbacks in both of them.

Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Reported-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   44 +++++++++++++++++++++++++++++++-------------
 1 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 10b095d..03aa959 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -135,8 +135,8 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *, int, int);
 static int igb_set_vf_mac(struct igb_adapter *adapter, int, unsigned char *);
 static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
 
-static int igb_suspend(struct pci_dev *, pm_message_t);
 #ifdef CONFIG_PM
+static int igb_suspend(struct pci_dev *, pm_message_t);
 static int igb_resume(struct pci_dev *);
 #endif
 static void igb_shutdown(struct pci_dev *);
@@ -5060,7 +5060,7 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
 	return 0;
 }
 
-static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
@@ -5119,15 +5119,9 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 		wr32(E1000_WUFC, 0);
 	}
 
-	/* make sure adapter isn't asleep if manageability/wol is enabled */
-	if (wufc || adapter->en_mng_pt) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	} else {
+	*enable_wake = wufc || adapter->en_mng_pt;
+	if (!*enable_wake)
 		igb_shutdown_fiber_serdes_link_82575(hw);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
-	}
 
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
@@ -5135,12 +5129,29 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	pci_disable_device(pdev);
 
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
 	return 0;
 }
 
 #ifdef CONFIG_PM
+static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int retval;
+	bool wake;
+
+	retval = __igb_shutdown(pdev, &wake);
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
 static int igb_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -5193,7 +5204,14 @@ static int igb_resume(struct pci_dev *pdev)
 
 static void igb_shutdown(struct pci_dev *pdev)
 {
-	igb_suspend(pdev, PMSG_SUSPEND);
+	bool wake;
+
+	__igb_shutdown(pdev, &wake);
+
+	if (system_state == SYSTEM_POWER_OFF) {
+		pci_wake_from_d3(pdev, wake);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER

