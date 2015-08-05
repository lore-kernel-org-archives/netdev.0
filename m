From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 3/3] be2net: protect eqo->affinity_mask from getting freed twice
Date: Wed,  5 Aug 2015 03:27:50 -0400
Message-ID: <1438759670-2134-4-git-send-email-sathya.perla@avagotech.com>
References: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56695 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751918AbbHEHVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 03:21:34 -0400
In-Reply-To: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@avagotech.com>

There are paths in the driver such as an unrecoverable error (UE) detection
followed by a driver unload wherein be_clear() is invoked twice.
Individual data structures are reset so that they are not cleaned/freed
twice. This patch does the same for eqo->affinity_mask. It is freed only
if EQs haven't yet been destroyed. This fixes a possible crash when
affinity_mask is freed twice.

Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 14ae67a..c28e3bf 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2584,8 +2584,8 @@ static void be_evt_queues_destroy(struct be_adapter *adapter)
 			be_cmd_q_destroy(adapter, &eqo->q, QTYPE_EQ);
 			napi_hash_del(&eqo->napi);
 			netif_napi_del(&eqo->napi);
+			free_cpumask_var(eqo->affinity_mask);
 		}
-		free_cpumask_var(eqo->affinity_mask);
 		be_queue_free(adapter, &eqo->q);
 	}
 }
@@ -2602,13 +2602,7 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 
 	for_all_evt_queues(adapter, eqo, i) {
 		int numa_node = dev_to_node(&adapter->pdev->dev);
-		if (!zalloc_cpumask_var(&eqo->affinity_mask, GFP_KERNEL))
-			return -ENOMEM;
-		cpumask_set_cpu(cpumask_local_spread(i, numa_node),
-				eqo->affinity_mask);
-		netif_napi_add(adapter->netdev, &eqo->napi, be_poll,
-			       BE_NAPI_WEIGHT);
-		napi_hash_add(&eqo->napi);
+
 		aic = &adapter->aic_obj[i];
 		eqo->adapter = adapter;
 		eqo->idx = i;
@@ -2624,6 +2618,14 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 		rc = be_cmd_eq_create(adapter, eqo);
 		if (rc)
 			return rc;
+
+		if (!zalloc_cpumask_var(&eqo->affinity_mask, GFP_KERNEL))
+			return -ENOMEM;
+		cpumask_set_cpu(cpumask_local_spread(i, numa_node),
+				eqo->affinity_mask);
+		netif_napi_add(adapter->netdev, &eqo->napi, be_poll,
+			       BE_NAPI_WEIGHT);
+		napi_hash_add(&eqo->napi);
 	}
 	return 0;
 }
-- 
2.4.1
