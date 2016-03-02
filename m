From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 3/7] bnx2x: fix receive of VF->PF mailbox messages by the PF on big-endian
Date: Wed,  2 Mar 2016 13:47:07 +0100
Message-ID: <1456922831-15071-4-git-send-email-mschmidt@redhat.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882AbcCBMoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:22 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ppc64 the PF did not receive messages from VFs correctly.

Fields of struct vf_pf_event_data are little-endian.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  | 6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 6 ++++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 47b13ed..1058591 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -5213,9 +5213,9 @@ struct eth_event_data {
 struct vf_pf_event_data {
 	u8 vf_id;
 	u8 reserved0;
-	u16 reserved1;
-	u32 msg_addr_lo;
-	u32 msg_addr_hi;
+	__le16 reserved1;
+	__le32 msg_addr_lo;
+	__le32 msg_addr_hi;
 };
 
 /*
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 1374e53..bfae300 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -2187,8 +2187,10 @@ void bnx2x_vf_mbx_schedule(struct bnx2x *bp,
 
 	/* Update VFDB with current message and schedule its handling */
 	mutex_lock(&BP_VFDB(bp)->event_mutex);
-	BP_VF_MBX(bp, vf_idx)->vf_addr_hi = vfpf_event->msg_addr_hi;
-	BP_VF_MBX(bp, vf_idx)->vf_addr_lo = vfpf_event->msg_addr_lo;
+	BP_VF_MBX(bp, vf_idx)->vf_addr_hi =
+		le32_to_cpu(vfpf_event->msg_addr_hi);
+	BP_VF_MBX(bp, vf_idx)->vf_addr_lo =
+		le32_to_cpu(vfpf_event->msg_addr_lo);
 	BP_VFDB(bp)->event_occur |= (1ULL << vf_idx);
 	mutex_unlock(&BP_VFDB(bp)->event_mutex);
 
-- 
2.5.0
