From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] UDP select handling of bad checksums.
Date: Mon, 22 Nov 2004 10:09:07 -0800
Message-ID: <20041122100907.2ab81f18@dxpl.pdx.osdl.net>
References: <20041102162454.3f153ff0@dxpl.pdx.osdl.net>
	<20041103005253.GA77817@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitchell Blank Jr <mitch@sfgoth.com>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041103005253.GA77817@gaz.sfgoth.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alternate workaround for blocking usage of select() by UDP applications.
The problem is Linux optimizes the UDP receive checksum path so that checksum
validation is not performed until the application read. This is a performance win
but can cause applications that do select with blocking file descriptors to get false
positives if the received message has a checksum error.
There is a long running thread about this on LKML.

This patch makes these applications work, but keeps the one-pass performance gain
for those applications smart enough to use non-blocking file descriptors with
select/poll. There is still a possibility to get a false positive if application does
select on non-blocking fd then makes it blocking before doing the receive, but that
is unlikely.

Tested by injecting bad packets with SOCK_RAW.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h	2004-11-19 10:37:56 -08:00
+++ b/include/net/udp.h	2004-11-19 10:37:56 -08:00
@@ -71,6 +71,8 @@
 extern int	udp_rcv(struct sk_buff *skb);
 extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int	udp_disconnect(struct sock *sk, int flags);
+extern unsigned int udp_poll(struct file *file, struct socket *sock,
+			     poll_table *wait);
 
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 #define UDP_INC_STATS(field)		SNMP_INC_STATS(udp_statistics, field)
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-11-19 10:37:56 -08:00
+++ b/net/ipv4/af_inet.c	2004-11-19 10:37:56 -08:00
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
--- a/net/ipv4/udp.c	2004-11-19 10:37:56 -08:00
+++ b/net/ipv4/udp.c	2004-11-19 10:37:56 -08:00
@@ -1303,6 +1303,52 @@
   	return 0;
 }
 
+/**
+ * 	udp_poll - wait for a UDP event.
+ *	@file - file struct
+ *	@sock - socket
+ *	@wait - poll table
+ *
+ *	This is same as datagram poll, except for the special case of 
+ *	blocking sockets. If application is using a blocking fd
+ *	and a packet with checksum error is in the queue;
+ *	then it could get return from select indicating data available
+ *	but then block when reading it. Add special case code
+ *	to work around these arguably broken applications.
+ */
+unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
+{
+	unsigned int mask = datagram_poll(file, sock, wait);
+	struct sock *sk = sock->sk;
+	
+	/* Check for false positives due to checksum errors */
+	if ( (mask & POLLRDNORM) &&
+	     !(file->f_flags & O_NONBLOCK) &&
+	     !(sk->sk_shutdown & RCV_SHUTDOWN)){
+		struct sk_buff_head *rcvq = &sk->sk_receive_queue;
+		struct sk_buff *skb;
+
+		spin_lock_irq(&rcvq->lock);
+		while ((skb = skb_peek(rcvq)) != NULL) {
+			if (udp_checksum_complete(skb)) {
+				UDP_INC_STATS_BH(UDP_MIB_INERRORS);
+				__skb_unlink(skb, rcvq);
+				kfree_skb(skb);
+			} else {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				break;
+			}
+		}
+		spin_unlock_irq(&rcvq->lock);
+
+		/* nothing to see, move along */
+		if (skb == NULL)
+			mask &= ~(POLLIN | POLLRDNORM);
+	}
+
+	return mask;
+	
+}
 
 struct proto udp_prot = {
  	.name =		"UDP",
@@ -1516,6 +1562,7 @@
 EXPORT_SYMBOL(udp_port_rover);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
+EXPORT_SYMBOL(udp_poll);
 
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-11-19 10:37:56 -08:00
+++ b/net/ipv6/af_inet6.c	2004-11-19 10:37:56 -08:00
@@ -501,7 +501,7 @@
 	.socketpair =	sock_no_socketpair,		/* a do nothing	*/
 	.accept =	sock_no_accept,			/* a do nothing	*/
 	.getname =	inet6_getname, 
-	.poll =		datagram_poll,			/* ok		*/
+	.poll =		udp_poll,			/* ok		*/
 	.ioctl =	inet6_ioctl,			/* must change  */
 	.listen =	sock_no_listen,			/* ok		*/
 	.shutdown =	inet_shutdown,			/* ok		*/
