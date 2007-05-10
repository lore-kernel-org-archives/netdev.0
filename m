From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Thu, 10 May 2007 15:25:52 -0700 (PDT)
Message-ID: <20070510.152552.117703057.davem@davemloft.net>
References: <464395E5.2090500@goop.org>
	<20070510151426.d808384f.akpm@linux-foundation.org>
	<46439B19.7010706@goop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, herbert@gondor.apana.org.au,
	hch@infradead.org, ak@suse.de, virtualization@lists.osdl.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	ian.pratt@xensource.com, Christian.Limpach@cl.cam.ac.uk,
	netdev@vger.kernel.org, jeff@garzik.org,
	shemminger@linux-foundation.org, rusty@rustcorp.com.au,
	Valdis.Kletnieks@vt.edu
To: jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758726AbXEJWZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 18:25:51 -0400
In-Reply-To: <46439B19.7010706@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 10 May 2007 15:22:17 -0700

> Andrew Morton wrote:
> > Five minutes after boot is when jiffies wraps.  Are you sure it's
> > a list-screwup rather than a jiffy-wrap screwup?
> >   
> 
> 
> Hm, its suggestive, isn't it?  Apparently they've already fixed this in
> the sekret networking clubhouse, so I'll need to track it down.

I'm not so certain now that we know it's the jiffies wrap point :-)

The fixes in question are attached below and they were posted and
discussed on netdev:

--------------------
commit fe47cdba83b3041e4ac1aa1418431020a4afe1e0
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue May 8 23:22:43 2007 -0700

    [NET] link_watch: Eliminate potential delay on wrap-around
    
    When the jiffies wrap around or when the system boots up for the first
    time, down events can be delayed indefinitely since we no longer
    update linkwatch_nextevent when only urgent events are processed.
    
    This patch fixes this by setting linkwatch_nextevent when a
    wrap-around occurs.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index b5f4579..4674ae5 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -101,8 +101,10 @@ static void linkwatch_schedule_work(unsigned long delay)
 		return;
 
 	/* If we wrap around we'll delay it by at most HZ. */
-	if (delay > HZ)
+	if (delay > HZ) {
+		linkwatch_nextevent = jiffies;
 		delay = 0;
+	}
 
 	schedule_delayed_work(&linkwatch_work, delay);
 }
--------------------
commit 4cba637dbb9a13706494a1c85174c8e736914010
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Wed May 9 00:17:30 2007 -0700

    [NET] link_watch: Always schedule urgent events
    
    Urgent events may be delayed if we already have a non-urgent event
    queued for that device.  This patch changes this by making sure that
    an urgent event is always looked at immediately.
    
    I've replaced the LW_RUNNING flag by LW_URGENT since whether work
    is scheduled is already kept track by the work queue system.
    
    The only complication is that we have to provide some exclusion for
    the setting linkwatch_nextevent which is available in the actual
    work function.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 4674ae5..a5e372b 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -26,7 +26,7 @@
 
 
 enum lw_bits {
-	LW_RUNNING = 0,
+	LW_URGENT = 0,
 };
 
 static unsigned long linkwatch_flags;
@@ -95,18 +95,41 @@ static void linkwatch_add_event(struct net_device *dev)
 }
 
 
-static void linkwatch_schedule_work(unsigned long delay)
+static void linkwatch_schedule_work(int urgent)
 {
-	if (test_and_set_bit(LW_RUNNING, &linkwatch_flags))
+	unsigned long delay = linkwatch_nextevent - jiffies;
+
+	if (test_bit(LW_URGENT, &linkwatch_flags))
 		return;
 
-	/* If we wrap around we'll delay it by at most HZ. */
-	if (delay > HZ) {
-		linkwatch_nextevent = jiffies;
+	/* Minimise down-time: drop delay for up event. */
+	if (urgent) {
+		if (test_and_set_bit(LW_URGENT, &linkwatch_flags))
+			return;
 		delay = 0;
 	}
 
-	schedule_delayed_work(&linkwatch_work, delay);
+	/* If we wrap around we'll delay it by at most HZ. */
+	if (delay > HZ)
+		delay = 0;
+
+	/*
+	 * This is true if we've scheduled it immeditately or if we don't
+	 * need an immediate execution and it's already pending.
+	 */
+	if (schedule_delayed_work(&linkwatch_work, delay) == !delay)
+		return;
+
+	/* Don't bother if there is nothing urgent. */
+	if (!test_bit(LW_URGENT, &linkwatch_flags))
+		return;
+
+	/* It's already running which is good enough. */
+	if (!cancel_delayed_work(&linkwatch_work))
+		return;
+
+	/* Otherwise we reschedule it again for immediate exection. */
+	schedule_delayed_work(&linkwatch_work, 0);
 }
 
 
@@ -123,7 +146,11 @@ static void __linkwatch_run_queue(int urgent_only)
 	 */
 	if (!urgent_only)
 		linkwatch_nextevent = jiffies + HZ;
-	clear_bit(LW_RUNNING, &linkwatch_flags);
+	/* Limit wrap-around effect on delay. */
+	else if (time_after(linkwatch_nextevent, jiffies + HZ))
+		linkwatch_nextevent = jiffies;
+
+	clear_bit(LW_URGENT, &linkwatch_flags);
 
 	spin_lock_irq(&lweventlist_lock);
 	next = lweventlist;
@@ -166,7 +193,7 @@ static void __linkwatch_run_queue(int urgent_only)
 	}
 
 	if (lweventlist)
-		linkwatch_schedule_work(linkwatch_nextevent - jiffies);
+		linkwatch_schedule_work(0);
 }
 
 
@@ -187,21 +214,16 @@ static void linkwatch_event(struct work_struct *dummy)
 
 void linkwatch_fire_event(struct net_device *dev)
 {
-	if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
-		unsigned long delay;
+	int urgent = linkwatch_urgent_event(dev);
 
+	if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
 		dev_hold(dev);
 
 		linkwatch_add_event(dev);
+	} else if (!urgent)
+		return;
 
-		delay = linkwatch_nextevent - jiffies;
-
-		/* Minimise down-time: drop delay for up event. */
-		if (linkwatch_urgent_event(dev))
-			delay = 0;
-
-		linkwatch_schedule_work(delay);
-	}
+	linkwatch_schedule_work(urgent);
 }
 
 EXPORT_SYMBOL(linkwatch_fire_event);
--------------------
