From: Jason Wang <jasowang@redhat.com>
Subject: [net-next v4 2/7] tuntap: move socket to tun_file
Date: Mon, 29 Oct 2012 13:35:59 +0800
Message-ID: <1351488964-11109-4-git-send-email-jasowang@redhat.com>
References: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
Cc: maxk@qualcomm.com, haixiao@juniper.net, ernesto.martin@viasat.com,
	krkumar2@in.ibm.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
In-Reply-To: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current tuntap makes use of the socket receive queue as its tx queue. To
implement multiple tx queues for tuntap and enable the ability of adding and
removing queues during workload, the first step is to move the socket related
structures to tun_file. Then we could let multiple fds/sockets to be attached to
the tuntap.

This patch removes tun_sock and moves socket related structures from tun_sock or
tun_struct to tun_file. Two exceptions are tap_filter and sock_fprog, they are
still kept in tun_structure since they are used to filter packets for the net
device instead of per transmit queue (at least I see no requirements for
them). After those changes, socket were created and destroyed during file open
and close (instead of device creation and destroy), the socket structures could
be dereferenced from tun_file instead of the file of tun_struct structure
itself.

For persisent device, since we purge during datching and wouldn't queue any
packets when no interface were attached, there's no behaviod changes before and
after this patch, so the changes were transparent to the userspace. To keep the
attributes such as sndbuf, socket filter and vnet header, those would be
re-initialize after a new interface were attached to an persist device.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |  266 +++++++++++++++++++++++++++++------------------------
 1 files changed, 145 insertions(+), 121 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ef13cf0..e8cedb0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -110,14 +110,29 @@ struct tap_filter {
 	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
 };
 
+/* A tun_file connects an open character device to a tuntap netdevice. It
+ * also contains all socket related strctures (except sock_fprog and tap_filter)
+ * to serve as one transmit queue for tuntap device. The sock_fprog and
+ * tap_filter were kept in tun_struct since they were used for filtering for the
+ * netdevice not for a specific queue (at least I didn't see the reqirement for
+ * this).
+ */
 struct tun_file {
+	struct sock sk;
+	struct socket socket;
+	struct socket_wq wq;
 	atomic_t count;
 	struct tun_struct *tun;
 	struct net *net;
+	struct fasync_struct *fasync;
+	/* only used for fasnyc */
+	unsigned int flags;
 };
 
-struct tun_sock;
-
+/* Since the socket were moved to tun_file, to preserve the behavior of persist
+ * device, socket fileter, sndbuf and vnet header size were restore when the
+ * file were attached to a persist device.
+ */
 struct tun_struct {
 	struct tun_file		*tfile;
 	unsigned int 		flags;
@@ -128,29 +143,18 @@ struct tun_struct {
 	netdev_features_t	set_features;
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
 			  NETIF_F_TSO6|NETIF_F_UFO)
-	struct fasync_struct	*fasync;
-
-	struct tap_filter       txflt;
-	struct socket		socket;
-	struct socket_wq	wq;
 
 	int			vnet_hdr_sz;
-
+	int			sndbuf;
+	struct tap_filter	txflt;
+	struct sock_fprog	fprog;
+	/* protected by rtnl lock */
+	bool			filter_attached;
 #ifdef TUN_DEBUG
 	int debug;
 #endif
 };
 
-struct tun_sock {
-	struct sock		sk;
-	struct tun_struct	*tun;
-};
-
-static inline struct tun_sock *tun_sk(struct sock *sk)
-{
-	return container_of(sk, struct tun_sock, sk);
-}
-
 static int tun_attach(struct tun_struct *tun, struct file *file)
 {
 	struct tun_file *tfile = file->private_data;
@@ -169,12 +173,19 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 		goto out;
 
 	err = 0;
+
+	/* Re-attach filter when attaching to a persist device */
+	if (tun->filter_attached == true) {
+		err = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		if (!err)
+			goto out;
+	}
 	tfile->tun = tun;
+	tfile->socket.sk->sk_sndbuf = tun->sndbuf;
 	tun->tfile = tfile;
-	tun->socket.file = file;
 	netif_carrier_on(tun->dev);
 	dev_hold(tun->dev);
-	sock_hold(tun->socket.sk);
+	sock_hold(&tfile->sk);
 	atomic_inc(&tfile->count);
 
 out:
@@ -184,14 +195,16 @@ out:
 
 static void __tun_detach(struct tun_struct *tun)
 {
+	struct tun_file *tfile = tun->tfile;
 	/* Detach from net device */
 	netif_tx_lock_bh(tun->dev);
 	netif_carrier_off(tun->dev);
 	tun->tfile = NULL;
+	tfile->tun = NULL;
 	netif_tx_unlock_bh(tun->dev);
 
 	/* Drop read queue */
-	skb_queue_purge(&tun->socket.sk->sk_receive_queue);
+	skb_queue_purge(&tfile->socket.sk->sk_receive_queue);
 
 	/* Drop the extra count on the net device */
 	dev_put(tun->dev);
@@ -350,21 +363,12 @@ static void tun_net_uninit(struct net_device *dev)
 	/* Inform the methods they need to stop using the dev.
 	 */
 	if (tfile) {
-		wake_up_all(&tun->wq.wait);
+		wake_up_all(&tfile->wq.wait);
 		if (atomic_dec_and_test(&tfile->count))
 			__tun_detach(tun);
 	}
 }
 
-static void tun_free_netdev(struct net_device *dev)
-{
-	struct tun_struct *tun = netdev_priv(dev);
-
-	BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED, &tun->socket.flags));
-
-	sk_release_kernel(tun->socket.sk);
-}
-
 /* Net device open. */
 static int tun_net_open(struct net_device *dev)
 {
@@ -383,11 +387,12 @@ static int tun_net_close(struct net_device *dev)
 static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_file *tfile = tun->tfile;
 
 	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
 
 	/* Drop packet if interface is not attached */
-	if (!tun->tfile)
+	if (!tfile)
 		goto drop;
 
 	/* Drop if the filter does not like it.
@@ -396,11 +401,12 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!check_filter(&tun->txflt, skb))
 		goto drop;
 
-	if (tun->socket.sk->sk_filter &&
-	    sk_filter(tun->socket.sk, skb))
+	if (tfile->socket.sk->sk_filter &&
+	    sk_filter(tfile->socket.sk, skb))
 		goto drop;
 
-	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
+	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
+	    >= dev->tx_queue_len) {
 		if (!(tun->flags & TUN_ONE_QUEUE)) {
 			/* Normal queueing mode. */
 			/* Packet scheduler handles dropping of further packets. */
@@ -423,12 +429,12 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_orphan(skb);
 
 	/* Enqueue packet */
-	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
+	skb_queue_tail(&tfile->socket.sk->sk_receive_queue, skb);
 
 	/* Notify and wake up reader process */
-	if (tun->flags & TUN_FASYNC)
-		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
-	wake_up_interruptible_poll(&tun->wq.wait, POLLIN |
+	if (tfile->flags & TUN_FASYNC)
+		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
+	wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
 				   POLLRDNORM | POLLRDBAND);
 	return NETDEV_TX_OK;
 
@@ -556,11 +562,11 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 	if (!tun)
 		return POLLERR;
 
-	sk = tun->socket.sk;
+	sk = tfile->socket.sk;
 
 	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
 
-	poll_wait(file, &tun->wq.wait, wait);
+	poll_wait(file, &tfile->wq.wait, wait);
 
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
@@ -579,11 +585,11 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 
 /* prepad is the amount to reserve at front.  len is length after that.
  * linear is a hint as to how much to copy (usually headers). */
-static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
+static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
 				     size_t prepad, size_t len,
 				     size_t linear, int noblock)
 {
-	struct sock *sk = tun->socket.sk;
+	struct sock *sk = tfile->socket.sk;
 	struct sk_buff *skb;
 	int err;
 
@@ -685,9 +691,9 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 }
 
 /* Get packet from user space buffer */
-static ssize_t tun_get_user(struct tun_struct *tun, void *msg_control,
-			    const struct iovec *iv, size_t total_len,
-			    size_t count, int noblock)
+static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
+			    void *msg_control, const struct iovec *iv,
+			    size_t total_len, size_t count, int noblock)
 {
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
@@ -757,7 +763,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, void *msg_control,
 	} else
 		copylen = len;
 
-	skb = tun_alloc_skb(tun, align, copylen, gso.hdr_len, noblock);
+	skb = tun_alloc_skb(tfile, align, copylen, gso.hdr_len, noblock);
 	if (IS_ERR(skb)) {
 		if (PTR_ERR(skb) != -EAGAIN)
 			tun->dev->stats.rx_dropped++;
@@ -862,6 +868,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 {
 	struct file *file = iocb->ki_filp;
 	struct tun_struct *tun = tun_get(file);
+	struct tun_file *tfile = file->private_data;
 	ssize_t result;
 
 	if (!tun)
@@ -869,8 +876,8 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 
 	tun_debug(KERN_INFO, tun, "tun_chr_write %ld\n", count);
 
-	result = tun_get_user(tun, NULL, iv, iov_length(iv, count), count,
-			      file->f_flags & O_NONBLOCK);
+	result = tun_get_user(tun, tfile, NULL, iv, iov_length(iv, count),
+			      count, file->f_flags & O_NONBLOCK);
 
 	tun_put(tun);
 	return result;
@@ -878,6 +885,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 
 /* Put packet to the user space buffer */
 static ssize_t tun_put_user(struct tun_struct *tun,
+			    struct tun_file *tfile,
 			    struct sk_buff *skb,
 			    const struct iovec *iv, int len)
 {
@@ -957,7 +965,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	return total;
 }
 
-static ssize_t tun_do_read(struct tun_struct *tun,
+static ssize_t tun_do_read(struct tun_struct *tun,struct tun_file *tfile,
 			   struct kiocb *iocb, const struct iovec *iv,
 			   ssize_t len, int noblock)
 {
@@ -968,12 +976,12 @@ static ssize_t tun_do_read(struct tun_struct *tun,
 	tun_debug(KERN_INFO, tun, "tun_chr_read\n");
 
 	if (unlikely(!noblock))
-		add_wait_queue(&tun->wq.wait, &wait);
+		add_wait_queue(&tfile->wq.wait, &wait);
 	while (len) {
 		current->state = TASK_INTERRUPTIBLE;
 
 		/* Read frames from the queue */
-		if (!(skb=skb_dequeue(&tun->socket.sk->sk_receive_queue))) {
+		if (!(skb = skb_dequeue(&tfile->socket.sk->sk_receive_queue))) {
 			if (noblock) {
 				ret = -EAGAIN;
 				break;
@@ -993,14 +1001,14 @@ static ssize_t tun_do_read(struct tun_struct *tun,
 		}
 		netif_wake_queue(tun->dev);
 
-		ret = tun_put_user(tun, skb, iv, len);
+		ret = tun_put_user(tun, tfile, skb, iv, len);
 		kfree_skb(skb);
 		break;
 	}
 
 	current->state = TASK_RUNNING;
 	if (unlikely(!noblock))
-		remove_wait_queue(&tun->wq.wait, &wait);
+		remove_wait_queue(&tfile->wq.wait, &wait);
 
 	return ret;
 }
@@ -1021,7 +1029,8 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	ret = tun_do_read(tun, iocb, iv, len, file->f_flags & O_NONBLOCK);
+	ret = tun_do_read(tun, tfile, iocb, iv, len,
+			  file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
 out:
 	tun_put(tun);
@@ -1036,7 +1045,7 @@ static void tun_setup(struct net_device *dev)
 	tun->group = INVALID_GID;
 
 	dev->ethtool_ops = &tun_ethtool_ops;
-	dev->destructor = tun_free_netdev;
+	dev->destructor = free_netdev;
 }
 
 /* Trivial set of netlink ops to allow deleting tun or tap
@@ -1056,7 +1065,7 @@ static struct rtnl_link_ops tun_link_ops __read_mostly = {
 
 static void tun_sock_write_space(struct sock *sk)
 {
-	struct tun_struct *tun;
+	struct tun_file *tfile;
 	wait_queue_head_t *wqueue;
 
 	if (!sock_writeable(sk))
@@ -1070,37 +1079,47 @@ static void tun_sock_write_space(struct sock *sk)
 		wake_up_interruptible_sync_poll(wqueue, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
 
-	tun = tun_sk(sk)->tun;
-	kill_fasync(&tun->fasync, SIGIO, POLL_OUT);
-}
-
-static void tun_sock_destruct(struct sock *sk)
-{
-	free_netdev(tun_sk(sk)->tun->dev);
+	tfile = container_of(sk, struct tun_file, sk);
+	kill_fasync(&tfile->fasync, SIGIO, POLL_OUT);
 }
 
 static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
-	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
-	return tun_get_user(tun, m->msg_control, m->msg_iov, total_len,
-			    m->msg_iovlen, m->msg_flags & MSG_DONTWAIT);
+	int ret;
+	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
+	struct tun_struct *tun = __tun_get(tfile);
+
+	if (!tun)
+		return -EBADFD;
+
+	ret = tun_get_user(tun, tfile, m->msg_control, m->msg_iov, total_len,
+			   m->msg_iovlen, m->msg_flags & MSG_DONTWAIT);
+	tun_put(tun);
+	return ret;
 }
 
+
 static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len,
 		       int flags)
 {
-	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
+	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
+	struct tun_struct *tun = __tun_get(tfile);
 	int ret;
+
+	if (!tun)
+		return -EBADFD;
+
 	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
 		return -EINVAL;
-	ret = tun_do_read(tun, iocb, m->msg_iov, total_len,
+	ret = tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
 			  flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
 	}
+	tun_put(tun);
 	return ret;
 }
 
@@ -1121,7 +1140,7 @@ static const struct proto_ops tun_socket_ops = {
 static struct proto tun_proto = {
 	.name		= "tun",
 	.owner		= THIS_MODULE,
-	.obj_size	= sizeof(struct tun_sock),
+	.obj_size	= sizeof(struct tun_file),
 };
 
 static int tun_flags(struct tun_struct *tun)
@@ -1178,8 +1197,8 @@ static DEVICE_ATTR(group, 0444, tun_show_group, NULL);
 
 static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 {
-	struct sock *sk;
 	struct tun_struct *tun;
+	struct tun_file *tfile = file->private_data;
 	struct net_device *dev;
 	int err;
 
@@ -1200,7 +1219,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		     (gid_valid(tun->group) && !in_egroup_p(tun->group))) &&
 		    !capable(CAP_NET_ADMIN))
 			return -EPERM;
-		err = security_tun_dev_attach(tun->socket.sk);
+		err = security_tun_dev_attach(tfile->socket.sk);
 		if (err < 0)
 			return err;
 
@@ -1246,25 +1265,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun->flags = flags;
 		tun->txflt.count = 0;
 		tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
-		set_bit(SOCK_EXTERNALLY_ALLOCATED, &tun->socket.flags);
-
-		err = -ENOMEM;
-		sk = sk_alloc(&init_net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
-		if (!sk)
-			goto err_free_dev;
 
-		sk_change_net(sk, net);
-		tun->socket.wq = &tun->wq;
-		init_waitqueue_head(&tun->wq.wait);
-		tun->socket.ops = &tun_socket_ops;
-		sock_init_data(&tun->socket, sk);
-		sk->sk_write_space = tun_sock_write_space;
-		sk->sk_sndbuf = INT_MAX;
-		sock_set_flag(sk, SOCK_ZEROCOPY);
+		tun->filter_attached = false;
+		tun->sndbuf = tfile->socket.sk->sk_sndbuf;
 
-		tun_sk(sk)->tun = tun;
-
-		security_tun_dev_post_create(sk);
+		security_tun_dev_post_create(&tfile->sk);
 
 		tun_net_init(dev);
 
@@ -1274,15 +1279,13 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		err = register_netdevice(tun->dev);
 		if (err < 0)
-			goto err_free_sk;
+			goto err_free_dev;
 
 		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_group))
 			pr_err("Failed to create tun sysfs files\n");
 
-		sk->sk_destruct = tun_sock_destruct;
-
 		err = tun_attach(tun, file);
 		if (err < 0)
 			goto failed;
@@ -1314,8 +1317,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
 
- err_free_sk:
-	tun_free_netdev(dev);
  err_free_dev:
 	free_netdev(dev);
  failed:
@@ -1379,7 +1380,6 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
 	void __user* argp = (void __user*)arg;
-	struct sock_fprog fprog;
 	struct ifreq ifr;
 	kuid_t owner;
 	kgid_t group;
@@ -1444,11 +1444,16 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		break;
 
 	case TUNSETPERSIST:
-		/* Disable/Enable persist mode */
-		if (arg)
+		/* Disable/Enable persist mode. Keep an extra reference to the
+		 * module to prevent the module being unprobed.
+		 */
+		if (arg) {
 			tun->flags |= TUN_PERSIST;
-		else
+			__module_get(THIS_MODULE);
+		} else {
 			tun->flags &= ~TUN_PERSIST;
+			module_put(THIS_MODULE);
+		}
 
 		tun_debug(KERN_INFO, tun, "persist %s\n",
 			  arg ? "enabled" : "disabled");
@@ -1526,7 +1531,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		break;
 
 	case TUNGETSNDBUF:
-		sndbuf = tun->socket.sk->sk_sndbuf;
+		sndbuf = tfile->socket.sk->sk_sndbuf;
 		if (copy_to_user(argp, &sndbuf, sizeof(sndbuf)))
 			ret = -EFAULT;
 		break;
@@ -1537,7 +1542,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			break;
 		}
 
-		tun->socket.sk->sk_sndbuf = sndbuf;
+		tun->sndbuf = tfile->socket.sk->sk_sndbuf = sndbuf;
 		break;
 
 	case TUNGETVNETHDRSZ:
@@ -1565,10 +1570,12 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
 			break;
 		ret = -EFAULT;
-		if (copy_from_user(&fprog, argp, sizeof(fprog)))
+		if (copy_from_user(&tun->fprog, argp, sizeof(tun->fprog)))
 			break;
 
-		ret = sk_attach_filter(&fprog, tun->socket.sk);
+		ret = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		if (!ret)
+			tun->filter_attached = true;
 		break;
 
 	case TUNDETACHFILTER:
@@ -1576,7 +1583,9 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		ret = -EINVAL;
 		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
 			break;
-		ret = sk_detach_filter(tun->socket.sk);
+		ret = sk_detach_filter(tfile->socket.sk);
+		if (!ret)
+			tun->filter_attached = false;
 		break;
 
 	default:
@@ -1628,27 +1637,21 @@ static long tun_chr_compat_ioctl(struct file *file,
 
 static int tun_chr_fasync(int fd, struct file *file, int on)
 {
-	struct tun_struct *tun = tun_get(file);
+	struct tun_file *tfile = file->private_data;
 	int ret;
 
-	if (!tun)
-		return -EBADFD;
-
-	tun_debug(KERN_INFO, tun, "tun_chr_fasync %d\n", on);
-
-	if ((ret = fasync_helper(fd, file, on, &tun->fasync)) < 0)
+	if ((ret = fasync_helper(fd, file, on, &tfile->fasync)) < 0)
 		goto out;
 
 	if (on) {
 		ret = __f_setown(file, task_pid(current), PIDTYPE_PID, 0);
 		if (ret)
 			goto out;
-		tun->flags |= TUN_FASYNC;
+		tfile->flags |= TUN_FASYNC;
 	} else
-		tun->flags &= ~TUN_FASYNC;
+		tfile->flags &= ~TUN_FASYNC;
 	ret = 0;
 out:
-	tun_put(tun);
 	return ret;
 }
 
@@ -1658,13 +1661,30 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 
 	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
 
-	tfile = kmalloc(sizeof(*tfile), GFP_KERNEL);
+	tfile = (struct tun_file *)sk_alloc(&init_net, AF_UNSPEC, GFP_KERNEL,
+					    &tun_proto);
 	if (!tfile)
 		return -ENOMEM;
 	atomic_set(&tfile->count, 0);
 	tfile->tun = NULL;
 	tfile->net = get_net(current->nsproxy->net_ns);
+	tfile->flags = 0;
+
+	rcu_assign_pointer(tfile->socket.wq, &tfile->wq);
+	init_waitqueue_head(&tfile->wq.wait);
+
+	tfile->socket.file = file;
+	tfile->socket.ops = &tun_socket_ops;
+
+	sock_init_data(&tfile->socket, &tfile->sk);
+	sk_change_net(&tfile->sk, tfile->net);
+
+	tfile->sk.sk_write_space = tun_sock_write_space;
+	tfile->sk.sk_sndbuf = INT_MAX;
+
 	file->private_data = tfile;
+	set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
+
 	return 0;
 }
 
@@ -1672,6 +1692,7 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 {
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
+	struct net *net = tfile->net;
 
 	tun = __tun_get(tfile);
 	if (tun) {
@@ -1688,14 +1709,16 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 				unregister_netdevice(dev);
 			rtnl_unlock();
 		}
-	}
 
-	tun = tfile->tun;
-	if (tun)
-		sock_put(tun->socket.sk);
+		/* drop the reference that netdevice holds */
+		sock_put(&tfile->sk);
+	}
 
-	put_net(tfile->net);
-	kfree(tfile);
+	/* drop the reference that file holds */
+	BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED,
+			 &tfile->socket.flags));
+	sk_release_kernel(&tfile->sk);
+	put_net(net);
 
 	return 0;
 }
@@ -1823,13 +1846,14 @@ static void tun_cleanup(void)
 struct socket *tun_get_socket(struct file *file)
 {
 	struct tun_struct *tun;
+	struct tun_file *tfile = file->private_data;
 	if (file->f_op != &tun_fops)
 		return ERR_PTR(-EINVAL);
 	tun = tun_get(file);
 	if (!tun)
 		return ERR_PTR(-EBADFD);
 	tun_put(tun);
-	return &tun->socket;
+	return &tfile->socket;
 }
 EXPORT_SYMBOL_GPL(tun_get_socket);
 
-- 
1.7.1
