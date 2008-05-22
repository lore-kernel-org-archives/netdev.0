From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] ppp: push BKL down into the driver
Date: Thu, 22 May 2008 21:57:11 +0100
Message-ID: <20080522215711.46fa07ac@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:58184 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754980AbYEVVJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 17:09:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've pushed it down as far as I dare at this point. Someone familiar with
the internal PPP semantics can probably push it further. Another step to
eliminating the old BKL ioctl usage.

Signed-off-by: Alan Cox <alan@redhat.com>

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index d3207c0..86e67ab 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -361,7 +361,7 @@ static int ppp_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int ppp_release(struct inode *inode, struct file *file)
+static int ppp_release(struct inode *unused, struct file *file)
 {
 	struct ppp_file *pf = file->private_data;
 	struct ppp *ppp;
@@ -545,8 +545,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 }
 #endif /* CONFIG_PPP_FILTER */
 
-static int ppp_ioctl(struct inode *inode, struct file *file,
-		     unsigned int cmd, unsigned long arg)
+static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct ppp_file *pf = file->private_data;
 	struct ppp *ppp;
@@ -574,24 +573,29 @@ static int ppp_ioctl(struct inode *inode, struct file *file,
 		 * this fd and reopening /dev/ppp.
 		 */
 		err = -EINVAL;
+		lock_kernel();
 		if (pf->kind == INTERFACE) {
 			ppp = PF_TO_PPP(pf);
 			if (file == ppp->owner)
 				ppp_shutdown_interface(ppp);
 		}
 		if (atomic_read(&file->f_count) <= 2) {
-			ppp_release(inode, file);
+			ppp_release(NULL, file);
 			err = 0;
 		} else
 			printk(KERN_DEBUG "PPPIOCDETACH file->f_count=%d\n",
 			       atomic_read(&file->f_count));
+		unlock_kernel();
 		return err;
 	}
 
 	if (pf->kind == CHANNEL) {
-		struct channel *pch = PF_TO_CHANNEL(pf);
+		struct channel *pch;
 		struct ppp_channel *chan;
 
+		lock_kernel();
+		pch = PF_TO_CHANNEL(pf);
+
 		switch (cmd) {
 		case PPPIOCCONNECT:
 			if (get_user(unit, p))
@@ -611,6 +615,7 @@ static int ppp_ioctl(struct inode *inode, struct file *file,
 				err = chan->ops->ioctl(chan, cmd, arg);
 			up_read(&pch->chan_sem);
 		}
+		unlock_kernel();
 		return err;
 	}
 
@@ -620,6 +625,7 @@ static int ppp_ioctl(struct inode *inode, struct file *file,
 		return -EINVAL;
 	}
 
+	lock_kernel();
 	ppp = PF_TO_PPP(pf);
 	switch (cmd) {
 	case PPPIOCSMRU:
@@ -767,7 +773,7 @@ static int ppp_ioctl(struct inode *inode, struct file *file,
 	default:
 		err = -ENOTTY;
 	}
-
+	unlock_kernel();
 	return err;
 }
 
@@ -779,6 +785,7 @@ static int ppp_unattached_ioctl(struct ppp_file *pf, struct file *file,
 	struct channel *chan;
 	int __user *p = (int __user *)arg;
 
+	lock_kernel();
 	switch (cmd) {
 	case PPPIOCNEWUNIT:
 		/* Create a new ppp unit */
@@ -827,6 +834,7 @@ static int ppp_unattached_ioctl(struct ppp_file *pf, struct file *file,
 	default:
 		err = -ENOTTY;
 	}
+	unlock_kernel();
 	return err;
 }
 
@@ -835,7 +843,7 @@ static const struct file_operations ppp_device_fops = {
 	.read		= ppp_read,
 	.write		= ppp_write,
 	.poll		= ppp_poll,
-	.ioctl		= ppp_ioctl,
+	.unlocked_ioctl	= ppp_ioctl,
 	.open		= ppp_open,
 	.release	= ppp_release
 };
