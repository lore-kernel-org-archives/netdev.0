From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 4/6] DMFE: WOL fixes:
Date: Sat,  6 Feb 2010 22:19:00 +0200
Message-ID: <1265487542-4447-5-git-send-email-maximlevitsky@gmail.com>
References: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:37418 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756002Ab0BFUTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2010 15:19:18 -0500
In-Reply-To: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Enable wol by default
* Move wol initialization into common function
* use pci_prepare_to_sleep/pci_back_from_sleep

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/net/tulip/dmfe.c |   51 +++++++++++++++++++++++----------------------
 1 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index ee93651..44e1e5d 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1729,6 +1729,26 @@ static void dmfe_ethtool_get_wol(struct net_device *dev,
 }
 
 
+static void dmfe_set_wol(struct net_device *dev, int enabled)
+{
+	struct dmfe_board_info *db = netdev_priv(dev);
+	u32 tmp;
+
+	pci_read_config_dword(db->pdev, 0x40, &tmp);
+	tmp &= ~(DMFE_WOL_LINKCHANGE|DMFE_WOL_MAGICPACKET);
+
+	if (enabled && device_may_wakeup(&db->pdev->dev)) {
+
+		if (db->wol_mode & WAKE_PHY)
+			tmp |= DMFE_WOL_LINKCHANGE;
+		if (db->wol_mode & WAKE_MAGIC)
+			tmp |= DMFE_WOL_MAGICPACKET;
+
+	}
+	pci_write_config_dword(db->pdev, 0x40, tmp);
+}
+
+
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= dmfe_ethtool_get_drvinfo,
 	.get_link               = ethtool_op_get_link,
@@ -1849,7 +1869,8 @@ static int __devinit dmfe_probe(struct pci_dev *pdev,
 	db->chip_id = pdev->device;
 	db->ioaddr = pci_resource_start(pdev, 0);
 	db->chip_revision = pdev->revision;
-	db->wol_mode = 0;
+	db->wol_mode = WAKE_MAGIC;
+	device_set_wakeup_enable(&pdev->dev, 1);
 
 	db->pdev = pdev;
 
@@ -1940,7 +1961,6 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct dmfe_board_info *db = netdev_priv(dev);
-	u32 tmp;
 
 	/* Disable upper layer interface */
 	netif_device_detach(dev);
@@ -1957,45 +1977,26 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	dmfe_free_rxbuffer(db);
 
 	/* Enable WOL */
-	pci_read_config_dword(pci_dev, 0x40, &tmp);
-	tmp &= ~(DMFE_WOL_LINKCHANGE|DMFE_WOL_MAGICPACKET);
-
-	if (db->wol_mode & WAKE_PHY)
-		tmp |= DMFE_WOL_LINKCHANGE;
-	if (db->wol_mode & WAKE_MAGIC)
-		tmp |= DMFE_WOL_MAGICPACKET;
-
-	pci_write_config_dword(pci_dev, 0x40, tmp);
-
-	pci_enable_wake(pci_dev, PCI_D3hot, 1);
-	pci_enable_wake(pci_dev, PCI_D3cold, 1);
+	dmfe_set_wol(dev, 1);
 
 	/* Power down device*/
 	pci_save_state(pci_dev);
-	pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state));
-
+	pci_prepare_to_sleep(pci_dev);
 	return 0;
 }
 
 static int dmfe_resume(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
-	u32 tmp;
 
-	pci_set_power_state(pci_dev, PCI_D0);
+	pci_back_from_sleep(pci_dev);
 	pci_restore_state(pci_dev);
 
 	/* Re-initilize DM910X board */
 	dmfe_hardware_init(dev);
 
 	/* Disable WOL */
-	pci_read_config_dword(pci_dev, 0x40, &tmp);
-
-	tmp &= ~(DMFE_WOL_LINKCHANGE | DMFE_WOL_MAGICPACKET);
-	pci_write_config_dword(pci_dev, 0x40, tmp);
-
-	pci_enable_wake(pci_dev, PCI_D3hot, 0);
-	pci_enable_wake(pci_dev, PCI_D3cold, 0);
+	dmfe_set_wol(dev, 0);
 
 	/* Restart upper layer interface */
 	netif_device_attach(dev);
-- 
1.6.3.3

