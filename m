From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Tue, 8 May 2007 22:13:22 +1000
Message-ID: <20070508121322.GA21647@gondor.apana.org.au>
References: <20070504232051.411946839@goop.org>
	<20070504232121.492190579@goop.org>
	<20070505091624.GA8890@infradead.org> <463C56D3.8060609@goop.org>
	<20070505102305.GA12771@gondor.apana.org.au>
	<463F95C3.60407@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, Jeff Garzik <jeff@garzik.org>,
        Ian Pratt <ian.pratt@xensource.com>, netdev@vger.kernel.org,
        lkml <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>, virtualization@lists.osdl.org,
        Keir Fraser <Keir.Fraser@cl.cam.ac.uk>,
        Stephen Hemminger <shemminge@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>,
        Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <463F95C3.60407@goop.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 02:10:27PM -0700, Jeremy Fitzhardinge wrote:
>
> > We should just change this to use netif_device_attach and
> > netif_device_detach.
> 
> Like this?

Sorry, I had forgotten that I've already concluded previously that
this doesn't work because we don't want to prevent the interface
from being brought up (and other reasons).  My memory is failing me :)

So I think the best option now is to get rid of the delay on carrier
on events for everyone.

Here is the first of 2 patches.

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

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
a6c194d06da9aed2a8f5a4ea07e3cbf9266db4ef
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3044622..f671cd2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -467,6 +467,8 @@ struct net_device
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
 
+	struct net_device	*link_watch_next;
+
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=0,
 	       NETREG_REGISTERED,	/* completed register_netdevice */
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index e3c26a9..71a35da 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -19,7 +19,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
-#include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
@@ -28,7 +27,6 @@
 
 enum lw_bits {
 	LW_RUNNING = 0,
-	LW_SE_USED
 };
 
 static unsigned long linkwatch_flags;
@@ -37,17 +35,9 @@ static unsigned long linkwatch_nextevent;
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
@@ -90,21 +80,23 @@ static void rfc2863_policy(struct net_device *dev)
 /* Must be called with the rtnl semaphore held */
 void linkwatch_run_queue(void)
 {
-	struct list_head head, *n, *next;
+	struct net_device *next;
 
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
 
-		if (event == &singleevent) {
-			clear_bit(LW_SE_USED, &linkwatch_flags);
-		} else {
-			kfree(event);
-		}
+		next = dev->link_watch_next;
+
+		/*
+		 * Make sure the above read is complete since it can be
+		 * rewritten as soon as we clear the bit below.
+		 */
+		smp_mb__before_clear_bit();
 
 		/* We are about to handle this device,
 		 * so new events can be accepted
@@ -147,24 +139,12 @@ void linkwatch_fire_event(struct net_device *dev)
 {
 	if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
 		unsigned long flags;
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
 
 		dev_hold(dev);
-		event->dev = dev;
 
 		spin_lock_irqsave(&lweventlist_lock, flags);
-		list_add_tail(&event->list, &lweventlist);
+		dev->link_watch_next = lweventlist;
+		lweventlist = dev;
 		spin_unlock_irqrestore(&lweventlist_lock, flags);
 
 		if (!test_and_set_bit(LW_RUNNING, &linkwatch_flags)) {
