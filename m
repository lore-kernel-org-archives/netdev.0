From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] r8169: ethtool message level control
Date: Wed, 9 Mar 2005 11:34:02 -0800
Message-ID: <20050309113402.05d25e49@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add ethtool message level control support. This is the standard way
to enable/disable console log messages.  Also, ratelimit the too much
work at interrupt message, so if under massive packet load the console
doesn't get flooded.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2005-03-09 11:25:04 -08:00
+++ b/drivers/net/r8169.c	2005-03-09 11:25:04 -08:00
@@ -188,6 +188,9 @@
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_copybreak = 200;
+static int debug = 3;
+static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE | 
+			       NETIF_MSG_LINK | NETIF_MSG_IFUP| NETIF_MSG_IFDOWN;
 
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
@@ -390,6 +393,7 @@
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;		/* spin lock flag */
+	int msg_enable;
 	int chipset;
 	int mac_version;
 	int phy_version;
@@ -425,6 +429,8 @@
 module_param_array(media, int, &num_media, 0);
 module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "copy breakpoint for copy-only-tiny-frames");
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 
@@ -547,9 +553,13 @@
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		netif_carrier_on(dev);
-		printk(KERN_INFO PFX "%s: link up\n", dev->name);
-	} else
+		if (netif_msg_ifup(tp))
+			printk(KERN_INFO PFX "%s: link up\n", dev->name);
+	} else {
+		if (netif_msg_ifdown(tp))
+			printk(KERN_INFO PFX "%s: link down\n", dev->name);
 		netif_carrier_off(dev);
+	}
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
@@ -875,12 +885,26 @@
         spin_unlock_irqrestore(&tp->lock, flags);
 }
 
+static u32 rtl8169_get_msglevel(struct net_device *dev)
+{
+        struct rtl8169_private *tp = netdev_priv(dev);
+	return tp->msg_enable;
+}
+
+static void rtl8169_set_msglevel(struct net_device *dev, u32 value)
+{
+        struct rtl8169_private *tp = netdev_priv(dev);
+	tp->msg_enable = value;
+}
+
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
 	.get_link		= ethtool_op_get_link,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
+	.get_msglevel		= rtl8169_get_msglevel,
+	.set_msglevel		= rtl8169_set_msglevel,
 	.get_rx_csum		= rtl8169_get_rx_csum,
 	.set_rx_csum		= rtl8169_set_rx_csum,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
@@ -1095,7 +1119,8 @@
 	if (tp->link_ok(ioaddr))
 		goto out_unlock;
 
-	printk(KERN_WARNING PFX "%s: PHY reset until link up\n", dev->name);
+	if (netif_msg_link(tp))
+		printk(KERN_WARNING PFX "%s: PHY reset until link up\n", dev->name);
 
 	tp->phy_reset_enable(ioaddr);
 
@@ -1180,6 +1205,7 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = netdev_priv(dev);
+	tp->msg_enable = netif_msg_init(debug, default_msg);
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
@@ -1395,20 +1421,22 @@
 		return rc;
 	}
 
-	printk(KERN_DEBUG "%s: Identified chip type is '%s'.\n", dev->name,
-	       rtl_chip_info[tp->chipset].name);
+	if (netif_msg_probe(tp))
+		printk(KERN_DEBUG "%s: Identified chip type is '%s'.\n", dev->name,
+		       rtl_chip_info[tp->chipset].name);
 
 	pci_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: %s at 0x%lx, "
-	       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-	       "IRQ %d\n",
-	       dev->name,
-	       rtl_chip_info[ent->driver_data].name,
-	       dev->base_addr,
-	       dev->dev_addr[0], dev->dev_addr[1],
-	       dev->dev_addr[2], dev->dev_addr[3],
-	       dev->dev_addr[4], dev->dev_addr[5], dev->irq);
+	if (netif_msg_probe(tp))
+		printk(KERN_INFO "%s: %s at 0x%lx, "
+		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
+		       "IRQ %d\n",
+		       dev->name,
+		       rtl_chip_info[ent->driver_data].name,
+		       dev->base_addr,
+		       dev->dev_addr[0], dev->dev_addr[1],
+		       dev->dev_addr[2], dev->dev_addr[3],
+		       dev->dev_addr[4], dev->dev_addr[5], dev->irq);
 
 	rtl8169_hw_phy_config(dev);
 
@@ -1431,7 +1459,7 @@
 
 	rtl8169_set_speed(dev, autoneg, speed, duplex);
 	
-	if (RTL_R8(PHYstatus) & TBI_Enable)
+	if (RTL_R8(PHYstatus) & TBI_Enable && netif_msg_link(tp))
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
 
 	return 0;
@@ -2185,8 +2213,10 @@
 
 		if (status & DescOwn)
 			break;
-		if (status & RxRES) {
-			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
+		if (unlikely(status & RxRES)) {
+			if (netif_msg_rx_err(tp))
+				printk(KERN_INFO "%s: Rx ERROR statu=%x!\n", 
+				       dev->name, status);
 			tp->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
 				tp->stats.rx_length_errors++;
@@ -2314,8 +2344,9 @@
 	} while (boguscnt > 0);
 
 	if (boguscnt <= 0) {
-		printk(KERN_WARNING "%s: Too much work at interrupt!\n",
-		       dev->name);
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s: Too much work at interrupt!\n",
+			       dev->name);
 		/* Clear all interrupt sources. */
 		RTL_W16(IntrStatus, 0xffff);
 	}
@@ -2409,8 +2440,9 @@
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-		       dev->name);
+		if (netif_msg_link(tp))
+			printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
+			       dev->name);
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
