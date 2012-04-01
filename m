From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 05/28] gianfar: Support the
	get_ts_info ethtool method.
Date: Sun,  1 Apr 2012 17:19:50 +0200
Message-ID: <ba0bf28891a28c9abef038a8efc2eaaee5259ee2.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.h         |    3 ++
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   29 ++++++++++++++++++++++
 drivers/net/ethernet/freescale/gianfar_ptp.c     |    2 +
 3 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 4c9f8d4..2136c7f 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1210,4 +1210,7 @@ struct filer_table {
 	struct gfar_filer_entry fe[MAX_FILER_CACHE_IDX + 20];
 };
 
+/* The gianfar_ptp module will set this variable */
+extern int gfar_phc_index;
+
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 8d74efd..27f49c7 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1739,6 +1739,34 @@ static int gfar_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	return ret;
 }
 
+int gfar_phc_index = -1;
+
+static int gfar_get_ts_info(struct net_device *dev,
+			    struct ethtool_ts_info *info)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)) {
+		info->so_timestamping =
+			SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_SOFTWARE;
+		info->phc_index = -1;
+		return 0;
+	}
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->phc_index = gfar_phc_index;
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_ALL);
+	return 0;
+}
+
 const struct ethtool_ops gfar_ethtool_ops = {
 	.get_settings = gfar_gsettings,
 	.set_settings = gfar_ssettings,
@@ -1761,4 +1789,5 @@ const struct ethtool_ops gfar_ethtool_ops = {
 #endif
 	.set_rxnfc = gfar_set_nfc,
 	.get_rxnfc = gfar_get_nfc,
+	.get_ts_info = gfar_get_ts_info,
 };
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 5fd620b..c08e5d4 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -515,6 +515,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 		err = PTR_ERR(etsects->clock);
 		goto no_clock;
 	}
+	gfar_phc_clock = ptp_clock_index(etsects->clock);
 
 	dev_set_drvdata(&dev->dev, etsects);
 
@@ -538,6 +539,7 @@ static int gianfar_ptp_remove(struct platform_device *dev)
 	gfar_write(&etsects->regs->tmr_temask, 0);
 	gfar_write(&etsects->regs->tmr_ctrl,   0);
 
+	gfar_phc_clock = -1;
 	ptp_clock_unregister(etsects->clock);
 	iounmap(etsects->regs);
 	release_resource(etsects->rsrc);
-- 
1.7.2.5


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
