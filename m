From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 07/10] tun: Move read_wait into tun_file
Date: Tue, 20 Jan 2009 13:03:21 -0800
Message-ID: <m1vds9k7vq.fsf_-_@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
	<m1skndlmrv.fsf@fess.ebiederm.org>
	<m1mydllmpf.fsf_-_@fess.ebiederm.org>
	<m1hc3tlmna.fsf_-_@fess.ebiederm.org>
	<m1bpu1lmkn.fsf_-_@fess.ebiederm.org>
	<m17i4plmir.fsf_-_@fess.ebiederm.org>
	<m11vuxlmhn.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56269 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523AbZAUCpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:17 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out02.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5h-00015T-8S
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:17 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5g-00054W-Lh
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:17 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jIru029121
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:18 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jItA029120
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:18 -0800
In-Reply-To: <m11vuxlmhn.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 13\:02\:28 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The poll interface requires that the waitqueue exist while the struct
file is open.  In the rare case when a tun device disappears before
the tun file closes we fail to provide this property, so move
read_wait.

This is safe now that tun_net_xmit is atomic with tun_detach.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index fa93160..030d985 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -90,6 +90,7 @@ struct tap_filter {
 struct tun_file {
 	struct tun_struct *tun;
 	struct net *net;
+	wait_queue_head_t	read_wait;
 };
 
 struct tun_struct {
@@ -98,7 +99,6 @@ struct tun_struct {
 	uid_t			owner;
 	gid_t			group;
 
-	wait_queue_head_t	read_wait;
 	struct sk_buff_head	readq;
 
 	struct net_device	*dev;
@@ -335,7 +335,7 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
-	wake_up_interruptible(&tun->read_wait);
+	wake_up_interruptible(&tun->tfile->read_wait);
 	return 0;
 
 drop:
@@ -420,7 +420,8 @@ static void tun_net_init(struct net_device *dev)
 /* Poll */
 static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 {
-	struct tun_struct *tun = tun_get(file);
+	struct tun_file *tfile = file->private_data;
+	struct tun_struct *tun = __tun_get(tfile);
 	unsigned int mask = POLLOUT | POLLWRNORM;
 
 	if (!tun)
@@ -428,7 +429,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 
 	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
-	poll_wait(file, &tun->read_wait, wait);
+	poll_wait(file, &tfile->read_wait, wait);
 
 	if (!skb_queue_empty(&tun->readq))
 		mask |= POLLIN | POLLRDNORM;
@@ -702,7 +703,8 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 			    unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
-	struct tun_struct *tun = tun_get(file);
+	struct tun_file *tfile = file->private_data;
+	struct tun_struct *tun = __tun_get(tfile);
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
 	ssize_t len, ret = 0;
@@ -718,7 +720,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	add_wait_queue(&tun->read_wait, &wait);
+	add_wait_queue(&tfile->read_wait, &wait);
 	while (len) {
 		current->state = TASK_INTERRUPTIBLE;
 
@@ -745,7 +747,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	}
 
 	current->state = TASK_RUNNING;
-	remove_wait_queue(&tun->read_wait, &wait);
+	remove_wait_queue(&tfile->read_wait, &wait);
 
 out:
 	tun_put(tun);
@@ -757,7 +759,6 @@ static void tun_setup(struct net_device *dev)
 	struct tun_struct *tun = netdev_priv(dev);
 
 	skb_queue_head_init(&tun->readq);
-	init_waitqueue_head(&tun->read_wait);
 
 	tun->owner = -1;
 	tun->group = -1;
@@ -1136,6 +1137,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 		return -ENOMEM;
 	tfile->tun = NULL;
 	tfile->net = get_net(current->nsproxy->net_ns);
+	init_waitqueue_head(&tfile->read_wait);
 	file->private_data = tfile;
 	return 0;
 }
-- 
1.5.6.3
