From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net] ipv6: accept 64k - 1 packet length in ip6_find_1stfragopt()
Date: Fri, 18 Aug 2017 14:40:53 +0200
Message-ID: <9597319ba96a966ee580bd04f36584b52dfa2c48.1503059705.git.sbrivio@redhat.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750993AbdHRMlV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 08:41:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A packet length of exactly IPV6_MAXPLEN is allowed, we should
refuse parsing options only if the size is 64KiB or more.

While at it, remove one extra variable and one assignment which
were also introduced by the commit that introduced the size
check. Checking the sum 'offset + len' and only later adding
'len' to 'offset' doesn't provide any advantage over directly
summing to 'offset' and checking it.

Fixes: 6399f1fae4ec ("ipv6: avoid overflow of offset in ip6_find_1stfragopt")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 net/ipv6/output_core.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index abb2c307fbe8..a338bbc33cf3 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -86,7 +86,6 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 
 	while (offset <= packet_len) {
 		struct ipv6_opt_hdr *exthdr;
-		unsigned int len;
 
 		switch (**nexthdr) {
 
@@ -112,10 +111,9 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 
 		exthdr = (struct ipv6_opt_hdr *)(skb_network_header(skb) +
 						 offset);
-		len = ipv6_optlen(exthdr);
-		if (len + offset >= IPV6_MAXPLEN)
+		offset += ipv6_optlen(exthdr);
+		if (offset > IPV6_MAXPLEN)
 			return -EINVAL;
-		offset += len;
 		*nexthdr = &exthdr->nexthdr;
 	}
 
-- 
2.9.4
