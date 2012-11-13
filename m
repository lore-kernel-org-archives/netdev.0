From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH 03/22] bnx2x: Add to VF <-> PF channel the release
 request
Date: Tue, 13 Nov 2012 18:17:12 +0200
Message-ID: <1352823451-27042-4-git-send-email-ariele@broadcom.com>
References: <1352823451-27042-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1343 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755116Ab2KMQPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 11:15:15 -0500
In-Reply-To: <1352823451-27042-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF driver uses this request when removed. The PF driver
reclaims all resources allocated for that VF at this
time.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   45 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h |   14 +++++++
 3 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 91c85d6..921e921 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2222,6 +2222,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 int bnx2x_get_vf_id(struct bnx2x *bp, u32 *vf_id);
 int bnx2x_send_msg2pf(struct bnx2x *bp, u8 *done, dma_addr_t msg_mapping);
 int __devinit bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count);
+int __devexit bnx2x_vfpf_release(struct bnx2x *bp);
 /* Congestion management fairness mode */
 #define CMNG_FNS_NONE		0
 #define CMNG_FNS_MINMAX		1
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9a8c397..8e71b04 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12276,6 +12276,9 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 
 	/* Make sure RESET task is not scheduled before continuing */
 	cancel_delayed_work_sync(&bp->sp_rtnl_task);
+	/* send message via vfpf channel to release the resources of this vf */
+	if (IS_VF(bp))
+		bnx2x_vfpf_release(bp);
 
 	if (bp->regview)
 		iounmap(bp->regview);
@@ -13265,3 +13268,45 @@ int __devinit bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count,
 
 	return 0;
 }
+
+int __devexit bnx2x_vfpf_release(struct bnx2x *bp)
+{
+	struct vfpf_release_tlv *req = &bp->vf2pf_mbox->req.release;
+	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
+	u32 rc = 0, vf_id;
+
+	/* clear mailbox and prep first tlv */
+	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_RELEASE, sizeof(*req));
+
+	if (bnx2x_get_vf_id(bp, &vf_id))
+		return -EAGAIN;
+
+	req->vf_id = vf_id;
+
+	/* add list termination tlv */
+	bnx2x_add_tlv(bp, req, req->first_tlv.tl.length, CHANNEL_TLV_LIST_END,
+		      sizeof(struct channel_list_end_tlv));
+
+	/* output tlvs list */
+	bnx2x_dp_tlv_list(bp, req);
+
+	/* send release request */
+	rc = bnx2x_send_msg2pf(bp, &resp->hdr.status, bp->vf2pf_mbox_mapping);
+
+	/* PF timeout */
+	if (rc)
+		return rc;
+
+	/* PF released us */
+	if (resp->hdr.status == PFVF_STATUS_SUCCESS) {
+		DP(BNX2X_MSG_SP, "vf released\n");
+
+	/* PF reports error */
+	} else {
+		BNX2X_ERR("PF failed our release request - are we out of sync? response status: %d\n",
+			  resp->hdr.status);
+		return -EAGAIN;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index 8f124fe..79eedd3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -67,6 +67,10 @@ struct pfvf_tlv {
 	u8 padding[3];
 };
 
+/* response tlv used for most tlvs */
+struct pfvf_general_resp_tlv {
+	struct pfvf_tlv hdr;
+};
 /* used to terminate and pad a tlv list */
 struct channel_list_end_tlv {
 	struct channel_tlv tl;
@@ -124,17 +128,26 @@ struct pfvf_acquire_resp_tlv {
 	} resc;
 };
 
+/* release the VF's acquired resources */
+struct vfpf_release_tlv {
+	struct vfpf_first_tlv   first_tlv;
+	u16			vf_id;  /* for debug */
+	u8 padding[2];
+};
+
 struct tlv_buffer_size {
 	u8 tlv_buffer[TLV_BUFFER_SIZE];
 };
 union vfpf_tlvs {
 	struct vfpf_first_tlv		first_tlv;
 	struct vfpf_acquire_tlv		acquire;
+	struct vfpf_release_tlv		release;
 	struct channel_list_end_tlv     list_end;
 	struct tlv_buffer_size		tlv_buf_size;
 };
 
 union pfvf_tlvs {
+	struct pfvf_general_resp_tlv	general_resp;
 	struct pfvf_acquire_resp_tlv	acquire_resp;
 	struct channel_list_end_tlv	list_end;
 	struct tlv_buffer_size		tlv_buf_size;
@@ -142,6 +155,7 @@ union pfvf_tlvs {
 enum channel_tlvs {
 	   CHANNEL_TLV_NONE, /* ends tlv sequence */
 	   CHANNEL_TLV_ACQUIRE,
+	   CHANNEL_TLV_RELEASE,
 	   CHANNEL_TLV_LIST_END,
 	   CHANNEL_TLV_MAX
 };
-- 
1.7.9.GIT
