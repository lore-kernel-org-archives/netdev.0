From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 03/11] 8139cp/too: remove disable_irq from netpoll controller
Date: Tue,  9 Dec 2014 15:37:14 +0100
Message-ID: <1418135842-21389-4-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:52278 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266AbaLIOi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:38:59 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep. The interrupt handlers for 8139 take the
device lock, so no need for additional protection.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/realtek/8139cp.c  | 3 +--
 drivers/net/ethernet/realtek/8139too.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 75b1693ec8bf..6a296c5c3860 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -581,6 +581,7 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 		return IRQ_NONE;
 	cp = netdev_priv(dev);
 
+	/* also protects against reentrancy from cp_poll_controller */
 	spin_lock(&cp->lock);
 
 	status = cpr16(IntrStatus);
@@ -639,9 +640,7 @@ static void cp_poll_controller(struct net_device *dev)
 	struct cp_private *cp = netdev_priv(dev);
 	const int irq = cp->pdev->irq;
 
-	disable_irq(irq);
 	cp_interrupt(irq, dev);
-	enable_irq(irq);
 }
 #endif
 
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 63dc0f95d050..f4437112984b 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2162,6 +2162,7 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
 	int link_changed = 0; /* avoid bogus "uninit" warning */
 	int handled = 0;
 
+	/* also protects against reentrancy from rtl8139_poll_controller */
 	spin_lock (&tp->lock);
 	status = RTL_R16 (IntrStatus);
 
@@ -2227,9 +2228,7 @@ static void rtl8139_poll_controller(struct net_device *dev)
 	struct rtl8139_private *tp = netdev_priv(dev);
 	const int irq = tp->pci_dev->irq;
 
-	disable_irq(irq);
 	rtl8139_interrupt(irq, dev);
-	enable_irq(irq);
 }
 #endif
 
-- 
2.1.3
