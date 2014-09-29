From: Joe Lawrence <joe.lawrence@stratus.com>
Subject: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Mon, 29 Sep 2014 11:54:45 -0400
Message-ID: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: Jiri Pirko <jiri@resnulli.us>, Tejun Heo <tj@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c12o148.mxlogic.net ([208.65.145.81]:56270 "EHLO
	p02c12o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbaI2QCN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 12:02:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jiri,

I've been debugging a hang on RHEL7 that seems to originate in the
teaming driver and the team_notify_peers_work/team_mcast_rejoin_work
rtnl_trylock rescheduling logic.  Running a stand-alone minimal driver
mimicing the same schedule_delayed_work(.., 0) reproduces the problem on
RHEL7 and upstream kernels [1].

A quick summary of the hang:

1 - systemd-udevd issues an ioctl that heads down dev_ioctl (grabs the
    rtnl_mutex), dev_ifsioc, dev_change_name and finally
    synchronize_sched.  In every vmcore I've taken of the hang, this
    thread is waiting on the RCU.

2 - A kworker thread goes to 100% CPU.

3 - Inspecting the running thread on the CPU that rcusched reported as
    holding up the RCU grace period usually shows it in either
    team_notify_peers_work, team_mcast_rejoin_work, or somewhere in the
    workqueue code (process_one_work).  This is the same CPU/thread as
    #2.

4 - team_notify_peers_work and team_mcast_rejoin_work want the rtnl_lock
    that systemd-udevd in #1 has, so they try to play nice by calling
    rtnl_trylock and rescheduling on failure.  Unfortunately with 0
    jiffy delay, process_one_work will "execute immediately" (ie, after
    others already in queue, but before the next tick).  With the stock
    RHEL7 !CONFIG_PREEMPT at least, this creates a tight loop on
    process_one_work + rtnl_trylock that spins the CPU in #2.

5 - Sometime minutes later, RCU seems to be kicked by a side effect of
    a smp_apic_timer_interrupt.  (This was the only other interesting
    function reported by ftrace function tracer).

See the patch below for a potential workaround.  Giving at least 1 jiffy
should give process_one_work some breathing room before calling back
into team_notify_peers_work/team_mcast_rejoin_work and attempting to
acquire the rtnl_lock mutex.

Regards,

-- Joe

[1] http://marc.info/?l=linux-kernel&m=141192244232345&w=2

-->8--- -->8--- -->8--- -->8---

>From fc5bbf5771b5732f7479ac6e84bbfdde05710023 Mon Sep 17 00:00:00 2001
From: Joe Lawrence <joe.lawrence@stratus.com>
Date: Mon, 29 Sep 2014 11:09:05 -0400
Subject: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock

Give the CPU running the kworker handling team_notify_peers_work and
team_mcast_rejoin_work functions some scheduling air by specifying a
non-zero delay.

Signed-off-by: Joe Lawrence <joe.lawrence@stratus.com>
---
 drivers/net/team/team.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ef10302..d46df38 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -633,7 +633,7 @@ static void team_notify_peers_work(struct work_struct *work)
 	team = container_of(work, struct team, notify_peers.dw.work);
 
 	if (!rtnl_trylock()) {
-		schedule_delayed_work(&team->notify_peers.dw, 0);
+		schedule_delayed_work(&team->notify_peers.dw, 1);
 		return;
 	}
 	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, team->dev);
@@ -673,7 +673,7 @@ static void team_mcast_rejoin_work(struct work_struct *work)
 	team = container_of(work, struct team, mcast_rejoin.dw.work);
 
 	if (!rtnl_trylock()) {
-		schedule_delayed_work(&team->mcast_rejoin.dw, 0);
+		schedule_delayed_work(&team->mcast_rejoin.dw, 1);
 		return;
 	}
 	call_netdevice_notifiers(NETDEV_RESEND_IGMP, team->dev);
-- 
1.7.10.4
