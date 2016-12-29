From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 09/14] bnxt_en: Assign additional vnics to VFs.
Date: Thu, 29 Dec 2016 12:13:39 -0500
Message-ID: <1483031624-20076-10-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33887 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753346AbcL2RON (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:13 -0500
Received: by mail-pf0-f171.google.com with SMTP id c4so63186398pfb.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:13 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assign additional vnics to VFs whenever possible so that NTUPLE can be
supported on the VFs.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index c696025..0c9f6c1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -429,6 +429,8 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 		vf_rx_rings = (pf->max_rx_rings - bp->rx_nr_rings) / num_vfs;
 	vf_ring_grps = (bp->pf.max_hw_ring_grps - bp->rx_nr_rings) / num_vfs;
 	vf_tx_rings = (pf->max_tx_rings - bp->tx_nr_rings) / num_vfs;
+	vf_vnics = (pf->max_vnics - bp->nr_vnics) / num_vfs;
+	vf_vnics = min_t(u16, vf_vnics, vf_rx_rings);
 
 	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_MTU |
 				  FUNC_CFG_REQ_ENABLES_MRU |
@@ -451,7 +453,6 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 	req.num_rx_rings = cpu_to_le16(vf_rx_rings);
 	req.num_hw_ring_grps = cpu_to_le16(vf_ring_grps);
 	req.num_l2_ctxs = cpu_to_le16(4);
-	vf_vnics = 1;
 
 	req.num_vnics = cpu_to_le16(vf_vnics);
 	/* FIXME spec currently uses 1 bit for stats ctx */
@@ -506,6 +507,8 @@ static int bnxt_sriov_enable(struct bnxt *bp, int *num_vfs)
 			    min_rx_rings)
 				rx_ok = 1;
 		}
+		if (bp->pf.max_vnics - bp->nr_vnics < min_rx_rings)
+			rx_ok = 0;
 
 		if (bp->pf.max_tx_rings - bp->tx_nr_rings >= min_tx_rings)
 			tx_ok = 1;
-- 
1.8.3.1
