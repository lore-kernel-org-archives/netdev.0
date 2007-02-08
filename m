From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2.6.20 5/5] dmfe: add support for wake on lan
Date: Thu, 8 Feb 2007 23:16:23 +0200
Message-ID: <200702082316.23974.maximlevitsky@gmail.com>
References: <200702082305.26735.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:41399 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423406AbXBHVTf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:19:35 -0500
Received: by nf-out-0910.google.com with SMTP id o25so990102nfa
        for <netdev@vger.kernel.org>; Thu, 08 Feb 2007 13:19:34 -0800 (PST)
In-Reply-To: <200702082305.26735.maximlevitsky@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2.6.20 5/5] dmfe: add support for wake on lan

This patch adds support for WOL on Magic Packet and on link change

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>


--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c	2007-02-08 22:03:07.000000000 
+0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c	2007-02-08 22:10:57.000000000 
+0200
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
@@ -430,6 +436,7 @@ static int __devinit dmfe_init_one (stru
 	db->chip_id = ent->driver_data;
 	db->ioaddr = pci_resource_start(pdev, 0);
 	db->chip_revision = dev_rev;
+	db->wol_mode = 0;
 
 	db->pdev = pdev;
 
@@ -1064,7 +1071,11 @@ static void dmfe_set_filter_mode(struct 
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
@@ -1078,9 +1089,35 @@ static void netdev_get_drvinfo(struct ne
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
@@ -2056,6 +2093,7 @@ static int dmfe_suspend(struct pci_dev *
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct dmfe_board_info *db = netdev_priv(dev);
+	u32 tmp;
 
 	/* Disable upper layer interface */
 	netif_device_detach (dev);
@@ -2071,6 +2109,20 @@ static int dmfe_suspend(struct pci_dev *
 	/* Fre RX buffers */
 	dmfe_free_rxbuffer (db);
 
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
 	pci_set_power_state (pci_dev, pci_choose_state (pci_dev,state));
 	pci_save_state (pci_dev);
@@ -2081,13 +2133,23 @@ static int dmfe_suspend(struct pci_dev *
 static int dmfe_resume (struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata (pci_dev);
+	u32 tmp;
 
 	pci_restore_state(pci_dev);
 	pci_set_power_state(pci_dev ,PCI_D0);
 
 	/* Re-initilize DM910X board */
 	dmfe_init_dm910x(dev);
+
+	/* Disable WOL */
+	pci_read_config_dword(pci_dev, 0x40, &tmp);
 
+	tmp &= (DMFE_WOL_LINKCHANGE | DMFE_WOL_MAGICPACKET);
+	pci_write_config_dword(pci_dev, 0x40, tmp);
+
+	pci_enable_wake(pci_dev, PCI_D3hot, 0);
+	pci_enable_wake(pci_dev, PCI_D3cold, 0);
+
 	/* Restart upper layer interface */
 	netif_device_attach(dev);
 
