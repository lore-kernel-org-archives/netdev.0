From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2 2/4] ipv4: add defensive check for CHECKSUM_PARTIAL skbs in ip_fragment
Date: Tue, 27 Oct 2015 16:02:13 +0100
Message-ID: <1445958135-19805-3-git-send-email-hannes@stressinduktion.org>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41259 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932667AbbJ0PCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 11:02:25 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3DA332167E
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 11:02:25 -0400 (EDT)
In-Reply-To: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHECKSUM_PARTIAL skbs should never arrive in ip_fragment. If we get one
of those warn about them once and handle them gracefully by recalculating
the checksum.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Benjamin Coddington <bcodding@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_output.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0b02417..3f94a3b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -533,6 +533,11 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 
 	dev = rt->dst.dev;
 
+	/* for offloaded checksums cleanup checksum before fragmentation */
+	if (WARN_ON_ONCE(skb->ip_summed == CHECKSUM_PARTIAL) &&
+	    (err = skb_checksum_help(skb)))
+		goto fail;
+
 	/*
 	 *	Point into the IP datagram header.
 	 */
@@ -657,9 +662,6 @@ slow_path_clean:
 	}
 
 slow_path:
-	/* for offloaded checksums cleanup checksum before fragmentation */
-	if ((skb->ip_summed == CHECKSUM_PARTIAL) && skb_checksum_help(skb))
-		goto fail;
 	iph = ip_hdr(skb);
 
 	left = skb->len - hlen;		/* Space per frame */
-- 
2.5.0
