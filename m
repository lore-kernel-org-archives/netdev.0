From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next v2 3/7] net: Correct comparisons and calculations using skb->tail and skb-transport_header
Date: Wed, 29 May 2013 15:34:25 +0900
Message-ID: <1369809269-13130-4-git-send-email-horms@verge.net.au>
References: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53156 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933784Ab3E2Gdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:33:53 -0400
In-Reply-To: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case skb->tail will be a pointer whereas skb->transport_header
will be an offset from head. This is corrected by using wrappers that
ensure that comparisons and calculations are always made using pointers.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/inet_ecn.h |    6 ++++--
 net/core/dev.c         |    4 ++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index aab7375..3bd2279 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -134,12 +134,14 @@ static inline int INET_ECN_set_ce(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case cpu_to_be16(ETH_P_IP):
-		if (skb->network_header + sizeof(struct iphdr) <= skb->tail)
+		if (skb_network_header(skb) + sizeof(struct iphdr) <=
+		    skb_tail_pointer(skb))
 			return IP_ECN_set_ce(ip_hdr(skb));
 		break;
 
 	case cpu_to_be16(ETH_P_IPV6):
-		if (skb->network_header + sizeof(struct ipv6hdr) <= skb->tail)
+		if (skb_network_header(skb) + sizeof(struct ipv6hdr) <=
+		    skb_tail_pointer(skb))
 			return IP6_ECN_set_ce(ipv6_hdr(skb));
 		break;
 	}
diff --git a/net/core/dev.c b/net/core/dev.c
index b2e9057..d4d874a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1724,7 +1724,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 			skb_reset_mac_header(skb2);
 
 			if (skb_network_header(skb2) < skb2->data ||
-			    skb2->network_header > skb2->tail) {
+			    skb_network_header(skb2) > skb_tail_pointer(skb2)) {
 				net_crit_ratelimited("protocol %04x is buggy, dev %s\n",
 						     ntohs(skb2->protocol),
 						     dev->name);
@@ -3892,7 +3892,7 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
 	NAPI_GRO_CB(skb)->frag0 = NULL;
 	NAPI_GRO_CB(skb)->frag0_len = 0;
 
-	if (skb->mac_header == skb->tail &&
+	if (skb_mac_header(skb) == skb_tail_pointer(skb) &&
 	    pinfo->nr_frags &&
 	    !PageHighMem(skb_frag_page(frag0))) {
 		NAPI_GRO_CB(skb)->frag0 = skb_frag_address(frag0);
-- 
1.7.10.4
