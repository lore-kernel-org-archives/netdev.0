From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 6/6] bnx2: Read iSCSI config from shared memory
 during ->probe()
Date: Wed, 13 Jul 2011 20:24:22 -0700
Message-ID: <1310613862-27497-6-git-send-email-mchan@broadcom.com>
References: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
 <1310613862-27497-2-git-send-email-mchan@broadcom.com>
 <1310613862-27497-3-git-send-email-mchan@broadcom.com>
 <1310613862-27497-4-git-send-email-mchan@broadcom.com>
 <1310613862-27497-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2710 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880Ab1GNEQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 00:16:48 -0400
In-Reply-To: <1310613862-27497-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The scratchpad location that we were reading from has not been
initialized yet during ->probe(), so we were getting inaccurate
information.

Update version to 2.1.10.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |   13 +++++++++----
 drivers/net/bnx2.h |    7 +++++++
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d105f1f..4816d6a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.1.6"
-#define DRV_MODULE_RELDATE	"Mar 7, 2011"
+#define DRV_MODULE_VERSION	"2.1.10"
+#define DRV_MODULE_RELDATE	"July 12, 2011"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.1.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1a.fw"
@@ -385,6 +385,9 @@ static int bnx2_register_cnic(struct net_device *dev, struct cnic_ops *ops,
 	if (cp->drv_state & CNIC_DRV_STATE_REGD)
 		return -EBUSY;
 
+	if (!bnx2_reg_rd_ind(bp, BNX2_FW_MAX_ISCSI_CONN))
+		return -ENODEV;
+
 	bp->cnic_data = data;
 	rcu_assign_pointer(bp->cnic_ops, ops);
 
@@ -8215,8 +8218,10 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->timer.function = bnx2_timer;
 
 #ifdef BCM_CNIC
-	bp->cnic_eth_dev.max_iscsi_conn =
-		bnx2_reg_rd_ind(bp, BNX2_FW_MAX_ISCSI_CONN);
+	if (bnx2_shmem_rd(bp, BNX2_ISCSI_INITIATOR) & BNX2_ISCSI_INITIATOR_EN)
+		bp->cnic_eth_dev.max_iscsi_conn =
+			(bnx2_shmem_rd(bp, BNX2_ISCSI_MAX_CONN) &
+			 BNX2_ISCSI_MAX_CONN_MASK) >> BNX2_ISCSI_MAX_CONN_SHIFT;
 #endif
 	pci_save_state(pdev);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 0f0ad2b..fc50d42 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -7368,6 +7368,13 @@ struct bnx2_rv2p_fw_file {
 #define BNX2_RPHY_SERDES_LINK			0x374
 #define BNX2_RPHY_COPPER_LINK			0x378
 
+#define BNX2_ISCSI_INITIATOR			0x3dc
+#define BNX2_ISCSI_INITIATOR_EN			 0x00080000
+
+#define BNX2_ISCSI_MAX_CONN			0x3e4
+#define BNX2_ISCSI_MAX_CONN_MASK		 0xffff0000
+#define BNX2_ISCSI_MAX_CONN_SHIFT		 16
+
 #define HOST_VIEW_SHMEM_BASE			0x167c00
 
 #define DP_SHMEM_LINE(bp, offset)					\
-- 
1.6.4.GIT


