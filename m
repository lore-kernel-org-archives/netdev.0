From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/9] gre: Fix GRE RX to use skb_transport_header
Date: Wed, 16 Jul 2014 21:14:20 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162059180.3962@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:61481 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaGQEOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:14:21 -0400
Received: by mail-qa0-f74.google.com with SMTP id j15so265643qaq.3
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:14:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE assumes that the GRE header is at skb_network_header +
ip_hrdlen(skb). It is more general to use skb_transport_header
and this allows the possbility of inserting additional header
between IP and GRE (which is what we will done in Generic UDP
Encapsulation for GRE).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_demux.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 0485bf7..b24e511 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -98,7 +98,6 @@ EXPORT_SYMBOL_GPL(gre_build_header);
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			    bool *csum_err)
 {
-	unsigned int ip_hlen = ip_hdrlen(skb);
 	const struct gre_base_hdr *greh;
 	__be32 *options;
 	int hdr_len;
@@ -106,7 +105,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
 		return -EINVAL;
 
-	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
 		return -EINVAL;
 
@@ -116,7 +115,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	if (!pskb_may_pull(skb, hdr_len))
 		return -EINVAL;
 
-	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 	tpi->proto = greh->protocol;
 
 	options = (__be32 *)(greh + 1);
-- 
2.0.0.526.g5318336
