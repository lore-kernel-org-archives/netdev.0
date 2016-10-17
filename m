From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH V3 RFC 2/2] ixgbe: ixgbe_atr() compute l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 14:12:39 -0700
Message-ID: <07bf787b2a346e12ca6e57edaf1a3025de9ae5dc.1476737917.git.sowmini.varadhan@oracle.com>
References: <cover.1476737917.git.sowmini.varadhan@oracle.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20122 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964894AbcJQVMw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 17:12:52 -0400
In-Reply-To: <cover.1476737917.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1476737917.git.sowmini.varadhan@oracle.com>
References: <cover.1476737917.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some Tx paths (e.g., tpacket_snd()), ixgbe_atr may be
passed down an sk_buff that has the network and transport
header in the paged data, so it needs to make sure these
headers are available in the headlen bytes to calculate the
l4_proto.

This patch expect that network and transport headers are
already available in the non-paged header dat.  The assumption
is that the caller has set this up if l4_proto based Tx
steering is desired.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v3: add unlikely(); remove needless check for hdr.network against
    skb_tail_pointer(); refactor check to make sure we have tcp header
    in non-paged part.

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index eceb47b..a9d2b0c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -54,6 +54,7 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/vxlan.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -7651,11 +7652,17 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	/* snag network header to get L4 type and address */
 	skb = first->skb;
 	hdr.network = skb_network_header(skb);
+	if (unlikely(hdr.network <= skb->data))
+		return;
 	if (skb->encapsulation &&
 	    first->protocol == htons(ETH_P_IP) &&
 	    hdr.ipv4->protocol == IPPROTO_UDP) {
 		struct ixgbe_adapter *adapter = q_vector->adapter;
 
+		if (unlikely(skb_tail_pointer(skb) < hdr.network +
+					    VXLAN_HEADROOM))
+			return;
+
 		/* verify the port is recognized as VXLAN */
 		if (adapter->vxlan_port &&
 		    udp_hdr(skb)->dest == adapter->vxlan_port)
@@ -7666,6 +7673,12 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 			hdr.network = skb_inner_network_header(skb);
 	}
 
+	/* Make sure we have at least [minimum IPv4 header + TCP]
+	 * or [IPv6 header] bytes
+	 */
+	if (unlikely(skb_tail_pointer(skb) < hdr.network + 40))
+		return;
+
 	/* Currently only IPv4/IPv6 with TCP is supported */
 	switch (hdr.ipv4->version) {
 	case IPVERSION:
@@ -7685,6 +7698,10 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	if (l4_proto != IPPROTO_TCP)
 		return;
 
+	if (unlikely(skb_tail_pointer(skb) < hdr.network +
+					     hlen + sizeof(struct tcphdr)))
+			return;
+
 	th = (struct tcphdr *)(hdr.network + hlen);
 
 	/* skip this packet since the socket is closing */
-- 
1.7.1
