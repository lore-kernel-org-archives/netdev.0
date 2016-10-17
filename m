From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH V2 RFC 2/2] ixgbe: ixgbe_atr() compute l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 10:25:07 -0700
Message-ID: <ff985fc71358a90f7a97ca176abb96845852269e.1476724638.git.sowmini.varadhan@oracle.com>
References: <cover.1476724638.git.sowmini.varadhan@oracle.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: sowmini.varadhan@oracle.com, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25572 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938599AbcJQRZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:25:25 -0400
In-Reply-To: <cover.1476724638.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1476724638.git.sowmini.varadhan@oracle.com>
References: <cover.1476724638.git.sowmini.varadhan@oracle.com>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index eceb47b..2cc1dae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -54,6 +54,7 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/vxlan.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -7651,11 +7652,16 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	/* snag network header to get L4 type and address */
 	skb = first->skb;
 	hdr.network = skb_network_header(skb);
+	if (hdr.network <= skb->data || hdr.network >= skb_tail_pointer(skb))
+		return;
 	if (skb->encapsulation &&
 	    first->protocol == htons(ETH_P_IP) &&
 	    hdr.ipv4->protocol == IPPROTO_UDP) {
 		struct ixgbe_adapter *adapter = q_vector->adapter;
 
+		if (skb_tail_pointer(skb) < hdr.network + VXLAN_HEADROOM)
+			return;
+
 		/* verify the port is recognized as VXLAN */
 		if (adapter->vxlan_port &&
 		    udp_hdr(skb)->dest == adapter->vxlan_port)
@@ -7666,15 +7672,27 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 			hdr.network = skb_inner_network_header(skb);
 	}
 
+	/* Make sure we have at least [minimum IPv4 header + TCP]
+	 * or [IPv6 header] bytes
+	 */
+	if (skb_tail_pointer(skb) < hdr.network + 40)
+		return;
+
 	/* Currently only IPv4/IPv6 with TCP is supported */
 	switch (hdr.ipv4->version) {
 	case IPVERSION:
 		/* access ihl as u8 to avoid unaligned access on ia64 */
 		hlen = (hdr.network[0] & 0x0F) << 2;
+		if (skb_tail_pointer(skb) < hdr.network + hlen +
+					    sizeof(struct tcphdr))
+			return;
 		l4_proto = hdr.ipv4->protocol;
 		break;
 	case 6:
 		hlen = hdr.network - skb->data;
+		if (skb_tail_pointer(skb) < hdr.network + hlen +
+					    sizeof(struct tcphdr))
+			return;
 		l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
 		hlen -= hdr.network - skb->data;
 		break;
-- 
1.7.1
