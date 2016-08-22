From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/4] qed: Change locking scheme for VF channel
Date: Mon, 22 Aug 2016 13:25:12 +0300
Message-ID: <1471861512-30104-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471861512-30104-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46056 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754796AbcHVKZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:25:31 -0400
In-Reply-To: <1471861512-30104-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each VF employees a lock that's supposed to serialize its usage of the
HW channel for communication with its PF, but the critical section is
ill-defined:

  - VFs currently release the lock whenever the PF response arrives,
    prior to actually processing the reply buffer [which was also supposed
    to have been protected by same lock].

  - The lock would be released on first response, ignoring the possibilty
    the sw flow isn't over [as might be the case of the acquisition flow].
    As a result, the flow would run unprotected and would cause a double
    mutex release [as the additional message completion would release it
    while its actually already free].

Change the flow to have a dedicated function to be called at end of each
flow and release the lock.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Notice this is basically a bug fix, but pushing it to net would create
several merge conflicts.
Furthermore, while the first issue is a theoretical race, the second
would be constantly hit if a modern VF would be used on top of a legacy
PF [i.e., patch #3 in this series].
Hence the motivation of adding it here.

Still, if prefered I can provide a version of this for `net'.
---
 drivers/net/ethernet/qlogic/qed/qed_vf.c | 124 ++++++++++++++++++++++---------
 1 file changed, 90 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index f9f68da..3c9071d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -46,6 +46,17 @@ static void *qed_vf_pf_prep(struct qed_hwfn *p_hwfn, u16 type, u16 length)
 	return p_tlv;
 }
 
+static void qed_vf_pf_req_end(struct qed_hwfn *p_hwfn, int req_status)
+{
+	union pfvf_tlvs *resp = p_hwfn->vf_iov_info->pf2vf_reply;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "VF request status = 0x%x, PF reply status = 0x%x\n",
+		   req_status, resp->default_resp.hdr.status);
+
+	mutex_unlock(&(p_hwfn->vf_iov_info->mutex));
+}
+
 static int qed_send_msg2pf(struct qed_hwfn *p_hwfn, u8 *done, u32 resp_size)
 {
 	union vfpf_tlvs *p_req = p_hwfn->vf_iov_info->vf2pf_request;
@@ -103,16 +114,12 @@ static int qed_send_msg2pf(struct qed_hwfn *p_hwfn, u8 *done, u32 resp_size)
 			   "VF <-- PF Timeout [Type %d]\n",
 			   p_req->first_tlv.tl.type);
 		rc = -EBUSY;
-		goto exit;
 	} else {
 		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
 			   "PF response: %d [Type %d]\n",
 			   *done, p_req->first_tlv.tl.type);
 	}
 
-exit:
-	mutex_unlock(&(p_hwfn->vf_iov_info->mutex));
-
 	return rc;
 }
 
@@ -296,6 +303,8 @@ static int qed_vf_pf_acquire(struct qed_hwfn *p_hwfn)
 	}
 
 exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
+
 	return rc;
 }
 
@@ -435,10 +444,12 @@ int qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
 	resp = &p_iov->pf2vf_reply->queue_start;
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
 
 	/* Learn the address of the producer from the response */
 	if (pp_prod && !p_iov->b_pre_fp_hsi) {
@@ -453,6 +464,8 @@ int qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
 		__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u32),
 				  (u32 *)&init_prod_val);
 	}
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
 
 	return rc;
 }
@@ -478,10 +491,15 @@ int qed_vf_pf_rxq_stop(struct qed_hwfn *p_hwfn, u16 rx_qid, bool cqe_completion)
 	resp = &p_iov->pf2vf_reply->default_resp;
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
 
 	return rc;
 }
@@ -544,6 +562,7 @@ int qed_vf_pf_txq_start(struct qed_hwfn *p_hwfn,
 			   tx_queue_id, *pp_doorbell, resp->offset);
 	}
 exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
 
 	return rc;
 }
@@ -568,10 +587,15 @@ int qed_vf_pf_txq_stop(struct qed_hwfn *p_hwfn, u16 tx_qid)
 	resp = &p_iov->pf2vf_reply->default_resp;
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
+
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
 
 	return rc;
 }
@@ -610,10 +634,15 @@ int qed_vf_pf_vport_start(struct qed_hwfn *p_hwfn,
 	resp = &p_iov->pf2vf_reply->default_resp;
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
 
 	return rc;
 }
@@ -634,10 +663,15 @@ int qed_vf_pf_vport_stop(struct qed_hwfn *p_hwfn)
 
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
+
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
 
 	return rc;
 }
@@ -837,13 +871,18 @@ int qed_vf_pf_vport_update(struct qed_hwfn *p_hwfn,
 
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, resp_size);
 	if (rc)
-		return rc;
+		goto exit;
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
 
 	qed_vf_handle_vp_update_tlvs_resp(p_hwfn, p_params);
 
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
+
 	return rc;
 }
 
@@ -864,14 +903,19 @@ int qed_vf_pf_reset(struct qed_hwfn *p_hwfn)
 	resp = &p_iov->pf2vf_reply->default_resp;
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EAGAIN;
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EAGAIN;
+		goto exit;
+	}
 
 	p_hwfn->b_int_enabled = 0;
 
-	return 0;
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
+
+	return rc;
 }
 
 int qed_vf_pf_release(struct qed_hwfn *p_hwfn)
@@ -895,6 +939,8 @@ int qed_vf_pf_release(struct qed_hwfn *p_hwfn)
 	if (!rc && resp->hdr.status != PFVF_STATUS_SUCCESS)
 		rc = -EAGAIN;
 
+	qed_vf_pf_req_end(p_hwfn, rc);
+
 	p_hwfn->b_int_enabled = 0;
 
 	if (p_iov->vf2pf_request)
@@ -963,12 +1009,17 @@ int qed_vf_pf_filter_ucast(struct qed_hwfn *p_hwfn,
 	resp = &p_iov->pf2vf_reply->default_resp;
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EAGAIN;
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EAGAIN;
+		goto exit;
+	}
 
-	return 0;
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
+
+	return rc;
 }
 
 int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
@@ -987,12 +1038,17 @@ int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
 
 	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
 	if (rc)
-		return rc;
+		goto exit;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		rc = -EINVAL;
+		goto exit;
+	}
 
-	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
-		return -EINVAL;
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
 
-	return 0;
+	return rc;
 }
 
 u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
-- 
1.9.3
