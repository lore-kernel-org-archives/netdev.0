From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] qed: FLR of active VFs might lead to FW assert
Date: Mon, 22 Aug 2016 12:03:29 +0300
Message-ID: <1471856609-8519-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:64199 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753397AbcHVJDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 05:03:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver never bothered marking the VF's vport with the VF's sw_fid.
As a result, FLR flows are not going to clean those vports.

If the vport was active when FLRed, re-activating it would lead
to a FW assertion.

Fixes: dacd88d6f6851 ("qed: IOV l2 functionality")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed.h | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 35e5377..45ab746 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -561,9 +561,18 @@ struct qed_dev {
 static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
 					u32 concrete_fid)
 {
+	u8 vfid = GET_FIELD(concrete_fid, PXP_CONCRETE_FID_VFID);
 	u8 pfid = GET_FIELD(concrete_fid, PXP_CONCRETE_FID_PFID);
+	u8 vf_valid = GET_FIELD(concrete_fid,
+				PXP_CONCRETE_FID_VFVALID);
+	u8 sw_fid;
 
-	return pfid;
+	if (vf_valid)
+		sw_fid = vfid + MAX_NUM_PFS;
+	else
+		sw_fid = pfid;
+
+	return sw_fid;
 }
 
 #define PURE_LB_TC 8
-- 
1.9.3
