From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9-rc4] r8169: netconsole support
Date: Mon, 18 Oct 2004 13:53:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018135346.E7539@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add a netconsole polling routine to the r8169 driver.

Tested w/ netconsole (& netdump) on x86_64 w/ FC3 Test3...

Signed-off-by: John W. Linville <linville@tuxdriver.com>

--- linux-2.6/drivers/net/r8169.c.orig
+++ linux-2.6/drivers/net/r8169.c
@@ -376,6 +376,10 @@ static struct net_device_stats *rtl8169_
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/* for netdump / net console */
+static void rtl8169_netpoll(struct net_device *netdev);
+#endif
 
 static const u16 rtl8169_intr_mask =
 	SYSErr | LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
@@ -1120,6 +1124,9 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->weight = R8169_NAPI_WEIGHT;
 	printk(KERN_INFO PFX "NAPI enabled\n");
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = rtl8169_netpoll;
+#endif
 	tp->intr_mask = 0xffff;
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
@@ -1950,6 +1957,22 @@ static struct net_device_stats *rtl8169_
 	return &tp->stats;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void
+rtl8169_netpoll (struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	disable_irq(tp->pci_dev->irq);
+	rtl8169_interrupt(tp->pci_dev->irq, dev, NULL);
+	enable_irq(tp->pci_dev->irq);
+}
+#endif
+
 static struct pci_driver rtl8169_pci_driver = {
 	.name		= MODULENAME,
 	.id_table	= rtl8169_pci_tbl,
