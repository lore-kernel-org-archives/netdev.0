From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] 6lowpan: reassembly: un-export local functions
Date: Thu, 13 Mar 2014 20:58:03 +0100
Message-ID: <1394740683-6910-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Alexander Aring <alex.aring@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42191 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753171AbaCMUCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 16:02:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

most of these are only used locally, make them static.
fold lowpan_expire_frag_queue into its caller, its small enough.

Cc: Alexander Aring <alex.aring@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Compile tested only.

 Seems this was cloned off ipv6/reassembly.c which exports
 some function for ipv6 netfilter defrag, these exports
 seem to be unneeded for 6lowpan.

 net/ieee802154/reassembly.c | 30 +++++++++++-------------------
 1 file changed, 11 insertions(+), 19 deletions(-)

diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index f4ac957..1dae199 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -58,7 +58,7 @@ static unsigned int lowpan_hashfn(struct inet_frag_queue *q)
 	return lowpan_hash_frag(fq->tag, fq->d_size, &fq->saddr, &fq->daddr);
 }
 
-bool lowpan_frag_match(struct inet_frag_queue *q, void *a)
+static bool lowpan_frag_match(struct inet_frag_queue *q, void *a)
 {
 	struct lowpan_frag_queue *fq;
 	struct lowpan_create_arg *arg = a;
@@ -68,9 +68,8 @@ bool lowpan_frag_match(struct inet_frag_queue *q, void *a)
 		ieee802154_addr_addr_equal(&fq->saddr, arg->src) &&
 		ieee802154_addr_addr_equal(&fq->daddr, arg->dst);
 }
-EXPORT_SYMBOL(lowpan_frag_match);
 
-void lowpan_frag_init(struct inet_frag_queue *q, void *a)
+static void lowpan_frag_init(struct inet_frag_queue *q, void *a)
 {
 	struct lowpan_frag_queue *fq;
 	struct lowpan_create_arg *arg = a;
@@ -82,21 +81,6 @@ void lowpan_frag_init(struct inet_frag_queue *q, void *a)
 	fq->saddr = *arg->src;
 	fq->daddr = *arg->dst;
 }
-EXPORT_SYMBOL(lowpan_frag_init);
-
-void lowpan_expire_frag_queue(struct frag_queue *fq, struct inet_frags *frags)
-{
-	spin_lock(&fq->q.lock);
-
-	if (fq->q.last_in & INET_FRAG_COMPLETE)
-		goto out;
-
-	inet_frag_kill(&fq->q, frags);
-out:
-	spin_unlock(&fq->q.lock);
-	inet_frag_put(&fq->q, frags);
-}
-EXPORT_SYMBOL(lowpan_expire_frag_queue);
 
 static void lowpan_frag_expire(unsigned long data)
 {
@@ -106,7 +90,15 @@ static void lowpan_frag_expire(unsigned long data)
 	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
 	net = container_of(fq->q.net, struct net, ieee802154_lowpan.frags);
 
-	lowpan_expire_frag_queue(fq, &lowpan_frags);
+	spin_lock(&fq->q.lock);
+
+	if (fq->q.last_in & INET_FRAG_COMPLETE)
+		goto out;
+
+	inet_frag_kill(&fq->q, &lowpan_frags);
+out:
+	spin_unlock(&fq->q.lock);
+	inet_frag_put(&fq->q, &lowpan_frags);
 }
 
 static inline struct lowpan_frag_queue *
-- 
1.8.1.5
