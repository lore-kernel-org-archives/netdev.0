From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V2 PATCH 4/5] tuntap: multiqueue support
Date: Sat, 17 Sep 2011 14:02:49 +0800
Message-ID: <20110917060249.32666.21024.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
References: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	mirq-linux@rere.qmqm.pl, joe@perches.com, shemminger@vyatta.com
To: krkumar2@in.ibm.com, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

This patch adds multiqueue support for tap device by allowing multiple
sockets to be attached to a tap device. Then we could parallize packets
transmission/reception by put them into different socket.

Following steps were used when choose tx queues:
1 For the packets comes from multiqueue nics, we would just choose the
tx queue based on the which physical queue the packets comes from.
2 Otherwise we try to use rxhash to choose the queue.
3 If all above fails, we always use the first queue.

In order to let the tx path lockless, like macvtap, netif_tx_loch_bh()
isr eplaced by RCU and NETIF_F_LLTX to synchronize between hot path
and systemcall.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |  358 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 223 insertions(+), 135 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index dc768e0..ec29f85 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -108,6 +108,8 @@ struct tap_filter {
 	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
 };
 
+#define MAX_TAP_QUEUES (NR_CPUS < 16 ? NR_CPUS : 16)
+
 struct tun_file {
 	struct sock sk;
 	struct socket socket;
@@ -115,16 +117,18 @@ struct tun_file {
 	int vnet_hdr_sz;
 	struct tap_filter txflt;
 	atomic_t count;
-	struct tun_struct *tun;
+	struct tun_struct __rcu *tun;
 	struct net *net;
 	struct fasync_struct *fasync;
 	unsigned int flags;
+	u16 queue_index;
 };
 
 struct tun_sock;
 
 struct tun_struct {
-	struct tun_file		*tfile;
+	struct tun_file		*tfiles[MAX_TAP_QUEUES];
+	unsigned int            numqueues;
 	unsigned int 		flags;
 	uid_t			owner;
 	gid_t			group;
@@ -139,80 +143,160 @@ struct tun_struct {
 #endif
 };
 
-static int tun_attach(struct tun_struct *tun, struct file *file)
+static DEFINE_SPINLOCK(tun_lock);
+
+/*
+ * tun_get_queue(): calculate the queue index
+ *     - if skbs comes from mq nics, we can just borrow
+ *     - if not, calculate from the hash
+ */
+static struct tun_file *tun_get_queue(struct net_device *dev,
+                                     struct sk_buff *skb)
 {
-	struct tun_file *tfile = file->private_data;
-	int err;
+	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_file *tfile = NULL;
+	int numqueues = tun->numqueues;
+	__u32 rxq;
 
-	ASSERT_RTNL();
+	BUG_ON(!rcu_read_lock_held());
 
-	netif_tx_lock_bh(tun->dev);
+	if (!numqueues)
+		goto out;
 
-	err = -EINVAL;
-	if (tfile->tun)
+	if (numqueues == 1) {
+		tfile = rcu_dereference(tun->tfiles[0]);
 		goto out;
+	}
 
-	err = -EBUSY;
-	if (tun->tfile)
+	if (likely(skb_rx_queue_recorded(skb))) {
+		rxq = skb_get_rx_queue(skb);
+
+		while (unlikely(rxq >= numqueues))
+			rxq -= numqueues;
+
+		tfile = rcu_dereference(tun->tfiles[rxq]);
 		goto out;
+	}
 
-	err = 0;
-	tfile->tun = tun;
-	tun->tfile = tfile;
-	netif_carrier_on(tun->dev);
-	dev_hold(tun->dev);
-	sock_hold(&tfile->sk);
-	atomic_inc(&tfile->count);
+	/* Check if we can use flow to select a queue */
+	rxq = skb_get_rxhash(skb);
+	if (rxq) {
+		u32 idx = ((u64)rxq * numqueues) >> 32;
+		tfile = rcu_dereference(tun->tfiles[idx]);
+		goto out;
+	}
 
+	tfile = rcu_dereference(tun->tfiles[0]);
 out:
-	netif_tx_unlock_bh(tun->dev);
-	return err;
+	return tfile;
 }
 
-static void __tun_detach(struct tun_struct *tun)
+static int tun_detach(struct tun_file *tfile, bool clean)
 {
-	struct tun_file *tfile = tun->tfile;
-	/* Detach from net device */
-	netif_tx_lock_bh(tun->dev);
-	netif_carrier_off(tun->dev);
-	tun->tfile = NULL;
-	netif_tx_unlock_bh(tun->dev);
-
-	/* Drop read queue */
-	skb_queue_purge(&tfile->socket.sk->sk_receive_queue);
-
-	/* Drop the extra count on the net device */
-	dev_put(tun->dev);
-}
+	struct tun_struct *tun;
+	struct net_device *dev = NULL;
+	bool destroy = false;
 
-static void tun_detach(struct tun_struct *tun)
-{
-	rtnl_lock();
-	__tun_detach(tun);
-	rtnl_unlock();
-}
+	spin_lock(&tun_lock);
 
-static struct tun_struct *__tun_get(struct tun_file *tfile)
-{
-	struct tun_struct *tun = NULL;
+	tun = rcu_dereference_protected(tfile->tun,
+					lockdep_is_held(&tun_lock));
+	if (tun) {
+		u16 index = tfile->queue_index;
+		BUG_ON(index > tun->numqueues);
+		BUG_ON(!tun->tfiles[tun->numqueues - 1]);
+		dev = tun->dev;
+
+		rcu_assign_pointer(tun->tfiles[index],
+				   tun->tfiles[tun->numqueues - 1]);
+		tun->tfiles[index]->queue_index = index;
+		rcu_assign_pointer(tfile->tun, NULL);
+		--tun->numqueues;
+		sock_put(&tfile->sk);
 
-	if (atomic_inc_not_zero(&tfile->count))
-		tun = tfile->tun;
+		if (tun->numqueues == 0 && !(tun->flags & TUN_PERSIST))
+			destroy = true;
+	}
+
+	spin_unlock(&tun_lock);
+
+	synchronize_rcu();
+	if (clean)
+		sock_put(&tfile->sk);
 
-	return tun;
+	if (destroy) {
+		rtnl_lock();
+		if (dev->reg_state == NETREG_REGISTERED)
+			unregister_netdevice(dev);
+		rtnl_unlock();
+	}
+
+	return 0;
 }
 
-static struct tun_struct *tun_get(struct file *file)
+static void tun_detach_all(struct net_device *dev)
 {
-	return __tun_get(file->private_data);
+	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_file *tfile, *tfile_list[MAX_TAP_QUEUES];
+	int i, j = 0;
+
+	spin_lock(&tun_lock);
+
+	for (i = 0; i < MAX_TAP_QUEUES && tun->numqueues; i++) {
+		tfile = rcu_dereference_protected(tun->tfiles[i],
+						lockdep_is_held(&tun_lock));
+		BUG_ON(!tfile);
+		wake_up_all(&tfile->wq.wait);
+		tfile_list[j++] = tfile;
+		rcu_assign_pointer(tfile->tun, NULL);
+		--tun->numqueues;
+	}
+	BUG_ON(tun->numqueues != 0);
+	spin_unlock(&tun_lock);
+
+	synchronize_rcu();
+	for(--j; j >= 0; j--)
+		sock_put(&tfile_list[j]->sk);
 }
 
-static void tun_put(struct tun_struct *tun)
+static int tun_attach(struct tun_struct *tun, struct file *file)
 {
-	struct tun_file *tfile = tun->tfile;
+	struct tun_file *tfile = file->private_data;
+	int err;
+
+	ASSERT_RTNL();
+
+	spin_lock(&tun_lock);
+
+	err = -EINVAL;
+	if (rcu_dereference_protected(tfile->tun, lockdep_is_held(&tun_lock)))
+		goto out;
+
+	err = -EBUSY;
+	if (!(tun->flags & TUN_TAP_MQ) &&
+		rcu_dereference_protected(tun->tfiles[0],
+					lockdep_is_held(&tun_lock))) {
+		/* Multiqueue is only for TAP */
+		goto out;
+	}
+
+	if (tun->numqueues == MAX_TAP_QUEUES)
+		goto out;
+
+	err = 0;
+	tfile->queue_index = tun->numqueues;
+	rcu_assign_pointer(tfile->tun, tun);
+	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
+	sock_hold(&tfile->sk);
+	tun->numqueues++;
+
+	if (tun->numqueues == 1)
+		netif_carrier_on(tun->dev);
 
-	if (atomic_dec_and_test(&tfile->count))
-		tun_detach(tfile->tun);
+	/* device is allowed to go away first, so no need to hold extra refcnt.	 */
+out:
+	spin_unlock(&tun_lock);
+	return err;
 }
 
 /* TAP filtering */
@@ -332,16 +416,7 @@ static const struct ethtool_ops tun_ethtool_ops;
 /* Net device detach from fd. */
 static void tun_net_uninit(struct net_device *dev)
 {
-	struct tun_struct *tun = netdev_priv(dev);
-	struct tun_file *tfile = tun->tfile;
-
-	/* Inform the methods they need to stop using the dev.
-	 */
-	if (tfile) {
-		wake_up_all(&tfile->wq.wait);
-		if (atomic_dec_and_test(&tfile->count))
-			__tun_detach(tun);
-	}
+	tun_detach_all(dev);
 }
 
 /* Net device open. */
@@ -361,10 +436,10 @@ static int tun_net_close(struct net_device *dev)
 /* Net device start xmit */
 static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct tun_struct *tun = netdev_priv(dev);
-	struct tun_file *tfile = tun->tfile;
+	struct tun_file *tfile = NULL;
 
-	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
+	rcu_read_lock();
+	tfile = tun_get_queue(dev, skb);
 
 	/* Drop packet if interface is not attached */
 	if (!tfile)
@@ -381,7 +456,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 
 	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
-		if (!(tun->flags & TUN_ONE_QUEUE)) {
+		if (!(tfile->flags & TUN_ONE_QUEUE) && !(tfile->flags && TUN_TAP_MQ)) {
 			/* Normal queueing mode. */
 			/* Packet scheduler handles dropping of further packets. */
 			netif_stop_queue(dev);
@@ -390,7 +465,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 			 * error is more appropriate. */
 			dev->stats.tx_fifo_errors++;
 		} else {
-			/* Single queue mode.
+			/* Single queue mode or multi queue mode.
 			 * Driver handles dropping of all packets itself. */
 			goto drop;
 		}
@@ -408,9 +483,11 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
 	wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
 				   POLLRDNORM | POLLRDBAND);
+	rcu_read_unlock();
 	return NETDEV_TX_OK;
 
 drop:
+	rcu_read_unlock();
 	dev->stats.tx_dropped++;
 	kfree_skb(skb);
 	return NETDEV_TX_OK;
@@ -526,16 +603,22 @@ static void tun_net_init(struct net_device *dev)
 static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 {
 	struct tun_file *tfile = file->private_data;
-	struct tun_struct *tun = __tun_get(tfile);
+	struct tun_struct *tun = NULL;
 	struct sock *sk;
 	unsigned int mask = 0;
 
-	if (!tun)
+	if (!tfile)
 		return POLLERR;
 
-	sk = tfile->socket.sk;
+	rcu_read_lock();
+	tun = rcu_dereference(tfile->tun);
+	if (!tun) {
+		rcu_read_unlock();
+		return POLLERR;
+	}
+	rcu_read_unlock();
 
-	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
+	sk = &tfile->sk;
 
 	poll_wait(file, &tfile->wq.wait, wait);
 
@@ -547,10 +630,12 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 	     sock_writeable(sk)))
 		mask |= POLLOUT | POLLWRNORM;
 
-	if (tun->dev->reg_state != NETREG_REGISTERED)
+	rcu_read_lock();
+	tun = rcu_dereference(tfile->tun);
+	if (!tun || tun->dev->reg_state != NETREG_REGISTERED)
 		mask = POLLERR;
+	rcu_read_unlock();
 
-	tun_put(tun);
 	return mask;
 }
 
@@ -706,11 +791,12 @@ static ssize_t tun_get_user(struct tun_file *tfile,
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
-	tun = __tun_get(tfile);
+	rcu_read_lock();
+	tun = rcu_dereference(tfile->tun);
 	if (!tun) {
+		rcu_read_unlock();
 		return -EBADFD;
 	}
-
 	switch (tfile->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
 		skb->dev = tun->dev;
@@ -719,27 +805,29 @@ static ssize_t tun_get_user(struct tun_file *tfile,
 		skb->protocol = eth_type_trans(skb, tun->dev);
 		break;
 	}
-
-	netif_rx_ni(skb);
 	tun->dev->stats.rx_packets++;
 	tun->dev->stats.rx_bytes += len;
-	tun_put(tun);
+	rcu_read_unlock();
+
+	netif_rx_ni(skb);
+
 	return count;
 
 err_free:
 	count = -EINVAL;
 	kfree_skb(skb);
 err:
-	tun = __tun_get(tfile);
+	rcu_read_lock();
+	tun = rcu_dereference(tfile->tun);
 	if (!tun) {
+		rcu_read_unlock();
 		return -EBADFD;
 	}
-
 	if (drop)
 		tun->dev->stats.rx_dropped++;
 	if (error)
 		tun->dev->stats.rx_frame_errors++;
-	tun_put(tun);
+	rcu_read_unlock();
 	return count;
 }
 
@@ -832,12 +920,13 @@ static ssize_t tun_put_user(struct tun_file *tfile,
 	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
 	total += skb->len;
 
-	tun = __tun_get(tfile);
+	rcu_read_lock();
+	tun = rcu_dereference(tfile->tun);
 	if (tun) {
 		tun->dev->stats.tx_packets++;
 		tun->dev->stats.tx_bytes += len;
-		tun_put(tun);
 	}
+	rcu_read_unlock();
 
 	return total;
 }
@@ -867,28 +956,31 @@ static ssize_t tun_do_read(struct tun_file *tfile,
 				break;
 			}
 
-			tun = __tun_get(tfile);
+			rcu_read_lock();
+			tun = rcu_dereference(tfile->tun);
 			if (!tun) {
-				ret = -EIO;
+				ret = -EBADFD;
+				rcu_read_unlock();
 				break;
 			}
 			if (tun->dev->reg_state != NETREG_REGISTERED) {
 				ret = -EIO;
-				tun_put(tun);
+				rcu_read_unlock();
 				break;
 			}
-			tun_put(tun);
+			rcu_read_unlock();
 
 			/* Nothing to read, let's sleep */
 			schedule();
 			continue;
 		}
 
-		tun = __tun_get(tfile);
+		rcu_read_lock();
+		tun = rcu_dereference(tfile->tun);
 		if (tun) {
 			netif_wake_queue(tun->dev);
-			tun_put(tun);
 		}
+		rcu_read_unlock();
 
 		ret = tun_put_user(tfile, skb, iv, len);
 		kfree_skb(skb);
@@ -1028,6 +1120,9 @@ static int tun_flags(struct tun_struct *tun)
 	if (tun->flags & TUN_VNET_HDR)
 		flags |= IFF_VNET_HDR;
 
+	if (tun->flags & TUN_TAP_MQ)
+		flags |= IFF_MULTI_QUEUE;
+
 	return flags;
 }
 
@@ -1107,6 +1202,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			/* TAP device */
 			flags |= TUN_TAP_DEV;
 			name = "tap%d";
+			if (ifr->ifr_flags & IFF_MULTI_QUEUE) {
+				flags |= TUN_TAP_MQ;
+				name = "mqtap%d";
+			}
 		} else
 			return -EINVAL;
 
@@ -1132,6 +1231,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
 			TUN_USER_FEATURES;
 		dev->features = dev->hw_features;
+		if (ifr->ifr_flags & IFF_MULTI_QUEUE)
+			dev->features |= NETIF_F_LLTX;
 
 		err = register_netdevice(tun->dev);
 		if (err < 0)
@@ -1164,6 +1265,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	else
 		tun->flags &= ~TUN_VNET_HDR;
 
+	if (ifr->ifr_flags & IFF_MULTI_QUEUE)
+		tun->flags |= TUN_TAP_MQ;
+	else
+		tun->flags &= ~TUN_TAP_MQ;
+
 	/* Cache flags from tun device */
 	tfile->flags = tun->flags;
 	/* Make sure persistent devices do not get stuck in
@@ -1254,38 +1360,39 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 				(unsigned int __user*)argp);
 	}
 
-	rtnl_lock();
-
-	tun = __tun_get(tfile);
-	if (cmd == TUNSETIFF && !tun) {
+	ret = 0;
+	if (cmd == TUNSETIFF) {
+		rtnl_lock();
 		ifr.ifr_name[IFNAMSIZ-1] = '\0';
-
 		ret = tun_set_iff(tfile->net, file, &ifr);
-
+		rtnl_unlock();
 		if (ret)
-			goto unlock;
-
+			return ret;
 		if (copy_to_user(argp, &ifr, ifreq_len))
-			ret = -EFAULT;
-		goto unlock;
+			return -EFAULT;
+		return ret;
 	}
 
+	rtnl_lock();
+
+	rcu_read_lock();
+
 	ret = -EBADFD;
+	tun = rcu_dereference(tfile->tun);
 	if (!tun)
 		goto unlock;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_ioctl cmd %d\n", cmd);
 
-	ret = 0;
-	switch (cmd) {
+	switch(cmd) {
 	case TUNGETIFF:
 		ret = tun_get_iff(current->nsproxy->net_ns, tun, &ifr);
+		rcu_read_unlock();
 		if (ret)
-			break;
+			goto out;
 
 		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
-		break;
+		goto out;
 
 	case TUNSETNOCSUM:
 		/* Disable/Enable checksum */
@@ -1347,9 +1454,10 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		/* Get hw address */
 		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev->dev_addr, ETH_ALEN);
 		ifr.ifr_hwaddr.sa_family = tun->dev->type;
+		rcu_read_unlock();
 		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
-		break;
+		goto out;
 
 	case SIOCSIFHWADDR:
 		/* Set hw address */
@@ -1365,9 +1473,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	}
 
 unlock:
+	rcu_read_unlock();
+out:
 	rtnl_unlock();
-	if (tun)
-		tun_put(tun);
 	return ret;
 }
 
@@ -1539,31 +1647,8 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 static int tun_chr_close(struct inode *inode, struct file *file)
 {
 	struct tun_file *tfile = file->private_data;
-	struct tun_struct *tun;
-
-	tun = __tun_get(tfile);
-	if (tun) {
-		struct net_device *dev = tun->dev;
-
-		tun_debug(KERN_INFO, tun, "tun_chr_close\n");
-
-		__tun_detach(tun);
-
-		/* If desirable, unregister the netdevice. */
-		if (!(tun->flags & TUN_PERSIST)) {
-			rtnl_lock();
-			if (dev->reg_state == NETREG_REGISTERED)
-				unregister_netdevice(dev);
-			rtnl_unlock();
-		}
-
-		/* drop the reference that netdevice holds */
-		sock_put(&tfile->sk);
-
-	}
 
-	/* drop the reference that file holds */
-	sock_put(&tfile->sk);
+	tun_detach(tfile, true);
 
 	return 0;
 }
@@ -1691,14 +1776,17 @@ static void tun_cleanup(void)
  * holding a reference to the file for as long as the socket is in use. */
 struct socket *tun_get_socket(struct file *file)
 {
-	struct tun_struct *tun;
+	struct tun_struct *tun = NULL;
 	struct tun_file *tfile = file->private_data;
 	if (file->f_op != &tun_fops)
 		return ERR_PTR(-EINVAL);
-	tun = tun_get(file);
-	if (!tun)
+	rcu_read_lock();
+	tun = rcu_dereference(tfile->tun);
+	if (!tun) {
+		rcu_read_unlock();
 		return ERR_PTR(-EBADFD);
-	tun_put(tun);
+	}
+	rcu_read_unlock();
 	return &tfile->socket;
 }
 EXPORT_SYMBOL_GPL(tun_get_socket);
