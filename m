From: akpm@linux-foundation.org
Subject: [patch 10/19] dmfe: add support for Wake on lan
Date: Tue, 06 Mar 2007 02:41:54 -0800
Message-ID: <200703061041.l26AfsYT019762@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	maximlevitsky@gmail.com, val_henson@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34696 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934061AbXCFKmf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxim Levitsky <maximlevitsky@gmail.com>

Add support for WOL on Magic Packet and on link change

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/dmfe.c |   66 +++++++++++++++++++++++++++++++++++--
 1 file changed, 64 insertions(+), 2 deletions(-)

diff -puN drivers/net/tulip/dmfe.c~dmfe-add-support-for-wake-on-lan drivers/net/tulip/dmfe.c
--- a/drivers/net/tulip/dmfe.c~dmfe-add-support-for-wake-on-lan
+++ a/drivers/net/tulip/dmfe.c
@@ -122,6 +122,11 @@
 #define DM9801_NOISE_FLOOR 8
 #define DM9802_NOISE_FLOOR 5
 
+#define DMFE_WOL_LINKCHANGE	0x20000000
+#define DMFE_WOL_SAMPLEPACKET	0x10000000
+#define DMFE_WOL_MAGICPACKET	0x08000000
+
+
 #define DMFE_10MHF      0
 #define DMFE_100MHF     1
 #define DMFE_10MFD      4
@@ -248,6 +253,7 @@ struct dmfe_board_info {
 	u8 wait_reset;			/* Hardware failed, need to reset */
 	u8 dm910x_chk_mode;		/* Operating mode check */
 	u8 first_in_callback;		/* Flag to record state */
+	u8 wol_mode;			/* user WOL settings */
 	struct timer_list timer;
 
 	/* System defined statistic counter */
@@ -428,6 +434,7 @@ static int __devinit dmfe_init_one (stru
 	db->chip_id = ent->driver_data;
 	db->ioaddr = pci_resource_start(pdev, 0);
 	db->chip_revision = dev_rev;
+	db->wol_mode = 0;
 
 	db->pdev = pdev;
 
@@ -1062,7 +1069,11 @@ static void dmfe_set_filter_mode(struct 
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
-static void netdev_get_drvinfo(struct net_device *dev,
+/*
+ * 	Ethtool interace
+ */
+
+static void dmfe_ethtool_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
 	struct dmfe_board_info *np = netdev_priv(dev);
@@ -1076,9 +1087,35 @@ static void netdev_get_drvinfo(struct ne
 			dev->base_addr, dev->irq);
 }
 
+static int dmfe_ethtool_set_wol(struct net_device *dev,
+				struct ethtool_wolinfo *wolinfo)
+{
+	struct dmfe_board_info *db = netdev_priv(dev);
+
+	if (wolinfo->wolopts & (WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
+		   		WAKE_ARP | WAKE_MAGICSECURE))
+		   return -EOPNOTSUPP;
+
+	db->wol_mode = wolinfo->wolopts;
+	return 0;
+}
+
+static void dmfe_ethtool_get_wol(struct net_device *dev,
+				 struct ethtool_wolinfo *wolinfo)
+{
+	struct dmfe_board_info *db = netdev_priv(dev);
+
+	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
+	wolinfo->wolopts = db->wol_mode;
+	return;
+}
+
+
 static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= netdev_get_drvinfo,
+	.get_drvinfo		= dmfe_ethtool_get_drvinfo,
 	.get_link               = ethtool_op_get_link,
+	.set_wol		= dmfe_ethtool_set_wol,
+	.get_wol		= dmfe_ethtool_get_wol,
 };
 
 /*
@@ -2052,6 +2089,7 @@ static int dmfe_suspend(struct pci_dev *
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct dmfe_board_info *db = netdev_priv(dev);
+	u32 tmp;
 
 	/* Disable upper layer interface */
 	netif_device_detach(dev);
@@ -2067,6 +2105,20 @@ static int dmfe_suspend(struct pci_dev *
 	/* Fre RX buffers */
 	dmfe_free_rxbuffer(db);
 
+	/* Enable WOL */
+	pci_read_config_dword(pci_dev, 0x40, &tmp);
+	tmp &= ~(DMFE_WOL_LINKCHANGE|DMFE_WOL_MAGICPACKET);
+
+	if (db->wol_mode & WAKE_PHY)
+		tmp |= DMFE_WOL_LINKCHANGE;
+	if (db->wol_mode & WAKE_MAGIC)
+		tmp |= DMFE_WOL_MAGICPACKET;
+
+	pci_write_config_dword(pci_dev, 0x40, tmp);
+
+	pci_enable_wake(pci_dev, PCI_D3hot, 1);
+	pci_enable_wake(pci_dev, PCI_D3cold, 1);
+
 	/* Power down device*/
 	pci_set_power_state(pci_dev, pci_choose_state (pci_dev,state));
 	pci_save_state(pci_dev);
@@ -2077,6 +2129,7 @@ static int dmfe_suspend(struct pci_dev *
 static int dmfe_resume(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
+	u32 tmp;
 
 	pci_restore_state(pci_dev);
 	pci_set_power_state(pci_dev, PCI_D0);
@@ -2084,6 +2137,15 @@ static int dmfe_resume(struct pci_dev *p
 	/* Re-initilize DM910X board */
 	dmfe_init_dm910x(dev);
 
+	/* Disable WOL */
+	pci_read_config_dword(pci_dev, 0x40, &tmp);
+
+	tmp &= ~(DMFE_WOL_LINKCHANGE | DMFE_WOL_MAGICPACKET);
+	pci_write_config_dword(pci_dev, 0x40, tmp);
+
+	pci_enable_wake(pci_dev, PCI_D3hot, 0);
+	pci_enable_wake(pci_dev, PCI_D3cold, 0);
+
 	/* Restart upper layer interface */
 	netif_device_attach(dev);
 
_
