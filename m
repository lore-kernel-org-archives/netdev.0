From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Thu, 30 Aug 2007 08:31:10 +0200
Message-ID: <20070830063110.GB1677@ff.dom.local>
References: <46D53D9C.5070204@bigtelecom.ru> <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:34673 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753483AbXH3G3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 02:29:49 -0400
Content-Disposition: inline
In-Reply-To: <20070830001632.ki4u5bx9sow40o4s@mail.himki.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 12:16:32AM +0400, slavon@bigtelecom.ru wrote:
> Quoting Jarek Poplawski <jarkao2@o2.pl>:
> 
> >On Wed, Aug 29, 2007 at 04:53:52PM +0400, Badalian Vyacheslav wrote:
> >...
> >>we have this kernel panic (then delete HTB) at all 2.6.18-x versions.
> >>on older kernel (2.6.x) we have another panic (then delete tc filter)...
> >>summary we have TC panics 1 year ago ;) Sysctl option "reboot on panic"
> >
> >I'm not sure: do you mean it was less often? Did you try to report it
> >here? (Delete HTB: qdisc or classes?)
> >
> 
> i was can't catch bug. now i have configured netconsole to catch panics.
> for every clinet run command like:

If some error repeats you should report it even without logs. Sometimes
people here could help to catch this, but at least they know something
is wrong around and look at the code more carefully.

> 
> ### command to recreate HTB
> tc filter del dev eth1 protocol ip parent 1:0 prio 5 handle 4:9:a1 u32
...

I need more time to think about it.

> In my desktop system i have "Black dead" (2.6.22-r5) All freeze (on  
> monitor KDE desctop. mouse, keyboard, network and other not work. HDD  
> led is on. No panics.)
> 
> Say that info you need. I will try get it.

I still think, at least .config and dmesg could be interesting.

> 
> PS. And also have we have strange bug in another computer (2.6.22-r5).
> Have computer XEON_CPUx2 (4 CPU)
> 
> after boot have CPU0 and CPU3 SI = ~50%
> after some time CPU0 SI = 0% and ksoftirqd/2 process have 100% cpu usage!
> nat-new ~ # cat /proc/interrupts
>            CPU0       CPU1       CPU2       CPU3
>   0:        403          0          0          0   IO-APIC-edge      timer
...
> LOC:   89312505   89314019   89310139   89313972
> ERR:          0
> MIS:          0
> 
> changes only LOC interrupts!
> 
> Maybe its info intresting for you. =)

Yes. It seems something loops or breaks with disabled interrupts. If
it's possible on this box try this 2.6.23-rc4 (and as minimum devices
and as maximum debug options in config as possible). Without anything
in logs or from the screen it could be hard, so maybe you need to
experiment with different configs and kernel versions.

Thanks,
Jarek P.

PS: if it's possible you can try this patch maybe with some fake load
plus these tc scripts (for testing only, linux 2.6.22.5).

---

diff -Nurp linux-2.6.22.5-/net/sched/sch_htb.c linux-2.6.22.5/net/sched/sch_htb.c
--- linux-2.6.22.5-/net/sched/sch_htb.c	2007-07-09 01:32:17.000000000 +0200
+++ linux-2.6.22.5/net/sched/sch_htb.c	2007-08-29 20:32:26.000000000 +0200
@@ -394,6 +394,14 @@ static void htb_safe_rb_erase(struct rb_
 {
 	if (RB_EMPTY_NODE(rb)) {
 		WARN_ON(1);
+	} else if (RB_EMPTY_ROOT(root)) {
+		WARN_ON(1);
+	} else if (((unsigned long)rb & ~3) == 0) {
+		WARN_ON(1);
+	} else if (((unsigned long)root & ~3) == 0) {
+		WARN_ON(1);
+	} else if (rb_parent(rb) == NULL) {
+		WARN_ON(1);
 	} else {
 		rb_erase(rb, root);
 		RB_CLEAR_NODE(rb);
@@ -688,7 +696,11 @@ static void htb_rate_timer(unsigned long
 
 
 	/* lock queue so that we can muck with it */
-	spin_lock_bh(&sch->dev->queue_lock);
+	if (!spin_trylock_bh(&sch->dev->queue_lock)) {
+		q->rttim.expires = jiffies + 1;
+		add_timer(&q->rttim);
+		return;
+	}
 
 	q->rttim.expires = jiffies + HZ;
 	add_timer(&q->rttim);
@@ -1306,7 +1318,8 @@ static void htb_destroy(struct Qdisc *sc
 
 	qdisc_watchdog_cancel(&q->watchdog);
 #ifdef HTB_RATECM
-	del_timer_sync(&q->rttim);
+	if (!del_timer_sync(&q->rttim))
+		del_timer(&q->rttim);
 #endif
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it
