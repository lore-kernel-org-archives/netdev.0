From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/8] net: udp: always set up for CHECKSUM_PARTIAL
 offload
Date: Fri, 8 Jan 2016 19:45:34 +0000
Message-ID: <569011DE.7080308@solarflare.com>
References: <56901197.8040808@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:42579 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755885AbcAHTpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 14:45:42 -0500
In-Reply-To: <56901197.8040808@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the dst device doesn't support it, it'll get fixed up later anyway
 by validate_xmit_skb().  Also, this allows us to take advantage of LCO
 to avoid summing the payload multiple times.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/ipv4/udp.c          | 14 +-------------
 net/ipv6/ip6_checksum.c | 13 +------------
 2 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f9bd5db..916d6ea 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -776,23 +776,11 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
 		uh->check = ~udp_v4_check(len, saddr, daddr, lco_csum(skb));
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
-	} else if (skb_dst(skb) && skb_dst(skb)->dev &&
-		   (skb_dst(skb)->dev->features &
-		    (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM))) {
+	} else {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
 		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
-	} else {
-		__wsum csum;
-
-		uh->check = 0;
-		csum = skb_checksum(skb, 0, len, 0);
-		uh->check = udp_v4_check(len, saddr, daddr, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 }
 EXPORT_SYMBOL(udp_set_csum);
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index eba525d..199c191 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -103,22 +103,11 @@ void udp6_set_csum(bool nocheck, struct sk_buff *skb,
 		uh->check = ~udp_v6_check(len, saddr, daddr, csum_fold(lco_csum(skb));
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
-	} else if (skb_dst(skb) && skb_dst(skb)->dev &&
-		   (skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM) {
+	} else {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
 		uh->check = ~udp_v6_check(len, saddr, daddr, 0);
-	} else {
-		__wsum csum;
-
-		uh->check = 0;
-		csum = skb_checksum(skb, 0, len, 0);
-		uh->check = udp_v6_check(len, saddr, daddr, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 }
 EXPORT_SYMBOL(udp6_set_csum);
