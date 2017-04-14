From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH net-next] net: mvneta: fix failed to suspend if WOL is enabled
Date: Fri, 14 Apr 2017 19:07:32 +0800
Message-ID: <20170414110732.3100-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Recently, suspend/resume and WOL support are added into mvneta driver.
If we enable WOL, then we get some error as below on Marvell BG4CT
platforms during suspend:

[  184.149723] dpm_run_callback(): mdio_bus_suspend+0x0/0x50 returns -16
[  184.149727] PM: Device f7b62004.mdio-mi:00 failed to suspend: error -16

-16 means -EBUSY, phy_suspend() will return -EBUSY if it finds the
device has WOL enabled.

We fix this issue by properly setting the netdev's power.can_wakeup
and power.wakeup, i.e

1. in mvneta_mdio_probe(), call device_set_wakeup_capable() to set
power.can_wakeup if the phy support WOL.

2. in mvneta_ethtool_set_wol(), call device_set_wakeup_enable() to
set power.wakeup if WOL has been successfully enabled in phy.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 34a3686d2ce6..0992db47070f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3318,6 +3318,7 @@ static void mvneta_adjust_link(struct net_device *ndev)
 static int mvneta_mdio_probe(struct mvneta_port *pp)
 {
 	struct phy_device *phy_dev;
+	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
 
 	phy_dev = of_phy_connect(pp->dev, pp->phy_node, mvneta_adjust_link, 0,
 				 pp->phy_interface);
@@ -3326,6 +3327,9 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
 		return -ENODEV;
 	}
 
+	phy_ethtool_get_wol(phy_dev, &wol);
+	device_set_wakeup_capable(&pp->dev->dev, !!wol.supported);
+
 	phy_dev->supported &= PHY_GBIT_FEATURES;
 	phy_dev->advertising = phy_dev->supported;
 
@@ -3942,10 +3946,16 @@ static void mvneta_ethtool_get_wol(struct net_device *dev,
 static int mvneta_ethtool_set_wol(struct net_device *dev,
 				  struct ethtool_wolinfo *wol)
 {
+	int ret;
+
 	if (!dev->phydev)
 		return -EOPNOTSUPP;
 
-	return phy_ethtool_set_wol(dev->phydev, wol);
+	ret = phy_ethtool_set_wol(dev->phydev, wol);
+	if (!ret)
+		device_set_wakeup_enable(&dev->dev, !!wol->wolopts);
+
+	return ret;
 }
 
 static const struct net_device_ops mvneta_netdev_ops = {
-- 
2.11.0
