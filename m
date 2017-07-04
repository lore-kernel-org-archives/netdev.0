From: Atul Gupta <atul.gupta@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4: Support for get_ts_info ethtool method
Date: Tue,  4 Jul 2017 16:46:22 +0530
Message-ID: <1499166982-4875-4-git-send-email-atul.gupta@chelsio.com>
References: <1499166982-4875-1-git-send-email-atul.gupta@chelsio.com>
Cc: richardcochran@gmail.com, ganeshgr@chelsio.com,
        Atul Gupta <atul.gupta@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:62852 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751910AbdGDLRl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 07:17:41 -0400
In-Reply-To: <1499166982-4875-1-git-send-email-atul.gupta@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index e9bab72..26eb00a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -1113,14 +1113,31 @@ static int set_flash(struct net_device *netdev, struct ethtool_flash *ef)
 
 static int get_ts_info(struct net_device *dev, struct ethtool_ts_info *ts_info)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct  adapter *adapter = pi->adapter;
+
 	ts_info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
 				   SOF_TIMESTAMPING_RX_SOFTWARE |
 				   SOF_TIMESTAMPING_SOFTWARE;
 
 	ts_info->so_timestamping |= SOF_TIMESTAMPING_RX_HARDWARE |
+				    SOF_TIMESTAMPING_TX_HARDWARE |
 				    SOF_TIMESTAMPING_RAW_HARDWARE;
 
-	ts_info->phc_index = -1;
+	ts_info->tx_types = (1 << HWTSTAMP_TX_OFF) |
+			    (1 << HWTSTAMP_TX_ON);
+
+	ts_info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ);
+
+	if (adapter->ptp_clock)
+		ts_info->phc_index = ptp_clock_index(adapter->ptp_clock);
+	else
+		ts_info->phc_index = -1;
 
 	return 0;
 }
-- 
1.8.3.1
