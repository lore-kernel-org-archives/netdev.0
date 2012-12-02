From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 11/13] bnx2x: prevent DCB if disabled in nvram
Date: Sun, 2 Dec 2012 16:05:55 +0200
Message-ID: <1354457157-4730-12-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1627 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab2LBOFY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:24 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c  |    5 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   11 +++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index c0d9b69..c8c0340 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -1904,6 +1904,11 @@ static u8 bnx2x_dcbnl_set_state(struct net_device *netdev, u8 state)
 	struct bnx2x *bp = netdev_priv(netdev);
 	DP(BNX2X_MSG_DCB, "state = %s\n", state ? "on" : "off");
 
+	if (state && ((bp->dcbx_enabled == BNX2X_DCBX_ENABLED_OFF) ||
+		      (bp->dcbx_enabled == BNX2X_DCBX_ENABLED_INVALID))) {
+		DP(BNX2X_MSG_DCB, "Can not set dcbx to enabled while it is disabled in nvm\n");
+		return 1;
+	}
 	bnx2x_dcbx_set_state(bp, (state ? true : false), bp->dcbx_enabled);
 	return 0;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d76ca90..ab65f34 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11120,8 +11120,15 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->timer.data = (unsigned long) bp;
 	bp->timer.function = bnx2x_timer;
 
-	bnx2x_dcbx_set_state(bp, true, BNX2X_DCBX_ENABLED_ON_NEG_ON);
-	bnx2x_dcbx_init_params(bp);
+	if (SHMEM2_HAS(bp, dcbx_lldp_params_offset) &&
+	    SHMEM2_HAS(bp, dcbx_lldp_dcbx_stat_offset) &&
+	    SHMEM2_RD(bp, dcbx_lldp_params_offset) &&
+	    SHMEM2_RD(bp, dcbx_lldp_dcbx_stat_offset)) {
+		bnx2x_dcbx_set_state(bp, true, BNX2X_DCBX_ENABLED_ON_NEG_ON);
+		bnx2x_dcbx_init_params(bp);
+	} else {
+		bnx2x_dcbx_set_state(bp, false, BNX2X_DCBX_ENABLED_OFF);
+	}
 
 	if (CHIP_IS_E1x(bp))
 		bp->cnic_base_cl_id = FP_SB_MAX_E1x;
-- 
1.7.1
