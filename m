From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v3 5/6] bnx2x: fix PTE write access error
Date: Thu, 18 Jul 2013 01:00:39 +0300
Message-ID: <1374098440-27877-6-git-send-email-dmitry@broadcom.com>
References: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1540 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756402Ab3GQWB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jul 2013 18:01:28 -0400
In-Reply-To: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowsky <barak@broadcom.com>

PTE write access error  might occur in MF_ALLOWED mode when IOMMU
is active. The patch adds rmmod HSI indicating to MFW to stop
running queries which might trigger this failure.

Signed-off-by: Barak Witkowsky <barak@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  | 5 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 9 +++++++++
 3 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 02f914d..906c7d9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1502,6 +1502,7 @@ struct bnx2x {
 #define BC_SUPPORTS_DCBX_MSG_NON_PMF	(1 << 21)
 #define IS_VF_FLAG			(1 << 22)
 #define INTERRUPTS_ENABLED_FLAG		(1 << 23)
+#define BC_SUPPORTS_RMMOD_CMD		(1 << 24)
 
 #define BP_NOMCP(bp)			((bp)->flags & NO_MCP_FLAG)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 5018e52..32767f6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1300,6 +1300,9 @@ struct drv_func_mb {
 
 	#define DRV_MSG_CODE_EEE_RESULTS_ACK            0xda000000
 
+	#define DRV_MSG_CODE_RMMOD                      0xdb000000
+	#define REQ_BC_VER_4_RMMOD_CMD                  0x0007080f
+
 	#define DRV_MSG_CODE_SET_MF_BW                  0xe0000000
 	#define REQ_BC_VER_4_SET_MF_BW                  0x00060202
 	#define DRV_MSG_CODE_SET_MF_BW_ACK              0xe1000000
@@ -1372,6 +1375,8 @@ struct drv_func_mb {
 
 	#define FW_MSG_CODE_EEE_RESULS_ACK              0xda100000
 
+	#define FW_MSG_CODE_RMMOD_ACK                   0xdb100000
+
 	#define FW_MSG_CODE_SET_MF_BW_SENT              0xe0000000
 	#define FW_MSG_CODE_SET_MF_BW_DONE              0xe1000000
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0f3de02..9394b7d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10368,6 +10368,10 @@ static void bnx2x_get_common_hwinfo(struct bnx2x *bp)
 
 	bp->flags |= (val >= REQ_BC_VER_4_DCBX_ADMIN_MSG_NON_PMF) ?
 			BC_SUPPORTS_DCBX_MSG_NON_PMF : 0;
+
+	bp->flags |= (val >= REQ_BC_VER_4_RMMOD_CMD) ?
+			BC_SUPPORTS_RMMOD_CMD : 0;
+
 	boot_mode = SHMEM_RD(bp,
 			dev_info.port_feature_config[BP_PORT(bp)].mba_config) &
 			PORT_FEATURE_MBA_BOOT_AGENT_TYPE_MASK;
@@ -12824,6 +12828,11 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 	bnx2x_dcbnl_update_applist(bp, true);
 #endif
 
+	if (IS_PF(bp) &&
+	    !BP_NOMCP(bp) &&
+	    (bp->flags & BC_SUPPORTS_RMMOD_CMD))
+		bnx2x_fw_command(bp, DRV_MSG_CODE_RMMOD, 0);
+
 	/* Close the interface - either directly or implicitly */
 	if (remove_netdev) {
 		unregister_netdev(dev);
-- 
1.8.1.4
