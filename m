From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] cpsw: cpts: enable HWTSTAMP_FILTER_PTP_V1_L4_EVENT filter
Date: Mon, 5 Jun 2017 18:21:08 -0500
Message-ID: <20170605232108.13453-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CPSW driver supports PTP v1 messages, but for unknown reasons this filter
is not advertised. As result,
./tools/testing/selftests/networking/timestamping/timestamping utility
can't be used for testing of CPSW RX timestamping with option
SOF_TIMESTAMPING_RX_HARDWARE, because it uses
HWTSTAMP_FILTER_PTP_V1_L4_SYNC filter.

Hence, fix it by advertising HWTSTAMP_FILTER_PTP_V1_L4_XXX filters
in CPSW driver.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 37fc165..b6a0d92 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1731,11 +1731,14 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 		cpts_rx_enable(cpts, 0);
 		break;
 	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_NTP_ALL:
+		return -ERANGE;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
-	case HWTSTAMP_FILTER_NTP_ALL:
-		return -ERANGE;
+		cpts_rx_enable(cpts, HWTSTAMP_FILTER_PTP_V1_L4_EVENT);
+		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+		break;
 	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
@@ -1745,7 +1748,7 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
-		cpts_rx_enable(cpts, 1);
+		cpts_rx_enable(cpts, HWTSTAMP_FILTER_PTP_V2_EVENT);
 		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		break;
 	default:
@@ -1784,7 +1787,7 @@ static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 	cfg.tx_type = cpts_is_tx_enabled(cpts) ?
 		      HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
 	cfg.rx_filter = (cpts_is_rx_enabled(cpts) ?
-			 HWTSTAMP_FILTER_PTP_V2_EVENT : HWTSTAMP_FILTER_NONE);
+			 cpts->rx_enable : HWTSTAMP_FILTER_NONE);
 
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
 }
@@ -2141,6 +2144,7 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 		(1 << HWTSTAMP_TX_ON);
 	info->rx_filters =
 		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
 		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
 	return 0;
 }
-- 
2.10.1
