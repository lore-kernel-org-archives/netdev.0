From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 3/7] bnx2x: fix possible overrun of VFPF multicast addresses array
Date: Fri,  3 Mar 2017 17:08:30 +0100
Message-ID: <20170303160834.4125-4-mschmidt@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62742 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdCCQIr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:47 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is too late to check for the limit of the number of VF multicast
addresses after they have already been copied to the req->multicast[]
array, possibly overflowing it.

Do the check before copying.

Also fix the error path to not skip unlocking vf2pf_mutex.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index bfae300cf2..c2d327d9df 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -868,7 +868,7 @@ int bnx2x_vfpf_set_mcast(struct net_device *dev)
 	struct bnx2x *bp = netdev_priv(dev);
 	struct vfpf_set_q_filters_tlv *req = &bp->vf2pf_mbox->req.set_q_filters;
 	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
-	int rc, i = 0;
+	int rc = 0, i = 0;
 	struct netdev_hw_addr *ha;
 
 	if (bp->state != BNX2X_STATE_OPEN) {
@@ -883,6 +883,15 @@ int bnx2x_vfpf_set_mcast(struct net_device *dev)
 	/* Get Rx mode requested */
 	DP(NETIF_MSG_IFUP, "dev->flags = %x\n", dev->flags);
 
+	/* We support PFVF_MAX_MULTICAST_PER_VF mcast addresses tops */
+	if (netdev_mc_count(dev) > PFVF_MAX_MULTICAST_PER_VF) {
+		DP(NETIF_MSG_IFUP,
+		   "VF supports not more than %d multicast MAC addresses\n",
+		   PFVF_MAX_MULTICAST_PER_VF);
+		rc = -EINVAL;
+		goto out;
+	}
+
 	netdev_for_each_mc_addr(ha, dev) {
 		DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
 		   bnx2x_mc_addr(ha));
@@ -890,16 +899,6 @@ int bnx2x_vfpf_set_mcast(struct net_device *dev)
 		i++;
 	}
 
-	/* We support four PFVF_MAX_MULTICAST_PER_VF mcast
-	  * addresses tops
-	  */
-	if (i >= PFVF_MAX_MULTICAST_PER_VF) {
-		DP(NETIF_MSG_IFUP,
-		   "VF supports not more than %d multicast MAC addresses\n",
-		   PFVF_MAX_MULTICAST_PER_VF);
-		return -EINVAL;
-	}
-
 	req->n_multicast = i;
 	req->flags |= VFPF_SET_Q_FILTERS_MULTICAST_CHANGED;
 	req->vf_qid = 0;
@@ -924,7 +923,7 @@ int bnx2x_vfpf_set_mcast(struct net_device *dev)
 out:
 	bnx2x_vfpf_finalize(bp, &req->first_tlv);
 
-	return 0;
+	return rc;
 }
 
 /* request pf to add a vlan for the vf */
-- 
2.9.3
