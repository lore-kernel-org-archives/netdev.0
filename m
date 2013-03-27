From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/6] bnx2x: Fix VF outer vlan removal
Date: Wed, 27 Mar 2013 13:05:16 +0200
Message-ID: <1364382319-24952-4-git-send-email-yuvalmin@broadcom.com>
References: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2697 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999Ab3C0MKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 08:10:31 -0400
In-Reply-To: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Outer vlan removal in VF queues was made according to the VF's
multi-function mode (which is never set).
Instead, the PF's multi-function mode should be used to determine
if outer vlan removal is needed.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 531eebf..5d59070 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -435,7 +435,6 @@ int bnx2x_vfpf_setup_q(struct bnx2x *bp, int fp_idx)
 	/* calculate queue flags */
 	flags |= VFPF_QUEUE_FLG_STATS;
 	flags |= VFPF_QUEUE_FLG_CACHE_ALIGN;
-	flags |= IS_MF_SD(bp) ? VFPF_QUEUE_FLG_OV : 0;
 	flags |= VFPF_QUEUE_FLG_VLAN;
 	DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
 
@@ -1004,7 +1003,7 @@ static void bnx2x_vf_mbx_init_vf(struct bnx2x *bp, struct bnx2x_virtf *vf,
 }
 
 /* convert MBX queue-flags to standard SP queue-flags */
-static void bnx2x_vf_mbx_set_q_flags(u32 mbx_q_flags,
+static void bnx2x_vf_mbx_set_q_flags(struct bnx2x *bp, u32 mbx_q_flags,
 				     unsigned long *sp_q_flags)
 {
 	if (mbx_q_flags & VFPF_QUEUE_FLG_TPA)
@@ -1015,8 +1014,6 @@ static void bnx2x_vf_mbx_set_q_flags(u32 mbx_q_flags,
 		__set_bit(BNX2X_Q_FLG_TPA_GRO, sp_q_flags);
 	if (mbx_q_flags & VFPF_QUEUE_FLG_STATS)
 		__set_bit(BNX2X_Q_FLG_STATS, sp_q_flags);
-	if (mbx_q_flags & VFPF_QUEUE_FLG_OV)
-		__set_bit(BNX2X_Q_FLG_OV, sp_q_flags);
 	if (mbx_q_flags & VFPF_QUEUE_FLG_VLAN)
 		__set_bit(BNX2X_Q_FLG_VLAN, sp_q_flags);
 	if (mbx_q_flags & VFPF_QUEUE_FLG_COS)
@@ -1025,6 +1022,10 @@ static void bnx2x_vf_mbx_set_q_flags(u32 mbx_q_flags,
 		__set_bit(BNX2X_Q_FLG_HC, sp_q_flags);
 	if (mbx_q_flags & VFPF_QUEUE_FLG_DHC)
 		__set_bit(BNX2X_Q_FLG_DHC, sp_q_flags);
+
+	/* outer vlan removal is set according to the PF's multi fuction mode */
+	if (IS_MF_SD(bp))
+		__set_bit(BNX2X_Q_FLG_OV, sp_q_flags);
 }
 
 static void bnx2x_vf_mbx_setup_q(struct bnx2x *bp, struct bnx2x_virtf *vf,
@@ -1075,11 +1076,11 @@ static void bnx2x_vf_mbx_setup_q(struct bnx2x *bp, struct bnx2x_virtf *vf,
 			init_p->tx.hc_rate = setup_q->txq.hc_rate;
 			init_p->tx.sb_cq_index = setup_q->txq.sb_index;
 
-			bnx2x_vf_mbx_set_q_flags(setup_q->txq.flags,
+			bnx2x_vf_mbx_set_q_flags(bp, setup_q->txq.flags,
 						 &init_p->tx.flags);
 
 			/* tx setup - flags */
-			bnx2x_vf_mbx_set_q_flags(setup_q->txq.flags,
+			bnx2x_vf_mbx_set_q_flags(bp, setup_q->txq.flags,
 						 &setup_p->flags);
 
 			/* tx setup - general, nothing */
@@ -1107,11 +1108,11 @@ static void bnx2x_vf_mbx_setup_q(struct bnx2x *bp, struct bnx2x_virtf *vf,
 			/* rx init */
 			init_p->rx.hc_rate = setup_q->rxq.hc_rate;
 			init_p->rx.sb_cq_index = setup_q->rxq.sb_index;
-			bnx2x_vf_mbx_set_q_flags(setup_q->rxq.flags,
+			bnx2x_vf_mbx_set_q_flags(bp, setup_q->rxq.flags,
 						 &init_p->rx.flags);
 
 			/* rx setup - flags */
-			bnx2x_vf_mbx_set_q_flags(setup_q->rxq.flags,
+			bnx2x_vf_mbx_set_q_flags(bp, setup_q->rxq.flags,
 						 &setup_p->flags);
 
 			/* rx setup - general */
-- 
1.8.1.227.g44fe835
