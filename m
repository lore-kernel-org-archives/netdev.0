From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 01/10] net: Drop unecessary enc_features variable
 from tunnel segmentation functions
Date: Fri, 05 Feb 2016 15:20:55 -0800
Message-ID: <20160205232055.18461.43313.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:32842 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbcBEXU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:20:57 -0500
Received: by mail-pf0-f181.google.com with SMTP id w123so76551724pfb.0
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:20:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The enc_features variable isn't necessary since features isn't used
anywhere after we create enc_features so instead just use a destructive AND
on features itself and save ourselves the variable declaration.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |    6 +++---
 net/ipv4/udp_offload.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 5a8ee3282550..02cb1a416c7d 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -19,7 +19,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	netdev_features_t enc_features;
 	int ghl;
 	struct gre_base_hdr *greh;
 	u16 mac_offset = skb->mac_header;
@@ -68,9 +67,10 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 
+	features &= skb->dev->hw_enc_features;
+
 	/* segment inner packet. */
-	enc_features = skb->dev->hw_enc_features & features;
-	segs = skb_mac_gso_segment(skb, enc_features);
+	segs = skb_mac_gso_segment(skb, features);
 	if (IS_ERR_OR_NULL(segs)) {
 		skb_gso_error_unwind(skb, protocol, ghl, mac_offset, mac_len);
 		goto out;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 4c519c1dc161..ce64c2b7ba55 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -37,7 +37,6 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	__be16 protocol = skb->protocol;
-	netdev_features_t enc_features;
 	int udp_offset, outer_hlen;
 	unsigned int oldlen;
 	bool need_csum = !!(skb_shinfo(skb)->gso_type &
@@ -65,9 +64,10 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 			   (skb->dev->features & (is_ipv6 ?
 			    NETIF_F_IPV6_CSUM : NETIF_F_IP_CSUM))));
 
+	features &= skb->dev->hw_enc_features;
+
 	/* segment inner packet. */
-	enc_features = skb->dev->hw_enc_features & features;
-	segs = gso_inner_segment(skb, enc_features);
+	segs = gso_inner_segment(skb, features);
 	if (IS_ERR_OR_NULL(segs)) {
 		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
 				     mac_len);
