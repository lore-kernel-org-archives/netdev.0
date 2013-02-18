From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] net: fec: Fix the disabling of RX interrupt
Date: Mon, 18 Feb 2013 16:07:27 -0300
Message-ID: <1361214447-7279-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Frank.Li@freescale.com>, <shawn.guo@linaro.org>, <marex@denx.de>,
	<s.hauer@pengutronix.de>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:44991
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754170Ab3BRTHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 14:07:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The correct way to disable FEC RX interrupt is to clean only the FEC_ENET_RXF 
bit.

Since commit dc975382d2e (net: fec: add napi support to improve proformance) 
FEC_RX_DISABLED_IMASK is being written to the FEC_IMASK register, which also 
incorrectly sets other bits.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0fe68c4..f4f8495 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -811,6 +811,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	uint int_events;
 	irqreturn_t ret = IRQ_NONE;
+	int reg;
 
 	do {
 		int_events = readl(fep->hwp + FEC_IEVENT);
@@ -821,8 +822,9 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 			/* Disable the RX interrupt */
 			if (napi_schedule_prep(&fep->napi)) {
-				writel(FEC_RX_DISABLED_IMASK,
-					fep->hwp + FEC_IMASK);
+				reg = readl(fep->hwp + FEC_IMASK);
+				reg &= ~FEC_ENET_RXF;
+				writel(reg, fep->hwp + FEC_IMASK);
 				__napi_schedule(&fep->napi);
 			}
 		}
-- 
1.7.9.5
