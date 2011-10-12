From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] igb: avoid unnecessarily creating a local copy of the q_vector
Date: Tue, 11 Oct 2011 20:38:20 -0700
Message-ID: <1318390708-12232-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41058 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab1JLDic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 23:38:32 -0400
In-Reply-To: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This is mostly a drop of unnecessary pointer defines for q_vector when we
don't have issues with line width and don't have multiple references to
the pointer.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   46 ++++++++++------------------
 1 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b3a2e3d..2768c35 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1270,11 +1270,9 @@ static void igb_free_irq(struct igb_adapter *adapter)
 
 		free_irq(adapter->msix_entries[vector++].vector, adapter);
 
-		for (i = 0; i < adapter->num_q_vectors; i++) {
-			struct igb_q_vector *q_vector = adapter->q_vector[i];
+		for (i = 0; i < adapter->num_q_vectors; i++)
 			free_irq(adapter->msix_entries[vector++].vector,
-			         q_vector);
-		}
+				 adapter->q_vector[i]);
 	} else {
 		free_irq(adapter->pdev->irq, adapter);
 	}
@@ -1476,10 +1474,9 @@ int igb_up(struct igb_adapter *adapter)
 
 	clear_bit(__IGB_DOWN, &adapter->state);
 
-	for (i = 0; i < adapter->num_q_vectors; i++) {
-		struct igb_q_vector *q_vector = adapter->q_vector[i];
-		napi_enable(&q_vector->napi);
-	}
+	for (i = 0; i < adapter->num_q_vectors; i++)
+		napi_enable(&(adapter->q_vector[i]->napi));
+
 	if (adapter->msix_entries)
 		igb_configure_msix(adapter);
 	else
@@ -1531,10 +1528,8 @@ void igb_down(struct igb_adapter *adapter)
 	wrfl();
 	msleep(10);
 
-	for (i = 0; i < adapter->num_q_vectors; i++) {
-		struct igb_q_vector *q_vector = adapter->q_vector[i];
-		napi_disable(&q_vector->napi);
-	}
+	for (i = 0; i < adapter->num_q_vectors; i++)
+		napi_disable(&(adapter->q_vector[i]->napi));
 
 	igb_irq_disable(adapter);
 
@@ -2497,10 +2492,8 @@ static int igb_open(struct net_device *netdev)
 	/* From here on the code is the same as igb_up() */
 	clear_bit(__IGB_DOWN, &adapter->state);
 
-	for (i = 0; i < adapter->num_q_vectors; i++) {
-		struct igb_q_vector *q_vector = adapter->q_vector[i];
-		napi_enable(&q_vector->napi);
-	}
+	for (i = 0; i < adapter->num_q_vectors; i++)
+		napi_enable(&(adapter->q_vector[i]->napi));
 
 	/* Clear any pending interrupts. */
 	rd32(E1000_ICR);
@@ -3699,10 +3692,8 @@ static void igb_watchdog_task(struct work_struct *work)
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	if (adapter->msix_entries) {
 		u32 eics = 0;
-		for (i = 0; i < adapter->num_q_vectors; i++) {
-			struct igb_q_vector *q_vector = adapter->q_vector[i];
-			eics |= q_vector->eims_value;
-		}
+		for (i = 0; i < adapter->num_q_vectors; i++)
+			eics |= adapter->q_vector[i]->eims_value;
 		wr32(E1000_EICS, eics);
 	} else {
 		wr32(E1000_ICS, E1000_ICS_RXDMT0);
@@ -6601,18 +6592,15 @@ static void igb_netpoll(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	struct igb_q_vector *q_vector;
 	int i;
 
-	if (!adapter->msix_entries) {
-		struct igb_q_vector *q_vector = adapter->q_vector[0];
-		igb_irq_disable(adapter);
-		napi_schedule(&q_vector->napi);
-		return;
-	}
-
 	for (i = 0; i < adapter->num_q_vectors; i++) {
-		struct igb_q_vector *q_vector = adapter->q_vector[i];
-		wr32(E1000_EIMC, q_vector->eims_value);
+		q_vector = adapter->q_vector[i];
+		if (adapter->msix_entries)
+			wr32(E1000_EIMC, q_vector->eims_value);
+		else
+			igb_irq_disable(adapter);
 		napi_schedule(&q_vector->napi);
 	}
 }
-- 
1.7.6.4
