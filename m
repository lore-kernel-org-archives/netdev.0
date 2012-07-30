From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] codel: refine one condition to avoid a nul rec_inv_sqrt
Date: Mon, 30 Jul 2012 08:52:21 +0200
Message-ID: <1343631141.2626.13293.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Anton Mich <lp2s1h@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52261 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab2G3Gw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:52:26 -0400
Received: by wgbdr13 with SMTP id dr13so4553572wgb.1
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 23:52:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

One condition before codel_Newton_step() was not good if
we never left the dropping state for a flow. As a result
rec_inv_sqrt was 0, instead of the ~0 initial value.

codel control law was then set to a very aggressive mode, dropping
many packets before reaching 'target' and recovering from this problem.

To keep codel_vars_init() as efficient as possible, refine
the condition to make sure rec_inv_sqrt initial value is correct

Many thanks to Anton Mich for discovering the issue and suggesting
a fix.

Reported-by: Anton Mich <lp2s1h@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/codel.h |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index 550debf..389cf62 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -305,6 +305,8 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 			}
 		}
 	} else if (drop) {
+		u32 delta;
+
 		if (params->ecn && INET_ECN_set_ce(skb)) {
 			stats->ecn_mark++;
 		} else {
@@ -320,9 +322,11 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 		 * assume that the drop rate that controlled the queue on the
 		 * last cycle is a good starting point to control it now.
 		 */
-		if (codel_time_before(now - vars->drop_next,
+		delta = vars->count - vars->lastcount;
+		if (delta > 1 &&
+		    codel_time_before(now - vars->drop_next,
 				      16 * params->interval)) {
-			vars->count = (vars->count - vars->lastcount) | 1;
+			vars->count = delta;
 			/* we dont care if rec_inv_sqrt approximation
 			 * is not very precise :
 			 * Next Newton steps will correct it quadratically.
