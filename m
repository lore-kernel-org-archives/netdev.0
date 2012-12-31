From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 06/15] via-rhine: The Great Renaming.
Date: Mon, 31 Dec 2012 16:25:40 +0100
Message-ID: <1356967549-5056-7-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54113 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab2LaPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:44 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

- rhine_dmi_table --> rhine_dmi_table_quirk_avoid_d3
- rhine_ethop_*()
  (clarify layering by renaming parts)
- rqWOL --> rqHaveWOL
  (improves clarity - WOL is not "quirky", we simply have it)
- rhine_cleanup() --> rhine_exit()
  These are specific handlers meant to serve the module_init()/module_exit()
  interface, thus there's no reason to have them named differently
  from the interface that they cover
  - until a rename of module_*() happens to come along, that is...
- rhine_shutdown() --> rhine_shutdown_and_keep_wol()
- correct to rhine_update_rx_crc_and_missed_errors()

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   47 ++++++++++++++++++---------------
 1 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 4162649..053375b 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -255,7 +255,7 @@ enum rhine_revs {
 };
 
 enum rhine_quirks {
-	rqWOL		= 0x0001,	/* Wake-On-LAN support */
+	rqHaveWOL	= 0x0001,	/* Wake-On-LAN support */
 	rqForceReset	= 0x0002,
 	rq6patterns	= 0x0040,	/* 6 instead of 4 patterns for WOL */
 	rqStatusWBRace	= 0x0080,	/* Tx Status Writeback Error possible */
@@ -571,7 +571,7 @@ static void rhine_power_init(struct net_device *dev)
 	void __iomem *ioaddr = rp->base;
 	u16 wolstat;
 
-	if (rp->quirks & rqWOL) {
+	if (rp->quirks & rqHaveWOL) {
 		/* Make sure chip is in power state D0 */
 		iowrite8(ioread8(ioaddr + StickyHW) & 0xFC, ioaddr + StickyHW);
 
@@ -689,7 +689,7 @@ static void rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 #endif
 
 	/* Turn off EEPROM-controlled wake-up (magic packet) */
-	if (rp->quirks & rqWOL)
+	if (rp->quirks & rqHaveWOL)
 		iowrite8(ioread8(ioaddr + ConfigA) & 0xFC, ioaddr + ConfigA);
 
 }
@@ -744,7 +744,8 @@ static void rhine_tx_err(struct rhine_private *rp, u32 status)
 	rhine_restart_tx(dev);
 }
 
-static void rhine_update_rx_crc_and_missed_errord(struct rhine_private *rp)
+static void
+rhine_update_rx_crc_and_missed_errors(struct rhine_private *rp)
 {
 	void __iomem *ioaddr = rp->base;
 	struct net_device_stats *stats = &rp->dev->stats;
@@ -814,7 +815,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 
 	if (status & IntrStatsMax) {
 		spin_lock(&rp->lock);
-		rhine_update_rx_crc_and_missed_errord(rp);
+		rhine_update_rx_crc_and_missed_errors(rp);
 		spin_unlock(&rp->lock);
 	}
 
@@ -895,7 +896,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		io_size = 128;
 	}
 	else if (pdev->revision >= VT6102) {
-		quirks = rqWOL | rqForceReset;
+		quirks = rqHaveWOL | rqForceReset;
 		if (pdev->revision < VT6105) {
 			name = "Rhine II";
 			quirks |= rqStatusWBRace;	/* Rhine-II exclusive */
@@ -2033,7 +2034,7 @@ static struct net_device_stats *rhine_get_stats(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 
 	spin_lock_bh(&rp->lock);
-	rhine_update_rx_crc_and_missed_errord(rp);
+	rhine_update_rx_crc_and_missed_errors(rp);
 	spin_unlock_bh(&rp->lock);
 
 	return &dev->stats;
@@ -2149,11 +2150,12 @@ static void netdev_set_msglevel(struct net_device *dev, u32 value)
 	rp->msg_enable = value;
 }
 
-static void rhine_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+static void
+rhine_ethop_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
-	if (!(rp->quirks & rqWOL))
+	if (!(rp->quirks & rqHaveWOL))
 		return;
 
 	spin_lock_irq(&rp->lock);
@@ -2163,13 +2165,14 @@ static void rhine_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	spin_unlock_irq(&rp->lock);
 }
 
-static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+static int
+rhine_ethop_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	u32 support = WAKE_PHY | WAKE_MAGIC |
 		      WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
 
-	if (!(rp->quirks & rqWOL))
+	if (!(rp->quirks & rqHaveWOL))
 		return -EINVAL;
 
 	if (wol->wolopts & ~support)
@@ -2190,8 +2193,8 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
-	.get_wol		= rhine_get_wol,
-	.set_wol		= rhine_set_wol,
+	.get_wol		= rhine_ethop_get_wol,
+	.set_wol		= rhine_ethop_set_wol,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
@@ -2254,13 +2257,14 @@ static void rhine_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
-static void rhine_shutdown (struct pci_dev *pdev)
+static void
+rhine_shutdown_and_keep_wol(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	if (!(rp->quirks & rqWOL))
+	if (!(rp->quirks & rqHaveWOL))
 		return; /* Nothing to do for non-WOL adapters */
 
 	rhine_power_init(dev);
@@ -2321,7 +2325,7 @@ static int rhine_suspend(struct device *device)
 
 	netif_device_detach(dev);
 
-	rhine_shutdown(pdev);
+	rhine_shutdown_and_keep_wol(pdev);
 
 	return 0;
 }
@@ -2393,11 +2397,11 @@ static struct pci_driver rhine_driver = {
 	.id_table	= rhine_pci_tbl,
 	.probe		= rhine_init_one,
 	.remove		= rhine_remove_one,
-	.shutdown	= rhine_shutdown,
+	.shutdown	= rhine_shutdown_and_keep_wol,
 	.driver.pm	= RHINE_PM_OPS,
 };
 
-static struct dmi_system_id __initdata rhine_dmi_table[] = {
+static struct dmi_system_id __initdata rhine_dmi_table_quirk_avoid_d3[] = {
 	{
 		.ident = "EPIA-M",
 		.matches = {
@@ -2421,7 +2425,7 @@ static int __init rhine_init(void)
 #ifdef MODULE
 	pr_info("%s\n", version);
 #endif
-	if (dmi_check_system(rhine_dmi_table)) {
+	if (dmi_check_system(rhine_dmi_table_quirk_avoid_d3)) {
 		/* these BIOSes fail at PXE boot if chip is in D3 */
 		avoid_D3 = true;
 		pr_warn("Broken BIOS detected, avoid_D3 enabled\n");
@@ -2433,11 +2437,12 @@ static int __init rhine_init(void)
 }
 
 
-static void __exit rhine_cleanup(void)
+static void __exit
+rhine_exit(void)
 {
 	pci_unregister_driver(&rhine_driver);
 }
 
 
 module_init(rhine_init);
-module_exit(rhine_cleanup);
+module_exit(rhine_exit);
-- 
1.7.2.5
