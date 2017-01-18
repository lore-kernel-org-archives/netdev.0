From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv2 4/7] TAP: Abstract type of virtual interface from tap  implementation
Date: Tue, 17 Jan 2017 16:03:03 -0800
Message-ID: <1484697786-50323-5-git-send-email-sainath.grandhi@intel.com>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

macvlan object is re-structured to hold tap related elements in a separate
entity, tap_dev. Upon NETDEV_REGISTER device_event, tap_dev is registered with
idr and fetched again on tap_open. Few of the tap functions are modified to
accepted tap_dev as argument. tap_dev object includes callbacks to be used by
underlying virtual interface to take care of tx and rx accounting.

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/macvlan.c      |   2 +-
 drivers/net/macvtap_main.c |  68 +++++++++---
 drivers/net/tap.c          | 264 ++++++++++++++++++++-------------------------
 include/linux/if_tap.h     |  57 +++++++++-
 4 files changed, 226 insertions(+), 165 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 20b3fdf2..79383f9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1526,7 +1526,6 @@ static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
 int macvlan_link_register(struct rtnl_link_ops *ops)
 {
 	/* common fields */
-	ops->priv_size		= sizeof(struct macvlan_dev);
 	ops->validate		= macvlan_validate;
 	ops->maxtype		= IFLA_MACVLAN_MAX;
 	ops->policy		= macvlan_policy;
@@ -1549,6 +1548,7 @@ static struct rtnl_link_ops macvlan_link_ops = {
 	.newlink	= macvlan_newlink,
 	.dellink	= macvlan_dellink,
 	.get_link_net	= macvlan_get_link_net,
+	.priv_size      = sizeof(struct macvlan_dev),
 };
 
 static int macvlan_device_event(struct notifier_block *unused,
diff --git a/drivers/net/macvtap_main.c b/drivers/net/macvtap_main.c
index 32ad560..6326a82 100644
--- a/drivers/net/macvtap_main.c
+++ b/drivers/net/macvtap_main.c
@@ -24,6 +24,11 @@
 #include <linux/virtio_net.h>
 #include <linux/skb_array.h>
 
+struct macvtap_dev {
+	struct macvlan_dev vlan;
+	struct tap_dev    tap;
+};
+
 /*
  * Variables for dealing with macvtaps device numbers.
  */
@@ -46,22 +51,52 @@ static struct cdev macvtap_cdev;
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
 		      NETIF_F_TSO6 | NETIF_F_UFO)
 
+static void macvtap_count_tx_dropped(struct tap_dev *tap)
+{
+	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
+
+	this_cpu_inc(vlan->pcpu_stats->tx_dropped);
+}
+
+static void macvtap_count_rx_dropped(struct tap_dev *tap)
+{
+	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
+
+	macvlan_count_rx(vlan, 0, 0, 0);
+}
+
+static void macvtap_update_features(struct tap_dev *tap,
+				    netdev_features_t features)
+{
+	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
+
+	vlan->set_features = features;
+	netdev_update_features(vlan->dev);
+}
+
 static int macvtap_newlink(struct net *src_net,
 			   struct net_device *dev,
 			   struct nlattr *tb[],
 			   struct nlattr *data[])
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvtap_dev *vlantap = netdev_priv(dev);
 	int err;
 
-	INIT_LIST_HEAD(&vlan->queue_list);
+	INIT_LIST_HEAD(&vlantap->tap.queue_list);
 
 	/* Since macvlan supports all offloads by default, make
 	 * tap support all offloads also.
 	 */
-	vlan->tap_features = TUN_OFFLOADS;
+	vlantap->tap.tap_features = TUN_OFFLOADS;
 
-	err = netdev_rx_handler_register(dev, tap_handle_frame, vlan);
+	/* Register callbacks for rx/tx drops accounting and updating
+	 * net_device features
+	 */
+	vlantap->tap.count_tx_dropped = macvtap_count_tx_dropped;
+	vlantap->tap.count_rx_dropped = macvtap_count_rx_dropped;
+	vlantap->tap.update_features  = macvtap_update_features;
+
+	err = netdev_rx_handler_register(dev, tap_handle_frame, &vlantap->tap);
 	if (err)
 		return err;
 
@@ -74,14 +109,18 @@ static int macvtap_newlink(struct net *src_net,
 		return err;
 	}
 
+	vlantap->tap.dev = vlantap->vlan.dev;
+
 	return 0;
 }
 
 static void macvtap_dellink(struct net_device *dev,
 			    struct list_head *head)
 {
+	struct macvtap_dev *vlantap = netdev_priv(dev);
+
 	netdev_rx_handler_unregister(dev);
-	tap_del_queues(dev);
+	tap_del_queues(&vlantap->tap);
 	macvlan_dellink(dev, head);
 }
 
@@ -96,13 +135,14 @@ static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
 	.setup		= macvtap_setup,
 	.newlink	= macvtap_newlink,
 	.dellink	= macvtap_dellink,
+	.priv_size      = sizeof(struct macvtap_dev),
 };
 
 static int macvtap_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct macvlan_dev *vlan;
+	struct macvtap_dev *vlantap;
 	struct device *classdev;
 	dev_t devt;
 	int err;
@@ -112,7 +152,7 @@ static int macvtap_device_event(struct notifier_block *unused,
 		return NOTIFY_DONE;
 
 	snprintf(tap_name, IFNAMSIZ, "tap%d", dev->ifindex);
-	vlan = netdev_priv(dev);
+	vlantap = netdev_priv(dev);
 
 	switch (event) {
 	case NETDEV_REGISTER:
@@ -120,15 +160,15 @@ static int macvtap_device_event(struct notifier_block *unused,
 		 * been registered but before register_netdevice has
 		 * finished running.
 		 */
-		err = tap_get_minor(vlan);
+		err = tap_get_minor(&vlantap->tap);
 		if (err)
 			return notifier_from_errno(err);
 
-		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
+		devt = MKDEV(MAJOR(macvtap_major), vlantap->tap.minor);
 		classdev = device_create(&macvtap_class, &dev->dev, devt,
 					 dev, tap_name);
 		if (IS_ERR(classdev)) {
-			tap_free_minor(vlan);
+			tap_free_minor(&vlantap->tap);
 			return notifier_from_errno(PTR_ERR(classdev));
 		}
 		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
@@ -138,15 +178,15 @@ static int macvtap_device_event(struct notifier_block *unused,
 		break;
 	case NETDEV_UNREGISTER:
 		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
-		if (vlan->minor == 0)
+		if (vlantap->tap.minor == 0)
 			break;
 		sysfs_remove_link(&dev->dev.kobj, tap_name);
-		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
+		devt = MKDEV(MAJOR(macvtap_major), vlantap->tap.minor);
 		device_destroy(&macvtap_class, devt);
-		tap_free_minor(vlan);
+		tap_free_minor(&vlantap->tap);
 		break;
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
-		if (tap_queue_resize(vlan))
+		if (tap_queue_resize(&vlantap->tap))
 			return NOTIFY_BAD;
 		break;
 	}
diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 774ef33..43d9d54 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -1,5 +1,5 @@
 #include <linux/etherdevice.h>
-#include <linux/if_macvlan.h>
+#include <linux/if_tap.h>
 #include <linux/if_vlan.h>
 #include <linux/interrupt.h>
 #include <linux/nsproxy.h>
@@ -23,30 +23,6 @@
 #include <linux/virtio_net.h>
 #include <linux/skb_array.h>
 
-/*
- * A tap queue is the central object of this driver, it connects
- * an open character device to a macvlan interface. There can be
- * multiple queues on one interface, which map back to queues
- * implemented in hardware on the underlying device.
- *
- * tap_proto is used to allocate queues through the sock allocation
- * mechanism.
- *
- */
-struct tap_queue {
-	struct sock sk;
-	struct socket sock;
-	struct socket_wq wq;
-	int vnet_hdr_sz;
-	struct macvlan_dev __rcu *vlan;
-	struct file *file;
-	unsigned int flags;
-	u16 queue_index;
-	bool enabled;
-	struct list_head next;
-	struct skb_array skb_array;
-};
-
 #define TAP_IFFEATURES (IFF_VNET_HDR | IFF_MULTI_QUEUE)
 
 #define TAP_VNET_LE 0x80000000
@@ -137,7 +113,7 @@ static const struct proto_ops tap_socket_ops;
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
 #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG | NETIF_F_FRAGLIST)
 
-static struct macvlan_dev *tap_get_vlan_rcu(const struct net_device *dev)
+static struct tap_dev *tap_dev_get_rcu(const struct net_device *dev)
 {
 	return rcu_dereference(dev->rx_handler_data);
 }
@@ -159,10 +135,9 @@ static struct macvlan_dev *tap_get_vlan_rcu(const struct net_device *dev)
  * when both our references and any pending SKBs are gone.
  */
 
-static int tap_enable_queue(struct net_device *dev, struct file *file,
+static int tap_enable_queue(struct tap_dev *tap, struct file *file,
 			    struct tap_queue *q)
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
 	int err = -EINVAL;
 
 	ASSERT_RTNL();
@@ -171,62 +146,60 @@ static int tap_enable_queue(struct net_device *dev, struct file *file,
 		goto out;
 
 	err = 0;
-	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
-	q->queue_index = vlan->numvtaps;
+	rcu_assign_pointer(tap->taps[tap->numvtaps], q);
+	q->queue_index = tap->numvtaps;
 	q->enabled = true;
 
-	vlan->numvtaps++;
+	tap->numvtaps++;
 out:
 	return err;
 }
 
 /* Requires RTNL */
-static int tap_set_queue(struct net_device *dev, struct file *file,
+static int tap_set_queue(struct tap_dev *tap, struct file *file,
 			 struct tap_queue *q)
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
-
-	if (vlan->numqueues == MAX_TAP_QUEUES)
+	if (tap->numqueues == MAX_TAP_QUEUES)
 		return -EBUSY;
 
-	rcu_assign_pointer(q->vlan, vlan);
-	rcu_assign_pointer(vlan->taps[vlan->numvtaps], q);
+	rcu_assign_pointer(q->tap, tap);
+	rcu_assign_pointer(tap->taps[tap->numvtaps], q);
 	sock_hold(&q->sk);
 
 	q->file = file;
-	q->queue_index = vlan->numvtaps;
+	q->queue_index = tap->numvtaps;
 	q->enabled = true;
 	file->private_data = q;
-	list_add_tail(&q->next, &vlan->queue_list);
+	list_add_tail(&q->next, &tap->queue_list);
 
-	vlan->numvtaps++;
-	vlan->numqueues++;
+	tap->numvtaps++;
+	tap->numqueues++;
 
 	return 0;
 }
 
 static int tap_disable_queue(struct tap_queue *q)
 {
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 	struct tap_queue *nq;
 
 	ASSERT_RTNL();
 	if (!q->enabled)
 		return -EINVAL;
 
-	vlan = rtnl_dereference(q->vlan);
+	tap = rtnl_dereference(q->tap);
 
-	if (vlan) {
+	if (tap) {
 		int index = q->queue_index;
-		BUG_ON(index >= vlan->numvtaps);
-		nq = rtnl_dereference(vlan->taps[vlan->numvtaps - 1]);
+		BUG_ON(index >= tap->numvtaps);
+		nq = rtnl_dereference(tap->taps[tap->numvtaps - 1]);
 		nq->queue_index = index;
 
-		rcu_assign_pointer(vlan->taps[index], nq);
-		RCU_INIT_POINTER(vlan->taps[vlan->numvtaps - 1], NULL);
+		rcu_assign_pointer(tap->taps[index], nq);
+		RCU_INIT_POINTER(tap->taps[tap->numvtaps - 1], NULL);
 		q->enabled = false;
 
-		vlan->numvtaps--;
+		tap->numvtaps--;
 	}
 
 	return 0;
@@ -242,17 +215,17 @@ static int tap_disable_queue(struct tap_queue *q)
  */
 static void tap_put_queue(struct tap_queue *q)
 {
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 
 	rtnl_lock();
-	vlan = rtnl_dereference(q->vlan);
+	tap = rtnl_dereference(q->tap);
 
-	if (vlan) {
+	if (tap) {
 		if (q->enabled)
 			BUG_ON(tap_disable_queue(q));
 
-		vlan->numqueues--;
-		RCU_INIT_POINTER(q->vlan, NULL);
+		tap->numqueues--;
+		RCU_INIT_POINTER(q->tap, NULL);
 		sock_put(&q->sk);
 		list_del_init(&q->next);
 	}
@@ -270,17 +243,16 @@ static void tap_put_queue(struct tap_queue *q)
  * Cache vlan->numvtaps since it can become zero during the execution
  * of this function.
  */
-static struct tap_queue *tap_get_queue(struct net_device *dev,
+static struct tap_queue *tap_get_queue(struct tap_dev *tap,
 				       struct sk_buff *skb)
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct tap_queue *tap = NULL;
+	struct tap_queue *queue = NULL;
 	/* Access to taps array is protected by rcu, but access to numvtaps
 	 * isn't. Below we use it to lookup a queue, but treat it as a hint
 	 * and validate that the result isn't NULL - in case we are
 	 * racing against queue removal.
 	 */
-	int numvtaps = ACCESS_ONCE(vlan->numvtaps);
+	int numvtaps = ACCESS_ONCE(tap->numvtaps);
 	__u32 rxq;
 
 	if (!numvtaps)
@@ -292,7 +264,7 @@ static struct tap_queue *tap_get_queue(struct net_device *dev,
 	/* Check if we can use flow to select a queue */
 	rxq = skb_get_hash(skb);
 	if (rxq) {
-		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
+		queue = rcu_dereference(tap->taps[rxq % numvtaps]);
 		goto out;
 	}
 
@@ -302,14 +274,14 @@ static struct tap_queue *tap_get_queue(struct net_device *dev,
 		while (unlikely(rxq >= numvtaps))
 			rxq -= numvtaps;
 
-		tap = rcu_dereference(vlan->taps[rxq]);
+		queue = rcu_dereference(tap->taps[rxq]);
 		goto out;
 	}
 
 single:
-	tap = rcu_dereference(vlan->taps[0]);
+	queue = rcu_dereference(tap->taps[0]);
 out:
-	return tap;
+	return queue;
 }
 
 /*
@@ -317,39 +289,38 @@ static struct tap_queue *tap_get_queue(struct net_device *dev,
  * that it holds on all queues and safely set the pointer
  * from the queues to NULL.
  */
-void tap_del_queues(struct net_device *dev)
+void tap_del_queues(struct tap_dev *tap)
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct tap_queue *q, *tmp;
 
 	ASSERT_RTNL();
-	list_for_each_entry_safe(q, tmp, &vlan->queue_list, next) {
+	list_for_each_entry_safe(q, tmp, &tap->queue_list, next) {
 		list_del_init(&q->next);
-		RCU_INIT_POINTER(q->vlan, NULL);
+		RCU_INIT_POINTER(q->tap, NULL);
 		if (q->enabled)
-			vlan->numvtaps--;
-		vlan->numqueues--;
+			tap->numvtaps--;
+		tap->numqueues--;
 		sock_put(&q->sk);
 	}
-	BUG_ON(vlan->numvtaps);
-	BUG_ON(vlan->numqueues);
+	BUG_ON(tap->numvtaps);
+	BUG_ON(tap->numqueues);
 	/* guarantee that any future tap_set_queue will fail */
-	vlan->numvtaps = MAX_TAP_QUEUES;
+	tap->numvtaps = MAX_TAP_QUEUES;
 }
 
 rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
 	struct net_device *dev = skb->dev;
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 	struct tap_queue *q;
 	netdev_features_t features = TAP_FEATURES;
 
-	vlan = tap_get_vlan_rcu(dev);
-	if (!vlan)
+	tap = tap_dev_get_rcu(dev);
+	if (!tap)
 		return RX_HANDLER_PASS;
 
-	q = tap_get_queue(dev, skb);
+	q = tap_get_queue(tap, skb);
 	if (!q)
 		return RX_HANDLER_PASS;
 
@@ -363,7 +334,7 @@ rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 	 * enabled.
 	 */
 	if (q->flags & IFF_VNET_HDR)
-		features |= vlan->tap_features;
+		features |= tap->tap_features;
 	if (netif_needs_gso(skb, features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
@@ -408,50 +379,51 @@ rx_handler_result_t tap_handle_frame(struct sk_buff **pskb)
 
 drop:
 	/* Count errors/drops only here, thus don't care about args. */
-	macvlan_count_rx(vlan, 0, 0, 0);
+	if (tap->count_rx_dropped)
+		tap->count_rx_dropped(tap);
 	kfree_skb(skb);
 	return RX_HANDLER_CONSUMED;
 }
 
-int tap_get_minor(struct macvlan_dev *vlan)
+int tap_get_minor(struct tap_dev *tap)
 {
 	int retval = -ENOMEM;
 
 	mutex_lock(&macvtap_major.minor_lock);
-	retval = idr_alloc(&macvtap_major.minor_idr, vlan, 1, TAP_NUM_DEVS, GFP_KERNEL);
+	retval = idr_alloc(&macvtap_major.minor_idr, tap, 1, TAP_NUM_DEVS, GFP_KERNEL);
 	if (retval >= 0) {
-		vlan->minor = retval;
+		tap->minor = retval;
 	} else if (retval == -ENOSPC) {
-		netdev_err(vlan->dev, "Too many tap devices\n");
+		netdev_err(tap->dev, "Too many tap devices\n");
 		retval = -EINVAL;
 	}
 	mutex_unlock(&macvtap_major.minor_lock);
 	return retval < 0 ? retval : 0;
 }
 
-void tap_free_minor(struct macvlan_dev *vlan)
+void tap_free_minor(struct tap_dev *tap)
 {
 	mutex_lock(&macvtap_major.minor_lock);
-	if (vlan->minor) {
-		idr_remove(&macvtap_major.minor_idr, vlan->minor);
-		vlan->minor = 0;
+	if (tap->minor) {
+		idr_remove(&macvtap_major.minor_idr, tap->minor);
+		tap->minor = 0;
 	}
 	mutex_unlock(&macvtap_major.minor_lock);
 }
 
-static struct net_device *dev_get_by_tap_minor(int minor)
+static struct tap_dev *dev_get_by_tap_minor(int minor)
 {
 	struct net_device *dev = NULL;
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 
 	mutex_lock(&macvtap_major.minor_lock);
-	vlan = idr_find(&macvtap_major.minor_idr, minor);
-	if (vlan) {
-		dev = vlan->dev;
+	tap = idr_find(&macvtap_major.minor_idr, minor);
+	if (tap) {
+		dev = tap->dev;
 		dev_hold(dev);
 	}
 	mutex_unlock(&macvtap_major.minor_lock);
-	return dev;
+	return tap;
 }
 
 static void tap_sock_write_space(struct sock *sk)
@@ -477,13 +449,13 @@ static void tap_sock_destruct(struct sock *sk)
 static int tap_open(struct inode *inode, struct file *file)
 {
 	struct net *net = current->nsproxy->net_ns;
-	struct net_device *dev;
+	struct tap_dev *tap;
 	struct tap_queue *q;
 	int err = -ENODEV;
 
 	rtnl_lock();
-	dev = dev_get_by_tap_minor(iminor(inode));
-	if (!dev)
+	tap = dev_get_by_tap_minor(iminor(inode));
+	if (!tap)
 		goto err;
 
 	err = -ENOMEM;
@@ -511,18 +483,18 @@ static int tap_open(struct inode *inode, struct file *file)
 	 * The macvlan supports zerocopy iff the lower device supports zero
 	 * copy so we don't have to look at the lower device directly.
 	 */
-	if ((dev->features & NETIF_F_HIGHDMA) && (dev->features & NETIF_F_SG))
+	if ((tap->dev->features & NETIF_F_HIGHDMA) && (tap->dev->features & NETIF_F_SG))
 		sock_set_flag(&q->sk, SOCK_ZEROCOPY);
 
 	err = -ENOMEM;
-	if (skb_array_init(&q->skb_array, dev->tx_queue_len, GFP_KERNEL))
+	if (skb_array_init(&q->skb_array, tap->dev->tx_queue_len, GFP_KERNEL))
 		goto err_array;
 
-	err = tap_set_queue(dev, file, q);
+	err = tap_set_queue(tap, file, q);
 	if (err)
 		goto err_queue;
 
-	dev_put(dev);
+	dev_put(tap->dev);
 
 	rtnl_unlock();
 	return err;
@@ -532,8 +504,8 @@ static int tap_open(struct inode *inode, struct file *file)
 err_array:
 	sock_put(&q->sk);
 err:
-	if (dev)
-		dev_put(dev);
+	if (tap)
+		dev_put(tap->dev);
 
 	rtnl_unlock();
 	return err;
@@ -601,7 +573,7 @@ static ssize_t tap_get_user(struct tap_queue *q, struct msghdr *m,
 {
 	int good_linear = SKB_MAX_HEAD(TAP_RESERVE);
 	struct sk_buff *skb;
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 	unsigned long total_len = iov_iter_count(from);
 	unsigned long len = total_len;
 	int err;
@@ -698,7 +670,7 @@ static ssize_t tap_get_user(struct tap_queue *q, struct msghdr *m,
 		skb_set_network_header(skb, depth);
 
 	rcu_read_lock();
-	vlan = rcu_dereference(q->vlan);
+	tap = rcu_dereference(q->tap);
 	/* copy skb_ubuf_info for callback when skb has no error */
 	if (zerocopy) {
 		skb_shinfo(skb)->destructor_arg = m->msg_control;
@@ -709,8 +681,8 @@ static ssize_t tap_get_user(struct tap_queue *q, struct msghdr *m,
 		uarg->callback(uarg, false);
 	}
 
-	if (vlan) {
-		skb->dev = vlan->dev;
+	if (tap) {
+		skb->dev = tap->dev;
 		dev_queue_xmit(skb);
 	} else {
 		kfree_skb(skb);
@@ -724,9 +696,9 @@ static ssize_t tap_get_user(struct tap_queue *q, struct msghdr *m,
 
 err:
 	rcu_read_lock();
-	vlan = rcu_dereference(q->vlan);
-	if (vlan)
-		this_cpu_inc(vlan->pcpu_stats->tx_dropped);
+	tap = rcu_dereference(q->tap);
+	if (tap && tap->count_tx_dropped)
+		tap->count_tx_dropped(tap);
 	rcu_read_unlock();
 
 	return err;
@@ -853,55 +825,55 @@ static ssize_t tap_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	return ret;
 }
 
-static struct macvlan_dev *tap_get_vlan(struct tap_queue *q)
+static struct tap_dev *tap_get_tap_dev(struct tap_queue *q)
 {
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 
 	ASSERT_RTNL();
-	vlan = rtnl_dereference(q->vlan);
-	if (vlan)
-		dev_hold(vlan->dev);
+	tap = rtnl_dereference(q->tap);
+	if (tap)
+		dev_hold(tap->dev);
 
-	return vlan;
+	return tap;
 }
 
-static void tap_put_vlan(struct macvlan_dev *vlan)
+static void tap_put_tap_dev(struct tap_dev *tap)
 {
-	dev_put(vlan->dev);
+	dev_put(tap->dev);
 }
 
 static int tap_ioctl_set_queue(struct file *file, unsigned int flags)
 {
 	struct tap_queue *q = file->private_data;
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 	int ret;
 
-	vlan = tap_get_vlan(q);
-	if (!vlan)
+	tap = tap_get_tap_dev(q);
+	if (!tap)
 		return -EINVAL;
 
 	if (flags & IFF_ATTACH_QUEUE)
-		ret = tap_enable_queue(vlan->dev, file, q);
+		ret = tap_enable_queue(tap, file, q);
 	else if (flags & IFF_DETACH_QUEUE)
 		ret = tap_disable_queue(q);
 	else
 		ret = -EINVAL;
 
-	tap_put_vlan(vlan);
+	tap_put_tap_dev(tap);
 	return ret;
 }
 
 static int set_offload(struct tap_queue *q, unsigned long arg)
 {
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 	netdev_features_t features;
 	netdev_features_t feature_mask = 0;
 
-	vlan = rtnl_dereference(q->vlan);
-	if (!vlan)
+	tap = rtnl_dereference(q->tap);
+	if (!tap)
 		return -ENOLINK;
 
-	features = vlan->dev->features;
+	features = tap->dev->features;
 
 	if (arg & TUN_F_CSUM) {
 		feature_mask = NETIF_F_HW_CSUM;
@@ -935,9 +907,9 @@ static int set_offload(struct tap_queue *q, unsigned long arg)
 	/* tap_features are the same as features on tun/tap and
 	 * reflect user expectations.
 	 */
-	vlan->tap_features = feature_mask;
-	vlan->set_features = features;
-	netdev_update_features(vlan->dev);
+	tap->tap_features = feature_mask;
+	if (tap->update_features)
+		tap->update_features(tap, features);
 
 	return 0;
 }
@@ -949,7 +921,7 @@ static long tap_ioctl(struct file *file, unsigned int cmd,
 		      unsigned long arg)
 {
 	struct tap_queue *q = file->private_data;
-	struct macvlan_dev *vlan;
+	struct tap_dev *tap;
 	void __user *argp = (void __user *)arg;
 	struct ifreq __user *ifr = argp;
 	unsigned int __user *up = argp;
@@ -975,18 +947,18 @@ static long tap_ioctl(struct file *file, unsigned int cmd,
 
 	case TUNGETIFF:
 		rtnl_lock();
-		vlan = tap_get_vlan(q);
-		if (!vlan) {
+		tap = tap_get_tap_dev(q);
+		if (!tap) {
 			rtnl_unlock();
 			return -ENOLINK;
 		}
 
 		ret = 0;
 		u = q->flags;
-		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
+		if (copy_to_user(&ifr->ifr_name, tap->dev->name, IFNAMSIZ) ||
 		    put_user(u, &ifr->ifr_flags))
 			ret = -EFAULT;
-		tap_put_vlan(vlan);
+		tap_put_tap_dev(tap);
 		rtnl_unlock();
 		return ret;
 
@@ -1059,18 +1031,18 @@ static long tap_ioctl(struct file *file, unsigned int cmd,
 
 	case SIOCGIFHWADDR:
 		rtnl_lock();
-		vlan = tap_get_vlan(q);
-		if (!vlan) {
+		tap = tap_get_tap_dev(q);
+		if (!tap) {
 			rtnl_unlock();
 			return -ENOLINK;
 		}
 		ret = 0;
-		u = vlan->dev->type;
-		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
-		    copy_to_user(&ifr->ifr_hwaddr.sa_data, vlan->dev->dev_addr, ETH_ALEN) ||
+		u = tap->dev->type;
+		if (copy_to_user(&ifr->ifr_name, tap->dev->name, IFNAMSIZ) ||
+		    copy_to_user(&ifr->ifr_hwaddr.sa_data, tap->dev->dev_addr, ETH_ALEN) ||
 		    put_user(u, &ifr->ifr_hwaddr.sa_family))
 			ret = -EFAULT;
-		tap_put_vlan(vlan);
+		tap_put_tap_dev(tap);
 		rtnl_unlock();
 		return ret;
 
@@ -1078,13 +1050,13 @@ static long tap_ioctl(struct file *file, unsigned int cmd,
 		if (copy_from_user(&sa, &ifr->ifr_hwaddr, sizeof(sa)))
 			return -EFAULT;
 		rtnl_lock();
-		vlan = tap_get_vlan(q);
-		if (!vlan) {
+		tap = tap_get_tap_dev(q);
+		if (!tap) {
 			rtnl_unlock();
 			return -ENOLINK;
 		}
-		ret = dev_set_mac_address(vlan->dev, &sa);
-		tap_put_vlan(vlan);
+		ret = dev_set_mac_address(tap->dev, &sa);
+		tap_put_tap_dev(tap);
 		rtnl_unlock();
 		return ret;
 
@@ -1167,19 +1139,19 @@ struct socket *tap_get_socket(struct file *file)
 }
 EXPORT_SYMBOL_GPL(tap_get_socket);
 
-int tap_queue_resize(struct macvlan_dev *vlan)
+int tap_queue_resize(struct tap_dev *tap)
 {
-	struct net_device *dev = vlan->dev;
+	struct net_device *dev = tap->dev;
 	struct tap_queue *q;
 	struct skb_array **arrays;
-	int n = vlan->numqueues;
+	int n = tap->numqueues;
 	int ret, i = 0;
 
 	arrays = kmalloc(sizeof *arrays * n, GFP_KERNEL);
 	if (!arrays)
 		return -ENOMEM;
 
-	list_for_each_entry(q, &vlan->queue_list, next)
+	list_for_each_entry(q, &tap->queue_list, next)
 		arrays[i++] = &q->skb_array;
 
 	ret = skb_array_resize_multiple(arrays, n,
diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h
index a2dfd90..75031e5 100644
--- a/include/linux/if_tap.h
+++ b/include/linux/if_tap.h
@@ -14,11 +14,60 @@ static inline struct socket *tap_get_socket(struct file *f)
 }
 #endif /* CONFIG_MACVTAP */
 
+#include <net/sock.h>
+#include <linux/skb_array.h>
+
+#define MAX_TAP_QUEUES 256
+
+struct tap_queue;
+
+struct tap_dev {
+	struct net_device	*dev;
+	u16			flags;
+	/* This array tracks active taps. */
+	struct tap_queue    __rcu *taps[MAX_TAP_QUEUES];
+	/* This list tracks all taps (both enabled and disabled) */
+	struct list_head	queue_list;
+	int			numvtaps;
+	int			numqueues;
+	netdev_features_t	tap_features;
+	int			minor;
+
+	void (*update_features)(struct tap_dev *tap, netdev_features_t features);
+	void (*count_tx_dropped)(struct tap_dev *tap);
+	void (*count_rx_dropped)(struct tap_dev *tap);
+};
+
+/*
+ * A tap queue is the central object of tap module, it connects
+ * an open character device to virtual interface. There can be
+ * multiple queues on one interface, which map back to queues
+ * implemented in hardware on the underlying device.
+ *
+ * tap_proto is used to allocate queues through the sock allocation
+ * mechanism.
+ *
+ */
+
+struct tap_queue {
+	struct sock sk;
+	struct socket sock;
+	struct socket_wq wq;
+	int vnet_hdr_sz;
+	struct tap_dev __rcu *tap;
+	struct file *file;
+	unsigned int flags;
+	u16 queue_index;
+	bool enabled;
+	struct list_head next;
+	struct skb_array skb_array;
+};
+
 rx_handler_result_t tap_handle_frame(struct sk_buff **pskb);
-void tap_del_queues(struct net_device *dev);
-int tap_get_minor(struct macvlan_dev *vlan);
-void tap_free_minor(struct macvlan_dev *vlan);
-int tap_queue_resize(struct macvlan_dev *vlan);
+void tap_del_queues(struct tap_dev *tap);
+int tap_get_minor(struct tap_dev *tap);
+void tap_free_minor(struct tap_dev *tap);
+int tap_queue_resize(struct tap_dev *tap);
 int tap_create_cdev(struct cdev *tap_cdev,
 		    dev_t *tap_major, const char *device_name);
 void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev);
-- 
2.7.4
