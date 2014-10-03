From: Joe Lawrence <joe.lawrence@stratus.com>
Subject: [PATCH] team: avoid race condition in scheduling delayed work
Date: Fri, 3 Oct 2014 09:58:34 -0400
Message-ID: <1412344714-29938-1-git-send-email-joe.lawrence@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jiri Pirko <jiri@resnulli.us>,
	Joe Lawrence <joe.lawrence@stratus.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c11o143.mxlogic.net ([208.65.144.76]:36524 "EHLO
	p02c11o143.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbaJCOFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 10:05:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When team_notify_peers and team_mcast_rejoin are called, they both reset
their respective .count_pending atomic variable. Then when the actual
worker function is executed, the variable is atomically decremented.
This pattern introduces a potential race condition where the
.count_pending rolls over and the worker function keeps rescheduling
until .count_pending decrements to zero again:

THREAD 1                           THREAD 2
========                           ========
team_notify_peers(teamX)
  atomic_set count_pending = 1
  schedule_delayed_work
                                   team_notify_peers(teamX)
                                   atomic_set count_pending = 1
team_notify_peers_work
  atomic_dec_and_test
    count_pending = 0
  (return)
                                   schedule_delayed_work
                                   team_notify_peers_work
                                   atomic_dec_and_test
                                     count_pending = -1
                                   schedule_delayed_work
                                   (repeat until count_pending = 0)

Instead of assigning a new value to .count_pending, use atomic_add to
tack-on the additional desired worker function invocations.

Signed-off-by: Joe Lawrence <joe.lawrence@stratus.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
Fixes: fc423ff00df3a19554414ee ("team: add peer notification")
Fixes: 492b200efdd20b8fcfdac87 ("team: add support for sending multicast rejoins")
---
 drivers/net/team/team.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index d46df38..2b87e3f 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -647,7 +647,7 @@ static void team_notify_peers(struct team *team)
 {
 	if (!team->notify_peers.count || !netif_running(team->dev))
 		return;
-	atomic_set(&team->notify_peers.count_pending, team->notify_peers.count);
+	atomic_add(team->notify_peers.count, &team->notify_peers.count_pending);
 	schedule_delayed_work(&team->notify_peers.dw, 0);
 }
 
@@ -687,7 +687,7 @@ static void team_mcast_rejoin(struct team *team)
 {
 	if (!team->mcast_rejoin.count || !netif_running(team->dev))
 		return;
-	atomic_set(&team->mcast_rejoin.count_pending, team->mcast_rejoin.count);
+	atomic_add(team->mcast_rejoin.count, &team->mcast_rejoin.count_pending);
 	schedule_delayed_work(&team->mcast_rejoin.dw, 0);
 }
 
-- 
1.7.10.4
