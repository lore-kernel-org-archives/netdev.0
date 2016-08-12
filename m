From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 13/21] net: thunderx: Use netdev's name for naming VF's interrupts
Date: Fri, 12 Aug 2016 16:51:36 +0530
Message-ID: <1471000904-21715-14-git-send-email-sunil.kovvuri@gmail.com>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch changes the way VF's irqs are visible in /proc/interrupts.
Instead of VF id, logical interface's netdev name is used for IRQ
naming and also all secondary VF's interrupts in multiqset config
use primary VF's netdev name.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index d9efe2f..5335ff1 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -938,16 +938,19 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 	int vector;
 
 	for_each_cq_irq(irq)
-		sprintf(nic->irq_name[irq], "NICVF%d CQ%d",
-			nic->vf_id, irq);
+		sprintf(nic->irq_name[irq], "%s-rxtx-%d",
+			nic->pnicvf->netdev->name,
+			nicvf_netdev_qidx(nic, irq));
 
 	for_each_sq_irq(irq)
-		sprintf(nic->irq_name[irq], "NICVF%d SQ%d",
-			nic->vf_id, irq - NICVF_INTR_ID_SQ);
+		sprintf(nic->irq_name[irq], "%s-sq-%d",
+			nic->pnicvf->netdev->name,
+			nicvf_netdev_qidx(nic, irq - NICVF_INTR_ID_SQ));
 
 	for_each_rbdr_irq(irq)
-		sprintf(nic->irq_name[irq], "NICVF%d RBDR%d",
-			nic->vf_id, irq - NICVF_INTR_ID_RBDR);
+		sprintf(nic->irq_name[irq], "%s-rbdr-%d",
+			nic->pnicvf->netdev->name,
+			nic->sqs_mode ? (nic->sqs_id + 1) : 0);
 
 	/* Register CQ interrupts */
 	for (irq = 0; irq < nic->qs->cq_cnt; irq++) {
@@ -971,8 +974,9 @@ static int nicvf_register_interrupts(struct nicvf *nic)
 	}
 
 	/* Register QS error interrupt */
-	sprintf(nic->irq_name[NICVF_INTR_ID_QS_ERR],
-		"NICVF%d Qset error", nic->vf_id);
+	sprintf(nic->irq_name[NICVF_INTR_ID_QS_ERR], "%s-qset-err-%d",
+		nic->pnicvf->netdev->name,
+		nic->sqs_mode ? (nic->sqs_id + 1) : 0);
 	irq = NICVF_INTR_ID_QS_ERR;
 	ret = request_irq(nic->msix_entries[irq].vector,
 			  nicvf_qs_err_intr_handler,
-- 
2.7.4
