From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/11] [NET] Convert sk_user_write_queue into SOCK_USE_WRITE_QUEUE flag
Date: Wed, 9 Mar 2005 20:47:43 +0100
Message-ID: <20050309194743.GK31837@postel.suug.ch>
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
--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-09 00:21:18.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-09 00:21:55.000000000 +0100
@@ -116,7 +116,6 @@
   *	struct sock - network layer representation of sockets
   *	@__sk_common - shared layout with tcp_tw_bucket
   *	@sk_shutdown - mask of %SEND_SHUTDOWN and/or %RCV_SHUTDOWN
-  *	@sk_use_write_queue - wheter to call sk->sk_write_space in sock_wfree
   *	@sk_userlocks - %SO_SNDBUF and %SO_RCVBUF settings
   *	@sk_lock -	synchronizer
   *	@sk_rcvbuf - size of receive buffer in bytes
@@ -191,7 +190,6 @@
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_refcnt		__sk_common.skc_refcnt
 	unsigned char		sk_shutdown;
-	unsigned char		sk_use_write_queue;
 	unsigned char		sk_userlocks;
 	socket_lock_t		sk_lock;
 	int			sk_rcvbuf;
@@ -390,6 +388,7 @@
 	SOCK_BROADCAST,
 	SOCK_TIMESTAMP,
 	SOCK_ZAPPED,
+	SOCK_USE_WRITE_QUEUE, /* wheter to call sk->sk_write_space in sock_wfree */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
diff -Nru linux-2.6.11-rc4.orig/net/core/sock.c linux-2.6.11-rc4/net/core/sock.c
--- linux-2.6.11-rc4.orig/net/core/sock.c	2005-03-09 00:21:19.000000000 +0100
+++ linux-2.6.11-rc4/net/core/sock.c	2005-03-09 00:19:39.000000000 +0100
@@ -709,7 +709,7 @@
 
 	/* In case it might be waiting for more memory. */
 	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
-	if (!sk->sk_use_write_queue)
+	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
 		sk->sk_write_space(sk);
 	sock_put(sk);
 }
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_ipv4.c linux-2.6.11-rc4/net/ipv4/tcp_ipv4.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_ipv4.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_ipv4.c	2005-03-09 00:19:55.000000000 +0100
@@ -2064,7 +2064,7 @@
 	sk->sk_state = TCP_CLOSE;
 
 	sk->sk_write_space = sk_stream_write_space;
-	sk->sk_use_write_queue = 1;
+	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
 	tp->af_specific = &ipv4_specific;
 
diff -Nru linux-2.6.11-rc4.orig/net/ipv6/tcp_ipv6.c linux-2.6.11-rc4/net/ipv6/tcp_ipv6.c
--- linux-2.6.11-rc4.orig/net/ipv6/tcp_ipv6.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv6/tcp_ipv6.c	2005-03-09 00:20:06.000000000 +0100
@@ -2027,7 +2027,7 @@
 	tp->af_specific = &ipv6_specific;
 
 	sk->sk_write_space = sk_stream_write_space;
-	sk->sk_use_write_queue = 1;
+	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
diff -Nru linux-2.6.11-rc4.orig/net/sctp/endpointola.c linux-2.6.11-rc4/net/sctp/endpointola.c
--- linux-2.6.11-rc4.orig/net/sctp/endpointola.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/sctp/endpointola.c	2005-03-09 00:20:42.000000000 +0100
@@ -126,7 +126,7 @@
 
 	/* Use SCTP specific send buffer space queues.  */
 	sk->sk_write_space = sctp_write_space;
-	sk->sk_use_write_queue = 1;
+	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
 	/* Initialize the secret key used with cookie. */
 	get_random_bytes(&ep->secret_key[0], SCTP_SECRET_SIZE);
