From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 22/33] netfilter: NF_QUEUE vs emergency skbs
Date: Tue, 30 Oct 2007 17:04:23 +0100
Message-ID: <20071030160914.593270000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755889AbXJ3QOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 12:14:09 -0400
Content-Disposition: inline; filename=emergency-nf_queue.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
@@ -181,9 +181,12 @@ next_hook:
 		ret = 1;
 		goto unlock;
 	} else if (verdict == NF_DROP) {
+drop:
 		kfree_skb(*pskb);
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK)  == NF_QUEUE) {
+		if (skb_emergency(*pskb))
+			goto drop;
 		NFDEBUG("nf_hook: Verdict = QUEUE.\n");
 		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))

--

