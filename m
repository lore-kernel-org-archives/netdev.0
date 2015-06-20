From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv3 net-next] net: fec: Ensure clocks are enabled while using mdio bus
Date: Sat, 20 Jun 2015 20:38:29 +0200
Message-ID: <1434825509-11241-1-git-send-email-andrew@lunn.ch>
Cc: Nimrod Andy <B38611@freescale.com>,
	Duan Andy <fugang.duan@freescale.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60042 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753701AbbFTSo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 14:44:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a switch is attached to the mdio bus, the mdio bus can be used
while the interface is not open. If the IPG clock are not enabled,
MDIO reads/writes will simply time out. So enable the clock before
starting a transaction, and disable it afterwards. The CCF performs
reference counting so the clock will only be disabled if there are no
other users.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

v3:
 Return the error code from clk_prepare_enable()
v2:
 Only enable the IGP clock.

 drivers/net/ethernet/freescale/fec_main.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bf4cf3fbb5f2..8d9b1fd175f7 100644
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
+	ret = clk_prepare_enable(fep->clk_ipg);
+	if (ret)
+		return ret;
 
 	fep->mii_timeout = 0;
 	init_completion(&fep->mdio_done);
@@ -1779,11 +1785,14 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		netdev_err(fep->netdev, "MDIO read timeout\n");
+		clk_disable_unprepare(fep->clk_ipg);
 		return -ETIMEDOUT;
 	}
 
-	/* return value */
-	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
+	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
+	clk_disable_unprepare(fep->clk_ipg);
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
 
+	ret = clk_prepare_enable(fep->clk_ipg);
+	if (ret)
+		return ret;
+
 	/* start a write op */
 	writel(FEC_MMFR_ST | FEC_MMFR_OP_WRITE |
 		FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) |
@@ -1807,9 +1821,12 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		netdev_err(fep->netdev, "MDIO write timeout\n");
+		clk_disable_unprepare(fep->clk_ipg);
 		return -ETIMEDOUT;
 	}
 
+	clk_disable_unprepare(fep->clk_ipg);
+
 	return 0;
 }
 
-- 
2.1.4
