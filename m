From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2 4/4] ipv6: add defensive check for CHECKSUM_PARTIAL skbs in ip_fragment
Date: Tue, 27 Oct 2015 16:02:15 +0100
Message-ID: <1445958135-19805-5-git-send-email-hannes@stressinduktion.org>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:42512 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964780AbbJ0PC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 11:02:27 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 5DEDA216EE
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 11:02:27 -0400 (EDT)
In-Reply-To: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHECKSUM_PARTIAL skbs should never arrive in ip_fragment. If we get one
of those warn about them once and handle them gracefully by recalculating
the checksum.

Fixes: commit 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
See-also: commit 72e843bb09d45 ("ipv6: ip6_fragment() should check CHECKSUM_PARTIAL")
Cc: Eric Dumazet <edumazet@google.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Benjamin Coddington <bcodding@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9828a71..c6c5630 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -605,6 +605,10 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
 				    &ipv6_hdr(skb)->saddr);
 
+	if (WARN_ON_ONCE(skb->ip_summed == CHECKSUM_PARTIAL) &&
+	    (err = skb_checksum_help(skb)))
+		goto fail;
+
 	hroom = LL_RESERVED_SPACE(rt->dst.dev);
 	if (skb_has_frag_list(skb)) {
 		int first_len = skb_pagelen(skb);
@@ -733,10 +737,6 @@ slow_path_clean:
 	}
 
 slow_path:
-	if ((skb->ip_summed == CHECKSUM_PARTIAL) &&
-	    skb_checksum_help(skb))
-		goto fail;
-
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = hlen;			/* Where to start from */
 
-- 
2.5.0
