From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 7/8] macvtap: add TUNSETQUEUE ioctl
Date: Thu,  6 Jun 2013 17:54:39 +0800
Message-ID: <1370512480-14272-8-git-send-email-jasowang@redhat.com>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds TUNSETQUEUE ioctl to let userspace can temporarily disable or
enable a queue of macvtap. This is used to be compatible at API layer of tuntap
to simplify the userspace to manage the queues. This is done through introducing
a linked list to track all taps while using vlan->taps array to only track
active taps.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c      |  135 +++++++++++++++++++++++++++++++++++++------
 include/linux/if_macvlan.h |    4 +
 2 files changed, 120 insertions(+), 19 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5ccba99..d2d1d55 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -45,6 +45,8 @@ struct macvtap_queue {
 	struct file *file;
 	unsigned int flags;
 	u16 queue_index;
+	bool enabled;
+	struct list_head next;
 };
 
 static struct proto macvtap_proto = {
@@ -85,14 +87,36 @@ static const struct proto_ops macvtap_socket_ops;
  */
 static DEFINE_SPINLOCK(macvtap_lock);
 
-static int macvtap_set_queue(struct net_device *dev, struct file *file,
+static int macvtap_enable_queue(struct net_device *dev, struct file *file,
 				struct macvtap_queue *q)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err = -EINVAL;
+
+	spin_lock(&macvtap_lock);
+
+	if (q->enabled)
+		goto out;
+
+	err = 0;
+	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
+	q->queue_index = vlan->numvtaps;
+	q->enabled = true;
+
+	vlan->numvtaps++;
+out:
+	spin_unlock(&macvtap_lock);
+	return err;
+}
+
+static int macvtap_set_queue(struct net_device *dev, struct file *file,
+			     struct macvtap_queue *q)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
 	int err = -EBUSY;
 
 	spin_lock(&macvtap_lock);
-	if (vlan->numvtaps == MAX_MACVTAP_QUEUES)
+	if (vlan->numqueues == MAX_MACVTAP_QUEUES)
 		goto out;
 
 	err = 0;
@@ -102,15 +126,57 @@ static int macvtap_set_queue(struct net_device *dev, struct file *file,
 
 	q->file = file;
 	q->queue_index = vlan->numvtaps;
+	q->enabled = true;
 	file->private_data = q;
+	list_add_tail(&q->next, &vlan->queue_list);
 
 	vlan->numvtaps++;
+	vlan->numqueues++;
 
 out:
 	spin_unlock(&macvtap_lock);
 	return err;
 }
 
+static int __macvtap_disable_queue(struct macvtap_queue *q)
+{
+	struct macvlan_dev *vlan;
+	struct macvtap_queue *nq;
+
+	vlan = rcu_dereference_protected(q->vlan,
+					 lockdep_is_held(&macvtap_lock));
+
+	if (!q->enabled)
+		return -EINVAL;
+
+	if (vlan) {
+		int index = q->queue_index;
+		BUG_ON(index >= vlan->numvtaps);
+		nq = rcu_dereference_protected(vlan->taps[vlan->numvtaps - 1],
+					       lockdep_is_held(&macvtap_lock));
+		nq->queue_index = index;
+
+		rcu_assign_pointer(vlan->taps[index], nq);
+		RCU_INIT_POINTER(vlan->taps[vlan->numvtaps - 1], NULL);
+		q->enabled = false;
+
+		vlan->numvtaps--;
+	}
+
+	return 0;
+}
+
+static int macvtap_disable_queue(struct macvtap_queue *q)
+{
+	int err;
+
+	spin_lock(&macvtap_lock);
+	err = __macvtap_disable_queue(q);
+	spin_unlock(&macvtap_lock);
+
+	return err;
+}
+
 /*
  * The file owning the queue got closed, give up both
  * the reference that the files holds as well as the
@@ -121,25 +187,19 @@ out:
  */
 static void macvtap_put_queue(struct macvtap_queue *q)
 {
-	struct macvtap_queue *nq;
 	struct macvlan_dev *vlan;
 
 	spin_lock(&macvtap_lock);
 	vlan = rcu_dereference_protected(q->vlan,
 					 lockdep_is_held(&macvtap_lock));
 	if (vlan) {
-		int index = q->queue_index;
-		BUG_ON(index >= vlan->numvtaps);
-
-		nq = rcu_dereference_protected(vlan->taps[vlan->numvtaps - 1],
-					       lockdep_is_held(&macvtap_lock));
-		rcu_assign_pointer(vlan->taps[index], nq);
-		nq->queue_index = index;
+		if (q->enabled)
+			BUG_ON(__macvtap_disable_queue(q));
 
-		RCU_INIT_POINTER(vlan->taps[vlan->numvtaps - 1], NULL);
+		vlan->numqueues--;
 		RCU_INIT_POINTER(q->vlan, NULL);
 		sock_put(&q->sk);
-		--vlan->numvtaps;
+		list_del_init(&q->next);
 	}
 
 	spin_unlock(&macvtap_lock);
@@ -160,6 +220,11 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvtap_queue *tap = NULL;
+	/* Access to taps array is protected by rcu, but access to numvtaps
+	 * isn't. Below we use it to lookup a queue, but treat it as a hint
+	 * and validate that the result isn't NULL - in case we are
+	 * racing against queue removal.
+	 */
 	int numvtaps = ACCESS_ONCE(vlan->numvtaps);
 	__u32 rxq;
 
@@ -196,18 +261,22 @@ out:
 static void macvtap_del_queues(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvtap_queue *q, *qlist[MAX_MACVTAP_QUEUES];
+	struct macvtap_queue *q, *tmp, *qlist[MAX_MACVTAP_QUEUES];
 	int i, j = 0;
 
 	spin_lock(&macvtap_lock);
-	for (i = 0; i < vlan->numvtaps; i++) {
-		q = rcu_dereference_protected(vlan->taps[i],
-					      lockdep_is_held(&macvtap_lock));
-		BUG_ON(q == NULL);
+	list_for_each_entry_safe(q, tmp, &vlan->queue_list, next) {
+		list_del_init(&q->next);
 		qlist[j++] = q;
-		RCU_INIT_POINTER(vlan->taps[i], NULL);
 		RCU_INIT_POINTER(q->vlan, NULL);
+		if (q->enabled)
+			vlan->numvtaps--;
+		vlan->numqueues--;
 	}
+	for (i = 0; i < vlan->numvtaps; i++)
+		RCU_INIT_POINTER(vlan->taps[i], NULL);
+	BUG_ON(vlan->numvtaps);
+	BUG_ON(vlan->numqueues);
 	/* guarantee that any future macvtap_set_queue will fail */
 	vlan->numvtaps = MAX_MACVTAP_QUEUES;
 	spin_unlock(&macvtap_lock);
@@ -298,6 +367,9 @@ static int macvtap_newlink(struct net *src_net,
 			   struct nlattr *tb[],
 			   struct nlattr *data[])
 {
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	INIT_LIST_HEAD(&vlan->queue_list);
+
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
@@ -887,6 +959,25 @@ static void macvtap_put_vlan(struct macvlan_dev *vlan)
 	dev_put(vlan->dev);
 }
 
+static int macvtap_ioctl_set_queue(struct file *file, unsigned int flags)
+{
+	struct macvtap_queue *q = file->private_data;
+	struct macvlan_dev *vlan;
+	int ret;
+
+	vlan = macvtap_get_vlan(q);
+	if (!vlan)
+		return -EINVAL;
+
+	if (flags & IFF_ATTACH_QUEUE)
+		ret = macvtap_enable_queue(vlan->dev, file, q);
+	else if (flags & IFF_DETACH_QUEUE)
+		ret = macvtap_disable_queue(q);
+
+	macvtap_put_vlan(vlan);
+	return ret;
+}
+
 /*
  * provide compatibility with generic tun/tap interface
  */
@@ -910,7 +1001,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			return -EFAULT;
 
 		ret = 0;
-		if ((u & ~IFF_VNET_HDR) != (IFF_NO_PI | IFF_TAP))
+		if ((u & ~(IFF_VNET_HDR | IFF_MULTI_QUEUE)) !=
+		    (IFF_NO_PI | IFF_TAP))
 			ret = -EINVAL;
 		else
 			q->flags = u;
@@ -929,6 +1021,11 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		macvtap_put_vlan(vlan);
 		return ret;
 
+	case TUNSETQUEUE:
+		if (get_user(u, &ifr->ifr_flags))
+			return -EFAULT;
+		return macvtap_ioctl_set_queue(file, u);
+
 	case TUNGETFEATURES:
 		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
 			return -EFAULT;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 62d8bda..1912133 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -69,8 +69,12 @@ struct macvlan_dev {
 	u16			flags;
 	int (*receive)(struct sk_buff *skb);
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
+	/* This array tracks active taps. */
 	struct macvtap_queue	*taps[MAX_MACVTAP_QUEUES];
+	/* This list tracks all taps (both enabled and disabled) */
+	struct list_head	queue_list;
 	int			numvtaps;
+	int			numqueues;
 	int			minor;
 };
 
-- 
1.7.1
