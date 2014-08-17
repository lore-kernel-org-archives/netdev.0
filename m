From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 6/9] bnx2x: Prevent IOV if no entries in CAM
Date: Sun, 17 Aug 2014 16:47:48 +0300
Message-ID: <1408283271-16176-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:44721 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392AbaHQNsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 09:48:17 -0400
In-Reply-To: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's possible there's a bad chip configuration which will result with
PCIe IOV capabilities, but with no available interrupts for VFs.

In such case, we want to gracefully prevent the PF from initializing its
IOV capabilities rather than encounter difficulties further along the way.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 5a88788..45ae68d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1125,7 +1125,7 @@ static int bnx2x_ari_enabled(struct pci_dev *dev)
 	return dev->bus->self && dev->bus->self->ari_enabled;
 }
 
-static void
+static int
 bnx2x_get_vf_igu_cam_info(struct bnx2x *bp)
 {
 	int sb_id;
@@ -1150,6 +1150,7 @@ bnx2x_get_vf_igu_cam_info(struct bnx2x *bp)
 		   GET_FIELD((val), IGU_REG_MAPPING_MEMORY_VECTOR));
 	}
 	DP(BNX2X_MSG_IOV, "vf_sbs_pool is %d\n", BP_VFDB(bp)->vf_sbs_pool);
+	return BP_VFDB(bp)->vf_sbs_pool;
 }
 
 static void __bnx2x_iov_free_vfdb(struct bnx2x *bp)
@@ -1314,7 +1315,11 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 	}
 
 	/* re-read the IGU CAM for VFs - index and abs_vfid must be set */
-	bnx2x_get_vf_igu_cam_info(bp);
+	if (!bnx2x_get_vf_igu_cam_info(bp)) {
+		BNX2X_ERR("No entries in IGU CAM for vfs\n");
+		err = -EINVAL;
+		goto failed;
+	}
 
 	/* allocate the queue arrays for all VFs */
 	bp->vfdb->vfqs = kzalloc(
-- 
1.7.1
