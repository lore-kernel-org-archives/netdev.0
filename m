From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 1/5] bcma: convert suspend/resume to pm_ops
Date: Fri, 13 Jan 2012 00:00:10 -0800 (PST)
Message-ID: <alpine.LNX.2.00.1201122359400.5860@air.linux-foundation.org>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com> <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:64123 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751049Ab2AMH7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:59:34 -0500
Received: by obcva7 with SMTP id va7so1846102obc.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:59:34 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jan 2012 22:47:01 -0800

.. and avoid doing th eunnecessary PCI operations - the PCI layer will do them for us.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/bcma/host_pci.c |   38 +++++++++++++-------------------------
 1 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 443b83a2fd7a..3aee641c9b7b 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -235,38 +235,27 @@ static void bcma_host_pci_remove(struct pci_dev *dev)
 }
 
 #ifdef CONFIG_PM
-static int bcma_host_pci_suspend(struct pci_dev *dev, pm_message_t state)
+static int bcma_suspend(struct device *dev)
 {
-	/* Host specific */
-	pci_save_state(dev);
-	pci_disable_device(dev);
-	pci_set_power_state(dev, pci_choose_state(dev, state));
-
 	return 0;
 }
 
-static int bcma_host_pci_resume(struct pci_dev *dev)
+static int bcma_resume(struct device *dev)
 {
-	struct bcma_bus *bus = pci_get_drvdata(dev);
-	int err;
-
-	/* Host specific */
-	pci_set_power_state(dev, 0);
-	err = pci_enable_device(dev);
-	if (err)
-		return err;
-	pci_restore_state(dev);
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct bcma_bus *bus = pci_get_drvdata(pdev);
 
-	/* Bus specific */
-	err = bcma_bus_resume(bus);
-	if (err)
-		return err;
+	return bcma_bus_resume(bus);
 
-	return 0;
 }
+
+static SIMPLE_DEV_PM_OPS(bcma_pm_ops, bcma_suspend, bcma_resume);
+#define BCMA_PM_OPS     (&bcma_pm_ops)
+
 #else /* CONFIG_PM */
-# define bcma_host_pci_suspend	NULL
-# define bcma_host_pci_resume	NULL
+
+#define BCMA_PM_OPS     NULL
+
 #endif /* CONFIG_PM */
 
 static DEFINE_PCI_DEVICE_TABLE(bcma_pci_bridge_tbl) = {
@@ -284,8 +273,7 @@ static struct pci_driver bcma_pci_bridge_driver = {
 	.id_table = bcma_pci_bridge_tbl,
 	.probe = bcma_host_pci_probe,
 	.remove = bcma_host_pci_remove,
-	.suspend = bcma_host_pci_suspend,
-	.resume = bcma_host_pci_resume,
+	.driver.pm = BCMA_PM_OPS,
 };
 
 int __init bcma_host_pci_init(void)
-- 
1.7.8.rc2.3.g0911
