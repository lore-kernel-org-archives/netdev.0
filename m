From: Petr Konecny <pekon@fi.muni.cz>
Subject: PATCH: netpoll with xircom_cb
Date: Thu, 14 Oct 2004 04:41:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <qww8yaarph5.fsf@decibel.fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have a headless computer with xircom pcmcia card and needed netconsole
on it. After looking around in other drivers I concocted this patch.  It
survived light testing. I have no documentation for the hw, so it maybe
totally bogus. What do you think ?

                                                        Petr

lspci -v of the card is:
0000:02:00.1 Serial controller: Xircom Cardbus Ethernet + 56k Modem (rev 03) (prog-if 02 [16550])
        Subsystem: Xircom CBEM56G-100 Ethernet + 56k Modem
        Flags: medium devsel, IRQ 11
        I/O ports at 4080 [size=8]
        Memory at 10801000 (32-bit, non-prefetchable) [size=2K]
        Memory at 10801800 (32-bit, non-prefetchable) [size=2K]
        Expansion ROM at 10404000 [disabled] [size=16K]
        Capabilities: [dc] Power Management version 1

--- linux-2.6.8.1/drivers/net/tulip/xircom_cb.c	2004-08-13 22:37:38.000000000 -0700
+++ work/drivers/net/tulip/xircom_cb.c	2004-10-13 18:54:34.000000000 -0700
@@ -117,6 +117,9 @@
 static int xircom_close(struct net_device *dev);
 static void xircom_up(struct xircom_private *card);
 static struct net_device_stats *xircom_get_stats(struct net_device *dev);
+#if CONFIG_NET_POLL_CONTROLLER
+static void xircom_poll_controller(struct net_device *dev);
+#endif
 
 static void investigate_read_descriptor(struct net_device *dev,struct xircom_private *card, int descnr, unsigned int bufferoffset);
 static void investigate_write_descriptor(struct net_device *dev, struct xircom_private *card, int descnr, unsigned int bufferoffset);
@@ -269,6 +272,9 @@
 	dev->stop = &xircom_close;
 	dev->get_stats = &xircom_get_stats;
 	dev->priv = private;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = &xircom_poll_controller;
+#endif
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	pci_set_drvdata(pdev, dev);
 
@@ -500,6 +506,14 @@
 } 
                                                  
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void xircom_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	xircom_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
 
 
 static void initialize_card(struct xircom_private *card)
