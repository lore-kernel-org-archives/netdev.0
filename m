From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/28] netvm: filter emergency skbs.
Date: Wed, 20 Feb 2008 15:46:28 +0100
Message-ID: <20080220150307.640565000@chello.nl>
References: <20080220144610.548202000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:35879 "EHLO
	viefep16-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932324AbYBTP2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:28:14 -0500
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
@@ -998,6 +998,9 @@ static inline int sk_filter(struct sock 
 {
 	int err;
 	struct sk_filter *filter;
+
+	if (skb_emergency(skb) && !sk_has_memalloc(sk))
+		return -ENOMEM;
 	
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)

--

