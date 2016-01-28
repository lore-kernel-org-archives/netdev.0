From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 20/40] net: fec: detect tx int lost
Date: Thu, 28 Jan 2016 14:25:44 -0700
Message-ID: <1454016364-30985-21-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34130 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524AbcA1V2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:42 -0500
Received: by mail-pf0-f180.google.com with SMTP id o185so25027780pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:42 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a tx int is lost, no need to reset
the fec. Just mark the event and call napi_schedule.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 36 ++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1225282..47df66e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1091,14 +1091,48 @@ fec_stop(struct net_device *ndev)
 	}
 }
 
+uint txint_flags[] = {FEC_ENET_TXF_0, FEC_ENET_TXF_1, FEC_ENET_TXF_2};
 
 static void
 fec_timeout(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct bufdesc *bdp;
+	unsigned short status;
+	int i;
+	uint events = 0;
 
-	fec_dump(ndev);
+	for (i = 0; i < fep->num_tx_queues; i++) {
+		struct fec_enet_priv_tx_q *txq = fep->tx_queue[i];
+		int index;
+		struct sk_buff *skb = NULL;
+
+		bdp = txq->dirty_tx;
+		while (1) {
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+			if (bdp == txq->bd.cur)
+				break;
+			index = fec_enet_get_bd_index(bdp, &txq->bd);
+			skb = txq->tx_skbuff[index];
+			if (skb) {
+				status = bdp->cbd_sc;
+				if ((status & BD_ENET_TX_READY) == 0)
+					events |= txint_flags[i];
+				break;
+			}
+		}
+	}
+	if (events) {
+		fep->events |= events;
+		/* Disable the RX/TX interrupt */
+		writel(FEC_NAPI_IMASK, fep->hwp + FEC_IMASK);
+		napi_schedule(&fep->napi);
+		netif_wake_queue(fep->netdev);
+		pr_err("%s: tx int lost\n", __func__);
+		return;
+	}
 
+	fec_dump(ndev);
 	ndev->stats.tx_errors++;
 
 	schedule_work(&fep->tx_timeout_work);
-- 
2.5.0
