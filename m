From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/5] bnx2x: Enhance MAC configuration for VFs
Date: Wed, 24 Apr 2013 14:45:00 +0300
Message-ID: <1366803902-17870-4-git-send-email-yuvalmin@broadcom.com>
References: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1067 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757854Ab3DXMq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 08:46:29 -0400
In-Reply-To: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Improved support for adding/removing vf mac addresses.

This includes the case where HyperVisor forced the address (sampled from
bulletin board), and the case where it did not in which the VF can
configure its own mac address.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |  3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 18 +++++++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  5 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 19 ++++++++++++++-----
 4 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 5a815ce..e8ed78f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2664,7 +2664,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (IS_PF(bp))
 		rc = bnx2x_set_eth_mac(bp, true);
 	else /* vf */
-		rc = bnx2x_vfpf_set_mac(bp);
+		rc = bnx2x_vfpf_config_mac(bp, bp->dev->dev_addr, bp->fp->index,
+					   true);
 	if (rc) {
 		BNX2X_ERR("Setting Ethernet MAC failed\n");
 		LOAD_ERROR_EXIT(bp, load_error3);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1cc4af5..9b4fb20 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7930,8 +7930,6 @@ int bnx2x_del_all_macs(struct bnx2x *bp,
 
 int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 {
-	unsigned long ramrod_flags = 0;
-
 	if (is_zero_ether_addr(bp->dev->dev_addr) &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
 		DP(NETIF_MSG_IFUP | NETIF_MSG_IFDOWN,
@@ -7939,12 +7937,18 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 		return 0;
 	}
 
-	DP(NETIF_MSG_IFUP, "Adding Eth MAC\n");
+	if (IS_PF(bp)) {
+		unsigned long ramrod_flags = 0;
 
-	__set_bit(RAMROD_COMP_WAIT, &ramrod_flags);
-	/* Eth MAC is set on RSS leading client (fp[0]) */
-	return bnx2x_set_mac_one(bp, bp->dev->dev_addr, &bp->sp_objs->mac_obj,
-				 set, BNX2X_ETH_MAC, &ramrod_flags);
+		DP(NETIF_MSG_IFUP, "Adding Eth MAC\n");
+		__set_bit(RAMROD_COMP_WAIT, &ramrod_flags);
+		return bnx2x_set_mac_one(bp, bp->dev->dev_addr,
+					 &bp->sp_objs->mac_obj, set,
+					 BNX2X_ETH_MAC, &ramrod_flags);
+	} else { /* vf */
+		return bnx2x_vfpf_config_mac(bp, bp->dev->dev_addr,
+					     bp->fp->index, true);
+	}
 }
 
 int bnx2x_setup_leading(struct bnx2x *bp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index d4b17b7..d67ddc5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -733,7 +733,7 @@ int bnx2x_vfpf_init(struct bnx2x *bp);
 void bnx2x_vfpf_close_vf(struct bnx2x *bp);
 int bnx2x_vfpf_setup_q(struct bnx2x *bp, int fp_idx);
 int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx);
-int bnx2x_vfpf_set_mac(struct bnx2x *bp);
+int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8 *addr, u8 vf_qid, bool set);
 int bnx2x_vfpf_set_mcast(struct net_device *dev);
 int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp);
 
@@ -794,7 +794,8 @@ static inline int bnx2x_vfpf_init(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_vfpf_close_vf(struct bnx2x *bp) {}
 static inline int bnx2x_vfpf_setup_q(struct bnx2x *bp, int fp_idx) {return 0; }
 static inline int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx) {return 0; }
-static inline int bnx2x_vfpf_set_mac(struct bnx2x *bp) {return 0; }
+static inline int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8 *addr,
+					u8 vf_qid, bool set) {return 0; }
 static inline int bnx2x_vfpf_set_mcast(struct net_device *dev) {return 0; }
 static inline int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp) {return 0; }
 static inline int bnx2x_iov_nic_init(struct bnx2x *bp) {return 0; }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 90fbf9c..928b074 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -406,6 +406,9 @@ void bnx2x_vfpf_close_vf(struct bnx2x *bp)
 	for_each_queue(bp, i)
 		bnx2x_vfpf_teardown_queue(bp, i);
 
+	/* remove mac */
+	bnx2x_vfpf_config_mac(bp, bp->dev->dev_addr, bp->fp->index, false);
+
 	/* clear mailbox and prep first tlv */
 	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_CLOSE, sizeof(*req));
 
@@ -561,10 +564,11 @@ out:
 }
 
 /* request pf to add a mac for the vf */
-int bnx2x_vfpf_set_mac(struct bnx2x *bp)
+int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8 *addr, u8 vf_qid, bool set)
 {
 	struct vfpf_set_q_filters_tlv *req = &bp->vf2pf_mbox->req.set_q_filters;
 	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
+	struct pf_vf_bulletin_content bulletin = bp->pf2vf_bulletin->content;
 	int rc = 0;
 
 	/* clear mailbox and prep first tlv */
@@ -572,16 +576,18 @@ int bnx2x_vfpf_set_mac(struct bnx2x *bp)
 			sizeof(*req));
 
 	req->flags = VFPF_SET_Q_FILTERS_MAC_VLAN_CHANGED;
-	req->vf_qid = 0;
+	req->vf_qid = vf_qid;
 	req->n_mac_vlan_filters = 1;
-	req->filters[0].flags =
-		VFPF_Q_FILTER_DEST_MAC_VALID | VFPF_Q_FILTER_SET_MAC;
+
+	req->filters[0].flags = VFPF_Q_FILTER_DEST_MAC_VALID;
+	if (set)
+		req->filters[0].flags |= VFPF_Q_FILTER_SET_MAC;
 
 	/* sample bulletin board for new mac */
 	bnx2x_sample_bulletin(bp);
 
 	/* copy mac from device to request */
-	memcpy(req->filters[0].mac, bp->dev->dev_addr, ETH_ALEN);
+	memcpy(req->filters[0].mac, addr, ETH_ALEN);
 
 	/* add list termination tlv */
 	bnx2x_add_tlv(bp, req, req->first_tlv.tl.length, CHANNEL_TLV_LIST_END,
@@ -602,6 +608,9 @@ int bnx2x_vfpf_set_mac(struct bnx2x *bp)
 		DP(BNX2X_MSG_IOV,
 		   "vfpf SET MAC failed. Check bulletin board for new posts\n");
 
+		/* copy mac from bulletin to device */
+		memcpy(bp->dev->dev_addr, bulletin.mac, ETH_ALEN);
+
 		/* check if bulletin board was updated */
 		if (bnx2x_sample_bulletin(bp) == PFVF_BULLETIN_UPDATED) {
 			/* copy mac from device to request */
-- 
1.8.1.227.g44fe835
