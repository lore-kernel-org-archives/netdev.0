From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost (take 2)
Date: Wed, 04 May 2005 00:32:54 +0200
Message-ID: <4277FC16.4050307@tpack.net>
References: <4276B13F.2040103@tpack.net> <20050503100306.GB29788@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060107070809070404040805"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050503100306.GB29788@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060107070809070404040805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Doing the wait when IFF_RUNNING is off isn't necessary though.  If
> IFF_RUNNING isn't set, then either the device has never been activated
> or we've already carried out those waits the last time we were in
> dev_deactivate.

Right. But it still depends on what the synchronization is meant to
protect us from. It isn't clear to me, whether it's
  o packets in flight
  o qdisc references
  o device references
so yes, I tried to play it safe.

Anyway, given the comments from Thomas, I've pulled out the IFF_RUNNING
stuff. We can add this later, when the other uses have been sorted out.

> I understand your preference for defensive programming.  However, in
> cases like this it's better to do the obvious thing because:
> 
> 1) We don't cover up bugs that may come back to bite us elsewhere.
> 2) We don't give people misconceptions.  If they're unfamiliar with
> the system they may infer things from this code that aren't necessarily
> the case.

I totally agree with this.

-Tommy

--------------060107070809070404040805
Content-Type: text/plain;
 name="carrier-5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="carrier-5.patch"

diff -ru linux-2.6.12-rc3/net/core/link_watch.c linux-2.6.12-work/net/core/link_watch.c
--- linux-2.6.12-rc3/net/core/link_watch.c	2005-03-04 09:55:42.000000000 +0100
+++ linux-2.6.12-work/net/core/link_watch.c	2005-05-02 22:40:59.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/if.h>
 #include <net/sock.h>
+#include <net/pkt_sched.h>
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
@@ -74,6 +75,12 @@
 		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
 
 		if (dev->flags & IFF_UP) {
+			if (netif_carrier_ok(dev)) {
+				WARN_ON(dev->qdisc_sleeping == &noop_qdisc);
+				dev_activate(dev);
+			} else
+				dev_deactivate(dev);
+
 			netdev_state_change(dev);
 		}
 
diff -ru linux-2.6.12-rc3/net/sched/sch_generic.c linux-2.6.12-work/net/sched/sch_generic.c
--- linux-2.6.12-rc3/net/sched/sch_generic.c	2005-03-04 09:55:44.000000000 +0100
+++ linux-2.6.12-work/net/sched/sch_generic.c	2005-05-04 00:24:55.558105856 +0200
@@ -539,6 +539,10 @@
 		write_unlock_bh(&qdisc_tree_lock);
 	}
 
+	if (!netif_carrier_ok(dev))
+		/* Delay activation until next carrier-on event */
+		return;
+
 	spin_lock_bh(&dev->queue_lock);
 	rcu_assign_pointer(dev->qdisc, dev->qdisc_sleeping);
 	if (dev->qdisc != &noqueue_qdisc) {

--------------060107070809070404040805--
