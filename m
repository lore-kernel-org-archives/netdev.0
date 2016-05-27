From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net v2 1/1] net: fec: update dirty_tx even if no skb
Date: Fri, 27 May 2016 13:30:40 -0700
Message-ID: <1464381040-19896-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, holgerschurig@gmail.com,
	Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34207 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbcE0Uat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 16:30:49 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so13414183pad.1
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 13:30:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dirty_tx isn't updated, then dma_unmap_single
can be called twice.

This fixes a
[   58.420980] ------------[ cut here ]------------
[   58.425667] WARNING: CPU: 0 PID: 377 at /home/schurig/d/mkarm/linux-4.5/lib/dma-debug.c:1096 check_unmap+0x9d0/0xab8()
[   58.436405] fec 2188000.ethernet: DMA-API: device driver tries to free DMA memory it has not allocated [device address=0x0000000000000000] [size=66 bytes]

encountered by Holger

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
Tested-by: <holgerschurig@gmail.com>
Acked-by: Fugang Duan <fugang.duan@nxp.com>

---
v2: add ack
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ca2cccc..3c0255e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1197,10 +1197,8 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 					 fec16_to_cpu(bdp->cbd_datlen),
 					 DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = cpu_to_fec32(0);
-		if (!skb) {
-			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-			continue;
-		}
+		if (!skb)
+			goto skb_done;
 
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
@@ -1239,7 +1237,7 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 
 		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
-
+skb_done:
 		/* Make sure the update to bdp and tx_skbuff are performed
 		 * before dirty_tx
 		 */
-- 
2.5.0
