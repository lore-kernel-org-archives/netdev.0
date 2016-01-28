From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 17/40] net: fec: move restart test for efficiency
Date: Thu, 28 Jan 2016 14:25:41 -0700
Message-ID: <1454016364-30985-18-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34093 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754927AbcA1V2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:37 -0500
Received: by mail-pf0-f176.google.com with SMTP id o185so25026859pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:37 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This saves 1 comparison.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1a838cc..fcbbf0d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1154,8 +1154,13 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 		/* Order the load of bd.cur and cbd_sc */
 		rmb();
 		status = READ_ONCE(bdp->cbd_sc);
-		if (status & BD_ENET_TX_READY)
+		if (status & BD_ENET_TX_READY) {
+			if (!readl(txq->bd.reg_desc_active)) {
+				/* ERR006358 has hit, restart tx */
+				writel(0, txq->bd.reg_desc_active);
+			}
 			break;
+		}
 
 		index = fec_enet_get_bd_index(bdp, &txq->bd);
 
@@ -1225,11 +1230,6 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 				netif_tx_wake_queue(nq);
 		}
 	}
-
-	/* ERR006538: Keep the transmitter going */
-	if (bdp != txq->bd.cur &&
-	    readl(txq->bd.reg_desc_active) == 0)
-		writel(0, txq->bd.reg_desc_active);
 }
 
 static int
-- 
2.5.0
