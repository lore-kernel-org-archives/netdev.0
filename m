From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net] bnx2: Fix shutdown sequence
Date: Sun, 9 Mar 2014 15:45:32 -0800
Message-ID: <1394408732-1269-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:26593 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbaCIW0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 18:26:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pci shutdown handler added in:

    bnx2: Add pci shutdown handler
    commit 25bfb1dd4ba3b2d9a49ce9d9b0cd7be1840e15ed

created a shutdown down sequence without chip reset if the device was
never brought up.  This can cause the firmware to shutdown the PHY
prematurely and cause MMIO read cycles to be unresponsive.  On some
systems, it may generate NMI in the bnx2's pci shutdown handler.

The fix is to tell the firmware not to shutdown the PHY if there was
no prior chip reset.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
Please consider adding this to -stable.

 drivers/net/ethernet/broadcom/bnx2.c |   37 ++++++++++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/bnx2.h |    5 ++++
 2 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index cda25ac..6c9e1c9 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2507,6 +2507,7 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int ack, int silent)
 
 	bp->fw_wr_seq++;
 	msg_data |= bp->fw_wr_seq;
+	bp->fw_last_msg = msg_data;
 
 	bnx2_shmem_wr(bp, BNX2_DRV_MB, msg_data);
 
@@ -4000,8 +4001,23 @@ bnx2_setup_wol(struct bnx2 *bp)
 			wol_msg = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
 	}
 
-	if (!(bp->flags & BNX2_FLAG_NO_WOL))
-		bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT3 | wol_msg, 1, 0);
+	if (!(bp->flags & BNX2_FLAG_NO_WOL)) {
+		u32 val;
+
+		wol_msg |= BNX2_DRV_MSG_DATA_WAIT3;
+		if (bp->fw_last_msg || BNX2_CHIP(bp) != BNX2_CHIP_5709) {
+			bnx2_fw_sync(bp, wol_msg, 1, 0);
+			return;
+		}
+		/* Tell firmware not to power down the PHY yet, otherwise
+		 * the chip will take a long time to respond to MMIO reads.
+		 */
+		val = bnx2_shmem_rd(bp, BNX2_PORT_FEATURE);
+		bnx2_shmem_wr(bp, BNX2_PORT_FEATURE,
+			      val | BNX2_PORT_FEATURE_ASF_ENABLED);
+		bnx2_fw_sync(bp, wol_msg, 1, 0);
+		bnx2_shmem_wr(bp, BNX2_PORT_FEATURE, val);
+	}
 
 }
 
@@ -4033,9 +4049,22 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 
 			if (bp->wol)
 				pci_set_power_state(bp->pdev, PCI_D3hot);
-		} else {
-			pci_set_power_state(bp->pdev, PCI_D3hot);
+			break;
+
+		}
+		if (!bp->fw_last_msg && BNX2_CHIP(bp) == BNX2_CHIP_5709) {
+			u32 val;
+
+			/* Tell firmware not to power down the PHY yet,
+			 * otherwise the other port may not respond to
+			 * MMIO reads.
+			 */
+			val = bnx2_shmem_rd(bp, BNX2_BC_STATE_CONDITION);
+			val &= ~BNX2_CONDITION_PM_STATE_MASK;
+			val |= BNX2_CONDITION_PM_STATE_UNPREP;
+			bnx2_shmem_wr(bp, BNX2_BC_STATE_CONDITION, val);
 		}
+		pci_set_power_state(bp->pdev, PCI_D3hot);
 
 		/* No more memory access after this point until
 		 * device is brought back to D0.
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index f1cf2c4..e341bc3 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6900,6 +6900,7 @@ struct bnx2 {
 
 	u16			fw_wr_seq;
 	u16			fw_drv_pulse_wr_seq;
+	u32			fw_last_msg;
 
 	int			rx_max_ring;
 	int			rx_ring_size;
@@ -7406,6 +7407,10 @@ struct bnx2_rv2p_fw_file {
 #define BNX2_CONDITION_MFW_RUN_NCSI		 0x00006000
 #define BNX2_CONDITION_MFW_RUN_NONE		 0x0000e000
 #define BNX2_CONDITION_MFW_RUN_MASK		 0x0000e000
+#define BNX2_CONDITION_PM_STATE_MASK		 0x00030000
+#define BNX2_CONDITION_PM_STATE_FULL		 0x00030000
+#define BNX2_CONDITION_PM_STATE_PREP		 0x00020000
+#define BNX2_CONDITION_PM_STATE_UNPREP		 0x00010000
 
 #define BNX2_BC_STATE_DEBUG_CMD			0x1dc
 #define BNX2_BC_STATE_BC_DBG_CMD_SIGNATURE	 0x42440000
-- 
1.7.1
