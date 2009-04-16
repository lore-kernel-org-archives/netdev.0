From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] NET/e1000e: Fix powering off during shutdown
Date: Wed, 15 Apr 2009 20:43:43 -0700
Message-ID: <20090416034343.14634.62484.stgit@localhost.localdomain>
References: <20090416034323.14634.30701.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:54280
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752281AbZDPDoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 23:44:01 -0400
In-Reply-To: <20090416034323.14634.30701.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Impact: Fix

Prevent e1000e from putting the adapter into D3 during shutdown except when
we're going to power off the system, since doing that may generally cause
problems with kexec to happen (such problems were observed for igb and
forcedeth).  For this purpose seperate e1000e_shutdown() from e1000e_suspend()
and use the appropriate PCI PM callbacks in both of them.

Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   59 +++++++++++++++++++++++++++++++++----------
 1 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3b0f087..1693ed1 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4346,7 +4346,7 @@ static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	}
 }
 
-static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -4409,20 +4409,16 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
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
 	/* make sure adapter isn't asleep if manageability is enabled */
-	if (adapter->flags & FLAG_MNG_PT_ENABLED) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	}
+	if (adapter->flags & FLAG_MNG_PT_ENABLED)
+		*enable_wake = true;
 
 	if (adapter->hw.phy.type == e1000_phy_igp_3)
 		e1000e_igp3_phy_powerdown_workaround_ich8lan(&adapter->hw);
@@ -4435,6 +4431,26 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	pci_disable_device(pdev);
 
+	return 0;
+}
+
+static void e1000_power_off(struct pci_dev *pdev, bool sleep, bool wake)
+{
+	if (sleep && wake) {
+		pci_prepare_to_sleep(pdev);
+		return;
+	}
+
+	pci_wake_from_d3(pdev, wake);
+	pci_set_power_state(pdev, PCI_D3hot);
+}
+
+static void e1000_complete_shutdown(struct pci_dev *pdev, bool sleep,
+                                    bool wake)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
 	/*
 	 * The pci-e switch on some quad port adapters will report a
 	 * correctable error when the MAC transitions from D0 to D3.  To
@@ -4450,14 +4466,12 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_write_config_word(us_dev, pos + PCI_EXP_DEVCTL,
 		                      (devctl & ~PCI_EXP_DEVCTL_CERE));
 
-		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+		e1000_power_off(pdev, sleep, wake);
 
 		pci_write_config_word(us_dev, pos + PCI_EXP_DEVCTL, devctl);
 	} else {
-		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+		e1000_power_off(pdev, sleep, wake);
 	}
-
-	return 0;
 }
 
 static void e1000e_disable_l1aspm(struct pci_dev *pdev)
@@ -4486,6 +4500,18 @@ static void e1000e_disable_l1aspm(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_PM
+static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int retval;
+	bool wake;
+
+	retval = __e1000_shutdown(pdev, &wake);
+	if (!retval)
+		e1000_complete_shutdown(pdev, true, wake);
+
+	return retval;
+}
+
 static int e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4549,7 +4575,12 @@ static int e1000_resume(struct pci_dev *pdev)
 
 static void e1000_shutdown(struct pci_dev *pdev)
 {
-	e1000_suspend(pdev, PMSG_SUSPEND);
+	bool wake = false;
+
+	__e1000_shutdown(pdev, &wake);
+
+	if (system_state == SYSTEM_POWER_OFF)
+		e1000_complete_shutdown(pdev, false, wake);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER

