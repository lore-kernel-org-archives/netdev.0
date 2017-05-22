From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 07/11] qed: Flush slowpath tasklet on stop
Date: Mon, 22 May 2017 14:32:07 +0300
Message-ID: <1495452731-27171-8-git-send-email-Yuval.Mintz@cavium.com>
References: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0042.outbound.protection.outlook.com ([104.47.41.42]:1952
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932406AbdEVLdL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 07:33:11 -0400
In-Reply-To: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

Today, driver has a synchronization point while closing
the device which synchronizes its slowpath interrupt line.
However, that's insufficient as that ISR would schedule the
slowpath-tasklet - so even after ISR is over it's possible the
handling of the interrupt has not completed.

By doing a disable/enable on the taskelt we guarantee that all
HW events that should no longer be genereated from that point
onward in the flow are truly behind us.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index f286daa..3043dcce 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -606,6 +606,18 @@ int qed_slowpath_irq_req(struct qed_hwfn *hwfn)
 	return rc;
 }
 
+static void qed_slowpath_tasklet_flush(struct qed_hwfn *p_hwfn)
+{
+	/* Calling the disable function will make sure that any
+	 * currently-running function is completed. The following call to the
+	 * enable function makes this sequence a flush-like operation.
+	 */
+	if (p_hwfn->b_sp_dpc_enabled) {
+		tasklet_disable(p_hwfn->sp_dpc);
+		tasklet_enable(p_hwfn->sp_dpc);
+	}
+}
+
 void qed_slowpath_irq_sync(struct qed_hwfn *p_hwfn)
 {
 	struct qed_dev *cdev = p_hwfn->cdev;
@@ -617,6 +629,8 @@ void qed_slowpath_irq_sync(struct qed_hwfn *p_hwfn)
 		synchronize_irq(cdev->int_params.msix_table[id].vector);
 	else
 		synchronize_irq(cdev->pdev->irq);
+
+	qed_slowpath_tasklet_flush(p_hwfn);
 }
 
 static void qed_slowpath_irq_free(struct qed_dev *cdev)
-- 
1.9.3
