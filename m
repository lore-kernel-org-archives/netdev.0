From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.10-rc2-netdev1 1/4] r8169: missing netif_poll_enable and irq ack
Date: Tue, 16 Nov 2004 23:30:40 +0100
Message-ID: <20041116223040.GA16715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

- (noticed by Jon D. Mason) rtl8169_wait_for_quiescence() needs to disable
  the NAPI processing but it has no reason to lock any part of the driver
  which would try to do the same at a later time. Let's reenable NAPI
  processing as soon as possible.
- properly ack any aborted interruption: a reset of the device is not
  always enough.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-250 drivers/net/r8169.c
--- linux-2.6.10-rc2-mm1.orig/drivers/net/r8169.c~r8169-250	2004-11-15 00:28:53.000000000 +0100
+++ linux-2.6.10-rc2-mm1/drivers/net/r8169.c	2004-11-16 22:32:23.000000000 +0100
@@ -1742,10 +1742,19 @@ static void rtl8169_schedule_work(struct
 
 static void rtl8169_wait_for_quiescence(struct net_device *dev)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
 	netif_poll_disable(dev);
+
+	RTL_W16(IntrMask, 0x0000);
+
+	RTL_W16(IntrStatus, 0xffff);
+
+	netif_poll_enable(dev);
 }
 
 static void rtl8169_reinit_task(void *_data)

_
