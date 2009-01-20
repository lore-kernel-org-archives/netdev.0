From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 08/10] tun: Fix races between tun_net_close and free_netdev.
Date: Tue, 20 Jan 2009 13:07:17 -0800
Message-ID: <m1prihk7p6.fsf_-_@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
	<m1skndlmrv.fsf@fess.ebiederm.org>
	<m1mydllmpf.fsf_-_@fess.ebiederm.org>
	<m1hc3tlmna.fsf_-_@fess.ebiederm.org>
	<m1bpu1lmkn.fsf_-_@fess.ebiederm.org>
	<m17i4plmir.fsf_-_@fess.ebiederm.org>
	<m11vuxlmhn.fsf_-_@fess.ebiederm.org>
	<m1vds9k7vq.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52478 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529AbZAUCpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:18 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out01.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5s-0007Ya-0M
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:28 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5h-00054Y-1x
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:17 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jIvf029125
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:18 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jIVj029124
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:18 -0800
In-Reply-To: <m1vds9k7vq.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 13\:03\:21 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The tun code does not cope gracefully if the network device goes away before
the tun file descriptor is closed.  It looks like we can trigger this with
rmmod, and moving tun devices between network namespaces will allow this
to be triggered when network namespaces exit.

To fix this I introduce an intermediate data structure tun_file which
holds a count of users and a pointer to the struct tun_struct.  tun_get
increments that reference count if it is greater than 0.  tun_put decrements
that reference count and detaches from the network device if the count is 0.

While we have a file attached to the network device I hold a reference
to the network device keeping it from going away completely.

When a network device is unregistered I decrement the count of the
attached tun_file and if that was the last user I detach the tun_file,
and all processes on read_wait are woken up to ensure they do not
sleep indefinitely. As some of those sleeps happen with the count on
the tun device elevated waking up the read waiters ensures that
tun_file will be detached in a timely manner.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 030d985..51dba61 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -88,6 +88,7 @@ struct tap_filter {
 };
 
 struct tun_file {
+	atomic_t count;
 	struct tun_struct *tun;
 	struct net *net;
 	wait_queue_head_t	read_wait;
@@ -138,6 +139,8 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	err = 0;
 	tfile->tun = tun;
 	tun->tfile = tfile;
+	dev_hold(tun->dev);
+	atomic_inc(&tfile->count);
 
 out:
 	netif_tx_unlock_bh(tun->dev);
@@ -156,11 +159,26 @@ static void __tun_detach(struct tun_struct *tun)
 
 	/* Drop read queue */
 	skb_queue_purge(&tun->readq);
+
+	/* Drop the extra count on the net device */
+	dev_put(tun->dev);
+}
+
+static void tun_detach(struct tun_struct *tun)
+{
+	rtnl_lock();
+	__tun_detach(tun);
+	rtnl_unlock();
 }
 
 static struct tun_struct *__tun_get(struct tun_file *tfile)
 {
-	return tfile->tun;
+	struct tun_struct *tun = NULL;
+
+	if (atomic_inc_not_zero(&tfile->count))
+		tun = tfile->tun;
+
+	return tun;
 }
 
 static struct tun_struct *tun_get(struct file *file)
@@ -170,7 +188,10 @@ static struct tun_struct *tun_get(struct file *file)
 
 static void tun_put(struct tun_struct *tun)
 {
-	/* Noop for now */
+	struct tun_file *tfile = tun->tfile;
+
+	if (atomic_dec_and_test(&tfile->count))
+		tun_detach(tfile->tun);
 }
 
 /* TAP filterting */
@@ -281,6 +302,21 @@ static int check_filter(struct tap_filter *filter, const struct sk_buff *skb)
 
 static const struct ethtool_ops tun_ethtool_ops;
 
+/* Net device detach from fd. */
+static void tun_net_uninit(struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	struct tun_file *tfile = tun->tfile;
+
+	/* Inform the methods they need to stop using the dev.
+	 */
+	if (tfile) {
+		wake_up_all(&tfile->read_wait);
+		if (atomic_dec_and_test(&tfile->count))
+			__tun_detach(tun);
+	}
+}
+
 /* Net device open. */
 static int tun_net_open(struct net_device *dev)
 {
@@ -367,6 +403,7 @@ tun_net_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 static const struct net_device_ops tun_netdev_ops = {
+	.ndo_uninit		= tun_net_uninit,
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
@@ -374,6 +411,7 @@ static const struct net_device_ops tun_netdev_ops = {
 };
 
 static const struct net_device_ops tap_netdev_ops = {
+	.ndo_uninit		= tun_net_uninit,
 	.ndo_open		= tun_net_open,
 	.ndo_stop		= tun_net_close,
 	.ndo_start_xmit		= tun_net_xmit,
@@ -434,6 +472,9 @@ static unsigned int tun_chr_poll(struct file *file, poll_table * wait)
 	if (!skb_queue_empty(&tun->readq))
 		mask |= POLLIN | POLLRDNORM;
 
+	if (tun->dev->reg_state != NETREG_REGISTERED)
+		mask = POLLERR;
+
 	tun_put(tun);
 	return mask;
 }
@@ -734,6 +775,10 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 				ret = -ERESTARTSYS;
 				break;
 			}
+			if (tun->dev->reg_state != NETREG_REGISTERED) {
+				ret = -EIO;
+				break;
+			}
 
 			/* Nothing to read, let's sleep */
 			schedule();
@@ -1135,6 +1180,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	tfile = kmalloc(sizeof(*tfile), GFP_KERNEL);
 	if (!tfile)
 		return -ENOMEM;
+	atomic_set(&tfile->count, 0);
 	tfile->tun = NULL;
 	tfile->net = get_net(current->nsproxy->net_ns);
 	init_waitqueue_head(&tfile->read_wait);
-- 
1.5.6.3
