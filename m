From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] UDP select handling of bad checksums.
Date: Tue, 2 Nov 2004 16:24:54 -0800
Message-ID: <20041102162454.3f153ff0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch addresses the issue of blocking usage of select() by UDP applications.
The problem is Linux optimizes the UDP receive checksum path so that checksum
validation is not performed until the application receive. This is a performance win
but can cause applications that do select with blocking file descriptors to get false
positives. There is a long running thread about this on LKML, as well as the cause
of http://bugme.osdl.org/show_bug.cgi?id=3610

This patch makes these applications work, but keeps the one-pass performance gain
for those applications smart enough to use non-blocking file descriptors with
select/poll. There is still a possibility to get a false positive if application does
select on non-blocking fd then makes it blocking before doing the receive, but that
is unlikely.

Tested by injecting bad packets with SOCK_RAW.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h	2004-11-02 16:16:29 -08:00
+++ b/include/net/udp.h	2004-11-02 16:16:29 -08:00
@@ -71,6 +71,8 @@
 extern int	udp_rcv(struct sk_buff *skb);
 extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int	udp_disconnect(struct sock *sk, int flags);
+extern unsigned int udp_poll(struct file *file, struct socket *sock,
+			     poll_table *wait);
 
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 #define UDP_INC_STATS(field)		SNMP_INC_STATS(udp_statistics, field)
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-11-02 16:16:29 -08:00
+++ b/net/ipv4/af_inet.c	2004-11-02 16:16:29 -08:00
@@ -809,7 +809,7 @@
 	.socketpair =	sock_no_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	inet_getname,
-	.poll =		datagram_poll,
+	.poll =		udp_poll,
 	.ioctl =	inet_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	inet_shutdown,
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2004-11-02 16:16:29 -08:00
+++ b/net/ipv4/udp.c	2004-11-02 16:16:29 -08:00
@@ -1303,6 +1303,67 @@
   	return 0;
 }
 
+static inline int udp_recv_ready(const struct file *file, 
+			  struct sk_buff_head *rcvq)
+{
+	struct sk_buff *skb;
+
+	/* If non-blocking, can use faster single pass method. */
+	if (file->f_flags & O_NONBLOCK)
+		return !skb_queue_empty(rcvq);
+	
+	spin_lock_irq(&rcvq->lock);
+	while ((skb = skb_peek(rcvq)) != NULL) {
+		/* checksum is wrong, silently remove it. */
+		if (udp_checksum_complete(skb))
+			__skb_unlink(skb, rcvq);
+		else {
+			/* no need to rescan */
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			break;
+		}
+	}
+	spin_unlock_irq(&rcvq->lock);
+
+	return skb != NULL;
+}
+
+/*
+ *	Wait for a UDP event.
+ *
+ *	This is same as datagram poll, except for the special case of 
+ *	blocking sockets. UDP doesn't checksum data until it is copied
+ *	to the application on receive. So handle that special case here.
+ */
+unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	unsigned int mask;
+
+	poll_wait(file, sk->sk_sleep, wait);
+	mask = 0;
+
+	/* exceptional events? */
+	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+		mask |= POLLERR;
+
+	if (sk->sk_shutdown == SHUTDOWN_MASK)
+		mask |= POLLHUP;
+
+	/* readable? */
+	if ( udp_recv_ready(file, &sk->sk_receive_queue) ||
+	     (sk->sk_shutdown & RCV_SHUTDOWN))
+		mask |= POLLIN | POLLRDNORM;
+
+	/* writable? */
+	if (sock_writeable(sk))
+		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+	else
+		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+
+	return mask;
+	
+}
 
 struct proto udp_prot = {
  	.name =		"UDP",
@@ -1516,6 +1577,7 @@
 EXPORT_SYMBOL(udp_port_rover);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
+EXPORT_SYMBOL(udp_poll);
 
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-11-02 16:16:29 -08:00
+++ b/net/ipv6/af_inet6.c	2004-11-02 16:16:29 -08:00
@@ -501,7 +501,7 @@
 	.socketpair =	sock_no_socketpair,		/* a do nothing	*/
 	.accept =	sock_no_accept,			/* a do nothing	*/
 	.getname =	inet6_getname, 
-	.poll =		datagram_poll,			/* ok		*/
+	.poll =		udp_poll,			/* ok		*/
 	.ioctl =	inet6_ioctl,			/* must change  */
 	.listen =	sock_no_listen,			/* ok		*/
 	.shutdown =	inet_shutdown,			/* ok		*/
