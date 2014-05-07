From: Xi Wang <xii@google.com>
Subject: [PATCH] net-tun: restructure tun_do_read for better sleep/wakeup efficiency
Date: Tue,  6 May 2014 17:24:04 -0700
Message-ID: <1399422244-22751-1-git-send-email-xii@google.com>
Cc: Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Jason Wang <jasowang@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>, Xi Wang <xii@google.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:43455 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754683AbaEGAYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 20:24:33 -0400
Received: by mail-qa0-f73.google.com with SMTP id hw13so47519qab.4
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 17:24:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun_do_read always adds current thread to wait queue, even if a packet
is ready to read. This is inefficient because both sleeper and waker
want to acquire the wait queue spin lock when packet rate is high.

We restructure the read function and use common kernel networking
routines to handle receive, sleep and wakeup. With the change
available packets are checked first before the reading thread is added
to the wait queue.

Ran performance tests with the following configuration:

 - my packet generator -> tap1 -> br0 -> tap0 -> my packet consumer
 - sender pinned to one core and receiver pinned to another core
 - sender send small UDP packets (64 bytes total) as fast as it can
 - sandy bridge cores
 - throughput are receiver side goodput numbers

The results are

baseline: 757k pkts/sec, cpu utilization at 1.54 cpus
 changed: 804k pkts/sec, cpu utilization at 1.57 cpus

The performance difference is largely determined by packet rate and
inter-cpu communication cost. For example, if the sender and
receiver are pinned to different cpu sockets, the results are

baseline: 558k pkts/sec, cpu utilization at 1.71 cpus
 changed: 690k pkts/sec, cpu utilization at 1.67 cpus

Co-authored-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Xi Wang <xii@google.com>
---
 drivers/net/tun.c | 68 +++++++++++++++++++++----------------------------------
 1 file changed, 26 insertions(+), 42 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ee328ba..cb25385 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -133,8 +133,7 @@ struct tap_filter {
 struct tun_file {
 	struct sock sk;
 	struct socket socket;
-	struct socket_wq wq;
-	struct tun_struct __rcu *tun;
+	struct tun_struct __rcu *tun ____cacheline_aligned_in_smp;
 	struct net *net;
 	struct fasync_struct *fasync;
 	/* only used for fasnyc */
@@ -498,12 +497,12 @@ static void tun_detach_all(struct net_device *dev)
 	for (i = 0; i < n; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
 		BUG_ON(!tfile);
-		wake_up_all(&tfile->wq.wait);
+		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
 		RCU_INIT_POINTER(tfile->tun, NULL);
 		--tun->numqueues;
 	}
 	list_for_each_entry(tfile, &tun->disabled, next) {
-		wake_up_all(&tfile->wq.wait);
+	tfile->socket.sk->sk_data_ready(tfile->socket.sk);
 		RCU_INIT_POINTER(tfile->tun, NULL);
 	}
 	BUG_ON(tun->numqueues != 0);
@@ -807,8 +806,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Notify and wake up reader process */
 	if (tfile->flags & TUN_FASYNC)
 		kill_fasync(&tfile->fasync, SIGIO, POLL_IN);
-	wake_up_interruptible_poll(&tfile->wq.wait, POLLIN |
-				   POLLRDNORM | POLLRDBAND);
+	tfile->socket.sk->sk_data_ready(tfile->socket.sk);
 
 	rcu_read_unlock();
 	return NETDEV_TX_OK;
@@ -965,7 +963,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
 
 	tun_debug(KERN_INFO, tun, "tun_chr_poll\n");
 
-	poll_wait(file, &tfile->wq.wait, wait);
+	poll_wait(file, sk_sleep(sk), wait);
 
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
@@ -1330,46 +1328,21 @@ done:
 static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 			   const struct iovec *iv, ssize_t len, int noblock)
 {
-	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
 	ssize_t ret = 0;
+	int peeked, err, off = 0;
 
 	tun_debug(KERN_INFO, tun, "tun_do_read\n");
 
-	if (unlikely(!noblock))
-		add_wait_queue(&tfile->wq.wait, &wait);
-	while (len) {
-		if (unlikely(!noblock))
-			current->state = TASK_INTERRUPTIBLE;
-
-		/* Read frames from the queue */
-		if (!(skb = skb_dequeue(&tfile->socket.sk->sk_receive_queue))) {
-			if (noblock) {
-				ret = -EAGAIN;
-				break;
-			}
-			if (signal_pending(current)) {
-				ret = -ERESTARTSYS;
-				break;
-			}
-			if (tun->dev->reg_state != NETREG_REGISTERED) {
-				ret = -EIO;
-				break;
-			}
-
-			/* Nothing to read, let's sleep */
-			schedule();
-			continue;
-		}
+	if (!len)
+		return ret;
 
+	/* Read frames from queue */
+	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
+				  &peeked, &off, &err);
+	if (skb) {
 		ret = tun_put_user(tun, tfile, skb, iv, len);
 		kfree_skb(skb);
-		break;
-	}
-
-	if (unlikely(!noblock)) {
-		current->state = TASK_RUNNING;
-		remove_wait_queue(&tfile->wq.wait, &wait);
 	}
 
 	return ret;
@@ -2187,20 +2160,28 @@ out:
 static int tun_chr_open(struct inode *inode, struct file * file)
 {
 	struct tun_file *tfile;
+	struct socket_wq *wq;
 
 	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
 
+	wq = kzalloc(sizeof(*wq), GFP_KERNEL);
+	if (!wq)
+		return -ENOMEM;
+
 	tfile = (struct tun_file *)sk_alloc(&init_net, AF_UNSPEC, GFP_KERNEL,
 					    &tun_proto);
-	if (!tfile)
+	if (!tfile) {
+		kfree(wq);
 		return -ENOMEM;
+	}
+
 	RCU_INIT_POINTER(tfile->tun, NULL);
 	tfile->net = get_net(current->nsproxy->net_ns);
 	tfile->flags = 0;
 	tfile->ifindex = 0;
 
-	rcu_assign_pointer(tfile->socket.wq, &tfile->wq);
-	init_waitqueue_head(&tfile->wq.wait);
+	init_waitqueue_head(&wq->wait);
+	RCU_INIT_POINTER(tfile->socket.wq, wq);
 
 	tfile->socket.file = file;
 	tfile->socket.ops = &tun_socket_ops;
@@ -2224,9 +2205,12 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 {
 	struct tun_file *tfile = file->private_data;
 	struct net *net = tfile->net;
+	struct socket_wq *wq;
 
+	wq = rcu_dereference_protected(tfile->socket.wq, 1);
 	tun_detach(tfile, true);
 	put_net(net);
+	kfree_rcu(wq, rcu);
 
 	return 0;
 }
-- 
1.9.1.423.g4596e3a
