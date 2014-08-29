From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 2/4] amd-xgbe: Reported fifo size from hardware is not
 correct
Date: Fri, 29 Aug 2014 13:16:56 -0500
Message-ID: <20140829181656.3257.6593.stgit@tlendack-t1.amdoffice.net>
References: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0203.outbound.protection.outlook.com ([207.46.163.203]:22362
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753363AbaH2SRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 14:17:14 -0400
In-Reply-To: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fifo size reported by the hardware is not correct. Add support
to limit the reported size to what is actually present.  Also, fix
the argument types used in the fifo size calculation function.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    8 ++++++--
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index e43747a..acde00c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1706,8 +1706,8 @@ static void xgbe_config_mtl_mode(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE_BITS(pdata, MTL_OMR, RAA, MTL_RAA_SP);
 }
 
-static unsigned int xgbe_calculate_per_queue_fifo(unsigned long fifo_size,
-						  unsigned char queue_count)
+static unsigned int xgbe_calculate_per_queue_fifo(unsigned int fifo_size,
+						  unsigned int queue_count)
 {
 	unsigned int q_fifo_size = 0;
 	enum xgbe_mtl_fifo_size p_fifo = XGMAC_MTL_FIFO_SIZE_256;
@@ -1751,6 +1751,10 @@ static unsigned int xgbe_calculate_per_queue_fifo(unsigned long fifo_size,
 		q_fifo_size = XGBE_FIFO_SIZE_KB(256);
 		break;
 	}
+
+	/* The configured value is not the actual amount of fifo RAM */
+	q_fifo_size = min_t(unsigned int, XGBE_FIFO_MAX, q_fifo_size);
+
 	q_fifo_size = q_fifo_size / queue_count;
 
 	/* Set the queue fifo size programmable value */
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 5af5c38..e9fe6e6 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -183,6 +183,7 @@
 #define XGMAC_DRIVER_CONTEXT	1
 #define XGMAC_IOCTL_CONTEXT	2
 
+#define XGBE_FIFO_MAX		81920
 #define XGBE_FIFO_SIZE_B(x)	(x)
 #define XGBE_FIFO_SIZE_KB(x)	(x * 1024)
 
