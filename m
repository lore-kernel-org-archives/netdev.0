From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] ipv6: gso: make ipv6_gso_segment() stackable
Date: Sun, 20 Oct 2013 20:47:29 -0700
Message-ID: <1382327251-21079-2-git-send-email-edumazet@google.com>
References: <1382327251-21079-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Erik Kline <ek@google.com>, Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:42224 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab3JUDrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 23:47:52 -0400
Received: by mail-yh0-f74.google.com with SMTP id a41so524681yho.1
        for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 20:47:51 -0700 (PDT)
In-Reply-To: <1382327251-21079-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support GSO on SIT tunnels, we need to make
inet_gso_segment() stackable.

It should not assume network header starts right after mac
header.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_offload.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 5c2fc1d..f9b33d8 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -90,6 +90,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	u8 *prevhdr;
 	int offset = 0;
 	bool tunnel;
+	int nhoff;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
 		     ~(SKB_GSO_UDP |
@@ -103,10 +104,16 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       0)))
 		goto out;
 
+	skb_reset_network_header(skb);
+	nhoff = skb_network_header(skb) - skb_mac_header(skb);
 	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
 		goto out;
 
-	tunnel = skb->encapsulation;
+	tunnel = SKB_GSO_CB(skb)->encap_level > 0;
+	if (tunnel)
+		features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	SKB_GSO_CB(skb)->encap_level += sizeof(*ipv6h);
+
 	ipv6h = ipv6_hdr(skb);
 	__skb_pull(skb, sizeof(*ipv6h));
 	segs = ERR_PTR(-EPROTONOSUPPORT);
@@ -123,13 +130,17 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		goto out;
 
 	for (skb = segs; skb; skb = skb->next) {
-		ipv6h = ipv6_hdr(skb);
-		ipv6h->payload_len = htons(skb->len - skb->mac_len -
-					   sizeof(*ipv6h));
+		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
+		ipv6h->payload_len = htons(skb->len - nhoff - sizeof(*ipv6h));
+		if (tunnel) {
+			skb_reset_inner_headers(skb);
+			skb->encapsulation = 1;
+		}
+		skb->network_header = (u8 *)ipv6h - skb->head;
+
 		if (!tunnel && proto == IPPROTO_UDP) {
 			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
-			fptr = (struct frag_hdr *)(skb_network_header(skb) +
-				unfrag_ip6hlen);
+			fptr = (struct frag_hdr *)((u8 *)ipv6h + unfrag_ip6hlen);
 			fptr->frag_off = htons(offset);
 			if (skb->next != NULL)
 				fptr->frag_off |= htons(IP6_MF);
-- 
1.8.4
