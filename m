From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 4/9] bnx2x: Semantic Validate vlan/mac changes
Date: Wed, 12 Feb 2014 18:19:52 +0200
Message-ID: <1392221997-25525-5-git-send-email-yuvalmin@broadcom.com>
References: <1392221997-25525-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:19877 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaBLQUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:20:10 -0500
In-Reply-To: <1392221997-25525-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is purely semantic - break the flow in which PF validates the VF
classification filtering requirement is valid into several sub-functions
for better readable code.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 51 +++++++++++++++++++-----
 1 file changed, 42 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 3fa6c2a..ebad48a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1694,16 +1694,12 @@ static int bnx2x_vfop_mbx_qfilters_cmd(struct bnx2x *bp,
 	return -ENOMEM;
 }
 
-static void bnx2x_vf_mbx_set_q_filters(struct bnx2x *bp,
-				       struct bnx2x_virtf *vf,
-				       struct bnx2x_vf_mbx *mbx)
+static int bnx2x_filters_validate_mac(struct bnx2x *bp,
+				      struct bnx2x_virtf *vf,
+				      struct vfpf_set_q_filters_tlv *filters)
 {
-	struct vfpf_set_q_filters_tlv *filters = &mbx->msg->req.set_q_filters;
 	struct pf_vf_bulletin_content *bulletin = BP_VF_BULLETIN(bp, vf->index);
-	struct bnx2x_vfop_cmd cmd = {
-		.done = bnx2x_vf_mbx_resp,
-		.block = false,
-	};
+	int rc = 0;
 
 	/* if a mac was already set for this VF via the set vf mac ndo, we only
 	 * accept mac configurations of that mac. Why accept them at all?
@@ -1716,6 +1712,7 @@ static void bnx2x_vf_mbx_set_q_filters(struct bnx2x *bp,
 			BNX2X_ERR("VF[%d] requested the addition of multiple macs after set_vf_mac ndo was called\n",
 				  vf->abs_vfid);
 			vf->op_rc = -EPERM;
+			rc = -EPERM;
 			goto response;
 		}
 
@@ -1726,9 +1723,22 @@ static void bnx2x_vf_mbx_set_q_filters(struct bnx2x *bp,
 				  vf->abs_vfid);
 
 			vf->op_rc = -EPERM;
+			rc = -EPERM;
 			goto response;
 		}
 	}
+
+response:
+	return rc;
+}
+
+static int bnx2x_filters_validate_vlan(struct bnx2x *bp,
+				       struct bnx2x_virtf *vf,
+				       struct vfpf_set_q_filters_tlv *filters)
+{
+	struct pf_vf_bulletin_content *bulletin = BP_VF_BULLETIN(bp, vf->index);
+	int rc = 0;
+
 	/* if vlan was set by hypervisor we don't allow guest to config vlan */
 	if (bulletin->valid_bitmap & 1 << VLAN_VALID) {
 		int i;
@@ -1740,13 +1750,36 @@ static void bnx2x_vf_mbx_set_q_filters(struct bnx2x *bp,
 				BNX2X_ERR("VF[%d] attempted to configure vlan but one was already set by Hypervisor. Aborting request\n",
 					  vf->abs_vfid);
 				vf->op_rc = -EPERM;
+				rc = -EPERM;
 				goto response;
 			}
 		}
 	}
 
 	/* verify vf_qid */
-	if (filters->vf_qid > vf_rxq_count(vf))
+	if (filters->vf_qid > vf_rxq_count(vf)) {
+		rc = -EPERM;
+		goto response;
+	}
+
+response:
+	return rc;
+}
+
+static void bnx2x_vf_mbx_set_q_filters(struct bnx2x *bp,
+				       struct bnx2x_virtf *vf,
+				       struct bnx2x_vf_mbx *mbx)
+{
+	struct vfpf_set_q_filters_tlv *filters = &mbx->msg->req.set_q_filters;
+	struct bnx2x_vfop_cmd cmd = {
+		.done = bnx2x_vf_mbx_resp,
+		.block = false,
+	};
+
+	if (bnx2x_filters_validate_mac(bp, vf, filters))
+		goto response;
+
+	if (bnx2x_filters_validate_vlan(bp, vf, filters))
 		goto response;
 
 	DP(BNX2X_MSG_IOV, "VF[%d] Q_FILTERS: queue[%d]\n",
-- 
1.8.1.227.g44fe835
