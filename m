From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 2/2] ipv6: protect mtu calculation of wrap-around and infinite loop by rounding issues
Date: Wed, 28 Oct 2015 13:21:04 +0100
Message-ID: <1446034864-14022-2-git-send-email-hannes@stressinduktion.org>
References: <1446034864-14022-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45173 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932185AbbJ1MVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 08:21:12 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id A82C92084E
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 08:21:11 -0400 (EDT)
In-Reply-To: <1446034864-14022-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raw sockets with hdrincl enabled can insert ipv6 extension headers
right into the data stream. In case we need to fragment those packets,
we reparse the options header to find the place where we can insert
the fragment header. If the extension headers exceed the link's MTU we
actually cannot make progress in such a case.

Instead of ending up in broken arithmetic or rounding towards 0 and
entering an endless loop in ip6_fragment, just prevent those cases by
aborting early and signal -EMSGSIZE to user space.

This is the second version of the patch which doesn't use the
overflow_usub function, which got reverted for now.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d03d6da..f84ec4e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -584,6 +584,8 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 		if (np->frag_size)
 			mtu = np->frag_size;
 	}
+	if (mtu < hlen + sizeof(struct frag_hdr) + 8)
+		goto fail_toobig;
 	mtu -= hlen + sizeof(struct frag_hdr);
 
 	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
-- 
2.4.3
