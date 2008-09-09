From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 22/24] ixgbe: lower stack space usage
Date: Mon, 08 Sep 2008 21:48:31 -0700
Message-ID: <20080909044831.18904.1010.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:12033 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbYIIEsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:33 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1350381waf.23
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:32 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
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
index 8916f07..3f529b9 100644
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
 

