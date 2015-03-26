From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/3] be2net: assign CPU affinity hints to be2net IRQs
Date: Thu, 26 Mar 2015 03:05:08 -0400
Message-ID: <1427353510-24790-2-git-send-email-sathya.perla@emulex.com>
References: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:14143 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbbCZHBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 03:01:15 -0400
In-Reply-To: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>

This patch provides hints to irqbalance to map be2net IRQs to
specific CPU cores. cpumask_set_cpu_local_first() is used, which first
maps IRQs to near NUMA cores; when those cores are exhausted, IRQs are
mapped to far NUMA cores.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  2 ++
 drivers/net/ethernet/emulex/benet/be_main.c | 17 ++++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index eb39673..a2fe1f3 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -30,6 +30,7 @@
 #include <linux/firmware.h>
 #include <linux/slab.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/cpumask.h>
 
 #include "be_hw.h"
 #include "be_roce.h"
@@ -183,6 +184,7 @@ struct be_eq_obj {
 	u16 spurious_intr;
 	struct napi_struct napi;
 	struct be_adapter *adapter;
+	cpumask_var_t  affinity_mask;
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 #define BE_EQ_IDLE		0
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d8df78b..3541207 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2342,6 +2342,7 @@ static void be_evt_queues_destroy(struct be_adapter *adapter)
 			napi_hash_del(&eqo->napi);
 			netif_napi_del(&eqo->napi);
 		}
+		free_cpumask_var(eqo->affinity_mask);
 		be_queue_free(adapter, &eqo->q);
 	}
 }
@@ -2357,6 +2358,11 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 				    adapter->cfg_num_qs);
 
 	for_all_evt_queues(adapter, eqo, i) {
+		if (!zalloc_cpumask_var(&eqo->affinity_mask, GFP_KERNEL))
+			return -ENOMEM;
+		cpumask_set_cpu_local_first(i, dev_to_node(&adapter->pdev->dev),
+					    eqo->affinity_mask);
+
 		netif_napi_add(adapter->netdev, &eqo->napi, be_poll,
 			       BE_NAPI_WEIGHT);
 		napi_hash_add(&eqo->napi);
@@ -3028,6 +3034,8 @@ static int be_msix_register(struct be_adapter *adapter)
 		status = request_irq(vec, be_msix, 0, eqo->desc, eqo);
 		if (status)
 			goto err_msix;
+
+		irq_set_affinity_hint(vec, eqo->affinity_mask);
 	}
 
 	return 0;
@@ -3072,7 +3080,7 @@ static void be_irq_unregister(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct be_eq_obj *eqo;
-	int i;
+	int i, vec;
 
 	if (!adapter->isr_registered)
 		return;
@@ -3084,8 +3092,11 @@ static void be_irq_unregister(struct be_adapter *adapter)
 	}
 
 	/* MSIx */
-	for_all_evt_queues(adapter, eqo, i)
-		free_irq(be_msix_vec_get(adapter, eqo), eqo);
+	for_all_evt_queues(adapter, eqo, i) {
+		vec = be_msix_vec_get(adapter, eqo);
+		irq_set_affinity_hint(vec, NULL);
+		free_irq(vec, eqo);
+	}
 
 done:
 	adapter->isr_registered = false;
-- 
2.2.0
