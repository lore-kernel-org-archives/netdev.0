From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 5/8] gianfar: Support the get_ts_info ethtool method.
Date: Sat, 17 Mar 2012 13:12:31 +0100
Message-ID: <914f876b267865916a9c891ff3091a2d2ef8de48.1331983687.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:48091 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030809Ab2CQMMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:12:55 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj6so1964362wib.1
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:12:54 -0700 (PDT)
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.h         |    3 ++
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   29 ++++++++++++++++++++++
 drivers/net/ethernet/freescale/gianfar_ptp.c     |    2 +
 3 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 4fe0f34..e1829e2 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1213,4 +1213,7 @@ struct filer_table {
 	struct gfar_filer_entry fe[MAX_FILER_CACHE_IDX + 20];
 };
 
+/* The gianfar_ptp module will set this variable */
+extern int gfar_phc_index;
+
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 5a78d55..3115c4a 100644
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
