From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/1] bnx2x: fix ring size for 10G functions
Date: Wed, 3 Oct 2012 16:22:59 +0200
Message-ID: <1349274179-18827-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2759 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756260Ab2JCOvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 10:51:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d760fc37b0f74502b3f748951f22c6683b079a8e caused 
1G functions to allocate rx rings which were 1/10 of the 
size of 10G functions' rx rings.

However, it also caused 10G functions on 5771x boards to 
allocate small rings, which limits their possible (default) 
rx throughput. This patch causes all 10G functions to use 
rings of intended length by default.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

This is a bug fix which corrects the default rx ring size of
10G functions on 5771x boards.

Please consider applying it to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 30f04a3..2422099 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3523,15 +3523,18 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	} else
 #endif
 	if (!bp->rx_ring_size) {
-		u32 cfg = SHMEM_RD(bp,
-			     dev_info.port_hw_config[BP_PORT(bp)].default_cfg);
-
 		rx_ring_size = MAX_RX_AVAIL/BNX2X_NUM_RX_QUEUES(bp);
 
-		/* Dercease ring size for 1G functions */
-		if ((cfg & PORT_HW_CFG_NET_SERDES_IF_MASK) ==
-		    PORT_HW_CFG_NET_SERDES_IF_SGMII)
-			rx_ring_size /= 10;
+		if (CHIP_IS_E3(bp)) {
+			u32 cfg = SHMEM_RD(bp,
+					   dev_info.port_hw_config[BP_PORT(bp)].
+					   default_cfg);
+
+			/* Decrease ring size for 1G functions */
+			if ((cfg & PORT_HW_CFG_NET_SERDES_IF_MASK) ==
+			    PORT_HW_CFG_NET_SERDES_IF_SGMII)
+				rx_ring_size /= 10;
+		}
 
 		/* allocate at least number of buffers required by FW */
 		rx_ring_size = max_t(int, bp->disable_tpa ? MIN_RX_SIZE_NONTPA :
-- 
1.7.9.rc2
