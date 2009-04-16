From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] NET/ixgbe: Fix powering off during shutdown
Date: Wed, 15 Apr 2009 20:44:01 -0700
Message-ID: <20090416034401.14634.77826.stgit@localhost.localdomain>
References: <20090416034323.14634.30701.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:36679 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752281AbZDPDoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 23:44:19 -0400
In-Reply-To: <20090416034323.14634.30701.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Impact: Fix

Prevent ixgbe from putting the adapter into D3 during shutdown except when
we're going to power off the system, since doing that may generally cause
problems with kexec to happen (such problems were observed for igb and
forcedeth).  For this purpose seperate ixgbe_shutdown() from ixgbe_suspend()
and use the appropriate PCI PM callbacks in both of them.

Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   36 ++++++++++++++++++++++++++++++++----
 1 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 11fd153..febde45 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3612,9 +3612,9 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
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
@@ -3673,18 +3673,46 @@ static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
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

