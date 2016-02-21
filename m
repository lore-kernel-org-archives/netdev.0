From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/5] qed: Handle possible race in SB config
Date: Sun, 21 Feb 2016 11:40:08 +0200
Message-ID: <1456047611-11222-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:58091 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751326AbcBURoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:44:17 -0500
In-Reply-To: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to HW design, some of the memories are wide-bus and access to those
needs to be sequentialized on a per-HW-block level; Read/write to a
given HW-block might break other read/write to wide-bus memory done at
~same time.

Status blocks initialization in CAU is done into such a wide-bus memory.
This moves the initialization into using DMAE which is guaranteed to be
safe to use on such memories.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 90ba1d7..fa73daa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -473,20 +473,20 @@ void qed_int_cau_conf_sb(struct qed_hwfn *p_hwfn,
 			 u8 vf_valid)
 {
 	struct cau_sb_entry sb_entry;
-	u32 val;
 
 	qed_init_cau_sb_entry(p_hwfn, &sb_entry, p_hwfn->rel_pf_id,
 			      vf_number, vf_valid);
 
 	if (p_hwfn->hw_init_done) {
-		val = CAU_REG_SB_ADDR_MEMORY + igu_sb_id * sizeof(u64);
-		qed_wr(p_hwfn, p_ptt, val, lower_32_bits(sb_phys));
-		qed_wr(p_hwfn, p_ptt, val + sizeof(u32),
-		       upper_32_bits(sb_phys));
-
-		val = CAU_REG_SB_VAR_MEMORY + igu_sb_id * sizeof(u64);
-		qed_wr(p_hwfn, p_ptt, val, sb_entry.data);
-		qed_wr(p_hwfn, p_ptt, val + sizeof(u32), sb_entry.params);
+		/* Wide-bus, initialize via DMAE */
+		u64 phys_addr = (u64)sb_phys;
+
+		qed_dmae_host2grc(p_hwfn, p_ptt, (u64)(uintptr_t)&phys_addr,
+				  CAU_REG_SB_ADDR_MEMORY +
+				  igu_sb_id * sizeof(u64), 2, 0);
+		qed_dmae_host2grc(p_hwfn, p_ptt, (u64)(uintptr_t)&sb_entry,
+				  CAU_REG_SB_VAR_MEMORY +
+				  igu_sb_id * sizeof(u64), 2, 0);
 	} else {
 		/* Initialize Status Block Address */
 		STORE_RT_REG_AGG(p_hwfn,
-- 
1.9.3
