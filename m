From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 04/26] gianfar: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:19 +0200
Message-ID: <c268d71203b066b9052a8cabd5f6c71de2a8fa77.1333529506.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56171 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077Ab2DDJAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:00:12 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so46815wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:00:12 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
