From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 22/30] netfilter: NF_QUEUE vs emergency skbs
Date: Thu, 20 Mar 2008 21:11:04 +0100
Message-ID: <20080320202124.669487000@chello.nl>
References: <20080320201042.675090000@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:14988 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757724AbYCTU1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 16:27:07 -0400
Content-Disposition: inline; filename=emergency-nf_queue.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid memory getting stuck waiting for userspace, drop all emergency packets.
This of course requires the regular storage route to not include an NF_QUEUE
target ;-)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/netfilter/core.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/net/netfilter/core.c
===================================================================
--- linux-2.6.orig/net/netfilter/core.c
+++ linux-2.6/net/netfilter/core.c
@@ -176,9 +176,12 @@ next_hook:
 		ret = 1;
 		goto unlock;
 	} else if (verdict == NF_DROP) {
+drop:
 		kfree_skb(skb);
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
+		if (skb_emergency(*pskb))
+			goto drop;
 		if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;

--

