From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next] ravb: Fix ravb_ptp_interrupt clear interrupt all status
Date: Tue, 18 Apr 2017 09:55:33 +0900
Message-ID: <1492476933-7952-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tsutomu Izawa <tsutomu.izawa.xk@renesas.com>

This patch fixes ravb_ptp_interrupt clears GIS register of all interrupts
status. It corrects to clear PTCF bit or PTMF bit.
Also it fixes returned value to IRQ_HANDLED or IRQ_NONE.

Signed-off-by: Tsutomu Izawa <tsutomu.izawa.xk@renesas.com>
Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/ravb.h      |  4 ++--
 drivers/net/ethernet/renesas/ravb_main.c | 12 ++++--------
 drivers/net/ethernet/renesas/ravb_ptp.c  | 15 ++++++++++++---
 3 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index 0525bd696d5d..fbfdefa659ce 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -1,6 +1,6 @@
 /* Renesas Ethernet AVB device driver
  *
- * Copyright (C) 2014-2015 Renesas Electronics Corporation
+ * Copyright (C) 2014-2017 Renesas Electronics Corporation
  * Copyright (C) 2015 Renesas Solutions Corp.
  * Copyright (C) 2015-2016 Cogent Embedded, Inc. <source@cogentembedded.com>
  *
@@ -1054,7 +1054,7 @@ void ravb_modify(struct net_device *ndev, enum ravb_reg reg, u32 clear,
 		 u32 set);
 int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value);
 
-void ravb_ptp_interrupt(struct net_device *ndev);
+irqreturn_t ravb_ptp_interrupt(struct net_device *ndev);
 void ravb_ptp_init(struct net_device *ndev, struct platform_device *pdev);
 void ravb_ptp_stop(struct net_device *ndev);
 
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 8cfc4a54f2dc..747686386513 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -820,10 +820,8 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
 	}
 
 	/* gPTP interrupt status summary */
-	if (iss & ISS_CGIS) {
-		ravb_ptp_interrupt(ndev);
-		result = IRQ_HANDLED;
-	}
+	if (iss & ISS_CGIS)
+		result = ravb_ptp_interrupt(ndev);
 
 	mmiowb();
 	spin_unlock(&priv->lock);
@@ -853,10 +851,8 @@ static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
 	}
 
 	/* gPTP interrupt status summary */
-	if (iss & ISS_CGIS) {
-		ravb_ptp_interrupt(ndev);
-		result = IRQ_HANDLED;
-	}
+	if (iss & ISS_CGIS)
+		result = ravb_ptp_interrupt(ndev);
 
 	mmiowb();
 	spin_unlock(&priv->lock);
diff --git a/drivers/net/ethernet/renesas/ravb_ptp.c b/drivers/net/ethernet/renesas/ravb_ptp.c
index eede70ec37f8..403cf85631ba 100644
--- a/drivers/net/ethernet/renesas/ravb_ptp.c
+++ b/drivers/net/ethernet/renesas/ravb_ptp.c
@@ -1,6 +1,6 @@
 /* PTP 1588 clock using the Renesas Ethernet AVB
  *
- * Copyright (C) 2013-2015 Renesas Electronics Corporation
+ * Copyright (C) 2013-2017 Renesas Electronics Corporation
  * Copyright (C) 2015 Renesas Solutions Corp.
  * Copyright (C) 2015-2016 Cogent Embedded, Inc. <source@cogentembedded.com>
  *
@@ -296,10 +296,11 @@ static const struct ptp_clock_info ravb_ptp_info = {
 };
 
 /* Caller must hold the lock */
-void ravb_ptp_interrupt(struct net_device *ndev)
+irqreturn_t ravb_ptp_interrupt(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	u32 gis = ravb_read(ndev, GIS);
+	irqreturn_t result = IRQ_NONE;
 
 	gis &= ravb_read(ndev, GIC);
 	if (gis & GIS_PTCF) {
@@ -309,6 +310,9 @@ void ravb_ptp_interrupt(struct net_device *ndev)
 		event.index = 0;
 		event.timestamp = ravb_read(ndev, GCPT);
 		ptp_clock_event(priv->ptp.clock, &event);
+
+		result = IRQ_HANDLED;
+		gis &= ~GIS_PTCF;
 	}
 	if (gis & GIS_PTMF) {
 		struct ravb_ptp_perout *perout = priv->ptp.perout;
@@ -317,9 +321,14 @@ void ravb_ptp_interrupt(struct net_device *ndev)
 			perout->target += perout->period;
 			ravb_ptp_update_compare(priv, perout->target);
 		}
+
+		result = IRQ_HANDLED;
+		gis &= ~GIS_PTMF;
 	}
 
-	ravb_write(ndev, ~gis, GIS);
+	ravb_write(ndev, gis, GIS);
+
+	return result;
 }
 
 void ravb_ptp_init(struct net_device *ndev, struct platform_device *pdev)
-- 
2.7.0.rc3.207.g0ac5344
