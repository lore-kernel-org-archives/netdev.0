From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Tue, 22 Jul 2008 14:17:48 -0700 (PDT)
Message-ID: <20080722.141748.192185957.davem@davemloft.net>
References: <20080722.043220.247312412.davem@davemloft.net>
	<4885DA49.50703@lwfinger.net>
	<4885F46A.30309@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, j@w1.fi
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4885F46A.30309-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Date: Tue, 22 Jul 2008 16:53:30 +0200

> Could you please retry with the three patches attached to this
> mail? If the lockdep warning still triggers, please post it again.

Since I'm convinced the original lockdep spurious warning
issue is cured, and we're looking at something different
now, I've integrated all of these fixes together as one
commit as below.

Thanks a lot Patrick.

netdev: Handle ->addr_list_lock just like ->_xmit_lock for lockdep.

The new address list lock needs to handle the same device layering
issues that the _xmit_lock one does.

This integrates work done by Patrick McHardy.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9737c06..a641eea 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5041,6 +5041,7 @@ static int bond_check_params(struct bond_params *params)
 }
 
 static struct lock_class_key bonding_netdev_xmit_lock_key;
+static struct lock_class_key bonding_netdev_addr_lock_key;
 
 static void bond_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -5052,6 +5053,8 @@ static void bond_set_lockdep_class_one(struct net_device *dev,
 
 static void bond_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock,
+			  &bonding_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
 }
 
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index b6500b2..58f4b1d 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -123,6 +123,7 @@ static LIST_HEAD(bpq_devices);
  * off into a separate class since they always nest.
  */
 static struct lock_class_key bpq_netdev_xmit_lock_key;
+static struct lock_class_key bpq_netdev_addr_lock_key;
 
 static void bpq_set_lockdep_class_one(struct net_device *dev,
 				      struct netdev_queue *txq,
@@ -133,6 +134,7 @@ static void bpq_set_lockdep_class_one(struct net_device *dev,
 
 static void bpq_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock, &bpq_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bpq_set_lockdep_class_one, NULL);
 }
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index efbc155..4239450 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -276,6 +276,7 @@ static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
  * separate class since they always nest.
  */
 static struct lock_class_key macvlan_netdev_xmit_lock_key;
+static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
@@ -295,6 +296,8 @@ static void macvlan_set_lockdep_class_one(struct net_device *dev,
 
 static void macvlan_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock,
+			  &macvlan_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, macvlan_set_lockdep_class_one, NULL);
 }
 
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 13d5882..3153fe9 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -3101,6 +3101,7 @@ static void prism2_clear_set_tim_queue(local_info_t *local)
  * This is a natural nesting, which needs a split lock type.
  */
 static struct lock_class_key hostap_netdev_xmit_lock_key;
+static struct lock_class_key hostap_netdev_addr_lock_key;
 
 static void prism2_set_lockdep_class_one(struct net_device *dev,
 					 struct netdev_queue *txq,
@@ -3112,6 +3113,8 @@ static void prism2_set_lockdep_class_one(struct net_device *dev,
 
 static void prism2_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock,
+			  &hostap_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, prism2_set_lockdep_class_one, NULL);
 }
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f42bc2b..4bf014e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -569,6 +569,7 @@ static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
  * separate class since they always nest.
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
+static struct lock_class_key vlan_netdev_addr_lock_key;
 
 static void vlan_dev_set_lockdep_one(struct net_device *dev,
 				     struct netdev_queue *txq,
@@ -581,6 +582,9 @@ static void vlan_dev_set_lockdep_one(struct net_device *dev,
 
 static void vlan_dev_set_lockdep_class(struct net_device *dev, int subclass)
 {
+	lockdep_set_class_and_subclass(&dev->addr_list_lock,
+				       &vlan_netdev_addr_lock_key,
+				       subclass);
 	netdev_for_each_tx_queue(dev, vlan_dev_set_lockdep_one, &subclass);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 65eea83..6bf217d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -261,7 +261,7 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
 
 DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
-#ifdef CONFIG_DEBUG_LOCK_ALLOC
+#ifdef CONFIG_LOCKDEP
 /*
  * register_netdevice() inits txq->_xmit_lock and sets lockdep class
  * according to dev->type
@@ -301,6 +301,7 @@ static const char *netdev_lock_name[] =
 	 "_xmit_NONE"};
 
 static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];
+static struct lock_class_key netdev_addr_lock_key[ARRAY_SIZE(netdev_lock_type)];
 
 static inline unsigned short netdev_lock_pos(unsigned short dev_type)
 {
@@ -313,8 +314,8 @@ static inline unsigned short netdev_lock_pos(unsigned short dev_type)
 	return ARRAY_SIZE(netdev_lock_type) - 1;
 }
 
-static inline void netdev_set_lockdep_class(spinlock_t *lock,
-					    unsigned short dev_type)
+static inline void netdev_set_xmit_lockdep_class(spinlock_t *lock,
+						 unsigned short dev_type)
 {
 	int i;
 
@@ -322,9 +323,22 @@ static inline void netdev_set_lockdep_class(spinlock_t *lock,
 	lockdep_set_class_and_name(lock, &netdev_xmit_lock_key[i],
 				   netdev_lock_name[i]);
 }
+
+static inline void netdev_set_addr_lockdep_class(struct net_device *dev)
+{
+	int i;
+
+	i = netdev_lock_pos(dev->type);
+	lockdep_set_class_and_name(&dev->addr_list_lock,
+				   &netdev_addr_lock_key[i],
+				   netdev_lock_name[i]);
+}
 #else
-static inline void netdev_set_lockdep_class(spinlock_t *lock,
-					    unsigned short dev_type)
+static inline void netdev_set_xmit_lockdep_class(spinlock_t *lock,
+						 unsigned short dev_type)
+{
+}
+static inline void netdev_set_addr_lockdep_class(struct net_device *dev)
 {
 }
 #endif
@@ -3851,7 +3865,7 @@ static void __netdev_init_queue_locks_one(struct net_device *dev,
 					  void *_unused)
 {
 	spin_lock_init(&dev_queue->_xmit_lock);
-	netdev_set_lockdep_class(&dev_queue->_xmit_lock, dev->type);
+	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
 	dev_queue->xmit_lock_owner = -1;
 }
 
@@ -3896,6 +3910,7 @@ int register_netdevice(struct net_device *dev)
 	net = dev_net(dev);
 
 	spin_lock_init(&dev->addr_list_lock);
+	netdev_set_addr_lockdep_class(dev);
 	netdev_init_queue_locks(dev);
 
 	dev->iflink = -1;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index fccc250..532e4fa 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -73,6 +73,7 @@ static const struct proto_ops nr_proto_ops;
  * separate class since they always nest.
  */
 static struct lock_class_key nr_netdev_xmit_lock_key;
+static struct lock_class_key nr_netdev_addr_lock_key;
 
 static void nr_set_lockdep_one(struct net_device *dev,
 			       struct netdev_queue *txq,
@@ -83,6 +84,7 @@ static void nr_set_lockdep_one(struct net_device *dev,
 
 static void nr_set_lockdep_key(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock, &nr_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, nr_set_lockdep_one, NULL);
 }
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index dbc963b..a7f1ce1 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -74,6 +74,7 @@ ax25_address rose_callsign;
  * separate class since they always nest.
  */
 static struct lock_class_key rose_netdev_xmit_lock_key;
+static struct lock_class_key rose_netdev_addr_lock_key;
 
 static void rose_set_lockdep_one(struct net_device *dev,
 				 struct netdev_queue *txq,
@@ -84,6 +85,7 @@ static void rose_set_lockdep_one(struct net_device *dev,
 
 static void rose_set_lockdep_key(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock, &rose_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, rose_set_lockdep_one, NULL);
 }
 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
