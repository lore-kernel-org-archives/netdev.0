From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 13/40] net: fec: split off napi routine with 3 queues
Date: Thu, 28 Jan 2016 14:25:37 -0700
Message-ID: <1454016364-30985-14-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33553 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754927AbcA1V2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:30 -0500
Received: by mail-pa0-f50.google.com with SMTP id cy9so29202016pac.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:30 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we only have 1 tx/rx queue, we need not check
the other queues.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 39 +++++++++++++++++++++++++++++--
 1 file changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 8bebf01..04b1fb7 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1510,7 +1510,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
+static int fec_enet_napi_q3(struct napi_struct *napi, int budget)
 {
 	struct net_device *ndev = napi->dev;
 	struct fec_enet_private *fep = netdev_priv(ndev);
@@ -1553,6 +1553,39 @@ static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 	return pkts;
 }
 
+static int fec_enet_napi_q1(struct napi_struct *napi, int budget)
+{
+	struct net_device *ndev = napi->dev;
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	int pkts = 0;
+	uint events;
+
+	do {
+		events = readl(fep->hwp + FEC_IEVENT);
+		if (fep->events) {
+			events |= fep->events;
+			fep->events = 0;
+		}
+		events &= FEC_ENET_RXF_0 | FEC_ENET_TXF_0;
+		if (!events) {
+			if (budget) {
+				napi_complete(napi);
+				writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+			}
+			return pkts;
+		}
+
+		writel(events, fep->hwp + FEC_IEVENT);
+		if (events & FEC_ENET_RXF_0)
+			pkts += fec_rxq(ndev, fep, fep->rx_queue[0],
+					budget - pkts);
+		if (events & FEC_ENET_TXF_0)
+			fec_txq(ndev, fep, fep->tx_queue[0]);
+	} while (pkts < budget);
+	fep->events |= FEC_ENET_RXF_0;	/* save for next callback */
+	return pkts;
+}
+
 /* ------------------------------------------------------------------------- */
 static void fec_get_mac(struct net_device *ndev)
 {
@@ -3113,7 +3146,9 @@ static int fec_enet_init(struct net_device *ndev)
 	ndev->ethtool_ops = &fec_enet_ethtool_ops;
 
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
-	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, NAPI_POLL_WEIGHT);
+	netif_napi_add(ndev, &fep->napi, (fep->num_rx_queues |
+		       fep->num_tx_queues) == 1 ? fec_enet_napi_q1 :
+		       fec_enet_napi_q3, NAPI_POLL_WEIGHT);
 
 	if (fep->quirks & FEC_QUIRK_HAS_VLAN)
 		/* enable hw VLAN support */
-- 
2.5.0
