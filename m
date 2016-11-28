From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [patch net] net: fec: cache statistics while device is down
Date: Mon, 28 Nov 2016 17:27:07 +0300
Message-ID: <1480343227-725-1-git-send-email-nikita.yoush@cogentembedded.com>
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel@vger.kernel.org,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: "David S. Miller" <davem@davemloft.net>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Execution 'ethtool -S' on fec device that is down causes OOPS on Vybrid
board:

Unhandled fault: external abort on non-linefetch (0x1008) at 0xe0898200
pgd = ddecc000
[e0898200] *pgd=9e406811, *pte=400d1653, *ppte=400d1453
Internal error: : 1008 [#1] SMP ARM
...

Reason of OOPS is that fec_enet_get_ethtool_stats() accesses fec
registers while IPG clock is stopped by PM.

Fix that by caching statistics in fec_enet_private. Cache is updated
just before statistics request if device is up, and also just before
turning device off on down path.

Additional locking is not needed, since cached statistics is always
updated under rtnl_lock().

Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
---
 drivers/net/ethernet/freescale/fec.h      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c | 21 +++++++++++++++++----
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index c865135f3cb9..5ea740b4cf14 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -574,6 +574,8 @@ struct fec_enet_private {
 	unsigned int reload_period;
 	int pps_enable;
 	unsigned int next_counter;
+
+	u64 ethtool_stats[0];
 };
 
 void fec_ptp_init(struct platform_device *pdev);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5aa9d4ded214..7da2d94ec8e5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2313,14 +2313,24 @@ static const struct fec_stat {
 	{ "IEEE_rx_octets_ok", IEEE_R_OCTETS_OK },
 };
 
-static void fec_enet_get_ethtool_stats(struct net_device *dev,
-	struct ethtool_stats *stats, u64 *data)
+static void fec_enet_update_ethtool_stats(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(fec_stats); i++)
-		data[i] = readl(fep->hwp + fec_stats[i].offset);
+		fep->ethtool_stats[i] = readl(fep->hwp + fec_stats[i].offset);
+}
+
+static void fec_enet_get_ethtool_stats(struct net_device *dev,
+				       struct ethtool_stats *stats, u64 *data)
+{
+	struct fec_enet_private *fep = netdev_priv(dev);
+
+	if (netif_running(dev))
+		fec_enet_update_ethtool_stats(dev);
+
+	memcpy(data, fep->ethtool_stats, ARRAY_SIZE(fec_stats) * sizeof(u64));
 }
 
 static void fec_enet_get_strings(struct net_device *netdev,
@@ -2874,6 +2884,8 @@ fec_enet_close(struct net_device *ndev)
 	if (fep->quirks & FEC_QUIRK_ERR006687)
 		imx6q_cpuidle_fec_irqs_unused();
 
+	fec_enet_update_ethtool_stats(ndev);
+
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 	pm_runtime_mark_last_busy(&fep->pdev->dev);
@@ -3278,7 +3290,8 @@ fec_probe(struct platform_device *pdev)
 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
 
 	/* Init network device */
-	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private),
+	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
+				  ARRAY_SIZE(fec_stats) * sizeof(u64),
 				  num_tx_qs, num_rx_qs);
 	if (!ndev)
 		return -ENOMEM;
-- 
2.1.4
