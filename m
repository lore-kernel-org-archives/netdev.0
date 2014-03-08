From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbevf: fix skb->pkt_type checks
Date: Sat,  8 Mar 2014 01:25:39 -0800
Message-ID: <1394270741-29926-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51114 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751609AbaCHJ0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:26:00 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

skb->pkt_type is not a bitmask, but contains only value at a time from
the range defined in include/uapi/linux/if_packet.h.

Checking it like if it was a bitmask of values would also cause
PACKET_OTHERHOST, PACKET_LOOPBACK and PACKET_FASTROUTE to be matched by
this check since their lower 2 bits are also set, although that does not
fix a real bug, it is still potentially confusing.

This bogus check was introduced in commit 815cccbf ("ixgbe: add setlink,
getlink support to ixgbe and ixgbevf").

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 57e0cd8..6ac5da2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -516,7 +516,8 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		/* Workaround hardware that can't do proper VEPA multicast
 		 * source pruning.
 		 */
-		if ((skb->pkt_type & (PACKET_BROADCAST | PACKET_MULTICAST)) &&
+		if ((skb->pkt_type == PACKET_BROADCAST ||
+		    skb->pkt_type == PACKET_MULTICAST) &&
 		    ether_addr_equal(rx_ring->netdev->dev_addr,
 				     eth_hdr(skb)->h_source)) {
 			dev_kfree_skb_irq(skb);
-- 
1.8.3.1
