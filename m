From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 1/5] r8169: missing netif_poll_enable and irq ack
Date: Tue, 7 Dec 2004 01:14:19 +0100
Message-ID: <20041207001419.GB12838@electric-eye.fr.zoreil.com>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org> <20041205235519.GA21885@lilah.hetzel.org> <20041205233756.GB29236@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com,
        Dorn Hetzel <kernel@dorn.hetzel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20041205233756.GB29236@electric-eye.fr.zoreil.com>
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
--- linux-2.6.10-rc2/drivers/net/r8169.c~r8169-250	2004-12-05 22:36:14.592843434 +0100
+++ linux-2.6.10-rc2-fr/drivers/net/r8169.c	2004-12-05 22:36:14.596842782 +0100
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
