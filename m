From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 3/8] bnx2x: fix rx ring size report
Date: Tue, 30 Aug 2011 13:08:41 +0300
Message-ID: <1314698926-24525-4-git-send-email-dmitry@broadcom.com>
References: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3491 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884Ab1H3KIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 06:08:47 -0400
In-Reply-To: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

Store the size in bp, read from bp when queried.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c     |   17 +++++++++++------
 drivers/net/bnx2x/bnx2x_ethtool.c |    5 +----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 2a33d24..c4cbf97 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -3091,15 +3091,20 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	struct bnx2x_fastpath *fp = &bp->fp[index];
 	int ring_size = 0;
 	u8 cos;
+	int rx_ring_size = 0;
 
 	/* if rx_ring_size specified - use it */
-	int rx_ring_size = bp->rx_ring_size ? bp->rx_ring_size :
-			   MAX_RX_AVAIL/BNX2X_NUM_RX_QUEUES(bp);
+	if (!bp->rx_ring_size) {
 
-	/* allocate at least number of buffers required by FW */
-	rx_ring_size = max_t(int, bp->disable_tpa ? MIN_RX_SIZE_NONTPA :
-						    MIN_RX_SIZE_TPA,
-				  rx_ring_size);
+		rx_ring_size = MAX_RX_AVAIL/BNX2X_NUM_RX_QUEUES(bp);
+
+		/* allocate at least number of buffers required by FW */
+		rx_ring_size = max_t(int, bp->disable_tpa ? MIN_RX_SIZE_NONTPA :
+				     MIN_RX_SIZE_TPA, rx_ring_size);
+
+		bp->rx_ring_size = rx_ring_size;
+	} else
+		rx_ring_size = bp->rx_ring_size;
 
 	/* Common */
 	sb = &bnx2x_fp(bp, index, status_blk);
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 2218630..0ceb6c7 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1310,10 +1310,7 @@ static void bnx2x_get_ringparam(struct net_device *dev,
 	if (bp->rx_ring_size)
 		ering->rx_pending = bp->rx_ring_size;
 	else
-		if (bp->state == BNX2X_STATE_OPEN && bp->num_queues)
-			ering->rx_pending = MAX_RX_AVAIL/bp->num_queues;
-		else
-			ering->rx_pending = MAX_RX_AVAIL;
+		ering->rx_pending = MAX_RX_AVAIL;
 
 	ering->rx_mini_pending = 0;
 	ering->rx_jumbo_pending = 0;
-- 
1.7.2.2
