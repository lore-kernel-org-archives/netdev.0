From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Thu, 8 Aug 2002 10:24:19 +1000 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0208081018410.16830-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Matthew Wilcox <willy@debian.org>
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
List-Id: netdev.vger.kernel.org

Suggested by Matthew Wilcox, the patch below consolidates FIOSETOWN etc. 
ioctl handling into the socket layer, making it common for all sockets.

 econet/af_econet.c     |   12 ------------
 ipv4/af_inet.c         |   16 ----------------
 ipv6/af_inet6.c        |   14 --------------
 packet/af_packet.c     |   14 --------------
 socket.c               |   30 ++++++++++++++++++++++++++++--
 wanrouter/af_wanpipe.c |   14 --------------
 6 files changed, 28 insertions, 72 deletions

Btw, is af_wanpipe.c likely to stay in the tree?  It doesn't seem to be 
used anymore.

- James
-- 
James Morris
<jmorris@intercode.com.au>


diff -urN -X dontdiff linux-2.5.30.orig/net/econet/af_econet.c linux-2.5.30.w1/net/econet/af_econet.c
--- linux-2.5.30.orig/net/econet/af_econet.c	Sat Aug  3 23:40:30 2002
+++ linux-2.5.30.w1/net/econet/af_econet.c	Wed Aug  7 23:33:57 2002
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
diff -urN -X dontdiff linux-2.5.30.orig/net/ipv4/af_inet.c linux-2.5.30.w1/net/ipv4/af_inet.c
--- linux-2.5.30.orig/net/ipv4/af_inet.c	Sat Aug  3 23:40:09 2002
+++ linux-2.5.30.w1/net/ipv4/af_inet.c	Wed Aug  7 23:25:23 2002
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
diff -urN -X dontdiff linux-2.5.30.orig/net/ipv6/af_inet6.c linux-2.5.30.w1/net/ipv6/af_inet6.c
--- linux-2.5.30.orig/net/ipv6/af_inet6.c	Sat Aug  3 23:40:22 2002
+++ linux-2.5.30.w1/net/ipv6/af_inet6.c	Wed Aug  7 23:30:36 2002
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
diff -urN -X dontdiff linux-2.5.30.orig/net/packet/af_packet.c linux-2.5.30.w1/net/packet/af_packet.c
--- linux-2.5.30.orig/net/packet/af_packet.c	Sat Aug  3 23:40:30 2002
+++ linux-2.5.30.w1/net/packet/af_packet.c	Thu Aug  8 01:34:44 2002
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
diff -urN -X dontdiff linux-2.5.30.orig/net/socket.c linux-2.5.30.w1/net/socket.c
--- linux-2.5.30.orig/net/socket.c	Sun Aug  4 23:59:29 2002
+++ linux-2.5.30.w1/net/socket.c	Wed Aug  7 23:39:00 2002
@@ -683,11 +683,37 @@
 	   unsigned long arg)
 {
 	struct socket *sock;
-	int err;
+	struct sock *sk;
+	int err = 0;
 
 	unlock_kernel();
 	sock = SOCKET_I(inode);
-	err = sock->ops->ioctl(sock, cmd, arg);
+	sk = sock->sk;
+	
+	switch(cmd) {
+	case FIOSETOWN:
+	case SIOCSPGRP: {
+		int pid;
+		
+		if (get_user(pid, (int *)arg))
+			err = -EFAULT;
+		else if (current->pid != pid && current->pgrp != -pid &&
+		         !capable(CAP_NET_ADMIN))
+			err = -EPERM;
+		else
+			sk->proc = pid;
+		break;
+	}
+	
+	case FIOGETOWN:
+	case SIOCGPGRP:
+		err = put_user(sk->proc, (int *)arg);
+		break;
+
+	default:
+		err = sock->ops->ioctl(sock, cmd, arg);
+	}
+	
 	lock_kernel();
 
 	return err;
diff -urN -X dontdiff linux-2.5.30.orig/net/wanrouter/af_wanpipe.c linux-2.5.30.w1/net/wanrouter/af_wanpipe.c
--- linux-2.5.30.orig/net/wanrouter/af_wanpipe.c	Sat Aug  3 23:39:41 2002
+++ linux-2.5.30.w1/net/wanrouter/af_wanpipe.c	Wed Aug  7 23:33:26 2002
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
