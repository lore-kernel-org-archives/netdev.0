From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 6/6] pkt_sched: sch_htb: Optimize WARN_ONs in
	htb_dequeue_tree() etc.
Date: Tue, 9 Dec 2008 10:21:57 +0000
Message-ID: <20081209102157.GF14862@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:44025 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705AbYLIKWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 05:22:02 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1033647ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 02:22:01 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can skip WARN_ON() in htb_dequeue_tree() because there should be
always a similar warning from htb_lookup_leaf() earlier.

The first WARN_ON() in in htb_lookup_leaf() is changed to BUG_ON()
because most likly this should end with oops anyway.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f44a4be..9de3682 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -730,7 +730,7 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 		u32 *pid;
 	} stk[TC_HTB_MAXDEPTH], *sp = stk;
 
-	WARN_ON(!tree->rb_node);
+	BUG_ON(!tree->rb_node);
 	sp->root = tree->rb_node;
 	sp->pptr = pptr;
 	sp->pid = pid;
@@ -750,9 +750,10 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 				*sp->pptr = (*sp->pptr)->rb_left;
 			if (sp > stk) {
 				sp--;
-				WARN_ON(!*sp->pptr);
-				if (!*sp->pptr)
+				if (!*sp->pptr) {
+					WARN_ON(1);
 					return NULL;
+				}
 				htb_next_rb_node(sp->pptr);
 			}
 		} else {
@@ -783,8 +784,7 @@ static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
 
 	do {
 next:
-		WARN_ON(!cl);
-		if (!cl)
+		if (unlikely(!cl))
 			return NULL;
 
 		/* class can be empty - it is unlikely but can be true if leaf
-- 
1.5.6.5

