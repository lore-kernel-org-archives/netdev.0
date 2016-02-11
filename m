From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Thu, 11 Feb 2016 21:01:07 +0000
Message-ID: <alpine.LFD.2.20.1602112100350.16113@ec-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:22289 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751067AbcBKVBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 16:01:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/ipv4/ip_gre.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7c51c4e..9b31532 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -440,6 +440,17 @@ drop:
 	return 0;
 }
 
+static __sum16 gre_checksum(struct sk_buff *skb)
+{
+	__wsum csum;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		csum = lco_csum(skb);
+	else
+		csum = skb_checksum(skb, 0, skb->len, 0);
+	return csum_fold(csum);
+}
+
 static void build_header(struct sk_buff *skb, int hdr_len, __be16 flags,
 			 __be16 proto, __be32 key, __be32 seq)
 {
@@ -467,8 +478,7 @@ static void build_header(struct sk_buff *skb, int hdr_len, __be16 flags,
 		    !(skb_shinfo(skb)->gso_type &
 		      (SKB_GSO_GRE | SKB_GSO_GRE_CSUM))) {
 			*ptr = 0;
-			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
-								 skb->len, 0));
+			*(__sum16 *)ptr = gre_checksum(skb);
 		}
 	}
 }
@@ -493,7 +503,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 static struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
 					   bool csum)
 {
-	return iptunnel_handle_offloads(skb, csum,
+	return iptunnel_handle_offloads(skb, false,
 					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
 }
 
