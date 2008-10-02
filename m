From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 24/32] netfilter: NF_QUEUE vs emergency skbs
Date: Thu, 02 Oct 2008 15:05:28 +0200
Message-ID: <20081002131609.424438287@chello.nl>
References: <20081002130504.927878499@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54832 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850AbYJBNT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 09:19:27 -0400
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

