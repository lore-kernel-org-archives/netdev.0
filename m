From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Files, sockets, and closing
Date: Fri, 26 Oct 2007 14:03:19 -0700
Message-ID: <20071026140319.5bcc8ac0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60783 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754177AbXJZVDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 17:03:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looking at this bug:
http://bugzilla.kernel.org/show_bug.cgi?id=9149

Exposes some rather deep issues in the filesystem/socket/inet/tcp
layering. It seems that sys_close() zaps the file table entry, but
since each thread has a separate reference, the actual tcp_close()
doesn't happen until the last thread calls close/exits.

I am no VFS expert.
The semantically correct fix appears to be complex.
  * add a flush handle to the socket_file_ops
  * propagate the flush through socket to inet and tcp
  * split tcp_close into two parts.
     1) tcp_flush - flush buffers and wakeup all other threads on the socket 
     2) tcp_release - release last reference and cleanup.

Bogus patch for explanation purposes:

--- a/include/linux/net.h	2007-10-26 12:44:41.000000000 -0700
+++ b/include/linux/net.h	2007-10-26 13:56:39.000000000 -0700
@@ -128,6 +128,7 @@ struct proto_ops {
 	int		family;
 	struct module	*owner;
 	int		(*release)   (struct socket *sock);
+	void		(*flush)     (struct socket *sock);
 	int		(*bind)	     (struct socket *sock,
 				      struct sockaddr *myaddr,
 				      int sockaddr_len);
--- a/include/net/tcp.h	2007-10-26 12:44:42.000000000 -0700
+++ b/include/net/tcp.h	2007-10-26 13:06:53.000000000 -0700
@@ -367,6 +367,7 @@ extern void			tcp_enter_loss(struct sock
 extern void			tcp_clear_retrans(struct tcp_sock *tp);
 extern void			tcp_update_metrics(struct sock *sk);
 
+extern void			tcp_flush(struct sock *sk);
 extern void			tcp_close(struct sock *sk, 
 					  long timeout);
 extern unsigned int		tcp_poll(struct file * file, struct socket *sock, struct poll_table_struct *wait);
--- a/net/ipv4/af_inet.c	2007-10-26 12:44:46.000000000 -0700
+++ b/net/ipv4/af_inet.c	2007-10-26 13:56:00.000000000 -0700
@@ -386,6 +386,14 @@ out_rcu_unlock:
 	goto out;
 }
 
+/* The file handle is closed, but not all threads maybe gone */
+void inet_flush(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	if (sk && sk->sk_prot->flush)
+		sk->sk_prot->flush(sk);
+}
 
 /*
  *	The peer socket should always be NULL (or else). When we call this
@@ -822,6 +830,7 @@ int inet_ioctl(struct socket *sock, unsi
 const struct proto_ops inet_stream_ops = {
 	.family		   = PF_INET,
 	.owner		   = THIS_MODULE,
+	.flush		   = inet_flush,
 	.release	   = inet_release,
 	.bind		   = inet_bind,
 	.connect	   = inet_stream_connect,
--- a/net/ipv4/tcp.c	2007-10-26 12:44:46.000000000 -0700
+++ b/net/ipv4/tcp.c	2007-10-26 14:00:42.000000000 -0700
@@ -1557,11 +1557,10 @@ void tcp_shutdown(struct sock *sk, int h
 	}
 }
 
-void tcp_close(struct sock *sk, long timeout)
+void tcp_flush(struct sock *sk)
 {
 	struct sk_buff *skb;
 	int data_was_unread = 0;
-	int state;
 
 	lock_sock(sk);
 	sk->sk_shutdown = SHUTDOWN_MASK;
@@ -1572,7 +1571,7 @@ void tcp_close(struct sock *sk, long tim
 		/* Special case. */
 		inet_csk_listen_stop(sk);
 
-		goto adjudge_to_death;
+		return;
 	}
 
 	/*  We need to flush the recv. buffs.  We do this only on the
@@ -1632,10 +1631,16 @@ void tcp_close(struct sock *sk, long tim
 		 */
 		tcp_send_fin(sk);
 	}
+	release_sock(sk);
+}
 
+void tcp_close(struct sock *sk, long timeout)
+{
+	int state;
+
+	lock_sock(sk);
 	sk_stream_wait_close(sk, timeout);
 
-adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
@@ -2524,6 +2529,7 @@ void __init tcp_init(void)
 	tcp_register_congestion_control(&tcp_reno);
 }
 
+EXPORT_SYMBOL(tcp_flush);
 EXPORT_SYMBOL(tcp_close);
 EXPORT_SYMBOL(tcp_disconnect);
 EXPORT_SYMBOL(tcp_getsockopt);
--- a/net/ipv4/tcp_ipv4.c	2007-10-26 12:44:46.000000000 -0700
+++ b/net/ipv4/tcp_ipv4.c	2007-10-26 13:06:04.000000000 -0700
@@ -2420,6 +2420,7 @@ void tcp4_proc_exit(void)
 struct proto tcp_prot = {
 	.name			= "TCP",
 	.owner			= THIS_MODULE,
+	.flush			= tcp_flush,
 	.close			= tcp_close,
 	.connect		= tcp_v4_connect,
 	.disconnect		= tcp_disconnect,
--- a/net/ipv6/tcp_ipv6.c	2007-10-26 12:44:47.000000000 -0700
+++ b/net/ipv6/tcp_ipv6.c	2007-10-26 13:06:25.000000000 -0700
@@ -2109,6 +2109,7 @@ void tcp6_proc_exit(void)
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.owner			= THIS_MODULE,
+	.flush			= tcp_flush,
 	.close			= tcp_close,
 	.connect		= tcp_v6_connect,
 	.disconnect		= tcp_disconnect,
--- a/net/socket.c	2007-10-26 12:44:48.000000000 -0700
+++ b/net/socket.c	2007-10-26 13:47:48.000000000 -0700
@@ -100,7 +100,7 @@ static ssize_t sock_aio_read(struct kioc
 static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
 			  unsigned long nr_segs, loff_t pos);
 static int sock_mmap(struct file *file, struct vm_area_struct *vma);
-
+static int sock_flush(struct file *file, fl_owner_t id);
 static int sock_close(struct inode *inode, struct file *file);
 static unsigned int sock_poll(struct file *file,
 			      struct poll_table_struct *wait);
@@ -130,6 +130,7 @@ static const struct file_operations sock
 #endif
 	.mmap =		sock_mmap,
 	.open =		sock_no_open,	/* special open code to disallow open via /proc */
+	.flush =	sock_flush,
 	.release =	sock_close,
 	.fasync =	sock_fasync,
 	.sendpage =	sock_sendpage,
@@ -961,6 +962,15 @@ static int sock_mmap(struct file *file, 
 	return sock->ops->mmap(file, sock, vma);
 }
 
+static int sock_flush(struct file *file, fl_owner_t id)
+{
+	struct socket *sock = file->private_data;
+
+	if (sock->ops && sock->ops->flush)
+		sock->ops->flush(sock);
+	return 0;
+}
+
 static int sock_close(struct inode *inode, struct file *filp)
 {
 	/*
--- a/include/net/sock.h	2007-10-26 12:44:42.000000000 -0700
+++ b/include/net/sock.h	2007-10-26 13:50:03.000000000 -0700
@@ -515,6 +515,7 @@ struct timewait_sock_ops;
 struct proto {
 	void			(*close)(struct sock *sk, 
 					long timeout);
+	void			(*flush)(struct sock *sk);
 	int			(*connect)(struct sock *sk,
 				        struct sockaddr *uaddr, 
 					int addr_len);
