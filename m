From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] ixgbe: Remove IXGBE_FLAG_IN_NETPOLL since it
 doesn't do anything
Date: Mon, 10 Nov 2014 14:50:04 -0800
Message-ID: <20141110224922.7245.35078.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbaKJWuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 17:50:08 -0500
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
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 ++++------------
 2 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 5032a60..c8880a1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -615,7 +615,6 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 4)
 #define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 5)
 #define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 6)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 7)
 #define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
 #define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 9)
 #define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 10)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8e4ba8c..ab14b6b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1590,10 +1590,8 @@ static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
 
 	if (ixgbe_qv_busy_polling(q_vector))
 		netif_receive_skb(skb);
-	else if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		napi_gro_receive(&q_vector->napi, skb);
 	else
-		netif_rx(skb);
+		napi_gro_receive(&q_vector->napi, skb);
 }
 
 /**
@@ -6017,7 +6015,6 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 
 	/* Cause software interrupt to ensure rings are cleaned */
 	ixgbe_irq_rearm_queues(adapter, eics);
-
 }
 
 /**
@@ -7340,14 +7337,9 @@ static void ixgbe_netpoll(struct net_device *netdev)
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
