From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] qed: Correct MSI-x for storage
Date: Wed, 5 Apr 2017 21:20:11 +0300
Message-ID: <1491416411-27750-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:35568 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753787AbdDESUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 14:20:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When qedr is enabled, qed would try dividing the msi-x vectors between
L2 and RoCE, starting with L2 and providing it with sufficient vectors
for its queues.

Problem is qed would also do that for storage partitions, and as those
don't need queues it would lead qed to award those partitions with 0
msi-x vectors, causing them to believe theye're using INTa and
preventing them from operating.

Fixes: 51ff17251c9c ("qed: Add support for RoCE hw init")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 634e7a2..aab89de 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -745,7 +745,8 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 	cdev->int_params.fp_msix_cnt = cdev->int_params.out.num_vectors -
 				       cdev->num_hwfns;
 
-	if (!IS_ENABLED(CONFIG_QED_RDMA))
+	if (!IS_ENABLED(CONFIG_QED_RDMA) ||
+	    QED_LEADING_HWFN(cdev)->hw_info.personality != QED_PCI_ETH_ROCE)
 		return 0;
 
 	for_each_hwfn(cdev, i)
-- 
1.9.3
