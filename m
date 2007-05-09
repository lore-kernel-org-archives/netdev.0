From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linkwatch bustage in git-net
Date: Tue, 8 May 2007 22:58:18 -0700
Message-ID: <20070508225818.c04e707d.akpm@linux-foundation.org>
References: <20070508222033.4e57a580.akpm@linux-foundation.org>
	<20070509053154.GA850@gondor.apana.org.au>
	<20070509054558.GA1184@gondor.apana.org.au>
	<20070508225153.d538f79c.akpm@linux-foundation.org>
	<20070509055405.GA1336@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:44970 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934716AbXEIF6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 01:58:55 -0400
In-Reply-To: <20070509055405.GA1336@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 May 2007 15:54:05 +1000 Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, May 08, 2007 at 10:51:53PM -0700, Andrew Morton wrote:
> > 
> > It's not hanging.  It's just going reeeeeeeaaaaallllllyyyy sslllooowwllyyy.
> > 
> > This is first noticeable during udev startup and persists all the way
> > through initscripts.
> 
> OK, does reverting the link watch patches make this go away?
> 

That's the only thing which is in git-net.  Here it is, in toto:


GIT 4833bb610f5d940d623c99ca5ed83e1faf9a7881 git+ssh://master.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

commit 
Author: Geert Uytterhoeven <geert@linux-m68k.org>
Date:   Tue May 8 18:40:27 2007 -0700

    [MAC80211]: include <linux/delay.h> instead of <asm/delay.h>
    
    |   CC      net/mac80211/ieee80211_sta.o
    | In file included from linux/net/mac80211/ieee80211_sta.c:31:
    | include2/asm/delay.h: In function '__const_udelay':
    | include2/asm/delay.h:33: error: 'loops_per_jiffy' undeclared (first use in this function)
    | include2/asm/delay.h:33: error: (Each undeclared identifier is reported only once
    | include2/asm/delay.h:33: error: for each function it appears in.)
    
    Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 804abf08e316754dc50f10f8dd6957b2e47c879d
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue May 8 18:36:28 2007 -0700

    [NET]: Remove link_watch delay for up even when we're down
    
    Currently all link carrier events are delayed by up to a second
    before they're processed to prevent link storms.  This causes
    unnecessary packet loss during that interval.
    
    In fact, we can achieve the same effect in preventing storms by
    only delaying down events and unnecssary up events.  The latter
    is defined as up events when we're already up.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 119a2edd882f7be9e90defcd57debf9d1658bbd5
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue May 8 18:34:17 2007 -0700

    [NET] link_watch: Move link watch list into net_device
    
    These days the link watch mechanism is an integral part of the
    network subsystem as it manages the carrier status.  So it now
    makes sense to allocate some memory for it in net_device rather
    than allocating it on demand.
    
    In fact, this is necessary because we can't tolerate a memory
    allocation failure since that means we'd have to potentially
    throw a link up event away.
    
    It also simplifies the code greatly.
    
    In doing so I discovered a subtle race condition in the use
    of singleevent.  This race condition still exists (and is
    somewhat magnified) without singleevent but it's now plugged
    thanks to an smp_mb__before_clear_bit.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>
 include/linux/netdevice.h    |    2 +
 net/core/link_watch.c        |  134 +++++++++++++++++++++++++-----------------
 net/mac80211/ieee80211_sta.c |    2 -
 3 files changed, 82 insertions(+), 56 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3044622..f671cd2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -467,6 +467,8 @@ #endif
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
 
+	struct net_device	*link_watch_next;
+
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=0,
 	       NETREG_REGISTERED,	/* completed register_netdevice */
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index e3c26a9..b5f4579 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -19,7 +19,6 @@ #include <net/pkt_sched.h>
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
-#include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
@@ -28,7 +27,6 @@ #include <asm/types.h>
 
 enum lw_bits {
 	LW_RUNNING = 0,
-	LW_SE_USED
 };
 
 static unsigned long linkwatch_flags;
@@ -37,17 +35,9 @@ static unsigned long linkwatch_nextevent
 static void linkwatch_event(struct work_struct *dummy);
 static DECLARE_DELAYED_WORK(linkwatch_work, linkwatch_event);
 
-static LIST_HEAD(lweventlist);
+static struct net_device *lweventlist;
 static DEFINE_SPINLOCK(lweventlist_lock);
 
-struct lw_event {
-	struct list_head list;
-	struct net_device *dev;
-};
-
-/* Avoid kmalloc() for most systems */
-static struct lw_event singleevent;
-
 static unsigned char default_operstate(const struct net_device *dev)
 {
 	if (!netif_carrier_ok(dev))
@@ -87,25 +77,73 @@ static void rfc2863_policy(struct net_de
 }
 
 
-/* Must be called with the rtnl semaphore held */
-void linkwatch_run_queue(void)
+static int linkwatch_urgent_event(struct net_device *dev)
+{
+	return netif_running(dev) && netif_carrier_ok(dev) &&
+	       dev->qdisc != dev->qdisc_sleeping;
+}
+
+
+static void linkwatch_add_event(struct net_device *dev)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&lweventlist_lock, flags);
+	dev->link_watch_next = lweventlist;
+	lweventlist = dev;
+	spin_unlock_irqrestore(&lweventlist_lock, flags);
+}
+
+
+static void linkwatch_schedule_work(unsigned long delay)
 {
-	struct list_head head, *n, *next;
+	if (test_and_set_bit(LW_RUNNING, &linkwatch_flags))
+		return;
+
+	/* If we wrap around we'll delay it by at most HZ. */
+	if (delay > HZ)
+		delay = 0;
+
+	schedule_delayed_work(&linkwatch_work, delay);
+}
+
+
+static void __linkwatch_run_queue(int urgent_only)
+{
+	struct net_device *next;
+
+	/*
+	 * Limit the number of linkwatch events to one
+	 * per second so that a runaway driver does not
+	 * cause a storm of messages on the netlink
+	 * socket.  This limit does not apply to up events
+	 * while the device qdisc is down.
+	 */
+	if (!urgent_only)
+		linkwatch_nextevent = jiffies + HZ;
+	clear_bit(LW_RUNNING, &linkwatch_flags);
 
 	spin_lock_irq(&lweventlist_lock);
-	list_replace_init(&lweventlist, &head);
+	next = lweventlist;
+	lweventlist = NULL;
 	spin_unlock_irq(&lweventlist_lock);
 
-	list_for_each_safe(n, next, &head) {
-		struct lw_event *event = list_entry(n, struct lw_event, list);
-		struct net_device *dev = event->dev;
+	while (next) {
+		struct net_device *dev = next;
+
+		next = dev->link_watch_next;
 
-		if (event == &singleevent) {
-			clear_bit(LW_SE_USED, &linkwatch_flags);
-		} else {
-			kfree(event);
+		if (urgent_only && !linkwatch_urgent_event(dev)) {
+			linkwatch_add_event(dev);
+			continue;
 		}
 
+		/*
+		 * Make sure the above read is complete since it can be
+		 * rewritten as soon as we clear the bit below.
+		 */
+		smp_mb__before_clear_bit();
+
 		/* We are about to handle this device,
 		 * so new events can be accepted
 		 */
@@ -124,21 +162,23 @@ void linkwatch_run_queue(void)
 
 		dev_put(dev);
 	}
+
+	if (lweventlist)
+		linkwatch_schedule_work(linkwatch_nextevent - jiffies);
 }
 
 
-static void linkwatch_event(struct work_struct *dummy)
+/* Must be called with the rtnl semaphore held */
+void linkwatch_run_queue(void)
 {
-	/* Limit the number of linkwatch events to one
-	 * per second so that a runaway driver does not
-	 * cause a storm of messages on the netlink
-	 * socket
-	 */
-	linkwatch_nextevent = jiffies + HZ;
-	clear_bit(LW_RUNNING, &linkwatch_flags);
+	__linkwatch_run_queue(0);
+}
+
 
+static void linkwatch_event(struct work_struct *dummy)
+{
 	rtnl_lock();
-	linkwatch_run_queue();
+	__linkwatch_run_queue(time_after(linkwatch_nextevent, jiffies));
 	rtnl_unlock();
 }
 
@@ -146,35 +186,19 @@ static void linkwatch_event(struct work_
 void linkwatch_fire_event(struct net_device *dev)
 {
 	if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
-		unsigned long flags;
-		struct lw_event *event;
-
-		if (test_and_set_bit(LW_SE_USED, &linkwatch_flags)) {
-			event = kmalloc(sizeof(struct lw_event), GFP_ATOMIC);
-
-			if (unlikely(event == NULL)) {
-				clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
-				return;
-			}
-		} else {
-			event = &singleevent;
-		}
+		unsigned long delay;
 
 		dev_hold(dev);
-		event->dev = dev;
 
-		spin_lock_irqsave(&lweventlist_lock, flags);
-		list_add_tail(&event->list, &lweventlist);
-		spin_unlock_irqrestore(&lweventlist_lock, flags);
+		linkwatch_add_event(dev);
 
-		if (!test_and_set_bit(LW_RUNNING, &linkwatch_flags)) {
-			unsigned long delay = linkwatch_nextevent - jiffies;
+		delay = linkwatch_nextevent - jiffies;
 
-			/* If we wrap around we'll delay it by at most HZ. */
-			if (delay > HZ)
-				delay = 0;
-			schedule_delayed_work(&linkwatch_work, delay);
-		}
+		/* Minimise down-time: drop delay for up event. */
+		if (linkwatch_urgent_event(dev))
+			delay = 0;
+
+		linkwatch_schedule_work(delay);
 	}
 }
 
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 822917d..3e07e9d 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -17,6 +17,7 @@
  * scan result table filtering (by capability (privacy, IBSS/BSS, WPA/RSN IE,
  *    SSID)
  */
+#include <linux/delay.h>
 #include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
@@ -27,7 +28,6 @@ #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/iw_handler.h>
 #include <asm/types.h>
-#include <asm/delay.h>
 
 #include <net/mac80211.h>
 #include "ieee80211_i.h"

