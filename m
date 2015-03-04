From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gro: remove obsolete code from
 skb_gro_receive()
Date: Wed, 04 Mar 2015 10:26:40 -0800
Message-ID: <1425493600.5130.208.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:46695 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758748AbbCDS0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 13:26:42 -0500
Received: by igbhl2 with SMTP id hl2so39074948igb.5
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 10:26:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some drivers use copybreak to copy tiny frames into smaller skb,
and this smaller skb might not have skb->head_frag set for various
reasons.

skb_gro_receive() currently doesn't allow to aggregate the smaller skb
into the previous GRO packet if this GRO packet has at least 2 MSS in
it.

Following workload easily demonstrates the problem.

netperf -t TCP_RR -H target -- -r 3000,3000 

(tcpdump shows one GRO packet with 2 MSS, plus one additional packet of
104 bytes that should have been appended.)

It turns out that we can remove code from skb_gro_receive(), because
commit 8a29111c7ca6 ("net: gro: allow to build full sized skb") and its
followups removed the assumption that a GRO packet with a frag_list had
to have an empty head.

Removing this code allows the aggregation of the last (incomplete) frame
in some RPC workloads. Note that tcp_gro_receive() already takes care of
forcing a flush if necessary, including this case.

If we want to avoid using frag_list in the first place (in forwarding
workloads for example, as the outgoing NIC is generally not able to cope
with skbs having a frag_list), we need to address this separately.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/core/skbuff.c |   42 ------------------------------------------
 1 file changed, 42 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 913b94a77060..a9bee7ef6397 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3276,48 +3276,6 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		NAPI_GRO_CB(skb)->free = NAPI_GRO_FREE_STOLEN_HEAD;
 		goto done;
 	}
-	/* switch back to head shinfo */
-	pinfo = skb_shinfo(p);
-
-	if (pinfo->frag_list)
-		goto merge;
-	if (skb_gro_len(p) != pinfo->gso_size)
-		return -E2BIG;
-
-	headroom = skb_headroom(p);
-	nskb = alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
-	if (unlikely(!nskb))
-		return -ENOMEM;
-
-	__copy_skb_header(nskb, p);
-	nskb->mac_len = p->mac_len;
-
-	skb_reserve(nskb, headroom);
-	__skb_put(nskb, skb_gro_offset(p));
-
-	skb_set_mac_header(nskb, skb_mac_header(p) - p->data);
-	skb_set_network_header(nskb, skb_network_offset(p));
-	skb_set_transport_header(nskb, skb_transport_offset(p));
-
-	__skb_pull(p, skb_gro_offset(p));
-	memcpy(skb_mac_header(nskb), skb_mac_header(p),
-	       p->data - skb_mac_header(p));
-
-	skb_shinfo(nskb)->frag_list = p;
-	skb_shinfo(nskb)->gso_size = pinfo->gso_size;
-	pinfo->gso_size = 0;
-	__skb_header_release(p);
-	NAPI_GRO_CB(nskb)->last = p;
-
-	nskb->data_len += p->len;
-	nskb->truesize += p->truesize;
-	nskb->len += p->len;
-
-	*head = nskb;
-	nskb->next = p->next;
-	p->next = NULL;
-
-	p = nskb;
 
 merge:
 	delta_truesize = skb->truesize;
