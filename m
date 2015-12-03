From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/15] ixgbe: Handle extended IPv6 headers in Tx path
Date: Thu,  3 Dec 2015 03:07:21 -0800
Message-ID: <1449140843-118580-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28882 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932973AbbLCLHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:37 -0500
In-Reply-To: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Check for and handle IPv6 extended headers so that Tx checksum
offload can be done. Also use skb_checksum_help for unexpected
cases. Thanks to Tom Herbert for noticing these problems. Thanks
to Alexander Duyck for recognizing problems with the first version
of this patch and recognizing how to coalesce error conditions
into a single location.

Reported-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a10a0fa..ebd4522 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7063,6 +7063,7 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 			struct tcphdr *tcphdr;
 			u8 *raw;
 		} transport_hdr;
+		__be16 frag_off;
 
 		if (skb->encapsulation) {
 			network_hdr.raw = skb_inner_network_header(skb);
@@ -7086,13 +7087,17 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 		case 6:
 			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
 			l4_hdr = network_hdr.ipv6->nexthdr;
+			if (likely((transport_hdr.raw - network_hdr.raw) ==
+				   sizeof(struct ipv6hdr)))
+				break;
+			ipv6_skip_exthdr(skb, network_hdr.raw - skb->data +
+					      sizeof(struct ipv6hdr),
+					 &l4_hdr, &frag_off);
+			if (unlikely(frag_off))
+				l4_hdr = NEXTHDR_FRAGMENT;
 			break;
 		default:
-			if (unlikely(net_ratelimit())) {
-				dev_warn(tx_ring->dev,
-					 "partial checksum but version=%d\n",
-					 network_hdr.ipv4->version);
-			}
+			break;
 		}
 
 		switch (l4_hdr) {
@@ -7113,16 +7118,18 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but l4 proto=%x!\n",
-				 l4_hdr);
+					 "partial checksum, version=%d, l4 proto=%x\n",
+					 network_hdr.ipv4->version, l4_hdr);
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
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
 
-- 
2.5.0
