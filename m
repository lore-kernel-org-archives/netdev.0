From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFT][PATCH 3/3] NET/ixgbe: Fix powering off during shutdown
Date: Sat, 4 Apr 2009 23:41:57 +0200
Message-ID: <200904042341.57942.rjw@sisk.pl>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757475AbZDDVmX@vger.kernel.org>
In-Reply-To: <200904042337.31706.rjw@sisk.pl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>

Impact: Fix

Prevent ixgbe from putting the adapter into D3 during shutdown
except when we're going to power off the system, since doing that may
generally cause problems with kexec to happen (such problems were
observed for igb and forcedeth).  For this purpose seperate
ixgbe_shutdown() from ixgbe_suspend() and use the appropriate PCI
PM callbacks in both of them.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/ixgbe/ixgbe_main.c |   36 ++++++++++++++++++++++++++++++++----
 1 file changed, 32 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_main.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_main.c
@@ -3611,9 +3611,9 @@ static int ixgbe_resume(struct pci_dev *
 
 	return 0;
 }
-
 #endif /* CONFIG_PM */
-static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
+
+static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -3672,18 +3672,46 @@ static int ixgbe_suspend(struct pci_dev 
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
+	*enable_wake = !!wufc;
+
 	ixgbe_release_hw_control(adapter);
 
 	pci_disable_device(pdev);
 
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int retval;
+	bool wake;
+
+	retval = __ixgbe_shutdown(pdev, &wake);
+	if (retval)
+		return retval;
+
+	if (wake) {
+		pci_prepare_to_sleep(pdev);
+	} else {
+		pci_wake_from_d3(pdev, false);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 
 	return 0;
 }
+#endif /* CONFIG_PM */
 
 static void ixgbe_shutdown(struct pci_dev *pdev)
 {
-	ixgbe_suspend(pdev, PMSG_SUSPEND);
+	bool wake;
+
+	__ixgbe_shutdown(pdev, &wake);
+
+	if (system_state == SYSTEM_POWER_OFF) {
+		pci_wake_from_d3(pdev, wake);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
 
 /**
