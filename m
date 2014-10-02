From: Joe Lawrence <joe.lawrence@stratus.com>
Subject: bug: race in team_{notify_peers,mcast_rejoin} scheduling
Date: Thu, 2 Oct 2014 14:50:28 -0400
Message-ID: <20141002145028.2f62838c@jlaw-desktop.mno.stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c12o148.mxlogic.net ([208.65.145.81]:58278 "EHLO
	p02c12o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbaJBSuh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 14:50:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jiri,

Occasionally on boot I noticed that team_notify_peers_work would get
*very* busy.

With the following debugging added to team_notify_peers:

        netdev_info(team->dev, "%s(%p)\n", __func__, team);
        dump_stack();

I saw the following:

% dmesg | grep -e 'team[0-9]: team_notify_peers' -e 'port_enable' -e 'port_disable'
[   68.340861] team0: team_notify_peers(ffff88104ffa4de0)
[   68.743264]  [<ffffffffa034fd38>] team_port_enable.part.40+0x78/0x90 [team]
[   69.622395] team0: team_notify_peers(ffff88104ffa4de0)
[   69.966758]  [<ffffffffa034ef63>] team_port_disable+0x123/0x160 [team]
[   71.099263] team0: team_notify_peers(ffff88104ffa4de0)
[   71.466243]  [<ffffffffa034fd38>] team_port_enable.part.40+0x78/0x90 [team]
[   72.383788] team0: team_notify_peers(ffff88104ffa4de0)
[   72.744778]  [<ffffffffa034ef63>] team_port_disable+0x123/0x160 [team]
[   73.476190] team0: team_notify_peers(ffff88104ffa4de0)
[   73.830592]  [<ffffffffa034fd38>] team_port_enable.part.40+0x78/0x90 [team]
[   74.796738] team1: team_notify_peers(ffff88104f5df080)
[   75.165577]  [<ffffffffa034fd38>] team_port_enable.part.40+0x78/0x90 [team]
[   75.694968] team1: team_notify_peers(ffff88104f5df080)
[   75.694984]  [<ffffffffa034ef63>] team_port_disable+0x123/0x160 [team]
[   77.316488] team1: team_notify_peers(ffff88104f5df080)
[   77.663122]  [<ffffffffa034fd38>] team_port_enable.part.40+0x78/0x90 [team]
[   78.470488] team1: team_notify_peers(ffff88104f5df080)
[   78.814722]  [<ffffffffa034ef63>] team_port_disable+0x123/0x160 [team]
[   82.690765] team2: team_notify_peers(ffff88083d24df40)
[   83.083540]  [<ffffffffa034fd38>] team_port_enable.part.40+0x78/0x90 [team]
[   83.942458] team2: team_notify_peers(ffff88083d24df40)
[   84.286446]  [<ffffffffa034ef63>] team_port_disable+0x123/0x160 [team]
[   86.089955] team3: team_notify_peers(ffff88083fd14de0)
[   86.453495]  [<ffffffffa034fd38>] team_port_enable.part.40+0x78/0x90 [team]
[   87.267773] team3: team_notify_peers(ffff88083fd14de0)
[   87.610203]  [<ffffffffa034ef63>] team_port_disable+0x123/0x160 [team]

which shows team_port_enable/disable getting invoked in short
succession.  When looking at one of the team's
notify_peers.count_pending value, I saw that it was negative and slowly
counting down from 0xffff...ffff!

This lead me believe that there is a race condition present in
the .count_pending pattern that both team_notify_peers and
team_mcast_rejoin employ.

Can you comment on the following patch/workaround?

Thanks,

-- Joe

-->8-- -->8-- -->8--

>From b11d7dcd051a2f141c1eec0a43c4a4ddf0361d10 Mon Sep 17 00:00:00 2001
From: Joe Lawrence <joe.lawrence@stratus.com>
Date: Thu, 2 Oct 2014 14:24:26 -0400
Subject: [PATCH] team: avoid race condition in scheduling delayed work

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
