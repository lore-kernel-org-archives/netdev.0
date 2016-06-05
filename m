From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 6/6] qed: PF to reply to unknown messages
Date: Sun, 5 Jun 2016 13:11:16 +0300
Message-ID: <1465121476-32494-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:12522 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751315AbcFEKLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:11:44 -0400
In-Reply-To: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a future VF would send the PF an unknown message, the PF today would
not send a reply. This would have 2 bad effects:
  a. VF would have to timeout on the request.
  b. If VF were to send an additional message to PF, firmware would mark
     it as malicious.

Instead, if there's some valid reply-address on the message - let the PF
answer and tell the VF it doesn't know the message.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 33 +++++++++++++++++++----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 50b535a..0a5b1f5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -2857,7 +2857,6 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 {
 	struct qed_iov_vf_mbx *mbx;
 	struct qed_vf_info *p_vf;
-	int i;
 
 	p_vf = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
 	if (!p_vf)
@@ -2866,9 +2865,8 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 	mbx = &p_vf->vf_mbx;
 
 	/* qed_iov_process_mbx_request */
-	DP_VERBOSE(p_hwfn,
-		   QED_MSG_IOV,
-		   "qed_iov_process_mbx_req vfid %d\n", p_vf->abs_vf_id);
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "VF[%02x]: Processing mailbox message\n", p_vf->abs_vf_id);
 
 	mbx->first_tlv = mbx->req_virt->first_tlv;
 
@@ -2922,15 +2920,28 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 		 * support them. Or this may be because someone wrote a crappy
 		 * VF driver and is sending garbage over the channel.
 		 */
-		DP_ERR(p_hwfn,
-		       "unknown TLV. type %d length %d. first 20 bytes of mailbox buffer:\n",
-		       mbx->first_tlv.tl.type, mbx->first_tlv.tl.length);
-
-		for (i = 0; i < 20; i++) {
+		DP_NOTICE(p_hwfn,
+			  "VF[%02x]: unknown TLV. type %04x length %04x padding %08x reply address %llu\n",
+			  p_vf->abs_vf_id,
+			  mbx->first_tlv.tl.type,
+			  mbx->first_tlv.tl.length,
+			  mbx->first_tlv.padding, mbx->first_tlv.reply_address);
+
+		/* Try replying in case reply address matches the acquisition's
+		 * posted address.
+		 */
+		if (p_vf->acquire.first_tlv.reply_address &&
+		    (mbx->first_tlv.reply_address ==
+		     p_vf->acquire.first_tlv.reply_address)) {
+			qed_iov_prepare_resp(p_hwfn, p_ptt, p_vf,
+					     mbx->first_tlv.tl.type,
+					     sizeof(struct pfvf_def_resp_tlv),
+					     PFVF_STATUS_NOT_SUPPORTED);
+		} else {
 			DP_VERBOSE(p_hwfn,
 				   QED_MSG_IOV,
-				   "%x ",
-				   mbx->req_virt->tlv_buf_size.tlv_buffer[i]);
+				   "VF[%02x]: Can't respond to TLV - no valid reply address\n",
+				   p_vf->abs_vf_id);
 		}
 	}
 }
-- 
1.9.3
