From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/8] can: flexcan: correctly initialize mailboxes
Date: Thu, 18 Sep 2014 12:40:58 +0200
Message-ID: <1411036862-13255-5-git-send-email-mkl@pengutronix.de>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, David Jander <david@protonic.nl>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37895 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574AbaIRKlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 06:41:13 -0400
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Jander <david@protonic.nl>

Apparently mailboxes may contain random data at startup, causing some of them
being prepared for message reception. This causes overruns being missed or even
confusing the IRQ check for trasmitted messages, increasing the transmit
counter instead of the error counter.

This patch initializes all mailboxes after the FIFO as RX_INACTIVE.

Signed-off-by: David Jander <david@protonic.nl>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 76dcbca..fc076952 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -812,6 +812,7 @@ static int flexcan_chip_start(struct net_device *dev)
 	struct flexcan_regs __iomem *regs = priv->base;
 	int err;
 	u32 reg_mcr, reg_ctrl;
+	int i;
 
 	/* enable module */
 	err = flexcan_chip_enable(priv);
@@ -878,6 +879,12 @@ static int flexcan_chip_start(struct net_device *dev)
 	netdev_dbg(dev, "%s: writing ctrl=0x%08x", __func__, reg_ctrl);
 	flexcan_write(reg_ctrl, &regs->ctrl);
 
+	/* clear and invalidate all mailboxes first */
+	for (i = FLEXCAN_TX_BUF_ID; i < ARRAY_SIZE(regs->cantxfg); i++) {
+		flexcan_write(FLEXCAN_MB_CODE_RX_INACTIVE,
+			      &regs->cantxfg[i].can_ctrl);
+	}
+
 	/* mark TX mailbox as INACTIVE */
 	flexcan_write(FLEXCAN_MB_CODE_TX_INACTIVE,
 		      &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
-- 
2.1.0
