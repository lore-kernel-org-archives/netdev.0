From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2] ixgbe: Remove IXGBE_FLAG_IN_NETPOLL since it
 doesn't do anything
Date: Wed, 19 Nov 2014 15:28:01 -0800
Message-ID: <20141119232710.19544.20012.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932472AbaKSX2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 18:28:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes some dead code from the cleanup path for ixgbe.

Setting and clearing the flag doesn't do anything since all we are doing is
setting the flag, scheduling napi, clearing the flag and then letting
netpoll do the polling cleanup.  As such it doesn't make much sense to have
it there.

This patch also removes one minor white-space error.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

v2: Fixed an unused variable warning for adapter in ixgbe_rx_skb

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   18 ++++--------------
 2 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 86fa607..f7d46b3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -610,7 +610,6 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 4)
 #define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 5)
 #define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 6)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 7)
 #define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
 #define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 9)
 #define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 10)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7c4d3b3..3dfec61 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1583,14 +1583,10 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
 			 struct sk_buff *skb)
 {
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-
 	if (ixgbe_qv_busy_polling(q_vector))
 		netif_receive_skb(skb);
-	else if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		napi_gro_receive(&q_vector->napi, skb);
 	else
-		netif_rx(skb);
+		napi_gro_receive(&q_vector->napi, skb);
 }
 
 /**
@@ -6064,7 +6060,6 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 
 	/* Cause software interrupt to ensure rings are cleaned */
 	ixgbe_irq_rearm_queues(adapter, eics);
-
 }
 
 /**
@@ -7397,14 +7392,9 @@ static void ixgbe_netpoll(struct net_device *netdev)
 	if (test_bit(__IXGBE_DOWN, &adapter->state))
 		return;
 
-	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		for (i = 0; i < adapter->num_q_vectors; i++)
-			ixgbe_msix_clean_rings(0, adapter->q_vector[i]);
-	} else {
-		ixgbe_intr(adapter->pdev->irq, netdev);
-	}
-	adapter->flags &= ~IXGBE_FLAG_IN_NETPOLL;
+	/* loop through and schedule all active queues */
+	for (i = 0; i < adapter->num_q_vectors; i++)
+		ixgbe_msix_clean_rings(0, adapter->q_vector[i]);
 }
 
 #endif
