From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next 1/4] macvtap: Convert to using rtnl lock
Date: Tue, 25 Jun 2013 16:04:19 -0400
Message-ID: <1372190662-30815-2-git-send-email-vyasevic@redhat.com>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab3FYUEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 16:04:30 -0400
In-Reply-To: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macvtap uses a private lock to protect the relationship between
macvtap_queue and macvlan_dev.  The private lock is not needed
since the relationship is managed by user via open(), release(),
and dellink() calls.  dellink() already happens under rtnl, so
we can safely convert open() and release(), and use it in ioctl()
as well.

Suggested by Eric Dumazet.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 62 +++++++++++++++++++++------------------------------
 1 file changed, 25 insertions(+), 37 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5a76f20..efbf2eb 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -69,7 +69,7 @@ static const struct proto_ops macvtap_socket_ops;
  * RCU usage:
  * The macvtap_queue and the macvlan_dev are loosely coupled, the
  * pointers from one to the other can only be read while rcu_read_lock
- * or macvtap_lock is held.
+ * or rtnl is held.
  *
  * Both the file and the macvlan_dev hold a reference on the macvtap_queue
  * through sock_hold(&q->sk). When the macvlan_dev goes away first,
@@ -81,7 +81,6 @@ static const struct proto_ops macvtap_socket_ops;
  * file or the dev. The data structure is freed through __sk_free
  * when both our references and any pending SKBs are gone.
  */
-static DEFINE_SPINLOCK(macvtap_lock);
 
 static int macvtap_enable_queue(struct net_device *dev, struct file *file,
 				struct macvtap_queue *q)
@@ -89,7 +88,7 @@ static int macvtap_enable_queue(struct net_device *dev, struct file *file,
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	int err = -EINVAL;
 
-	spin_lock(&macvtap_lock);
+	ASSERT_RTNL();
 
 	if (q->enabled)
 		goto out;
@@ -101,7 +100,6 @@ static int macvtap_enable_queue(struct net_device *dev, struct file *file,
 
 	vlan->numvtaps++;
 out:
-	spin_unlock(&macvtap_lock);
 	return err;
 }
 
@@ -111,7 +109,7 @@ static int macvtap_set_queue(struct net_device *dev, struct file *file,
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	int err = -EBUSY;
 
-	spin_lock(&macvtap_lock);
+	rtnl_lock();
 	if (vlan->numqueues == MAX_MACVTAP_QUEUES)
 		goto out;
 
@@ -130,26 +128,25 @@ static int macvtap_set_queue(struct net_device *dev, struct file *file,
 	vlan->numqueues++;
 
 out:
-	spin_unlock(&macvtap_lock);
+	rtnl_unlock();
 	return err;
 }
 
-static int __macvtap_disable_queue(struct macvtap_queue *q)
+static int macvtap_disable_queue(struct macvtap_queue *q)
 {
 	struct macvlan_dev *vlan;
 	struct macvtap_queue *nq;
 
-	vlan = rcu_dereference_protected(q->vlan,
-					 lockdep_is_held(&macvtap_lock));
-
+	ASSERT_RTNL();
 	if (!q->enabled)
 		return -EINVAL;
 
+	vlan = rtnl_dereference(q->vlan);
+
 	if (vlan) {
 		int index = q->queue_index;
 		BUG_ON(index >= vlan->numvtaps);
-		nq = rcu_dereference_protected(vlan->taps[vlan->numvtaps - 1],
-					       lockdep_is_held(&macvtap_lock));
+		nq = rtnl_dereference(vlan->taps[vlan->numvtaps - 1]);
 		nq->queue_index = index;
 
 		rcu_assign_pointer(vlan->taps[index], nq);
@@ -162,17 +159,6 @@ static int __macvtap_disable_queue(struct macvtap_queue *q)
 	return 0;
 }
 
-static int macvtap_disable_queue(struct macvtap_queue *q)
-{
-	int err;
-
-	spin_lock(&macvtap_lock);
-	err = __macvtap_disable_queue(q);
-	spin_unlock(&macvtap_lock);
-
-	return err;
-}
-
 /*
  * The file owning the queue got closed, give up both
  * the reference that the files holds as well as the
@@ -185,12 +171,12 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 {
 	struct macvlan_dev *vlan;
 
-	spin_lock(&macvtap_lock);
-	vlan = rcu_dereference_protected(q->vlan,
-					 lockdep_is_held(&macvtap_lock));
+	rtnl_lock();
+	vlan = rtnl_dereference(q->vlan);
+
 	if (vlan) {
 		if (q->enabled)
-			BUG_ON(__macvtap_disable_queue(q));
+			BUG_ON(macvtap_disable_queue(q));
 
 		vlan->numqueues--;
 		RCU_INIT_POINTER(q->vlan, NULL);
@@ -198,7 +184,7 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 		list_del_init(&q->next);
 	}
 
-	spin_unlock(&macvtap_lock);
+	rtnl_unlock();
 
 	synchronize_rcu();
 	sock_put(&q->sk);
@@ -260,7 +246,7 @@ static void macvtap_del_queues(struct net_device *dev)
 	struct macvtap_queue *q, *tmp, *qlist[MAX_MACVTAP_QUEUES];
 	int i, j = 0;
 
-	spin_lock(&macvtap_lock);
+	ASSERT_RTNL();
 	list_for_each_entry_safe(q, tmp, &vlan->queue_list, next) {
 		list_del_init(&q->next);
 		qlist[j++] = q;
@@ -275,9 +261,6 @@ static void macvtap_del_queues(struct net_device *dev)
 	BUG_ON(vlan->numqueues);
 	/* guarantee that any future macvtap_set_queue will fail */
 	vlan->numvtaps = MAX_MACVTAP_QUEUES;
-	spin_unlock(&macvtap_lock);
-
-	synchronize_rcu();
 
 	for (--j; j >= 0; j--)
 		sock_put(&qlist[j]->sk);
@@ -941,11 +924,10 @@ static struct macvlan_dev *macvtap_get_vlan(struct macvtap_queue *q)
 {
 	struct macvlan_dev *vlan;
 
-	rcu_read_lock_bh();
-	vlan = rcu_dereference_bh(q->vlan);
+	ASSERT_RTNL();
+	vlan = rtnl_dereference(q->vlan);
 	if (vlan)
 		dev_hold(vlan->dev);
-	rcu_read_unlock_bh();
 
 	return vlan;
 }
@@ -1008,21 +990,27 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return ret;
 
 	case TUNGETIFF:
+		rtnl_lock();
 		vlan = macvtap_get_vlan(q);
-		if (!vlan)
+		if (!vlan) {
+			rtnl_unlock();
 			return -ENOLINK;
+		}
 
 		ret = 0;
 		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
 		    put_user(q->flags, &ifr->ifr_flags))
 			ret = -EFAULT;
 		macvtap_put_vlan(vlan);
+		rtnl_unlock();
 		return ret;
 
 	case TUNSETQUEUE:
 		if (get_user(u, &ifr->ifr_flags))
 			return -EFAULT;
-		return macvtap_ioctl_set_queue(file, u);
+		rtnl_lock();
+		ret = macvtap_ioctl_set_queue(file, u);
+		rtnl_unlock();
 
 	case TUNGETFEATURES:
 		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR |
-- 
1.8.1.4
