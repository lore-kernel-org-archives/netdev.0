From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net/fec: Don't let ndo_start_xmit return NETDEV_TX_BUSY without link
Date: Tue, 30 Jul 2013 11:29:40 +0200
Message-ID: <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
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
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	Florian Fainelli <florian@openwrt.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43982 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925Ab3G3JaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 05:30:06 -0400
In-Reply-To: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't test for having link and let hardware deal with this situation.

Without this patch I see a machine running an -rt patched Linux being
stuck in sch_direct_xmit when it looses link while there is still a
packet to be sent. In this case the fec_enet_start_xmit routine returne=
d
NETDEV_TX_BUSY which makes the network stack reschedule the packet and
so sch_direct_xmit calls fec_enet_start_xmit again.
I failed to reproduce a complete hang without -rt, but I think the
problem exists there, too.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

this is a new variant of "[PATCH] net/fec: call netif_carrier_off when
not having link" that drops calling netif_carrier_{on,off} in
fec_restart because the phy library already handles that.

I think this is 3.11 material assuming you are ok with the patch now.

Best regards
Uwe

 drivers/net/ethernet/freescale/fec_main.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index ed61160..792d729 100644
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
--=20
1.8.3.2
