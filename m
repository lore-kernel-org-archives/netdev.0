From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/3] net: Fix GRE RX to use skb_transport_header for GRE
Date: Tue, 11 Feb 2014 09:43:37 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1402110925240.6562@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ogerlitz@mellanox.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:43515 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaBKRui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:50:38 -0500
Received: by mail-qa0-f74.google.com with SMTP id cm18so1011253qab.1
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 09:50:36 -0800 (PST)
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
index 1863422f..6162269 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -118,7 +118,6 @@ static __sum16 check_checksum(struct sk_buff *skb)
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			    bool *csum_err)
 {
-	unsigned int ip_hlen = ip_hdrlen(skb);
 	const struct gre_base_hdr *greh;
 	__be32 *options;
 	int hdr_len;
@@ -126,7 +125,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
 		return -EINVAL;
 
-	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
 		return -EINVAL;
 
@@ -136,7 +135,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	if (!pskb_may_pull(skb, hdr_len))
 		return -EINVAL;
 
-	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 	tpi->proto = greh->protocol;
 
 	options = (__be32 *)(greh + 1);
-- 
1.9.0.rc1.175.g0b1dcb5
