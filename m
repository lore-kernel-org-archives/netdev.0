From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2: Read PCI function number from
 internal register
Date: Sat, 16 Jun 2012 18:45:43 -0700
Message-ID: <1339897544-20254-3-git-send-email-mchan@broadcom.com>
References: <1339897544-20254-1-git-send-email-mchan@broadcom.com>
 <1339897544-20254-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4109 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756157Ab2FQBl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jun 2012 21:41:58 -0400
In-Reply-To: <1339897544-20254-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so that it will work on any hypervisor.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    7 +++++--
 drivers/net/ethernet/broadcom/bnx2.h |    2 ++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index da88de7..c6d3943 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7903,7 +7903,7 @@ bnx2_get_5709_media(struct bnx2 *bp)
 	else
 		strap = (val & BNX2_MISC_DUAL_MEDIA_CTRL_PHY_CTRL_STRAP) >> 8;
 
-	if (PCI_FUNC(bp->pdev->devfn) == 0) {
+	if (bp->func == 0) {
 		switch (strap) {
 		case 0x4:
 		case 0x5:
@@ -8202,9 +8202,12 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	reg = bnx2_reg_rd_ind(bp, BNX2_SHM_HDR_SIGNATURE);
 
+	if (bnx2_reg_rd_ind(bp, BNX2_MCP_TOE_ID) & BNX2_MCP_TOE_ID_FUNCTION_ID)
+		bp->func = 1;
+
 	if ((reg & BNX2_SHM_HDR_SIGNATURE_SIG_MASK) ==
 	    BNX2_SHM_HDR_SIGNATURE_SIG) {
-		u32 off = PCI_FUNC(pdev->devfn) << 2;
+		u32 off = bp->func << 2;
 
 		bp->shmem_base = bnx2_reg_rd_ind(bp, BNX2_SHM_HDR_ADDR_0 + off);
 	} else
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index f9cb639..af6451d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6971,6 +6971,8 @@ struct bnx2 {
 	struct bnx2_irq		irq_tbl[BNX2_MAX_MSIX_VEC];
 	int			irq_nvecs;
 
+	u8			func;
+
 	u8			num_tx_rings;
 	u8			num_rx_rings;
 
-- 
1.7.1
