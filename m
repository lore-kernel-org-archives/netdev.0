From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/8] amd-xgbe: Tx engine must not be active
 before stopping it
Date: Thu, 20 Nov 2014 11:03:32 -0600
Message-ID: <20141120170332.15397.30576.stgit@tlendack-t1.amdoffice.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0113.outbound.protection.outlook.com ([157.56.111.113]:64864
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932081AbaKTRDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:03:38 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the Tx engine is told to stop while it is actively processing Tx
descriptors it is possible that the Tx descriptor(s) will not be closed
out properly. When the Tx engine is restarted this could result in the
driver being stuck on the improperly closed descriptor.

Update the driver to wait for the Tx engine to be in a stopped or
suspended state before issuing the stop command.

This has not been an issue to date, but it's a good safe-guard to have.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   21 ++++++----
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |   59 +++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h        |    1 
 3 files changed, 74 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 2fe8fc7..75b08c6 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -125,9 +125,6 @@
 #define DMA_AXIAWCR			0x3018
 #define DMA_DSR0			0x3020
 #define DMA_DSR1			0x3024
-#define DMA_DSR2			0x3028
-#define DMA_DSR3			0x302c
-#define DMA_DSR4			0x3030
 
 /* DMA register entry bit positions and sizes */
 #define DMA_AXIARCR_DRC_INDEX		0
@@ -158,10 +155,6 @@
 #define DMA_AXIAWCR_TDC_WIDTH		4
 #define DMA_AXIAWCR_TDD_INDEX		28
 #define DMA_AXIAWCR_TDD_WIDTH		2
-#define DMA_DSR0_RPS_INDEX		8
-#define DMA_DSR0_RPS_WIDTH		4
-#define DMA_DSR0_TPS_INDEX		12
-#define DMA_DSR0_TPS_WIDTH		4
 #define DMA_ISR_MACIS_INDEX		17
 #define DMA_ISR_MACIS_WIDTH		1
 #define DMA_ISR_MTLIS_INDEX		16
@@ -175,6 +168,20 @@
 #define DMA_SBMR_UNDEF_INDEX		0
 #define DMA_SBMR_UNDEF_WIDTH		1
 
+/* DMA register values */
+#define DMA_DSR_RPS_WIDTH		4
+#define DMA_DSR_TPS_WIDTH		4
+#define DMA_DSR_Q_WIDTH			(DMA_DSR_RPS_WIDTH + DMA_DSR_TPS_WIDTH)
+#define DMA_DSR0_RPS_START		8
+#define DMA_DSR0_TPS_START		12
+#define DMA_DSRX_FIRST_QUEUE		3
+#define DMA_DSRX_INC			4
+#define DMA_DSRX_QPR			4
+#define DMA_DSRX_RPS_START		0
+#define DMA_DSRX_TPS_START		4
+#define DMA_TPS_STOPPED			0x00
+#define DMA_TPS_SUSPENDED		0x06
+
 /* DMA channel register offsets
  *   Multiple channels can be active.  The first channel has registers
  *   that begin at 0x3100.  Each subsequent channel has registers that
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 9b1d9fa..dcd0347 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -2453,6 +2453,47 @@ static void xgbe_config_mmc(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE_BITS(pdata, MMC_CR, CR, 1);
 }
 
+static void xgbe_prepare_tx_stop(struct xgbe_prv_data *pdata,
+				 struct xgbe_channel *channel)
+{
+	unsigned int tx_dsr, tx_pos, tx_qidx;
+	unsigned int tx_status;
+	unsigned long tx_timeout;
+
+	/* Calculate the status register to read and the position within */
+	if (channel->queue_index < DMA_DSRX_FIRST_QUEUE) {
+		tx_dsr = DMA_DSR0;
+		tx_pos = (channel->queue_index * DMA_DSR_Q_WIDTH) +
+			 DMA_DSR0_TPS_START;
+	} else {
+		tx_qidx = channel->queue_index - DMA_DSRX_FIRST_QUEUE;
+
+		tx_dsr = DMA_DSR1 + ((tx_qidx / DMA_DSRX_QPR) * DMA_DSRX_INC);
+		tx_pos = ((tx_qidx % DMA_DSRX_QPR) * DMA_DSR_Q_WIDTH) +
+			 DMA_DSRX_TPS_START;
+	}
+
+	/* The Tx engine cannot be stopped if it is actively processing
+	 * descriptors. Wait for the Tx engine to enter the stopped or
+	 * suspended state.  Don't wait forever though...
+	 */
+	tx_timeout = jiffies + (XGBE_DMA_STOP_TIMEOUT * HZ);
+	while (time_before(jiffies, tx_timeout)) {
+		tx_status = XGMAC_IOREAD(pdata, tx_dsr);
+		tx_status = GET_BITS(tx_status, tx_pos, DMA_DSR_TPS_WIDTH);
+		if ((tx_status == DMA_TPS_STOPPED) ||
+		    (tx_status == DMA_TPS_SUSPENDED))
+			break;
+
+		usleep_range(500, 1000);
+	}
+
+	if (!time_before(jiffies, tx_timeout))
+		netdev_info(pdata->netdev,
+			    "timed out waiting for Tx DMA channel %u to stop\n",
+			    channel->queue_index);
+}
+
 static void xgbe_enable_tx(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_channel *channel;
@@ -2481,6 +2522,15 @@ static void xgbe_disable_tx(struct xgbe_prv_data *pdata)
 	struct xgbe_channel *channel;
 	unsigned int i;
 
+	/* Prepare for Tx DMA channel stop */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		xgbe_prepare_tx_stop(pdata, channel);
+	}
+
 	/* Disable MAC Tx */
 	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, TE, 0);
 
@@ -2572,6 +2622,15 @@ static void xgbe_powerdown_tx(struct xgbe_prv_data *pdata)
 	struct xgbe_channel *channel;
 	unsigned int i;
 
+	/* Prepare for Tx DMA channel stop */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		xgbe_prepare_tx_stop(pdata, channel);
+	}
+
 	/* Disable MAC Tx */
 	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, TE, 0);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 901fb1f..46ce544 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -147,6 +147,7 @@
 
 #define XGBE_MAX_DMA_CHANNELS	16
 #define XGBE_MAX_QUEUES		16
+#define XGBE_DMA_STOP_TIMEOUT	5
 
 /* DMA cache settings - Outer sharable, write-back, write-allocate */
 #define XGBE_DMA_OS_AXDOMAIN	0x2
