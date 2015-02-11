From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/7] udp: Set SKB_GSO_UDP_TUNNEL* in UDP GRO path
Date: Tue, 10 Feb 2015 16:30:29 -0800
Message-ID: <1423614633-25042-4-git-send-email-therbert@google.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:56800 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbbBKAau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:50 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so1267306igb.5
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:49 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly set GSO types and skb->encapsulation in the UDP tunnel GRO
complete so that packets are properly represented for GSO. This sets
SKB_GSO_UDP_TUNNEL or SKB_GSO_UDP_TUNNEL_CSUM depending on whether
non-zero checksums were received, and sets SKB_GSO_TUNNEL_REMCSUM if
the remote checksum option was processed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp_offload.c | 13 ++++++++++++-
 net/ipv6/udp_offload.c |  6 +++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index d10f6f4..4915d82 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -402,6 +402,13 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 	}
 
 	rcu_read_unlock();
+
+	if (skb->remcsum_offload)
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TUNNEL_REMCSUM;
+
+	skb->encapsulation = 1;
+	skb_set_inner_mac_header(skb, nhoff + sizeof(struct udphdr));
+
 	return err;
 }
 
@@ -410,9 +417,13 @@ static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
 
-	if (uh->check)
+	if (uh->check) {
+		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL_CSUM;
 		uh->check = ~udp_v4_check(skb->len - nhoff, iph->saddr,
 					  iph->daddr, 0);
+	} else {
+		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
+	}
 
 	return udp_gro_complete(skb, nhoff);
 }
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index a562769..ab889bb 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -161,9 +161,13 @@ static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
 
-	if (uh->check)
+	if (uh->check) {
+		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL_CSUM;
 		uh->check = ~udp_v6_check(skb->len - nhoff, &ipv6h->saddr,
 					  &ipv6h->daddr, 0);
+	} else {
+		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
+	}
 
 	return udp_gro_complete(skb, nhoff);
 }
-- 
2.2.0.rc0.207.ga3a616c
