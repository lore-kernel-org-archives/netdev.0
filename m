From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: fec: Issue error for missing but expected PHY
Date: Sun, 30 Jul 2017 22:11:06 +0200
Message-ID: <1501445466-23518-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Fugang Duan <fugang.duan@nxp.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45236 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754192AbdG3UL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:11:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the PHY is missing but expected, e.g. because of a typ0 in the dt
file, it is not possible to open the interface. ip link returns:

RTNETLINK answers: No such device

It is not very obvious what the problem is. Add a netdev_err() in this
case to make it easier to debug the issue.

[   21.409385] fec 2188000.ethernet eth0: Unable to connect to phy
RTNETLINK answers: No such device

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cc0c2a58c4de..c5995f07f821 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1907,8 +1907,10 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 		phy_dev = of_phy_connect(ndev, fep->phy_node,
 					 &fec_enet_adjust_link, 0,
 					 fep->phy_interface);
-		if (!phy_dev)
+		if (!phy_dev) {
+			netdev_err(ndev, "Unable to connect to phy\n");
 			return -ENODEV;
+		}
 	} else {
 		/* check for attached phy */
 		for (phy_id = 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
-- 
2.13.2
