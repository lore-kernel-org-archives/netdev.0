From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH] gro: Partly revert "net: gro: allow to build full sized
 skb"
Date: Thu, 21 Apr 2016 09:40:42 +0200
Message-ID: <20160421074042.GF3347@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45791 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbcDUHkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 03:40:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This partly reverts the below mentioned patch because on
forwarding, such skbs can't be offloaded to a NIC.

We need this to get IPsec GRO for forwarding to work properly,
otherwise the GRO aggregated packets get segmented again by
the GSO layer. Although discovered when implementing IPsec GRO,
this is a general problem in the forwarding path.

-------------------------------------------------------------------------
commit 8a29111c7ca68d928dfab58636f3f6acf0ac04f7
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Oct 8 09:02:23 2013 -0700

    net: gro: allow to build full sized skb

    skb_gro_receive() is currently limited to 16 or 17 MSS per GRO skb,
    typically 24616 bytes, because it fills up to MAX_SKB_FRAGS frags.

    It's relatively easy to extend the skb using frag_list to allow
    more frags to be appended into the last sk_buff.

    This still builds very efficient skbs, and allows reaching 45 MSS per
    skb.

    (45 MSS GRO packet uses one skb plus a frag_list containing 2 additional
    sk_buff)

    High speed TCP flows benefit from this extension by lowering TCP stack
    cpu usage (less packets stored in receive queue, less ACK packets
    processed)

    Forwarding setups could be hurt, as such skbs will need to be
    linearized, although its not a new problem, as GRO could already
    provide skbs with a frag_list.

    We could make the 65536 bytes threshold a tunable to mitigate this.

    (First time we need to linearize skb in skb_needs_linearize(), we could
    lower the tunable to ~16*1460 so that following skb_gro_receive() calls
    build smaller skbs)

    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
---------------------------------------------------------------------------

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---

Hi Eric, this is a followup on our discussion at the netdev
conference. Would you still be ok with this revert, or do
you think there is a better solution in sight?

The full IPsec patchset for what I need this can be found here:

https://git.kernel.org/cgit/linux/kernel/git/klassert/linux-stk.git/log/?h=net-next-ipsec-offload-work

 net/core/skbuff.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4cc594c..fb11a9b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3347,7 +3347,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		int nr_frags = pinfo->nr_frags + i;
 
 		if (nr_frags > MAX_SKB_FRAGS)
-			goto merge;
+			return -E2BIG;
 
 		offset -= headlen;
 		pinfo->nr_frags = nr_frags;
@@ -3380,7 +3380,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		unsigned int first_offset;
 
 		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)
-			goto merge;
+			return -E2BIG;
 
 		first_offset = skb->data -
 			       (unsigned char *)page_address(page) +
@@ -3400,7 +3400,6 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		goto done;
 	}
 
-merge:
 	delta_truesize = skb->truesize;
 	if (offset > headlen) {
 		unsigned int eat = offset - headlen;
-- 
1.9.1
