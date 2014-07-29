From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 4/8] amd-xgbe: Base queue fifo size and enablement
 on ring count
Date: Tue, 29 Jul 2014 08:57:31 -0500
Message-ID: <20140729135731.2791.23799.stgit@tlendack-t1.amdoffice.net>
References: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0141.outbound.protection.outlook.com ([207.46.163.141]:36220
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753483AbaG2N5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 09:57:37 -0400
In-Reply-To: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting the fifo sizes for the queues and enabling the queues
use the number of active Tx and Rx queues that have been enabled
not the maximum number available.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |   42 +++++++++++++++--------------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |   10 ++++++-
 drivers/net/ethernet/amd/xgbe/xgbe.h      |    3 ++
 3 files changed, 33 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 098a746..2cdf34f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -247,7 +247,7 @@ static int xgbe_config_rsf_mode(struct xgbe_prv_data *pdata, unsigned int val)
 {
 	unsigned int i;
 
-	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+	for (i = 0; i < pdata->rx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RSF, val);
 
 	return 0;
@@ -257,7 +257,7 @@ static int xgbe_config_tsf_mode(struct xgbe_prv_data *pdata, unsigned int val)
 {
 	unsigned int i;
 
-	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TSF, val);
 
 	return 0;
@@ -268,7 +268,7 @@ static int xgbe_config_rx_threshold(struct xgbe_prv_data *pdata,
 {
 	unsigned int i;
 
-	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+	for (i = 0; i < pdata->rx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RTC, val);
 
 	return 0;
@@ -279,7 +279,7 @@ static int xgbe_config_tx_threshold(struct xgbe_prv_data *pdata,
 {
 	unsigned int i;
 
-	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TTC, val);
 
 	return 0;
@@ -343,12 +343,12 @@ static int xgbe_disable_tx_flow_control(struct xgbe_prv_data *pdata)
 	unsigned int i;
 
 	/* Clear MTL flow control */
-	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+	for (i = 0; i < pdata->rx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, 0);
 
 	/* Clear MAC flow control */
 	max_q_count = XGMAC_MAX_FLOW_CONTROL_QUEUES;
-	q_count = min_t(unsigned int, pdata->hw_feat.rx_q_cnt, max_q_count);
+	q_count = min_t(unsigned int, pdata->rx_q_count, max_q_count);
 	reg = MAC_Q0TFCR;
 	for (i = 0; i < q_count; i++) {
 		reg_val = XGMAC_IOREAD(pdata, reg);
@@ -368,12 +368,12 @@ static int xgbe_enable_tx_flow_control(struct xgbe_prv_data *pdata)
 	unsigned int i;
 
 	/* Set MTL flow control */
-	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+	for (i = 0; i < pdata->rx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, 1);
 
 	/* Set MAC flow control */
 	max_q_count = XGMAC_MAX_FLOW_CONTROL_QUEUES;
-	q_count = min_t(unsigned int, pdata->hw_feat.rx_q_cnt, max_q_count);
+	q_count = min_t(unsigned int, pdata->rx_q_count, max_q_count);
 	reg = MAC_Q0TFCR;
 	for (i = 0; i < q_count; i++) {
 		reg_val = XGMAC_IOREAD(pdata, reg);
@@ -1551,11 +1551,11 @@ static int xgbe_flush_tx_queues(struct xgbe_prv_data *pdata)
 {
 	unsigned int i, count;
 
-	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, FTQ, 1);
 
 	/* Poll Until Poll Condition */
-	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++) {
+	for (i = 0; i < pdata->tx_q_count; i++) {
 		count = 2000;
 		while (count-- && XGMAC_MTL_IOREAD_BITS(pdata, i,
 							MTL_Q_TQOMR, FTQ))
@@ -1700,13 +1700,13 @@ static void xgbe_config_tx_fifo_size(struct xgbe_prv_data *pdata)
 	unsigned int i;
 
 	fifo_size = xgbe_calculate_per_queue_fifo(pdata->hw_feat.tx_fifo_size,
-						  pdata->hw_feat.tx_q_cnt);
+						  pdata->tx_q_count);
 
-	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TQS, fifo_size);
 
 	netdev_notice(pdata->netdev, "%d Tx queues, %d byte fifo per queue\n",
-		      pdata->hw_feat.tx_q_cnt, ((fifo_size + 1) * 256));
+		      pdata->tx_q_count, ((fifo_size + 1) * 256));
 }
 
 static void xgbe_config_rx_fifo_size(struct xgbe_prv_data *pdata)
@@ -1715,19 +1715,19 @@ static void xgbe_config_rx_fifo_size(struct xgbe_prv_data *pdata)
 	unsigned int i;
 
 	fifo_size = xgbe_calculate_per_queue_fifo(pdata->hw_feat.rx_fifo_size,
-						  pdata->hw_feat.rx_q_cnt);
+						  pdata->rx_q_count);
 
-	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+	for (i = 0; i < pdata->rx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RQS, fifo_size);
 
 	netdev_notice(pdata->netdev, "%d Rx queues, %d byte fifo per queue\n",
-		      pdata->hw_feat.rx_q_cnt, ((fifo_size + 1) * 256));
+		      pdata->rx_q_count, ((fifo_size + 1) * 256));
 }
 
 static void xgbe_config_rx_queue_mapping(struct xgbe_prv_data *pdata)
 {
 	unsigned int i, reg, reg_val;
-	unsigned int q_count = pdata->hw_feat.rx_q_cnt;
+	unsigned int q_count = pdata->rx_q_count;
 
 	/* Select dynamic mapping of MTL Rx queue to DMA Rx channel */
 	reg = MTL_RQDCM0R;
@@ -1749,7 +1749,7 @@ static void xgbe_config_flow_control_threshold(struct xgbe_prv_data *pdata)
 {
 	unsigned int i;
 
-	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++) {
+	for (i = 0; i < pdata->rx_q_count; i++) {
 		/* Activate flow control when less than 4k left in fifo */
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RFA, 2);
 
@@ -2141,7 +2141,7 @@ static void xgbe_enable_tx(struct xgbe_prv_data *pdata)
 	}
 
 	/* Enable each Tx queue */
-	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TXQEN,
 				       MTL_Q_ENABLED);
 
@@ -2158,7 +2158,7 @@ static void xgbe_disable_tx(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, TE, 0);
 
 	/* Disable each Tx queue */
-	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TXQEN, 0);
 
 	/* Disable each Tx DMA channel */
@@ -2187,7 +2187,7 @@ static void xgbe_enable_rx(struct xgbe_prv_data *pdata)
 
 	/* Enable each Rx queue */
 	reg_val = 0;
-	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+	for (i = 0; i < pdata->rx_q_count; i++)
 		reg_val |= (0x02 << (i << 1));
 	XGMAC_IOWRITE(pdata, MAC_RQC0R, reg_val);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index ca6a6af..04e6c72 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -355,9 +355,16 @@ static int xgbe_probe(struct platform_device *pdev)
 	/* Set default configuration data */
 	xgbe_default_config(pdata);
 
-	/* Calculate the number of Tx and Rx rings to be created */
+	/* Calculate the number of Tx and Rx rings to be created
+	 *  -Tx (DMA) Channels map 1-to-1 to Tx Queues so set
+	 *   the number of Tx queues to the number of Tx channels
+	 *   enabled
+	 *  -Rx (DMA) Channels do not map 1-to-1 so use the actual
+	 *   number of Rx queues
+	 */
 	pdata->tx_ring_count = min_t(unsigned int, num_online_cpus(),
 				     pdata->hw_feat.tx_ch_cnt);
+	pdata->tx_q_count = pdata->tx_ring_count;
 	ret = netif_set_real_num_tx_queues(netdev, pdata->tx_ring_count);
 	if (ret) {
 		dev_err(dev, "error setting real tx queue count\n");
@@ -367,6 +374,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	pdata->rx_ring_count = min_t(unsigned int,
 				     netif_get_num_default_rss_queues(),
 				     pdata->hw_feat.rx_ch_cnt);
+	pdata->rx_q_count = pdata->hw_feat.rx_q_cnt;
 	ret = netif_set_real_num_rx_queues(netdev, pdata->rx_ring_count);
 	if (ret) {
 		dev_err(dev, "error setting real rx queue count\n");
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 8b6ad3e..f011d88 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -590,6 +590,9 @@ struct xgbe_prv_data {
 	unsigned int rx_ring_count;
 	unsigned int rx_desc_count;
 
+	unsigned int tx_q_count;
+	unsigned int rx_q_count;
+
 	/* Tx/Rx common settings */
 	unsigned int pblx8;
 
