From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/15] ixgbevf: Handle extended IPv6 headers in Tx path
Date: Thu,  3 Dec 2015 03:07:23 -0800
Message-ID: <1449140843-118580-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:63144 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933023AbbLCLHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:38 -0500
In-Reply-To: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Check for and handle IPv6 extended headers so that Tx checksum
offload can be done. Also use skb_checksum_help for unexpected
cases. Thanks to Tom Herbert for noticing these problems. Thanks
to Alexander Duyck for seeing how to coalesce the error handling
into one location.

Reported-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 42b971c..f098952 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3344,6 +3344,7 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 l4_hdr = 0;
+		__be16 frag_off;
 
 		switch (first->protocol) {
 		case htons(ETH_P_IP):
@@ -3354,13 +3355,16 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 		case htons(ETH_P_IPV6):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			l4_hdr = ipv6_hdr(skb)->nexthdr;
+			if (likely(skb_network_header_len(skb) ==
+				   sizeof(struct ipv6hdr)))
+				break;
+			ipv6_skip_exthdr(skb, skb_network_offset(skb) +
+					      sizeof(struct ipv6hdr),
+					 &l4_hdr, &frag_off);
+			if (unlikely(frag_off))
+				l4_hdr = NEXTHDR_FRAGMENT;
 			break;
 		default:
-			if (unlikely(net_ratelimit())) {
-				dev_warn(tx_ring->dev,
-					 "partial checksum but proto=%x!\n",
-					 first->protocol);
-			}
 			break;
 		}
 
@@ -3382,16 +3386,18 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-					 "partial checksum but l4 proto=%x!\n",
-					 l4_hdr);
+					 "partial checksum, l3 proto=%x, l4 proto=%x\n",
+					 first->protocol, l4_hdr);
 			}
-			break;
+			skb_checksum_help(skb);
+			goto no_csum;
 		}
 
 		/* update TX checksum flag */
 		first->tx_flags |= IXGBE_TX_FLAGS_CSUM;
 	}
 
+no_csum:
 	/* vlan_macip_lens: MACLEN, VLAN tag */
 	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
-- 
2.5.0
