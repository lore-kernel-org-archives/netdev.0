From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 8/8] net/emergency: remove locking from reycling pool if emergncy pools are not used
Date: Fri,  2 Jul 2010 21:20:21 +0200
Message-ID: <1278098421-21296-9-git-send-email-sebastian@breakpoint.cc>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41211 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757621Ab0GBTUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:20:36 -0400
In-Reply-To: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Right now both users (socket and network driver) are accessing the
emergency pools locked. If there is no socket user then we have only the
NIC driver which is touching the pool in its napi callback. The locking
is not required since the driver has its own locking.

Disabling the emergency pools results in emerg_skb_users going down to
zero. Once the driver notices this then further allocations will be lock
less. This is performed while holding the list lock of the pool to
ensure that all users which touch the struct locked are gone.
Enabling the pools for the socket user requires that the NIC driver is
not touching the pool unlocked. This is ensured by the ndo_emerg_reload
callback which performs a lightweight disable/enable of the card.

As a side effect, the emergency mode of the nic is now deactivated once
the last user is gone.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/gianfar.c     |   10 ++++
 drivers/net/ucc_geth.c    |    8 ++++
 include/linux/netdevice.h |   55 ++++++++++++++++++++++--
 net/core/dev.c            |    1 +
 net/core/skbuff.c         |   19 ++++++++-
 net/core/sock.c           |  101 ++++++++++++++++++++++++++++++++++++++-------
 6 files changed, 172 insertions(+), 22 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1a1a249..0c891ea 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -116,6 +116,7 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 		struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
+static int gfar_emerg_reload(struct net_device *dev);
 static irqreturn_t gfar_error(int irq, void *dev_id);
 static irqreturn_t gfar_transmit(int irq, void *dev_id);
 static irqreturn_t gfar_interrupt(int irq, void *dev_id);
@@ -464,6 +465,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_start_xmit = gfar_start_xmit,
 	.ndo_stop = gfar_close,
 	.ndo_change_mtu = gfar_change_mtu,
+	.ndo_emerg_reload = gfar_emerg_reload,
 	.ndo_set_multicast_list = gfar_set_multi,
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
@@ -1918,6 +1920,8 @@ int startup_gfar(struct net_device *ndev)
 	if (err)
 		return err;
 
+	fill_emerg_pool(ndev);
+
 	gfar_init_mac(ndev);
 
 	for (i = 0; i < priv->num_grps; i++) {
@@ -2393,6 +2397,12 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static int gfar_emerg_reload(struct net_device *dev)
+{
+	stop_gfar(dev);
+	startup_gfar(dev);
+}
+
 /* gfar_reset_task gets scheduled when a packet has not been
  * transmitted after a set amount of time.
  * For now, assume that clearing out all the structures, and
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 9d6097b..6280226 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1991,6 +1991,12 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 	}
 }
 
+static void ucc_emerg_reload(struct net_device *dev)
+{
+	ucc_geth_close(dev);
+	ucc_geth_open(dev);
+}
+
 static void ucc_geth_set_multi(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth;
@@ -3499,6 +3505,7 @@ static int ucc_geth_open(struct net_device *dev)
 				  dev->name);
 		goto err;
 	}
+	fill_emerg_pool(dev);
 
 	err = request_irq(ugeth->ug_info->uf_info.irq, ucc_geth_irq_handler,
 			  0, "UCC Geth", dev);
@@ -3707,6 +3714,7 @@ static const struct net_device_ops ucc_geth_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ucc_geth_set_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_emerg_reload	= ucc_emerg_reload,
 	.ndo_set_multicast_list	= ucc_geth_set_multi,
 	.ndo_tx_timeout		= ucc_geth_timeout,
 	.ndo_do_ioctl		= ucc_geth_ioctl,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa7e951..2606156 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -717,6 +717,10 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
+ * void (*ndo_emerg_reload)(struct net_device *dev);
+ *	If the card supports emergency pools then this function will perform a
+ *	lightweight reload to ensure that the card is not lockless accessing
+ *	the emergency pool for recycling purpose.
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -788,6 +792,7 @@ struct net_device_ops {
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
 						    u64 *wwn, int type);
 #endif
+	void			(*ndo_emerg_reload)(struct net_device *dev);
 };
 
 /*
@@ -1092,6 +1097,7 @@ struct net_device {
 	struct sk_buff_head rx_recycle;
 	u32 rx_rec_skbs_max;
 	u32 rx_rec_skb_size;
+	atomic_t emerg_skb_users;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -1138,24 +1144,63 @@ static inline void net_recycle_cleanup(struct net_device *dev)
 	skb_queue_purge(&dev->rx_recycle);
 }
 
+static inline int recycle_possible(struct net_device *dev, struct sk_buff *skb)
+{
+	if (skb_queue_len(&dev->rx_recycle) < dev->rx_rec_skbs_max &&
+			skb_recycle_check(skb, dev->rx_rec_skb_size))
+		return 1;
+	else
+		return 0;
+}
+
 static inline void net_recycle_add(struct net_device *dev, struct sk_buff *skb)
 {
+	int emerg_active;
+
 	if (skb->emerg_dev) {
 		dev_put(skb->emerg_dev);
 		skb->emerg_dev = NULL;
 	}
-	if (skb_queue_len(&dev->rx_recycle) < dev->rx_rec_skbs_max &&
-			skb_recycle_check(skb, dev->rx_rec_skb_size))
-		skb_queue_head(&dev->rx_recycle, skb);
-	else
+
+	emerg_active = atomic_read(&dev->emerg_skb_users);
+
+	if (recycle_possible(dev, skb)) {
+		if (emerg_active)
+			skb_queue_head(&dev->rx_recycle, skb);
+		else
+			__skb_queue_head(&dev->rx_recycle, skb);
+	} else {
 		dev_kfree_skb_any(skb);
+	}
+}
+
+static inline void fill_emerg_pool(struct net_device *dev)
+{
+	struct sk_buff *skb;
+
+	if (atomic_read(&dev->emerg_skb_users) == 0)
+		return;
+
+	do {
+		if (skb_queue_len(&dev->rx_recycle) >= dev->rx_rec_skbs_max)
+			return;
+
+		skb = __netdev_alloc_skb(dev, dev->rx_rec_skb_size, GFP_KERNEL);
+		if (!skb)
+			return;
+
+		net_recycle_add(dev, skb);
+	} while (1);
 }
 
 static inline struct sk_buff *net_recycle_get(struct net_device *dev)
 {
 	struct sk_buff *skb;
 
-	skb = skb_dequeue(&dev->rx_recycle);
+	if (atomic_read(&dev->emerg_skb_users) > 0)
+		skb = skb_dequeue(&dev->rx_recycle);
+	else
+		skb = __skb_dequeue(&dev->rx_recycle);
 	if (skb)
 		return skb;
 	return netdev_alloc_skb(dev, dev->rx_rec_skb_size);
diff --git a/net/core/dev.c b/net/core/dev.c
index db9acd5..5dbe356 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5405,6 +5405,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	netdev_init_queues(dev);
 
 	skb_queue_head_init(&dev->rx_recycle);
+	atomic_set(&dev->emerg_skb_users, 0);
 	INIT_LIST_HEAD(&dev->ethtool_ntuple_list.list);
 	dev->ethtool_ntuple_list.count = 0;
 	INIT_LIST_HEAD(&dev->napi_list);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9e094fc..374d353 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -428,10 +428,25 @@ void __kfree_skb(struct sk_buff *skb)
 	struct net_device *ndev = skb->emerg_dev;
 
 	if (ndev) {
-		net_recycle_add(ndev, skb);
+		int emerg_en;
+		unsigned long flags;
+		int can_recycle;
+
+		skb->emerg_dev = NULL;
+		can_recycle = recycle_possible(ndev, skb);
+		spin_lock_irqsave(&ndev->rx_recycle.lock, flags);
+		emerg_en = atomic_read(&ndev->emerg_skb_users);
+		if (!emerg_en || !can_recycle) {
+			spin_unlock_irqrestore(&ndev->rx_recycle.lock, flags);
+			dev_put(ndev);
+			goto free_it;
+		}
+		__skb_queue_head(&ndev->rx_recycle, skb);
+		spin_unlock_irqrestore(&ndev->rx_recycle.lock, flags);
+		dev_put(ndev);
 		return;
 	}
-
+free_it:
 	skb_release_all(skb);
 	kfree_skbmem(skb);
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 33aa1a5..409d069 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -424,6 +424,10 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 	if (optlen < 0)
 		goto out;
 
+	ret = -EBUSY;
+	if (sk->emerg_en)
+		goto out;
+
 	/* Bind this socket to a particular device like "eth0",
 	 * as specified in the passed interface name. If the
 	 * name is "" or the option length is zero the socket
@@ -497,10 +501,6 @@ static int sock_epool_set_mode(struct sock *sk, int val)
 	struct net *net = sock_net(sk);
 	struct net_device *dev;
 
-	if (!val) {
-		sk->emerg_en = 0;
-		return 0;
-	}
 	if (sk->emerg_en && val)
 		return -EBUSY;
 	if (!capable(CAP_NET_ADMIN))
@@ -510,10 +510,45 @@ static int sock_epool_set_mode(struct sock *sk, int val)
 	dev = dev_get_by_index(net, sk->sk_bound_dev_if);
 	if (!dev)
 		return -ENODEV;
+	if (!val) {
+		ret = 0;
+		if (!sk->emerg_en)
+			goto out;
+		/*
+		 * new skbs for this socket won't be taken from the emergency
+		 * pool anymore.
+		 */
+		sk->emerg_en = 0;
+		smp_rmb();
+		/* get rid of anyone who got into the critical section before
+		 * the flag was changed and is still there
+		 */
+		spin_lock_irq(&dev->rx_recycle.lock);
+		/*
+		 * if we fall down to 0 users, kfree will no longer add
+		 * packets to the pool but simply free them. Also the recycle
+		 * code which takes tx packets and adds them to the pool will
+		 * start working lockless since there are no further user
+		 * except the nic driver.
+		 */
+		atomic_dec(&dev->emerg_skb_users);
+		spin_unlock_irq(&dev->rx_recycle.lock);
+		goto out;
+	}
 	ret = -ENODEV;
+
 	if (!dev->rx_rec_skb_size)
 		goto out;
 
+	if (!dev->netdev_ops->ndo_emerg_reload)
+		goto out;
+
+	rtnl_lock();
+	ret = atomic_add_return(1, &dev->emerg_skb_users);
+	if (ret == 1 && (dev->flags & IFF_UP))
+		dev->netdev_ops->ndo_emerg_reload(dev);
+	rtnl_unlock();
+
 	do {
 		struct sk_buff *skb;
 
@@ -532,6 +567,8 @@ static int sock_epool_set_mode(struct sock *sk, int val)
 
 	if (!ret)
 		sk->emerg_en = 1;
+	else
+		atomic_dec(&dev->emerg_skb_users);
 out:
 	dev_put(dev);
 	return ret;
@@ -1223,6 +1260,8 @@ EXPORT_SYMBOL(sk_alloc);
 static void __sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
+	struct net_device *dev;
+	struct net *net = sock_net(sk);
 
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
@@ -1244,6 +1283,18 @@ static void __sk_free(struct sock *sk)
 	if (sk->sk_peer_cred)
 		put_cred(sk->sk_peer_cred);
 	put_pid(sk->sk_peer_pid);
+
+	if (sk->emerg_en) {
+		dev = dev_get_by_index(net, sk->sk_bound_dev_if);
+		if (dev) {
+			spin_lock_irq(&dev->rx_recycle.lock);
+			atomic_dec(&dev->emerg_skb_users);
+			spin_unlock_irq(&dev->rx_recycle.lock);
+			WARN_ON(atomic_read(&dev->emerg_skb_users) < 0);
+			dev_put(dev);
+		}
+	}
+
 	put_net(sock_net(sk));
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
@@ -1566,6 +1617,7 @@ static struct sk_buff *alloc_emerg_skb(struct sock *sk, unsigned int skb_len)
 {
 	struct net *net = sock_net(sk);
 	struct net_device *dev;
+	unsigned long flags;
 	int err;
 	struct sk_buff *skb;
 
@@ -1580,18 +1632,33 @@ static struct sk_buff *alloc_emerg_skb(struct sock *sk, unsigned int skb_len)
 		dev_put(dev);
 		return ERR_PTR(err);
 	}
-	skb = skb_dequeue(&dev->rx_recycle);
-	if (!skb) {
-		dev_put(dev);
-		err = -ENOBUFS;
-		return ERR_PTR(err);
+
+	spin_lock_irqsave(&dev->rx_recycle.lock, flags);
+	if (sk->emerg_en) {
+		skb = __skb_dequeue(&dev->rx_recycle);
+		spin_unlock_irqrestore(&dev->rx_recycle.lock, flags);
+		if (!skb) {
+			dev_put(dev);
+			err = -ENOBUFS;
+			return ERR_PTR(err);
+		}
+		/* remove earlier skb_reserve() */
+		skb_reserve(skb, - skb_headroom(skb));
+		skb->emerg_dev = dev;
+		/*
+		 * dev will be put once the skb is back from
+		 * its journey.
+		 */
+		return skb;
 	}
 	/*
-	 * dev will be put once the skb is back from
-	 * its journey.
+	 * We got called but the emergency pools are not activated. This might
+	 * happen if the pools got deactivated between checkecing the emerg_en
+	 * flag and taking the lock.
 	 */
-	skb->emerg_dev = dev;
-	return skb;
+	spin_unlock_irqrestore(&dev->rx_recycle.lock, flags);
+	dev_put(dev);
+	return NULL;
 }
 
 /*
@@ -1627,8 +1694,12 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 				if (IS_ERR(skb)) {
 					err = PTR_ERR(skb);
 					goto failure;
-				}
-				break;
+
+				} else if (skb)
+					break;
+				/*
+				 * else skb is null because emerg_en is not set
+				 */
 			}
 			skb = alloc_skb(header_len, gfp_mask);
 			if (skb) {
-- 
1.6.6.1

