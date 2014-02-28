From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] ixgbevf: fix skb->pkt_type checks
Date: Fri, 28 Feb 2014 15:46:49 -0800
Message-ID: <1393631209-5991-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <aaron.f.brown@intel.com>, <alexander.h.duyck@intel.com>,
	<jesse.brandeburg@intel.com>, <e1000-devel@lists.sourceforge.net>,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:33275 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbaB1XrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 18:47:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->pkt_type is not a bitmask, but contains only value at a time from
the range defined in include/uapi/linux/if_packet.h.

Checking it like if it was a bitmask of values would also cause
PACKET_OTHERHOST, PACKET_LOOPBACK and PACKET_FASTROUTE to be matched by
this check since their lower 2 bits are also set, although that does not
fix a real bug, it is still potentially confusing.

This bogus check was introduced in commit 815cccbf ("ixgbe: add setlink,
getlink support to ixgbe and ixgbevf").

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- properly resolve the rebase, fixes the build failure in v1

 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 57e0cd89b3dc..6ac5da219150 100644
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
1.8.3.2
