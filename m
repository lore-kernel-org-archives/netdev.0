From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 1/11] r8169: add ethtool_ops.{get_regs_len/get_regs}
Date: Tue, 24 Aug 2004 00:44:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823224425.GA20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823224100.GA14680@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


- ethtool_ops.{get_regs_len/get_regs} for r8169;
- fix a dubious check: datasheet v1.21 claims on p.44 that io/memory space
  is exactly 256 bytes wide;
- use SET_ETHTOOL_OPS().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-000 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-000	2004-08-23 23:29:58.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:29:58.000000000 +0200
@@ -99,6 +99,7 @@ static int multicast_filter_limit = 32;
 #define RxPacketMaxSize	0x0800	/* Maximum size supported is 16K-1 */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
+#define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
@@ -106,7 +107,6 @@ static int multicast_filter_limit = 32;
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
-#define RTL_MIN_IO_SIZE 0x80
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
@@ -508,6 +508,11 @@ static void rtl8169_get_drvinfo(struct n
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
 }
 
+static int rtl8169_get_regs_len(struct net_device *dev)
+{
+	return R8169_REGS_SIZE;
+}
+
 static int rtl8169_set_speed_tbi(struct net_device *dev,
 				 u8 autoneg, u16 speed, u8 duplex)
 {
@@ -671,12 +676,27 @@ static int rtl8169_get_settings(struct n
 	return 0;
 }
 
+static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			     void *p)
+{
+        struct rtl8169_private *tp = netdev_priv(dev);
+        unsigned long flags;
+
+        if (regs->len > R8169_REGS_SIZE)
+        	regs->len = R8169_REGS_SIZE;
+
+        spin_lock_irqsave(&tp->lock, flags);
+        memcpy_fromio(p, tp->mmio_addr, regs->len);
+        spin_unlock_irqrestore(&tp->lock, flags);
+}
 
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
+	.get_regs_len		= rtl8169_get_regs_len,
 	.get_link		= ethtool_op_get_link,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
+	.get_regs		= rtl8169_get_regs,
 };
 
 static void rtl8169_write_gmii_reg_bit(void *ioaddr, int reg, int bitnum,
@@ -968,7 +988,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 	// check for weird/broken PCI region reporting
-	if (mmio_len < RTL_MIN_IO_SIZE) {
+	if (mmio_len < R8169_REGS_SIZE) {
 		printk(KERN_ERR PFX "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
@@ -1105,7 +1125,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->open = rtl8169_open;
 	dev->hard_start_xmit = rtl8169_start_xmit;
 	dev->get_stats = rtl8169_get_stats;
-	dev->ethtool_ops = &rtl8169_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
 	dev->set_multicast_list = rtl8169_set_rx_mode;

_
