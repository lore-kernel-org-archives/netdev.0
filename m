From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC] ixgbe: ixgbe_atr() must check if network header is
 available in headlen
Date: Sat, 15 Oct 2016 17:31:04 -0400
Message-ID: <20161015213104.GK31471@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com
To: alexander.h.duyck@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51264 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbcJOVbK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 17:31:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For some Tx paths (e.g., tpacket_snd()), ixgbe_atr may be
passed down an sk_buff that has the network and transport
header in the paged data, so it needs to make sure these
headers are available in the headlen bytes to calculate the
l4_proto.

This patch bails out if the headlen is "too short", and does
not attempt to call skb_header_pointer() to get the needed
bytes: the assumption is that the caller should set things
up properly if the l4_proto based tx steering is desired.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a244d9a..0868de1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7632,6 +7632,7 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	struct sk_buff *skb;
 	__be16 vlan_id;
 	int l4_proto;
+	int min_hdr_size = 0;
 
 	/* if ring doesn't have a interrupt vector, cannot perform ATR */
 	if (!q_vector)
@@ -7650,6 +7651,14 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 
 	/* snag network header to get L4 type and address */
 	skb = first->skb;
+	if (first->protocol == htons(ETH_P_IP))
+		min_hdr_size = sizeof(struct iphdr) +
+			       sizeof(struct tcphdr);
+	else if (first->protocol == htons(ETH_P_IPV6))
+		min_hdr_size = sizeof(struct ipv6hdr) +
+			       sizeof(struct tcphdr);
+	if (min_hdr_size && skb_headlen(skb) < ETH_HLEN + min_hdr_size)
+		return;
 	hdr.network = skb_network_header(skb);
 	if (skb->encapsulation &&
 	    first->protocol == htons(ETH_P_IP) &&
-- 
1.7.1
