From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH] ipv6: gso: fix payload length when gso_size is zero
Date: Thu,  5 Oct 2017 20:06:47 +0300
Message-ID: <1507223207-17557-1-git-send-email-alexey.kodanev@oracle.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32750 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbdJEQ6l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:58:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When gso_size reset to zero for the tail segment in skb_segment(), later
in ipv6_gso_segment(), we will get incorrect payload_len for that segment.
inet_gso_segment() already has a check for gso_size before calculating
payload so fixing only IPv6 part.

The issue was found with LTP vxlan & gre tests over ixgbe NIC.

Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 net/ipv6/ip6_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
