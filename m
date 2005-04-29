From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Fri, 29 Apr 2005 11:51:48 +0200
Message-ID: <1114768308.4695.1487.camel@tsc-6.cph.tpack.net>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au>
	 <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au>
	 <42701FFD.5000505@tpack.net>  <20050427234359.GB22238@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-EIU1GPvPvAE3JEFONXJG"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050427234359.GB22238@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-EIU1GPvPvAE3JEFONXJG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-04-28 at 01:43, Herbert Xu wrote:
> On Thu, Apr 28, 2005 at 01:27:57AM +0200, Tommy Christensen wrote:
> > This is indeed possible, but hopefully you can agree that this would be
> > a driver bug. As stated above, I'm not trying to solve everything. We
> > have to assume some level of sanity of the drivers. E.g. for a NIC that
> > stalls the TX engine on carrier off, the driver would have to flush the
> > TX ring and either call netif_stop_queue or discard packets in their
> > hard_start_xmit function.  At present, even such well-behaving drivers
> > would hit the problem, because packets were piling up in the qdisc.
> 
> I am not saying that there is nothing to fix.  I'm simply stating
> that doing it in the watchdog is not ideal for two reasons:
> 
> 1) The watchdog is not always there.
> 2) The delay introduced by the watchdog is driver-dependent and
> varies wildly.  For the purpose of shutting down the qdisc after
> a carrier off we want everything to use the same delay (if we're
> going to delay at all).
> 
> So instead of doing it in the watchdog, just do both actions in
> the link_watch worker.

Originally, I was afraid it could get too trigger happy, so I left
this idea. Perhaps that's not such a big deal afterall.

How does this look?


Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>


--=-EIU1GPvPvAE3JEFONXJG
Content-Description: 
Content-Disposition: inline; filename=carrier-2.patch
Content-Type: text/x-patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff -ru linux-2.6.12-rc3/net/core/link_watch.c linux-2.6.12-work/net/core/link_watch.c
--- linux-2.6.12-rc3/net/core/link_watch.c	2005-03-04 09:55:42.000000000 +0100
+++ linux-2.6.12-work/net/core/link_watch.c	2005-04-29 11:22:05.330262591 +0200
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
+				if (dev->qdisc_sleeping != &noop_qdisc)
+					dev_activate(dev);
+			} else if (netif_queue_stopped(dev))
+				dev_deactivate(dev);
+
 			netdev_state_change(dev);
 		}
 
diff -ru linux-2.6.12-rc3/net/sched/sch_generic.c linux-2.6.12-work/net/sched/sch_generic.c
--- linux-2.6.12-rc3/net/sched/sch_generic.c	2005-03-04 09:55:44.000000000 +0100
+++ linux-2.6.12-work/net/sched/sch_generic.c	2005-04-29 11:22:05.420250195 +0200
@@ -539,6 +539,10 @@
 		write_unlock_bh(&qdisc_tree_lock);
 	}
 
+	if (!netif_carrier_ok(dev) && netif_queue_stopped(dev))
+		/* Delay activation until next carrier-on event */
+		return;
+
 	spin_lock_bh(&dev->queue_lock);
 	rcu_assign_pointer(dev->qdisc, dev->qdisc_sleeping);
 	if (dev->qdisc != &noqueue_qdisc) {

--=-EIU1GPvPvAE3JEFONXJG--
