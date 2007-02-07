From: Levitsky Maxim <maximlevitsky@yahoo.com>
Subject: [PATCH] [005] dmfe : Add support for wake-on-lan [FIXED]
Date: Wed, 7 Feb 2007 12:36:56 -0800 (PST)
Message-ID: <397230.56357.qm@web38501.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: tori@unhappy.mine.nu, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38501.mail.mud.yahoo.com ([209.191.125.47]:37254 "HELO
	web38501.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161418AbXBGUg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 15:36:57 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello , I just noticed a error in my patch , just a mistake , sorry please

in dmfe_resume I mixed DMFE_WOL_LINKCHANGE | DMFE_WOL_MAGICPACKET , and WAKE_PHY | WAKE_MAGIC

here goes updated patch:

From: Maxim Levitsky <maximlevitsky@yahoo.com>
Subject: [PATCH] [NET] [005] dmfe : Add support for wake-on-lan

Adds support for wake on lan feature

Signed-off-by: Maxim Levitsky <maximlevitsky@yahoo.com>

---

This board supports WOL on magic packet / link change / specific packet
This adds support for WOL on magic packet / link change

Note : WOL is enabled when you suspend system ether to disk or ram, and is not enabled when you
turn system off


--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c	2007-02-07 18:53:19.000000000 +0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c	2007-02-07 18:55:44.000000000 +0200
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
@@ -242,6 +247,7 @@ struct dmfe_board_info {
 	u8 wait_reset;			/* Hardware failed, need to reset */
 	u8 dm910x_chk_mode;		/* Operating mode check */
 	u8 first_in_callback;		/* Flag to record state */
+	u8 wol_mode;			/* user WOL settings */
 	struct timer_list timer;
 
 	/* System defined statistic counter */
@@ -423,6 +429,7 @@ static int __devinit dmfe_init_one (stru
 	db->chip_id = ent->driver_data;
 	db->ioaddr = pci_resource_start(pdev, 0);
 	db->chip_revision = dev_rev;
+	db->wol_mode = 0;
 
 	db->pdev = pdev;
 
@@ -1054,7 +1061,11 @@ static void dmfe_set_filter_mode(struct 
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
@@ -1068,9 +1079,35 @@ static void netdev_get_drvinfo(struct ne
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
@@ -2046,6 +2083,20 @@ static int dmfe_suspend(struct pci_dev *
     /* Fre RX buffers */
     dmfe_free_rxbuffer(db);
 
+    /* Enable WOL */
+    pci_read_config_dword(pci_dev, 0x40, &tmp);
+    tmp &= ~(DMFE_WOL_LINKCHANGE|DMFE_WOL_MAGICPACKET);
+    
+    if (db->wol_mode & WAKE_PHY)
+	    tmp |= DMFE_WOL_LINKCHANGE;
+    if (db->wol_mode & WAKE_MAGIC)
+	    tmp |= DMFE_WOL_MAGICPACKET;
+    
+    pci_write_config_dword(pci_dev, 0x40, tmp);
+    
+    pci_enable_wake(pci_dev, PCI_D3hot, 1);
+    pci_enable_wake(pci_dev, PCI_D3cold, 1);
+    
     /* Power down device*/
     pci_set_power_state(pci_dev ,  pci_choose_state(pci_dev,state));
     pci_save_state(pci_dev);
@@ -2064,6 +2115,15 @@ static int dmfe_resume(struct pci_dev *p
     /* Re-initilize DM910X board */
     dmfe_init_dm910x(dev);
         
+    /* Disable WOL */
+    pci_read_config_dword(pci_dev, 0x40, &tmp);
+    
+    tmp &= (DMFE_WOL_LINKCHANGE | DMFE_WOL_MAGICPACKET);
+    pci_write_config_dword(pci_dev, 0x40, tmp);
+    
+    pci_enable_wake(pci_dev, PCI_D3hot, 0);
+    pci_enable_wake(pci_dev, PCI_D3cold, 0);
+    
     /* Restart upper layer interface */
     netif_device_attach(dev);
 



 
____________________________________________________________________________________
No need to miss a message. Get email on-the-go 
with Yahoo! Mail for Mobile. Get started.
http://mobile.yahoo.com/mail 
