From: akpm@osdl.org
Subject: [patch 05/10] r8169: missing netif_poll_enable and irq ack
Date: Tue, 04 Jan 2005 21:59:31 -0800
Message-ID: <200501050559.j055xe614686@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org,
        romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Francois Romieu <romieu@fr.zoreil.com>

- (noticed by Jon D. Mason) rtl8169_wait_for_quiescence() needs to disable
  the NAPI processing but it has no reason to lock any part of the driver
  which would try to do the same at a later time. Let's reenable NAPI
  processing as soon as possible.
- properly ack any aborted interruption: a reset of the device is not
  always enough.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/r8169.c |    9 +++++++++
 1 files changed, 9 insertions(+)

diff -puN drivers/net/r8169.c~r8169-missing-netif_poll_enable-and-irq-ack drivers/net/r8169.c
--- 25/drivers/net/r8169.c~r8169-missing-netif_poll_enable-and-irq-ack	2005-01-04 21:57:35.938670776 -0800
+++ 25-akpm/drivers/net/r8169.c	2005-01-04 21:57:45.096278608 -0800
@@ -1743,10 +1743,19 @@ static void rtl8169_schedule_work(struct
 
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
