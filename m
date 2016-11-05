From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbe: ixgbe_atr() compute l4_proto only if non-paged data has network/transport headers
Date: Sat,  5 Nov 2016 00:54:20 -0700
Message-ID: <1478332461-43147-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:56205 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753923AbcKEHy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:28 -0400
In-Reply-To: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>

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
Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e4a3227..2436984 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -54,6 +54,7 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/vxlan.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -7660,11 +7661,17 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
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
+			     VXLAN_HEADROOM))
+			return;
+
 		/* verify the port is recognized as VXLAN */
 		if (adapter->vxlan_port &&
 		    udp_hdr(skb)->dest == adapter->vxlan_port)
@@ -7675,6 +7682,12 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
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
@@ -7694,6 +7707,10 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	if (l4_proto != IPPROTO_TCP)
 		return;
 
+	if (unlikely(skb_tail_pointer(skb) < hdr.network +
+		     hlen + sizeof(struct tcphdr)))
+		return;
+
 	th = (struct tcphdr *)(hdr.network + hlen);
 
 	/* skip this packet since the socket is closing */
-- 
2.7.4
