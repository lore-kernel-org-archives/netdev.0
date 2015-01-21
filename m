From: <shh.xie@gmail.com>
Subject: [PATCH 2/2] net/fsl: Replace spin_event_timeout() with arch independent in xgmac_mdio
Date: Wed, 21 Jan 2015 19:08:32 +0800
Message-ID: <1421838512-826-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0078.outbound.protection.outlook.com ([157.56.110.78]:3520
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750754AbbAUMaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 07:30:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

spin_event_timeout() is PPC dependent, use an arch independent
equivalent instead.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index ab9a6bf..3a83bc2 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -52,12 +52,16 @@ struct tgec_mdio_controller {
 static int xgmac_wait_until_free(struct device *dev,
 				 struct tgec_mdio_controller __iomem *regs)
 {
-	uint32_t status;
+	unsigned int timeout;
 
 	/* Wait till the bus is free */
-	status = spin_event_timeout(
-		!((ioread32be(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
-	if (!status) {
+	timeout = TIMEOUT;
+	while ((ioread32be(&regs->mdio_stat) & MDIO_STAT_BSY) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
+
+	if (!timeout) {
 		dev_err(dev, "timeout waiting for bus to be free\n");
 		return -ETIMEDOUT;
 	}
@@ -71,12 +75,16 @@ static int xgmac_wait_until_free(struct device *dev,
 static int xgmac_wait_until_done(struct device *dev,
 				 struct tgec_mdio_controller __iomem *regs)
 {
-	uint32_t status;
+	unsigned int timeout;
 
 	/* Wait till the MDIO write is complete */
-	status = spin_event_timeout(
-		!((ioread32be(&regs->mdio_data)) & MDIO_DATA_BSY), TIMEOUT, 0);
-	if (!status) {
+	timeout = TIMEOUT;
+	while ((ioread32be(&regs->mdio_data) & MDIO_DATA_BSY) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
+
+	if (!timeout) {
 		dev_err(dev, "timeout waiting for operation to complete\n");
 		return -ETIMEDOUT;
 	}
-- 
1.8.4.1
