From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v3 8/9] amd-xgbe: Fix Rx coalescing reporting
Date: Fri, 20 Mar 2015 11:50:34 -0500
Message-ID: <20150320165034.13799.31687.stgit@tlendack-t1.amdoffice.net>
References: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0130.outbound.protection.outlook.com ([157.56.111.130]:34208
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752126AbbCTQuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 12:50:39 -0400
In-Reply-To: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Rx coalescing value is internally converted from usecs to a value
that the hardware can use. When reporting the Rx coalescing value, this
internal value is converted back to usecs. During the conversion from
and back to usecs some rounding occurs. So, for example, when setting an
Rx usec of 30, it will be reported as 29. Fix this reporting issue by
keeping the original usec value and using that during reporting.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    1 +
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   12 +++++-------
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    1 +
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 122a631..fc362be 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -702,6 +702,7 @@ void xgbe_init_rx_coalesce(struct xgbe_prv_data *pdata)
 	DBGPR("-->xgbe_init_rx_coalesce\n");
 
 	pdata->rx_riwt = hw_if->usec_to_riwt(pdata, XGMAC_INIT_DMA_RX_USECS);
+	pdata->rx_usecs = XGMAC_INIT_DMA_RX_USECS;
 	pdata->rx_frames = XGMAC_INIT_DMA_RX_FRAMES;
 
 	hw_if->config_rx_coalesce(pdata);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 376d6a5..b4f6eaa 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -377,15 +377,12 @@ static int xgbe_get_coalesce(struct net_device *netdev,
 			     struct ethtool_coalesce *ec)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
-	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	unsigned int riwt;
 
 	DBGPR("-->xgbe_get_coalesce\n");
 
 	memset(ec, 0, sizeof(struct ethtool_coalesce));
 
-	riwt = pdata->rx_riwt;
-	ec->rx_coalesce_usecs = hw_if->riwt_to_usec(pdata, riwt);
+	ec->rx_coalesce_usecs = pdata->rx_usecs;
 	ec->rx_max_coalesced_frames = pdata->rx_frames;
 
 	ec->tx_max_coalesced_frames = pdata->tx_frames;
@@ -438,17 +435,17 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	}
 
 	rx_riwt = hw_if->usec_to_riwt(pdata, ec->rx_coalesce_usecs);
+	rx_usecs = ec->rx_coalesce_usecs;
 	rx_frames = ec->rx_max_coalesced_frames;
 
 	/* Use smallest possible value if conversion resulted in zero */
-	if (ec->rx_coalesce_usecs && !rx_riwt)
+	if (rx_usecs && !rx_riwt)
 		rx_riwt = 1;
 
 	/* Check the bounds of values for Rx */
 	if (rx_riwt > XGMAC_MAX_DMA_RIWT) {
-		rx_usecs = hw_if->riwt_to_usec(pdata, XGMAC_MAX_DMA_RIWT);
 		netdev_alert(netdev, "rx-usec is limited to %d usecs\n",
-			     rx_usecs);
+			     hw_if->riwt_to_usec(pdata, XGMAC_MAX_DMA_RIWT));
 		return -EINVAL;
 	}
 	if (rx_frames > pdata->rx_desc_count) {
@@ -467,6 +464,7 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	}
 
 	pdata->rx_riwt = rx_riwt;
+	pdata->rx_usecs = rx_usecs;
 	pdata->rx_frames = rx_frames;
 	hw_if->config_rx_coalesce(pdata);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 72b8f27..dd74242 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -716,6 +716,7 @@ struct xgbe_prv_data {
 
 	/* Rx coalescing settings */
 	unsigned int rx_riwt;
+	unsigned int rx_usecs;
 	unsigned int rx_frames;
 
 	/* Current Rx buffer size */
