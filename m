From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/2] bnxt_en: Setup multicast properly after resetting device.
Date: Wed,  4 May 2016 16:56:44 -0400
Message-ID: <1462395404-21875-3-git-send-email-michael.chan@broadcom.com>
References: <1462395404-21875-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:42141 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbcEDU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:56:45 -0400
In-Reply-To: <1462395404-21875-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The multicast/all-multicast internal flags are not properly restored
after device reset.  This could lead to unreliable multicast operations
after an ethtool configuration change for example.

Call bnxt_mc_list_updated() and setup the vnic->mask in bnxt_init_chip()
to fix the issue.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f33ff20..9d4e8e1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4042,9 +4042,11 @@ static int bnxt_alloc_rfs_vnics(struct bnxt *bp)
 }
 
 static int bnxt_cfg_rx_mode(struct bnxt *);
+static bool bnxt_mc_list_updated(struct bnxt *, u32 *);
 
 static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 {
+	struct bnxt_vnic_info *vnic = &bp->vnic_info[0];
 	int rc = 0;
 
 	if (irq_re_init) {
@@ -4100,13 +4102,22 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 		netdev_err(bp->dev, "HWRM vnic filter failure rc: %x\n", rc);
 		goto err_out;
 	}
-	bp->vnic_info[0].uc_filter_count = 1;
+	vnic->uc_filter_count = 1;
 
-	bp->vnic_info[0].rx_mask = CFA_L2_SET_RX_MASK_REQ_MASK_BCAST;
+	vnic->rx_mask = CFA_L2_SET_RX_MASK_REQ_MASK_BCAST;
 
 	if ((bp->dev->flags & IFF_PROMISC) && BNXT_PF(bp))
-		bp->vnic_info[0].rx_mask |=
-				CFA_L2_SET_RX_MASK_REQ_MASK_PROMISCUOUS;
+		vnic->rx_mask |= CFA_L2_SET_RX_MASK_REQ_MASK_PROMISCUOUS;
+
+	if (bp->dev->flags & IFF_ALLMULTI) {
+		vnic->rx_mask |= CFA_L2_SET_RX_MASK_REQ_MASK_ALL_MCAST;
+		vnic->mc_list_count = 0;
+	} else {
+		u32 mask = 0;
+
+		bnxt_mc_list_updated(bp, &mask);
+		vnic->rx_mask |= mask;
+	}
 
 	rc = bnxt_cfg_rx_mode(bp);
 	if (rc)
-- 
1.8.3.1
