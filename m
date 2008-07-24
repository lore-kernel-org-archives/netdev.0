From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/30] netvm: filter emergency skbs.
Date: Thu, 24 Jul 2008 16:01:02 +0200
Message-ID: <20080724141530.724917290@chello.nl>
References: <20080724140042.408642539@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46453 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756246AbYGXOmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 10:42:37 -0400
Content-Disposition: inline; filename=netvm-sk_filter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toss all emergency packets not for a SOCK_MEMALLOC socket. This ensures our
precious memory reserve doesn't get stuck waiting for user-space.

The correctness of this approach relies on the fact that networks must be
assumed lossy.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/core/filter.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/net/core/filter.c
===================================================================
--- linux-2.6.orig/net/core/filter.c
+++ linux-2.6/net/core/filter.c
@@ -81,6 +81,9 @@ int sk_filter(struct sock *sk, struct sk
 	int err;
 	struct sk_filter *filter;
 
+	if (skb_emergency(skb) && !sk_has_memalloc(sk))
+		return -ENOMEM;
+
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)
 		return err;

-- 

