From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/15] ixgbevf: compare total_rx_packets and budget in ixgbevf_clean_rx_irq
Date: Thu, 20 Nov 2014 15:09:06 -0800
Message-ID: <1416524953-15161-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56512 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757595AbaKTXJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:20 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

total_rx_packets is the number of packets we had cleaned, and budget is
the total number of packets that we could clean per poll. Instead of
altering both of these values we can save ourselves one write to memory by
just comparing total_rx_packets to the budget and as long as we are less
than budget we continue cleaning.

Also change the do{}while logic to while{} in order to avoid processing
packets when budget is 0.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 07222b8..70a2b8f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -809,7 +809,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
 	struct sk_buff *skb = rx_ring->skb;
 
-	do {
+	while (likely(total_rx_packets < budget)) {
 		union ixgbe_adv_rx_desc *rx_desc;
 
 		/* return some buffers to hardware, one at a time is too slow */
@@ -850,7 +850,6 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
-		total_rx_packets++;
 
 		/* Workaround hardware that can't do proper VEPA multicast
 		 * source pruning.
@@ -872,8 +871,8 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		skb = NULL;
 
 		/* update budget accounting */
-		budget--;
-	} while (likely(budget));
+		total_rx_packets++;
+	}
 
 	/* place incomplete frames back on ring for completion */
 	rx_ring->skb = skb;
-- 
1.9.3
