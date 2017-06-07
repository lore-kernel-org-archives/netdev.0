From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: fec: Clear and enable MIB counters on imx51
Date: Wed,  7 Jun 2017 03:57:09 +0200
Message-ID: <1496800629-24910-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Chris Healy <cphealy@gmail.com>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39110 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751453AbdFGB5q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 21:57:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both the IMX51 and IMX53 datasheet indicates that the MIB counters
should be cleared during setup. Otherwise random numbers are returned
via ethtool -S.  Add a quirk and a function to do this.

Tested on an IMX51.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/freescale/fec.h      |  4 ++++
 drivers/net/ethernet/freescale/fec_main.c | 27 ++++++++++++++++++++++++---
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 5ea740b4cf14..38c7b21e5d63 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -446,6 +446,10 @@ struct bufdesc_ex {
 #define FEC_QUIRK_HAS_COALESCE		(1 << 13)
 /* Interrupt doesn't wake CPU from deep idle */
 #define FEC_QUIRK_ERR006687		(1 << 14)
+/* The MIB counters should be cleared and enabled during
+ * initialisation.
+ */
+#define FEC_QUIRK_MIB_CLEAR		(1 << 15)
 
 struct bufdesc_prop {
 	int qid;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f7c8649fd28f..297fd196c879 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -89,10 +89,10 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = 0,
 	}, {
 		.name = "imx25-fec",
-		.driver_data = FEC_QUIRK_USE_GASKET,
+		.driver_data = FEC_QUIRK_USE_GASKET | FEC_QUIRK_MIB_CLEAR,
 	}, {
 		.name = "imx27-fec",
-		.driver_data = 0,
+		.driver_data = FEC_QUIRK_MIB_CLEAR,
 	}, {
 		.name = "imx28-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME |
@@ -184,6 +184,9 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define FEC_RACC_SHIFT16	BIT(7)
 #define FEC_RACC_OPTIONS	(FEC_RACC_IPDIS | FEC_RACC_PRODIS)
 
+/* MIB Control Register */
+#define FEC_MIB_CTRLSTAT_DISABLE	BIT(31)
+
 /*
  * The 5270/5271/5280/5282/532x RX control register also contains maximum frame
  * size bits. Other FEC hardware does not, so we need to take that into
@@ -2356,6 +2359,21 @@ static int fec_enet_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+static void fec_enet_clear_ethtool_stats(struct net_device *dev)
+{
+	struct fec_enet_private *fep = netdev_priv(dev);
+	int i;
+
+	/* Disable MIB statistics counters */
+	writel(FEC_MIB_CTRLSTAT_DISABLE, fep->hwp + FEC_MIB_CTRLSTAT);
+
+	for (i = 0; i < ARRAY_SIZE(fec_stats); i++)
+		writel(0, fep->hwp + fec_stats[i].offset);
+
+	/* Don't disable MIB statistics counters */
+	writel(0, fep->hwp + FEC_MIB_CTRLSTAT);
+}
+
 #else	/* !defined(CONFIG_M5272) */
 #define FEC_STATS_SIZE	0
 static inline void fec_enet_update_ethtool_stats(struct net_device *dev)
@@ -3182,7 +3200,10 @@ static int fec_enet_init(struct net_device *ndev)
 
 	fec_restart(ndev);
 
-	fec_enet_update_ethtool_stats(ndev);
+	if (fep->quirks & FEC_QUIRK_MIB_CLEAR)
+		fec_enet_clear_ethtool_stats(ndev);
+	else
+		fec_enet_update_ethtool_stats(ndev);
 
 	return 0;
 }
-- 
2.11.0
