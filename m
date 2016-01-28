From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 19/40] net: fec: dump all tx queues in fec_dump
Date: Thu, 28 Jan 2016 14:25:43 -0700
Message-ID: <1454016364-30985-20-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35612 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857AbcA1V2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:40 -0500
Received: by mail-pa0-f41.google.com with SMTP id ho8so29143554pac.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:40 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump all tx queues, not just queue 0.
Also, disable fec interrupts first.
The interrupts will be reenabled in fec_restart.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 36 +++++++++++++++++--------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1759705..1225282 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -271,26 +271,30 @@ static void swap_buffer2(void *dst_buf, void *src_buf, int len)
 static void fec_dump(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct bufdesc *bdp;
-	struct fec_enet_priv_tx_q *txq;
-	int index = 0;
+	int i;
 
+	/* Disable all FEC interrupts */
+	writel(0, fep->hwp + FEC_IMASK);
 	netdev_info(ndev, "TX ring dump\n");
 	pr_info("Nr     SC     addr       len  SKB\n");
 
-	txq = fep->tx_queue[0];
-	bdp = txq->bd.base;
-
-	do {
-		pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
-			index,
-			bdp == txq->bd.cur ? 'S' : ' ',
-			bdp == txq->dirty_tx ? 'H' : ' ',
-			bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
-			txq->tx_skbuff[index]);
-		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-		index++;
-	} while (bdp != txq->bd.base);
+	for (i = 0; i < fep->num_tx_queues; i++) {
+		struct fec_enet_priv_tx_q *txq = fep->tx_queue[i];
+		struct bufdesc *bdp = txq->bd.base;
+		int index = 0;
+
+		pr_info("tx queue %d\n", i);
+		do {
+			pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
+				index,
+				bdp == txq->bd.cur ? 'S' : ' ',
+				bdp == txq->dirty_tx ? 'H' : ' ',
+				bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
+				txq->tx_skbuff[index]);
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+			index++;
+		} while (bdp != txq->bd.base);
+	}
 }
 
 static inline bool is_ipv4_pkt(struct sk_buff *skb)
-- 
2.5.0
