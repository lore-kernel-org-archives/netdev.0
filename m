From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/11] [NET] Convert sk_debug into SOCK_DBG flag
Date: Wed, 9 Mar 2005 20:48:19 +0100
Message-ID: <20050309194819.GL31837@postel.suug.ch>
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
--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-09 00:40:06.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-09 00:49:23.000000000 +0100
@@ -61,10 +61,10 @@
  * the other protocols.
  */
 
-/* Define this to get the sk->sk_debug debugging facility. */
+/* Define this to get the SOCK_DBG debugging facility. */
 #define SOCK_DEBUGGING
 #ifdef SOCK_DEBUGGING
-#define SOCK_DEBUG(sk, msg...) do { if ((sk) && ((sk)->sk_debug)) \
+#define SOCK_DEBUG(sk, msg...) do { if ((sk) && sock_flag((sk), SOCK_DBG)) \
 					printk(KERN_DEBUG msg); } while (0)
 #else
 #define SOCK_DEBUG(sk, msg...) do { } while (0)
@@ -134,7 +134,6 @@
   *	@sk_sndbuf - size of send buffer in bytes
   *	@sk_flags - %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE, %SO_OOBINLINE settings
   *	@sk_no_check - %SO_NO_CHECK setting, wether or not checkup packets
-  *	@sk_debug - %SO_DEBUG setting
   *	@sk_rcvtstamp - %SO_TIMESTAMP setting
   *	@sk_no_largesend - whether to sent large segments or not
   *	@sk_route_caps - route capabilities (e.g. %NETIF_F_TSO)
@@ -208,7 +207,6 @@
 	int			sk_sndbuf;
 	unsigned long 		sk_flags;
 	char		 	sk_no_check;
-	unsigned char		sk_debug;
 	unsigned char		sk_rcvtstamp;
 	unsigned char		sk_no_largesend;
 	int			sk_route_caps;
@@ -389,6 +387,7 @@
 	SOCK_TIMESTAMP,
 	SOCK_ZAPPED,
 	SOCK_USE_WRITE_QUEUE, /* wheter to call sk->sk_write_space in sock_wfree */
+	SOCK_DBG, /* %SO_DEBUG setting */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
diff -Nru linux-2.6.11-rc4.orig/net/ax25/af_ax25.c linux-2.6.11-rc4/net/ax25/af_ax25.c
--- linux-2.6.11-rc4.orig/net/ax25/af_ax25.c	2005-03-09 00:21:19.000000000 +0100
+++ linux-2.6.11-rc4/net/ax25/af_ax25.c	2005-03-09 00:43:51.000000000 +0100
@@ -868,10 +868,12 @@
 	sk->sk_protocol = osk->sk_protocol;
 	sk->sk_rcvbuf   = osk->sk_rcvbuf;
 	sk->sk_sndbuf   = osk->sk_sndbuf;
-	sk->sk_debug    = osk->sk_debug;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
 
+	if (sock_flag(osk, SOCK_DBG))
+		sock_set_flag(sk, SOCK_DBG);
+
 	if (sock_flag(osk, SOCK_ZAPPED))
 		sock_set_flag(sk, SOCK_ZAPPED);
 
diff -Nru linux-2.6.11-rc4.orig/net/core/sock.c linux-2.6.11-rc4/net/core/sock.c
--- linux-2.6.11-rc4.orig/net/core/sock.c	2005-03-09 00:40:06.000000000 +0100
+++ linux-2.6.11-rc4/net/core/sock.c	2005-03-09 00:45:23.000000000 +0100
@@ -228,8 +228,10 @@
 			{
 				ret = -EACCES;
 			}
+			else if (valbool)
+				sock_set_flag(sk, SOCK_DBG);
 			else
-				sk->sk_debug = valbool;
+				sock_reset_flag(sk, SOCK_DBG);
 			break;
 		case SO_REUSEADDR:
 			sk->sk_reuse = valbool;
@@ -463,7 +465,7 @@
   	switch(optname) 
   	{
 		case SO_DEBUG:		
-			v.val = sk->sk_debug;
+			v.val = sock_flag(sk, SOCK_DBG);
 			break;
 		
 		case SO_DONTROUTE:
diff -Nru linux-2.6.11-rc4.orig/net/netrom/af_netrom.c linux-2.6.11-rc4/net/netrom/af_netrom.c
--- linux-2.6.11-rc4.orig/net/netrom/af_netrom.c	2005-03-09 00:21:19.000000000 +0100
+++ linux-2.6.11-rc4/net/netrom/af_netrom.c	2005-03-09 00:46:08.000000000 +0100
@@ -476,13 +476,15 @@
 	sk->sk_protocol = osk->sk_protocol;
 	sk->sk_rcvbuf   = osk->sk_rcvbuf;
 	sk->sk_sndbuf   = osk->sk_sndbuf;
-	sk->sk_debug    = osk->sk_debug;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
 
 	if (sock_flag(osk, SOCK_ZAPPED))
 		sock_set_flag(sk, SOCK_ZAPPED);
 
+	if (sock_flag(osk, SOCK_DBG))
+		sock_set_flag(sk, SOCK_DBG);
+
 	skb_queue_head_init(&nr->ack_queue);
 	skb_queue_head_init(&nr->reseq_queue);
 	skb_queue_head_init(&nr->frag_queue);
diff -Nru linux-2.6.11-rc4.orig/net/rose/af_rose.c linux-2.6.11-rc4/net/rose/af_rose.c
--- linux-2.6.11-rc4.orig/net/rose/af_rose.c	2005-03-09 00:21:19.000000000 +0100
+++ linux-2.6.11-rc4/net/rose/af_rose.c	2005-03-09 00:46:28.000000000 +0100
@@ -572,13 +572,15 @@
 	sk->sk_protocol = osk->sk_protocol;
 	sk->sk_rcvbuf   = osk->sk_rcvbuf;
 	sk->sk_sndbuf   = osk->sk_sndbuf;
-	sk->sk_debug    = osk->sk_debug;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
 
 	if (sock_flag(osk, SOCK_ZAPPED))
 		sock_set_flag(sk, SOCK_ZAPPED);
 
+	if (sock_flag(osk, SOCK_DBG))
+		sock_set_flag(sk, SOCK_DBG);
+
 	init_timer(&rose->timer);
 	init_timer(&rose->idletimer);
 
diff -Nru linux-2.6.11-rc4.orig/net/wanrouter/af_wanpipe.c linux-2.6.11-rc4/net/wanrouter/af_wanpipe.c
--- linux-2.6.11-rc4.orig/net/wanrouter/af_wanpipe.c	2005-03-09 00:21:19.000000000 +0100
+++ linux-2.6.11-rc4/net/wanrouter/af_wanpipe.c	2005-03-09 00:46:50.000000000 +0100
@@ -468,10 +468,12 @@
 	wp_sk(sk)->num	= wp_sk(osk)->num;
 	sk->sk_rcvbuf	= osk->sk_rcvbuf;
 	sk->sk_sndbuf	= osk->sk_sndbuf;
-	sk->sk_debug	= osk->sk_debug;
 	sk->sk_state	= WANSOCK_CONNECTING;
 	sk->sk_sleep	= osk->sk_sleep;
 
+	if (sock_flag(osk, SOCK_DBG))
+		sock_set_flag(sk, SOCK_DBG);
+
 	return sk;
 }
 
diff -Nru linux-2.6.11-rc4.orig/net/x25/af_x25.c linux-2.6.11-rc4/net/x25/af_x25.c
--- linux-2.6.11-rc4.orig/net/x25/af_x25.c	2005-03-09 00:21:19.000000000 +0100
+++ linux-2.6.11-rc4/net/x25/af_x25.c	2005-03-09 00:47:10.000000000 +0100
@@ -525,13 +525,15 @@
 	sk->sk_protocol    = osk->sk_protocol;
 	sk->sk_rcvbuf      = osk->sk_rcvbuf;
 	sk->sk_sndbuf      = osk->sk_sndbuf;
-	sk->sk_debug       = osk->sk_debug;
 	sk->sk_state       = TCP_ESTABLISHED;
 	sk->sk_sleep       = osk->sk_sleep;
 	sk->sk_backlog_rcv = osk->sk_backlog_rcv;
 
 	if (sock_flag(osk, SOCK_ZAPPED))
 		sock_set_flag(sk, SOCK_ZAPPED);
+	
+	if (sock_flag(osk, SOCK_DBG))
+		sock_set_flag(sk, SOCK_DBG);
 
 	ox25 = x25_sk(osk);
 	x25->t21        = ox25->t21;
