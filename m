From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 07/10] gre: Use inner_proto to obtain inner header
 protocol
Date: Fri, 05 Feb 2016 15:28:08 -0800
Message-ID: <20160205232807.18529.87448.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36111 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbcBEX2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:28:09 -0500
Received: by mail-pf0-f170.google.com with SMTP id n128so75858401pfn.3
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:28:09 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of parsing headers to determine the inner protocol we can just pull
the value from inner_proto.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index c15441b5ff61..003b0ebbcfdd 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -20,7 +20,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 {
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	struct gre_base_hdr *greh;
 	u16 mac_offset = skb->mac_header;
 	__be16 protocol = skb->protocol;
 	u16 mac_len = skb->mac_len;
@@ -48,15 +47,13 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
 
-	greh = (struct gre_base_hdr *)skb_transport_header(skb);
-
 	/* setup inner skb. */
-	skb->protocol = greh->protocol;
 	skb->encapsulation = 0;
 	__skb_pull(skb, tnl_hlen);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
+	skb->protocol = skb->inner_protocol;
 
 	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE_CSUM);
 	skb->encap_hdr_csum = need_csum;
@@ -75,6 +72,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	gre_offset = outer_hlen - tnl_hlen;
 	skb = segs;
 	do {
+		struct gre_base_hdr *greh;
 		__be32 *pcsum;
 
 		skb_reset_inner_headers(skb);
