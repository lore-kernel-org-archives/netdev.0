From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 09/16] net: fec: move restart test for efficiency
Date: Wed, 24 Feb 2016 17:36:52 -0700
Message-ID: <1456360619-24390-10-git-send-email-troy.kisky@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35386 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757976AbcBYAk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:40:28 -0500
Received: by mail-pf0-f175.google.com with SMTP id c10so23034440pfc.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:40:27 -0800 (PST)
In-Reply-To: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This saves 1 comparison.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b5ed287..1902897 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1157,8 +1157,13 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 		/* Order the load of bd.cur and cbd_sc */
 		rmb();
 		status = fec16_to_cpu(READ_ONCE(bdp->cbd_sc));
-		if (status & BD_ENET_TX_READY)
+		if (status & BD_ENET_TX_READY) {
+			if (!readl(txq->bd.reg_desc_active)) {
+				/* ERR006358 has hit, restart tx */
+				writel(0, txq->bd.reg_desc_active);
+			}
 			break;
+		}
 
 		index = fec_enet_get_bd_index(bdp, &txq->bd);
 
@@ -1230,11 +1235,6 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
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
