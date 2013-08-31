From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v11 11/11] net: unify skb_udp_tunnel_segment() and skb_udp6_tunnel_segment()
Date: Sat, 31 Aug 2013 11:07:28 +0800
Message-ID: <1377918448-29888-12-git-send-email-amwang@redhat.com>
References: <1377918448-29888-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756238Ab3HaDIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 23:08:21 -0400
In-Reply-To: <1377918448-29888-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As suggested by Pravin, we can unify the code in case of duplicated
code.

Cc: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/udp.c         |   13 ++++++++++-
 net/ipv6/udp_offload.c |   56 +-----------------------------------------------
 2 files changed, 13 insertions(+), 56 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0b24508..74d2c95 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2337,7 +2337,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 		uh->len = htons(skb->len - udp_offset);
 
 		/* csum segment if tunnel sets skb with csum. */
-		if (unlikely(uh->check)) {
+		if (protocol == htons(ETH_P_IP) && unlikely(uh->check)) {
 			struct iphdr *iph = ip_hdr(skb);
 
 			uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
@@ -2348,7 +2348,18 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 			if (uh->check == 0)
 				uh->check = CSUM_MANGLED_0;
 
+		} else if (protocol == htons(ETH_P_IPV6)) {
+			struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+			u32 len = skb->len - udp_offset;
+
+			uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
+						     len, IPPROTO_UDP, 0);
+			uh->check = csum_fold(skb_checksum(skb, udp_offset, len, 0));
+			if (uh->check == 0)
+				uh->check = CSUM_MANGLED_0;
+			skb->ip_summed = CHECKSUM_NONE;
 		}
+
 		skb->protocol = protocol;
 	} while ((skb = skb->next));
 out:
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 7e5e5ac..6055951 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -38,60 +38,6 @@ static int udp6_ufo_send_check(struct sk_buff *skb)
 	return 0;
 }
 
-static struct sk_buff *skb_udp6_tunnel_segment(struct sk_buff *skb,
-					       netdev_features_t features)
-{
-	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	int mac_len = skb->mac_len;
-	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	int outer_hlen;
-	netdev_features_t enc_features;
-
-	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
-		goto out;
-
-	skb->encapsulation = 0;
-	__skb_pull(skb, tnl_hlen);
-	skb_reset_mac_header(skb);
-	skb_set_network_header(skb, skb_inner_network_offset(skb));
-	skb->mac_len = skb_inner_network_offset(skb);
-
-	/* segment inner packet. */
-	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
-	segs = skb_mac_gso_segment(skb, enc_features);
-	if (!segs || IS_ERR(segs))
-		goto out;
-
-	outer_hlen = skb_tnl_header_len(skb);
-	skb = segs;
-	do {
-		struct udphdr *uh;
-		struct ipv6hdr *ipv6h;
-		int udp_offset = outer_hlen - tnl_hlen;
-		u32 len;
-
-		skb->mac_len = mac_len;
-
-		skb_push(skb, outer_hlen);
-		skb_reset_mac_header(skb);
-		skb_set_network_header(skb, mac_len);
-		skb_set_transport_header(skb, udp_offset);
-		uh = udp_hdr(skb);
-		uh->len = htons(skb->len - udp_offset);
-		ipv6h = ipv6_hdr(skb);
-		len = skb->len - udp_offset;
-
-		uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
-					     len, IPPROTO_UDP, 0);
-		uh->check = csum_fold(skb_checksum(skb, udp_offset, len, 0));
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-		skb->ip_summed = CHECKSUM_NONE;
-	} while ((skb = skb->next));
-out:
-	return segs;
-}
-
 static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 					 netdev_features_t features)
 {
@@ -129,7 +75,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 	}
 
 	if (skb->encapsulation && skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
-		segs = skb_udp6_tunnel_segment(skb, features);
+		segs = skb_udp_tunnel_segment(skb, features);
 	else {
 		/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
 		 * do checksum of UDP packets sent as multiple IP fragments.
-- 
1.7.7.6
