From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 8/9] amd-xgbe: Check Rx queue fifos before
 stopping Rx DMA
Date: Wed, 17 Feb 2016 11:49:16 -0600
Message-ID: <20160217174916.26246.99839.stgit@tlendack-t1.amdoffice.net>
References: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0090.outbound.protection.outlook.com ([207.46.100.90]:3392
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161429AbcBQRtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:49:24 -0500
In-Reply-To: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check to be sure that the Rx queue fifos are empty before stopping the
Rx DMA channels.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   10 ++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |   30 +++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index b6fa891..bbef959 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -6,7 +6,7 @@
  *
  * License 1: GPLv2
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  *
  * This file is free software; you may copy, redistribute and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,7 +56,7 @@
  *
  * License 2: Modified BSD
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -768,12 +768,16 @@
 #define MTL_Q_TQDR			0x08
 #define MTL_Q_RQOMR			0x40
 #define MTL_Q_RQMPOCR			0x44
-#define MTL_Q_RQDR			0x4c
+#define MTL_Q_RQDR			0x48
 #define MTL_Q_RQFCR			0x50
 #define MTL_Q_IER			0x70
 #define MTL_Q_ISR			0x74
 
 /* MTL queue register entry bit positions and sizes */
+#define MTL_Q_RQDR_PRXQ_INDEX		16
+#define MTL_Q_RQDR_PRXQ_WIDTH		14
+#define MTL_Q_RQDR_RXQSTS_INDEX		4
+#define MTL_Q_RQDR_RXQSTS_WIDTH		2
 #define MTL_Q_RQFCR_RFA_INDEX		1
 #define MTL_Q_RQFCR_RFA_WIDTH		6
 #define MTL_Q_RQFCR_RFD_INDEX		17
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 43273c98..b48c6ec 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -2656,6 +2656,32 @@ static void xgbe_disable_tx(struct xgbe_prv_data *pdata)
 	}
 }
 
+static void xgbe_prepare_rx_stop(struct xgbe_prv_data *pdata,
+				 unsigned int queue)
+{
+	unsigned int rx_status;
+	unsigned long rx_timeout;
+
+	/* The Rx engine cannot be stopped if it is actively processing
+	 * packets. Wait for the Rx queue to empty the Rx fifo.  Don't
+	 * wait forever though...
+	 */
+	rx_timeout = jiffies + (XGBE_DMA_STOP_TIMEOUT * HZ);
+	while (time_before(jiffies, rx_timeout)) {
+		rx_status = XGMAC_MTL_IOREAD(pdata, queue, MTL_Q_RQDR);
+		if ((XGMAC_GET_BITS(rx_status, MTL_Q_RQDR, PRXQ) == 0) &&
+		    (XGMAC_GET_BITS(rx_status, MTL_Q_RQDR, RXQSTS) == 0))
+			break;
+
+		usleep_range(500, 1000);
+	}
+
+	if (!time_before(jiffies, rx_timeout))
+		netdev_info(pdata->netdev,
+			    "timed out waiting for Rx queue %u to empty\n",
+			    queue);
+}
+
 static void xgbe_enable_rx(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_channel *channel;
@@ -2694,6 +2720,10 @@ static void xgbe_disable_rx(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, ACS, 0);
 	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, RE, 0);
 
+	/* Prepare for Rx DMA channel stop */
+	for (i = 0; i < pdata->rx_q_count; i++)
+		xgbe_prepare_rx_stop(pdata, i);
+
 	/* Disable each Rx queue */
 	XGMAC_IOWRITE(pdata, MAC_RQC0R, 0);
 
