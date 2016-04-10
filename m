From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] ravb: make ravb_ptp_interrupt() *void*
Date: Sun, 10 Apr 2016 23:55:15 +0300
Message-ID: <6123492.pMMRNT1FnA@wasted.cogentembedded.com>
References: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:35575 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756233AbcDJUzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 16:55:20 -0400
Received: by mail-lf0-f54.google.com with SMTP id c126so133018162lfb.2
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 13:55:18 -0700 (PDT)
In-Reply-To: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we have the ISS.CGIS bit set, we already know that gPTP interrupt has
happened, so an extra GIS register check at the end of ravb_ptp_interrupt()
seems superfluous.  We can model the gPTP interrupt  handler like all other
dedicated interrupt handlers in the driver and make it *void*.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo.

 drivers/net/ethernet/renesas/ravb.h      |    2 +-
 drivers/net/ethernet/renesas/ravb_main.c |    8 ++++++--
 drivers/net/ethernet/renesas/ravb_ptp.c  |    9 ++-------
 3 files changed, 9 insertions(+), 10 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/ravb.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb.h
+++ net-next/drivers/net/ethernet/renesas/ravb.h
@@ -1045,7 +1045,7 @@ void ravb_modify(struct net_device *ndev
 		 u32 set);
 int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value);
 
-irqreturn_t ravb_ptp_interrupt(struct net_device *ndev);
+void ravb_ptp_interrupt(struct net_device *ndev);
 void ravb_ptp_init(struct net_device *ndev, struct platform_device *pdev);
 void ravb_ptp_stop(struct net_device *ndev);
 
Index: net-next/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net-next/drivers/net/ethernet/renesas/ravb_main.c
@@ -807,8 +807,10 @@ static irqreturn_t ravb_interrupt(int ir
 	}
 
 	/* gPTP interrupt status summary */
-	if ((iss & ISS_CGIS) && ravb_ptp_interrupt(ndev) == IRQ_HANDLED)
+	if (iss & ISS_CGIS) {
+		ravb_ptp_interrupt(ndev);
 		result = IRQ_HANDLED;
+	}
 
 	mmiowb();
 	spin_unlock(&priv->lock);
@@ -838,8 +840,10 @@ static irqreturn_t ravb_multi_interrupt(
 	}
 
 	/* gPTP interrupt status summary */
-	if ((iss & ISS_CGIS) && ravb_ptp_interrupt(ndev) == IRQ_HANDLED)
+	if (iss & ISS_CGIS) {
+		ravb_ptp_interrupt(ndev);
 		result = IRQ_HANDLED;
+	}
 
 	mmiowb();
 	spin_unlock(&priv->lock);
Index: net-next/drivers/net/ethernet/renesas/ravb_ptp.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb_ptp.c
+++ net-next/drivers/net/ethernet/renesas/ravb_ptp.c
@@ -296,7 +296,7 @@ static const struct ptp_clock_info ravb_
 };
 
 /* Caller must hold the lock */
-irqreturn_t ravb_ptp_interrupt(struct net_device *ndev)
+void ravb_ptp_interrupt(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	u32 gis = ravb_read(ndev, GIS);
@@ -319,12 +319,7 @@ irqreturn_t ravb_ptp_interrupt(struct ne
 		}
 	}
 
-	if (gis) {
-		ravb_write(ndev, ~gis, GIS);
-		return IRQ_HANDLED;
-	}
-
-	return IRQ_NONE;
+	ravb_write(ndev, ~gis, GIS);
 }
 
 void ravb_ptp_init(struct net_device *ndev, struct platform_device *pdev)
