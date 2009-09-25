From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 06/13] e1000: fix tx waking queue after queue stopped
	during shutdown
Date: Fri, 25 Sep 2009 15:18:07 -0700
Message-ID: <20090925221807.26715.3976.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:34302 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbZIYWSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:18:36 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This fix closes a race where the adapter can be shutting down while
hard_start_xmit is being called and interrupts are being handled.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 11508af..8c64363 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2733,8 +2733,9 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			size -= 4;
 
 		buffer_info->length = size;
-		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
+		/* set time_stamp *before* dma to help avoid a possible race */
 		buffer_info->time_stamp = jiffies;
+		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
 		buffer_info->next_to_watch = i;
 
 		len -= size;
@@ -2774,8 +2775,8 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 				size -= 4;
 
 			buffer_info->length = size;
-			buffer_info->dma = map[f] + offset;
 			buffer_info->time_stamp = jiffies;
+			buffer_info->dma = map[f] + offset;
 			buffer_info->next_to_watch = i;
 
 			len -= size;
@@ -3459,7 +3460,9 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
-		if (netif_queue_stopped(netdev)) {
+
+		if (netif_queue_stopped(netdev) &&
+		    !(test_bit(__E1000_DOWN, &adapter->flags))) {
 			netif_wake_queue(netdev);
 			++adapter->restart_queue;
 		}
@@ -3469,8 +3472,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = false;
-		if (tx_ring->buffer_info[i].time_stamp &&
-		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp +
+		if (tx_ring->buffer_info[eop].time_stamp &&
+		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))
 		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 
@@ -3492,7 +3495,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 				readl(hw->hw_addr + tx_ring->tdt),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
-				tx_ring->buffer_info[i].time_stamp,
+				tx_ring->buffer_info[eop].time_stamp,
 				eop,
 				jiffies,
 				eop_desc->upper.fields.status);

