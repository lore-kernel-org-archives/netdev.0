From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 3/3] dl2k: Implement suspend
Date: Tue, 17 Nov 2015 18:28:18 +0100
Message-ID: <1447781298-19785-3-git-send-email-linux@rainbow-software.org>
References: <1447781298-19785-1-git-send-email-linux@rainbow-software.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.gsystem.sk ([62.176.172.50]:56228 "EHLO gsystem.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752901AbbKQR2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 12:28:30 -0500
In-Reply-To: <1447781298-19785-1-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add suspend/resume support to dl2k driver.
Tested on Asus NX1101 (IP1000A) and D-Link DGE-550T (DL-2000).

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/dlink/dl2k.c |   46 +++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 9e9baa0..b53dfa7 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1824,11 +1824,57 @@ rio_remove1 (struct pci_dev *pdev)
 	}
 }
 
+#ifdef CONFIG_PM
+static int rio_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct netdev_private *np = netdev_priv(dev);
+
+	pci_save_state(pdev);
+
+	if (netif_running(dev)) {
+		netif_device_detach(dev);
+		del_timer_sync(&np->timer);
+		rio_hw_stop(dev);
+		free_list(dev);
+	}
+
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+static int rio_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct netdev_private *np = netdev_priv(dev);
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	if (netif_running(dev)) {
+		alloc_list(dev);
+		rio_hw_init(dev);
+		np->timer.expires = jiffies + 1 * HZ;
+		add_timer(&np->timer);
+		netif_device_attach(dev);
+		dl2k_enable_int(np);
+	}
+
+	return 0;
+}
+
+#endif /* CONFIG_PM */
+
 static struct pci_driver rio_driver = {
 	.name		= "dl2k",
 	.id_table	= rio_pci_tbl,
 	.probe		= rio_probe1,
 	.remove		= rio_remove1,
+#ifdef CONFIG_PM
+	.suspend	= rio_suspend,
+	.resume		= rio_resume,
+#endif /* CONFIG_PM */
 };
 
 module_pci_driver(rio_driver);
-- 
Ondrej Zary
