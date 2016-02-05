From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 09/10] udp: Use uh->len instead of skb->len to
 compute checksum in segmentation
Date: Fri, 05 Feb 2016 15:28:20 -0800
Message-ID: <20160205232820.18529.77427.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33945 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbcBEX2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:28:21 -0500
Received: by mail-pf0-f179.google.com with SMTP id o185so76295564pfb.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:28:21 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The segmentation code was having to do a bunch of work to pull the
skb->len and strip the udp header offset before the value could be used to
adjust the checksum.  Instead of doing all this work we can just use the
value that goes into uh->len since that is the correct value with the
correct byte order that we need anyway.  By using this value we can save
ourselves a bunch of pain as there is no need to do multiple byte swaps.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/udp_offload.c |   28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 9e4816fc9927..56c4c8b88b28 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -32,20 +32,23 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 					     netdev_features_t features),
 	__be16 new_protocol, bool is_ipv6)
 {
+	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	bool remcsum, need_csum, offload_csum;
+	struct udphdr *uh = udp_hdr(skb);
 	u16 mac_offset = skb->mac_header;
-	int mac_len = skb->mac_len;
-	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	__be16 protocol = skb->protocol;
+	u16 mac_len = skb->mac_len;
 	int udp_offset, outer_hlen;
-	unsigned int oldlen;
-
-	oldlen = (u16)~skb->len;
+	u32 partial;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
 
+	/* adjust partial header checksum to negate old length */
+	partial = (__force u32)uh->check + (__force u16)~uh->len;
+
+	/* setup inner skb. */
 	skb->encapsulation = 0;
 	__skb_pull(skb, tnl_hlen);
 	skb_reset_mac_header(skb);
@@ -89,9 +92,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	udp_offset = outer_hlen - tnl_hlen;
 	skb = segs;
 	do {
-		struct udphdr *uh;
-		int len;
-		__be32 delta;
+		__be16 len;
 
 		if (remcsum)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -105,22 +106,19 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		skb->mac_len = mac_len;
 		skb->protocol = protocol;
 
-		skb_push(skb, outer_hlen);
+		__skb_push(skb, outer_hlen);
 		skb_reset_mac_header(skb);
 		skb_set_network_header(skb, mac_len);
 		skb_set_transport_header(skb, udp_offset);
-		len = skb->len - udp_offset;
+		len = htons(skb->len - udp_offset);
 		uh = udp_hdr(skb);
-		uh->len = htons(len);
+		uh->len = len;
 
 		if (!need_csum)
 			continue;
 
-		delta = htonl(oldlen + len);
-
 		uh->check = ~csum_fold((__force __wsum)
-				       ((__force u32)uh->check +
-					(__force u32)delta));
+				       ((__force u32)len + partial));
 
 		if (skb->encapsulation || !offload_csum) {
 			uh->check = gso_make_checksum(skb, ~uh->check);
