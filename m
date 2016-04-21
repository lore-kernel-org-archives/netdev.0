From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/17] fm10k: fix incorrect IPv6 extended header checksum
Date: Wed, 20 Apr 2016 23:09:29 -0700
Message-ID: <1461218969-68578-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8320 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbcDUGJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:36 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Check for and handle IPv6 extended headers so that Tx checksum offload
can be done. Also use skb_checksum_help for unexpected cases. This was
originally discovered in ixgbe.

Reported-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index b875f42..0e166e9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -820,6 +820,8 @@ static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 		struct ipv6hdr *ipv6;
 		u8 *raw;
 	} network_hdr;
+	u8 *transport_hdr;
+	__be16 frag_off;
 	__be16 protocol;
 	u8 l4_hdr = 0;
 
@@ -837,9 +839,11 @@ static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 			goto no_csum;
 		}
 		network_hdr.raw = skb_inner_network_header(skb);
+		transport_hdr = skb_inner_transport_header(skb);
 	} else {
 		protocol = vlan_get_protocol(skb);
 		network_hdr.raw = skb_network_header(skb);
+		transport_hdr = skb_transport_header(skb);
 	}
 
 	switch (protocol) {
@@ -848,15 +852,17 @@ static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 		break;
 	case htons(ETH_P_IPV6):
 		l4_hdr = network_hdr.ipv6->nexthdr;
+		if (likely((transport_hdr - network_hdr.raw) ==
+			   sizeof(struct ipv6hdr)))
+			break;
+		ipv6_skip_exthdr(skb, network_hdr.raw - skb->data +
+				      sizeof(struct ipv6hdr),
+				 &l4_hdr, &frag_off);
+		if (unlikely(frag_off))
+			l4_hdr = NEXTHDR_FRAGMENT;
 		break;
 	default:
-		if (unlikely(net_ratelimit())) {
-			dev_warn(tx_ring->dev,
-				 "partial checksum but ip version=%x!\n",
-				 protocol);
-		}
-		tx_ring->tx_stats.csum_err++;
-		goto no_csum;
+		break;
 	}
 
 	switch (l4_hdr) {
@@ -869,9 +875,10 @@ static void fm10k_tx_csum(struct fm10k_ring *tx_ring,
 	default:
 		if (unlikely(net_ratelimit())) {
 			dev_warn(tx_ring->dev,
-				 "partial checksum but l4 proto=%x!\n",
-				 l4_hdr);
+				 "partial checksum, version=%d l4 proto=%x\n",
+				 protocol, l4_hdr);
 		}
+		skb_checksum_help(skb);
 		tx_ring->tx_stats.csum_err++;
 		goto no_csum;
 	}
-- 
2.5.5
