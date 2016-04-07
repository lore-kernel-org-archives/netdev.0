From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] igb: Add support for bulk Tx cleanup & cleanup boolean logic
Date: Wed,  6 Apr 2016 21:37:27 -0700
Message-ID: <1460003853-133949-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5553 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbcDGEhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:36 -0400
In-Reply-To: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch enables bulk free in Tx cleanup for igb and cleans up the
boolean logic in the polling routines for igb in the hopes of avoiding
any mix-ups similar to what occurred with i40e and i40evf.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 36814a2..e40983c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -150,7 +150,7 @@ static void igb_update_dca(struct igb_q_vector *);
 static void igb_setup_dca(struct igb_adapter *);
 #endif /* CONFIG_IGB_DCA */
 static int igb_poll(struct napi_struct *, int);
-static bool igb_clean_tx_irq(struct igb_q_vector *);
+static bool igb_clean_tx_irq(struct igb_q_vector *, int);
 static int igb_clean_rx_irq(struct igb_q_vector *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
@@ -6522,13 +6522,14 @@ static int igb_poll(struct napi_struct *napi, int budget)
 		igb_update_dca(q_vector);
 #endif
 	if (q_vector->tx.ring)
-		clean_complete = igb_clean_tx_irq(q_vector);
+		clean_complete = igb_clean_tx_irq(q_vector, budget);
 
 	if (q_vector->rx.ring) {
 		int cleaned = igb_clean_rx_irq(q_vector, budget);
 
 		work_done += cleaned;
-		clean_complete &= (cleaned < budget);
+		if (cleaned >= budget)
+			clean_complete = false;
 	}
 
 	/* If all work not completed, return budget and keep polling */
@@ -6545,10 +6546,11 @@ static int igb_poll(struct napi_struct *napi, int budget)
 /**
  *  igb_clean_tx_irq - Reclaim resources after transmit completes
  *  @q_vector: pointer to q_vector containing needed info
+ *  @napi_budget: Used to determine if we are in netpoll
  *
  *  returns true if ring is completely cleaned
  **/
-static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
+static bool igb_clean_tx_irq(struct igb_q_vector *q_vector, int napi_budget)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct igb_ring *tx_ring = q_vector->tx.ring;
@@ -6587,7 +6589,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		napi_consume_skb(tx_buffer->skb, napi_budget);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
-- 
2.5.5
