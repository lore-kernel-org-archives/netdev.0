From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Fix SRIOV on big-endian architecture.
Date: Tue, 11 Jul 2017 13:05:36 -0400
Message-ID: <1499792736-28697-4-git-send-email-michael.chan@broadcom.com>
References: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36752 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754297AbdGKRFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 13:05:51 -0400
Received: by mail-qk0-f182.google.com with SMTP id p21so9184319qke.3
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 10:05:50 -0700 (PDT)
In-Reply-To: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PF driver sets up a list of firmware commands from the VF driver that
needs to be forwarded to the PF for approval.  This list is a 256-bit
bitmap.  The code that sets up the bitmap falls apart on big-endian
architecture.  __set_bit() does not work because it operates on long types
whereas the firmware interface is defined in u32 types, causing bits in
the wrong 32-bit word to be set.

Fix it by setting the proper bits on an array of u32.

Fixes: de68f5de5651 ("bnxt_en: Fix bitmap declaration to work on 32-bit arches.")
Reported-by: Shannon Nelson <shannon.nelson@oracle.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index d9830d0..e7c8539 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3458,13 +3458,18 @@ static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 	req.ver_upd = DRV_VER_UPD;
 
 	if (BNXT_PF(bp)) {
-		DECLARE_BITMAP(vf_req_snif_bmap, 256);
-		u32 *data = (u32 *)vf_req_snif_bmap;
+		u32 data[8];
 		int i;
 
-		memset(vf_req_snif_bmap, 0, sizeof(vf_req_snif_bmap));
-		for (i = 0; i < ARRAY_SIZE(bnxt_vf_req_snif); i++)
-			__set_bit(bnxt_vf_req_snif[i], vf_req_snif_bmap);
+		memset(data, 0, sizeof(data));
+		for (i = 0; i < ARRAY_SIZE(bnxt_vf_req_snif); i++) {
+			u16 cmd = bnxt_vf_req_snif[i];
+			unsigned int bit, idx;
+
+			idx = cmd / 32;
+			bit = cmd % 32;
+			data[idx] |= 1 << bit;
+		}
 
 		for (i = 0; i < 8; i++)
 			req.vf_req_fwd[i] = cpu_to_le32(data[i]);
-- 
1.8.3.1
