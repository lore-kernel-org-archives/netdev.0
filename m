From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Use unlocked_ioctl for sock_ioctl
Date: Mon, 17 Jan 2005 23:23:35 +0100
Message-ID: <20050117222335.GC10882@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Now that unlocked_ioctl has been merged use it for sock_ioctl.

Signed-off-by: Andi Kleen <ak@suse.de>

diff -u linux-2.6.11-rc1-bk4/net/socket.c-o linux-2.6.11-rc1-bk4/net/socket.c
--- linux-2.6.11-rc1-bk4/net/socket.c-o	2005-01-17 10:39:43.000000000 +0100
+++ linux-2.6.11-rc1-bk4/net/socket.c	2005-01-17 14:24:21.000000000 +0100
@@ -104,7 +104,7 @@
 static int sock_close(struct inode *inode, struct file *file);
 static unsigned int sock_poll(struct file *file,
 			      struct poll_table_struct *wait);
-static int sock_ioctl(struct inode *inode, struct file *file,
+static long sock_ioctl(struct file *file,
 		      unsigned int cmd, unsigned long arg);
 static int sock_fasync(int fd, struct file *filp, int on);
 static ssize_t sock_readv(struct file *file, const struct iovec *vector,
@@ -126,7 +126,7 @@
 	.aio_read =	sock_aio_read,
 	.aio_write =	sock_aio_write,
 	.poll =		sock_poll,
-	.ioctl =	sock_ioctl,
+	.unlocked_ioctl = sock_ioctl,
 	.mmap =		sock_mmap,
 	.open =		sock_no_open,	/* special open code to disallow open via /proc */
 	.release =	sock_close,
@@ -829,15 +829,13 @@
  *	what to do with it - that's up to the protocol still.
  */
 
-static int sock_ioctl(struct inode *inode, struct file *file, unsigned int cmd,
-		      unsigned long arg)
+static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 {
 	struct socket *sock;
 	void __user *argp = (void __user *)arg;
 	int pid, err;
 
-	unlock_kernel();
-	sock = SOCKET_I(inode);
+	sock = SOCKET_I(file->f_dentry->d_inode);
 	if (cmd >= SIOCDEVPRIVATE && cmd <= (SIOCDEVPRIVATE + 15)) {
 		err = dev_ioctl(cmd, argp);
 	} else
@@ -903,8 +901,6 @@
 			err = sock->ops->ioctl(sock, cmd, arg);
 			break;
 	}
-	lock_kernel();
-
 	return err;
 }
 
