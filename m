From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/11] [NET] Convert sk_rcvtstamp into SOCK_RCVTSTAMP flag
Date: Wed, 9 Mar 2005 20:48:46 +0100
Message-ID: <20050309194846.GM31837@postel.suug.ch>
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
--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-09 00:53:32.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-09 01:01:33.000000000 +0100
@@ -134,7 +134,6 @@
   *	@sk_sndbuf - size of send buffer in bytes
   *	@sk_flags - %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE, %SO_OOBINLINE settings
   *	@sk_no_check - %SO_NO_CHECK setting, wether or not checkup packets
-  *	@sk_rcvtstamp - %SO_TIMESTAMP setting
   *	@sk_no_largesend - whether to sent large segments or not
   *	@sk_route_caps - route capabilities (e.g. %NETIF_F_TSO)
   *	@sk_lingertime - %SO_LINGER l_linger setting
@@ -207,7 +206,6 @@
 	int			sk_sndbuf;
 	unsigned long 		sk_flags;
 	char		 	sk_no_check;
-	unsigned char		sk_rcvtstamp;
 	unsigned char		sk_no_largesend;
 	int			sk_route_caps;
 	unsigned long	        sk_lingertime;
@@ -388,6 +386,7 @@
 	SOCK_ZAPPED,
 	SOCK_USE_WRITE_QUEUE, /* wheter to call sk->sk_write_space in sock_wfree */
 	SOCK_DBG, /* %SO_DEBUG setting */
+	SOCK_RCVTSTAMP, /* %SO_TIMESTAMP setting */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
@@ -1237,7 +1236,7 @@
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
 	struct timeval *stamp = &skb->stamp;
-	if (sk->sk_rcvtstamp) { 
+	if (sock_flag(sk, SOCK_RCVTSTAMP)) {
 		/* Race occurred between timestamp enabling and packet
 		   receiving.  Fill in the current time for now. */
 		if (stamp->tv_sec == 0)
diff -Nru linux-2.6.11-rc4.orig/net/core/sock.c linux-2.6.11-rc4/net/core/sock.c
--- linux-2.6.11-rc4.orig/net/core/sock.c	2005-03-09 00:53:32.000000000 +0100
+++ linux-2.6.11-rc4/net/core/sock.c	2005-03-09 00:58:43.000000000 +0100
@@ -339,9 +339,11 @@
 			break;
 
 		case SO_TIMESTAMP:
-			sk->sk_rcvtstamp = valbool;
-			if (valbool) 
+			if (valbool)  {
+				sock_set_flag(sk, SOCK_RCVTSTAMP);
 				sock_enable_timestamp(sk);
+			} else
+				sock_reset_flag(sk, SOCK_RCVTSTAMP);
 			break;
 
 		case SO_RCVLOWAT:
@@ -525,7 +527,7 @@
 			break;
 
 		case SO_TIMESTAMP:
-			v.val = sk->sk_rcvtstamp;
+			v.val = sock_flag(sk, SOCK_RCVTSTAMP);
 			break;
 
 		case SO_RCVTIMEO:
