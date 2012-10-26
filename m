From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net: compute skb->rxhash if nic hash may be 3-tuple
Date: Fri, 26 Oct 2012 17:52:08 -0400
Message-ID: <1351288328-30147-1-git-send-email-willemb@google.com>
Cc: edumazet@google.com, netdev@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:37661 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964839Ab2JZVwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 17:52:16 -0400
Received: by mail-gg0-f202.google.com with SMTP id i4so420968ggm.1
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 14:52:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network device drivers can communicate a Toeplitz hash in skb->rxhash,
but devices differ in their hashing capabilities. All compute a 5-tuple
hash for TCP over IPv4, but for other connection-oriented protocols,
they may compute only a 3-tuple. This breaks RPS load balancing, e.g.,
for TCP over IPv6 flows. Additionally, for GRE and other tunnels,
the kernel computes a 5-tuple hash over the inner packet if possible,
but devices do not.

This patch recomputes the rxhash in software in all cases where it
cannot be certain that a 5-tuple was computed. Device drivers can avoid
recomputation by setting the skb->l4_rxhash flag.

Recomputing adds cycles to each packet when RPS is enabled or the
packet arrives over a tunnel. A comparison of 200x TCP_STREAM between
two servers running unmodified netnext with rxhash computation
in hardware vs software (using ethtool -K eth0 rxhash [on|off]) shows
how much time is spent in __skb_get_rxhash in this worst case:

     0.03%          swapper  [kernel.kallsyms]     [k] __skb_get_rxhash
     0.03%          swapper  [kernel.kallsyms]     [k] __skb_get_rxhash
     0.05%          swapper  [kernel.kallsyms]     [k] __skb_get_rxhash

With 200x TCP_RR it increases to

     0.10%          netperf  [kernel.kallsyms]     [k] __skb_get_rxhash
     0.10%          netperf  [kernel.kallsyms]     [k] __skb_get_rxhash
     0.10%          netperf  [kernel.kallsyms]     [k] __skb_get_rxhash

I considered having the patch explicitly skips recomputation when it knows
that it will not improve the hash (TCP over IPv4), but that conditional
complicates code without saving many cycles in practice, because it has
to take place after flow dissector.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6a2c34e..a2a0bdb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -643,7 +643,7 @@ extern unsigned int   skb_find_text(struct sk_buff *skb, unsigned int from,
 extern void __skb_get_rxhash(struct sk_buff *skb);
 static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 {
-	if (!skb->rxhash)
+	if (!skb->l4_rxhash)
 		__skb_get_rxhash(skb);
 
 	return skb->rxhash;
-- 
1.7.7.3
