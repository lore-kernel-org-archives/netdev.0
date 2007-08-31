From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 11:05:09 +0200
Message-ID: <20070831090509.GC1772@ff.dom.local>
References: <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:56239 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756900AbXHaJDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 05:03:46 -0400
Content-Disposition: inline
In-Reply-To: <46D7D072.5060508@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 12:25:22PM +0400, Badalian Vyacheslav wrote:
> i not have testing mashine.
> we have 2 mashine and dynamic routing. if 1 mashine down - all traffic 
> go to second mashine.
> I can test is on this mashines but i need that testing mashine will 
> reboot on kernel panic (sysctl message). No freezes =)
> 
> Ok. i try 2.6.23-rc4.

...but without testing machine it can be too much risk! New versions
of kernel can break your applications (sometimes they should be at
least rebuilded).

So, maybe you would better try this, 'less testing', version of my patch:

Jarek P.

---

diff -Nurp linux-2.6.22.5-/net/sched/sch_htb.c linux-2.6.22.5/net/sched/sch_htb.c
--- linux-2.6.22.5-/net/sched/sch_htb.c	2007-07-09 01:32:17.000000000 +0200
+++ linux-2.6.22.5/net/sched/sch_htb.c	2007-08-31 08:43:45.000000000 +0200
@@ -688,7 +688,11 @@ static void htb_rate_timer(unsigned long
 
 
 	/* lock queue so that we can muck with it */
-	spin_lock_bh(&sch->dev->queue_lock);
+	if (!spin_trylock_bh(&sch->dev->queue_lock)) {
+		q->rttim.expires = jiffies + 1;
+		add_timer(&q->rttim);
+		return;
+	}
 
 	q->rttim.expires = jiffies + HZ;
 	add_timer(&q->rttim);
@@ -1306,7 +1310,8 @@ static void htb_destroy(struct Qdisc *sc
 
 	qdisc_watchdog_cancel(&q->watchdog);
 #ifdef HTB_RATECM
-	del_timer_sync(&q->rttim);
+	if (!del_timer_sync(&q->rttim))
+		del_timer(&q->rttim);
 #endif
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it
