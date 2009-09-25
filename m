From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 07/13] e1000: two workarounds were incomplete, fix them
Date: Fri, 25 Sep 2009 15:18:41 -0700
Message-ID: <20090925221841.26715.68566.stgit@localhost.localdomain>
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
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:58227 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752967AbZIYWS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:18:56 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

1) 82544 does not need last_tx_tso workaround, it interferes with the 82544
workaround too
2) 82544 hang workaround was using the address of the page struct instead of
the physical address as its "workaround decider" not sure how that ever worked

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8c64363..cdbf4fb 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2416,6 +2416,11 @@ enum latency_range {
 
 /**
  * e1000_update_itr - update the dynamic ITR value based on statistics
+ * @adapter: pointer to adapter
+ * @itr_setting: current adapter->itr
+ * @packets: the number of packets during this measurement interval
+ * @bytes: the number of bytes during this measurement interval
+ *
  *      Stores a new ITR value based on packets and byte
  *      counts during the last interrupt.  The advantage of per interrupt
  *      computation is faster updates and more accurate ITR for the current
@@ -2425,10 +2430,6 @@ enum latency_range {
  *      while increasing bulk throughput.
  *      this functionality is controlled by the InterruptThrottleRate module
  *      parameter (see e1000_param.c)
- * @adapter: pointer to adapter
- * @itr_setting: current adapter->itr
- * @packets: the number of packets during this measurement interval
- * @bytes: the number of bytes during this measurement interval
  **/
 static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 				     u16 itr_setting, int packets, int bytes)
@@ -2770,8 +2771,9 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			 * Avoid terminating buffers within evenly-aligned
 			 * dwords. */
 			if (unlikely(adapter->pcix_82544 &&
-			   !((unsigned long)(frag->page+offset+size-1) & 4) &&
-			   size > 4))
+			    !((unsigned long)(page_to_phys(frag->page) + offset
+			                      + size - 1) & 4) &&
+			    size > 4))
 				size -= 4;
 
 			buffer_info->length = size;
@@ -3042,7 +3044,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	}
 
 	if (likely(tso)) {
-		tx_ring->last_tx_tso = 1;
+		if (likely(hw->mac_type != e1000_82544))
+			tx_ring->last_tx_tso = 1;
 		tx_flags |= E1000_TX_FLAGS_TSO;
 	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;

