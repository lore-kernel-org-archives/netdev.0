From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PATCH net-next-2.6] linkwatch: linkwatch_forget_dev() to speedup
 device dismantle
Date: Tue, 17 Nov 2009 16:59:21 +0100
Message-ID: <4B02C859.6020100@gmail.com>
References: <4B019381.2010509@gmail.com> <4B01C938.8000705@gmail.com> <20091116143917.14e4fa4f@s6510> <20091117.042604.99618154.davem@davemloft.net> <20091117123133.GA14831@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38924 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbZKQP7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 10:59:24 -0500
In-Reply-To: <20091117123133.GA14831@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> On Tue, Nov 17, 2009 at 04:26:04AM -0800, David Miller wrote:
>> Really, the link watch stuff is just due for a redesign.  I don't
>> think a simple hack is going to cut it this time, sorry Eric :-)
>=20
> I have no objections against any redesigns, but since the only
> caller of linkwatch_forget_dev runs in process context with the
> RTNL, it could also legally emit those events.

Thanks guys, here an updated version then, before linkwatch surgery ?

In this version, I force the event to be sent synchronously.

[PATCH net-next-2.6] linkwatch: linkwatch_forget_dev() to speedup devic=
e dismantle

time ip link del eth3.103 ; time ip link del eth3.104 ; time ip link de=
l eth3.105

real	0m0.266s
user	0m0.000s
sys	0m0.001s

real	0m0.770s
user	0m0.000s
sys	0m0.000s

real	0m1.022s
user	0m0.000s
sys	0m0.000s


One problem of current schem in vlan dismantle phase is the
holding of device done by following chain :

vlan_dev_stop() ->
	netif_carrier_off(dev) ->
		linkwatch_fire_event(dev) ->
			dev_hold() ...

And __linkwatch_run_queue() runs up to one second later...

A generic fix to this problem is to add a linkwatch_forget_dev() method
to unlink the device from the list of watched devices.

dev->link_watch_next becomes dev->link_watch_list (and use a bit more m=
emory),
to be able to unlink device in O(1).

After patch :
time ip link del eth3.103 ; time ip link del eth3.104 ; time ip link de=
l eth3.105

real    0m0.024s
user    0m0.000s
sys     0m0.000s

real    0m0.032s
user    0m0.000s
sys     0m0.001s

real    0m0.033s
user    0m0.000s
sys     0m0.000s


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    3 -
 net/core/dev.c            |    3 +
 net/core/link_watch.c     |   94 +++++++++++++++++++++---------------
 3 files changed, 62 insertions(+), 38 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7043f85..4e25730 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -896,7 +896,7 @@ struct net_device {
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
=20
-	struct net_device	*link_watch_next;
+	struct list_head	link_watch_list;
=20
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=3D0,
@@ -1600,6 +1600,7 @@ static inline void dev_hold(struct net_device *de=
v)
  */
=20
 extern void linkwatch_fire_event(struct net_device *dev);
+extern void linkwatch_forget_dev(struct net_device *dev);
=20
 /**
  *	netif_carrier_ok - test if carrier present
diff --git a/net/core/dev.c b/net/core/dev.c
index d867522..9b58c04 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5067,6 +5067,8 @@ static void netdev_wait_allrefs(struct net_device=
 *dev)
 {
 	unsigned long rebroadcast_time, warning_time;
=20
+	linkwatch_forget_dev(dev);
+
 	rebroadcast_time =3D warning_time =3D jiffies;
 	while (atomic_read(&dev->refcnt) !=3D 0) {
 		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
@@ -5281,6 +5283,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
=20
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
+	INIT_LIST_HEAD(&dev->link_watch_list);
 	dev->priv_flags =3D IFF_XMIT_DST_RELEASE;
 	setup(dev);
 	strcpy(dev->name, name);
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index bf8f7af..5910b55 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -35,7 +35,7 @@ static unsigned long linkwatch_nextevent;
 static void linkwatch_event(struct work_struct *dummy);
 static DECLARE_DELAYED_WORK(linkwatch_work, linkwatch_event);
=20
-static struct net_device *lweventlist;
+static LIST_HEAD(lweventlist);
 static DEFINE_SPINLOCK(lweventlist_lock);
=20
 static unsigned char default_operstate(const struct net_device *dev)
@@ -89,8 +89,10 @@ static void linkwatch_add_event(struct net_device *d=
ev)
 	unsigned long flags;
=20
 	spin_lock_irqsave(&lweventlist_lock, flags);
-	dev->link_watch_next =3D lweventlist;
-	lweventlist =3D dev;
+	if (list_empty(&dev->link_watch_list)) {
+		list_add_tail(&dev->link_watch_list, &lweventlist);
+		dev_hold(dev);
+	}
 	spin_unlock_irqrestore(&lweventlist_lock, flags);
 }
=20
@@ -133,9 +135,35 @@ static void linkwatch_schedule_work(int urgent)
 }
=20
=20
+static void linkwatch_do_dev(struct net_device *dev)
+{
+	/*
+	 * Make sure the above read is complete since it can be
+	 * rewritten as soon as we clear the bit below.
+	 */
+	smp_mb__before_clear_bit();
+
+	/* We are about to handle this device,
+	 * so new events can be accepted
+	 */
+	clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
+
+	rfc2863_policy(dev);
+	if (dev->flags & IFF_UP) {
+		if (netif_carrier_ok(dev))
+			dev_activate(dev);
+		else
+			dev_deactivate(dev);
+
+		netdev_state_change(dev);
+	}
+	dev_put(dev);
+}
+
 static void __linkwatch_run_queue(int urgent_only)
 {
-	struct net_device *next;
+	struct net_device *dev;
+	LIST_HEAD(wrk);
=20
 	/*
 	 * Limit the number of linkwatch events to one
@@ -153,46 +181,40 @@ static void __linkwatch_run_queue(int urgent_only=
)
 	clear_bit(LW_URGENT, &linkwatch_flags);
=20
 	spin_lock_irq(&lweventlist_lock);
-	next =3D lweventlist;
-	lweventlist =3D NULL;
-	spin_unlock_irq(&lweventlist_lock);
+	list_splice_init(&lweventlist, &wrk);
=20
-	while (next) {
-		struct net_device *dev =3D next;
+	while (!list_empty(&wrk)) {
=20
-		next =3D dev->link_watch_next;
+		dev =3D list_first_entry(&wrk, struct net_device, link_watch_list);
+		list_del_init(&dev->link_watch_list);
=20
 		if (urgent_only && !linkwatch_urgent_event(dev)) {
-			linkwatch_add_event(dev);
+			list_add_tail(&dev->link_watch_list, &lweventlist);
 			continue;
 		}
-
-		/*
-		 * Make sure the above read is complete since it can be
-		 * rewritten as soon as we clear the bit below.
-		 */
-		smp_mb__before_clear_bit();
-
-		/* We are about to handle this device,
-		 * so new events can be accepted
-		 */
-		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
-
-		rfc2863_policy(dev);
-		if (dev->flags & IFF_UP) {
-			if (netif_carrier_ok(dev))
-				dev_activate(dev);
-			else
-				dev_deactivate(dev);
-
-			netdev_state_change(dev);
-		}
-
-		dev_put(dev);
+		spin_unlock_irq(&lweventlist_lock);
+		linkwatch_do_dev(dev);
+		spin_lock_irq(&lweventlist_lock);
 	}
=20
-	if (lweventlist)
+	if (!list_empty(&lweventlist))
 		linkwatch_schedule_work(0);
+	spin_unlock_irq(&lweventlist_lock);
+}
+
+void linkwatch_forget_dev(struct net_device *dev)
+{
+	unsigned long flags;
+	int clean =3D 0;
+
+	spin_lock_irqsave(&lweventlist_lock, flags);
+	if (!list_empty(&dev->link_watch_list)) {
+		list_del_init(&dev->link_watch_list);
+		clean =3D 1;
+	}
+	spin_unlock_irqrestore(&lweventlist_lock, flags);
+	if (clean)
+		linkwatch_do_dev(dev);
 }
=20
=20
@@ -216,8 +238,6 @@ void linkwatch_fire_event(struct net_device *dev)
 	bool urgent =3D linkwatch_urgent_event(dev);
=20
 	if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
-		dev_hold(dev);
-
 		linkwatch_add_event(dev);
 	} else if (!urgent)
 		return;
