From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] (3/3) 8139too -- poll_controller
Date: Wed, 19 Nov 2003 14:40:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119144029.5ba66fda.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>,
        OGAWA Hirofumi
 <hirofumi@mail.parknet.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For net-drivers-2.5-exp, add a poll_controller hook to allow use of netconsole
with this driver. 

jeff, don't have netconsole setup to test this so please give it a try before
including it.

diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	Wed Nov 19 14:34:13 2003
+++ b/drivers/net/8139too.c	Wed Nov 19 14:34:13 2003
@@ -612,6 +612,7 @@
 static int rtl8139_start_xmit (struct sk_buff *skb,
 			       struct net_device *dev);
 static int rtl8139_poll(struct net_device *dev, int *budget);
+static void rtl8139_poll_controller(struct net_device *dev);
 static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance,
 			       struct pt_regs *regs);
 static int rtl8139_close (struct net_device *dev);
@@ -989,6 +990,9 @@
 	dev->ethtool_ops = &rtl8139_ethtool_ops;
 	dev->tx_timeout = rtl8139_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = rtl8139_poll_controller;
+#endif
 
 	/* note: the hardware is not capable of sg/csum/highdma, however
 	 * through the use of skb_copy_and_csum_dev we enable these
@@ -2184,6 +2188,18 @@
 	return IRQ_RETVAL(handled);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void rtl8139_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	rtl8139_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
 
 static int rtl8139_close (struct net_device *dev)
 {
