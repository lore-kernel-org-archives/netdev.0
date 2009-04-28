From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e100: do not go D3 in shutdown unless system is
	powering off
Date: Tue, 28 Apr 2009 14:45:27 -0700
Message-ID: <20090428214525.1654.27832.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:58688 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753466AbZD1Vpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 17:45:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>

After experimenting with kexec with the last merges after 2.6.29, I've
had some problems when probing e100.  It would not read the eeprom.  After
some bisects, I realized this has been like that since forever (at least
2.6.18).  The problem is that shutdown is doing the same thing that
suspend does and puts the device in D3 state.  I couldn't find a way to
get the device back to a sane state in the probe function.  So, based on
some similar patches from Rafael J. Wysocki for e1000, e1000e, and ixgbe,
I wrote this one for e100.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Acked-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e100.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 5c0b457..0f9ee13 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2728,7 +2728,7 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 #define E100_82552_SMARTSPEED   0x14   /* SmartSpeed Ctrl register */
 #define E100_82552_REV_ANEG     0x0200 /* Reverse auto-negotiation */
 #define E100_82552_ANEG_NOW     0x0400 /* Auto-negotiate now */
-static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
+static void __e100_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
@@ -2749,19 +2749,32 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 			           E100_82552_SMARTSPEED, smartspeed |
 			           E100_82552_REV_ANEG | E100_82552_ANEG_NOW);
 		}
-		if (pci_enable_wake(pdev, PCI_D3cold, true))
-			pci_enable_wake(pdev, PCI_D3hot, true);
+		*enable_wake = true;
 	} else {
-		pci_enable_wake(pdev, PCI_D3hot, false);
+		*enable_wake = false;
 	}
 
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+}
 
-	return 0;
+static int __e100_power_off(struct pci_dev *pdev, bool wake)
+{
+	if (wake) {
+		return pci_prepare_to_sleep(pdev);
+	} else {
+		pci_wake_from_d3(pdev, false);
+		return pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
 
 #ifdef CONFIG_PM
+static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	bool wake;
+	__e100_shutdown(pdev, &wake);
+	return __e100_power_off(pdev, wake);
+}
+
 static int e100_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2792,7 +2805,10 @@ static int e100_resume(struct pci_dev *pdev)
 
 static void e100_shutdown(struct pci_dev *pdev)
 {
-	e100_suspend(pdev, PMSG_SUSPEND);
+	bool wake;
+	__e100_shutdown(pdev, &wake);
+	if (system_state == SYSTEM_POWER_OFF)
+		__e100_power_off(pdev, wake);
 }
 
 /* ------------------ PCI Error Recovery infrastructure  -------------- */

