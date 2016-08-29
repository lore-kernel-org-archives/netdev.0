From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 1/3] qed*: Disallow dcbx configuration for VF interfaces.
Date: Mon, 29 Aug 2016 08:29:52 -0400
Message-ID: <1472473794-11933-2-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1472473794-11933-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        <sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34340 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933012AbcH2NNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:13:44 -0400
In-Reply-To: <1472473794-11933-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dcbx configuration is not supported for VF interfaces. Hence don't populate
the callbacks for VFs and also fail the dcbx-query for VFs.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c   | 4 ++++
 drivers/net/ethernet/qlogic/qede/qede_main.c | 3 ++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 226cb08..7ad1667 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -19,6 +19,7 @@
 #include "qed_dcbx.h"
 #include "qed_hsi.h"
 #include "qed_sp.h"
+#include "qed_sriov.h"
 #ifdef CONFIG_DCB
 #include <linux/qed/qed_eth_if.h>
 #endif
@@ -945,6 +946,9 @@ static int qed_dcbx_query_params(struct qed_hwfn *p_hwfn,
 	struct qed_ptt *p_ptt;
 	int rc;
 
+	if (IS_VF(p_hwfn->cdev))
+		return -EINVAL;
+
 	p_ptt = qed_ptt_acquire(p_hwfn);
 	if (!p_ptt)
 		return -EBUSY;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index a6eb6af..9544e4c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2520,7 +2520,8 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 	edev->ops->register_ops(cdev, &qede_ll_ops, edev);
 
 #ifdef CONFIG_DCB
-	qede_set_dcbnl_ops(edev->ndev);
+	if (!IS_VF(edev))
+		qede_set_dcbnl_ops(edev->ndev);
 #endif
 
 	INIT_DELAYED_WORK(&edev->sp_task, qede_sp_task);
-- 
1.8.3.1
