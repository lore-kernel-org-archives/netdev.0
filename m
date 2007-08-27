From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH] pcnet32: add suspend and resume capability
Date: Sun, 26 Aug 2007 21:22:32 -0700
Message-ID: <1188188552.4748.11.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:64137 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbXH0EW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 00:22:58 -0400
Received: from [192.168.1.2] ([71.117.241.192])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JNF004KN05M2061@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Sun, 26 Aug 2007 23:22:35 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add suspend and resume capability to the driver.
Tested both to ram and to disk on x86_64 platform.

Signed-off-by:  Don Fry <pcnet32@verizon.net>
---
--- linux-2.6.23-rc3/drivers/net/pcnet32.c.orig	2007-08-14 13:52:24.000000000 -0700
+++ linux-2.6.23-rc3/drivers/net/pcnet32.c	2007-08-14 14:16:55.000000000 -0700
@@ -23,11 +23,11 @@
 
 #define DRV_NAME	"pcnet32"
 #ifdef CONFIG_PCNET32_NAPI
-#define DRV_VERSION	"1.33-NAPI"
+#define DRV_VERSION	"1.34-NAPI"
 #else
-#define DRV_VERSION	"1.33"
+#define DRV_VERSION	"1.34"
 #endif
-#define DRV_RELDATE	"27.Jun.2006"
+#define DRV_RELDATE	"14.Aug.2007"
 #define PFX		DRV_NAME ": "
 
 static const char *const version =
@@ -2943,6 +2943,33 @@ static void pcnet32_watchdog(struct net_
 	mod_timer(&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
 }
 
+static int pcnet32_pm_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	if (netif_running(dev)) {
+		netif_device_detach(dev);
+		pcnet32_close(dev);
+	}
+	pci_save_state(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	return 0;
+}
+
+static int pcnet32_pm_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	if (netif_running(dev)) {
+		pcnet32_open(dev);
+		netif_device_attach(dev);
+	}
+	return 0;
+}
+
 static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -2966,6 +2993,8 @@ static struct pci_driver pcnet32_driver 
 	.probe = pcnet32_probe_pci,
 	.remove = __devexit_p(pcnet32_remove_one),
 	.id_table = pcnet32_pci_tbl,
+	.suspend = pcnet32_pm_suspend,
+	.resume = pcnet32_pm_resume,
 };
 
 /* An additional parameter that may be passed in... */


