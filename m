From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: fix bogus cast in skb_pagelen() and use unsigned
 variables
Date: Sat, 19 Nov 2016 04:08:08 +0300
Message-ID: <20161119010808.GF1200@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35500 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753047AbcKRXIR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:08:17 -0500
Received: by mail-wm0-f68.google.com with SMTP id a20so10857369wme.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 15:08:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) cast to "int" is unnecessary:
   u8 will be promoted to int before decrementing,
   small positive numbers fit into "int", so their values won't be changed
   during promotion.

   Once everything is int including loop counters, signedness doesn't
   matter: 32-bit operations will stay 32-bit operations.

   But! Someone tried to make this loop smart by making everything of
   the same type apparently in an attempt to optimise it.
   Do the optimization, just differently.
   Do the cast where it matters. :^)

2) frag size is unsigned entity and sum of fragments sizes is also
   unsigned.

Make everything unsigned, leave no MOVSX instruction behind.


	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-4 (-4)
	function                                     old     new   delta
	skb_cow_data                                 835     834      -1
	ip_do_fragment                              2549    2548      -1
	ip6_fragment                                3130    3128      -2
	Total: Before=154865032, After=154865028, chg -0.00%


Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/skbuff.h |    6 +++---
 net/ipv4/ip_output.c   |    2 +-
 net/ipv6/ip6_output.c  |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1799,11 +1799,11 @@ static inline unsigned int skb_headlen(const struct sk_buff *skb)
 	return skb->len - skb->data_len;
 }
 
-static inline int skb_pagelen(const struct sk_buff *skb)
+static inline unsigned int skb_pagelen(const struct sk_buff *skb)
 {
-	int i, len = 0;
+	unsigned int i, len = 0;
 
-	for (i = (int)skb_shinfo(skb)->nr_frags - 1; i >= 0; i--)
+	for (i = skb_shinfo(skb)->nr_frags - 1; (int)i >= 0; i--)
 		len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
 	return len + skb_headlen(skb);
 }
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -581,7 +581,7 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	 */
 	if (skb_has_frag_list(skb)) {
 		struct sk_buff *frag, *frag2;
-		int first_len = skb_pagelen(skb);
+		unsigned int first_len = skb_pagelen(skb);
 
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -625,7 +625,7 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 
 	hroom = LL_RESERVED_SPACE(rt->dst.dev);
 	if (skb_has_frag_list(skb)) {
-		int first_len = skb_pagelen(skb);
+		unsigned int first_len = skb_pagelen(skb);
 		struct sk_buff *frag2;
 
 		if (first_len - hlen > mtu ||
