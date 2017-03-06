From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 3/7 v2] bnx2x: fix possible overrun of VFPF multicast
 addresses array
Date: Mon, 6 Mar 2017 15:45:40 +0100
Message-ID: <186b89fe-dbf4-ecc2-7c0c-0f2c37b846b8@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
 <20170303160834.4125-4-mschmidt@redhat.com>
 <BL2PR07MB230637FFDAFE26D2052B269F8D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753133AbdCFOwN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 09:52:13 -0500
In-Reply-To: <BL2PR07MB230637FFDAFE26D2052B269F8D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is too late to check for the limit of the number of VF multicast
addresses after they have already been copied to the req->multicast[]
array, possibly overflowing it.

Do the check before copying.

Checking early also avoids having to (and forgetting to) unlock
vf2pf_mutex.

While we're looking at the error paths in the function, also return
an error code from it when the PF responds with an error. Even though
the caller ignores it.

v2: Move the check before bnx2x_vfpf_prep() as suggested by Yuval.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
  drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 22 ++++++++++------------
  1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index bfae300..2b2ae92 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -864,46 +864,44 @@ int bnx2x_vfpf_config_rss(struct bnx2x *bp,
  }
  
  int bnx2x_vfpf_set_mcast(struct net_device *dev)
  {
  	struct bnx2x *bp = netdev_priv(dev);
  	struct vfpf_set_q_filters_tlv *req = &bp->vf2pf_mbox->req.set_q_filters;
  	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
-	int rc, i = 0;
+	int rc = 0, i = 0;
  	struct netdev_hw_addr *ha;
  
  	if (bp->state != BNX2X_STATE_OPEN) {
  		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
  		return -EINVAL;
  	}
  
+	/* We support PFVF_MAX_MULTICAST_PER_VF mcast addresses tops */
+	if (netdev_mc_count(dev) > PFVF_MAX_MULTICAST_PER_VF) {
+		DP(NETIF_MSG_IFUP,
+		   "VF supports not more than %d multicast MAC addresses\n",
+		   PFVF_MAX_MULTICAST_PER_VF);
+		return -EINVAL;
+	}
+
  	/* clear mailbox and prep first tlv */
  	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_SET_Q_FILTERS,
  			sizeof(*req));
  
  	/* Get Rx mode requested */
  	DP(NETIF_MSG_IFUP, "dev->flags = %x\n", dev->flags);
  
  	netdev_for_each_mc_addr(ha, dev) {
  		DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
  		   bnx2x_mc_addr(ha));
  		memcpy(req->multicast[i], bnx2x_mc_addr(ha), ETH_ALEN);
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
  
  	/* add list termination tlv */
  	bnx2x_add_tlv(bp, req, req->first_tlv.tl.length, CHANNEL_TLV_LIST_END,
  		      sizeof(struct channel_list_end_tlv));
@@ -920,15 +918,15 @@ int bnx2x_vfpf_set_mcast(struct net_device *dev)
  		BNX2X_ERR("Set Rx mode/multicast failed: %d\n",
  			  resp->hdr.status);
  		rc = -EINVAL;
  	}
  out:
  	bnx2x_vfpf_finalize(bp, &req->first_tlv);
  
-	return 0;
+	return rc;
  }
  
  /* request pf to add a vlan for the vf */
  int bnx2x_vfpf_update_vlan(struct bnx2x *bp, u16 vid, u8 vf_qid, bool add)
  {
  	struct vfpf_set_q_filters_tlv *req = &bp->vf2pf_mbox->req.set_q_filters;
  	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
-- 
2.9.3
