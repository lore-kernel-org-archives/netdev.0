From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 4/6] bnx2x: Prevent VF race
Date: Wed, 27 Mar 2013 13:05:17 +0200
Message-ID: <1364382319-24952-5-git-send-email-yuvalmin@broadcom.com>
References: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2778 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753992Ab3C0MKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 08:10:31 -0400
In-Reply-To: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

The mail box containing the Vf-Pf messages is susceptible
to a race - it's possible for 2 flows to try and write commands,
causing one to override the other's message.
Use a mutex to synchronize the access, preventing said race.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |  2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 12 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  9 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 90 ++++++++++++++++-------
 5 files changed, 82 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index c59da2d..c630342 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1277,6 +1277,8 @@ struct bnx2x {
 #define BP_FW_MB_IDX(bp)		BP_FW_MB_IDX_VN(bp, BP_VN(bp))
 
 #ifdef CONFIG_BNX2X_SRIOV
+	/* protects vf2pf mailbox from simultaneous access */
+	struct mutex		vf2pf_mutex;
 	/* vf pf channel mailbox contains request and response buffers */
 	struct bnx2x_vf_mbx_msg	*vf2pf_mbox;
 	dma_addr_t		vf2pf_mbox_mapping;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2c6a2a6..6de18d7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12520,7 +12520,8 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	 * l2 connections.
 	 */
 	if (IS_VF(bp)) {
-		bnx2x_vf_map_doorbells(bp);
+		bp->doorbells = bnx2x_vf_doorbells(bp);
+		mutex_init(&bp->vf2pf_mutex);
 		rc = bnx2x_vf_pci_alloc(bp);
 		if (rc)
 			goto init_one_exit;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index faadd15..0431b98 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2386,8 +2386,8 @@ int bnx2x_iov_eq_sp_event(struct bnx2x *bp, union event_ring_elem *elem)
 		goto get_vf;
 	case EVENT_RING_OPCODE_MALICIOUS_VF:
 		abs_vfid = elem->message.data.malicious_vf_event.vf_id;
-		DP(BNX2X_MSG_IOV, "Got VF MALICIOUS notification abs_vfid=%d\n",
-		   abs_vfid);
+		DP(BNX2X_MSG_IOV, "Got VF MALICIOUS notification abs_vfid=%d err_id=0x%x\n",
+		   abs_vfid, elem->message.data.malicious_vf_event.err_id);
 		goto get_vf;
 	default:
 		return 1;
@@ -2444,8 +2444,8 @@ get_vf:
 		/* Do nothing for now */
 		break;
 	case EVENT_RING_OPCODE_MALICIOUS_VF:
-		DP(BNX2X_MSG_IOV, "got VF [%d] MALICIOUS notification\n",
-		   vf->abs_vfid);
+		DP(BNX2X_MSG_IOV, "Got VF MALICIOUS notification abs_vfid=%d error id %x\n",
+		   abs_vfid, elem->message.data.malicious_vf_event.err_id);
 		/* Do nothing for now */
 		break;
 	}
@@ -3415,10 +3415,10 @@ enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp)
 	return PFVF_BULLETIN_UPDATED;
 }
 
-void bnx2x_vf_map_doorbells(struct bnx2x *bp)
+void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
 {
 	/* vf doorbells are embedded within the regview */
-	bp->doorbells = bp->regview + PXP_VF_ADDR_DB_START;
+	return bp->regview + PXP_VF_ADDR_DB_START;
 }
 
 int bnx2x_vf_pci_alloc(struct bnx2x *bp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index a10bdb2..d4b17b7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -713,6 +713,7 @@ void bnx2x_add_tlv(struct bnx2x *bp, void *tlvs_list, u16 offset, u16 type,
 		   u16 length);
 void bnx2x_vfpf_prep(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv,
 		     u16 type, u16 length);
+void bnx2x_vfpf_finalize(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv);
 void bnx2x_dp_tlv_list(struct bnx2x *bp, void *tlvs_list);
 
 bool bnx2x_tlv_supported(u16 tlvtype);
@@ -751,7 +752,7 @@ static inline int bnx2x_vf_ustorm_prods_offset(struct bnx2x *bp,
 }
 
 enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp);
-void bnx2x_vf_map_doorbells(struct bnx2x *bp);
+void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp);
 int bnx2x_vf_pci_alloc(struct bnx2x *bp);
 int bnx2x_enable_sriov(struct bnx2x *bp);
 void bnx2x_disable_sriov(struct bnx2x *bp);
@@ -808,7 +809,11 @@ static inline enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp
 	return PFVF_BULLETIN_UNCHANGED;
 }
 
-static inline int bnx2x_vf_map_doorbells(struct bnx2x *bp) {return 0; }
+static inline void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
+{
+	return NULL;
+}
+
 static inline int bnx2x_vf_pci_alloc(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp) {}
 static inline int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs) {return 0; }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 531eebf..46f9843 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -36,6 +36,8 @@ void bnx2x_add_tlv(struct bnx2x *bp, void *tlvs_list, u16 offset, u16 type,
 void bnx2x_vfpf_prep(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv,
 		     u16 type, u16 length)
 {
+	mutex_lock(&bp->vf2pf_mutex);
+
 	DP(BNX2X_MSG_IOV, "preparing to send %d tlv over vf pf channel\n",
 	   type);
 
@@ -49,6 +51,15 @@ void bnx2x_vfpf_prep(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv,
 	first_tlv->resp_msg_offset = sizeof(bp->vf2pf_mbox->req);
 }
 
+/* releases the mailbox */
+void bnx2x_vfpf_finalize(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv)
+{
+	DP(BNX2X_MSG_IOV, "done sending [%d] tlv over vf pf channel\n",
+	   first_tlv->tl.type);
+
+	mutex_unlock(&bp->vf2pf_mutex);
+}
+
 /* list the types and lengths of the tlvs on the buffer */
 void bnx2x_dp_tlv_list(struct bnx2x *bp, void *tlvs_list)
 {
@@ -181,8 +192,10 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 	/* clear mailbox and prep first tlv */
 	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_ACQUIRE, sizeof(*req));
 
-	if (bnx2x_get_vf_id(bp, &vf_id))
-		return -EAGAIN;
+	if (bnx2x_get_vf_id(bp, &vf_id)) {
+		rc = -EAGAIN;
+		goto out;
+	}
 
 	req->vfdev_info.vf_id = vf_id;
 	req->vfdev_info.vf_os = 0;
@@ -213,7 +226,7 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 
 		/* PF timeout */
 		if (rc)
-			return rc;
+			goto out;
 
 		/* copy acquire response from buffer to bp */
 		memcpy(&bp->acquire_resp, resp, sizeof(bp->acquire_resp));
@@ -253,7 +266,8 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 			/* PF reports error */
 			BNX2X_ERR("Failed to get the requested amount of resources: %d. Breaking...\n",
 				  bp->acquire_resp.hdr.status);
-			return -EAGAIN;
+			rc = -EAGAIN;
+			goto out;
 		}
 	}
 
@@ -279,20 +293,24 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 		       bp->acquire_resp.resc.current_mac_addr,
 		       ETH_ALEN);
 
-	return 0;
+out:
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
+	return rc;
 }
 
 int bnx2x_vfpf_release(struct bnx2x *bp)
 {
 	struct vfpf_release_tlv *req = &bp->vf2pf_mbox->req.release;
 	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
-	u32 rc = 0, vf_id;
+	u32 rc, vf_id;
 
 	/* clear mailbox and prep first tlv */
 	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_RELEASE, sizeof(*req));
 
-	if (bnx2x_get_vf_id(bp, &vf_id))
-		return -EAGAIN;
+	if (bnx2x_get_vf_id(bp, &vf_id)) {
+		rc = -EAGAIN;
+		goto out;
+	}
 
 	req->vf_id = vf_id;
 
@@ -308,7 +326,8 @@ int bnx2x_vfpf_release(struct bnx2x *bp)
 
 	if (rc)
 		/* PF timeout */
-		return rc;
+		goto out;
+
 	if (resp->hdr.status == PFVF_STATUS_SUCCESS) {
 		/* PF released us */
 		DP(BNX2X_MSG_SP, "vf released\n");
@@ -316,10 +335,13 @@ int bnx2x_vfpf_release(struct bnx2x *bp)
 		/* PF reports error */
 		BNX2X_ERR("PF failed our release request - are we out of sync? response status: %d\n",
 			  resp->hdr.status);
-		return -EAGAIN;
+		rc = -EAGAIN;
+		goto out;
 	}
+out:
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
 
-	return 0;
+	return rc;
 }
 
 /* Tell PF about SB addresses */
@@ -350,16 +372,20 @@ int bnx2x_vfpf_init(struct bnx2x *bp)
 
 	rc = bnx2x_send_msg2pf(bp, &resp->hdr.status, bp->vf2pf_mbox_mapping);
 	if (rc)
-		return rc;
+		goto out;
 
 	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
 		BNX2X_ERR("INIT VF failed: %d. Breaking...\n",
 			  resp->hdr.status);
-		return -EAGAIN;
+		rc = -EAGAIN;
+		goto out;
 	}
 
 	DP(BNX2X_MSG_SP, "INIT VF Succeeded\n");
-	return 0;
+out:
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
+
+	return rc;
 }
 
 /* CLOSE VF - opposite to INIT_VF */
@@ -401,6 +427,8 @@ void bnx2x_vfpf_close_vf(struct bnx2x *bp)
 		BNX2X_ERR("Sending CLOSE failed: pf response was %d\n",
 			  resp->hdr.status);
 
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
+
 free_irq:
 	/* Disable HW interrupts, NAPI */
 	bnx2x_netif_stop(bp, 0);
@@ -486,8 +514,11 @@ int bnx2x_vfpf_setup_q(struct bnx2x *bp, int fp_idx)
 	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
 		BNX2X_ERR("Status of SETUP_Q for queue[%d] is %d\n",
 			  fp_idx, resp->hdr.status);
-		return -EINVAL;
+		rc = -EINVAL;
 	}
+
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
+
 	return rc;
 }
 
@@ -515,17 +546,19 @@ int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx)
 	if (rc) {
 		BNX2X_ERR("Sending TEARDOWN for queue %d failed: %d\n", qidx,
 			  rc);
-		return rc;
+		goto out;
 	}
 
 	/* PF failed the transaction */
 	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
 		BNX2X_ERR("TEARDOWN for queue %d failed: %d\n", qidx,
 			  resp->hdr.status);
-		return -EINVAL;
+		rc = -EINVAL;
 	}
 
-	return 0;
+out:
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
+	return rc;
 }
 
 /* request pf to add a mac for the vf */
@@ -533,7 +566,7 @@ int bnx2x_vfpf_set_mac(struct bnx2x *bp)
 {
 	struct vfpf_set_q_filters_tlv *req = &bp->vf2pf_mbox->req.set_q_filters;
 	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
-	int rc;
+	int rc = 0;
 
 	/* clear mailbox and prep first tlv */
 	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_SET_Q_FILTERS,
@@ -562,7 +595,7 @@ int bnx2x_vfpf_set_mac(struct bnx2x *bp)
 	rc = bnx2x_send_msg2pf(bp, &resp->hdr.status, bp->vf2pf_mbox_mapping);
 	if (rc) {
 		BNX2X_ERR("failed to send message to pf. rc was %d\n", rc);
-		return rc;
+		goto out;
 	}
 
 	/* failure may mean PF was configured with a new mac for us */
@@ -587,8 +620,10 @@ int bnx2x_vfpf_set_mac(struct bnx2x *bp)
 
 	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
 		BNX2X_ERR("vfpf SET MAC failed: %d\n", resp->hdr.status);
-		return -EINVAL;
+		rc = -EINVAL;
 	}
+out:
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
 
 	return 0;
 }
@@ -643,14 +678,16 @@ int bnx2x_vfpf_set_mcast(struct net_device *dev)
 	rc = bnx2x_send_msg2pf(bp, &resp->hdr.status, bp->vf2pf_mbox_mapping);
 	if (rc) {
 		BNX2X_ERR("Sending a message failed: %d\n", rc);
-		return rc;
+		goto out;
 	}
 
 	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
 		BNX2X_ERR("Set Rx mode/multicast failed: %d\n",
 			  resp->hdr.status);
-		return -EINVAL;
+		rc = -EINVAL;
 	}
+out:
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
 
 	return 0;
 }
@@ -689,7 +726,8 @@ int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp)
 		break;
 	default:
 		BNX2X_ERR("BAD rx mode (%d)\n", mode);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 
 	req->flags |= VFPF_SET_Q_FILTERS_RX_MASK_CHANGED;
@@ -708,8 +746,10 @@ int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp)
 
 	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
 		BNX2X_ERR("Set Rx mode failed: %d\n", resp->hdr.status);
-		return -EINVAL;
+		rc = -EINVAL;
 	}
+out:
+	bnx2x_vfpf_finalize(bp, &req->first_tlv);
 
 	return rc;
 }
-- 
1.8.1.227.g44fe835
