From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] e1000e: fix bug in restart queue logic
Date: Thu, 16 Apr 2009 19:59:28 -0700
Message-ID: <20090417025928.19671.88859.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:52879 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752989AbZDQC7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 22:59:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

If the e1000e transmit cleanup inner loop exited early, then
cleaned might not be true.  This could cause tx hangs or other
badness.  Use count to track the total number of descriptors
cleaned instead of basing a tx queue restart off of a temporary
working state variable.

This code now makes the flow the same for e1000/e1000e/igb/ixgbe

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1693ed1..ca82f19 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -621,7 +621,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
 	unsigned int count = 0;
-	bool cleaned = false;
 	unsigned int total_tx_bytes = 0, total_tx_packets = 0;
 
 	i = tx_ring->next_to_clean;
@@ -630,7 +629,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
-		for (cleaned = 0; !cleaned; count++) {
+		bool cleaned = false;
+		for (; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
@@ -661,8 +661,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD 32
-	if (cleaned && netif_carrier_ok(netdev) &&
-		     e1000_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD) {
+	if (count && netif_carrier_ok(netdev) &&
+	    e1000_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */

