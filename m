From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH net-next] netem: markov loss model transition fix
Date: Tue, 22 Oct 2013 23:27:06 +0200
Message-ID: <1382477226-1869-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	Stefano Salsano <stefano.salsano@uniroma2.it>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36537 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753370Ab3JVV1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 17:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The transition from markov state "3 => lost packets within a burst
period" to "1 => successfully transmitted packets within a gap period"
has no *additional* loss event. The loss already happen for transition
from 1 -> 3, this additional loss will make things go wild.

E.g. transition probabilities:

p13:   10%
p31:  100%

Expected:

Ploss = p13 / (p13 + p31)
Ploss = ~9.09%

... but it isn't. Even worse: we get a double loss - each time.
So simple don't return true to indicate loss, rather break and return
false.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Stefano Salsano <stefano.salsano@uniroma2.it>
Cc: Fabio Ludovici <fabio.ludovici@yahoo.it>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/sched/sch_netem.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a6d788d..6bf9088 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -235,7 +235,6 @@ static bool loss_4state(struct netem_sched_data *q)
 			clg->state = 2;
 		else if (clg->a3 < rnd && rnd < clg->a2 + clg->a3) {
 			clg->state = 1;
-			return true;
 		} else if (clg->a2 + clg->a3 < rnd) {
 			clg->state = 3;
 			return true;
-- 
1.8.4.rc3
