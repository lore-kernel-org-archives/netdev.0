From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net v2] ppp: ensure file->private_data can't be overridden
Date: Mon, 14 Mar 2016 21:17:16 +0100
Message-ID: <7866074a3c03ea15640aa72ef2553987862bc8b6.1457986520.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>, Alan Cox <alan@linux.intel.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:37927 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171AbcCNURV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 16:17:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locking ppp_mutex must be done before dereferencing file->private_data,
otherwise it could be modified before ppp_unattached_ioctl() takes the
lock. This could lead ppp_unattached_ioctl() to override ->private_data,
thus leaking reference to the ppp_file previously pointed to.

v2: lock all ppp_ioctl() instead of just checking private_data in
    ppp_unattached_ioctl(), to avoid ambiguous behaviour.

Fixes: f3ff8a4d80e8 ("ppp: push BKL down into the driver")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index d61da9ec..8c8eedb 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -575,7 +575,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 
 static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
-	struct ppp_file *pf = file->private_data;
+	struct ppp_file *pf;
 	struct ppp *ppp;
 	int err = -EFAULT, val, val2, i;
 	struct ppp_idle idle;
@@ -585,9 +585,14 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 	int __user *p = argp;
 
-	if (!pf)
-		return ppp_unattached_ioctl(current->nsproxy->net_ns,
-					pf, file, cmd, arg);
+	mutex_lock(&ppp_mutex);
+
+	pf = file->private_data;
+	if (!pf) {
+		err = ppp_unattached_ioctl(current->nsproxy->net_ns,
+					   pf, file, cmd, arg);
+		goto out;
+	}
 
 	if (cmd == PPPIOCDETACH) {
 		/*
@@ -602,7 +607,6 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		 * this fd and reopening /dev/ppp.
 		 */
 		err = -EINVAL;
-		mutex_lock(&ppp_mutex);
 		if (pf->kind == INTERFACE) {
 			ppp = PF_TO_PPP(pf);
 			rtnl_lock();
@@ -616,15 +620,13 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		} else
 			pr_warn("PPPIOCDETACH file->f_count=%ld\n",
 				atomic_long_read(&file->f_count));
-		mutex_unlock(&ppp_mutex);
-		return err;
+		goto out;
 	}
 
 	if (pf->kind == CHANNEL) {
 		struct channel *pch;
 		struct ppp_channel *chan;
 
-		mutex_lock(&ppp_mutex);
 		pch = PF_TO_CHANNEL(pf);
 
 		switch (cmd) {
@@ -646,17 +648,16 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				err = chan->ops->ioctl(chan, cmd, arg);
 			up_read(&pch->chan_sem);
 		}
-		mutex_unlock(&ppp_mutex);
-		return err;
+		goto out;
 	}
 
 	if (pf->kind != INTERFACE) {
 		/* can't happen */
 		pr_err("PPP: not interface or channel??\n");
-		return -EINVAL;
+		err = -EINVAL;
+		goto out;
 	}
 
-	mutex_lock(&ppp_mutex);
 	ppp = PF_TO_PPP(pf);
 	switch (cmd) {
 	case PPPIOCSMRU:
@@ -831,7 +832,10 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	default:
 		err = -ENOTTY;
 	}
+
+out:
 	mutex_unlock(&ppp_mutex);
+
 	return err;
 }
 
@@ -844,7 +848,6 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 	struct ppp_net *pn;
 	int __user *p = (int __user *)arg;
 
-	mutex_lock(&ppp_mutex);
 	switch (cmd) {
 	case PPPIOCNEWUNIT:
 		/* Create a new ppp unit */
@@ -894,7 +897,7 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 	default:
 		err = -ENOTTY;
 	}
-	mutex_unlock(&ppp_mutex);
+
 	return err;
 }
 
-- 
2.7.0
