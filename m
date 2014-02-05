From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Allow VF rss on higher PFs
Date: Wed, 5 Feb 2014 16:07:12 +0200
Message-ID: <1391609232-875-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:18459 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbaBEOHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 09:07:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x driver uses incorrect PF identifier to configure (in HW) the VF
interrupt scheme; As a result, in multi-function mode the configuration
for PFs with a high index (4+) will overflow and the PF will erroneously
configure a single ISR scheme for its VFs.
As a result, if such a VF uses multiple queues, interrupt generation will
stop after VF receives an Rx packet or sends a Tx packet on a queue
other than queue[0].

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index aec5ef2..e42f48d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1446,12 +1446,12 @@ static void bnx2x_vf_igu_reset(struct bnx2x *bp, struct bnx2x_virtf *vf)
 	if (vf->cfg_flags & VF_CFG_INT_SIMD)
 		val |= IGU_VF_CONF_SINGLE_ISR_EN;
 	val &= ~IGU_VF_CONF_PARENT_MASK;
-	val |= BP_FUNC(bp) << IGU_VF_CONF_PARENT_SHIFT;	/* parent PF */
+	val |= (BP_ABS_FUNC(bp) >> 1) << IGU_VF_CONF_PARENT_SHIFT;
 	REG_WR(bp, IGU_REG_VF_CONFIGURATION, val);
 
 	DP(BNX2X_MSG_IOV,
-	   "value in IGU_REG_VF_CONFIGURATION of vf %d after write %x\n",
-	   vf->abs_vfid, REG_RD(bp, IGU_REG_VF_CONFIGURATION));
+	   "value in IGU_REG_VF_CONFIGURATION of vf %d after write is 0x%08x\n",
+	   vf->abs_vfid, val);
 
 	bnx2x_pretend_func(bp, BP_ABS_FUNC(bp));
 
-- 
1.8.1.227.g44fe835
