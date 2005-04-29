From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Fri, 29 Apr 2005 14:22:36 +0200
Message-ID: <1114777355.4695.1598.camel@tsc-6.cph.tpack.net>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au>
	 <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au>
	 <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au>
	 <1114768308.4695.1487.camel@tsc-6.cph.tpack.net>
	 <20050429101836.GA2237@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hX5Sj6f8b3ADswQ3SGCz"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050429101836.GA2237@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-hX5Sj6f8b3ADswQ3SGCz
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-04-29 at 12:18, Herbert Xu wrote:
> On Fri, Apr 29, 2005 at 11:51:48AM +0200, Tommy Christensen wrote:
> > @@ -74,6 +75,12 @@
> >  		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
> >  
> >  		if (dev->flags & IFF_UP) {
> > +			if (netif_carrier_ok(dev)) {
> > +				if (dev->qdisc_sleeping != &noop_qdisc)
> > +					dev_activate(dev);
> 
> I don't see how qdisc_sleeping can be noop_qdisc unless there is a bug.
> So why not convert this to a BUG_ON?

Calling dev->open instead of dev_open leads to this.  Probably that
shouldn't be allowed anyway.  But since it doesn't hurt us here, I'd
rather settle for a WARN_ON.

> > diff -ru linux-2.6.12-rc3/net/sched/sch_generic.c linux-2.6.12-work/net/sched/sch_generic.c
> > --- linux-2.6.12-rc3/net/sched/sch_generic.c	2005-03-04 09:55:44.000000000 +0100
> > +++ linux-2.6.12-work/net/sched/sch_generic.c	2005-04-29 11:22:05.420250195 +0200
> > @@ -539,6 +539,10 @@
> >  		write_unlock_bh(&qdisc_tree_lock);
> >  	}
> >  
> > +	if (!netif_carrier_ok(dev) && netif_queue_stopped(dev))
> > +		/* Delay activation until next carrier-on event */
> > +		return;
> 
> How about moving this check into dev_open?

But that would indeed leave qdisc_sleeping set to noop_qdisc, wouldn't
it?  Besides, I wanted to catch qdisc changes done by tc as well.


Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>


--=-hX5Sj6f8b3ADswQ3SGCz
Content-Description: 
Content-Disposition: inline; filename=carrier-3.patch
Content-Type: text/x-patch; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

diff -ru linux-2.6.12-rc3/net/core/link_watch.c linux-2.6.12-work/net/core/link_watch.c
--- linux-2.6.12-rc3/net/core/link_watch.c	2005-03-04 09:55:42.000000000 +0100
+++ linux-2.6.12-work/net/core/link_watch.c	2005-04-29 14:19:07.356024339 +0200
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

--=-hX5Sj6f8b3ADswQ3SGCz--
