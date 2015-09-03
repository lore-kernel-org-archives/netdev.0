From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: [PATCH] net: fec: normalize return value of pm_runtime_get_sync()
 in MDIO write
Date: Thu, 03 Sep 2015 21:38:30 +0200
Message-ID: <55E8A1B6.2080008@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	=?UTF-8?B?IkxvdGhhciBXYcOfbWFubiI=?= <LW@KARO-electronics.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Andrew Lunn <andrew@lunn.ch>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If fec MDIO write method succeeds its return value comes from
call to pm_runtime_get_sync().
But pm_runtime_get_sync() can also return 1.

In case of Micrel KSZ9031 PHY this value will then
be returned along the call chain of phy_write() ->
ksz9031_extended_write() -> ksz9031_center_flp_timing() ->
ksz9031_config_init() -> phy_init_hw() -> phy_attach_direct() ->
phy_connect_direct().

Then phy_connect() will cast it into a pointer using ERR_PTR(),
which then fec_enet_mii_probe() will try to dereference
resulting in an oops.

Fix it by normalizing return value of pm_runtime_get_sync()
to be zero if positive in MDIO write method.

Signed-off-by: Maciej Szmigiero <mail@maciej.szmigiero.name>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 91925e3..6cc3340 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1816,11 +1816,13 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	struct fec_enet_private *fep = bus->priv;
 	struct device *dev = &fep->pdev->dev;
 	unsigned long time_left;
-	int ret = 0;
+	int ret;
 
 	ret = pm_runtime_get_sync(dev);
 	if (ret < 0)
 		return ret;
+	else
+		ret = 0;
 
 	fep->mii_timeout = 0;
 	reinit_completion(&fep->mdio_done);
