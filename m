From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v2 1/1 net-next] net: fec: report correct hardware stamping info to ethtool
Date: Mon, 7 Jan 2013 10:25:07 +0800
Message-ID: <1357525507-16148-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>,
	<richardcochran@gmail.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:43414
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753409Ab3AGDE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 22:04:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report correct hardware stamping capability by ethtool interface.
The v1.0 ptp4l check it.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
Change v1->v2
 1. s/capibilty/capability/
 2. apply Sascha's feedback 
    avoid return the return value of ethtool_op_get_ts_info()
    when bufdesc_ex ==  1

 drivers/net/ethernet/freescale/fec.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index a379319..1c117e5 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1173,12 +1173,41 @@ static void fec_enet_get_drvinfo(struct net_device *ndev,
 	strcpy(info->bus_info, dev_name(&ndev->dev));
 }
 
+static int fec_enet_get_ts_info(struct net_device *ndev,
+				struct ethtool_ts_info *info)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	if (fep->bufdesc_ex) {
+
+		info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+					SOF_TIMESTAMPING_RX_SOFTWARE |
+					SOF_TIMESTAMPING_SOFTWARE |
+					SOF_TIMESTAMPING_TX_HARDWARE |
+					SOF_TIMESTAMPING_RX_HARDWARE |
+					SOF_TIMESTAMPING_RAW_HARDWARE;
+		if (fep->ptp_clock)
+			info->phc_index = ptp_clock_index(fep->ptp_clock);
+		else
+			info->phc_index = -1;
+
+		info->tx_types = (1 << HWTSTAMP_TX_OFF) |
+				 (1 << HWTSTAMP_TX_ON);
+
+		info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+				   (1 << HWTSTAMP_FILTER_ALL);
+		return 0;
+	} else {
+		return ethtool_op_get_ts_info(ndev, info);
+	}
+}
+
 static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ts_info		= fec_enet_get_ts_info,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.7.1
