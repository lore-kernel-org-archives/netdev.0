From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/macvtap: fix reference counting
Date: Thu, 11 Feb 2010 16:45:02 +0100
Message-ID: <201002111645.02770.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de> <1265825143.30414.81.camel@w-sridhar.beaverton.ibm.com> <4B72F67F.1040008@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Ed Swierk <eswierk@aristanetworks.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:63327 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab0BKPpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 10:45:15 -0500
In-Reply-To: <4B72F67F.1040008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RCU usage in the original code was broken because
there are cases where we possibly sleep with rcu_read_lock
held. As a fix, change the macvtap_file_get_queue to
get a reference on the socket and the netdev instead of
taking the full rcu_read_lock.

Also, change macvtap_file_get_queue failure case to
not require a subsequent macvtap_file_put_queue, as
pointed out by Ed Swierk.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Ed Swierk <eswierk@aristanetworks.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>
---
 drivers/net/macvtap.c |   57 +++++++++++++++++++++++++++++++-----------------
 1 files changed, 37 insertions(+), 20 deletions(-)

Sridhar, Ed: Does this look ok to you? I'm still working
on restoring my test setup, but I'd like you to take a
look at this version.

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index ad1f6ef..5954324 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -159,8 +159,12 @@ static void macvtap_del_queues(struct net_device *dev)
 
 static inline struct macvtap_queue *macvtap_file_get_queue(struct file *file)
 {
+	struct macvtap_queue *q;
 	rcu_read_lock_bh();
-	return rcu_dereference(file->private_data);
+	q = rcu_dereference(file->private_data);
+	if (!q)
+		rcu_read_unlock_bh();
+	return q;
 }
 
 static inline void macvtap_file_put_queue(void)
@@ -314,13 +318,13 @@ static unsigned int macvtap_poll(struct file *file, poll_table * wait)
 	     sock_writeable(&q->sk)))
 		mask |= POLLOUT | POLLWRNORM;
 
-out:
 	macvtap_file_put_queue();
+out:
 	return mask;
 }
 
 /* Get packet from user space buffer */
-static ssize_t macvtap_get_user(struct macvtap_queue *q,
+static ssize_t macvtap_get_user(struct macvlan_dev *vlan, struct sock *sk,
 				const struct iovec *iv, size_t count,
 				int noblock)
 {
@@ -331,10 +335,10 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	if (unlikely(len < ETH_HLEN))
 		return -EINVAL;
 
-	skb = sock_alloc_send_skb(&q->sk, NET_IP_ALIGN + len, noblock, &err);
+	skb = sock_alloc_send_skb(sk, NET_IP_ALIGN + len, noblock, &err);
 
 	if (!skb) {
-		macvlan_count_rx(q->vlan, 0, false, false);
+		macvlan_count_rx(vlan, 0, false, false);
 		return err;
 	}
 
@@ -342,14 +346,14 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	skb_put(skb, count);
 
 	if (skb_copy_datagram_from_iovec(skb, 0, iv, 0, len)) {
-		macvlan_count_rx(q->vlan, 0, false, false);
+		macvlan_count_rx(vlan, 0, false, false);
 		kfree_skb(skb);
 		return -EFAULT;
 	}
 
 	skb_set_network_header(skb, ETH_HLEN);
 
-	macvlan_start_xmit(skb, q->vlan->dev);
+	macvlan_start_xmit(skb, vlan->dev);
 
 	return count;
 }
@@ -360,23 +364,29 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
 	struct file *file = iocb->ki_filp;
 	ssize_t result = -ENOLINK;
 	struct macvtap_queue *q = macvtap_file_get_queue(file);
+	struct macvlan_dev *vlan;
+	struct sock *sk;
 
 	if (!q)
 		goto out;
 
-	result = macvtap_get_user(q, iv, iov_length(iv, count),
+	vlan = q->vlan;
+	sk = &q->sk;
+	sock_hold(sk);
+	macvtap_file_put_queue();
+
+	result = macvtap_get_user(vlan, sk, iv, iov_length(iv, count),
 			      file->f_flags & O_NONBLOCK);
+	sock_put(sk);
 out:
-	macvtap_file_put_queue();
 	return result;
 }
 
 /* Put packet to the user space buffer */
-static ssize_t macvtap_put_user(struct macvtap_queue *q,
+static ssize_t macvtap_put_user(struct macvlan_dev *vlan,
 				const struct sk_buff *skb,
 				const struct iovec *iv, int len)
 {
-	struct macvlan_dev *vlan = q->vlan;
 	int ret;
 
 	len = min_t(int, skb->len, len);
@@ -393,15 +403,20 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 {
 	struct file *file = iocb->ki_filp;
 	struct macvtap_queue *q = macvtap_file_get_queue(file);
+	struct macvlan_dev *vlan;
+	struct sock *sk;
 
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
 	ssize_t len, ret = 0;
 
-	if (!q) {
-		ret = -ENOLINK;
-		goto out;
-	}
+	if (!q)
+		return -ENOLINK;
+
+	vlan = q->vlan;
+	sk = &q->sk;
+	sock_hold(sk);
+	macvtap_file_put_queue();
 
 	len = iov_length(iv, count);
 	if (len < 0) {
@@ -409,12 +424,12 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	add_wait_queue(q->sk.sk_sleep, &wait);
+	add_wait_queue(sk->sk_sleep, &wait);
 	while (len) {
 		current->state = TASK_INTERRUPTIBLE;
 
 		/* Read frames from the queue */
-		skb = skb_dequeue(&q->sk.sk_receive_queue);
+		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (!skb) {
 			if (file->f_flags & O_NONBLOCK) {
 				ret = -EAGAIN;
@@ -428,16 +443,16 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 			schedule();
 			continue;
 		}
-		ret = macvtap_put_user(q, skb, iv, len);
+		ret = macvtap_put_user(vlan, skb, iv, len);
 		kfree_skb(skb);
 		break;
 	}
 
 	current->state = TASK_RUNNING;
-	remove_wait_queue(q->sk.sk_sleep, &wait);
+	remove_wait_queue(sk->sk_sleep, &wait);
 
 out:
-	macvtap_file_put_queue();
+	sock_put(sk);
 	return ret;
 }
 
@@ -485,6 +500,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			return -EFAULT;
 
 		q = macvtap_file_get_queue(file);
+		if (!q)
+			return -ENOLINK;
 		q->sk.sk_sndbuf = u;
 		macvtap_file_put_queue();
 		return 0;
-- 
1.6.3.3
