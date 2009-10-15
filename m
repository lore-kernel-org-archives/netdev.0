From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 3/5] sunrpc: Convert to unlocked_ioctl and remove stray
	smp_lock.h
Date: Thu, 15 Oct 2009 20:28:43 -0000
Message-ID: <20091015202758.481789582@linutronix.de>
References: <20091015202722.372890083@linutronix.de>
Cc: ALan Cox <alan@lxorguk.ukuu.org.uk>, Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935539AbZJOU36@vger.kernel.org>
Content-Disposition: inline;
	filename=net-sunrpc-convert-to-unlocked-ioctl.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ioctls in sunrpc/cache.c can be converted to unlocked_ioctl safely
because the operation is already protected by queue_lock.

The ioctl in rpc_pipe.c can be converted by serializing via
inode->i_mutex.

Remove the stray smp_lock.h include in svc_xprt.c which was not
removed when the BKL was replaced in commit ed2d8aed

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: netdev@vger.kernel.org
---
 net/sunrpc/cache.c    |   25 ++++++++++++-------------
 net/sunrpc/rpc_pipe.c |   16 ++++++++++------
 net/sunrpc/svc_xprt.c |    1 -
 3 files changed, 22 insertions(+), 20 deletions(-)

Index: linux-2.6-tip/net/sunrpc/cache.c
===================================================================
--- linux-2.6-tip.orig/net/sunrpc/cache.c
+++ linux-2.6-tip/net/sunrpc/cache.c
@@ -815,9 +815,8 @@ static unsigned int cache_poll(struct fi
 	return mask;
 }
 
-static int cache_ioctl(struct inode *ino, struct file *filp,
-		       unsigned int cmd, unsigned long arg,
-		       struct cache_detail *cd)
+static long cache_ioctl(struct file *filp, unsigned int cmd, unsigned long arg,
+			struct cache_detail *cd)
 {
 	int len = 0;
 	struct cache_reader *rp = filp->private_data;
@@ -1332,12 +1331,12 @@ static unsigned int cache_poll_procfs(st
 	return cache_poll(filp, wait, cd);
 }
 
-static int cache_ioctl_procfs(struct inode *inode, struct file *filp,
-			      unsigned int cmd, unsigned long arg)
+static long cache_ioctl_procfs(struct file *filp, unsigned int cmd,
+			       unsigned long arg)
 {
-	struct cache_detail *cd = PDE(inode)->data;
+	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
 
-	return cache_ioctl(inode, filp, cmd, arg, cd);
+	return cache_ioctl(filp, cmd, arg, cd);
 }
 
 static int cache_open_procfs(struct inode *inode, struct file *filp)
@@ -1360,7 +1359,7 @@ static const struct file_operations cach
 	.read		= cache_read_procfs,
 	.write		= cache_write_procfs,
 	.poll		= cache_poll_procfs,
-	.ioctl		= cache_ioctl_procfs, /* for FIONREAD */
+	.unlocked_ioctl	= cache_ioctl_procfs, /* for FIONREAD */
 	.open		= cache_open_procfs,
 	.release	= cache_release_procfs,
 };
@@ -1526,12 +1525,12 @@ static unsigned int cache_poll_pipefs(st
 	return cache_poll(filp, wait, cd);
 }
 
-static int cache_ioctl_pipefs(struct inode *inode, struct file *filp,
-			      unsigned int cmd, unsigned long arg)
+static long cache_ioctl_pipefs(struct file *filp, unsigned int cmd,
+			       unsigned long arg)
 {
-	struct cache_detail *cd = RPC_I(inode)->private;
+	struct cache_detail *cd = RPC_I(filp->f_path.dentry->d_inode)->private;
 
-	return cache_ioctl(inode, filp, cmd, arg, cd);
+	return cache_ioctl(filp, cmd, arg, cd);
 }
 
 static int cache_open_pipefs(struct inode *inode, struct file *filp)
@@ -1554,7 +1553,7 @@ const struct file_operations cache_file_
 	.read		= cache_read_pipefs,
 	.write		= cache_write_pipefs,
 	.poll		= cache_poll_pipefs,
-	.ioctl		= cache_ioctl_pipefs, /* for FIONREAD */
+	.unlocked_ioctl	= cache_ioctl_pipefs, /* for FIONREAD */
 	.open		= cache_open_pipefs,
 	.release	= cache_release_pipefs,
 };
Index: linux-2.6-tip/net/sunrpc/rpc_pipe.c
===================================================================
--- linux-2.6-tip.orig/net/sunrpc/rpc_pipe.c
+++ linux-2.6-tip/net/sunrpc/rpc_pipe.c
@@ -308,23 +308,27 @@ rpc_pipe_poll(struct file *filp, struct 
 	return mask;
 }
 
-static int
-rpc_pipe_ioctl(struct inode *ino, struct file *filp,
-		unsigned int cmd, unsigned long arg)
+static long
+rpc_pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 {
-	struct rpc_inode *rpci = RPC_I(filp->f_path.dentry->d_inode);
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct rpc_inode *rpci = RPC_I(inode);
 	int len;
 
 	switch (cmd) {
 	case FIONREAD:
-		if (rpci->ops == NULL)
+		mutex_lock(&inode->i_mutex);
+		if (rpci->ops == NULL) {
+			mutex_unlock(&inode->i_mutex);
 			return -EPIPE;
+		}
 		len = rpci->pipelen;
 		if (filp->private_data) {
 			struct rpc_pipe_msg *msg;
 			msg = (struct rpc_pipe_msg *)filp->private_data;
 			len += msg->len - msg->copied;
 		}
+		mutex_unlock(&inode->i_mutex);
 		return put_user(len, (int __user *)arg);
 	default:
 		return -EINVAL;
@@ -337,7 +341,7 @@ static const struct file_operations rpc_
 	.read		= rpc_pipe_read,
 	.write		= rpc_pipe_write,
 	.poll		= rpc_pipe_poll,
-	.ioctl		= rpc_pipe_ioctl,
+	.unlocked_ioctl	= rpc_pipe_ioctl,
 	.open		= rpc_pipe_open,
 	.release	= rpc_pipe_release,
 };
Index: linux-2.6-tip/net/sunrpc/svc_xprt.c
===================================================================
--- linux-2.6-tip.orig/net/sunrpc/svc_xprt.c
+++ linux-2.6-tip/net/sunrpc/svc_xprt.c
@@ -5,7 +5,6 @@
  */
 
 #include <linux/sched.h>
-#include <linux/smp_lock.h>
 #include <linux/errno.h>
 #include <linux/freezer.h>
 #include <linux/kthread.h>
