From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net 4/4] inet: frags: remove INET_FRAG_EVICTED and use list_evictor for the test
Date: Thu, 23 Jul 2015 12:05:40 +0200
Message-ID: <1437645940-7895-5-git-send-email-fw@strlen.de>
References: <1437645940-7895-1-git-send-email-fw@strlen.de>
Cc: Johan Schuijt <johan@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41988 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753324AbbGWKjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 06:39:51 -0400
In-Reply-To: <1437645940-7895-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

We can simply remove the INET_FRAG_EVICTED flag to avoid all the flags
race conditions with the evictor and use a participation test for the
evictor list, when we're at that point (after inet_frag_kill) in the
timer there're 2 possible cases:

1. The evictor added the entry to its evictor list while the timer was
waiting for the chainlock
or
2. The timer unchained the entry and the evictor won't see it

In both cases we should be able to see list_evictor correctly due
to the sync on the chainlock.

Joint work with Florian Westphal.

Tested-by: Frank Schreuder <fschreuder@transip.nl>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h  | 7 +++++--
 net/ipv4/inet_fragment.c | 1 -
 net/ipv4/ip_fragment.c   | 2 +-
 net/ipv6/reassembly.c    | 2 +-
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index e71ca17..53eead2 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -21,13 +21,11 @@ struct netns_frags {
  * @INET_FRAG_FIRST_IN: first fragment has arrived
  * @INET_FRAG_LAST_IN: final fragment has arrived
  * @INET_FRAG_COMPLETE: frag queue has been processed and is due for destruction
- * @INET_FRAG_EVICTED: frag queue is being evicted
  */
 enum {
 	INET_FRAG_FIRST_IN	= BIT(0),
 	INET_FRAG_LAST_IN	= BIT(1),
 	INET_FRAG_COMPLETE	= BIT(2),
-	INET_FRAG_EVICTED	= BIT(3)
 };
 
 /**
@@ -127,6 +125,11 @@ static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f
 		inet_frag_destroy(q, f);
 }
 
+static inline bool inet_frag_evicting(struct inet_frag_queue *q)
+{
+	return !hlist_unhashed(&q->list_evictor);
+}
+
 /* Memory Tracking Functions. */
 
 /* The default percpu_counter batch size is not big enough to scale to
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index a00ca4c..d0a7c03 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -140,7 +140,6 @@ inet_evict_bucket(struct inet_frags *f, struct inet_frag_bucket *hb)
 		if (!del_timer(&fq->timer))
 			continue;
 
-		fq->flags |= INET_FRAG_EVICTED;
 		hlist_add_head(&fq->list_evictor, &expired);
 		++evicted;
 	}
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b4a77d02..921138f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -202,7 +202,7 @@ static void ip_expire(unsigned long arg)
 	ipq_kill(qp);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 
-	if (!(qp->q.flags & INET_FRAG_EVICTED)) {
+	if (!inet_frag_evicting(&qp->q)) {
 		struct sk_buff *head = qp->q.fragments;
 		const struct iphdr *iph;
 		int err;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 5c3bbca..f1159bb 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -144,7 +144,7 @@ void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
 
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 
-	if (fq->q.flags & INET_FRAG_EVICTED)
+	if (inet_frag_evicting(&fq->q))
 		goto out_rcu_unlock;
 
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
-- 
2.0.5
