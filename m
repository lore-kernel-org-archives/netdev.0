From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] net: fec: Ensure clocks are enabled while using mdio bus
Date: Fri, 12 Jun 2015 17:39:05 +0200
Message-ID: <1434123545-13549-1-git-send-email-andrew@lunn.ch>
Cc: Nimrod Andy <B38611@freescale.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55288 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbbFLPpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2015 11:45:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a switch is attached to the mdio bus, the mdio bus can be used
while the interface is not open. If the clocks are not enabled, MDIO
reads/writes will simply time out. So enable the clocks before
starting a transaction, and disable them afterwards. The CCF performs
reference counting so the clocks will only be disabled if there are no
other users.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/freescale/fec_main.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bf4cf3fbb5f2..122186b90cdb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -65,6 +65,7 @@
 
 static void set_multicast_list(struct net_device *ndev);
 static void fec_enet_itr_coal_init(struct net_device *ndev);
+static int fec_enet_clk_enable(struct net_device *ndev, bool enable);
 
 #define DRIVER_NAME	"fec"
 
@@ -1764,6 +1765,11 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
 	struct fec_enet_private *fep = bus->priv;
 	unsigned long time_left;
+	int ret;
+
+	ret = fec_enet_clk_enable(fep->netdev, true);
+	if (ret)
+		return 0xffff;
 
 	fep->mii_timeout = 0;
 	init_completion(&fep->mdio_done);
@@ -1779,11 +1785,14 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		netdev_err(fep->netdev, "MDIO read timeout\n");
+		fec_enet_clk_enable(fep->netdev, false);
 		return -ETIMEDOUT;
 	}
 
-	/* return value */
-	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
+	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
+	fec_enet_clk_enable(fep->netdev, false);
+
+	return ret;
 }
 
 static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
@@ -1791,10 +1800,15 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 {
 	struct fec_enet_private *fep = bus->priv;
 	unsigned long time_left;
+	int ret;
 
 	fep->mii_timeout = 0;
 	init_completion(&fep->mdio_done);
 
+	ret = fec_enet_clk_enable(fep->netdev, true);
+	if (ret)
+		netdev_err(fep->netdev, "Unable to enable clks\n");
+
 	/* start a write op */
 	writel(FEC_MMFR_ST | FEC_MMFR_OP_WRITE |
 		FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) |
@@ -1807,9 +1821,12 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		netdev_err(fep->netdev, "MDIO write timeout\n");
+		fec_enet_clk_enable(fep->netdev, false);
 		return -ETIMEDOUT;
 	}
 
+	fec_enet_clk_enable(fep->netdev, false);
+
 	return 0;
 }
 
-- 
2.1.4
