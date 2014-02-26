From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] ixgbevf: fix skb->pkt_type checks
Date: Wed, 26 Feb 2014 14:44:00 -0800
Message-ID: <1393454640-19651-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <e1000-devel@lists.sourceforge.net>, <aaron.f.brown@intel.com>,
	<alexander.h.duyck@intel.com>, <jesse.brandeburg@intel.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:25973 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbaBZWoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:44:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->pkt_type is not a bitmask, but contains only value at a time from
the range defined in include/uapi/linux/if_packet.h.

Checking it like if it was a bitmask of values would also cause
PACKET_OTHERHOST, PACKET_LOOPBACK and PACKET_FASTROUTE to be matched by this
check since their lower 2 bits are also set, although that does not fix a real
bug due to how the checks are used, it is still potentially confusing.

This bogus check was introduced in commit 815cccbf ("ixgbe: add setlink,
getlink support to ixgbe and ixgbevf").

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a6af7b7..c6be010 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -516,8 +516,9 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		/* Workaround hardware that can't do proper VEPA multicast
 		 * source pruning.
 		 */
-		if ((skb->pkt_type & (PACKET_BROADCAST | PACKET_MULTICAST)) &&
-		    ether_addr_equal(rx_ring->netdev->dev_addr,
+		if ((skb->pkt_type == PACKET_BROADCAST ||
+		    skb->pkt_type == PACKET_MULTICAST) &&
+		    ether_addr_equal(adapter->netdev->dev_addr,
 				     eth_hdr(skb)->h_source)) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
-- 
1.8.3.2
