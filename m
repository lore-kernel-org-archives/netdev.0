From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Fix VF flr flow
Date: Tue, 21 Jan 2014 10:31:20 +0200
Message-ID: <1390293080-21276-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ariel Elior <ariele@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:51210 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbaAUIbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 03:31:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

When a VF originating from a given PF is flr-ed, that PF gets an interrupt
from the chip management and takes a part in the flr process.

This patch fixes several corner cases in which the driver performs its part
of the flr flow out-of-order, causing the FW to assert due to badly timed
messages received from the driver.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 61 ++++++++++++-----------
 1 file changed, 33 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index e7845e5..36e2222 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -617,7 +617,7 @@ static void bnx2x_vfop_vlan_mac(struct bnx2x *bp, struct bnx2x_virtf *vf)
 					   &vlan_mac->user_req.vlan_mac_flags,
 					   &vlan_mac->ramrod_flags);
 
-		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_DONE);
+		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
 
 	case BNX2X_VFOP_VLAN_MAC_CONFIG_SINGLE:
 		/* next state */
@@ -628,7 +628,7 @@ static void bnx2x_vfop_vlan_mac(struct bnx2x *bp, struct bnx2x_virtf *vf)
 		if (vfop->rc == -EEXIST)
 			vfop->rc = 0;
 
-		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_DONE);
+		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
 
 	case BNX2X_VFOP_VLAN_MAC_CHK_DONE:
 		vfop->rc = !!obj->raw.check_pending(&obj->raw);
@@ -645,7 +645,7 @@ static void bnx2x_vfop_vlan_mac(struct bnx2x *bp, struct bnx2x_virtf *vf)
 
 		set_bit(RAMROD_CONT, &vlan_mac->ramrod_flags);
 		vfop->rc = bnx2x_config_vlan_mac(bp, vlan_mac);
-		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_DONE);
+		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
 
 	case BNX2X_VFOP_VLAN_CONFIG_LIST:
 		/* next state */
@@ -657,7 +657,7 @@ static void bnx2x_vfop_vlan_mac(struct bnx2x *bp, struct bnx2x_virtf *vf)
 			set_bit(RAMROD_CONT, &vlan_mac->ramrod_flags);
 			vfop->rc = bnx2x_config_vlan_mac(bp, vlan_mac);
 		}
-		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_DONE);
+		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
 
 	default:
 		bnx2x_vfop_default(state);
@@ -1023,25 +1023,35 @@ static void bnx2x_vfop_qflr(struct bnx2x *bp, struct bnx2x_virtf *vf)
 	case BNX2X_VFOP_QFLR_CLR_VLAN:
 		/* vlan-clear-all: driver-only, don't consume credit */
 		vfop->state = BNX2X_VFOP_QFLR_CLR_MAC;
-		if (!validate_vlan_mac(bp, &bnx2x_vfq(vf, qid, vlan_obj)))
-			vfop->rc = bnx2x_vfop_vlan_delall_cmd(bp, vf, &cmd, qid,
-							      true);
-		if (vfop->rc)
-			goto op_err;
-		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
+
+		if (!validate_vlan_mac(bp, &bnx2x_vfq(vf, qid, vlan_obj))) {
+			/* the vlan_mac vfop will re-schedule us */
+			vfop->rc = bnx2x_vfop_vlan_delall_cmd(bp, vf, &cmd,
+							      qid, true);
+			if (vfop->rc)
+				goto op_err;
+			return;
+
+		} else {
+			/* need to reschedule ourselves */
+			bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
+		}
 
 	case BNX2X_VFOP_QFLR_CLR_MAC:
 		/* mac-clear-all: driver only consume credit */
 		vfop->state = BNX2X_VFOP_QFLR_TERMINATE;
-		if (!validate_vlan_mac(bp, &bnx2x_vfq(vf, qid, mac_obj)))
-			vfop->rc = bnx2x_vfop_mac_delall_cmd(bp, vf, &cmd, qid,
-							     true);
-		DP(BNX2X_MSG_IOV,
-		   "VF[%d] vfop->rc after bnx2x_vfop_mac_delall_cmd was %d",
-		   vf->abs_vfid, vfop->rc);
-		if (vfop->rc)
-			goto op_err;
-		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
+		if (!validate_vlan_mac(bp, &bnx2x_vfq(vf, qid, mac_obj))) {
+			/* the vlan_mac vfop will re-schedule us */
+			vfop->rc = bnx2x_vfop_mac_delall_cmd(bp, vf, &cmd,
+							     qid, true);
+			if (vfop->rc)
+				goto op_err;
+			return;
+
+		} else {
+			/* need to reschedule ourselves */
+			bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);
+		}
 
 	case BNX2X_VFOP_QFLR_TERMINATE:
 		qstate = &vfop->op_p->qctor.qstate;
@@ -2372,8 +2382,9 @@ int bnx2x_iov_eq_sp_event(struct bnx2x *bp, union event_ring_elem *elem)
 		goto get_vf;
 	case EVENT_RING_OPCODE_MALICIOUS_VF:
 		abs_vfid = elem->message.data.malicious_vf_event.vf_id;
-		DP(BNX2X_MSG_IOV, "Got VF MALICIOUS notification abs_vfid=%d err_id=0x%x\n",
-		   abs_vfid, elem->message.data.malicious_vf_event.err_id);
+		BNX2X_ERR("Got VF MALICIOUS notification abs_vfid=%d err_id=0x%x\n",
+			  abs_vfid,
+			  elem->message.data.malicious_vf_event.err_id);
 		goto get_vf;
 	default:
 		return 1;
@@ -2425,15 +2436,9 @@ get_vf:
 		bnx2x_vf_handle_filters_eqe(bp, vf);
 		break;
 	case EVENT_RING_OPCODE_VF_FLR:
-		DP(BNX2X_MSG_IOV, "got VF [%d] FLR notification\n",
-		   vf->abs_vfid);
-		/* Do nothing for now */
-		break;
 	case EVENT_RING_OPCODE_MALICIOUS_VF:
-		DP(BNX2X_MSG_IOV, "Got VF MALICIOUS notification abs_vfid=%d error id %x\n",
-		   abs_vfid, elem->message.data.malicious_vf_event.err_id);
 		/* Do nothing for now */
-		break;
+		return 0;
 	}
 	/* SRIOV: reschedule any 'in_progress' operations */
 	bnx2x_iov_sp_event(bp, cid, false);
-- 
1.8.1.227.g44fe835
