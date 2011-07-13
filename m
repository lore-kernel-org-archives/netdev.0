From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/2] e1000e: use GFP_KERNEL allocations at init time
Date: Tue, 12 Jul 2011 19:10:12 -0700
Message-ID: <1310523012-25391-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1310523012-25391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26837 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756982Ab1GMCKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 22:10:16 -0400
In-Reply-To: <1310523012-25391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In process and sleep allowed context, favor GFP_KERNEL allocations over
GFP_ATOMIC ones.

-v2: fixed checkpatch.pl warnings

CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ben Greear <greearb@candelatech.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/e1000e/e1000.h  |    2 +-
 drivers/net/e1000e/netdev.c |   37 +++++++++++++++++++++----------------
 2 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index e9d6e0a..638d175 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -334,7 +334,7 @@ struct e1000_adapter {
 			  int *work_done, int work_to_do)
 						____cacheline_aligned_in_smp;
 	void (*alloc_rx_buf) (struct e1000_adapter *adapter,
-			      int cleaned_count);
+			      int cleaned_count, gfp_t gfp);
 	struct e1000_ring *rx_ring;
 
 	u32 rx_int_delay;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ed7a93d..4353ad5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -523,7 +523,7 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
  * @adapter: address of board private structure
  **/
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
-				   int cleaned_count)
+				   int cleaned_count, gfp_t gfp)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -544,7 +544,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			goto map_skb;
 		}
 
-		skb = netdev_alloc_skb_ip_align(netdev, bufsz);
+		skb = __netdev_alloc_skb_ip_align(netdev, bufsz, gfp);
 		if (!skb) {
 			/* Better luck next round */
 			adapter->alloc_rx_buff_failed++;
@@ -589,7 +589,7 @@ map_skb:
  * @adapter: address of board private structure
  **/
 static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
-				      int cleaned_count)
+				      int cleaned_count, gfp_t gfp)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -615,7 +615,7 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 				continue;
 			}
 			if (!ps_page->page) {
-				ps_page->page = alloc_page(GFP_ATOMIC);
+				ps_page->page = alloc_page(gfp);
 				if (!ps_page->page) {
 					adapter->alloc_rx_buff_failed++;
 					goto no_buffers;
@@ -641,8 +641,9 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 			    cpu_to_le64(ps_page->dma);
 		}
 
-		skb = netdev_alloc_skb_ip_align(netdev,
-						adapter->rx_ps_bsize0);
+		skb = __netdev_alloc_skb_ip_align(netdev,
+						  adapter->rx_ps_bsize0,
+						  gfp);
 
 		if (!skb) {
 			adapter->alloc_rx_buff_failed++;
@@ -692,7 +693,7 @@ no_buffers:
  **/
 
 static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
-                                         int cleaned_count)
+					 int cleaned_count, gfp_t gfp)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -713,7 +714,7 @@ static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 			goto check_page;
 		}
 
-		skb = netdev_alloc_skb_ip_align(netdev, bufsz);
+		skb = __netdev_alloc_skb_ip_align(netdev, bufsz, gfp);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			adapter->alloc_rx_buff_failed++;
@@ -724,7 +725,7 @@ static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 check_page:
 		/* allocate a new page if necessary */
 		if (!buffer_info->page) {
-			buffer_info->page = alloc_page(GFP_ATOMIC);
+			buffer_info->page = alloc_page(gfp);
 			if (unlikely(!buffer_info->page)) {
 				adapter->alloc_rx_buff_failed++;
 				break;
@@ -888,7 +889,8 @@ next_desc:
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= E1000_RX_BUFFER_WRITE) {
-			adapter->alloc_rx_buf(adapter, cleaned_count);
+			adapter->alloc_rx_buf(adapter, cleaned_count,
+					      GFP_ATOMIC);
 			cleaned_count = 0;
 		}
 
@@ -900,7 +902,7 @@ next_desc:
 
 	cleaned_count = e1000_desc_unused(rx_ring);
 	if (cleaned_count)
-		adapter->alloc_rx_buf(adapter, cleaned_count);
+		adapter->alloc_rx_buf(adapter, cleaned_count, GFP_ATOMIC);
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
@@ -1230,7 +1232,8 @@ next_desc:
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= E1000_RX_BUFFER_WRITE) {
-			adapter->alloc_rx_buf(adapter, cleaned_count);
+			adapter->alloc_rx_buf(adapter, cleaned_count,
+					      GFP_ATOMIC);
 			cleaned_count = 0;
 		}
 
@@ -1244,7 +1247,7 @@ next_desc:
 
 	cleaned_count = e1000_desc_unused(rx_ring);
 	if (cleaned_count)
-		adapter->alloc_rx_buf(adapter, cleaned_count);
+		adapter->alloc_rx_buf(adapter, cleaned_count, GFP_ATOMIC);
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
@@ -1411,7 +1414,8 @@ next_desc:
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
-			adapter->alloc_rx_buf(adapter, cleaned_count);
+			adapter->alloc_rx_buf(adapter, cleaned_count,
+					      GFP_ATOMIC);
 			cleaned_count = 0;
 		}
 
@@ -1423,7 +1427,7 @@ next_desc:
 
 	cleaned_count = e1000_desc_unused(rx_ring);
 	if (cleaned_count)
-		adapter->alloc_rx_buf(adapter, cleaned_count);
+		adapter->alloc_rx_buf(adapter, cleaned_count, GFP_ATOMIC);
 
 	adapter->total_rx_bytes += total_rx_bytes;
 	adapter->total_rx_packets += total_rx_packets;
@@ -3105,7 +3109,8 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	e1000_configure_tx(adapter);
 	e1000_setup_rctl(adapter);
 	e1000_configure_rx(adapter);
-	adapter->alloc_rx_buf(adapter, e1000_desc_unused(adapter->rx_ring));
+	adapter->alloc_rx_buf(adapter, e1000_desc_unused(adapter->rx_ring),
+			      GFP_KERNEL);
 }
 
 /**
-- 
1.7.6

