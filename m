From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/5] bnx2x: Don't allow VFs to become promiscuous
Date: Sun, 23 Mar 2014 18:12:27 +0200
Message-ID: <1395591147-26350-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1395591147-26350-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46033 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752369AbaCWQNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 12:13:54 -0400
In-Reply-To: <1395591147-26350-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a VF's Rx Mode will be configured to support promiscuous mode
the PF will comply, causing the VF to actually become promiscuous.
This will enable the VF to see all unicast traffic which might be intended for
other VMs, which we believe should not be possible.

This patch will cause the hypervisor to ignore the VF's request for changes in
its Rx mode (other than disabling it), preventing it from becoming promiscuous.

Reported-by: Yoann Juet <yoann.juet@univ-nantes.fr>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 42 ++++++------------------
 1 file changed, 10 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index fe3737e..0622884 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -896,29 +896,16 @@ int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp)
 
 	DP(NETIF_MSG_IFUP, "Rx mode is %d\n", mode);
 
-	switch (mode) {
-	case BNX2X_RX_MODE_NONE: /* no Rx */
+	/* Ignore everything accept MODE_NONE */
+	if (mode  == BNX2X_RX_MODE_NONE) {
 		req->rx_mask = VFPF_RX_MASK_ACCEPT_NONE;
-		break;
-	case BNX2X_RX_MODE_NORMAL:
+	} else {
+		/* Current PF driver will not look at the specific flags,
+		 * but they are required when working with older drivers on hv.
+		 */
 		req->rx_mask = VFPF_RX_MASK_ACCEPT_MATCHED_MULTICAST;
 		req->rx_mask |= VFPF_RX_MASK_ACCEPT_MATCHED_UNICAST;
 		req->rx_mask |= VFPF_RX_MASK_ACCEPT_BROADCAST;
-		break;
-	case BNX2X_RX_MODE_ALLMULTI:
-		req->rx_mask = VFPF_RX_MASK_ACCEPT_ALL_MULTICAST;
-		req->rx_mask |= VFPF_RX_MASK_ACCEPT_MATCHED_UNICAST;
-		req->rx_mask |= VFPF_RX_MASK_ACCEPT_BROADCAST;
-		break;
-	case BNX2X_RX_MODE_PROMISC:
-		req->rx_mask = VFPF_RX_MASK_ACCEPT_ALL_UNICAST;
-		req->rx_mask |= VFPF_RX_MASK_ACCEPT_ALL_MULTICAST;
-		req->rx_mask |= VFPF_RX_MASK_ACCEPT_BROADCAST;
-		break;
-	default:
-		BNX2X_ERR("BAD rx mode (%d)\n", mode);
-		rc = -EINVAL;
-		goto out;
 	}
 
 	req->flags |= VFPF_SET_Q_FILTERS_RX_MASK_CHANGED;
@@ -939,7 +926,7 @@ int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp)
 		BNX2X_ERR("Set Rx mode failed: %d\n", resp->hdr.status);
 		rc = -EINVAL;
 	}
-out:
+
 	bnx2x_vfpf_finalize(bp, &req->first_tlv);
 
 	return rc;
@@ -1571,21 +1558,12 @@ static int bnx2x_vf_mbx_qfilters(struct bnx2x *bp, struct bnx2x_virtf *vf)
 		struct pf_vf_bulletin_content *bulletin =
 					BP_VF_BULLETIN(bp, vf->index);
 
-		/* covert VF-PF if mask to bnx2x accept flags */
-		if (msg->rx_mask & VFPF_RX_MASK_ACCEPT_MATCHED_UNICAST)
+		/* Ignore VF requested mode; instead set a regular mode */
+		if (msg->rx_mask !=  VFPF_RX_MASK_ACCEPT_NONE) {
 			__set_bit(BNX2X_ACCEPT_UNICAST, &accept);
-
-		if (msg->rx_mask & VFPF_RX_MASK_ACCEPT_MATCHED_MULTICAST)
 			__set_bit(BNX2X_ACCEPT_MULTICAST, &accept);
-
-		if (msg->rx_mask & VFPF_RX_MASK_ACCEPT_ALL_UNICAST)
-			__set_bit(BNX2X_ACCEPT_ALL_UNICAST, &accept);
-
-		if (msg->rx_mask & VFPF_RX_MASK_ACCEPT_ALL_MULTICAST)
-			__set_bit(BNX2X_ACCEPT_ALL_MULTICAST, &accept);
-
-		if (msg->rx_mask & VFPF_RX_MASK_ACCEPT_BROADCAST)
 			__set_bit(BNX2X_ACCEPT_BROADCAST, &accept);
+		}
 
 		/* A packet arriving the vf's mac should be accepted
 		 * with any vlan, unless a vlan has already been
-- 
1.8.1.227.g44fe835
