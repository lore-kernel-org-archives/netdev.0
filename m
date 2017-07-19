From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipv6: avoid overflow of offset in ip6_find_1stfragopt
Date: Wed, 19 Jul 2017 22:28:55 +0200
Message-ID: <0f29f7f5eeb18d49879cf18a868fd36dc4d87c52.1500479911.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54162 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932136AbdGSU3P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 16:29:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases, offset can overflow and can cause an infinite loop in
ip6_find_1stfragopt(). Make it unsigned int to prevent the overflow, and
cap it at IPV6_MAXPLEN, since packets larger than that should be invalid.

This problem has been here since before the beginning of git history.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/output_core.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index e9065b8d3af8..abb2c307fbe8 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -78,7 +78,7 @@ EXPORT_SYMBOL(ipv6_select_ident);
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 {
-	u16 offset = sizeof(struct ipv6hdr);
+	unsigned int offset = sizeof(struct ipv6hdr);
 	unsigned int packet_len = skb_tail_pointer(skb) -
 		skb_network_header(skb);
 	int found_rhdr = 0;
@@ -86,6 +86,7 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 
 	while (offset <= packet_len) {
 		struct ipv6_opt_hdr *exthdr;
+		unsigned int len;
 
 		switch (**nexthdr) {
 
@@ -111,7 +112,10 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 
 		exthdr = (struct ipv6_opt_hdr *)(skb_network_header(skb) +
 						 offset);
-		offset += ipv6_optlen(exthdr);
+		len = ipv6_optlen(exthdr);
+		if (len + offset >= IPV6_MAXPLEN)
+			return -EINVAL;
+		offset += len;
 		*nexthdr = &exthdr->nexthdr;
 	}
 
-- 
2.13.2
