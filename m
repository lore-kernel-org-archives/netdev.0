From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] e100: do not go D3 in shutdown unless system is powering off
Date: Mon, 20 Apr 2009 11:27:01 -0300
Message-ID: <1240237621-11415-1-git-send-email-cascardo@holoscopio.com>
Cc: rjw@sisk.pl, linux-kernel@vger.kernel.org,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756378AbZDTO1Z@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After experimenting with kexec with the last merges after 2.6.29, I've
had some problems when probing e100. It would not read the eeprom. After
some bisects, I realized this has been like that since forever (at least
2.6.18). The problem is that shutdown is doing the same thing that
suspend does and puts the device in D3 state. I couldn't find a way to
get the device back to a sane state in the probe function. So, based on
some similar patches from Rafael J. Wysocki for e1000, e1000e and ixgbe,
I wrote this one for e100.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 drivers/net/e100.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c0f8443..3db7b29 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2728,7 +2728,7 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 #define E100_82552_SMARTSPEED   0x14   /* SmartSpeed Ctrl register */
 #define E100_82552_REV_ANEG     0x0200 /* Reverse auto-negotiation */
 #define E100_82552_ANEG_NOW     0x0400 /* Auto-negotiate now */
-static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __e100_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
@@ -2749,19 +2749,31 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
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
 
 	return 0;
 }
 
+static void __e100_power_off(struct pci_dev *pdev, bool wake)
+{
+	pci_enable_wake(pdev, PCI_D3hot, wake);
+	pci_set_power_state(pdev, PCI_D3hot);
+}
+
 #ifdef CONFIG_PM
+static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	bool wake;
+	int retval = __e100_shutdown(pdev, &wake);
+	__e100_power_off(pdev, wake);
+	return retval;
+}
+
 static int e100_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2792,7 +2804,10 @@ static int e100_resume(struct pci_dev *pdev)
 
 static void e100_shutdown(struct pci_dev *pdev)
 {
-	e100_suspend(pdev, PMSG_SUSPEND);
+	bool wake;
+	__e100_shutdown(pdev, &wake);
+	if (system_state == SYSTEM_POWER_OFF)
+		__e100_power_off(pdev, wake);
 }
 
 /* ------------------ PCI Error Recovery infrastructure  -------------- */
-- 
1.6.2.2
