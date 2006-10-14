From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATHC] e100: fix reboot -f with netconsole enabled
Date: Sat, 14 Oct 2006 10:00:28 -0700
Message-ID: <453117AC.90906@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42125 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1422732AbWJNRBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2006 13:01:46 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


e100: FIX: fix netconsole fast reboot attached to e100

When rebooting with netconsole over e100, the driver shutdown code
would deadlock with netpoll. Reduce shutdown code to a bare minimum
while retaining WoL and suspend functionality.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

  drivers/net/e100.c |   50 ++++++++++++++++++++++++++-----------------
  1 file changed, 31 insertions(+), 19 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 27d5d2f..a3a08a5 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2039,7 +2039,6 @@ static int e100_change_mtu(struct net_de
  	return 0;
  }

-#ifdef CONFIG_PM
  static int e100_asf(struct nic *nic)
  {
  	/* ASF can be enabled from eeprom */
@@ -2048,7 +2047,6 @@ static int e100_asf(struct nic *nic)
  	   !(nic->eeprom[eeprom_config_asf] & eeprom_gcl) &&
  	   ((nic->eeprom[eeprom_smbus_addr] & 0xFF) != 0xFE));
  }
-#endif

  static int e100_up(struct nic *nic)
  {
@@ -2715,34 +2713,32 @@ static void __devexit e100_remove(struct
  	}
  }

+#ifdef CONFIG_PM
  static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
  {
  	struct net_device *netdev = pci_get_drvdata(pdev);
  	struct nic *nic = netdev_priv(netdev);

-	if (netif_running(netdev))
-		e100_down(nic);
-	e100_hw_reset(nic);
-	netif_device_detach(netdev);
+	netif_poll_disable(nic->netdev);
+	del_timer_sync(&nic->watchdog);
+	netif_carrier_off(nic->netdev);

-#ifdef CONFIG_PM
  	pci_save_state(pdev);
-	if (nic->flags & (wol_magic | e100_asf(nic)))
-#else
-	if (nic->flags & (wol_magic))
-#endif
-		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
-	else
-		/* disable PME */
-		pci_enable_wake(pdev, 0, 0);
+
+	if ((nic->flags & wol_magic) | e100_asf(nic)) {
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+	}

  	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	pci_set_power_state(pdev, PCI_D3hot);

  	return 0;
  }

-#ifdef CONFIG_PM
  static int e100_resume(struct pci_dev *pdev)
  {
  	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2764,7 +2760,23 @@ #endif /* CONFIG_PM */

  static void e100_shutdown(struct pci_dev *pdev)
  {
-	e100_suspend(pdev, PMSG_SUSPEND);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+	netif_poll_disable(nic->netdev);
+	del_timer_sync(&nic->watchdog);
+	netif_carrier_off(nic->netdev);
+
+	if ((nic->flags & wol_magic) | e100_asf(nic)) {
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+	}
+
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
  }

  /* ------------------ PCI Error Recovery infrastructure  -------------- */
@@ -2848,9 +2860,9 @@ static struct pci_driver e100_driver = {
  	.id_table =     e100_id_table,
  	.probe =        e100_probe,
  	.remove =       __devexit_p(e100_remove),
+#ifdef CONFIG_PM
  	/* Power Management hooks */
  	.suspend =      e100_suspend,
-#ifdef CONFIG_PM
  	.resume =       e100_resume,
  #endif
  	.shutdown =     e100_shutdown,
