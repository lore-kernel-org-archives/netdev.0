From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 7/7] qed: Fix possible race when reading firmware return code.
Date: Thu, 13 Oct 2016 07:22:51 -0400
Message-ID: <1476357771-1578-8-git-send-email-manish.chopra@qlogic.com>
References: <1476357771-1578-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        Manish Chopra <manish.chopra@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33202 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754344AbcJMMIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:08:55 -0400
In-Reply-To: <1476357771-1578-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@caviumnetworks.com>

While handling SPQ ramrod completion, there is a possible race
where driver might not read updated fw return code based on
ramrod completion done. This patch ensures that fw return code
is written first and then completion done flag is updated
using appropriate memory barriers.

Signed-off-by: Manish Chopra <manish.chopra@caviumnetworks.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
 drivers/net/ethernet/qlogic/qed/qed_spq.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 259a615..6c05402 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -54,11 +54,10 @@ static void qed_spq_blocking_cb(struct qed_hwfn *p_hwfn,
 
 	comp_done = (struct qed_spq_comp_done *)cookie;
 
-	comp_done->done			= 0x1;
-	comp_done->fw_return_code	= fw_return_code;
+	comp_done->fw_return_code = fw_return_code;
 
-	/* make update visible to waiting thread */
-	smp_wmb();
+	/* Make sure completion done is visible on waiting thread */
+	smp_store_release(&comp_done->done, 0x1);
 }
 
 static int __qed_spq_block(struct qed_hwfn *p_hwfn,
@@ -74,8 +73,9 @@ static int __qed_spq_block(struct qed_hwfn *p_hwfn,
 
 	while (iter_cnt--) {
 		/* Validate we receive completion update */
-		smp_rmb();
-		if (comp_done->done == 1) {
+		if (READ_ONCE(comp_done->done) == 1) {
+			/* Read updated FW return value */
+			smp_read_barrier_depends();
 			if (p_fw_ret)
 				*p_fw_ret = comp_done->fw_return_code;
 			return 0;
-- 
2.7.2
