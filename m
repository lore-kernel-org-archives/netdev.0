From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH net-next] sundance: Add power management hooks
Date: Sat, 11 Sep 2010 09:23:13 +0000
Message-ID: <20100911092313.GA5887@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42703 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871Ab0IKJXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Sep 2010 05:23:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch to adds support for PM hooks into sundance driver

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 3fa9497..7dfdbee 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1757,11 +1757,59 @@ static void __devexit sundance_remove1 (struct pci_dev *pdev)
 	}
 }
 
+#ifdef CONFIG_PM
+
+static int sundance_suspend(struct pci_dev *pci_dev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pci_dev);
+
+	if (!netif_running(dev))
+		return 0;
+
+	netdev_close(dev);
+	netif_device_detach(dev);
+
+	pci_save_state(pci_dev);
+	pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state));
+
+	return 0;
+}
+
+static int sundance_resume(struct pci_dev *pci_dev)
+{
+	struct net_device *dev = pci_get_drvdata(pci_dev);
+	int err = 0;
+
+	if (!netif_running(dev))
+		return 0;
+
+	pci_set_power_state(pci_dev, PCI_D0);
+	pci_restore_state(pci_dev);
+
+	err = netdev_open(dev);
+	if (err) {
+		printk(KERN_ERR "%s: Can't resume interface!\n",
+				dev->name);
+		goto out;
+	}
+
+	netif_device_attach(dev);
+
+out:
+	return err;
+}
+
+#endif /* CONFIG_PM */
+
 static struct pci_driver sundance_driver = {
 	.name		= DRV_NAME,
 	.id_table	= sundance_pci_tbl,
 	.probe		= sundance_probe1,
 	.remove		= __devexit_p(sundance_remove1),
+#ifdef CONFIG_PM
+	.suspend	= sundance_suspend,
+	.resume		= sundance_resume,
+#endif /* CONFIG_PM */
 };
 
 static int __init sundance_init(void)
-- 
1.6.4.4

