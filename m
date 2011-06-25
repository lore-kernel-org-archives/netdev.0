From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] ixgbe: pass adapter struct instead of netdev for interrupt data
Date: Sat, 25 Jun 2011 00:22:18 -0700
Message-ID: <1308986546-12964-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31485 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab1FYHW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:28 -0400
In-Reply-To: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we pass the adapter struct instead of the
netdev for most of the basic interrupts that are not associated with
q_vectors.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2496a27..b308571 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1880,8 +1880,7 @@ static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
 
 static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 {
-	struct net_device *netdev = data;
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = data;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr;
 
@@ -2376,7 +2375,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 
 	sprintf(adapter->lsc_int_name, "%s:lsc", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  ixgbe_msix_lsc, 0, adapter->lsc_int_name, netdev);
+			  ixgbe_msix_lsc, 0, adapter->lsc_int_name, adapter);
 	if (err) {
 		e_err(probe, "request_irq for msix_lsc failed: %d\n", err);
 		goto free_queue_irqs;
@@ -2488,8 +2487,7 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
  **/
 static irqreturn_t ixgbe_intr(int irq, void *data)
 {
-	struct net_device *netdev = data;
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = data;
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
 	u32 eicr;
@@ -2586,10 +2584,10 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 		err = ixgbe_request_msix_irqs(adapter);
 	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
 		err = request_irq(adapter->pdev->irq, ixgbe_intr, 0,
-				  netdev->name, netdev);
+				  netdev->name, adapter);
 	} else {
 		err = request_irq(adapter->pdev->irq, ixgbe_intr, IRQF_SHARED,
-				  netdev->name, netdev);
+				  netdev->name, adapter);
 	}
 
 	if (err)
@@ -2600,15 +2598,13 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 
 static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
-
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		int i, q_vectors;
 
 		q_vectors = adapter->num_msix_vectors;
 
 		i = q_vectors - 1;
-		free_irq(adapter->msix_entries[i].vector, netdev);
+		free_irq(adapter->msix_entries[i].vector, adapter);
 
 		i--;
 		for (; i >= 0; i--) {
@@ -2623,7 +2619,7 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 
 		ixgbe_reset_q_vectors(adapter);
 	} else {
-		free_irq(adapter->pdev->irq, netdev);
+		free_irq(adapter->pdev->irq, adapter);
 	}
 }
 
-- 
1.7.5.4

