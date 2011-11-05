From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 03/11] sch_hfsc.c: rtsc_min() convex/convex case fixup
Date: Sat,  5 Nov 2011 03:32:49 +0100
Message-ID: <1320460377-8682-4-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:2710 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab1KECdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:08 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The condition, which chooses smaller curve in convex/convex case is a bit too
simple. If we actually have intersecting curves, and base the test on initial
(x,y), instead of (x+dx,y+dy), the we can choose wrong curve:

                     +
                *   +
               *++++
       x,y  ++*+
    new ++++ *
            *
        ****
old ****

>From the above art, (x,y) will win the comparison and old curve will be chosen,
but it's new that should be selected (as its infinite 2nd segment is below the
old one).

Another possibility is to flatten the 1st segment (see hfsc paper), which has
an effect for *y2x() functions to return max x such that f(x) = y. In this way
the old curve would take precedence on the initial part. Worth considering for
another patch.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6b73725..710cbda 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -559,13 +559,21 @@ rtsc_min(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x, u64 y)
 	u32 dsm;
 
 	if (isc->sm1 <= isc->sm2) {
-		/* service curve is convex */
-		y1 = rtsc_x2y(rtsc, x);
-		if (y1 < y)
-			/* the current rtsc is smaller */
-			return;
-		rtsc->x = x;
-		rtsc->y = y;
+		/* service curve is convex or linear */
+		y1 = rtsc_x2y(rtsc, x + isc->dx);
+		if (y1 > y + isc->dy) {
+			/*
+			 * sm1/sm2 junction point is below the old curve, so
+			 * update the curve with ours; note that for strictly
+			 * convex curves a brief part of the first segment
+			 * might be above, but it's important that 2nd infinite
+			 * segment wins (which is below the old curve in this
+			 * case)
+			 */
+			rtsc->x = x;
+			rtsc->y = y;
+		}
+		/* else: the current rtsc is smaller */
 		return;
 	}
 
-- 
1.7.7.1
