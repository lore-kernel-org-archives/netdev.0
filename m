From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Thu, 23 Apr 2009 21:41:11 -0700 (PDT)
Message-ID: <20090423.214111.114375716.davem@davemloft.net>
References: <20090421.233403.83067664.davem@davemloft.net>
	<200904240207.n3O27Sb0096107@www262.sakura.ne.jp>
	<20090423.213542.03667490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, greg@blekko.com
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090423.213542.03667490.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 23 Apr 2009 21:35:42 -0700 (PDT)

> This behavior mentioned in that manpage snippet is a BUG which we
> FIXED!  You're just proving my point even more!

And here is that bug fix, for your reference.  The behavior was
wrong, it BROKE real applications, we removed it.

commit edea8fef1415a7499c09149b383a171e83480375
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Tue Nov 30 05:26:12 2004 -0800

    [UDP]: Select handling of bad checksums.
    
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
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/udp.h b/include/net/udp.h
index 2ef99a7..c496d10 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -71,6 +71,8 @@ extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
 extern int	udp_rcv(struct sk_buff *skb);
 extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int	udp_disconnect(struct sock *sk, int flags);
+extern unsigned int udp_poll(struct file *file, struct socket *sock,
+			     poll_table *wait);
 
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 #define UDP_INC_STATS(field)		SNMP_INC_STATS(udp_statistics, field)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f9cacaf..d127c16 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -809,7 +809,7 @@ struct proto_ops inet_dgram_ops = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	inet_getname,
-	.poll =		datagram_poll,
+	.poll =		udp_poll,
 	.ioctl =	inet_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	inet_shutdown,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d38f2b2..4a1bfb3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1303,6 +1303,52 @@ static int udp_getsockopt(struct sock *sk, int level, int optname,
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
@@ -1517,6 +1563,7 @@ EXPORT_SYMBOL(udp_ioctl);
 EXPORT_SYMBOL(udp_port_rover);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
+EXPORT_SYMBOL(udp_poll);
 
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 0190359..1d10fb1 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -501,7 +501,7 @@ struct proto_ops inet6_dgram_ops = {
 	.socketpair =	sock_no_socketpair,		/* a do nothing	*/
 	.accept =	sock_no_accept,			/* a do nothing	*/
 	.getname =	inet6_getname, 
-	.poll =		datagram_poll,			/* ok		*/
+	.poll =		udp_poll,			/* ok		*/
 	.ioctl =	inet6_ioctl,			/* must change  */
 	.listen =	sock_no_listen,			/* ok		*/
 	.shutdown =	inet_shutdown,			/* ok		*/
