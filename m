From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH v2 net 3/3] bnxt_en: Setup uc_list mac filters after resetting the chip.
Date: Wed, 2 Dec 2015 01:54:08 -0500
Message-ID: <1449039248-8745-4-git-send-email-mchan@broadcom.com>
References: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:29885 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088AbbLBGyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 01:54:10 -0500
In-Reply-To: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call bnxt_cfg_rx_mode() in bnxt_init_chip() to setup uc_list and
mc_list mac address filters.  Before the patch, uc_list is not
setup again after chip reset (such as ethtool ring size change)
and macvlans don't work any more after that.

Modify bnxt_cfg_rx_mode() to return error codes appropriately so
that the init chip sequence can detect any failures.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f0481dc..bdf094f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3884,6 +3884,8 @@ static int bnxt_alloc_rfs_vnics(struct bnxt *bp)
 #endif
 }
 
+static int bnxt_cfg_rx_mode(struct bnxt *);
+
 static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 {
 	int rc = 0;
@@ -3950,11 +3952,9 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 		bp->vnic_info[0].rx_mask |=
 				CFA_L2_SET_RX_MASK_REQ_MASK_PROMISCUOUS;
 
-	rc = bnxt_hwrm_cfa_l2_set_rx_mask(bp, 0);
-	if (rc) {
-		netdev_err(bp->dev, "HWRM cfa l2 rx mask failure rc: %x\n", rc);
+	rc = bnxt_cfg_rx_mode(bp);
+	if (rc)
 		goto err_out;
-	}
 
 	rc = bnxt_hwrm_set_coal(bp);
 	if (rc)
@@ -4869,7 +4869,7 @@ static void bnxt_set_rx_mode(struct net_device *dev)
 	}
 }
 
-static void bnxt_cfg_rx_mode(struct bnxt *bp)
+static int bnxt_cfg_rx_mode(struct bnxt *bp)
 {
 	struct net_device *dev = bp->dev;
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[0];
@@ -4918,6 +4918,7 @@ static void bnxt_cfg_rx_mode(struct bnxt *bp)
 			netdev_err(bp->dev, "HWRM vnic filter failure rc: %x\n",
 				   rc);
 			vnic->uc_filter_count = i;
+			return rc;
 		}
 	}
 
@@ -4926,6 +4927,8 @@ skip_uc:
 	if (rc)
 		netdev_err(bp->dev, "HWRM cfa l2 rx mask failure rc: %x\n",
 			   rc);
+
+	return rc;
 }
 
 static netdev_features_t bnxt_fix_features(struct net_device *dev,
-- 
1.8.3.1
