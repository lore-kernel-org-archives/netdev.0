From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: fec: only clear a queue's work bit if the queue was emptied
Date: Tue,  3 May 2016 16:38:53 +0200
Message-ID: <1462286333-23402-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de, netdev@vger.kernel.org
To: Fugang Duan <fugang.duan@nxp.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42895 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932269AbcECOjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 10:39:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the receive path a queue's work bit was cleared unconditionally even
if fec_enet_rx_queue only read out a part of the available packets from
the hardware. This resulted in not reading any packets in the next napi
turn and so packets were delayed or lost.

The obvious fix is to only clear a queue's bit when the queue was
emptied.

=46ixes: 4d494cdc92b3 ("net: fec: change data structure to support mult=
iqueue")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

I created this patch against net/master. If you think it's to late to
get it into 4.6 and it doesn't fit on net-next/master, just tell me and
I will rebase.

Best regards
Uwe


 drivers/net/ethernet/freescale/fec_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 08243c2ff4b4..2a03857cca18 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1521,9 +1521,15 @@ fec_enet_rx(struct net_device *ndev, int budget)
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
=20
 	for_each_set_bit(queue_id, &fep->work_rx, FEC_ENET_MAX_RX_QS) {
-		clear_bit(queue_id, &fep->work_rx);
-		pkt_received +=3D fec_enet_rx_queue(ndev,
+		int ret;
+
+		ret =3D fec_enet_rx_queue(ndev,
 					budget - pkt_received, queue_id);
+
+		if (ret < budget - pkt_received)
+			clear_bit(queue_id, &fep->work_rx);
+
+		pkt_received +=3D ret;
 	}
 	return pkt_received;
 }
--=20
2.8.0.rc3
