From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/30] netvm: filter emergency skbs.
Date: Thu, 20 Mar 2008 21:11:02 +0100
Message-ID: <20080320202124.436150000@chello.nl>
References: <20080320201042.675090000@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:63981 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755896AbYCTUgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 16:36:42 -0400
Content-Disposition: inline; filename=netvm-sk_filter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toss all emergency packets not for a SOCK_MEMALLOC socket. This ensures our
precious memory reserve doesn't get stuck waiting for user-space.

The correctness of this approach relies on the fact that networks must be
assumed lossy.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/include/net/sock.h
===================================================================
--- linux-2.6.orig/include/net/sock.h
+++ linux-2.6/include/net/sock.h
@@ -1007,6 +1007,9 @@ static inline int sk_filter(struct sock 
 {
 	int err;
 	struct sk_filter *filter;
+
+	if (skb_emergency(skb) && !sk_has_memalloc(sk))
+		return -ENOMEM;
 	
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)

--

