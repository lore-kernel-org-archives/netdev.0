From: Jason Wang <jasowang@redhat.com>
Subject: [net-next resend v4 3/7] tuntap: RCUify dereferencing between tun_struct and tun_file
Date: Mon, 29 Oct 2012 14:15:47 +0800
Message-ID: <1351491351-11477-4-git-send-email-jasowang@redhat.com>
References: <1351491351-11477-1-git-send-email-jasowang@redhat.com>
Cc: maxk@qualcomm.com, edumazet@google.com, krkumar2@in.ibm.com,
	ernesto.martin@viasat.com, haixiao@juniper.net,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351491351-11477-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RCU were introduced in this patch to synchronize the dereferences between
tun_struct and tun_file. All tun_{get|put} were replaced with RCU, the
dereference from one to other must be done under rtnl lock or rcu read critical
region.

This is needed for the following patches since the one of the goal of multiqueue
tuntap is to allow adding or removing queues during workload. Without RCU,
control path would hold tx locks when adding or removing queues (which may cause
sme delay) and it's hard to change the number of queues without stopping the net
device. With the help of rcu, there's also no need for tun_file hold an refcnt
to tun_struct.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   95 ++++++++++++++++++++++++++---------------------------
 1 files changed, 47 insertions(+), 48 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e8cedb0..d332cb8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -116,13 +116,16 @@ struct tap_filter {
  * tap_filter were kept in tun_struct since they were used for filtering for the
  * netdevice not for a specific queue (at least I didn't see the reqirement for
  * this).
+ *
+ * RCU usage:
+ * The tun_file and tun_struct are loosely coupled, the pointer from on to the
+ * other can only be read while rcu_read_lock or rtnl_lock is held.
  */
 struct tun_file {
 	struct sock sk;
 	struct socket socket;
 	struct socket_wq wq;
-	atomic_t count;
-	struct tun_struct *tun;
+	struct tun_struct __rcu *tun;
 	struct net *net;
 	struct fasync_struct *fasync;
 	/* only used for fasnyc */
@@ -134,7 +137,7 @@ struct tun_file {
  * file were attached to a persist device.
  */
 struct tun_struct {
-	struct tun_file		*tfile;
+	struct tun_file	__rcu	*tfile;
 	unsigned int 		flags;
 	kuid_t			owner;
 	kgid_t			group;
@@ -180,13 +183,11 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 		if (!err)
 			goto out;
 	}
-	tfile->tun = tun;
+	rcu_assign_pointer(tfile->tun, tun);
 	tfile->socket.sk->sk_sndbuf = tun->sndbuf;
-	tun->tfile = tfile;
+	rcu_assign_pointer(tun->tfile, tfile);
 	netif_carrier_on(tun->dev);
-	dev_hold(tun->dev);
 	sock_hold(&tfile->sk);
-	atomic_inc(&tfile->count);
 
 out:
 	netif_tx_unlock_bh(tun->dev);
@@ -195,34 +196,29 @@ out:
 
 static void __tun_detach(struct tun_struct *tun)
 {
-	struct tun_file *tfile = tun->tfile;
+	struct tun_file *tfile = rcu_dereference_protected(tun->tfile,
+							lockdep_rtnl_is_held());
 	/* Detach from net device */
-	netif_tx_lock_bh(tun->dev);
 	netif_carrier_off(tun->dev);
-	tun->tfile = NULL;
-	tfile->tun = NULL;
-	netif_tx_unlock_bh(tun->dev);
-
-	/* Drop read queue */
-	skb_queue_purge(&tfile->socket.sk->sk_receive_queue);
-
-	/* Drop the extra count on the net device */
-	dev_put(tun->dev);
-}
+	rcu_assign_pointer(tun->tfile, NULL);
+	if (tfile) {
+		rcu_assign_pointer(tfile->tun, NULL);
 
-static void tun_detach(struct tun_struct *tun)
-{
-	rtnl_lock();
-	__tun_detach(tun);
-	rtnl_unlock();
+		synchronize_net();
+		/* Drop read queue */
+		skb_queue_purge(&tfile->socket.sk->sk_receive_queue);
+	}
 }
 
 static struct tun_struct *__tun_get(struct tun_file *tfile)
 {
-	struct tun_struct *tun = NULL;
+	struct tun_struct *tun;
 
-	if (atomic_inc_not_zero(&tfile->count))
-		tun = tfile->tun;
+	rcu_read_lock();
+	tun = rcu_dereference(tfile->tun);
+	if (tun)
+		dev_hold(tun->dev);
+	rcu_read_unlock();
 
 	return tun;
 }
@@ -234,10 +230,7 @@ static struct tun_struct *tun_get(struct file *file)
 
 static void tun_put(struct tun_struct *tun)
 {
-	struct tun_file *tfile = tun->tfile;
-
-	if (atomic_dec_and_test(&tfile->count))
-		tun_detach(tfile->tun);
+	dev_put(tun->dev);
 }
 
 /* TAP filtering */
@@ -358,14 +351,15 @@ static const struct ethtool_ops tun_ethtool_ops;
 static void tun_net_uninit(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
-	struct tun_file *tfile = tun->tfile;
+	struct tun_file *tfile = rcu_dereference_protected(tun->tfile,
+							lockdep_rtnl_is_held());
 
 	/* Inform the methods they need to stop using the dev.
 	 */
 	if (tfile) {
 		wake_up_all(&tfile->wq.wait);
-		if (atomic_dec_and_test(&tfile->count))
-			__tun_detach(tun);
+		__tun_detach(tun);
+		synchronize_net();
 	}
 }
 
@@ -387,14 +381,16 @@ static int tun_net_close(struct net_device *dev)
 static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
-	struct tun_file *tfile = tun->tfile;
-
-	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
+	struct tun_file *tfile;
 
+	rcu_read_lock();
+	tfile = rcu_dereference(tun->tfile);
 	/* Drop packet if interface is not attached */
 	if (!tfile)
 		goto drop;
 
+	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
+
 	/* Drop if the filter does not like it.
 	 * This is a noop if the filter is disabled.
 	 * Filter can be enabled only for the TAP devices. */
@@ -436,11 +432,14 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
 	wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
 				   POLLRDNORM | POLLRDBAND);
+
+	rcu_read_unlock();
 	return NETDEV_TX_OK;
 
 drop:
 	dev->stats.tx_dropped++;
 	kfree_skb(skb);
+	rcu_read_unlock();
 	return NETDEV_TX_OK;
 }
 
@@ -1092,7 +1091,6 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (!tun)
 		return -EBADFD;
-
 	ret = tun_get_user(tun, tfile, m->msg_control, m->msg_iov, total_len,
 			   m->msg_iovlen, m->msg_flags & MSG_DONTWAIT);
 	tun_put(tun);
@@ -1665,8 +1663,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 					    &tun_proto);
 	if (!tfile)
 		return -ENOMEM;
-	atomic_set(&tfile->count, 0);
-	tfile->tun = NULL;
+	rcu_assign_pointer(tfile->tun, NULL);
 	tfile->net = get_net(current->nsproxy->net_ns);
 	tfile->flags = 0;
 
@@ -1694,7 +1691,9 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 	struct tun_struct *tun;
 	struct net *net = tfile->net;
 
-	tun = __tun_get(tfile);
+	rtnl_lock();
+
+	tun = rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held());
 	if (tun) {
 		struct net_device *dev = tun->dev;
 
@@ -1702,18 +1701,20 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 
 		__tun_detach(tun);
 
+		synchronize_net();
+
 		/* If desirable, unregister the netdevice. */
 		if (!(tun->flags & TUN_PERSIST)) {
-			rtnl_lock();
 			if (dev->reg_state == NETREG_REGISTERED)
 				unregister_netdevice(dev);
-			rtnl_unlock();
 		}
 
 		/* drop the reference that netdevice holds */
 		sock_put(&tfile->sk);
 	}
 
+	rtnl_unlock();
+
 	/* drop the reference that file holds */
 	BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED,
 			 &tfile->socket.flags));
@@ -1845,14 +1846,12 @@ static void tun_cleanup(void)
  * holding a reference to the file for as long as the socket is in use. */
 struct socket *tun_get_socket(struct file *file)
 {
-	struct tun_struct *tun;
-	struct tun_file *tfile = file->private_data;
+	struct tun_file *tfile;
 	if (file->f_op != &tun_fops)
 		return ERR_PTR(-EINVAL);
-	tun = tun_get(file);
-	if (!tun)
+	tfile = file->private_data;
+	if (!tfile)
 		return ERR_PTR(-EBADFD);
-	tun_put(tun);
 	return &tfile->socket;
 }
 EXPORT_SYMBOL_GPL(tun_get_socket);
-- 
1.7.1
