From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Fri, 30 Aug 2013 12:35:25 +0800
Message-ID: <1377837325-5232-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>,
	<bhutchings@solarflare.com>, <l.stach@pengutronix.de>
To: <davem@davemloft.net>, <b20596@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:24703
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756364Ab3H3Emo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:42:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the current BD is the first BD, the previous BD entry
must be the last BD, not "bdp - 1".

Add BD entry check to get the previous BD entry correctly.

Signed-off-by: Fugang Duan  <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4ea1555..b13746f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -380,7 +380,15 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		}
 	}
 
-	bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
+	if (bdp == fep->tx_bd_base) {
+		if (fep->bufdesc_ex)
+			bdp_pre = (struct bufdesc *)((void *)bdp +
+				(sizeof(struct bufdesc_ex) * (TX_RING_SIZE - 1)));
+		else
+			bdp_pre = bdp + TX_RING_SIZE - 1;
+	} else {
+		bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
+	}
 	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
 	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
 		fep->delay_work.trig_tx = true;
-- 
1.7.1
