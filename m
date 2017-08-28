From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/11] bnxt_en: assign CPU affinity hints to bnxt_en IRQs
Date: Mon, 28 Aug 2017 13:40:27 -0400
Message-ID: <1503942035-24924-4-git-send-email-michael.chan@broadcom.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org,
        Vasundhara Volam <vasundhara-v.volam@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33350 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdH1Rkx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:53 -0400
Received: by mail-qt0-f178.google.com with SMTP id e2so5348213qta.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:40:52 -0700 (PDT)
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara-v.volam@broadcom.com>

This patch provides hints to irqbalance to map bnxt_en device IRQs
to specific CPU cores. cpumask_local_spread() is used, which first
maps IRQs to near NUMA cores; when those cores are exhausted, IRQs
are mapped to far NUMA cores.

Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 25 ++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  4 +++-
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4b0a807..9657bfb 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -49,6 +49,7 @@
 #include <linux/aer.h>
 #include <linux/bitmap.h>
 #include <linux/cpu_rmap.h>
+#include <linux/cpumask.h>
 
 #include "bnxt_hsi.h"
 #include "bnxt.h"
@@ -5554,8 +5555,15 @@ static void bnxt_free_irq(struct bnxt *bp)
 
 	for (i = 0; i < bp->cp_nr_rings; i++) {
 		irq = &bp->irq_tbl[i];
-		if (irq->requested)
+		if (irq->requested) {
+			if (irq->have_cpumask) {
+				irq_set_affinity_hint(irq->vector, NULL);
+				free_cpumask_var(irq->cpu_mask);
+				irq->have_cpumask = 0;
+			}
 			free_irq(irq->vector, bp->bnapi[i]);
+		}
+
 		irq->requested = 0;
 	}
 }
@@ -5588,6 +5596,21 @@ static int bnxt_request_irq(struct bnxt *bp)
 			break;
 
 		irq->requested = 1;
+
+		if (zalloc_cpumask_var(&irq->cpu_mask, GFP_KERNEL)) {
+			int numa_node = dev_to_node(&bp->pdev->dev);
+
+			irq->have_cpumask = 1;
+			cpumask_set_cpu(cpumask_local_spread(i, numa_node),
+					irq->cpu_mask);
+			rc = irq_set_affinity_hint(irq->vector, irq->cpu_mask);
+			if (rc) {
+				netdev_warn(bp->dev,
+					    "Set affinity failed, IRQ = %d\n",
+					    irq->vector);
+				break;
+			}
+		}
 	}
 	return rc;
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 568516f..801c0f7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -701,8 +701,10 @@ struct bnxt_napi {
 struct bnxt_irq {
 	irq_handler_t	handler;
 	unsigned int	vector;
-	u8		requested;
+	u8		requested:1;
+	u8		have_cpumask:1;
 	char		name[IFNAMSIZ + 2];
+	cpumask_var_t	cpu_mask;
 };
 
 #define HWRM_RING_ALLOC_TX	0x1
-- 
1.8.3.1
