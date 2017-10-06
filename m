From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH v2] gso: fix payload length when gso_size is zero
Date: Fri,  6 Oct 2017 19:02:35 +0300
Message-ID: <1507305755-14393-1-git-send-email-alexey.kodanev@oracle.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42562 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752379AbdJFPyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 11:54:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When gso_size reset to zero for the tail segment in skb_segment(), later
in ipv6_gso_segment(), __skb_udp_tunnel_segment() and gre_gso_segment()
we will get incorrect results (payload length, pcsum) for that segment.
inet_gso_segment() already has a check for gso_size before calculating
payload.

The issue was found with LTP vxlan & gre tests over ixgbe NIC.

Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
v2: also added skb_is_gso to gre_gso_segment() and __skb_udp_tunnel_segment()

 net/ipv4/gre_offload.c | 2 +-
 net/ipv4/udp_offload.c | 2 +-
 net/ipv6/ip6_offload.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index d5cac99..8c72034 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -98,7 +98,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		greh = (struct gre_base_hdr *)skb_transport_header(skb);
 		pcsum = (__sum16 *)(greh + 1);
 
-		if (gso_partial) {
+		if (gso_partial && skb_is_gso(skb)) {
 			unsigned int partial_adj;
 
 			/* Adjust checksum to account for the fact that
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 0932c85..6401574 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -122,7 +122,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		 * will be using a length value equal to only one MSS sized
 		 * segment instead of the entire frame.
 		 */
-		if (gso_partial) {
+		if (gso_partial && skb_is_gso(skb)) {
 			uh->len = htons(skb_shinfo(skb)->gso_size +
 					SKB_GSO_CB(skb)->data_offset +
 					skb->head - (unsigned char *)uh);
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index cdb3728..4a87f94 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -105,7 +105,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 	for (skb = segs; skb; skb = skb->next) {
 		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
-		if (gso_partial)
+		if (gso_partial && skb_is_gso(skb))
 			payload_len = skb_shinfo(skb)->gso_size +
 				      SKB_GSO_CB(skb)->data_offset +
 				      skb->head - (unsigned char *)(ipv6h + 1);
-- 
1.8.3.1
