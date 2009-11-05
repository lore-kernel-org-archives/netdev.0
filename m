From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 5/5] net: kill proto_ops wrapper
Date: Thu,  5 Nov 2009 15:37:30 +0100
Message-ID: <1257431850-20874-6-git-send-email-arnd@arndb.de>
References: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, John Kacur <jkacur@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757545AbZKEOiD@vger.kernel.org>
In-Reply-To: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All users of wrapped proto_ops are now gone, so we can safely remove
the wrappers as well.

Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/net.h |   83 ---------------------------------------------------
 1 files changed, 0 insertions(+), 83 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 529a093..041a8e4 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -263,89 +263,6 @@ extern int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
 extern int kernel_sock_shutdown(struct socket *sock,
 				enum sock_shutdown_cmd how);
 
-#ifndef CONFIG_SMP
-#define SOCKOPS_WRAPPED(name) name
-#define SOCKOPS_WRAP(name, fam)
-#else
-
-#define SOCKOPS_WRAPPED(name) __unlocked_##name
-
-#define SOCKCALL_WRAP(name, call, parms, args)		\
-static int __lock_##name##_##call  parms		\
-{							\
-	int ret;					\
-	lock_kernel();					\
-	ret = __unlocked_##name##_ops.call  args ;\
-	unlock_kernel();				\
-	return ret;					\
-}
-
-#define SOCKCALL_UWRAP(name, call, parms, args)		\
-static unsigned int __lock_##name##_##call  parms	\
-{							\
-	int ret;					\
-	lock_kernel();					\
-	ret = __unlocked_##name##_ops.call  args ;\
-	unlock_kernel();				\
-	return ret;					\
-}
-
-
-#define SOCKOPS_WRAP(name, fam)					\
-SOCKCALL_WRAP(name, release, (struct socket *sock), (sock))	\
-SOCKCALL_WRAP(name, bind, (struct socket *sock, struct sockaddr *uaddr, int addr_len), \
-	      (sock, uaddr, addr_len))				\
-SOCKCALL_WRAP(name, connect, (struct socket *sock, struct sockaddr * uaddr, \
-			      int addr_len, int flags), 	\
-	      (sock, uaddr, addr_len, flags))			\
-SOCKCALL_WRAP(name, socketpair, (struct socket *sock1, struct socket *sock2), \
-	      (sock1, sock2))					\
-SOCKCALL_WRAP(name, accept, (struct socket *sock, struct socket *newsock, \
-			 int flags), (sock, newsock, flags)) \
-SOCKCALL_WRAP(name, getname, (struct socket *sock, struct sockaddr *uaddr, \
-			 int *addr_len, int peer), (sock, uaddr, addr_len, peer)) \
-SOCKCALL_UWRAP(name, poll, (struct file *file, struct socket *sock, struct poll_table_struct *wait), \
-	      (file, sock, wait)) \
-SOCKCALL_WRAP(name, ioctl, (struct socket *sock, unsigned int cmd, \
-			 unsigned long arg), (sock, cmd, arg)) \
-SOCKCALL_WRAP(name, compat_ioctl, (struct socket *sock, unsigned int cmd, \
-			 unsigned long arg), (sock, cmd, arg)) \
-SOCKCALL_WRAP(name, listen, (struct socket *sock, int len), (sock, len)) \
-SOCKCALL_WRAP(name, shutdown, (struct socket *sock, int flags), (sock, flags)) \
-SOCKCALL_WRAP(name, setsockopt, (struct socket *sock, int level, int optname, \
-			 char __user *optval, unsigned int optlen), (sock, level, optname, optval, optlen)) \
-SOCKCALL_WRAP(name, getsockopt, (struct socket *sock, int level, int optname, \
-			 char __user *optval, int __user *optlen), (sock, level, optname, optval, optlen)) \
-SOCKCALL_WRAP(name, sendmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, size_t len), \
-	      (iocb, sock, m, len)) \
-SOCKCALL_WRAP(name, recvmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, size_t len, int flags), \
-	      (iocb, sock, m, len, flags)) \
-SOCKCALL_WRAP(name, mmap, (struct file *file, struct socket *sock, struct vm_area_struct *vma), \
-	      (file, sock, vma)) \
-	      \
-static const struct proto_ops name##_ops = {			\
-	.family		= fam,				\
-	.owner		= THIS_MODULE,			\
-	.release	= __lock_##name##_release,	\
-	.bind		= __lock_##name##_bind,		\
-	.connect	= __lock_##name##_connect,	\
-	.socketpair	= __lock_##name##_socketpair,	\
-	.accept		= __lock_##name##_accept,	\
-	.getname	= __lock_##name##_getname,	\
-	.poll		= __lock_##name##_poll,		\
-	.ioctl		= __lock_##name##_ioctl,	\
-	.compat_ioctl	= __lock_##name##_compat_ioctl,	\
-	.listen		= __lock_##name##_listen,	\
-	.shutdown	= __lock_##name##_shutdown,	\
-	.setsockopt	= __lock_##name##_setsockopt,	\
-	.getsockopt	= __lock_##name##_getsockopt,	\
-	.sendmsg	= __lock_##name##_sendmsg,	\
-	.recvmsg	= __lock_##name##_recvmsg,	\
-	.mmap		= __lock_##name##_mmap,		\
-};
-
-#endif
-
 #define MODULE_ALIAS_NETPROTO(proto) \
 	MODULE_ALIAS("net-pf-" __stringify(proto))
 
-- 
1.6.3.3
