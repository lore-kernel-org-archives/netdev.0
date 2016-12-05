From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [patch net v2] net: fec: fix compile with CONFIG_M5272
Date: Mon,  5 Dec 2016 11:16:03 +0300
Message-ID: <1480925763-20254-1-git-send-email-nikita.yoush@cogentembedded.com>
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

Commit 4dfb80d18d05 ("net: fec: cache statistics while device is down")
introduced unconditional statistics-related actions.

However, when driver is compiled with CONFIG_M5272, staticsics-related
definitions do not exist, which results into build errors.

Fix that by adding explicit handling of !defined(CONFIG_M5272) case.

Fixes: 4dfb80d18d05 ("net: fec: cache statistics while device is down")
Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
---
Changes since v1:
- instead of #ifdef'ing calls to fec_enet_update_ethtool_stats(), add
  definition of empty fec_enet_update_ethtool_stats() for CONFIG_M5272
  case,
- add FEC_STATS_SIZE macro to avoid #ifdef in the middle of
  alloc_etherdev_mqs() args.

 drivers/net/ethernet/freescale/fec_main.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5f77caa59534..741cf4a57bfc 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2313,6 +2313,8 @@ static const struct fec_stat {
 	{ "IEEE_rx_octets_ok", IEEE_R_OCTETS_OK },
 };
 
+#define FEC_STATS_SIZE		(ARRAY_SIZE(fec_stats) * sizeof(u64))
+
 static void fec_enet_update_ethtool_stats(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
@@ -2330,7 +2332,7 @@ static void fec_enet_get_ethtool_stats(struct net_device *dev,
 	if (netif_running(dev))
 		fec_enet_update_ethtool_stats(dev);
 
-	memcpy(data, fep->ethtool_stats, ARRAY_SIZE(fec_stats) * sizeof(u64));
+	memcpy(data, fep->ethtool_stats, FEC_STATS_SIZE);
 }
 
 static void fec_enet_get_strings(struct net_device *netdev,
@@ -2355,6 +2357,12 @@ static int fec_enet_get_sset_count(struct net_device *dev, int sset)
 		return -EOPNOTSUPP;
 	}
 }
+
+#else	/* !defined(CONFIG_M5272) */
+#define FEC_STATS_SIZE	0
+static inline void fec_enet_update_ethtool_stats(struct net_device *dev)
+{
+}
 #endif /* !defined(CONFIG_M5272) */
 
 static int fec_enet_nway_reset(struct net_device *dev)
@@ -3293,8 +3301,7 @@ fec_probe(struct platform_device *pdev)
 
 	/* Init network device */
 	ndev = alloc_etherdev_mqs(sizeof(struct fec_enet_private) +
-				  ARRAY_SIZE(fec_stats) * sizeof(u64),
-				  num_tx_qs, num_rx_qs);
+				  FEC_STAT_SIZE, num_tx_qs, num_rx_qs);
 	if (!ndev)
 		return -ENOMEM;
 
-- 
2.1.4
