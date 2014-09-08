From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/5] net: Fix GRE RX to use skb_transport_header for GRE header offset
Date: Sun,  7 Sep 2014 22:26:25 -0700
Message-ID: <1410153989-23837-2-git-send-email-therbert@google.com>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38095 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaIHF1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 01:27:02 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so3985185pad.34
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 22:27:01 -0700 (PDT)
In-Reply-To: <1410153989-23837-1-git-send-email-therbert@google.com>
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
index 7e0756d..4a7b5b2 100644
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
2.1.0.rc2.206.gedb03e5
