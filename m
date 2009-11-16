From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: PATCH net-next-2.6] linkwatch: linkwatch_forget_dev() to speedup
 device dismantle
Date: Mon, 16 Nov 2009 22:50:48 +0100
Message-ID: <4B01C938.8000705@gmail.com>
References: <4B019381.2010509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57764 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798AbZKPVut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 16:50:49 -0500
In-Reply-To: <4B019381.2010509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

time ip link del eth3.103 ; time ip link del eth3.104 ; time ip link del eth3.105

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

dev->link_watch_next becomes dev->link_watch_list (and use a bit more memory),
to be able to unlink device in O(1).

After patch :
time ip link del eth3.103 ; time ip link del eth3.104 ; time ip link del eth3.105

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
 include/linux/netdevice.h |    3 +-
 net/core/dev.c            |    3 ++
 net/core/link_watch.c     |   42 ++++++++++++++++++++++++------------
 3 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7043f85..4e25730 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -896,7 +896,7 @@ struct net_device {
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
 
-	struct net_device	*link_watch_next;
+	struct list_head	link_watch_list;
 
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=0,
@@ -1600,6 +1600,7 @@ static inline void dev_hold(struct net_device *dev)
  */
 
 extern void linkwatch_fire_event(struct net_device *dev);
+extern void linkwatch_forget_dev(struct net_device *dev);
 
 /**
  *	netif_carrier_ok - test if carrier present
diff --git a/net/core/dev.c b/net/core/dev.c
index 4b24d79..649de02 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5066,6 +5066,8 @@ static void netdev_wait_allrefs(struct net_device *dev)
 {
 	unsigned long rebroadcast_time, warning_time;
 
+	linkwatch_forget_dev(dev);
+
 	rebroadcast_time = warning_time = jiffies;
 	while (atomic_read(&dev->refcnt) != 0) {
 		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
@@ -5280,6 +5282,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
+	INIT_LIST_HEAD(&dev->link_watch_list);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 	strcpy(dev->name, name);
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index bf8f7af..05fe273 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -35,7 +35,7 @@ static unsigned long linkwatch_nextevent;
 static void linkwatch_event(struct work_struct *dummy);
 static DECLARE_DELAYED_WORK(linkwatch_work, linkwatch_event);
 
-static struct net_device *lweventlist;
+static LIST_HEAD(lweventlist);
 static DEFINE_SPINLOCK(lweventlist_lock);
 
 static unsigned char default_operstate(const struct net_device *dev)
@@ -89,8 +89,10 @@ static void linkwatch_add_event(struct net_device *dev)
 	unsigned long flags;
 
 	spin_lock_irqsave(&lweventlist_lock, flags);
-	dev->link_watch_next = lweventlist;
-	lweventlist = dev;
+	if (list_empty(&dev->link_watch_list)) {
+		list_add_tail(&dev->link_watch_list, &lweventlist);
+		dev_hold(dev);
+	}
 	spin_unlock_irqrestore(&lweventlist_lock, flags);
 }
 
@@ -135,7 +137,8 @@ static void linkwatch_schedule_work(int urgent)
 
 static void __linkwatch_run_queue(int urgent_only)
 {
-	struct net_device *next;
+	struct net_device *dev;
+	LIST_HEAD(wrk);
 
 	/*
 	 * Limit the number of linkwatch events to one
@@ -153,19 +156,18 @@ static void __linkwatch_run_queue(int urgent_only)
 	clear_bit(LW_URGENT, &linkwatch_flags);
 
 	spin_lock_irq(&lweventlist_lock);
-	next = lweventlist;
-	lweventlist = NULL;
-	spin_unlock_irq(&lweventlist_lock);
+	list_splice_init(&lweventlist, &wrk);
 
-	while (next) {
-		struct net_device *dev = next;
+	while (!list_empty(&wrk)) {
 
-		next = dev->link_watch_next;
+		dev = list_first_entry(&wrk, struct net_device, link_watch_list);
+		list_del_init(&dev->link_watch_list);
 
 		if (urgent_only && !linkwatch_urgent_event(dev)) {
-			linkwatch_add_event(dev);
+			list_add_tail(&dev->link_watch_list, &lweventlist);
 			continue;
 		}
+		spin_unlock_irq(&lweventlist_lock);
 
 		/*
 		 * Make sure the above read is complete since it can be
@@ -189,10 +191,24 @@ static void __linkwatch_run_queue(int urgent_only)
 		}
 
 		dev_put(dev);
+		spin_lock_irq(&lweventlist_lock);
 	}
 
-	if (lweventlist)
+	if (!list_empty(&lweventlist))
 		linkwatch_schedule_work(0);
+	spin_unlock_irq(&lweventlist_lock);
+}
+
+void linkwatch_forget_dev(struct net_device *dev)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&lweventlist_lock, flags);
+	if (!list_empty(&dev->link_watch_list)) {
+		list_del_init(&dev->link_watch_list);
+		dev_put(dev);
+	}
+	spin_unlock_irqrestore(&lweventlist_lock, flags);
 }
 
 
@@ -216,8 +232,6 @@ void linkwatch_fire_event(struct net_device *dev)
 	bool urgent = linkwatch_urgent_event(dev);
 
 	if (!test_and_set_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state)) {
-		dev_hold(dev);
-
 		linkwatch_add_event(dev);
 	} else if (!urgent)
 		return;
