From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] 8139cp - add netpoll support
Date: Mon, 27 Sep 2004 15:53:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927135359.GD18851@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch adds netpoll support to the 8139cp driver.
The patch needs some tests because I have no NIC of this type for testing.

Applies against linux-2.6.9-rc2-mm3

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

--  

diff -urN vanilla-2.6.9-rc2-mm3/drivers/net/8139cp.c linux-2.6.9-rc2-mm3/drivers/net/8139cp.c
--- vanilla-2.6.9-rc2-mm3/drivers/net/8139cp.c	Sat Sep 25 12:00:58 2004
+++ linux-2.6.9-rc2-mm3/drivers/net/8139cp.c	Mon Sep 27 11:55:04 2004
@@ -398,6 +398,9 @@ struct cp_private {
 static void __cp_set_rx_mode (struct net_device *dev);
 static void cp_tx (struct cp_private *cp);
 static void cp_clean_rings (struct cp_private *cp);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void cp_poll_controller(struct net_device *dev);
+#endif
 
 static struct pci_device_id cp_pci_tbl[] = {
 	{ PCI_VENDOR_ID_REALTEK, PCI_DEVICE_ID_REALTEK_8139,
@@ -690,6 +693,19 @@ cp_interrupt (int irq, void *dev_instanc
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void cp_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	cp_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 static void cp_tx (struct cp_private *cp)
 {
 	unsigned tx_head = cp->tx_head;
@@ -1761,6 +1777,9 @@ static int cp_init_one (struct pci_dev *
 	dev->get_stats = cp_get_stats;
 	dev->do_ioctl = cp_ioctl;
 	dev->poll = cp_rx_poll;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = cp_poll_controller;
+#endif
 	dev->weight = 16;	/* arbitrary? from NAPI_HOWTO.txt. */
 #ifdef BROKEN
 	dev->change_mtu = cp_change_mtu;
