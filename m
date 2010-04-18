From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 7/13] bnx2x: Fixed MSI-X enabling flow
Date: Sun, 18 Apr 2010 17:49:31 +0300
Message-ID: <1271602171.27235.192.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>, dmitry@broadcom.com,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4411 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755128Ab0DROti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:49:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to enable less MSI-X vectors if initial request has failed.

Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   18 +++++++++++++-----
 drivers/net/bnx2x_main.c |   28 +++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index a9130f6..7abb2de 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -24,16 +24,25 @@
 #define BCM_VLAN			1
 #endif
 
+#define BNX2X_MULTI_QUEUE
+
+#define BNX2X_NEW_NAPI
+
+
+
 #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
 #define BCM_CNIC 1
 #include "cnic_if.h"
 #endif
 
-#define BNX2X_MULTI_QUEUE
-
-#define BNX2X_NEW_NAPI
-
 
+#ifdef BCM_CNIC
+#define BNX2X_MIN_MSIX_VEC_CNT 3
+#define BNX2X_MSIX_VEC_FP_START 2
+#else
+#define BNX2X_MIN_MSIX_VEC_CNT 2
+#define BNX2X_MSIX_VEC_FP_START 1
+#endif
 
 #include <linux/mdio.h>
 #include "bnx2x_reg.h"
@@ -859,7 +868,6 @@ struct bnx2x {
 #endif
 #define INT_MODE_INTx			1
 #define INT_MODE_MSI			2
-#define INT_MODE_MSIX			3
 
 	int			tx_ring_size;
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 25a8bbf..484ff2b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7430,7 +7430,31 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 
 	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
 			     BNX2X_NUM_QUEUES(bp) + offset);
-	if (rc) {
+
+	/*
+	 * reconfigure number of tx/rx queues according to available
+	 * MSI-X vectors
+	 */
+	if (rc >= BNX2X_MIN_MSIX_VEC_CNT) {
+		/* vectors available for FP */
+		int fp_vec = rc - BNX2X_MSIX_VEC_FP_START;
+
+		DP(NETIF_MSG_IFUP,
+		   "Trying to use less MSI-X vectors: %d\n", rc);
+
+		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], rc);
+
+		if (rc) {
+			DP(NETIF_MSG_IFUP,
+			   "MSI-X is not attainable  rc %d\n", rc);
+			return rc;
+		}
+
+		bp->num_queues = min(bp->num_queues, fp_vec);
+
+		DP(NETIF_MSG_IFUP, "New queue configuration set: %d\n",
+				  bp->num_queues);
+	} else if (rc) {
 		DP(NETIF_MSG_IFUP, "MSI-X is not attainable  rc %d\n", rc);
 		return rc;
 	}
@@ -7853,8 +7877,6 @@ static int bnx2x_set_num_queues(struct bnx2x *bp)
 		bp->num_queues = 1;
 		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
 		break;
-
-	case INT_MODE_MSIX:
 	default:
 		/* Set number of queues according to bp->multi_mode value */
 		bnx2x_set_num_queues_msix(bp);
-- 
1.6.3.3




