From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 5/5] sched: place state, next_sched and gso_skb in same cacheline again
Date: Thu,  9 Jun 2016 00:27:43 +0200
Message-ID: <1465424863-18456-6-git-send-email-fw@strlen.de>
References: <1465424863-18456-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60742 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1424775AbcFHW1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 18:27:42 -0400
In-Reply-To: <1465424863-18456-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Earlier commits removed two members from struct Qdisc which places
next_sched/gso_skb into a different cacheline than ->state.

This restores the struct layout to what it was before the removal.
Move the two members, then add an annotation so they all reside in the
same cacheline.

This adds a 16 byte hole after cpu_qstats.

The hole could be closed but as it doesn't decrease total struct size just
do it this way.

Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sch_generic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4dedb7f..49534e2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -71,11 +71,11 @@ struct Qdisc {
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue	__percpu *cpu_qstats;
 
-	struct Qdisc		*next_sched;
-	struct sk_buff		*gso_skb;
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
+	struct Qdisc		*next_sched ____cacheline_aligned_in_smp;
+	struct sk_buff		*gso_skb;
 	unsigned long		state;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
-- 
2.7.3
