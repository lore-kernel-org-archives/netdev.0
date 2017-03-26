From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: tehuti: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 26 Mar 2017 22:03:13 +0200
Message-ID: <1490558593-17411-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: andy@greyhouse.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/tehuti/tehuti.c |   43 ++++++++++++++-------------------
 1 files changed, 18 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index f864fd0..711fbbb 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -2124,33 +2124,26 @@ static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, int size)
 };
 
 /*
- * bdx_get_settings - get device-specific settings
+ * bdx_get_link_ksettings - get device-specific settings
  * @netdev
  * @ecmd
  */
-static int bdx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
-{
-	u32 rdintcm;
-	u32 tdintcm;
-	struct bdx_priv *priv = netdev_priv(netdev);
-
-	rdintcm = priv->rdintcm;
-	tdintcm = priv->tdintcm;
-
-	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	ethtool_cmd_speed_set(ecmd, SPEED_10000);
-	ecmd->duplex = DUPLEX_FULL;
-	ecmd->port = PORT_FIBRE;
-	ecmd->transceiver = XCVR_EXTERNAL;	/* what does it mean? */
-	ecmd->autoneg = AUTONEG_DISABLE;
-
-	/* PCK_TH measures in multiples of FIFO bytes
-	   We translate to packets */
-	ecmd->maxtxpkt =
-	    ((GET_PCK_TH(tdintcm) * PCK_TH_MULT) / BDX_TXF_DESC_SZ);
-	ecmd->maxrxpkt =
-	    ((GET_PCK_TH(rdintcm) * PCK_TH_MULT) / sizeof(struct rxf_desc));
+static int bdx_get_link_ksettings(struct net_device *netdev,
+				  struct ethtool_link_ksettings *ecmd)
+{
+	ethtool_link_ksettings_zero_link_mode(ecmd, supported);
+	ethtool_link_ksettings_add_link_mode(ecmd, supported,
+					     10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(ecmd, supported, FIBRE);
+	ethtool_link_ksettings_zero_link_mode(ecmd, advertising);
+	ethtool_link_ksettings_add_link_mode(ecmd, advertising,
+					     10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(ecmd, advertising, FIBRE);
+
+	ecmd->base.speed = SPEED_10000;
+	ecmd->base.duplex = DUPLEX_FULL;
+	ecmd->base.port = PORT_FIBRE;
+	ecmd->base.autoneg = AUTONEG_DISABLE;
 
 	return 0;
 }
@@ -2384,7 +2377,6 @@ static void bdx_get_ethtool_stats(struct net_device *netdev,
 static void bdx_set_ethtool_ops(struct net_device *netdev)
 {
 	static const struct ethtool_ops bdx_ethtool_ops = {
-		.get_settings = bdx_get_settings,
 		.get_drvinfo = bdx_get_drvinfo,
 		.get_link = ethtool_op_get_link,
 		.get_coalesce = bdx_get_coalesce,
@@ -2394,6 +2386,7 @@ static void bdx_set_ethtool_ops(struct net_device *netdev)
 		.get_strings = bdx_get_strings,
 		.get_sset_count = bdx_get_sset_count,
 		.get_ethtool_stats = bdx_get_ethtool_stats,
+		.get_link_ksettings = bdx_get_link_ksettings,
 	};
 
 	netdev->ethtool_ops = &bdx_ethtool_ops;
-- 
1.7.4.4
