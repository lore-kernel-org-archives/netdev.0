From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH 07/22] bnx2x: Support ndo_set_rxmode in VF driver
Date: Tue, 13 Nov 2012 18:17:16 +0200
Message-ID: <1352823451-27042-8-git-send-email-ariele@broadcom.com>
References: <1352823451-27042-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1030 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754821Ab2KMQP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 11:15:29 -0500
In-Reply-To: <1352823451-27042-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VF driver uses the 'q_filter' request in the VF <-> PF channel to
have the PF configure the requested rxmode to device. ndo_set_rxmode
is called under bottom half lock, so sleeping until the response
arrives over the VF <-> PF channel is out of the question. For this reason
the VF driver returns from the ndo after scheduling a work item, which
in turn processes the rx mode request and adds the classification
information through the VF <-> PF channel accordingly.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    5 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  177 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h |    7 +
 3 files changed, 183 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index de6b9d4..0ed35e3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1194,6 +1194,8 @@ enum {
 	BNX2X_SP_RTNL_TX_TIMEOUT,
 	BNX2X_SP_RTNL_AFEX_F_UPDATE,
 	BNX2X_SP_RTNL_FAN_FAILURE,
+	BNX2X_SP_RTNL_VFPF_MCAST,
+	BNX2X_SP_RTNL_VFPF_STORM_RX_MODE,
 };
 
 
@@ -2231,6 +2233,9 @@ void bnx2x_vfpf_close_vf(struct bnx2x *bp);
 int bnx2x_vfpf_setup_q(struct bnx2x *bp, int fp_idx);
 int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx);
 int bnx2x_vfpf_set_mac(struct bnx2x *bp);
+int bnx2x_vfpf_set_mcast(struct net_device *dev);
+int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp);
+
 int bnx2x_nic_load_analyze_req(struct bnx2x *bp, u32 load_code);
 /* Congestion management fairness mode */
 #define CMNG_FNS_NONE		0
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fe7e5ab..c19c19d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9380,6 +9380,19 @@ sp_rtnl_not_reset:
 		bnx2x_close(bp->dev);
 	}
 
+	if (test_and_clear_bit(BNX2X_SP_RTNL_VFPF_MCAST, &bp->sp_rtnl_state)) {
+		DP(BNX2X_MSG_SP,
+		   "sending set mcast vf pf channel message from rtnl sp-task\n");
+		bnx2x_vfpf_set_mcast(bp->dev);
+	}
+
+	if (test_and_clear_bit(BNX2X_SP_RTNL_VFPF_STORM_RX_MODE,
+			       &bp->sp_rtnl_state)) {
+		DP(BNX2X_MSG_SP,
+		   "sending set storm rx mode vf pf channel message from rtnl sp-task\n");
+		bnx2x_vfpf_storm_rx_mode(bp);
+	}
+
 sp_rtnl_exit:
 	rtnl_unlock();
 }
@@ -11399,12 +11412,25 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 		  CHIP_IS_E1(bp)))
 		rx_mode = BNX2X_RX_MODE_ALLMULTI;
 	else {
-		/* some multicasts */
-		if (bnx2x_set_mc_list(bp) < 0)
-			rx_mode = BNX2X_RX_MODE_ALLMULTI;
+		if (IS_PF(bp)) {
+			/* some multicasts */
+			if (bnx2x_set_mc_list(bp) < 0)
+				rx_mode = BNX2X_RX_MODE_ALLMULTI;
 
-		if (bnx2x_set_uc_list(bp) < 0)
-			rx_mode = BNX2X_RX_MODE_PROMISC;
+			if (bnx2x_set_uc_list(bp) < 0)
+				rx_mode = BNX2X_RX_MODE_PROMISC;
+		} else {
+			/* configuring mcast to a vf involves sleeping (when we
+			 * wait for the pf's response). Since this function is
+			 * called from non sleepable context we must schedule
+			 * a work item for this purpose
+			 */
+			smp_mb__before_clear_bit();
+			set_bit(BNX2X_SP_RTNL_VFPF_MCAST,
+				&bp->sp_rtnl_state);
+			smp_mb__after_clear_bit();
+			schedule_delayed_work(&bp->sp_rtnl_task, 0);
+		}
 	}
 
 	bp->rx_mode = rx_mode;
@@ -11418,7 +11444,20 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 		return;
 	}
 
-	bnx2x_set_storm_rx_mode(bp);
+	if (IS_PF(bp)) {
+		bnx2x_set_storm_rx_mode(bp);
+	} else {
+		/* configuring rx mode to storms in a vf involves sleeping (when
+		 * we wait for the pf's response). Since this function is
+		 * called from non sleepable context we must schedule
+		 * a work item for this purpose
+		 */
+		smp_mb__before_clear_bit();
+		set_bit(BNX2X_SP_RTNL_VFPF_STORM_RX_MODE,
+			&bp->sp_rtnl_state);
+		smp_mb__after_clear_bit();
+		schedule_delayed_work(&bp->sp_rtnl_task, 0);
+	}
 }
 
 /* called with rtnl_lock */
@@ -13611,3 +13650,129 @@ int bnx2x_vfpf_set_mac(struct bnx2x *bp)
 
 	return 0;
 }
+
+int bnx2x_vfpf_set_mcast(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	struct vfpf_set_q_filters_tlv *req = &bp->vf2pf_mbox->req.set_q_filters;
+	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
+	int rc, i = 0;
+	struct netdev_hw_addr *ha;
+
+	if (bp->state != BNX2X_STATE_OPEN) {
+		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
+		return -EINVAL;
+	}
+
+	/* clear mailbox and prep first tlv */
+	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_SET_Q_FILTERS,
+			sizeof(*req));
+
+	/* Get Rx mode requested */
+	DP(NETIF_MSG_IFUP, "dev->flags = %x\n", dev->flags);
+
+	netdev_for_each_mc_addr(ha, dev) {
+		DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
+		   bnx2x_mc_addr(ha));
+		memcpy(req->multicast[i], bnx2x_mc_addr(ha),
+		       sizeof(req->multicast[i]));
+
+		i++;
+	}
+
+	/* We support four PFVF_MAX_MULTICAST_PER_VF mcast
+	 * addresses tops
+	 */
+	if (i >= PFVF_MAX_MULTICAST_PER_VF) {
+		DP(NETIF_MSG_IFUP,
+		   "VF supports not more than %d multicast MAC addresses\n",
+		   PFVF_MAX_MULTICAST_PER_VF);
+		return -EINVAL;
+	}
+
+	req->n_multicast = i;
+	req->flags |= VFPF_SET_Q_FILTERS_MULTICAST_CHANGED;
+
+	req->vf_qid = 0;
+
+	/* add list termination tlv */
+	bnx2x_add_tlv(bp, req, req->first_tlv.tl.length, CHANNEL_TLV_LIST_END,
+		      sizeof(struct channel_list_end_tlv));
+
+	/* output tlvs list */
+	bnx2x_dp_tlv_list(bp, req);
+
+	rc = bnx2x_send_msg2pf(bp, &resp->hdr.status, bp->vf2pf_mbox_mapping);
+	if (rc) {
+		BNX2X_ERR("Sending a message failed: %d\n", rc);
+		return rc;
+	}
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		BNX2X_ERR("Set Rx mode/multicast failed: %d\n",
+			  resp->hdr.status);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp)
+{
+	int mode = bp->rx_mode;
+	struct vfpf_set_q_filters_tlv *req = &bp->vf2pf_mbox->req.set_q_filters;
+	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
+	int rc;
+
+
+	/* clear mailbox and prep first tlv */
+	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_SET_Q_FILTERS,
+			sizeof(*req));
+
+	DP(NETIF_MSG_IFUP, "Rx mode is %d\n", mode);
+
+	switch (mode) {
+	case BNX2X_RX_MODE_NONE: /* no Rx */
+		req->rx_mask = VFPF_RX_MASK_ACCEPT_NONE;
+		break;
+	case BNX2X_RX_MODE_NORMAL:
+		req->rx_mask = VFPF_RX_MASK_ACCEPT_MATCHED_MULTICAST;
+		req->rx_mask |= VFPF_RX_MASK_ACCEPT_MATCHED_UNICAST;
+		req->rx_mask |= VFPF_RX_MASK_ACCEPT_BROADCAST;
+		break;
+	case BNX2X_RX_MODE_ALLMULTI:
+		req->rx_mask = VFPF_RX_MASK_ACCEPT_ALL_MULTICAST;
+		req->rx_mask |= VFPF_RX_MASK_ACCEPT_MATCHED_UNICAST;
+		req->rx_mask |= VFPF_RX_MASK_ACCEPT_BROADCAST;
+		break;
+	case BNX2X_RX_MODE_PROMISC:
+		req->rx_mask = VFPF_RX_MASK_ACCEPT_ALL_UNICAST;
+		req->rx_mask |= VFPF_RX_MASK_ACCEPT_ALL_MULTICAST;
+		req->rx_mask |= VFPF_RX_MASK_ACCEPT_BROADCAST;
+		break;
+	default:
+		BNX2X_ERR("BAD rx mode (%d)\n", mode);
+		return -EINVAL;
+	}
+
+	req->flags |= VFPF_SET_Q_FILTERS_RX_MASK_CHANGED;
+	req->vf_qid = 0;
+
+	/* add list termination tlv */
+	bnx2x_add_tlv(bp, req, req->first_tlv.tl.length, CHANNEL_TLV_LIST_END,
+		      sizeof(struct channel_list_end_tlv));
+
+	/* output tlvs list */
+	bnx2x_dp_tlv_list(bp, req);
+
+	rc = bnx2x_send_msg2pf(bp, &resp->hdr.status, bp->vf2pf_mbox_mapping);
+	if (rc)
+		BNX2X_ERR("Sending a message failed: %d\n", rc);
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS) {
+		BNX2X_ERR("Set Rx mode failed: %d\n", resp->hdr.status);
+		return -EINVAL;
+	}
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index a482d69..7fe5b83 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -53,6 +53,13 @@ struct hw_sb_info {
 #define VFPF_QUEUE_DROP_TTL0		(1 << 2)
 #define VFPF_QUEUE_DROP_UDP_CS_ERR	(1 << 3)
 
+#define VFPF_RX_MASK_ACCEPT_NONE		0x00000000
+#define VFPF_RX_MASK_ACCEPT_MATCHED_UNICAST	0x00000001
+#define VFPF_RX_MASK_ACCEPT_MATCHED_MULTICAST	0x00000002
+#define VFPF_RX_MASK_ACCEPT_ALL_UNICAST		0x00000004
+#define VFPF_RX_MASK_ACCEPT_ALL_MULTICAST	0x00000008
+#define VFPF_RX_MASK_ACCEPT_BROADCAST		0x00000010
+
 enum {
 	PFVF_STATUS_WAITING = 0,
 	PFVF_STATUS_SUCCESS,
-- 
1.7.9.GIT
