From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ip_gre: fix a possible crash in parse_gre_header()
Date: Thu, 04 Apr 2013 18:41:27 -0700
Message-ID: <1365126087.3308.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:48137 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932334Ab3DEBlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 21:41:31 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so1717670pde.23
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 18:41:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

pskb_may_pull() can change skb->head, so we must init iph/greh after
calling it.

Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code.)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_gre.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e5dfd28..987a4e5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -159,14 +159,14 @@ static int ip_gre_calc_hlen(__be16 o_flags)
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			    bool *csum_err, int *hdr_len)
 {
-	struct iphdr *iph = ip_hdr(skb);
-	struct gre_base_hdr *greh;
+	unsigned int ip_hlen = ip_hdrlen(skb);
+	const struct gre_base_hdr *greh;
 	__be32 *options;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
 		return -EINVAL;
 
-	greh = (struct gre_base_hdr *)((u8 *)iph + (iph->ihl << 2));
+	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
 	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
 		return -EINVAL;
 
@@ -176,6 +176,8 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	if (!pskb_may_pull(skb, *hdr_len))
 		return -EINVAL;
 
+	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
+
 	tpi->proto = greh->protocol;
 
 	options = (__be32 *)(greh + 1);
