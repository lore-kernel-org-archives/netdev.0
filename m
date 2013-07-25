From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net/fec: call netif_carrier_off when not having link
Date: Thu, 25 Jul 2013 15:27:55 +0200
Message-ID: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>, kernel@pengutronix.de,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46656 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609Ab3GYN2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:28:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch I see a machine running an -rt patched Linux being
stuck in sch_direct_xmit when it looses link while there is still a
packet to be send. In this case the fec_enet_start_xmit routine returns
NETDEV_TX_BUSY which makes the network stack reschedule the packet and
so sch_direct_xmit calls fec_enet_start_xmit again.

The right fix is to tell the network stack that the link was lost (usin=
g
netif_carrier_off) so that it doesn't even try to get rid of the pendin=
g
packets.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

this resembles a problem described on the linux-rt mailing list some
time ago:

	http://thread.gmane.org/gmane.linux.rt.user/7815

So I Cc:d the people that participated in that thread.

IMHO this is 3.11 material (assuming I did it right) and is even worth
backporting as I think the problem exists in mainline, too, just harder
to trigger.

Best regards
Uwe

 drivers/net/ethernet/freescale/fec_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 0642006..631bd5a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -280,11 +280,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct ne=
t_device *ndev)
 	unsigned short	status;
 	unsigned int index;
=20
-	if (!fep->link) {
-		/* Link is down or auto-negotiation is in progress. */
-		return NETDEV_TX_BUSY;
-	}
-
 	/* Fill in a Tx ring entry */
 	bdp =3D fep->cur_tx;
=20
@@ -459,6 +454,11 @@ fec_restart(struct net_device *ndev, int duplex)
 		netif_tx_lock_bh(ndev);
 	}
=20
+	if (!fep->link)
+		netif_carrier_off(ndev);
+	else
+		netif_carrier_on(ndev);
+
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
--=20
1.8.3.2
