From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH v4 2/2] macvtap: Implement multiqueue for macvtap driver
Date: Wed, 04 Aug 2010 16:25:25 +0530
Message-ID: <20100804105525.22212.45090.sendpatchset@krkumar2.in.ibm.com>
References: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com>
Cc: mst@redhat.com, netdev@vger.kernel.org, xiaosuo@gmail.com,
	bhutchings@solarflare.com, Krishna Kumar <krkumar2@in.ibm.com>,
	therbert@google.com
To: davem@davemloft.net, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:39625 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201Ab0HDKzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 06:55:35 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id o74AtS7n018819
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 16:25:28 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o74AtSxw4411634
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 16:25:28 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o74AtRhM013036
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 20:55:28 +1000
In-Reply-To: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Implement multiqueue facility for macvtap driver. The idea is that
a macvtap device can be opened multiple times and the fd's can be
used to register eg, as backend for vhost.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/macvtap.c      |   89 ++++++++++++++++++++++++++++-------
 include/linux/if_macvlan.h |    9 +++
 2 files changed, 80 insertions(+), 18 deletions(-)

diff -ruNp org/drivers/net/macvtap.c new/drivers/net/macvtap.c
--- org/drivers/net/macvtap.c	2010-07-28 15:10:10.000000000 +0530
+++ new/drivers/net/macvtap.c	2010-08-04 16:19:32.000000000 +0530
@@ -84,26 +84,45 @@ static const struct proto_ops macvtap_so
 static DEFINE_SPINLOCK(macvtap_lock);
 
 /*
- * Choose the next free queue, for now there is only one
+ * get_slot: return a [unused/occupied] slot in vlan->taps[]:
+ *	- if 'q' is NULL, return the first empty slot;
+ *	- otherwise, return the slot this pointer occupies.
  */
+static int get_slot(struct macvlan_dev *vlan, struct macvtap_queue *q)
+{
+	int i;
+
+	for (i = 0; i < MAX_MACVTAP_QUEUES; i++) {
+		if (rcu_dereference(vlan->taps[i]) == q)
+			return i;
+	}
+
+	/* Should never happen */
+	BUG_ON(1);
+}
+
 static int macvtap_set_queue(struct net_device *dev, struct file *file,
 				struct macvtap_queue *q)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	int index;
 	int err = -EBUSY;
 
 	spin_lock(&macvtap_lock);
-	if (rcu_dereference(vlan->tap))
+	if (vlan->numvtaps == MAX_MACVTAP_QUEUES)
 		goto out;
 
 	err = 0;
+	index = get_slot(vlan, NULL);
 	rcu_assign_pointer(q->vlan, vlan);
-	rcu_assign_pointer(vlan->tap, q);
+	rcu_assign_pointer(vlan->taps[index], q);
 	sock_hold(&q->sk);
 
 	q->file = file;
 	file->private_data = q;
 
+	vlan->numvtaps++;
+
 out:
 	spin_unlock(&macvtap_lock);
 	return err;
@@ -124,9 +143,12 @@ static void macvtap_put_queue(struct mac
 	spin_lock(&macvtap_lock);
 	vlan = rcu_dereference(q->vlan);
 	if (vlan) {
-		rcu_assign_pointer(vlan->tap, NULL);
+		int index = get_slot(vlan, q);
+
+		rcu_assign_pointer(vlan->taps[index], NULL);
 		rcu_assign_pointer(q->vlan, NULL);
 		sock_put(&q->sk);
+		--vlan->numvtaps;
 	}
 
 	spin_unlock(&macvtap_lock);
@@ -136,39 +158,72 @@ static void macvtap_put_queue(struct mac
 }
 
 /*
- * Since we only support one queue, just dereference the pointer.
+ * Select a queue based on the rxq of the device on which this packet
+ * arrived. If the incoming device is not mq, calculate a flow hash to
+ * select a queue. vlan->numvtaps is cached in case it reduces during
+ * the execution of this function.
  */
 static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 					       struct sk_buff *skb)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvtap_queue *tap = NULL;
+	int numvtaps = vlan->numvtaps;
+	__u32 rxq;
+
+	if (!numvtaps)
+		goto out;
+
+	if (likely(skb_rx_queue_recorded(skb))) {
+		rxq = skb_get_rx_queue(skb);
+
+		while (unlikely(rxq >= numvtaps))
+			rxq -= numvtaps;
 
-	return rcu_dereference(vlan->tap);
+		tap = rcu_dereference(vlan->taps[rxq]);
+		if (tap)
+			goto out;
+	}
+
+	rxq = skb_get_rxhash(skb);
+	if (!rxq)
+		rxq = smp_processor_id();
+
+	tap = rcu_dereference(vlan->taps[rxq & (numvtaps - 1)]);
+
+out:
+	return tap;
 }
 
 /*
  * The net_device is going away, give up the reference
- * that it holds on the queue (all the queues one day)
- * and safely set the pointer from the queues to NULL.
+ * that it holds on all queues and safely set the pointer
+ * from the queues to NULL.
  */
 static void macvtap_del_queues(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvtap_queue *q;
+	struct macvtap_queue *q, *qlist[MAX_MACVTAP_QUEUES];
+	int i, j = 0;
 
+	/* macvtap_put_queue can free some slots, so go through all slots */
 	spin_lock(&macvtap_lock);
-	q = rcu_dereference(vlan->tap);
-	if (!q) {
-		spin_unlock(&macvtap_lock);
-		return;
+	for (i = 0; i < MAX_MACVTAP_QUEUES && vlan->numvtaps; i++) {
+		q = rcu_dereference(vlan->taps[i]);
+		if (q) {
+			qlist[j++] = q;
+			rcu_assign_pointer(vlan->taps[i], NULL);
+			rcu_assign_pointer(q->vlan, NULL);
+			vlan->numvtaps--;
+		}
 	}
-
-	rcu_assign_pointer(vlan->tap, NULL);
-	rcu_assign_pointer(q->vlan, NULL);
+	BUG_ON(vlan->numvtaps != 0);
 	spin_unlock(&macvtap_lock);
 
 	synchronize_rcu();
-	sock_put(&q->sk);
+
+	for (--j; j >= 0; j--)
+		sock_put(&qlist[j]->sk);
 }
 
 /*
diff -ruNp org/include/linux/if_macvlan.h new/include/linux/if_macvlan.h
--- org/include/linux/if_macvlan.h	2010-07-28 15:10:10.000000000 +0530
+++ new/include/linux/if_macvlan.h	2010-08-04 16:19:32.000000000 +0530
@@ -40,6 +40,12 @@ struct macvlan_rx_stats {
 	unsigned long		rx_errors;
 };
 
+/*
+ * Maximum times a macvtap device can be opened. This can be used to
+ * configure the number of receive queue, e.g. for multiqueue virtio.
+ */
+#define MAX_MACVTAP_QUEUES	(NR_CPUS < 16 ? NR_CPUS : 16)
+
 struct macvlan_dev {
 	struct net_device	*dev;
 	struct list_head	list;
@@ -50,7 +56,8 @@ struct macvlan_dev {
 	enum macvlan_mode	mode;
 	int (*receive)(struct sk_buff *skb);
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
-	struct macvtap_queue	*tap;
+	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
+	int			numvtaps;
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
