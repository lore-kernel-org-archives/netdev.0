From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8736] New: New TC deadlock scenario
Date: Sat, 14 Jul 2007 17:43:55 +0200
Message-ID: <4698EF3B.5070907@trash.net>
References: <bug-8736-10286@http.bugzilla.kernel.org/> <20070711111803.f8f97d98.akpm@linux-foundation.org> <469521F0.1010803@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090105060209020505030002"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: ranko@spidernet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36110 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbXGNPol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 11:44:41 -0400
In-Reply-To: <469521F0.1010803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090105060209020505030002
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Andrew Morton wrote:
> 
>>>http://bugzilla.kernel.org/show_bug.cgi?id=8736
>>>
>>>Here is another scenario I bumped onto - qdisc_watchdog_cancel() and
>>>qdisc_restart() deadlock.
>>>
>>>[...]
>>>DEADLOCK!
> 
> 
> 
> Good catch.
> 
> Please try reverting commit 1936502d00ae6c2aa3931c42f6cf54afaba094f2,
> that should fix it.


Ranko, did you get a chance to test this? I've attached the patch
since it doesn't revert cleanly ..


--------------090105060209020505030002
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: Revert "avoid transmit softirq on watchdog wakeup" optimization

As noticed by Ranko Zivojnovic <ranko@spidernet.net>, calling qdisc_run
from the timer handler can result in deadlock:

> CPU#0
>
> qdisc_watchdog() fires and gets dev->queue_lock
> qdisc_run()...qdisc_restart()...
> -> releases dev->queue_lock and enters dev_hard_start_xmit()
>
> CPU#1
>
> tc del qdisc dev ...
> qdisc_graft()...dev_graft_qdisc()...dev_deactivate()...
> -> grabs dev->queue_lock ...
>
> qdisc_reset()...{cbq,hfsc,htb,netem,tbf}_reset()...qdisc_watchdog_cancel()...
> -> hrtimer_cancel() - waiting for the qdisc_watchdog() to exit, while still
>		        holding dev->queue_lock
>
> CPU#0
>
> dev_hard_start_xmit() returns ...
> -> wants to get dev->queue_lock(!)
>
> DEADLOCK!

The entire optimization is a bit questionable IMO, it moves potentially
large parts of NET_TX_SOFTIRQ work to TIMER_SOFTIRQ/HRTIMER_SOFTIRQ,
which kind of defeats the separation of them.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d92ea26..4fd0bec 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -278,11 +278,7 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	smp_wmb();
-	if (spin_trylock(&dev->queue_lock)) {
-		qdisc_run(dev);
-		spin_unlock(&dev->queue_lock);
-	} else
-		netif_schedule(dev);
+	netif_schedule(dev);
 
 	return HRTIMER_NORESTART;
 }

--------------090105060209020505030002--
