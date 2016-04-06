From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 12/16] net: fec: dump all tx queues in fec_dump
Date: Tue,  5 Apr 2016 19:25:58 -0700
Message-ID: <1459909562-22865-13-git-send-email-troy.kisky@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35557 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760246AbcDFC2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:34 -0400
Received: by mail-pa0-f51.google.com with SMTP id td3so22733289pab.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:34 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump all tx queues, not just queue 0.
Also, disable fec interrupts first.
The interrupts will be reenabled in fec_restart.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

---
v3: no change
---
 drivers/net/ethernet/freescale/fec_main.c | 40 +++++++++++++++++--------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f96ea97..be875fd 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -271,28 +271,32 @@ static void swap_buffer2(void *dst_buf, void *src_buf, int len)
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
-		pr_info("%3u %c%c 0x%04x 0x%08x %4u %p\n",
-			index,
-			bdp == txq->bd.cur ? 'S' : ' ',
-			bdp == txq->dirty_tx ? 'H' : ' ',
-			fec16_to_cpu(bdp->cbd_sc),
-			fec32_to_cpu(bdp->cbd_bufaddr),
-			fec16_to_cpu(bdp->cbd_datlen),
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
+			pr_info("%3u %c%c 0x%04x 0x%08x %4u %p\n",
+				index,
+				bdp == txq->bd.cur ? 'S' : ' ',
+				bdp == txq->dirty_tx ? 'H' : ' ',
+				fec16_to_cpu(bdp->cbd_sc),
+				fec32_to_cpu(bdp->cbd_bufaddr),
+				fec16_to_cpu(bdp->cbd_datlen),
+				txq->tx_skbuff[index]);
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+			index++;
+		} while (bdp != txq->bd.base);
+	}
 }
 
 static inline bool is_ipv4_pkt(struct sk_buff *skb)
-- 
2.5.0
