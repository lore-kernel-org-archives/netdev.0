From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  07/11] ixgbevf: have clean_rx_irq return total_rx_packets cleaned
Date: Tue, 29 Oct 2013 05:02:27 -0700
Message-ID: <1383048151-15002-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38645 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825Ab3J2MCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:40 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Rather than return true/false indicating whether there was budget left, return
the total packets cleaned. This currently has no use, but will be used in a
following patch which enables CONFIG_NET_RX_BUSY_POLL support in order to track
how many packets were cleaned during the busy poll as part of the extended
statistics.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a2cc6bb..06e29bd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -410,9 +410,9 @@ static inline void ixgbevf_irq_enable_queues(struct ixgbevf_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_VTEIMS, qmask);
 }
 
-static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
-				 struct ixgbevf_ring *rx_ring,
-				 int budget)
+static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
+				struct ixgbevf_ring *rx_ring,
+				int budget)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
 	struct pci_dev *pdev = adapter->pdev;
@@ -540,7 +540,7 @@ next_desc:
 	q_vector->rx.total_packets += total_rx_packets;
 	q_vector->rx.total_bytes += total_rx_bytes;
 
-	return !!budget;
+	return total_rx_packets;
 }
 
 /**
@@ -572,8 +572,9 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 
 	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
 	ixgbevf_for_each_ring(ring, q_vector->rx)
-		clean_complete &= ixgbevf_clean_rx_irq(q_vector, ring,
-						       per_ring_budget);
+		clean_complete &= (ixgbevf_clean_rx_irq(q_vector, ring,
+							per_ring_budget)
+				   < per_ring_budget);
 	adapter->flags &= ~IXGBE_FLAG_IN_NETPOLL;
 
 	/* If all work not completed, return budget and keep polling */
-- 
1.8.3.1
