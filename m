From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/9] bnx2x: handle spurious interrupts
Date: Mon, 18 Feb 2013 10:16:32 +0200
Message-ID: <1361175398-12888-4-git-send-email-yuvalmin@broadcom.com>
References: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4081 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757407Ab3BRJVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 04:21:20 -0500
In-Reply-To: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In scenarios in which a previous driver was removed without proper cleanup
(e.g., kdump), it is possible for the chip to generate an interrupt without
any apparent reason.
This would cause improper behaviour at best, possibly resulting in NULL
pointer dereferences as interrupts might be sent to an ISR accessing
uninitialized structures and memories.

This causes the driver to ignore any interrupt which arrives in an
inappropriate time, i.e., when the driver has not yet properly configured
its interrupt routines.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   11 +++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c |    3 ++-
 4 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e4605a9..3e26eb5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1379,6 +1379,7 @@ struct bnx2x {
 #define USING_SINGLE_MSIX_FLAG		(1 << 20)
 #define BC_SUPPORTS_DCBX_MSG_NON_PMF	(1 << 21)
 #define IS_VF_FLAG			(1 << 22)
+#define INTERRUPTS_ENABLED_FLAG	(1 << 23)
 
 #define BP_NOMCP(bp)			((bp)->flags & NO_MCP_FLAG)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ecac04a3..525c2b5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1037,6 +1037,17 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	DP(NETIF_MSG_INTR,
 	   "got an MSI-X interrupt on IDX:SB [fp %d fw_sd %d igusb %d]\n",
 	   fp->index, fp->fw_sb_id, fp->igu_sb_id);
+
+	/* It's possible for a spurious interrupt to be received, if the
+	 * driver was loaded above a previous configured function (e.g., kdump).
+	 * We simply ignore such interrupts.
+	 */
+	if (unlikely(!(bp->flags & INTERRUPTS_ENABLED_FLAG))) {
+		WARN_ONCE(1, "%s: Got Spurious interrupts",
+			  bp->dev ? bp->dev->name : "?");
+		return IRQ_HANDLED;
+	}
+
 	bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c4daee1..1776b8b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -868,6 +868,7 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 		bnx2x_hc_int_disable(bp);
 	else
 		bnx2x_igu_int_disable(bp);
+	bp->flags &= ~INTERRUPTS_ENABLED_FLAG;
 }
 
 void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
@@ -1607,6 +1608,8 @@ static void bnx2x_igu_int_enable(struct bnx2x *bp)
 
 void bnx2x_int_enable(struct bnx2x *bp)
 {
+	bp->flags |= INTERRUPTS_ENABLED_FLAG;
+
 	if (bp->common.int_block == INT_BLOCK_HC)
 		bnx2x_hc_int_enable(bp);
 	else
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 3624612..df9209e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -268,7 +268,8 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 	bp->mf_mode = 0;
 	bp->common.flash_size = 0;
 	bp->flags |=
-		NO_WOL_FLAG | NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG | NO_FCOE_FLAG;
+		NO_WOL_FLAG | NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG | NO_FCOE_FLAG |
+		INTERRUPTS_ENABLED_FLAG;
 	bp->igu_sb_cnt = 1;
 	bp->igu_base_sb = bp->acquire_resp.resc.hw_sbs[0].hw_sb_id;
 	strlcpy(bp->fw_ver, bp->acquire_resp.pfdev_info.fw_ver,
-- 
1.7.9.GIT
