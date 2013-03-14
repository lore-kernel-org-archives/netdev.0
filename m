From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] net: fec: restart the FEC when PHY speed changes
Date: Thu, 14 Mar 2013 16:12:01 +0100
Message-ID: <1363273921-5035-1-git-send-email-l.stach@pengutronix.de>
Cc: Frank Li <Frank.Li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47891 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755834Ab3CNPMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:12:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Proviously we would only restart the FEC when PHY link or duplex state
changed. PHY does not always bring down the link for speed changes, in
which case we would not detect any change and keep FEC running.

Switching link speed without restarting the FEC results in the FEC being
stuck in an indefinite state, generating error conditions for every
packet.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec.c |   26 +++++++++++++++-----------
 drivers/net/ethernet/freescale/fec.h |    1 +
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 069a155..61d2e62 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -934,24 +934,28 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 		goto spin_unlock;
 	}
 
-	/* Duplex link change */
 	if (phy_dev->link) {
-		if (fep->full_duplex != phy_dev->duplex) {
-			fec_restart(ndev, phy_dev->duplex);
-			/* prevent unnecessary second fec_restart() below */
+		if (!fep->link) {
 			fep->link = phy_dev->link;
 			status_change = 1;
 		}
-	}
 
-	/* Link on or off change */
-	if (phy_dev->link != fep->link) {
-		fep->link = phy_dev->link;
-		if (phy_dev->link)
+		if (fep->full_duplex != phy_dev->duplex)
+			status_change = 1;
+
+		if (phy_dev->speed != fep->speed) {
+			fep->speed = phy_dev->speed;
+			status_change = 1;
+		}
+
+		/* if any of the above changed restart the FEC */
+		if (status_change)
 			fec_restart(ndev, phy_dev->duplex);
-		else
+	} else {
+		if (fep->link) {
 			fec_stop(ndev);
-		status_change = 1;
+			status_change = 1;
+		}
 	}
 
 spin_unlock:
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index f539007..eb43729 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -240,6 +240,7 @@ struct fec_enet_private {
 	phy_interface_t	phy_interface;
 	int	link;
 	int	full_duplex;
+	int	speed;
 	struct	completion mdio_done;
 	int	irq[FEC_IRQ_NUM];
 	int	bufdesc_ex;
-- 
1.7.10.4
