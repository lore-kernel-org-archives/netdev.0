From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/4] e1000e: commonize tx cleanup routine to match
	e1000 & igb
Date: Thu, 26 Mar 2009 01:05:03 -0700
Message-ID: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:45390 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752937AbZCZIFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:05:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change updates the e1000e tx cleanup routine to more closely match
what already exists in igb and e1000.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 15424ba..1797412 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -621,15 +621,16 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
 	unsigned int count = 0;
-	bool cleaned = 0;
+	bool cleaned;
 	unsigned int total_tx_bytes = 0, total_tx_packets = 0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
-	while (eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
-		for (cleaned = 0; !cleaned; ) {
+	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
+	       (count < tx_ring->count)) {
+		for (cleaned = 0; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
@@ -655,10 +656,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
-#define E1000_TX_WEIGHT 64
-		/* weight of a sort for tx, to avoid endless transmit cleanup */
-		if (count++ == E1000_TX_WEIGHT)
-			break;
 	}
 
 	tx_ring->next_to_clean = i;
@@ -682,8 +679,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = 0;
-		if (tx_ring->buffer_info[eop].time_stamp &&
-		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp
+		if (tx_ring->buffer_info[i].time_stamp &&
+		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp
 			       + (adapter->tx_timeout_factor * HZ))
 		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 			e1000_print_tx_hang(adapter);
@@ -694,7 +691,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	adapter->total_tx_packets += total_tx_packets;
 	adapter->net_stats.tx_bytes += total_tx_bytes;
 	adapter->net_stats.tx_packets += total_tx_packets;
-	return cleaned;
+	return (count < tx_ring->count);
 }
 
 /**
@@ -2010,7 +2007,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 clean_rx:
 	adapter->clean_rx(adapter, &work_done, budget);
 
-	if (tx_cleaned)
+	if (!tx_cleaned)
 		work_done = budget;
 
 	/* If budget not fully consumed, exit the polling mode */

