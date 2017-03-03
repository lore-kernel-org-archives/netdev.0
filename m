From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 7/7] bnx2x: add missing configuration of VF VLAN filters
Date: Fri,  3 Mar 2017 17:08:34 +0100
Message-ID: <20170303160834.4125-8-mschmidt@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44208 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752115AbdCCQIq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:46 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configuring VLANs from the VF side had no effect, because the PF ignored
filters of type VFPF_VLAN_FILTER in the VF-PF message.

Add the missing filter type to configure.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index c2d327d9df..76a4668c50 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1777,6 +1777,23 @@ static int bnx2x_vf_mbx_qfilters(struct bnx2x *bp, struct bnx2x_virtf *vf)
 				goto op_err;
 		}
 
+		/* build vlan list */
+		fl = NULL;
+
+		rc = bnx2x_vf_mbx_macvlan_list(bp, vf, msg, &fl,
+					       VFPF_VLAN_FILTER);
+		if (rc)
+			goto op_err;
+
+		if (fl) {
+			/* set vlan list */
+			rc = bnx2x_vf_mac_vlan_config_list(bp, vf, fl,
+							   msg->vf_qid,
+							   false);
+			if (rc)
+				goto op_err;
+		}
+
 	}
 
 	if (msg->flags & VFPF_SET_Q_FILTERS_RX_MASK_CHANGED) {
-- 
2.9.3
