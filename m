From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2x: Wait for MCP validity during AER
Date: Wed, 22 May 2013 15:22:38 +0300
Message-ID: <1369225359-5578-4-git-send-email-yuvalmin@broadcom.com>
References: <1369225359-5578-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4377 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456Ab3EVMUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 08:20:46 -0400
In-Reply-To: <1369225359-5578-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During PCIe advanced error recovery, the secondary bus reset will cause FW
to reset; This will cause the shared memory between it and the driver to be
invalidated.

During the driver's recovery flow, the driver should not make any assumption
on the validity of that memory and instead re-initialize it.

This also removes a redundant re-initialization of a previously
initialized mutex.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 649880d..7ed9cdf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12760,19 +12760,6 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	return 0;
 }
 
-static void bnx2x_eeh_recover(struct bnx2x *bp)
-{
-	u32 val;
-
-	mutex_init(&bp->port.phy_mutex);
-
-
-	val = SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
-	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		BNX2X_ERR("BAD MCP validity signature\n");
-}
-
 /**
  * bnx2x_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
@@ -12841,6 +12828,10 @@ static pci_ers_result_t bnx2x_io_slot_reset(struct pci_dev *pdev)
 
 	if (netif_running(dev)) {
 		BNX2X_ERR("IO slot reset --> driver unload\n");
+
+		/* MCP should have been reset; Need to wait for validity */
+		bnx2x_init_shmem(bp);
+
 		if (IS_PF(bp) && SHMEM2_HAS(bp, drv_capabilities_flag)) {
 			u32 v;
 
@@ -12899,8 +12890,6 @@ static void bnx2x_io_resume(struct pci_dev *pdev)
 
 	rtnl_lock();
 
-	bnx2x_eeh_recover(bp);
-
 	bp->fw_seq = SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
 							DRV_MSG_SEQ_NUMBER_MASK;
 
-- 
1.8.1.227.g44fe835
