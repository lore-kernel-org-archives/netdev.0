From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30] cxgb3 - ease msi-x settings conditions
Date: Sun, 18 Jan 2009 12:48:36 -0800
Message-ID: <20090118204836.10826.2994.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11238 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427AbZARUsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 15:48:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

The driver currently drops to line interrupt mode
if it did not get all the msi-x vectors it requested.

Allow msi-x settings when a minimal amount of vectors
is provided.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |    1 +
 drivers/net/cxgb3/cxgb3_main.c |   23 +++++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index a89d8cc..5fb7c68 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -230,6 +230,7 @@ struct adapter {
 	unsigned int slow_intr_mask;
 	unsigned long irq_stats[IRQ_NUM_STATS];
 
+	int msix_nvectors;
 	struct {
 		unsigned short vec;
 		char desc[22];
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 0089746..52131bd 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -338,7 +338,7 @@ static void free_irq_resources(struct adapter *adapter)
 
 		free_irq(adapter->msix_info[0].vec, adapter);
 		for_each_port(adapter, i)
-		    n += adap2pinfo(adapter, i)->nqsets;
+			n += adap2pinfo(adapter, i)->nqsets;
 
 		for (i = 0; i < n; ++i)
 			free_irq(adapter->msix_info[i + 1].vec,
@@ -2752,7 +2752,7 @@ static void set_nqsets(struct adapter *adap)
 	int i, j = 0;
 	int num_cpus = num_online_cpus();
 	int hwports = adap->params.nports;
-	int nqsets = SGE_QSETS;
+	int nqsets = adap->msix_nvectors - 1;
 
 	if (adap->params.rev > 0 && adap->flags & USING_MSIX) {
 		if (hwports == 2 &&
@@ -2781,18 +2781,25 @@ static void set_nqsets(struct adapter *adap)
 static int __devinit cxgb_enable_msix(struct adapter *adap)
 {
 	struct msix_entry entries[SGE_QSETS + 1];
+	int vectors;
 	int i, err;
 
-	for (i = 0; i < ARRAY_SIZE(entries); ++i)
+	vectors = ARRAY_SIZE(entries);
+	for (i = 0; i < vectors; ++i)
 		entries[i].entry = i;
 
-	err = pci_enable_msix(adap->pdev, entries, ARRAY_SIZE(entries));
+	while ((err = pci_enable_msix(adap->pdev, entries, vectors)) > 0)
+		vectors = err;
+
+	if (!err && vectors < (adap->params.nports + 1))
+		err = -1;
+
 	if (!err) {
-		for (i = 0; i < ARRAY_SIZE(entries); ++i)
+		for (i = 0; i < vectors; ++i)
 			adap->msix_info[i].vec = entries[i].vector;
-	} else if (err > 0)
-		dev_info(&adap->pdev->dev,
-		       "only %d MSI-X vectors left, not using MSI-X\n", err);
+		adap->msix_nvectors = vectors;
+	}
+
 	return err;
 }
 

