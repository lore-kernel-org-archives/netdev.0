From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/11] [NET] Convert sk_queue_shrunk into SOCK_QUEUE_SHRUNK flag
Date: Wed, 9 Mar 2005 20:50:31 +0100
Message-ID: <20050309195031.GP31837@postel.suug.ch>
References: <20050309194521.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050309194521.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc4.orig/include/net/sock.h linux-2.6.11-rc4/include/net/sock.h
--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-09 01:31:21.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-09 02:48:15.000000000 +0100
@@ -164,7 +164,6 @@
   *	@sk_sndmsg_off - cached offset for sendmsg
   *	@sk_send_head - front of stuff to transmit
   *	@sk_write_pending - a write to stream socket waits to start
-  *	@sk_queue_shrunk - write queue has been shrunk recently
   *	@sk_state_change - callback to indicate change in the state of the sock
   *	@sk_data_ready - callback to indicate there is data to be processed
   *	@sk_write_space - callback to indicate there is bf sending space available
@@ -243,7 +242,6 @@
 	struct sk_buff		*sk_send_head;
 	int			sk_write_pending;
 	void			*sk_security;
-	__u8			sk_queue_shrunk;
 	/* three bytes hole, try to pack */
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
@@ -385,6 +383,7 @@
 	SOCK_RCVTSTAMP, /* %SO_TIMESTAMP setting */
	SOCK_NO_LARGESEND, /* whether to sent large segments or not */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
+	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
@@ -449,7 +448,7 @@
 
 static inline void sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
 {
-	sk->sk_queue_shrunk   = 1;
+	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
 	sk->sk_wmem_queued   -= skb->truesize;
 	sk->sk_forward_alloc += skb->truesize;
 	__kfree_skb(skb);
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_input.c linux-2.6.11-rc4/net/ipv4/tcp_input.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_input.c	2005-03-09 01:09:59.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_input.c	2005-03-09 02:48:13.000000000 +0100
@@ -3935,7 +3935,7 @@
 
 
 /* When incoming ACK allowed to free some skb from write_queue,
- * we remember this event in flag sk->sk_queue_shrunk and wake up socket
+ * we remember this event in flag SOCK_QUEUE_SHRUNK and wake up socket
  * on the exit from tcp input handler.
  *
  * PROBLEM: sndbuf expansion does not work well with largesend.
@@ -3963,8 +3963,8 @@
 
 static inline void tcp_check_space(struct sock *sk)
 {
-	if (sk->sk_queue_shrunk) {
-		sk->sk_queue_shrunk = 0;
+	if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
+		sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);
 		if (sk->sk_socket &&
 		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
 			tcp_new_space(sk);
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_output.c linux-2.6.11-rc4/net/ipv4/tcp_output.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_output.c	2005-03-09 01:09:59.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_output.c	2005-03-09 02:47:14.000000000 +0100
@@ -593,9 +593,9 @@
 	skb->ip_summed = CHECKSUM_HW;
 
 	skb->truesize	     -= len;
-	sk->sk_queue_shrunk   = 1;
 	sk->sk_wmem_queued   -= len;
 	sk->sk_forward_alloc += len;
+	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
 
 	/* Any change of skb->len requires recalculation of tso
 	 * factor and mss.
