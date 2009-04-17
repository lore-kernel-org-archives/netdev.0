From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] e1000: fix transmit routine exit bug
Date: Thu, 16 Apr 2009 19:59:47 -0700
Message-ID: <20090417025946.19671.21412.stgit@localhost.localdomain>
References: <20090417025928.19671.88859.stgit@localhost.localdomain>
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
	by vger.kernel.org with ESMTP id S1754736AbZDQDAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 23:00:03 -0400
In-Reply-To: <20090417025928.19671.88859.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

If the e1000 transmit cleanup inner loop exited early, then
cleaned might not be true.  This could cause tx hangs or other
badness.  Use count to track the total number of descriptors
cleaned instead of basing a tx queue restart off of a temporary
working state variable.

This code now makes the flow the same for e1000/e1000e/igb/ixgbe

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ef12931..6a46cee 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3834,7 +3834,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
 	unsigned int count = 0;
-	bool cleaned = false;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
@@ -3843,7 +3842,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
-		for (cleaned = false; !cleaned; count++) {
+		bool cleaned = false;
+		for ( ; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
@@ -3871,7 +3871,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD 32
-	if (unlikely(cleaned && netif_carrier_ok(netdev) &&
+	if (unlikely(count && netif_carrier_ok(netdev) &&
 		     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.

