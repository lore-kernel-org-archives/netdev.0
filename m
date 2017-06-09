From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 2/2] bnx2x: Don't post statistics to malicious VFs
Date: Fri, 9 Jun 2017 17:17:02 +0300
Message-ID: <20170609141702.20688-3-Yuval.Mintz@cavium.com>
References: <20170609141702.20688-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mschmidt@redhat.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0066.outbound.protection.outlook.com ([104.47.32.66]:30848
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751646AbdFIORh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:17:37 -0400
In-Reply-To: <20170609141702.20688-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once firmware indicates that a given VF is malicious and until
that VF passes an FLR all bets are off - PF can't know anything
is happening to the VF [since VF can't communicate anything to its PF].
But PF is currently still periodically asking device to collect
statistics for the VF which might in turn fill logs by IOMMU blocking
memory access done by the VF's PCI function [in the case VF has unmapped
its buffers].

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 13 ++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  1 +
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 870ea00..9ca994d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -901,6 +901,8 @@ static void bnx2x_vf_flr(struct bnx2x *bp, struct bnx2x_virtf *vf)
 	/* release VF resources */
 	bnx2x_vf_free_resc(bp, vf);
 
+	vf->malicious = false;
+
 	/* re-open the mailbox */
 	bnx2x_vf_enable_mbx(bp, vf->abs_vfid);
 	return;
@@ -1822,9 +1824,11 @@ int bnx2x_iov_eq_sp_event(struct bnx2x *bp, union event_ring_elem *elem)
 		   vf->abs_vfid, qidx);
 		bnx2x_vf_handle_rss_update_eqe(bp, vf);
 	case EVENT_RING_OPCODE_VF_FLR:
-	case EVENT_RING_OPCODE_MALICIOUS_VF:
 		/* Do nothing for now */
 		return 0;
+	case EVENT_RING_OPCODE_MALICIOUS_VF:
+		vf->malicious = true;
+		return 0;
 	}
 
 	return 0;
@@ -1905,6 +1909,13 @@ void bnx2x_iov_adjust_stats_req(struct bnx2x *bp)
 			continue;
 		}
 
+		if (vf->malicious) {
+			DP_AND((BNX2X_MSG_IOV | BNX2X_MSG_STATS),
+			       "vf %d malicious so no stats for it\n",
+			       vf->abs_vfid);
+			continue;
+		}
+
 		DP_AND((BNX2X_MSG_IOV | BNX2X_MSG_STATS),
 		       "add addresses for vf %d\n", vf->abs_vfid);
 		for_each_vfq(vf, j) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 888d0b6..53466f6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -141,6 +141,7 @@ struct bnx2x_virtf {
 #define VF_RESET	3	/* VF FLR'd, pending cleanup */
 
 	bool flr_clnup_stage;	/* true during flr cleanup */
+	bool malicious;		/* true if FW indicated so, until FLR */
 
 	/* dma */
 	dma_addr_t fw_stat_map;
-- 
2.9.4
