From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 2.6-exp] netpoll + fixes to speed/duplex forced settings
Date: Mon, 22 Dec 2003 17:01:17 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312221658410.20044-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Preserve forced speed/duplex settings during close/open sequence.
* Reset PHY when going from autoneg to forced speed/duplex settings
  using ethtool.
* Add netpoll support.


--- net-drivers-2.5-exp/drivers/net/e100.c.orig	2003-12-16 16:49:43.000000000 -0800
+++ net-drivers-2.5-exp/drivers/net/e100.c	2003-12-16 16:53:40.000000000 -0800
@@ -155,7 +155,7 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.11_dev"
+#define DRV_VERSION		"3.0.12_dev"
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2003 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -550,35 +550,6 @@
 	u32 pm_state[16];
 };
 
-static void e100_get_defaults(struct nic *nic)
-{
-	struct param_range rfds = { .min = 64, .max = 256, .count = 64 };
-	struct param_range cbs  = { .min = 64, .max = 256, .count = 64 };
-
-	pci_read_config_byte(nic->pdev, PCI_REVISION_ID, &nic->rev_id);
-	/* MAC type is encoded as rev ID; exception: ICH is treated as 82559 */
-	nic->mac = (nic->flags & ich) ? mac_82559_D101M : nic->rev_id;
-	if(nic->mac == mac_unknown)
-		nic->mac = mac_82557_D100_A;
-
-	nic->params.rfds = rfds; 
-	nic->params.cbs = cbs; 
-	
-	/* Quadwords to DMA into FIFO before starting frame transmit */
-	nic->tx_threshold = 0xE0;
-
-	nic->tx_command = cpu_to_le16(cb_tx | cb_i | cb_tx_sf |
-		((nic->mac >= mac_82558_D101_A4) ? cb_cid : 0));
-
-	/* Template for a freshly allocated RFD */
-	nic->blank_rfd.status = 0;
-	nic->blank_rfd.command = cpu_to_le16(cb_el);
-	nic->blank_rfd.link = 0;
-	nic->blank_rfd.rbd = 0xFFFFFFFF;
-	nic->blank_rfd.actual_size = 0;
-	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
-}
-
 static inline void e100_write_flush(struct nic *nic)
 {
 	/* Flush previous PCI writes through intermediate bridges
@@ -893,6 +864,39 @@
 	mdio_ctrl(netdev->priv, addr, mdi_write, reg, data);
 }
 
+static void e100_get_defaults(struct nic *nic)
+{
+	struct param_range rfds = { .min = 64, .max = 256, .count = 64 };
+	struct param_range cbs  = { .min = 64, .max = 256, .count = 64 };
+
+	pci_read_config_byte(nic->pdev, PCI_REVISION_ID, &nic->rev_id);
+	/* MAC type is encoded as rev ID; exception: ICH is treated as 82559 */
+	nic->mac = (nic->flags & ich) ? mac_82559_D101M : nic->rev_id;
+	if(nic->mac == mac_unknown)
+		nic->mac = mac_82557_D100_A;
+
+	nic->params.rfds = rfds; 
+	nic->params.cbs = cbs; 
+	
+	/* Quadwords to DMA into FIFO before starting frame transmit */
+	nic->tx_threshold = 0xE0;
+
+	nic->tx_command = cpu_to_le16(cb_tx | cb_i | cb_tx_sf |
+		((nic->mac >= mac_82558_D101_A4) ? cb_cid : 0));
+
+	/* Template for a freshly allocated RFD */
+	nic->blank_rfd.command = cpu_to_le16(cb_el);
+	nic->blank_rfd.rbd = 0xFFFFFFFF;
+	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
+
+	/* MII setup */
+	nic->mii.phy_id_mask = 0x1F;
+	nic->mii.reg_num_mask = 0x1F;
+	nic->mii.dev = nic->netdev;
+	nic->mii.mdio_read = mdio_read;
+	nic->mii.mdio_write = mdio_write;
+}
+
 static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct config *config = &cb->u.config;
@@ -989,16 +993,6 @@
 	u32 addr;
 	u16 bmcr, stat, id_lo, id_hi, cong;
 
-	nic->mii.phy_id = 0;
-	nic->mii.advertising = 0;
-	nic->mii.phy_id_mask = 0x1F;
-	nic->mii.reg_num_mask = 0x1F;
-	nic->mii.dev = netdev;
-	nic->mii.full_duplex = 0;
-	nic->mii.force_media = 0;
-	nic->mii.mdio_read = mdio_read;
-	nic->mii.mdio_write = mdio_write;
-	
 	/* Discover phy addr by searching addrs in order {1,0,2,..., 31} */
 	for(addr = 0; addr < 32; addr++) {
 		nic->mii.phy_id = (addr == 0) ? 1 : (addr == 1) ? 0 : addr;
@@ -1038,10 +1032,10 @@
 		mdio_write(netdev, nic->mii.phy_id, MII_NSC_CONG, cong);
 	}
 	
-	/* enable MDI/MDI-X auto-switching */
 	if(nic->mac >= mac_82550_D102)
+		/* enable/disable MDI/MDI-X auto-switching */
 		mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
-			NCONFIG_AUTO_SWITCH);
+			nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);
 
 	return 0;
 }
@@ -1591,6 +1585,16 @@
 }
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void e100_netpoll(struct net_device *netdev)
+{
+	struct nic *nic = netdev->priv;
+	e100_disable_irq(nic);
+	e100_intr(nic->pdev->irq, netdev, NULL);
+	e100_enable_irq(nic);
+}
+#endif
+
 static struct net_device_stats *e100_get_stats(struct net_device *netdev)
 {
 	struct nic *nic = netdev->priv;
@@ -1760,7 +1764,13 @@
 static int e100_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
 	struct nic *nic = netdev->priv;
-	return mii_ethtool_sset(&nic->mii, cmd);
+	int err;
+
+	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, BMCR_RESET);
+	err = mii_ethtool_sset(&nic->mii, cmd);
+	e100_exec_cb(nic, NULL, e100_configure);
+
+	return err;
 }
   
 static void e100_get_drvinfo(struct net_device *netdev,
@@ -2116,6 +2126,9 @@
 	netdev->poll = e100_poll;
 	netdev->weight = E100_NAPI_WEIGHT;
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = e100_netpoll;
+#endif
 
 	nic = netdev->priv;
 	nic->netdev = netdev;
