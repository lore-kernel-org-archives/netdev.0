From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 6/6] bnx2x: handle known but unsupported VF messages
Date: Mon, 23 Sep 2013 10:12:55 +0300
Message-ID: <1379920375-10303-7-git-send-email-yuvalmin@broadcom.com>
References: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2400 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab3IWHNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 03:13:17 -0400
In-Reply-To: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Commit b9871bcf "bnx2x: VF RSS support - PF side" has deprecated one of
the previous existing messages. If an old VF driver were to send this message
to the PF then the PF will not reply and leave the mailbox in an unsteady
state (and cause a timeout on the VF side).

Wait until firmware ack is written before unlocking channel

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 50 ++++++++++++------------
 1 file changed, 24 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 6cfb887..da16953 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1765,28 +1765,28 @@ static void bnx2x_vf_mbx_request(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		switch (mbx->first_tlv.tl.type) {
 		case CHANNEL_TLV_ACQUIRE:
 			bnx2x_vf_mbx_acquire(bp, vf, mbx);
-			break;
+			return;
 		case CHANNEL_TLV_INIT:
 			bnx2x_vf_mbx_init_vf(bp, vf, mbx);
-			break;
+			return;
 		case CHANNEL_TLV_SETUP_Q:
 			bnx2x_vf_mbx_setup_q(bp, vf, mbx);
-			break;
+			return;
 		case CHANNEL_TLV_SET_Q_FILTERS:
 			bnx2x_vf_mbx_set_q_filters(bp, vf, mbx);
-			break;
+			return;
 		case CHANNEL_TLV_TEARDOWN_Q:
 			bnx2x_vf_mbx_teardown_q(bp, vf, mbx);
-			break;
+			return;
 		case CHANNEL_TLV_CLOSE:
 			bnx2x_vf_mbx_close_vf(bp, vf, mbx);
-			break;
+			return;
 		case CHANNEL_TLV_RELEASE:
 			bnx2x_vf_mbx_release_vf(bp, vf, mbx);
-			break;
+			return;
 		case CHANNEL_TLV_UPDATE_RSS:
 			bnx2x_vf_mbx_update_rss(bp, vf, mbx);
-			break;
+			return;
 		}
 
 	} else {
@@ -1802,26 +1802,24 @@ static void bnx2x_vf_mbx_request(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		for (i = 0; i < 20; i++)
 			DP_CONT(BNX2X_MSG_IOV, "%x ",
 				mbx->msg->req.tlv_buf_size.tlv_buffer[i]);
+	}
 
-		/* test whether we can respond to the VF (do we have an address
-		 * for it?)
-		 */
-		if (vf->state == VF_ACQUIRED || vf->state == VF_ENABLED) {
-			/* mbx_resp uses the op_rc of the VF */
-			vf->op_rc = PFVF_STATUS_NOT_SUPPORTED;
+	/* can we respond to VF (do we have an address for it?) */
+	if (vf->state == VF_ACQUIRED || vf->state == VF_ENABLED) {
+		/* mbx_resp uses the op_rc of the VF */
+		vf->op_rc = PFVF_STATUS_NOT_SUPPORTED;
 
-			/* notify the VF that we do not support this request */
-			bnx2x_vf_mbx_resp(bp, vf);
-		} else {
-			/* can't send a response since this VF is unknown to us
-			 * just ack the FW to release the mailbox and unlock
-			 * the channel.
-			 */
-			storm_memset_vf_mbx_ack(bp, vf->abs_vfid);
-			mmiowb();
-			bnx2x_unlock_vf_pf_channel(bp, vf,
-						   mbx->first_tlv.tl.type);
-		}
+		/* notify the VF that we do not support this request */
+		bnx2x_vf_mbx_resp(bp, vf);
+	} else {
+		/* can't send a response since this VF is unknown to us
+		 * just ack the FW to release the mailbox and unlock
+		 * the channel.
+		 */
+		storm_memset_vf_mbx_ack(bp, vf->abs_vfid);
+		/* Firmware ack should be written before unlocking channel */
+		mmiowb();
+		bnx2x_unlock_vf_pf_channel(bp, vf, mbx->first_tlv.tl.type);
 	}
 }
 
-- 
1.8.1.227.g44fe835
