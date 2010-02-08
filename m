From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Mon, 08 Feb 2010 10:55:34 -0800
Message-ID: <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>
References: <201001271104.20607.arnd@arndb.de>
	 <201001302322.15237.arnd@arndb.de>
	 <20100203.202104.151098461.davem@davemloft.net>
	 <9ae48b021002080914j2811e7cejd1c29aa3653ba8de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org
To: Ed Swierk <eswierk@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:36779 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962Ab0BHSzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 13:55:38 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o18ImYiO021822
	for <netdev@vger.kernel.org>; Mon, 8 Feb 2010 13:48:34 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o18ItbOC139318
	for <netdev@vger.kernel.org>; Mon, 8 Feb 2010 13:55:37 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o18ItaN3025167
	for <netdev@vger.kernel.org>; Mon, 8 Feb 2010 16:55:37 -0200
In-Reply-To: <9ae48b021002080914j2811e7cejd1c29aa3653ba8de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-08 at 09:14 -0800, Ed Swierk wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> > Date: Sat, 30 Jan 2010 23:22:15 +0100
> >
> >> This is the fourth version of the macvtap driver,
> >> based on the comments I got for the last version
> >> I got a few days ago. Very few changes:
> >>
> >> * release netdev in chardev open function so
> >>   we can destroy it properly.
> >> * Implement TUNSETSNDBUF
> >> * fix sleeping call in rcu_read_lock
> >> * Fix comment in namespace isolation patch
> >> * Fix small context difference to make it apply
> >>   to net-next
> >>
> >> I can't really test here while travelling, so please
> >> give it a go if you're interested in this driver.
> 
> I'm seeing complaints from might_sleep():
> 
> Feb  8 16:21:06 ti102 kernel: BUG: sleeping function called from
> invalid context at include/linux/kernel.h:155
> Feb  8 16:21:06 ti102 kernel: in_atomic(): 1, irqs_disabled(): 0, pid:
> 2881, name: qemu-kvm
> Feb  8 16:21:06 ti102 kernel: Pid: 2881, comm: qemu-kvm Not tainted
> 2.6.29.6.Ar-224527.2009eswierk8 #1
> Feb  8 16:21:06 ti102 kernel: Call Trace:
> Feb  8 16:21:06 ti102 kernel: [<c0119250>] __might_sleep+0xdc/0xe3
> Feb  8 16:21:06 ti102 kernel: [<c0210f7c>] copy_to_user+0x36/0x106
> Feb  8 16:21:06 ti102 kernel: [<c02af568>] memcpy_toiovec+0x2c/0x50
> Feb  8 16:21:06 ti102 kernel: [<c02afbb3>] skb_copy_datagram_iovec+0x47/0x184
> Feb  8 16:21:06 ti102 kernel: [<c034bd07>] ? _spin_unlock_irqrestore+0x17/0x2c
> Feb  8 16:21:06 ti102 kernel: [<f829a776>]
> macvtap_aio_read+0x102/0x158 [macvtap]
> Feb  8 16:21:06 ti102 kernel: [<c011eaf7>] ? default_wake_function+0x0/0xd
> Feb  8 16:21:06 ti102 kernel: [<c016c75f>] do_sync_read+0xab/0xe9
> Feb  8 16:21:06 ti102 kernel: [<c0133933>] ? autoremove_wake_function+0x0/0x33
> Feb  8 16:21:06 ti102 kernel: [<c019211f>] ? eventfd_read+0x121/0x156
> Feb  8 16:21:06 ti102 kernel: [<c011eaf7>] ? default_wake_function+0x0/0xd
> Feb  8 16:21:06 ti102 kernel: [<c016d101>] vfs_read+0xb5/0x129
> Feb  8 16:21:06 ti102 kernel: [<c016d20e>] sys_read+0x3b/0x60
> Feb  8 16:21:06 ti102 kernel: [<c0102e71>] sysenter_do_call+0x12/0x25

I am also seeing this issue with net-next-2.6.
Basically macvtap_put_user() and macvtap_get_user() call copy_to/from_user
from within a RCU read-side critical section.

The following patch fixes this issue by releasing the RCU read lock before
calling these routines, but instead hold a reference to q->sk.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index ad1f6ef..e3102ab 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -320,7 +320,7 @@ out:
 }
 
 /* Get packet from user space buffer */
-static ssize_t macvtap_get_user(struct macvtap_queue *q,
+static ssize_t macvtap_get_user(struct macvlan_dev *vlan, struct sock *sk,
 				const struct iovec *iv, size_t count,
 				int noblock)
 {
@@ -331,10 +331,10 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	if (unlikely(len < ETH_HLEN))
 		return -EINVAL;
 
-	skb = sock_alloc_send_skb(&q->sk, NET_IP_ALIGN + len, noblock, &err);
+	skb = sock_alloc_send_skb(sk, NET_IP_ALIGN + len, noblock, &err);
 
 	if (!skb) {
-		macvlan_count_rx(q->vlan, 0, false, false);
+		macvlan_count_rx(vlan, 0, false, false);
 		return err;
 	}
 
@@ -342,14 +342,14 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
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
@@ -360,23 +360,29 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
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
@@ -393,15 +399,20 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
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
@@ -409,12 +420,12 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
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
@@ -428,16 +439,16 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
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
 




