From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 1/4 - 2.6.15 ]net : 32 bit (socket layer) ioctl emulation
	for 64 bit kernels
Date: Tue, 17 Jan 2006 10:11:09 +1100
Message-ID: <1137453069.6553.17.camel@spereira05.tusc.com.au>
References: <1137122079.5589.34.camel@spereira05.tusc.com.au>
	 <1137391160.5588.32.camel@spereira05.tusc.com.au>
	 <20060116.154106.64415709.yoshfuji@linux-ipv6.org>
	 <200601161043.31742.arnd@arndb.de>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?=
	 =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>,
	acme@ghostprotocols.net, ak@muc.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pereira.shaun@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751031AbWAPXNR@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200601161043.31742.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
Here are the corrected patches
/Shaun

diff -uprN -X dontdiff linux-2.6.15-vanilla/include/linux/net.h
linux-2.6.15/include/linux/net.h
--- linux-2.6.15-vanilla/include/linux/net.h	2006-01-03
14:21:10.000000000 +1100
+++ linux-2.6.15/include/linux/net.h	2006-01-17 09:43:56.000000000 +1100
@@ -143,6 +143,8 @@ struct proto_ops {
 				      struct poll_table_struct *wait);
 	int		(*ioctl)     (struct socket *sock, unsigned int cmd,
 				      unsigned long arg);
+	int	 	(*compat_ioctl) (struct socket *sock, unsigned int cmd,
+				      unsigned long arg);
 	int		(*listen)    (struct socket *sock, int len);
 	int		(*shutdown)  (struct socket *sock, int flags);
 	int		(*setsockopt)(struct socket *sock, int level,
@@ -247,6 +249,8 @@ SOCKCALL_UWRAP(name, poll, (struct file 
 	      (file, sock, wait)) \
 SOCKCALL_WRAP(name, ioctl, (struct socket *sock, unsigned int cmd, \
 			 unsigned long arg), (sock, cmd, arg)) \
+SOCKCALL_WRAP(name, compat_ioctl, (struct socket *sock, unsigned int
cmd, \
+			 unsigned long arg), (sock, cmd, arg)) \
 SOCKCALL_WRAP(name, listen, (struct socket *sock, int len), (sock,
len)) \
 SOCKCALL_WRAP(name, shutdown, (struct socket *sock, int flags), (sock,
flags)) \
 SOCKCALL_WRAP(name, setsockopt, (struct socket *sock, int level, int
optname, \
@@ -271,6 +275,7 @@ static struct proto_ops name##_ops = {		
 	.getname	= __lock_##name##_getname,	\
 	.poll		= __lock_##name##_poll,		\
 	.ioctl		= __lock_##name##_ioctl,	\
+	.compat_ioctl	= __lock_##name##_compat_ioctl,	\
 	.listen		= __lock_##name##_listen,	\
 	.shutdown	= __lock_##name##_shutdown,	\
 	.setsockopt	= __lock_##name##_setsockopt,	\
@@ -279,6 +284,7 @@ static struct proto_ops name##_ops = {		
 	.recvmsg	= __lock_##name##_recvmsg,	\
 	.mmap		= __lock_##name##_mmap,		\
 };
+
 #endif
 
 #define MODULE_ALIAS_NETPROTO(proto) \
diff -uprN -X dontdiff linux-2.6.15-vanilla/net/socket.c
linux-2.6.15/net/socket.c
--- linux-2.6.15-vanilla/net/socket.c	2006-01-03 14:21:10.000000000
+1100
+++ linux-2.6.15/net/socket.c	2006-01-17 09:43:56.000000000 +1100
@@ -109,6 +109,10 @@ static unsigned int sock_poll(struct fil
 			      struct poll_table_struct *wait);
 static long sock_ioctl(struct file *file,
 		      unsigned int cmd, unsigned long arg);
+#ifdef CONFIG_COMPAT
+static long compat_sock_ioctl(struct file *file,
+		      unsigned int cmd, unsigned long arg);
+#endif
 static int sock_fasync(int fd, struct file *filp, int on);
 static ssize_t sock_readv(struct file *file, const struct iovec
*vector,
 			  unsigned long count, loff_t *ppos);
@@ -130,6 +134,9 @@ static struct file_operations socket_fil
 	.aio_write =	sock_aio_write,
 	.poll =		sock_poll,
 	.unlocked_ioctl = sock_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl = compat_sock_ioctl,
+#endif
 	.mmap =		sock_mmap,
 	.open =		sock_no_open,	/* special open code to disallow open via /proc
*/
 	.release =	sock_close,
@@ -2084,6 +2091,20 @@ void socket_seq_show(struct seq_file *se
 }
 #endif /* CONFIG_PROC_FS */
 
+#ifdef CONFIG_COMPAT
+static long compat_sock_ioctl(struct file *file, unsigned cmd, unsigned
long arg)
+{
+	struct socket *sock;
+	sock = file->private_data;
+
+	int ret = -ENOIOCTLCMD;
+	if(sock->ops->compat_ioctl)
+		ret = sock->ops->compat_ioctl(sock, cmd, arg);
+
+	return ret;
+}
+#endif
+
 /* ABI emulation layers need these two */
 EXPORT_SYMBOL(move_addr_to_kernel);
 EXPORT_SYMBOL(move_addr_to_user);
