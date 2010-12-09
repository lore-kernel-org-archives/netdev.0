From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH, post-2.6.36 regression fix] r8169: Fix runtime power management
Date: Thu, 9 Dec 2010 02:32:14 +0100
Message-ID: <201012090232.14375.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Matthew Garrett <mjg@redhat.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"Linux-pm mailing list" <linux-pm@lists.linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: r8169: Fix runtime power management

I noticed that one of the post-2.6.36 patches broke runtime PM of the
r8169 on my MSI Wind test machine in such a way that the link was not
brought up after reconnecting the network cable.

In the process of debugging the issue I realized that we only should
invoke the runtime PM functions in rtl8169_check_link_status() when
link change is reported and if we do so, the problem goes away.
Moreover, this allows rtl8169_runtime_idle() to be simplified quite
a bit.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/r8169.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

Index: linux-2.6/drivers/net/r8169.c
===================================================================
--- linux-2.6.orig/drivers/net/r8169.c
+++ linux-2.6/drivers/net/r8169.c
@@ -744,26 +744,36 @@ static void rtl8169_xmii_reset_enable(vo
 	mdio_write(ioaddr, MII_BMCR, val & 0xffff);
 }
 
-static void rtl8169_check_link_status(struct net_device *dev,
+static void __rtl8169_check_link_status(struct net_device *dev,
 				      struct rtl8169_private *tp,
-				      void __iomem *ioaddr)
+				      void __iomem *ioaddr,
+				      bool pm)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		/* This is to cancel a scheduled suspend if there's one. */
-		pm_request_resume(&tp->pci_dev->dev);
+		if (pm)
+			pm_request_resume(&tp->pci_dev->dev);
 		netif_carrier_on(dev);
 		netif_info(tp, ifup, dev, "link up\n");
 	} else {
 		netif_carrier_off(dev);
 		netif_info(tp, ifdown, dev, "link down\n");
-		pm_schedule_suspend(&tp->pci_dev->dev, 100);
+		if (pm)
+			pm_schedule_suspend(&tp->pci_dev->dev, 100);
 	}
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
+static void rtl8169_check_link_status(struct net_device *dev,
+				      struct rtl8169_private *tp,
+				      void __iomem *ioaddr)
+{
+	__rtl8169_check_link_status(dev, tp, ioaddr, false);
+}
+
 #define WAKE_ANY (WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_BCAST | WAKE_MCAST)
 
 static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
@@ -4600,7 +4610,7 @@ static irqreturn_t rtl8169_interrupt(int
 		}
 
 		if (status & LinkChg)
-			rtl8169_check_link_status(dev, tp, ioaddr);
+			__rtl8169_check_link_status(dev, tp, ioaddr, true);
 
 		/* We need to see the lastest version of tp->intr_mask to
 		 * avoid ignoring an MSI interrupt and having to wait for
@@ -4890,11 +4900,7 @@ static int rtl8169_runtime_idle(struct d
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if (!tp->TxDescArray)
-		return 0;
-
-	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
-	return -EBUSY;
+	return tp->TxDescArray ? -EBUSY : 0;
 }
 
 static const struct dev_pm_ops rtl8169_pm_ops = {
