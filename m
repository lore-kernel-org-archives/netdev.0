From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] e1000: move tbi workaround code into helper function
Date: Fri, 12 Sep 2014 05:33:46 -0700
Message-ID: <1410525231-19851-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31878 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754315AbaILMd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 08:33:58 -0400
In-Reply-To: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Its the same in both handlers.

Signed-off-by: Florian Westphal <fw@strlen.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 63 ++++++++++++++-------------
 1 file changed, 33 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index fe2b9ad..e26a32d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4057,6 +4057,26 @@ static void e1000_tbi_adjust_stats(struct e1000_hw *hw,
 	}
 }
 
+static bool e1000_tbi_should_accept(struct e1000_adapter *adapter,
+				    u8 status, u8 errors,
+				    u32 length, const u8 *data)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u8 last_byte = *(data + length - 1);
+
+	if (TBI_ACCEPT(hw, status, errors, length, last_byte)) {
+		unsigned long irq_flags;
+
+		spin_lock_irqsave(&adapter->stats_lock, irq_flags);
+		e1000_tbi_adjust_stats(hw, &adapter->stats, length, data);
+		spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
+
+		return true;
+	}
+
+	return false;
+}
+
 /**
  * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
@@ -4071,12 +4091,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				     struct e1000_rx_ring *rx_ring,
 				     int *work_done, int work_to_do)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_buffer *buffer_info, *next_buffer;
-	unsigned long irq_flags;
 	u32 length;
 	unsigned int i;
 	int cleaned_count = 0;
@@ -4117,23 +4135,15 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
 		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
-			u8 *mapped;
-			u8 last_byte;
-
-			mapped = page_address(buffer_info->page);
-			last_byte = *(mapped + length - 1);
-			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
-				       last_byte)) {
-				spin_lock_irqsave(&adapter->stats_lock,
-						  irq_flags);
-				e1000_tbi_adjust_stats(hw, &adapter->stats,
-						       length, mapped);
-				spin_unlock_irqrestore(&adapter->stats_lock,
-						       irq_flags);
+			u8 *mapped = page_address(buffer_info->page);
+
+			if (e1000_tbi_should_accept(adapter, status,
+						    rx_desc->errors,
+						    length, mapped)) {
 				length--;
+			} else if (netdev->features & NETIF_F_RXALL) {
+				goto process_skb;
 			} else {
-				if (netdev->features & NETIF_F_RXALL)
-					goto process_skb;
 				/* recycle both page and skb */
 				buffer_info->skb = skb;
 				/* an error means any chain goes out the window
@@ -4284,12 +4294,10 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
 			       int *work_done, int work_to_do)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_buffer *buffer_info, *next_buffer;
-	unsigned long flags;
 	u32 length;
 	unsigned int i;
 	int cleaned_count = 0;
@@ -4339,7 +4347,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		if (adapter->discarding) {
 			/* All receives must fit into a single buffer */
-			e_dbg("Receive packet consumed multiple buffers\n");
+			netdev_dbg(netdev, "Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
 			if (status & E1000_RXD_STAT_EOP)
@@ -4348,18 +4356,13 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		}
 
 		if (unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
-			u8 last_byte = *(skb->data + length - 1);
-			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
-				       last_byte)) {
-				spin_lock_irqsave(&adapter->stats_lock, flags);
-				e1000_tbi_adjust_stats(hw, &adapter->stats,
-						       length, skb->data);
-				spin_unlock_irqrestore(&adapter->stats_lock,
-						       flags);
+			if (e1000_tbi_should_accept(adapter, status,
+						    rx_desc->errors,
+						    length, skb->data)) {
 				length--;
+			} else if (netdev->features & NETIF_F_RXALL) {
+				goto process_skb;
 			} else {
-				if (netdev->features & NETIF_F_RXALL)
-					goto process_skb;
 				/* recycle */
 				buffer_info->skb = skb;
 				goto next_desc;
-- 
1.9.3
