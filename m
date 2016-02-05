From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 06/10] gre: Use GSO flags to determine csum need
 instead of GRE flags
Date: Fri, 05 Feb 2016 15:28:01 -0800
Message-ID: <20160205232801.18529.33991.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33830 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbcBEX2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:28:04 -0500
Received: by mail-pf0-f173.google.com with SMTP id o185so76292456pfb.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:28:03 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the gre checksum path to follow something much closer to
the UDP checksum path.  By doing this we can avoid needing to do as much
header inspection and can just make use of the fields we were already
reading in the sk_buff structure.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |   64 +++++++++++++++++++++++-------------------------
 1 file changed, 30 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 35a8dd35ed4e..c15441b5ff61 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -18,14 +18,14 @@
 static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
+	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	int ghl;
 	struct gre_base_hdr *greh;
 	u16 mac_offset = skb->mac_header;
-	int mac_len = skb->mac_len;
 	__be16 protocol = skb->protocol;
-	int tnl_hlen;
-	bool csum;
+	u16 mac_len = skb->mac_len;
+	int gre_offset, outer_hlen;
+	bool need_csum;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
 				~(SKB_GSO_TCPV4 |
@@ -42,64 +42,60 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	if (!skb->encapsulation)
 		goto out;
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(*greh))))
+	if (unlikely(tnl_hlen < sizeof(struct gre_base_hdr)))
 		goto out;
 
-	greh = (struct gre_base_hdr *)skb_transport_header(skb);
-
-	ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	if (unlikely(ghl < sizeof(*greh)))
+	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
 
-	csum = !!(greh->flags & GRE_CSUM);
-	if (csum)
-		skb->encap_hdr_csum = 1;
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 
 	/* setup inner skb. */
 	skb->protocol = greh->protocol;
 	skb->encapsulation = 0;
-
-	if (unlikely(!pskb_may_pull(skb, ghl)))
-		goto out;
-
-	__skb_pull(skb, ghl);
+	__skb_pull(skb, tnl_hlen);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 
+	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE_CSUM);
+	skb->encap_hdr_csum = need_csum;
+
 	features &= skb->dev->hw_enc_features;
 
 	/* segment inner packet. */
 	segs = skb_mac_gso_segment(skb, features);
 	if (IS_ERR_OR_NULL(segs)) {
-		skb_gso_error_unwind(skb, protocol, ghl, mac_offset, mac_len);
+		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
+				     mac_len);
 		goto out;
 	}
 
+	outer_hlen = skb_tnl_header_len(skb);
+	gre_offset = outer_hlen - tnl_hlen;
 	skb = segs;
-	tnl_hlen = skb_tnl_header_len(skb);
 	do {
-		__skb_push(skb, ghl);
-		if (csum) {
-			__be32 *pcsum;
-
-			skb_reset_transport_header(skb);
-
-			greh = (struct gre_base_hdr *)
-			    skb_transport_header(skb);
-			pcsum = (__be32 *)(greh + 1);
-			*pcsum = 0;
-			*(__sum16 *)pcsum = gso_make_checksum(skb, 0);
-		}
-		__skb_push(skb, tnl_hlen - ghl);
+		__be32 *pcsum;
 
 		skb_reset_inner_headers(skb);
 		skb->encapsulation = 1;
 
-		skb_reset_mac_header(skb);
-		skb_set_network_header(skb, mac_len);
 		skb->mac_len = mac_len;
 		skb->protocol = protocol;
+
+		__skb_push(skb, outer_hlen);
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+		skb_set_transport_header(skb, gre_offset);
+
+		if (!need_csum)
+			continue;
+
+		greh = (struct gre_base_hdr *)skb_transport_header(skb);
+		pcsum = (__be32 *)(greh + 1);
+
+		*pcsum = 0;
+		*(__sum16 *)pcsum = gso_make_checksum(skb, 0);
 	} while ((skb = skb->next));
 out:
 	return segs;
