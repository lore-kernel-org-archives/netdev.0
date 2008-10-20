From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 2/3] smc911x: Add IRQ polarity configuration
Date: Mon, 20 Oct 2008 18:15:30 +0100
Message-ID: <20081020171523.6277.86237.stgit@pc1117.cambridge.arm.com>
References: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:52986 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752183AbYJTRkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:40:20 -0400
Received: from cam-owa2.Emea.Arm.com (cam-owa2.emea.arm.com [10.1.105.18])
	by cam-admin0.cambridge.arm.com (8.12.6/8.12.6) with ESMTP id m9KHFU6e003396
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 18:15:30 +0100 (BST)
In-Reply-To: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Platforms like ARM Ltd's RealView require the IRQ polarity bit to be set
for the SMC9118 chip. This patch allows the dynamic configuration via
the smc911x_platdata structure.

This patch also changes the smc91x_platdata structure name to the
correct smc911x_platdata in the smc911x_drv_probe() function.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 drivers/net/smc911x.c   |   11 ++++++++---
 include/linux/smc911x.h |    1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 8aa7460..0216440 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -180,7 +180,7 @@ static void PRINT_PKT(u_char *buf, int length)
 static void smc911x_reset(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned int reg, timeout=0, resets=1;
+	unsigned int reg, timeout=0, resets=1, irq_cfg;
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
@@ -252,7 +252,12 @@ static void smc911x_reset(struct net_device *dev)
 	 * Deassert IRQ for 1*10us for edge type interrupts
 	 * and drive IRQ pin push-pull
 	 */
-	SMC_SET_IRQ_CFG(lp, (1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_);
+	irq_cfg = (1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_;
+#ifdef SMC_DYNAMIC_BUS_CONFIG
+	if (lp->cfg.irq_polarity)
+		irq_cfg |= INT_CFG_IRQ_POL_;
+#endif
+	SMC_SET_IRQ_CFG(lp, irq_cfg);
 
 	/* clear anything saved */
 	if (lp->pending_tx_skb != NULL) {
@@ -2054,7 +2059,7 @@ err_out:
  */
 static int smc911x_drv_probe(struct platform_device *pdev)
 {
-	struct smc91x_platdata *pd = pdev->dev.platform_data;
+	struct smc911x_platdata *pd = pdev->dev.platform_data;
 	struct net_device *ndev;
 	struct resource *res;
 	struct smc911x_local *lp;
diff --git a/include/linux/smc911x.h b/include/linux/smc911x.h
index b58f54c..521f371 100644
--- a/include/linux/smc911x.h
+++ b/include/linux/smc911x.h
@@ -7,6 +7,7 @@
 struct smc911x_platdata {
 	unsigned long flags;
 	unsigned long irq_flags; /* IRQF_... */
+	int irq_polarity;
 };
 
 #endif /* __SMC911X_H__ */

