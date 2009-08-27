From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Allow running MSIx with fewer vectors.
Date: Thu, 27 Aug 2009 14:02:10 -0700
Message-ID: <1251406931-15107-3-git-send-email-ron.mercer@qlogic.com>
References: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40659 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbZH0VHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 17:07:52 -0400
In-Reply-To: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we downshift to MSI/Legacy if we don't get enough vectors for
cpu_count RSS rings plus cpu_count TX completion rings.  This patch
allows running MSIX with the vector count that the platform provides.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   85 +++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 47 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 89ea9c7..0cbda4d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2815,17 +2815,20 @@ static void ql_disable_msix(struct ql_adapter *qdev)
 	}
 }
 
+/* We start by trying to get the number of vectors
+ * stored in qdev->intr_count. If we don't get that
+ * many then we reduce the count and try again.
+ */
 static void ql_enable_msix(struct ql_adapter *qdev)
 {
-	int i;
+	int i, err;
 
-	qdev->intr_count = 1;
 	/* Get the MSIX vectors. */
 	if (irq_type == MSIX_IRQ) {
 		/* Try to alloc space for the msix struct,
 		 * if it fails then go to MSI/legacy.
 		 */
-		qdev->msi_x_entry = kcalloc(qdev->rx_ring_count,
+		qdev->msi_x_entry = kcalloc(qdev->intr_count,
 					    sizeof(struct msix_entry),
 					    GFP_KERNEL);
 		if (!qdev->msi_x_entry) {
@@ -2833,26 +2836,36 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 			goto msi;
 		}
 
-		for (i = 0; i < qdev->rx_ring_count; i++)
+		for (i = 0; i < qdev->intr_count; i++)
 			qdev->msi_x_entry[i].entry = i;
 
-		if (!pci_enable_msix
-		    (qdev->pdev, qdev->msi_x_entry, qdev->rx_ring_count)) {
-			set_bit(QL_MSIX_ENABLED, &qdev->flags);
-			qdev->intr_count = qdev->rx_ring_count;
-			QPRINTK(qdev, IFUP, DEBUG,
-				"MSI-X Enabled, got %d vectors.\n",
-				qdev->intr_count);
-			return;
-		} else {
+		/* Loop to get our vectors.  We start with
+		 * what we want and settle for what we get.
+		 */
+		do {
+			err = pci_enable_msix(qdev->pdev,
+				qdev->msi_x_entry, qdev->intr_count);
+			if (err > 0)
+				qdev->intr_count = err;
+		} while (err > 0);
+
+		if (err < 0) {
 			kfree(qdev->msi_x_entry);
 			qdev->msi_x_entry = NULL;
 			QPRINTK(qdev, IFUP, WARNING,
 				"MSI-X Enable failed, trying MSI.\n");
+			qdev->intr_count = 1;
 			irq_type = MSI_IRQ;
+		} else if (err == 0) {
+			set_bit(QL_MSIX_ENABLED, &qdev->flags);
+			QPRINTK(qdev, IFUP, INFO,
+				"MSI-X Enabled, got %d vectors.\n",
+				qdev->intr_count);
+			return;
 		}
 	}
 msi:
+	qdev->intr_count = 1;
 	if (irq_type == MSI_IRQ) {
 		if (!pci_enable_msi(qdev->pdev)) {
 			set_bit(QL_MSI_ENABLED, &qdev->flags);
@@ -2876,8 +2889,6 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 	int i = 0;
 	struct intr_context *intr_context = &qdev->intr_context[0];
 
-	ql_enable_msix(qdev);
-
 	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags))) {
 		/* Each rx_ring has it's
 		 * own intr_context since we have separate
@@ -3438,40 +3449,20 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	int i;
 	struct rx_ring *rx_ring;
 	struct tx_ring *tx_ring;
-	int cpu_cnt = num_online_cpus();
-
-	/*
-	 * For each processor present we allocate one
-	 * rx_ring for outbound completions, and one
-	 * rx_ring for inbound completions.  Plus there is
-	 * always the one default queue.  For the CPU
-	 * counts we end up with the following rx_rings:
-	 * rx_ring count =
-	 *  one default queue +
-	 *  (CPU count * outbound completion rx_ring) +
-	 *  (CPU count * inbound (RSS) completion rx_ring)
-	 * To keep it simple we limit the total number of
-	 * queues to < 32, so we truncate CPU to 8.
-	 * This limitation can be removed when requested.
+	int cpu_cnt = min(MAX_CPUS, (int)num_online_cpus());
+
+	/* In a perfect world we have one RSS ring for each CPU
+	 * and each has it's own vector.  To do that we ask for
+	 * cpu_cnt vectors.  ql_enable_msix() will adjust the
+	 * vector count to what we actually get.  We then
+	 * allocate an RSS ring for each.
+	 * Essentially, we are doing min(cpu_count, msix_vector_count).
 	 */
-
-	if (cpu_cnt > MAX_CPUS)
-		cpu_cnt = MAX_CPUS;
-
-	/*
-	 * rx_ring[0] is always the default queue.
-	 */
-	/* Allocate outbound completion ring for each CPU. */
+	qdev->intr_count = cpu_cnt;
+	ql_enable_msix(qdev);
+	/* Adjust the RSS ring count to the actual vector count. */
+	qdev->rss_ring_count = qdev->intr_count;
 	qdev->tx_ring_count = cpu_cnt;
-	/* Allocate inbound completion (RSS) ring for each CPU. */
-	qdev->rss_ring_count = cpu_cnt;
-	/*
-	 * qdev->rx_ring_count:
-	 * Total number of rx_rings.  This includes the one
-	 * default queue, a number of outbound completion
-	 * handler rx_rings, and the number of inbound
-	 * completion handler rx_rings.
-	 */
 	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count;
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
-- 
1.6.0.2

