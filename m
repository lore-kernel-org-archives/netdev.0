From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 22/29] ixgbe: lower stack space usage
Date: Thu, 11 Sep 2008 20:03:23 -0700
Message-ID: <20080912030305.6234.33368.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:19113 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034AbYILDDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:03:25 -0400
Received: by rv-out-0506.google.com with SMTP id k40so614761rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:03:25 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

some functions were un-necessarily using local variables.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 257866b..a215350 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -482,7 +482,6 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
                                    struct ixgbe_ring *rx_ring,
                                    int cleaned_count)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
@@ -516,7 +515,8 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		}
 
 		if (!bi->skb) {
-			struct sk_buff *skb = netdev_alloc_skb(netdev, bufsz);
+			struct sk_buff *skb = netdev_alloc_skb(adapter->netdev,
+			                                       bufsz);
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -580,7 +580,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 	                       struct ixgbe_ring *rx_ring,
 	                       int *work_done, int work_to_do)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
@@ -680,9 +679,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		skb->protocol = eth_type_trans(skb, netdev);
+		skb->protocol = eth_type_trans(skb, adapter->netdev);
 		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc);
-		netdev->last_rx = jiffies;
+		adapter->netdev->last_rx = jiffies;
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
@@ -1070,7 +1069,6 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	struct ixgbe_q_vector *q_vector =
 	                       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_ring *rx_ring = NULL;
 	int work_done = 0, i;
 	long r_idx;
@@ -1097,7 +1095,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(adapter->netdev, napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -2284,7 +2282,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	struct ixgbe_q_vector *q_vector = container_of(napi,
 					  struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	int tx_cleaned = 0, work_done = 0;
+	int tx_cleaned, work_done = 0;
 
 #if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
@@ -2307,7 +2305,6 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable(adapter);
 	}
-
 	return work_done;
 }
 

