From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 10/11] gianfar: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:21 +0100
Message-ID: <1418135842-21389-11-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:54154 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757255AbaLIOjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:42 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt
handler and netpoll controller.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 38 ++++++++++++++------------------
 drivers/net/ethernet/freescale/gianfar.h |  5 +++++
 2 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 86dccb26fecc..c6e85983fb65 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2709,6 +2709,7 @@ irqreturn_t gfar_receive(int irq, void *grp_id)
 	unsigned long flags;
 	u32 imask;
 
+	netpoll_irq_lock(&grp->netpoll_rx_lock);
 	if (likely(napi_schedule_prep(&grp->napi_rx))) {
 		spin_lock_irqsave(&grp->grplock, flags);
 		imask = gfar_read(&grp->regs->imask);
@@ -2723,6 +2724,7 @@ irqreturn_t gfar_receive(int irq, void *grp_id)
 		gfar_write(&grp->regs->ievent, IEVENT_RX_MASK);
 	}
 
+	netpoll_irq_unlock(&grp->netpoll_rx_lock);
 	return IRQ_HANDLED;
 }
 
@@ -2733,6 +2735,7 @@ static irqreturn_t gfar_transmit(int irq, void *grp_id)
 	unsigned long flags;
 	u32 imask;
 
+	netpoll_irq_lock(&grp->netpoll_tx_lock);
 	if (likely(napi_schedule_prep(&grp->napi_tx))) {
 		spin_lock_irqsave(&grp->grplock, flags);
 		imask = gfar_read(&grp->regs->imask);
@@ -2747,6 +2750,7 @@ static irqreturn_t gfar_transmit(int irq, void *grp_id)
 		gfar_write(&grp->regs->ievent, IEVENT_TX_MASK);
 	}
 
+	netpoll_irq_unlock(&grp->netpoll_tx_lock);
 	return IRQ_HANDLED;
 }
 
@@ -3073,27 +3077,10 @@ static void gfar_netpoll(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	int i;
 
-	/* If the device has multiple interrupts, run tx/rx */
-	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		for (i = 0; i < priv->num_grps; i++) {
-			struct gfar_priv_grp *grp = &priv->gfargrp[i];
-
-			disable_irq(gfar_irq(grp, TX)->irq);
-			disable_irq(gfar_irq(grp, RX)->irq);
-			disable_irq(gfar_irq(grp, ER)->irq);
-			gfar_interrupt(gfar_irq(grp, TX)->irq, grp);
-			enable_irq(gfar_irq(grp, ER)->irq);
-			enable_irq(gfar_irq(grp, RX)->irq);
-			enable_irq(gfar_irq(grp, TX)->irq);
-		}
-	} else {
-		for (i = 0; i < priv->num_grps; i++) {
-			struct gfar_priv_grp *grp = &priv->gfargrp[i];
+	for (i = 0; i < priv->num_grps; i++) {
+		struct gfar_priv_grp *grp = &priv->gfargrp[i];
 
-			disable_irq(gfar_irq(grp, TX)->irq);
-			gfar_interrupt(gfar_irq(grp, TX)->irq, grp);
-			enable_irq(gfar_irq(grp, TX)->irq);
-		}
+		gfar_interrupt(gfar_irq(grp, TX)->irq, grp);
 	}
 }
 #endif
@@ -3102,9 +3089,11 @@ static void gfar_netpoll(struct net_device *dev)
 static irqreturn_t gfar_interrupt(int irq, void *grp_id)
 {
 	struct gfar_priv_grp *gfargrp = grp_id;
+	u32 events;
 
+	netpoll_irq_lock(&gfargrp->netpoll_intr_lock);
 	/* Save ievent for future reference */
-	u32 events = gfar_read(&gfargrp->regs->ievent);
+	events = gfar_read(&gfargrp->regs->ievent);
 
 	/* Check for reception */
 	if (events & IEVENT_RX_MASK)
@@ -3118,6 +3107,7 @@ static irqreturn_t gfar_interrupt(int irq, void *grp_id)
 	if (events & IEVENT_ERR_MASK)
 		gfar_error(irq, grp_id);
 
+	netpoll_irq_unlock(&gfargrp->netpoll_intr_lock);
 	return IRQ_HANDLED;
 }
 
@@ -3306,9 +3296,11 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 	struct gfar __iomem *regs = gfargrp->regs;
 	struct gfar_private *priv= gfargrp->priv;
 	struct net_device *dev = priv->ndev;
+	u32 events;
 
+	netpoll_irq_lock(&gfargrp->netpoll_err_lock);
 	/* Save ievent for future reference */
-	u32 events = gfar_read(&regs->ievent);
+	events = gfar_read(&regs->ievent);
 
 	/* Clear IEVENT */
 	gfar_write(&regs->ievent, events & IEVENT_ERR_MASK);
@@ -3377,6 +3369,8 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 		atomic64_inc(&priv->extra_stats.tx_babt);
 		netif_dbg(priv, tx_err, dev, "babbling TX error\n");
 	}
+
+	netpoll_irq_unlock(&gfargrp->netpoll_err_lock);
 	return IRQ_HANDLED;
 }
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index b581b8823a2a..4da559dd772d 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -37,6 +37,7 @@
 #include <linux/mm.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/netpoll.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -1079,6 +1080,10 @@ struct gfar_priv_grp {
 	unsigned long rx_bit_map;
 
 	struct gfar_irqinfo *irqinfo[GFAR_NUM_IRQS];
+	struct netpoll_irq_lock netpoll_intr_lock;
+	struct netpoll_irq_lock netpoll_rx_lock;
+	struct netpoll_irq_lock netpoll_tx_lock;
+	struct netpoll_irq_lock netpoll_err_lock;
 };
 
 #define gfar_irq(grp, ID) \
-- 
2.1.3
