From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Fri, 9 Aug 2002 03:26:10 +1000 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0208090320010.20027-100000@blackbird.intercode.com.au>
References: <20020808181717.P24631@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20020808181717.P24631@parcelfarce.linux.theplanet.co.uk>
List-Id: netdev.vger.kernel.org

On Thu, 8 Aug 2002, Matthew Wilcox wrote:

> On Thu, Aug 08, 2002 at 09:13:15PM +0400, kuznet@ms2.inr.ac.ru wrote:
> > No, this is not true. This creepy ioctl is specific to TCP
> > (well, x.25 also uses SIGURG), which use kill*(sk->proc, SIGURG) directly.
> > 
> > Probably, it is better to move sk->proc to TCP private data,
> > this ioctl to tcp_ioctl(). Or... find a way to get rid of this completely,
> > not breaking compatibility with a few BSDish applications.
> 
> jamesm also has patches which remove sk->proc altogether and make TCP
> use the normal fasync methods.  this ioctl then does an f_setown and
> most of the creepiness is gone.  consider this patch a stepping-stone.
> 

Yes, this patch is complete (see below), but is waiting on another fix to
go in (which I sent you recently).  The unification of the ioctl code also
now means SIOCSPGRP works exactly the same as F_SETOWN (i.e. it also works
now for sigio).


- James
-- 
James Morris
<jmorris@intercode.com.au>

diff -urN -X dontdiff linux-2.5.27.orig/drivers/char/tty_io.c linux-2.5.27.w1/drivers/char/tty_io.c
--- linux-2.5.27.orig/drivers/char/tty_io.c	Wed Jul 17 19:10:44 2002
+++ linux-2.5.27.w1/drivers/char/tty_io.c	Sun Jul 28 03:12:50 2002
@@ -1457,11 +1457,8 @@
 	if (on) {
 		if (!waitqueue_active(&tty->read_wait))
 			tty->minimum_to_wake = 1;
-		if (filp->f_owner.pid == 0) {
-			filp->f_owner.pid = (-tty->pgrp) ? : current->pid;
-			filp->f_owner.uid = current->uid;
-			filp->f_owner.euid = current->euid;
-		}
+		if (filp->f_owner.pid == 0)
+			f_setown(filp, (-tty->pgrp) ? : current->pid);
 	} else {
 		if (!tty->fasync && !waitqueue_active(&tty->read_wait))
 			tty->minimum_to_wake = N_TTY_BUF_SIZE;
diff -urN -X dontdiff linux-2.5.27.orig/drivers/net/tun.c linux-2.5.27.w1/drivers/net/tun.c
--- linux-2.5.27.orig/drivers/net/tun.c	Fri Jun 21 13:12:48 2002
+++ linux-2.5.27.w1/drivers/net/tun.c	Sun Jul 28 03:30:05 2002
@@ -514,11 +514,8 @@
  
 	if (on) {
 		tun->flags |= TUN_FASYNC;
-		if (!file->f_owner.pid) {
-			file->f_owner.pid  = current->pid;
-			file->f_owner.uid  = current->uid;
-			file->f_owner.euid = current->euid;
-		}
+		if (!file->f_owner.pid)
+			f_setown(file, current->pid);
 	} else 
 		tun->flags &= ~TUN_FASYNC;
 
diff -urN -X dontdiff linux-2.5.27.orig/fs/Makefile linux-2.5.27.w1/fs/Makefile
--- linux-2.5.27.orig/fs/Makefile	Wed Jul 17 19:10:45 2002
+++ linux-2.5.27.w1/fs/Makefile	Sun Jul 28 03:24:30 2002
@@ -8,7 +8,7 @@
 O_TARGET := fs.o
 
 export-objs :=	filesystems.o open.o dcache.o buffer.o bio.o inode.o dquot.o \
-		mpage.o
+		mpage.o fcntl.o
 
 obj-y :=	open.o read_write.o devices.o file_table.o buffer.o \
 		bio.o super.o block_dev.o char_dev.o stat.o exec.o pipe.o \
diff -urN -X dontdiff linux-2.5.27.orig/fs/dnotify.c linux-2.5.27.w1/fs/dnotify.c
--- linux-2.5.27.orig/fs/dnotify.c	Tue Jun 18 01:20:45 2002
+++ linux-2.5.27.w1/fs/dnotify.c	Sun Jul 28 03:12:11 2002
@@ -93,9 +93,7 @@
 		}
 		prev = &odn->dn_next;
 	}
-	filp->f_owner.pid = current->pid;
-	filp->f_owner.uid = current->uid;
-	filp->f_owner.euid = current->euid;
+	f_setown(filp, current->pid);
 	dn->dn_mask = arg;
 	dn->dn_fd = fd;
 	dn->dn_filp = filp;
diff -urN -X dontdiff linux-2.5.27.orig/fs/fcntl.c linux-2.5.27.w1/fs/fcntl.c
--- linux-2.5.27.orig/fs/fcntl.c	Sun Jul 21 10:57:51 2002
+++ linux-2.5.27.w1/fs/fcntl.c	Sun Jul 28 18:23:03 2002
@@ -11,12 +11,12 @@
 #include <linux/smp_lock.h>
 #include <linux/slab.h>
 #include <linux/iobuf.h>
+#include <linux/module.h>
 
 #include <asm/poll.h>
 #include <asm/siginfo.h>
 #include <asm/uaccess.h>
 
-extern int sock_fcntl (struct file *, unsigned int cmd, unsigned long arg);
 extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
@@ -259,6 +259,18 @@
 	return 0;
 }
 
+long f_getown(struct file *filp)
+{
+	return filp->f_owner.pid;
+}
+
+void f_setown(struct file *filp, unsigned long arg)
+{
+	filp->f_owner.pid = arg;
+	filp->f_owner.uid = current->uid;
+	filp->f_owner.euid = current->euid;
+}
+
 static long do_fcntl(unsigned int fd, unsigned int cmd,
 		     unsigned long arg, struct file * filp)
 {
@@ -301,16 +313,12 @@
 			 * current syscall conventions, the only way
 			 * to fix this will be in libc.
 			 */
-			err = filp->f_owner.pid;
+			err = f_getown(filp);
 			break;
 		case F_SETOWN:
-			lock_kernel();
-			filp->f_owner.pid = arg;
-			filp->f_owner.uid = current->uid;
-			filp->f_owner.euid = current->euid;
 			err = 0;
-			if (S_ISSOCK (filp->f_dentry->d_inode->i_mode))
-				err = sock_fcntl (filp, F_SETOWN, arg);
+			lock_kernel();
+			f_setown(filp, arg);
 			unlock_kernel();
 			break;
 		case F_GETSIG:
@@ -334,10 +342,6 @@
 			err = fcntl_dirnotify(fd, filp, arg);
 			break;
 		default:
-			/* sockets need a few special fcntls. */
-			err = -EINVAL;
-			if (S_ISSOCK (filp->f_dentry->d_inode->i_mode))
-				err = sock_fcntl (filp, cmd, arg);
 			break;
 	}
 
@@ -400,15 +404,22 @@
 	POLLHUP | POLLERR			/* POLL_HUP */
 };
 
+static inline int sigio_perm(struct task_struct *p,
+                             struct fown_struct *fown)
+{
+	return ((fown->euid == 0) ||
+	        (fown->euid == p->suid) || (fown->euid == p->uid) ||
+	        (fown->uid == p->suid) || (fown->uid == p->uid));
+}
+
 static void send_sigio_to_task(struct task_struct *p,
 			       struct fown_struct *fown, 
 			       int fd,
 			       int reason)
 {
-	if ((fown->euid != 0) &&
-	    (fown->euid ^ p->suid) && (fown->euid ^ p->uid) &&
-	    (fown->uid ^ p->suid) && (fown->uid ^ p->uid))
+	if (!sigio_perm(p, fown))
 		return;
+
 	switch (fown->signum) {
 		siginfo_t si;
 		default:
@@ -461,6 +472,35 @@
 	read_unlock(&tasklist_lock);
 }
 
+static void send_sigurg_to_task(struct task_struct *p,
+                                struct fown_struct *fown)
+{
+	if (sigio_perm(p, fown))
+		send_sig(SIGURG, p, 1);
+}
+
+void send_sigurg(struct fown_struct *fown)
+{
+	struct task_struct *p;
+	int pid	= fown->pid;
+
+	read_lock(&tasklist_lock);
+	if ((pid > 0) && (p = find_task_by_pid(pid))) {
+		send_sigurg_to_task(p, fown);
+		goto out;
+	}
+	for_each_task(p) {
+		int match = p->pid;
+		if (pid < 0)
+			match = -p->pgrp;
+		if (pid != match)
+			continue;
+		send_sigurg_to_task(p, fown);
+	}
+out:
+	read_unlock(&tasklist_lock);
+}
+
 static rwlock_t fasync_lock = RW_LOCK_UNLOCKED;
 static kmem_cache_t *fasync_cache;
 
@@ -544,3 +584,5 @@
 }
 
 module_init(fasync_init)
+
+EXPORT_SYMBOL(f_setown);
diff -urN -X dontdiff linux-2.5.27.orig/fs/locks.c linux-2.5.27.w1/fs/locks.c
--- linux-2.5.27.orig/fs/locks.c	Sat Jul  6 11:01:01 2002
+++ linux-2.5.27.w1/fs/locks.c	Sun Jul 28 18:23:18 2002
@@ -1309,9 +1309,7 @@
 	fl->fl_next = *before;
 	*before = fl;
 	list_add(&fl->fl_link, &file_lock_list);
-	filp->f_owner.pid = current->pid;
-	filp->f_owner.uid = current->uid;
-	filp->f_owner.euid = current->euid;
+	f_setown(filp, current->pid);
 out_unlock:
 	unlock_kernel();
 	return error;
diff -urN -X dontdiff linux-2.5.27.orig/include/linux/fs.h linux-2.5.27.w1/include/linux/fs.h
--- linux-2.5.27.orig/include/linux/fs.h	Sun Jul 21 10:57:51 2002
+++ linux-2.5.27.w1/include/linux/fs.h	Sun Jul 28 18:22:10 2002
@@ -604,6 +604,10 @@
 /* only for net: no internal synchronization */
 extern void __kill_fasync(struct fasync_struct *, int, int);
 
+extern void send_sigurg(struct fown_struct *fown);
+extern long f_getown(struct file *filp);
+extern void f_setown(struct file *filp, unsigned long arg);
+
 /*
  *	Umount options
  */
diff -urN -X dontdiff linux-2.5.27.orig/include/net/inet_common.h linux-2.5.27.w1/include/net/inet_common.h
--- linux-2.5.27.orig/include/net/inet_common.h	Tue Aug 24 03:01:02 1999
+++ linux-2.5.27.w1/include/net/inet_common.h	Sat Jul 27 01:40:08 2002
@@ -34,9 +34,6 @@
 extern int			inet_getsockopt(struct socket *sock, int level,
 						int optname, char *optval, 
 						int *optlen);
-extern int			inet_fcntl(struct socket *sock, 
-					   unsigned int cmd, 
-					   unsigned long arg);
 extern int			inet_listen(struct socket *sock, int backlog);
 
 extern void			inet_sock_release(struct sock *sk);
diff -urN -X dontdiff linux-2.5.27.orig/include/net/sock.h linux-2.5.27.w1/include/net/sock.h
--- linux-2.5.27.orig/include/net/sock.h	Tue Jun 18 01:19:54 2002
+++ linux-2.5.27.w1/include/net/sock.h	Sat Jul 27 01:40:08 2002
@@ -132,7 +132,6 @@
 	unsigned char		rcvtstamp;
 	/* Hole of 1 byte. Try to pack. */
 	int			route_caps;
-	int			proc;
 	unsigned long	        lingertime;
 
 	int			hashent;
@@ -362,6 +361,7 @@
 						      int *errcode);
 extern void *sock_kmalloc(struct sock *sk, int size, int priority);
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
+extern int sk_send_sigurg(struct sock *sk);
 
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
diff -urN -X dontdiff linux-2.5.27.orig/kernel/futex.c linux-2.5.27.w1/kernel/futex.c
--- linux-2.5.27.orig/kernel/futex.c	Wed Jul 17 19:10:45 2002
+++ linux-2.5.27.w1/kernel/futex.c	Sun Jul 28 15:02:28 2002
@@ -276,9 +276,7 @@
 	filp->f_dentry = dget(futex_mnt->mnt_root);
 
 	if (signal) {
-		filp->f_owner.pid = current->tgid;
-		filp->f_owner.uid = current->uid;
-		filp->f_owner.euid = current->euid;
+		f_setown(filp, current->tgid);
 		filp->f_owner.signum = signal;
 	}
 
diff -urN -X dontdiff linux-2.5.27.orig/net/core/sock.c linux-2.5.27.w1/net/core/sock.c
--- linux-2.5.27.orig/net/core/sock.c	Tue Jun 18 01:20:53 2002
+++ linux-2.5.27.w1/net/core/sock.c	Sun Jul 28 15:02:53 2002
@@ -1048,34 +1048,6 @@
 	return -EOPNOTSUPP;
 }
 
-/* 
- * Note: if you add something that sleeps here then change sock_fcntl()
- *       to do proper fd locking.
- */
-int sock_no_fcntl(struct socket *sock, unsigned int cmd, unsigned long arg)
-{
-	struct sock *sk = sock->sk;
-
-	switch(cmd)
-	{
-		case F_SETOWN:
-			/*
-			 * This is a little restrictive, but it's the only
-			 * way to make sure that you can't send a sigurg to
-			 * another process.
-			 */
-			if (current->pgrp != -arg &&
-				current->pid != arg &&
-				!capable(CAP_KILL)) return(-EPERM);
-			sk->proc = arg;
-			return(0);
-		case F_GETOWN:
-			return(sk->proc);
-		default:
-			return(-EINVAL);
-	}
-}
-
 int sock_no_sendmsg(struct socket *sock, struct msghdr *m, int flags,
 		    struct scm_cookie *scm)
 {
@@ -1177,6 +1149,15 @@
 {
 	if (sk->protinfo)
 		kfree(sk->protinfo);
+}
+
+int sk_send_sigurg(struct sock *sk)
+{
+	if (sk->socket && sk->socket->file && sk->socket->file->f_owner.pid) {
+		send_sigurg(&sk->socket->file->f_owner);
+		return 1;
+	}
+	return 0;
 }
 
 void sock_init_data(struct socket *sock, struct sock *sk)
diff -urN -X dontdiff linux-2.5.27.orig/net/econet/af_econet.c linux-2.5.27.w1/net/econet/af_econet.c
--- linux-2.5.27.orig/net/econet/af_econet.c	Tue Jun 18 01:19:54 2002
+++ linux-2.5.27.w1/net/econet/af_econet.c	Sun Jul 28 21:54:52 2002
@@ -643,21 +643,9 @@
 static int econet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	int pid;
 
 	switch(cmd) 
 	{
-		case FIOSETOWN:
-		case SIOCSPGRP:
-			if (get_user(pid, (int *) arg))
-				return -EFAULT; 
-			if (current->pid != pid && current->pgrp != -pid && !capable(CAP_NET_ADMIN))
-				return -EPERM;
-			sk->proc = pid;
-			return(0);
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			return put_user(sk->proc, (int *)arg);
 		case SIOCGSTAMP:
 			if(sk->stamp.tv_sec==0)
 				return -ENOENT;
diff -urN -X dontdiff linux-2.5.27.orig/net/ipv4/af_inet.c linux-2.5.27.w1/net/ipv4/af_inet.c
--- linux-2.5.27.orig/net/ipv4/af_inet.c	Tue Jun 18 01:21:13 2002
+++ linux-2.5.27.w1/net/ipv4/af_inet.c	Sun Jul 28 22:01:28 2002
@@ -850,24 +850,8 @@
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
-	int pid;
 
 	switch (cmd) {
-		case FIOSETOWN:
-		case SIOCSPGRP:
-			if (get_user(pid, (int *)arg))
-				err = -EFAULT;
-			else if (current->pid != pid &&
-				 current->pgrp != -pid &&
-				!capable(CAP_NET_ADMIN))
-				err = -EPERM;
-			else
-				sk->proc = pid;
-			break;
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			err = put_user(sk->proc, (int *)arg);
-			break;
 		case SIOCGSTAMP:
 			if (!sk->stamp.tv_sec)
 				err = -ENOENT;
diff -urN -X dontdiff linux-2.5.27.orig/net/ipv4/tcp_input.c linux-2.5.27.w1/net/ipv4/tcp_input.c
--- linux-2.5.27.orig/net/ipv4/tcp_input.c	Tue Jun 18 01:20:53 2002
+++ linux-2.5.27.w1/net/ipv4/tcp_input.c	Sat Jul 27 01:40:08 2002
@@ -3093,13 +3093,8 @@
 		return;
 
 	/* Tell the world about our new urgent pointer. */
-	if (sk->proc != 0) {
-		if (sk->proc > 0)
-			kill_proc(sk->proc, SIGURG, 1);
-		else
-			kill_pg(-sk->proc, SIGURG, 1);
+	if (sk_send_sigurg(sk))
 		sk_wake_async(sk, 3, POLL_PRI);
-	}
 
 	/* We may be adding urgent data when the last byte read was
 	 * urgent. To do this requires some care. We cannot just ignore
diff -urN -X dontdiff linux-2.5.27.orig/net/ipv4/tcp_minisocks.c linux-2.5.27.w1/net/ipv4/tcp_minisocks.c
--- linux-2.5.27.orig/net/ipv4/tcp_minisocks.c	Tue Jun 18 01:19:54 2002
+++ linux-2.5.27.w1/net/ipv4/tcp_minisocks.c	Sat Jul 27 01:40:08 2002
@@ -676,7 +676,6 @@
 
 		newsk->done = 0;
 		newsk->userlocks = sk->userlocks & ~SOCK_BINDPORT_LOCK;
-		newsk->proc = 0;
 		newsk->backlog.head = newsk->backlog.tail = NULL;
 		newsk->callback_lock = RW_LOCK_UNLOCKED;
 		skb_queue_head_init(&newsk->error_queue);
diff -urN -X dontdiff linux-2.5.27.orig/net/ipv6/af_inet6.c linux-2.5.27.w1/net/ipv6/af_inet6.c
--- linux-2.5.27.orig/net/ipv6/af_inet6.c	Fri Jun 21 13:12:48 2002
+++ linux-2.5.27.w1/net/ipv6/af_inet6.c	Sun Jul 28 22:06:54 2002
@@ -455,23 +455,9 @@
 {
 	struct sock *sk = sock->sk;
 	int err = -EINVAL;
-	int pid;
 
 	switch(cmd) 
 	{
-	case FIOSETOWN:
-	case SIOCSPGRP:
-		if (get_user(pid, (int *) arg))
-			return -EFAULT;
-		/* see sock_no_fcntl */
-		if (current->pid != pid && current->pgrp != -pid && 
-		    !capable(CAP_NET_ADMIN))
-			return -EPERM;
-		sk->proc = pid;
-		return(0);
-	case FIOGETOWN:
-	case SIOCGPGRP:
-		return put_user(sk->proc,(int *)arg);
 	case SIOCGSTAMP:
 		if(sk->stamp.tv_sec==0)
 			return -ENOENT;
diff -urN -X dontdiff linux-2.5.27.orig/net/packet/af_packet.c linux-2.5.27.w1/net/packet/af_packet.c
--- linux-2.5.27.orig/net/packet/af_packet.c	Tue Jun 18 01:19:54 2002
+++ linux-2.5.27.w1/net/packet/af_packet.c	Sun Jul 28 22:03:07 2002
@@ -1458,20 +1458,6 @@
 			spin_unlock_bh(&sk->receive_queue.lock);
 			return put_user(amount, (int *)arg);
 		}
-		case FIOSETOWN:
-		case SIOCSPGRP: {
-			int pid;
-			if (get_user(pid, (int *) arg))
-				return -EFAULT; 
-			if (current->pid != pid && current->pgrp != -pid && 
-			    !capable(CAP_NET_ADMIN))
-				return -EPERM;
-			sk->proc = pid;
-			break;
-		}
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			return put_user(sk->proc, (int *)arg);
 		case SIOCGSTAMP:
 			if(sk->stamp.tv_sec==0)
 				return -ENOENT;
diff -urN -X dontdiff linux-2.5.27.orig/net/socket.c linux-2.5.27.w1/net/socket.c
--- linux-2.5.27.orig/net/socket.c	Sat Jul  6 11:01:02 2002
+++ linux-2.5.27.w1/net/socket.c	Sun Jul 28 22:08:37 2002
@@ -674,20 +674,36 @@
 				 file, vector, count, tot_len);
 }
 
-/*
- *	With an ioctl arg may well be a user mode pointer, but we don't know what to do
- *	with it - that's up to the protocol still.
- */
-
 int sock_ioctl(struct inode *inode, struct file *file, unsigned int cmd,
 	   unsigned long arg)
 {
 	struct socket *sock;
-	int err;
+	int err = 0;
+	int pid;
 
 	unlock_kernel();
 	sock = SOCKET_I(inode);
-	err = sock->ops->ioctl(sock, cmd, arg);
+	
+	switch(cmd) {
+	case FIOSETOWN:
+	case SIOCSPGRP:
+		if (get_user(pid, (int *)arg))
+			err = -EFAULT;
+		else
+			f_setown(sock->file, pid);
+		break;
+		
+	case FIOGETOWN:
+	case SIOCGPGRP:
+		pid = f_getown(sock->file);
+		err = put_user(pid, (int *)arg);
+		break;
+
+	default:
+		err = sock->ops->ioctl(sock, cmd, arg);
+	
+	}
+	
 	lock_kernel();
 
 	return err;
@@ -1514,24 +1530,6 @@
 	sockfd_put(sock);
 out:
 	return err;
-}
-
-
-/*
- *	Perform a file control on a socket file descriptor.
- *
- *	Doesn't acquire a fd lock, because no network fcntl
- *	function sleeps currently.
- */
-
-int sock_fcntl(struct file *filp, unsigned int cmd, unsigned long arg)
-{
-	struct socket *sock;
-
-	sock = SOCKET_I (filp->f_dentry->d_inode);
-	if (sock && sock->ops)
-		return sock_no_fcntl(sock, cmd, arg);
-	return(-EINVAL);
 }
 
 /* Argument list sizes for sys_socketcall */
diff -urN -X dontdiff linux-2.5.27.orig/net/wanrouter/af_wanpipe.c linux-2.5.27.w1/net/wanrouter/af_wanpipe.c
--- linux-2.5.27.orig/net/wanrouter/af_wanpipe.c	Tue Jun 18 01:19:39 2002
+++ linux-2.5.27.w1/net/wanrouter/af_wanpipe.c	Sun Jul 28 21:56:01 2002
@@ -1867,23 +1867,9 @@
 {
 	struct sock *sk = sock->sk;
 	int err;
-	int pid;
 
 	switch(cmd) 
 	{
-		case FIOSETOWN:
-		case SIOCSPGRP:
-			err = get_user(pid, (int *) arg);
-			if (err)
-				return err; 
-			if (current->pid != pid && current->pgrp != -pid && 
-			    !capable(CAP_NET_ADMIN))
-				return -EPERM;
-			sk->proc = pid;
-			return(0);
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			return put_user(sk->proc, (int *)arg);
 		case SIOCGSTAMP:
 			if(sk->stamp.tv_sec==0)
 				return -ENOENT;
diff -urN -X dontdiff linux-2.5.27.orig/net/x25/x25_in.c linux-2.5.27.w1/net/x25/x25_in.c
--- linux-2.5.27.orig/net/x25/x25_in.c	Tue Jun 18 01:19:10 2002
+++ linux-2.5.27.w1/net/x25/x25_in.c	Sat Jul 27 01:40:08 2002
@@ -283,13 +283,8 @@
 				skb_queue_tail(&x25->interrupt_in_queue, skb);
 				queued = 1;
 			}
-			if (sk->proc != 0) {
-				if (sk->proc > 0)
-					kill_proc(sk->proc, SIGURG, 1);
-				else
-					kill_pg(-sk->proc, SIGURG, 1);
+			if (sk_send_sigurg(sk))
 				sock_wake_async(sk->socket, 3, POLL_PRI);
-			}
 			x25_write_internal(sk, X25_INTERRUPT_CONFIRMATION);
 			break;
 
