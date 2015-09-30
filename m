From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 5/8] amd-xgbe: Simplify calculation and setting
 of queue fifos
Date: Wed, 30 Sep 2015 08:53:03 -0500
Message-ID: <20150930135303.12605.16702.stgit@tlendack-t1.amdoffice.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0094.outbound.protection.outlook.com ([157.56.111.94]:41101
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751765AbbI3OHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:07:30 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The calculation of the Tx and Rx fifo sizes can be calculated rather
than hardcoded in a switch statement. Additionally, the per-queue fifo
sizes can be calculated rather than hardcoded using if/else if statements
that can possibly underutilize the available fifo area.

Change the code to calculate the fifo sizes and the per-queue fifo sizes
to simplify the code and make best use of the available fifo.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   81 +++++-------------------------
 drivers/net/ethernet/amd/xgbe/xgbe.h     |   16 ------
 2 files changed, 14 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 553e251..4551224 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1940,84 +1940,31 @@ static void xgbe_config_mtl_mode(struct xgbe_prv_data *pdata)
 static unsigned int xgbe_calculate_per_queue_fifo(unsigned int fifo_size,
 						  unsigned int queue_count)
 {
-	unsigned int q_fifo_size = 0;
-	enum xgbe_mtl_fifo_size p_fifo = XGMAC_MTL_FIFO_SIZE_256;
+	unsigned int q_fifo_size;
+	unsigned int p_fifo;
 
-	/* Calculate Tx/Rx fifo share per queue */
-	switch (fifo_size) {
-	case 0:
-		q_fifo_size = XGBE_FIFO_SIZE_B(128);
-		break;
-	case 1:
-		q_fifo_size = XGBE_FIFO_SIZE_B(256);
-		break;
-	case 2:
-		q_fifo_size = XGBE_FIFO_SIZE_B(512);
-		break;
-	case 3:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(1);
-		break;
-	case 4:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(2);
-		break;
-	case 5:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(4);
-		break;
-	case 6:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(8);
-		break;
-	case 7:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(16);
-		break;
-	case 8:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(32);
-		break;
-	case 9:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(64);
-		break;
-	case 10:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(128);
-		break;
-	case 11:
-		q_fifo_size = XGBE_FIFO_SIZE_KB(256);
-		break;
-	}
+	/* Calculate the configured fifo size */
+	q_fifo_size = 1 << (fifo_size + 7);
 
-	/* The configured value is not the actual amount of fifo RAM */
+	/* The configured value may not be the actual amount of fifo RAM */
 	q_fifo_size = min_t(unsigned int, XGBE_FIFO_MAX, q_fifo_size);
 
 	q_fifo_size = q_fifo_size / queue_count;
 
-	/* Set the queue fifo size programmable value */
-	if (q_fifo_size >= XGBE_FIFO_SIZE_KB(256))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_256K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(128))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_128K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(64))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_64K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(32))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_32K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(16))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_16K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(8))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_8K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(4))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_4K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(2))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_2K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(1))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_1K;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_B(512))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_512;
-	else if (q_fifo_size >= XGBE_FIFO_SIZE_B(256))
-		p_fifo = XGMAC_MTL_FIFO_SIZE_256;
+	/* Each increment in the queue fifo size represents 256 bytes of
+	 * fifo, with 0 representing 256 bytes. Distribute the fifo equally
+	 * between the queues.
+	 */
+	p_fifo = q_fifo_size / 256;
+	if (p_fifo)
+		p_fifo--;
 
 	return p_fifo;
 }
 
 static void xgbe_config_tx_fifo_size(struct xgbe_prv_data *pdata)
 {
-	enum xgbe_mtl_fifo_size fifo_size;
+	unsigned int fifo_size;
 	unsigned int i;
 
 	fifo_size = xgbe_calculate_per_queue_fifo(pdata->hw_feat.tx_fifo_size,
@@ -2033,7 +1980,7 @@ static void xgbe_config_tx_fifo_size(struct xgbe_prv_data *pdata)
 
 static void xgbe_config_rx_fifo_size(struct xgbe_prv_data *pdata)
 {
-	enum xgbe_mtl_fifo_size fifo_size;
+	unsigned int fifo_size;
 	unsigned int i;
 
 	fifo_size = xgbe_calculate_per_queue_fifo(pdata->hw_feat.rx_fifo_size,
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 8c9d01e..5f9a1ab 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -209,8 +209,6 @@
 #define XGMAC_IOCTL_CONTEXT	2
 
 #define XGBE_FIFO_MAX		81920
-#define XGBE_FIFO_SIZE_B(x)	(x)
-#define XGBE_FIFO_SIZE_KB(x)	(x * 1024)
 
 #define XGBE_TC_MIN_QUANTUM	10
 
@@ -483,20 +481,6 @@ enum xgbe_int_state {
 	XGMAC_INT_STATE_RESTORE,
 };
 
-enum xgbe_mtl_fifo_size {
-	XGMAC_MTL_FIFO_SIZE_256  = 0x00,
-	XGMAC_MTL_FIFO_SIZE_512  = 0x01,
-	XGMAC_MTL_FIFO_SIZE_1K   = 0x03,
-	XGMAC_MTL_FIFO_SIZE_2K   = 0x07,
-	XGMAC_MTL_FIFO_SIZE_4K   = 0x0f,
-	XGMAC_MTL_FIFO_SIZE_8K   = 0x1f,
-	XGMAC_MTL_FIFO_SIZE_16K  = 0x3f,
-	XGMAC_MTL_FIFO_SIZE_32K  = 0x7f,
-	XGMAC_MTL_FIFO_SIZE_64K  = 0xff,
-	XGMAC_MTL_FIFO_SIZE_128K = 0x1ff,
-	XGMAC_MTL_FIFO_SIZE_256K = 0x3ff,
-};
-
 enum xgbe_speed {
 	XGBE_SPEED_1000 = 0,
 	XGBE_SPEED_2500,
