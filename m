From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 02/13] gro: Partly revert "net: gro: allow to build full sized skb"
Date: Thu, 4 Feb 2016 07:36:55 +0100
Message-ID: <1454567826-13018-3-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36680 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756588AbcBDHFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:50 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This partly reverts the below mentioned patch because on
forwarding, such skbs can't be offloaded to a NIC.

This is just a hack to get IPsec GRO for forwarding to work.
A real fix may consider the proposed solutions in the original
patch, see below.

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
 net/core/skbuff.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 120add40..336a3e9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3224,7 +3224,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		int nr_frags = pinfo->nr_frags + i;
 
 		if (nr_frags > MAX_SKB_FRAGS)
-			goto merge;
+			return -E2BIG;
 
 		offset -= headlen;
 		pinfo->nr_frags = nr_frags;
@@ -3257,7 +3257,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		unsigned int first_offset;
 
 		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)
-			goto merge;
+			return -E2BIG;
 
 		first_offset = skb->data -
 			       (unsigned char *)page_address(page) +
@@ -3277,7 +3277,6 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		goto done;
 	}
 
-merge:
 	delta_truesize = skb->truesize;
 	if (offset > headlen) {
 		unsigned int eat = offset - headlen;
-- 
1.9.1
