From: Matthew Wilcox <willy@debian.org>
Subject: [PATCH] migrate ioctls upwards
Date: Fri, 27 Sep 2002 20:44:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927204428.B18377@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Move some of the common ioctls into net/socket.c from the various protocol
families.  Many more can be raised; this is just testing the waters.

diff -urpNX dontdiff linux-2.5.38/net/econet/af_econet.c linux-2.5.38-willy/net/econet/af_econet.c
--- linux-2.5.38/net/econet/af_econet.c	2002-09-09 14:27:27.000000000 -0400
+++ linux-2.5.38-willy/net/econet/af_econet.c	2002-09-27 13:42:46.000000000 -0400
@@ -643,51 +643,19 @@ static int ec_dev_ioctl(struct socket *s
 static int econet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	int pid;
 
-	switch(cmd) 
-	{
-		case FIOSETOWN:
-		case SIOCSPGRP:
-			if (get_user(pid, (int *) arg))
-				return -EFAULT; 
-			return f_setown(sock->file, pid, 1);
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			return put_user(sock->file->f_owner.pid, (int *)arg);
+	switch(cmd) {
 		case SIOCGSTAMP:
 			if(sk->stamp.tv_sec==0)
 				return -ENOENT;
 			return copy_to_user((void *)arg, &sk->stamp, sizeof(struct timeval)) ? -EFAULT : 0;
-		case SIOCGIFFLAGS:
-		case SIOCSIFFLAGS:
-		case SIOCGIFCONF:
-		case SIOCGIFMETRIC:
-		case SIOCSIFMETRIC:
-		case SIOCGIFMEM:
-		case SIOCSIFMEM:
-		case SIOCGIFMTU:
-		case SIOCSIFMTU:
-		case SIOCSIFLINK:
-		case SIOCGIFHWADDR:
-		case SIOCSIFHWADDR:
-		case SIOCSIFMAP:
-		case SIOCGIFMAP:
-		case SIOCSIFSLAVE:
-		case SIOCGIFSLAVE:
-		case SIOCGIFINDEX:
-		case SIOCGIFNAME:
-		case SIOCGIFCOUNT:
-		case SIOCSIFHWBROADCAST:
-			return(dev_ioctl(cmd,(void *) arg));
-
 		case SIOCSIFADDR:
 		case SIOCGIFADDR:
 			return ec_dev_ioctl(sock, cmd, (void *)arg);
 			break;
 
 		default:
-			return(dev_ioctl(cmd,(void *) arg));
+			return dev_ioctl(cmd,(void *) arg);
 	}
 	/*NOTREACHED*/
 	return 0;
diff -urpNX dontdiff linux-2.5.38/net/ipv4/af_inet.c linux-2.5.38-willy/net/ipv4/af_inet.c
--- linux-2.5.38/net/ipv4/af_inet.c	2002-09-09 14:27:27.000000000 -0400
+++ linux-2.5.38-willy/net/ipv4/af_inet.c	2002-09-27 14:25:25.000000000 -0400
@@ -117,9 +117,6 @@
 #ifdef CONFIG_NET_DIVERT
 #include <linux/divert.h>
 #endif /* CONFIG_NET_DIVERT */
-#if defined(CONFIG_NET_RADIO) || defined(CONFIG_NET_PCMCIA_RADIO)
-#include <linux/wireless.h>		/* Note : will define WIRELESS_EXT */
-#endif	/* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
 
 struct linux_mib net_statistics[NR_CPUS * 2];
 
@@ -850,20 +847,8 @@ int inet_ioctl(struct socket *sock, unsi
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
-	int pid;
 
 	switch (cmd) {
-		case FIOSETOWN:
-		case SIOCSPGRP:
-			if (get_user(pid, (int *)arg))
-				err = -EFAULT;
-			else
-				err = f_setown(sock->file, pid, 1);
-			break;
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			err = put_user(sock->file->f_owner.pid, (int *)arg);
-			break;
 		case SIOCGSTAMP:
 			if (!sk->stamp.tv_sec)
 				err = -ENOENT;
@@ -949,15 +934,6 @@ int inet_ioctl(struct socket *sock, unsi
 			err = -ENOPKG;
 			break;
 		default:
-			if (cmd >= SIOCDEVPRIVATE &&
-			    cmd <= (SIOCDEVPRIVATE + 15))
-				err = dev_ioctl(cmd, (void *)arg);
-			else
-#ifdef WIRELESS_EXT
-			if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
-				err = dev_ioctl(cmd, (void *)arg);
-			else
-#endif	/* WIRELESS_EXT */
 			if (!sk->prot->ioctl ||
 			    (err = sk->prot->ioctl(sk, cmd, arg)) ==
 			    					-ENOIOCTLCMD)
diff -urpNX dontdiff linux-2.5.38/net/ipv6/af_inet6.c linux-2.5.38-willy/net/ipv6/af_inet6.c
--- linux-2.5.38/net/ipv6/af_inet6.c	2002-09-09 14:27:27.000000000 -0400
+++ linux-2.5.38-willy/net/ipv6/af_inet6.c	2002-09-27 10:51:35.000000000 -0400
@@ -455,18 +455,9 @@ int inet6_ioctl(struct socket *sock, uns
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
-		return f_setown(sock->file, pid, 1);
-	case FIOGETOWN:
-	case SIOCGPGRP:
-		return put_user(sock->file->f_owner.pid, (int *)arg);
 	case SIOCGSTAMP:
 		if(sk->stamp.tv_sec==0)
 			return -ENOENT;
@@ -488,10 +479,6 @@ int inet6_ioctl(struct socket *sock, uns
 	case SIOCSIFDSTADDR:
 		return addrconf_set_dstaddr((void *) arg);
 	default:
-		if ((cmd >= SIOCDEVPRIVATE) &&
-		    (cmd <= (SIOCDEVPRIVATE + 15)))
-			return(dev_ioctl(cmd,(void *) arg));
-		
 		if(sk->prot->ioctl==0 || (err=sk->prot->ioctl(sk, cmd, arg))==-ENOIOCTLCMD)
 			return(dev_ioctl(cmd,(void *) arg));		
 		return err;
diff -urpNX dontdiff linux-2.5.38/net/packet/af_packet.c linux-2.5.38-willy/net/packet/af_packet.c
--- linux-2.5.38/net/packet/af_packet.c	2002-09-09 14:27:27.000000000 -0400
+++ linux-2.5.38-willy/net/packet/af_packet.c	2002-09-27 14:24:19.000000000 -0400
@@ -1458,16 +1458,6 @@ static int packet_ioctl(struct socket *s
 			spin_unlock_bh(&sk->receive_queue.lock);
 			return put_user(amount, (int *)arg);
 		}
-		case FIOSETOWN:
-		case SIOCSPGRP: {
-			int pid;
-			if (get_user(pid, (int *) arg))
-				return -EFAULT; 
-			return f_setown(sock->file, pid, 1);
-		}
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			return put_user(sock->file->f_owner.pid, (int *)arg);
 		case SIOCGSTAMP:
 			if(sk->stamp.tv_sec==0)
 				return -ENOENT;
@@ -1542,14 +1532,6 @@ static int packet_ioctl(struct socket *s
 #endif
 
 		default:
-			if ((cmd >= SIOCDEVPRIVATE) &&
-			    (cmd <= (SIOCDEVPRIVATE + 15)))
-				return(dev_ioctl(cmd,(void *) arg));
-
-#ifdef CONFIG_NET_RADIO
-			if((cmd >= SIOCIWFIRST) && (cmd <= SIOCIWLAST))
-				return(dev_ioctl(cmd,(void *) arg));
-#endif
 			return -EOPNOTSUPP;
 	}
 	return 0;
diff -urpNX dontdiff linux-2.5.38/net/socket.c linux-2.5.38-willy/net/socket.c
--- linux-2.5.38/net/socket.c	2002-09-09 14:27:27.000000000 -0400
+++ linux-2.5.38-willy/net/socket.c	2002-09-27 14:26:06.000000000 -0400
@@ -79,6 +79,10 @@
 #include <linux/kmod.h>
 #endif
 
+#if defined(CONFIG_NET_RADIO) || defined(CONFIG_NET_PCMCIA_RADIO)
+#include <linux/wireless.h>		/* Note : will define WIRELESS_EXT */
+#endif	/* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
+
 #include <asm/uaccess.h>
 
 #include <net/sock.h>
@@ -675,19 +679,42 @@ static ssize_t sock_writev(struct file *
 }
 
 /*
- *	With an ioctl arg may well be a user mode pointer, but we don't know what to do
- *	with it - that's up to the protocol still.
+ *	With an ioctl, arg may well be a user mode pointer, but we don't know
+ *	what to do with it - that's up to the protocol still.
  */
 
 int sock_ioctl(struct inode *inode, struct file *file, unsigned int cmd,
 	   unsigned long arg)
 {
 	struct socket *sock;
-	int err;
+	int pid, err;
 
 	unlock_kernel();
 	sock = SOCKET_I(inode);
-	err = sock->ops->ioctl(sock, cmd, arg);
+	if (cmd >= SIOCDEVPRIVATE && cmd <= (SIOCDEVPRIVATE + 15)) {
+		err = dev_ioctl(cmd, (void *)arg);
+	} else
+#ifdef WIRELESS_EXT
+	if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) {
+		err = dev_ioctl(cmd, (void *)arg);
+	} else
+#endif	/* WIRELESS_EXT */
+	switch (cmd) {
+		case FIOSETOWN:
+		case SIOCSPGRP:
+			err = -EFAULT;
+			if (get_user(pid, (int *)arg))
+				break;
+			err = f_setown(sock->file, pid, 1);
+			break;
+		case FIOGETOWN:
+		case SIOCGPGRP:
+			err = put_user(sock->file->f_owner.pid, (int *)arg);
+			break;
+		default:
+			err = sock->ops->ioctl(sock, cmd, arg);
+			break;
+	}
 	lock_kernel();
 
 	return err;
diff -urpNX dontdiff linux-2.5.38/net/wanrouter/af_wanpipe.c linux-2.5.38-willy/net/wanrouter/af_wanpipe.c
--- linux-2.5.38/net/wanrouter/af_wanpipe.c	2002-09-09 14:27:27.000000000 -0400
+++ linux-2.5.38-willy/net/wanrouter/af_wanpipe.c	2002-09-27 14:24:28.000000000 -0400
@@ -1867,19 +1867,9 @@ static int wanpipe_ioctl(struct socket *
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
-			return f_setown(sock->file, pid, 1);
-		case FIOGETOWN:
-		case SIOCGPGRP:
-			return put_user(sock->file->f_owner.pid, (int *)arg);
 		case SIOCGSTAMP:
 			if(sk->stamp.tv_sec==0)
 				return -ENOENT;
@@ -1979,14 +1969,6 @@ static int wanpipe_ioctl(struct socket *
 #endif
 
 		default:
-			if ((cmd >= SIOCDEVPRIVATE) &&
-			    (cmd <= (SIOCDEVPRIVATE + 15)))
-				return(dev_ioctl(cmd,(void *) arg));
-
-#ifdef CONFIG_NET_RADIO
-			if((cmd >= SIOCIWFIRST) && (cmd <= SIOCIWLAST))
-				return(dev_ioctl(cmd,(void *) arg));
-#endif
 			return -EOPNOTSUPP;
 	}
 	/*NOTREACHED*/

-- 
Revolutions do not require corporate support.
