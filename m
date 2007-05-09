From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linkwatch bustage in git-net
Date: Wed, 9 May 2007 17:16:15 +1000
Message-ID: <20070509071614.GA2138@gondor.apana.org.au>
References: <20070508222033.4e57a580.akpm@linux-foundation.org> <20070509053154.GA850@gondor.apana.org.au> <20070509054558.GA1184@gondor.apana.org.au> <20070508231143.fcae61c7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1141 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755525AbXEIHQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 03:16:23 -0400
Content-Disposition: inline
In-Reply-To: <20070508231143.fcae61c7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 11:11:43PM -0700, Andrew Morton wrote:
>
> > [NET] link_watch: Eliminate potential delay on wrap-around
> 
> hm, that fixed it.  Do we know why? ;)

Yep :)

> btw, looking at the code:
> 
> 	clear_bit(LW_RUNNING, &linkwatch_flags);
> 
> 	spin_lock_irq(&lweventlist_lock);
> 	next = lweventlist;
> 	lweventlist = NULL;
> 	spin_unlock_irq(&lweventlist_lock);
> 
> 	while (next) {
> 		struct net_device *dev = next;
> 
> 		next = dev->link_watch_next;
> 
> lweventlist_lock protects lweventlist and every netdev's ->link_watch_next.
>  But this code is walking that singly-linked list outside the lock and
> after clearing LW_RUNNING.  What stops this singly-linked list from getting
> altered by another thread of control while this code is traversing it?

It's protected by the __LINK_STATE_LINKWATCH_PENDING bit.

The real problem here is a combination of factors.  First of all e100
does a netif_carrier_off in its open routine *before* the first call
to dev_activate.  This when combined with the wrap-around bug causes
an infinitely delayed event for your NIC to be installed.

When the carrier comes up it notices that we already have an event
queued for that NIC so it just drops it even though it's urgent.

The previous bug fix limits this delay to one second but it is still
sub-optimal.

So here is the additional fix.

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

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
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
