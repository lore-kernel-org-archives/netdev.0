From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] Fix Rx/Tx HW interrupt coalescing counter reset procedure.
Date: Mon, 24 Mar 2008 10:53:28 -0500
Message-ID: <1206374009-1292-3-git-send-email-afleming@freescale.com>
References: <1206374009-1292-1-git-send-email-afleming@freescale.com>
 <1206374009-1292-2-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:48198 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbYCXPyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 11:54:08 -0400
In-Reply-To: <1206374009-1292-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fix Rx/Tx HW interrupt coalescing counter reset logic. Disabling is required before resetting the counter.

- Update the Default both Rx and Tx coalescing timer threshold. Formerly 4 is set which is equal to 1.5 frame at the line rate of 1GbE interface, and it doesn't match to the coalescing frame count which is set to 16. Threashold 21 is matched to frame count 16.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   18 +++++++++---------
 drivers/net/gianfar.h |    4 ++--
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index a59edf7..601f93e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1299,11 +1299,11 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 
 	/* If we are coalescing the interrupts, reset the timer */
 	/* Otherwise, clear it */
-	if (priv->txcoalescing)
+	if (likely(priv->txcoalescing)) {
+		gfar_write(&priv->regs->txic, 0);
 		gfar_write(&priv->regs->txic,
 			   mk_ic_value(priv->txcount, priv->txtime));
-	else
-		gfar_write(&priv->regs->txic, 0);
+	}
 
 	spin_unlock(&priv->txlock);
 
@@ -1417,11 +1417,11 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 
 	/* If we are coalescing interrupts, update the timer */
 	/* Otherwise, clear it */
-	if (priv->rxcoalescing)
+	if (likely(priv->rxcoalescing)) {
+		gfar_write(&priv->regs->rxic, 0);
 		gfar_write(&priv->regs->rxic,
 			   mk_ic_value(priv->rxcount, priv->rxtime));
-	else
-		gfar_write(&priv->regs->rxic, 0);
+	}
 
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 #endif
@@ -1593,11 +1593,11 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 		/* If we are coalescing interrupts, update the timer */
 		/* Otherwise, clear it */
-		if (priv->rxcoalescing)
+		if (likely(priv->rxcoalescing)) {
+			gfar_write(&priv->regs->rxic, 0);
 			gfar_write(&priv->regs->rxic,
 				   mk_ic_value(priv->rxcount, priv->rxtime));
-		else
-			gfar_write(&priv->regs->rxic, 0);
+		}
 	}
 
 	return howmany;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 26eb6ab..119019a 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -124,11 +124,11 @@ extern const char gfar_driver_version[];
 
 #define DEFAULT_TX_COALESCE 1
 #define DEFAULT_TXCOUNT	16
-#define DEFAULT_TXTIME	4
+#define DEFAULT_TXTIME	21
 
 #define DEFAULT_RX_COALESCE 1
 #define DEFAULT_RXCOUNT	16
-#define DEFAULT_RXTIME	4
+#define DEFAULT_RXTIME	21
 
 #define TBIPA_VALUE		0x1f
 #define MIIMCFG_INIT_VALUE	0x00000007
-- 
1.5.4.23.gef5b9

