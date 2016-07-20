From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/20] fm10k: wait for queues to drain if stop_hw() fails once
Date: Wed, 20 Jul 2016 15:23:47 -0700
Message-ID: <1469053438-85381-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44560 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755361AbcGTWYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:04 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

It turns out that sometimes during a reset the Tx queues will be
temporarily stuck longer than .stop_hw() expects. Work around this issue
by attempting to .stop_hw() first. If it tails, wait a number of
attempts until the Tx queues appear to be drained. After this, attempt
stop_hw() again. This ensures that we avoid waiting if we don't need to,
such as during the first initialization of a VF, and give the proper
amount of time necessary to recover from most situations. It is possible
that the hardware is actually stuck. For PFs, this is usually fixed by
a datapath reset. Unfortunately the VF cannot request a similar reset
for itself.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h      |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  | 44 +++++++++++++++++++++++----
 3 files changed, 40 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index c8d0817..c4cf08d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -458,6 +458,7 @@ __be16 fm10k_tx_encap_offload(struct sk_buff *skb);
 netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 				  struct fm10k_ring *tx_ring);
 void fm10k_tx_timeout_reset(struct fm10k_intfc *interface);
+u64 fm10k_get_tx_pending(struct fm10k_ring *ring);
 bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring);
 void fm10k_alloc_rx_buffers(struct fm10k_ring *rx_ring, u16 cleaned_count);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index c6a4645..c85fc9894 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1128,7 +1128,7 @@ static u64 fm10k_get_tx_completed(struct fm10k_ring *ring)
 	return ring->stats.packets;
 }
 
-static u64 fm10k_get_tx_pending(struct fm10k_ring *ring)
+u64 fm10k_get_tx_pending(struct fm10k_ring *ring)
 {
 	struct fm10k_intfc *interface = ring->q_vector->interface;
 	struct fm10k_hw *hw = &interface->hw;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4dfd128..7c9b20c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1613,7 +1613,7 @@ void fm10k_down(struct fm10k_intfc *interface)
 {
 	struct net_device *netdev = interface->netdev;
 	struct fm10k_hw *hw = &interface->hw;
-	int err;
+	int err, i = 0, count = 0;
 
 	/* signal that we are down to the interrupt handler and service task */
 	if (test_and_set_bit(__FM10K_DOWN, &interface->state))
@@ -1629,9 +1629,6 @@ void fm10k_down(struct fm10k_intfc *interface)
 	/* reset Rx filters */
 	fm10k_reset_rx_state(interface);
 
-	/* allow 10ms for device to quiesce */
-	usleep_range(10000, 20000);
-
 	/* disable polling routines */
 	fm10k_napi_disable_all(interface);
 
@@ -1642,11 +1639,46 @@ void fm10k_down(struct fm10k_intfc *interface)
 	while (test_and_set_bit(__FM10K_UPDATING_STATS, &interface->state))
 		usleep_range(1000, 2000);
 
+	/* skip waiting for TX DMA if we lost PCIe link */
+	if (FM10K_REMOVED(hw->hw_addr))
+		goto skip_tx_dma_drain;
+
+	/* In some rare circumstances it can take a while for Tx queues to
+	 * quiesce and be fully disabled. Attempt to .stop_hw() first, and
+	 * then if we get ERR_REQUESTS_PENDING, go ahead and wait in a loop
+	 * until the Tx queues have emptied, or until a number of retries. If
+	 * we fail to clear within the retry loop, we will issue a warning
+	 * indicating that Tx DMA is probably hung. Note this means we call
+	 * .stop_hw() twice but this shouldn't cause any problems.
+	 */
+	err = hw->mac.ops.stop_hw(hw);
+	if (err != FM10K_ERR_REQUESTS_PENDING)
+		goto skip_tx_dma_drain;
+
+#define TX_DMA_DRAIN_RETRIES 25
+	for (count = 0; count < TX_DMA_DRAIN_RETRIES; count++) {
+		usleep_range(10000, 20000);
+
+		/* start checking at the last ring to have pending Tx */
+		for (; i < interface->num_tx_queues; i++)
+			if (fm10k_get_tx_pending(interface->tx_ring[i]))
+				break;
+
+		/* if all the queues are drained, we can break now */
+		if (i == interface->num_tx_queues)
+			break;
+	}
+
+	if (count >= TX_DMA_DRAIN_RETRIES)
+		dev_err(&interface->pdev->dev,
+			"Tx queues failed to drain after %d tries. Tx DMA is probably hung.\n",
+			count);
+skip_tx_dma_drain:
 	/* Disable DMA engine for Tx/Rx */
 	err = hw->mac.ops.stop_hw(hw);
 	if (err == FM10K_ERR_REQUESTS_PENDING)
-		dev_info(&interface->pdev->dev,
-			 "due to pending requests hw was not shut down gracefully\n");
+		dev_err(&interface->pdev->dev,
+			"due to pending requests hw was not shut down gracefully\n");
 	else if (err)
 		dev_err(&interface->pdev->dev, "stop_hw failed: %d\n", err);
 
-- 
2.5.5
