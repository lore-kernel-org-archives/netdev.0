From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queue 5/7] ixgbe: Remove IXGBE_FLAG_IN_NETPOLL since it doesn't do anything
Date: Fri, 13 Mar 2015 17:00:46 -0700
Message-ID: <1426291248-14739-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, <kernel-team@fb.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19112 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbbCNAAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 20:00:53 -0400
In-Reply-To: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This patch removes some dead code from the cleanup path for ixgbe.

Setting and clearing the flag doesn't do anything since all we are
doing is setting the flag, scheduling NAPI, clearing the flag and
then letting netpoll do the polling cleanup.  As such it doesn't
make much sense to have it there.

This patch also removes one minor white-space error.

CC: <kernel-team@fb.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 18 ++++--------------
 2 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 7dcbbec..7068e9c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -613,7 +613,6 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 4)
 #define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 5)
 #define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 6)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 7)
 #define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
 #define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 9)
 #define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 10)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 581015b..395dc6b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1619,14 +1619,10 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
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
@@ -6172,7 +6168,6 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 
 	/* Cause software interrupt to ensure rings are cleaned */
 	ixgbe_irq_rearm_queues(adapter, eics);
-
 }
 
 /**
@@ -7505,14 +7500,9 @@ static void ixgbe_netpoll(struct net_device *netdev)
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
-- 
1.9.3
