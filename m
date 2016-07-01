From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 09/11] bnxt_en: Allow promiscuous mode for VF if default VLAN is enabled.
Date: Fri,  1 Jul 2016 18:46:27 -0400
Message-ID: <1467413189-29566-10-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35355 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbcGAWqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:51 -0400
Received: by mail-pf0-f180.google.com with SMTP id c2so44000253pfa.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:51 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a default VLAN, the VF has its own VLAN domain and it can receive
all traffic within that domain.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9134268..2740ac3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4316,6 +4316,16 @@ static int bnxt_alloc_rfs_vnics(struct bnxt *bp)
 #endif
 }
 
+/* Allow PF and VF with default VLAN to be in promiscuous mode */
+static bool bnxt_promisc_ok(struct bnxt *bp)
+{
+#ifdef CONFIG_BNXT_SRIOV
+	if (BNXT_VF(bp) && !bp->vf.vlan)
+		return false;
+#endif
+	return true;
+}
+
 static int bnxt_cfg_rx_mode(struct bnxt *);
 static bool bnxt_mc_list_updated(struct bnxt *, u32 *);
 
@@ -4381,7 +4391,7 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 
 	vnic->rx_mask = CFA_L2_SET_RX_MASK_REQ_MASK_BCAST;
 
-	if ((bp->dev->flags & IFF_PROMISC) && BNXT_PF(bp))
+	if ((bp->dev->flags & IFF_PROMISC) && bnxt_promisc_ok(bp))
 		vnic->rx_mask |= CFA_L2_SET_RX_MASK_REQ_MASK_PROMISCUOUS;
 
 	if (bp->dev->flags & IFF_ALLMULTI) {
@@ -5528,8 +5538,7 @@ static void bnxt_set_rx_mode(struct net_device *dev)
 		  CFA_L2_SET_RX_MASK_REQ_MASK_MCAST |
 		  CFA_L2_SET_RX_MASK_REQ_MASK_ALL_MCAST);
 
-	/* Only allow PF to be in promiscuous mode */
-	if ((dev->flags & IFF_PROMISC) && BNXT_PF(bp))
+	if ((dev->flags & IFF_PROMISC) && bnxt_promisc_ok(bp))
 		mask |= CFA_L2_SET_RX_MASK_REQ_MASK_PROMISCUOUS;
 
 	uc_update = bnxt_uc_list_updated(bp);
-- 
1.8.3.1
