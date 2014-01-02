From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC 1/7] net: Fix GRE RX to use skb_transport_header for
 offset
Date: Thu, 2 Jan 2014 14:12:37 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021401030.32428@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hkchu@google.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:39318 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbaABWMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:12:38 -0500
Received: by mail-ie0-f202.google.com with SMTP id lx4so3336677iec.3
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:12:37 -0800 (PST)
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
index 5893e99..6fe5036 100644
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
1.8.5.1
