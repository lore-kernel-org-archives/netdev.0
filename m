From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Tue, 13 Mar 2012 21:04:25 -0700
Message-ID: <1331697865.2456.19.camel@edumazet-laptop>
References: <1327570722.8191.46.camel@probook>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>, netdev <netdev@vger.kernel.org>
To: jdb@comx.dk, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38195 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab2CNEE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 00:04:27 -0400
Received: by gghe5 with SMTP id e5so1377228ggh.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 21:04:27 -0700 (PDT)
In-Reply-To: <1327570722.8191.46.camel@probook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit d47a0ac7b6 (sch_sfq: dont put new flow at the end of
flows)

As Jesper found out, patch sounded great but has bad side effects.

In stress situation, pushing new flows in front of the queue can prevent
old flows doing any progress. Packets can stay in SFQ queue for
unlimited amount of time.

It's possible to add heuristics to limit this problem, but this would
add complexity outside of SFQ scope.

A more sensible answer to Dave Taht concerns (who reported the issued I
tried to solve in original commit) is probably to use a qdisc hierarchy
so that high prio packets dont enter a potentially crowded SFQ qdisc.

Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
Cc: Dave Taht <dave.taht@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
I tried various tricks to avoid a revert but in the end it sounds better
to use a single queue.

 net/sched/sch_sfq.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 60d4718..02a21ab 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -469,11 +469,15 @@ enqueue:
 	if (slot->qlen == 1) {		/* The flow is new */
 		if (q->tail == NULL) {	/* It is the first flow */
 			slot->next = x;
-			q->tail = slot;
 		} else {
 			slot->next = q->tail->next;
 			q->tail->next = x;
 		}
+		/* We put this flow at the end of our flow list.
+		 * This might sound unfair for a new flow to wait after old ones,
+		 * but we could endup servicing new flows only, and freeze old ones.
+		 */
+		q->tail = slot;
 		/* We could use a bigger initial quantum for new flows */
 		slot->allot = q->scaled_quantum;
 	}
