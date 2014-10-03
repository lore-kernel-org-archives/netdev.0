From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net 7/8] gianfar: Replace spin_event_timeout() with arch independent
Date: Fri, 3 Oct 2014 19:02:48 +0300
Message-ID: <1412352169-14414-8-git-send-email-claudiu.manoil@freescale.com>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0122.outbound.protection.outlook.com ([207.46.100.122]:58272
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753448AbaJCQXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:23:38 -0400
In-Reply-To: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use arch independent code to replace the powerpc dependent
spin_event_timeout() from gfar_halt_nodisable().
Added GRS/GTS read accessors to clean-up the implementation
of gfar_halt_nodisable().

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 32 +++++++++++++++++++-------------
 drivers/net/ethernet/freescale/gianfar.h | 15 +++++++++++++++
 2 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 961198a..356a998 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1762,26 +1762,32 @@ static void gfar_halt_nodisable(struct gfar_private *priv)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 tempval;
+	unsigned int timeout;
+	int stopped;
 
 	gfar_ints_disable(priv);
 
+	if (gfar_is_dma_stopped(priv))
+		return;
+
 	/* Stop the DMA, and wait for it to stop */
 	tempval = gfar_read(&regs->dmactrl);
-	if ((tempval & (DMACTRL_GRS | DMACTRL_GTS)) !=
-	    (DMACTRL_GRS | DMACTRL_GTS)) {
-		int ret;
-
-		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
-		gfar_write(&regs->dmactrl, tempval);
+	tempval |= (DMACTRL_GRS | DMACTRL_GTS);
+	gfar_write(&regs->dmactrl, tempval);
 
-		do {
-			ret = spin_event_timeout(((gfar_read(&regs->ievent) &
-				 (IEVENT_GRSC | IEVENT_GTSC)) ==
-				 (IEVENT_GRSC | IEVENT_GTSC)), 1000000, 0);
-			if (!ret && !(gfar_read(&regs->ievent) & IEVENT_GRSC))
-				ret = __gfar_is_rx_idle(priv);
-		} while (!ret);
+retry:
+	timeout = 1000;
+	while (!(stopped = gfar_is_dma_stopped(priv)) && timeout) {
+		cpu_relax();
+		timeout--;
 	}
+
+	if (!timeout)
+		stopped = gfar_is_dma_stopped(priv);
+
+	if (!stopped && !gfar_is_rx_dma_stopped(priv) &&
+	    !__gfar_is_rx_idle(priv))
+		goto retry;
 }
 
 /* Halt the receive and transmit queues */
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 84632c5..0b37722 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1226,6 +1226,21 @@ static inline void gfar_write_isrg(struct gfar_private *priv)
 	}
 }
 
+static inline int gfar_is_dma_stopped(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+
+	return ((gfar_read(&regs->ievent) & (IEVENT_GRSC | IEVENT_GTSC)) ==
+	       (IEVENT_GRSC | IEVENT_GTSC));
+}
+
+static inline int gfar_is_rx_dma_stopped(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+
+	return gfar_read(&regs->ievent) & IEVENT_GRSC;
+}
+
 irqreturn_t gfar_receive(int irq, void *dev_id);
 int startup_gfar(struct net_device *dev);
 void stop_gfar(struct net_device *dev);
-- 
1.7.11.7
