From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2 2/5] stmmac: pci: convert to use dev_pm_ops
Date: Mon,  3 Nov 2014 15:02:14 +0200
Message-ID: <1415019737-32736-3-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9801 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355AbaKCNC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 08:02:58 -0500
In-Reply-To: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert system PM callbacks to use dev_pm_ops. In addition remove the PCI calls
related to a power state since the bus code cares about this already.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 27 ++++++++++--------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index e45794d..f19ac8e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -150,30 +150,26 @@ static void stmmac_pci_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-#ifdef CONFIG_PM
-static int stmmac_pci_suspend(struct pci_dev *pdev, pm_message_t state)
+#ifdef CONFIG_PM_SLEEP
+static int stmmac_pci_suspend(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	int ret;
 
-	ret = stmmac_suspend(ndev);
-	pci_save_state(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
-	return ret;
+	return stmmac_suspend(ndev);
 }
 
-static int stmmac_pci_resume(struct pci_dev *pdev)
+static int stmmac_pci_resume(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *ndev = pci_get_drvdata(pdev);
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-
 	return stmmac_resume(ndev);
 }
 #endif
 
+static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_pci_suspend, stmmac_pci_resume);
+
 #define STMMAC_VENDOR_ID 0x700
 #define STMMAC_DEVICE_ID 0x1108
 
@@ -190,10 +186,9 @@ struct pci_driver stmmac_pci_driver = {
 	.id_table = stmmac_id_table,
 	.probe = stmmac_pci_probe,
 	.remove = stmmac_pci_remove,
-#ifdef CONFIG_PM
-	.suspend = stmmac_pci_suspend,
-	.resume = stmmac_pci_resume,
-#endif
+	.driver         = {
+		.pm     = &stmmac_pm_ops,
+	},
 };
 
 MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet PCI driver");
-- 
2.1.1
