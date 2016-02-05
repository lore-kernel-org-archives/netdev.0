From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 7/8] net: fec: don't transfer ownership until descriptor write is complete
Date: Fri,  5 Feb 2016 14:52:49 -0700
Message-ID: <1454709170-19527-8-git-send-email-troy.kisky@boundarydevices.com>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de,
	Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36804 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbcBEVzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 16:55:16 -0500
Received: by mail-pa0-f49.google.com with SMTP id yy13so40329963pab.3
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 13:55:16 -0800 (PST)
In-Reply-To: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you don't own it, you shouldn't write to it.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ca2708d..97ca72a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -390,6 +390,10 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 
 		bdp->cbd_bufaddr = cpu_to_fec32(addr);
 		bdp->cbd_datlen = cpu_to_fec16(frag_len);
+		/* Make sure the updates to rest of the descriptor are
+		 * performed before transferring ownership.
+		 */
+		wmb();
 		bdp->cbd_sc = cpu_to_fec16(status);
 	}
 
@@ -499,6 +503,10 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 
 	bdp->cbd_datlen = cpu_to_fec16(buflen);
 	bdp->cbd_bufaddr = cpu_to_fec32(addr);
+	/* Make sure the updates to rest of the descriptor are performed before
+	 * transferring ownership.
+	 */
+	wmb();
 
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
@@ -1475,7 +1483,6 @@ rx_processing_done:
 
 		/* Mark the buffer empty */
 		status |= BD_ENET_RX_EMPTY;
-		bdp->cbd_sc = cpu_to_fec16(status);
 
 		if (fep->bufdesc_ex) {
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
@@ -1484,6 +1491,11 @@ rx_processing_done:
 			ebdp->cbd_prot = 0;
 			ebdp->cbd_bdu = 0;
 		}
+		/* Make sure the updates to rest of the descriptor are
+		 * performed before transferring ownership.
+		 */
+		wmb();
+		bdp->cbd_sc = cpu_to_fec16(status);
 
 		/* Update BD pointer to next entry */
 		bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
-- 
2.5.0
