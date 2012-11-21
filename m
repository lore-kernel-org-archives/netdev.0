From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ixgbe: Reformat output of ixgbe_dump
Date: Wed, 21 Nov 2012 02:47:27 -0800
Message-ID: <1353494856-12344-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Josh Hay <joshua.a.hay@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28698 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754455Ab2KUKrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2012 05:47:40 -0500
In-Reply-To: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hay <joshua.a.hay@intel.com>

Reformats the output of the Tx/Rx descriptor dumps to more
appropriately align the output of the ixgbe_dump and improve readability.
Prevents empty Tx descriptors from being displayed to decrease the size
of the dump and make it more manageable.

Signed-off-by: Josh Hay <joshua.a.hay@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 75 +++++++++++++++------------
 1 file changed, 41 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 38fc186..004ea6c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -336,11 +336,13 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		goto exit;
 
 	dev_info(&adapter->pdev->dev, "TX Rings Summary\n");
-	pr_info("Queue [NTU] [NTC] [bi(ntc)->dma  ] leng ntw timestamp\n");
+	pr_info(" %s     %s              %s        %s\n",
+		"Queue [NTU] [NTC] [bi(ntc)->dma  ]",
+		"leng", "ntw", "timestamp");
 	for (n = 0; n < adapter->num_tx_queues; n++) {
 		tx_ring = adapter->tx_ring[n];
 		tx_buffer = &tx_ring->tx_buffer_info[tx_ring->next_to_clean];
-		pr_info(" %5d %5X %5X %016llX %04X %p %016llX\n",
+		pr_info(" %5d %5X %5X %016llX %08X %p %016llX\n",
 			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
 			   (u64)dma_unmap_addr(tx_buffer, dma),
 			   dma_unmap_len(tx_buffer, len),
@@ -394,40 +396,43 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		pr_info("------------------------------------\n");
 		pr_info("TX QUEUE INDEX = %d\n", tx_ring->queue_index);
 		pr_info("------------------------------------\n");
-		pr_info("T [desc]     [address 63:0  ] "
-			"[PlPOIdStDDt Ln] [bi->dma       ] "
-			"leng  ntw timestamp        bi->skb\n");
+		pr_info("%s%s    %s              %s        %s          %s\n",
+			"T [desc]     [address 63:0  ] ",
+			"[PlPOIdStDDt Ln] [bi->dma       ] ",
+			"leng", "ntw", "timestamp", "bi->skb");
 
 		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
 			tx_desc = IXGBE_TX_DESC(tx_ring, i);
 			tx_buffer = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
-			pr_info("T [0x%03X]    %016llX %016llX %016llX"
-				" %04X  %p %016llX %p", i,
-				le64_to_cpu(u0->a),
-				le64_to_cpu(u0->b),
-				(u64)dma_unmap_addr(tx_buffer, dma),
-				dma_unmap_len(tx_buffer, len),
-				tx_buffer->next_to_watch,
-				(u64)tx_buffer->time_stamp,
-				tx_buffer->skb);
-			if (i == tx_ring->next_to_use &&
-				i == tx_ring->next_to_clean)
-				pr_cont(" NTC/U\n");
-			else if (i == tx_ring->next_to_use)
-				pr_cont(" NTU\n");
-			else if (i == tx_ring->next_to_clean)
-				pr_cont(" NTC\n");
-			else
-				pr_cont("\n");
-
-			if (netif_msg_pktdata(adapter) &&
-			    tx_buffer->skb)
-				print_hex_dump(KERN_INFO, "",
-					DUMP_PREFIX_ADDRESS, 16, 1,
-					tx_buffer->skb->data,
+			if (dma_unmap_len(tx_buffer, len) > 0) {
+				pr_info("T [0x%03X]    %016llX %016llX %016llX %08X %p %016llX %p",
+					i,
+					le64_to_cpu(u0->a),
+					le64_to_cpu(u0->b),
+					(u64)dma_unmap_addr(tx_buffer, dma),
 					dma_unmap_len(tx_buffer, len),
-					true);
+					tx_buffer->next_to_watch,
+					(u64)tx_buffer->time_stamp,
+					tx_buffer->skb);
+				if (i == tx_ring->next_to_use &&
+					i == tx_ring->next_to_clean)
+					pr_cont(" NTC/U\n");
+				else if (i == tx_ring->next_to_use)
+					pr_cont(" NTU\n");
+				else if (i == tx_ring->next_to_clean)
+					pr_cont(" NTC\n");
+				else
+					pr_cont("\n");
+
+				if (netif_msg_pktdata(adapter) &&
+				    tx_buffer->skb)
+					print_hex_dump(KERN_INFO, "",
+						DUMP_PREFIX_ADDRESS, 16, 1,
+						tx_buffer->skb->data,
+						dma_unmap_len(tx_buffer, len),
+						true);
+			}
 		}
 	}
 
@@ -497,11 +502,13 @@ rx_ring_summary:
 		pr_info("------------------------------------\n");
 		pr_info("RX QUEUE INDEX = %d\n", rx_ring->queue_index);
 		pr_info("------------------------------------\n");
-		pr_info("R  [desc]      [ PktBuf     A0] "
-			"[  HeadBuf   DD] [bi->dma       ] [bi->skb] "
+		pr_info("%s%s%s",
+			"R  [desc]      [ PktBuf     A0] ",
+			"[  HeadBuf   DD] [bi->dma       ] [bi->skb       ] ",
 			"<-- Adv Rx Read format\n");
-		pr_info("RWB[desc]      [PcsmIpSHl PtRs] "
-			"[vl er S cks ln] ---------------- [bi->skb] "
+		pr_info("%s%s%s",
+			"RWB[desc]      [PcsmIpSHl PtRs] ",
+			"[vl er S cks ln] ---------------- [bi->skb       ] ",
 			"<-- Adv Rx Write-Back format\n");
 
 		for (i = 0; i < rx_ring->count; i++) {
-- 
1.7.11.7
