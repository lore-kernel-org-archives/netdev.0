From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] tun: reuse struct sock fields
Date: Sun, 30 Aug 2009 20:04:42 +0300
Message-ID: <20090830170442.GA3482@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>, m.s.tsirkin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6541 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747AbZH3RGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Aug 2009 13:06:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As tun always has an embeedded struct sock,
use sk and sk_receive_queue fields instead of
duplicating them in tun_struct.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This patch is on top of net-next.
Any comments? Thanks.

 drivers/net/tun.c |   30 ++++++++++++------------------
 1 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 2533f5c..37e13af 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -103,13 +103,10 @@ struct tun_struct {
 	uid_t			owner;
 	gid_t			group;
 
-	struct sk_buff_head	readq;
-
 	struct net_device	*dev;
 	struct fasync_struct	*fasync;
 
 	struct tap_filter       txflt;
-	struct sock		*sk;
 	struct socket		socket;
 
 #ifdef TUN_DEBUG
@@ -155,7 +152,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	tfile->tun = tun;
 	tun->tfile = tfile;
 	dev_hold(tun->dev);
-	sock_hold(tun->sk);
+	sock_hold(tun->socket.sk);
 	atomic_inc(&tfile->count);
 
 out:
@@ -171,7 +168,7 @@ static void __tun_detach(struct tun_struct *tun)
 	netif_tx_unlock_bh(tun->dev);
 
 	/* Drop read queue */
-	skb_queue_purge(&tun->readq);
+	skb_queue_purge(&tun->socket.sk->sk_receive_queue);
 
 	/* Drop the extra count on the net device */
 	dev_put(tun->dev);
@@ -340,7 +337,7 @@ static void tun_free_netdev(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	sock_put(tun->sk);
+	sock_put(tun->socket.sk);
 }
 
 /* Net device open. */
@@ -374,7 +371,7 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!check_filter(&tun->txflt, skb))
 		goto drop;
 
-	if (skb_queue_len(&tun->readq) >= dev->tx_queue_len) {
+	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
 		if (!(tun->flags & TUN_ONE_QUEUE)) {
 			/* Normal queueing mode. */
 			/* Packet scheduler handles dropping of further packets. */
@@ -391,7 +388,7 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Enqueue packet */
-	skb_queue_tail(&tun->readq, skb);
+	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
 	dev->trans_start = jiffies;
 
 	/* Notify and wake up reader process */
@@ -492,13 +489,13 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 	if (!tun)
 		return POLLERR;
 
-	sk = tun->sk;
+	sk = tun->socket.sk;
 
 	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
 	poll_wait(file, &tun->socket.wait, wait);
 
-	if (!skb_queue_empty(&tun->readq))
+	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sock_writeable(sk) ||
@@ -519,7 +516,7 @@ static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 					    size_t prepad, size_t len,
 					    size_t linear, int noblock)
 {
-	struct sock *sk = tun->sk;
+	struct sock *sk = tun->socket.sk;
 	struct sk_buff *skb;
 	int err;
 
@@ -787,7 +784,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		current->state = TASK_INTERRUPTIBLE;
 
 		/* Read frames from the queue */
-		if (!(skb=skb_dequeue(&tun->readq))) {
+		if (!(skb=skb_dequeue(&tun->socket.sk->sk_receive_queue))) {
 			if (file->f_flags & O_NONBLOCK) {
 				ret = -EAGAIN;
 				break;
@@ -824,8 +821,6 @@ static void tun_setup(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	skb_queue_head_init(&tun->readq);
-
 	tun->owner = -1;
 	tun->group = -1;
 
@@ -991,7 +986,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		sk->sk_write_space = tun_sock_write_space;
 		sk->sk_sndbuf = INT_MAX;
 
-		tun->sk = sk;
 		container_of(sk, struct tun_sock, sk)->tun = tun;
 
 		tun_net_init(dev);
@@ -1249,7 +1244,7 @@ static long tun_chr_ioctl(struct file *file, unsigned int cmd,
 		break;
 
 	case TUNGETSNDBUF:
-		sndbuf = tun->sk->sk_sndbuf;
+		sndbuf = tun->socket.sk->sk_sndbuf;
 		if (copy_to_user(argp, &sndbuf, sizeof(sndbuf)))
 			ret = -EFAULT;
 		break;
@@ -1260,7 +1255,7 @@ static long tun_chr_ioctl(struct file *file, unsigned int cmd,
 			break;
 		}
 
-		tun->sk->sk_sndbuf = sndbuf;
+		tun->socket.sk->sk_sndbuf = sndbuf;
 		break;
 
 	default:
@@ -1343,7 +1338,7 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 
 	tun = tfile->tun;
 	if (tun)
-		sock_put(tun->sk);
+		sock_put(tun->socket.sk);
 
 	put_net(tfile->net);
 	kfree(tfile);
-- 
1.6.2.5
