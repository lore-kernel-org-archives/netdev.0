From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC 5/8] macvtap: eliminate linear search
Date: Thu, 23 May 2013 11:12:30 +0800
Message-ID: <1369278753-2533-6-git-send-email-jasowang@redhat.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linear search were used in both get_slot() and macvtap_get_queue(), this is
because:

- macvtap didn't reshuffle the array of taps when create or destroy a queue, so
  when adding a new queue, macvtap must do linear search to find a location for
  the new queue. This will also complicate the TUNSETQUEUE implementation for
  multiqueue API.
- the queue itself didn't track the queue index, so the we must do a linear
  search in the array to find the location of a existed queue.

The solution is straightforward: reshuffle the array and introduce a queue_index
to macvtap_queue.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   63 +++++++++++++++---------------------------------
 1 files changed, 20 insertions(+), 43 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a36e49e..5fd341c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -44,6 +44,7 @@ struct macvtap_queue {
 	struct macvlan_dev __rcu *vlan;
 	struct file *file;
 	unsigned int flags;
+	u16 queue_index;
 };
 
 static struct proto macvtap_proto = {
@@ -84,30 +85,10 @@ static const struct proto_ops macvtap_socket_ops;
  */
 static DEFINE_SPINLOCK(macvtap_lock);
 
-/*
- * get_slot: return a [unused/occupied] slot in vlan->taps[]:
- *	- if 'q' is NULL, return the first empty slot;
- *	- otherwise, return the slot this pointer occupies.
- */
-static int get_slot(struct macvlan_dev *vlan, struct macvtap_queue *q)
-{
-	int i;
-
-	for (i = 0; i < MAX_MACVTAP_QUEUES; i++) {
-		if (rcu_dereference_protected(vlan->taps[i],
-					      lockdep_is_held(&macvtap_lock)) == q)
-			return i;
-	}
-
-	/* Should never happen */
-	BUG_ON(1);
-}
-
 static int macvtap_set_queue(struct net_device *dev, struct file *file,
 				struct macvtap_queue *q)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	int index;
 	int err = -EBUSY;
 
 	spin_lock(&macvtap_lock);
@@ -115,12 +96,12 @@ static int macvtap_set_queue(struct net_device *dev, struct file *file,
 		goto out;
 
 	err = 0;
-	index = get_slot(vlan, NULL);
 	rcu_assign_pointer(q->vlan, vlan);
-	rcu_assign_pointer(vlan->taps[index], q);
+	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
 	sock_hold(&q->sk);
 
 	q->file = file;
+	q->queue_index = vlan->numvtaps;
 	file->private_data = q;
 
 	vlan->numvtaps++;
@@ -140,16 +121,23 @@ out:
  */
 static void macvtap_put_queue(struct macvtap_queue *q)
 {
+	struct macvtap_queue *nq;
 	struct macvlan_dev *vlan;
 
 	spin_lock(&macvtap_lock);
 	vlan = rcu_dereference_protected(q->vlan,
 					 lockdep_is_held(&macvtap_lock));
 	if (vlan) {
-		int index = get_slot(vlan, q);
+		int index = q->queue_index;
+		BUG_ON(index >= vlan->numvtaps);
 
-		RCU_INIT_POINTER(vlan->taps[index], NULL);
+		rcu_assign_pointer(vlan->taps[index],
+				   vlan->taps[vlan->numvtaps - 1]);
 		RCU_INIT_POINTER(q->vlan, NULL);
+		nq = rcu_dereference_protected(vlan->taps[index],
+					       lockdep_is_held(&macvtap_lock));
+		nq->queue_index = index;
+
 		sock_put(&q->sk);
 		--vlan->numvtaps;
 	}
@@ -182,8 +170,7 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 	rxq = skb_get_rxhash(skb);
 	if (rxq) {
 		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
-		if (tap)
-			goto out;
+		goto out;
 	}
 
 	if (likely(skb_rx_queue_recorded(skb))) {
@@ -193,17 +180,10 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 			rxq -= numvtaps;
 
 		tap = rcu_dereference(vlan->taps[rxq]);
-		if (tap)
-			goto out;
-	}
-
-	/* Everything failed - find first available queue */
-	for (rxq = 0; rxq < MAX_MACVTAP_QUEUES; rxq++) {
-		tap = rcu_dereference(vlan->taps[rxq]);
-		if (tap)
-			break;
+		goto out;
 	}
 
+	tap = rcu_dereference(vlan->taps[0]);
 out:
 	return tap;
 }
@@ -221,17 +201,14 @@ static void macvtap_del_queues(struct net_device *dev)
 
 	/* macvtap_put_queue can free some slots, so go through all slots */
 	spin_lock(&macvtap_lock);
-	for (i = 0; i < MAX_MACVTAP_QUEUES && vlan->numvtaps; i++) {
+	for (i = 0; i < vlan->numvtaps; i++) {
 		q = rcu_dereference_protected(vlan->taps[i],
 					      lockdep_is_held(&macvtap_lock));
-		if (q) {
-			qlist[j++] = q;
-			RCU_INIT_POINTER(vlan->taps[i], NULL);
-			RCU_INIT_POINTER(q->vlan, NULL);
-			vlan->numvtaps--;
-		}
+		BUG_ON(q == NULL);
+		qlist[j++] = q;
+		RCU_INIT_POINTER(vlan->taps[i], NULL);
+		RCU_INIT_POINTER(q->vlan, NULL);
 	}
-	BUG_ON(vlan->numvtaps != 0);
 	/* guarantee that any future macvtap_set_queue will fail */
 	vlan->numvtaps = MAX_MACVTAP_QUEUES;
 	spin_unlock(&macvtap_lock);
-- 
1.7.1
