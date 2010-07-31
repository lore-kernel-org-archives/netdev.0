From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Multiqueue macvtap driver
Date: Sat, 31 Jul 2010 19:27:43 +0530
Message-ID: <20100731135743.3072.99933.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	mst@redhat.com
To: davem@davemloft.net, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:59764 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089Ab0GaN5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 09:57:48 -0400
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id o6VDvkkk000964
	for <netdev@vger.kernel.org>; Sat, 31 Jul 2010 23:57:46 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6VDvkci1183948
	for <netdev@vger.kernel.org>; Sat, 31 Jul 2010 23:57:46 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6VDvjLY010875
	for <netdev@vger.kernel.org>; Sat, 31 Jul 2010 23:57:46 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Implement multiqueue facility for macvtap driver. The idea is that
a macvtap device can be opened multiple times and the fd's can be
used to register eg, as backend for vhost.

Please review.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/macvtap.c      |   85 ++++++++++++++++++++++++++++-------
 include/linux/if_macvlan.h |   11 ++++
 2 files changed, 78 insertions(+), 18 deletions(-)

diff -ruNp org/include/linux/if_macvlan.h new/include/linux/if_macvlan.h
--- org/include/linux/if_macvlan.h	2010-07-28 15:10:10.000000000 +0530
+++ new/include/linux/if_macvlan.h	2010-07-31 19:18:38.000000000 +0530
@@ -40,6 +40,14 @@ struct macvlan_rx_stats {
 	unsigned long		rx_errors;
 };
 
+#define MIN(x, y)		(((x) < (y)) ? (x) : (y))
+
+/*
+ * Maximum times a macvtap device can be opened. This can be used to
+ * configure the number of receive queue, e.g. for multiqueue virtio.
+ */
+#define MAX_MACVTAP_QUEUES	MIN(16, NR_CPUS)
+
 struct macvlan_dev {
 	struct net_device	*dev;
 	struct list_head	list;
@@ -50,7 +58,8 @@ struct macvlan_dev {
 	enum macvlan_mode	mode;
 	int (*receive)(struct sk_buff *skb);
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
-	struct macvtap_queue	*tap;
+	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
+	int			numvtaps;
 };
 
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
diff -ruNp org/drivers/net/macvtap.c new/drivers/net/macvtap.c
--- org/drivers/net/macvtap.c	2010-07-28 15:10:10.000000000 +0530
+++ new/drivers/net/macvtap.c	2010-07-31 19:07:22.000000000 +0530
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
@@ -136,39 +158,68 @@ static void macvtap_put_queue(struct mac
 }
 
 /*
- * Since we only support one queue, just dereference the pointer.
+ * Select a queue based on the rxq of the device on which this packet
+ * arrived. If the incoming device is not mq, then use our cpu number
+ * to select a queue. vlan->numvtaps is cached in case it changes
+ * during the execution of this function.
  */
 static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 					       struct sk_buff *skb)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvtap_queue *tap = NULL;
+	int numvtaps = vlan->numvtaps;
+	u16 rxq;
+
+	if (!numvtaps)
+		return NULL;
+
+	if (likely(skb_rx_queue_recorded(skb))) {
+		rxq = skb_get_rx_queue(skb);
 
-	return rcu_dereference(vlan->tap);
+		while (unlikely(rxq >= numvtaps))
+			rxq -= numvtaps;
+
+		tap = rcu_dereference(vlan->taps[rxq]);
+	}
+
+	if (unlikely(!tap)) {
+		rxq = smp_processor_id() % numvtaps;
+		tap = rcu_dereference(vlan->taps[rxq]);
+	}
+
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
