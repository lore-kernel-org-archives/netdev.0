From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/11] [NET] Convert sk_no_largesend into SOCK_NO_LARGESEND flag
Date: Wed, 9 Mar 2005 20:49:19 +0100
Message-ID: <20050309194919.GN31837@postel.suug.ch>
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
--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-09 01:03:45.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-09 01:08:01.000000000 +0100
@@ -134,7 +134,6 @@
   *	@sk_sndbuf - size of send buffer in bytes
   *	@sk_flags - %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE, %SO_OOBINLINE settings
   *	@sk_no_check - %SO_NO_CHECK setting, wether or not checkup packets
-  *	@sk_no_largesend - whether to sent large segments or not
   *	@sk_route_caps - route capabilities (e.g. %NETIF_F_TSO)
   *	@sk_lingertime - %SO_LINGER l_linger setting
   *	@sk_hashent - hash entry in several tables (e.g. tcp_ehash)
@@ -206,7 +205,6 @@
 	int			sk_sndbuf;
 	unsigned long 		sk_flags;
 	char		 	sk_no_check;
-	unsigned char		sk_no_largesend;
 	int			sk_route_caps;
 	unsigned long	        sk_lingertime;
 	int			sk_hashent;
@@ -387,6 +385,7 @@
 	SOCK_USE_WRITE_QUEUE, /* wheter to call sk->sk_write_space in sock_wfree */
 	SOCK_DBG, /* %SO_DEBUG setting */
 	SOCK_RCVTSTAMP, /* %SO_TIMESTAMP setting */
+	SOCK_NO_LARGESEND, /* whether to sent large segments or not */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
diff -Nru linux-2.6.11-rc4.orig/include/net/tcp.h linux-2.6.11-rc4/include/net/tcp.h
--- linux-2.6.11-rc4.orig/include/net/tcp.h	2005-03-08 18:11:24.000000000 +0100
+++ linux-2.6.11-rc4/include/net/tcp.h	2005-03-09 01:06:29.000000000 +0100
@@ -1914,7 +1914,7 @@
 {
 	sk->sk_route_caps = dst->dev->features;
 	if (sk->sk_route_caps & NETIF_F_TSO) {
-		if (sk->sk_no_largesend || dst->header_len)
+		if (sock_flag(sk, SOCK_NO_LARGESEND) || dst->header_len)
 			sk->sk_route_caps &= ~NETIF_F_TSO;
 	}
 }
diff -Nru linux-2.6.11-rc4.orig/include/net/tcp_ecn.h linux-2.6.11-rc4/include/net/tcp_ecn.h
--- linux-2.6.11-rc4.orig/include/net/tcp_ecn.h	2005-03-08 18:11:24.000000000 +0100
+++ linux-2.6.11-rc4/include/net/tcp_ecn.h	2005-03-09 01:06:42.000000000 +0100
@@ -33,7 +33,7 @@
 	if (sysctl_tcp_ecn && !(sk->sk_route_caps & NETIF_F_TSO)) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
-		sk->sk_no_largesend = 1;
+		sock_set_flag(sk, SOCK_NO_LARGESEND);
 	}
 }
 
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_input.c linux-2.6.11-rc4/net/ipv4/tcp_input.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_input.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_input.c	2005-03-09 01:07:20.000000000 +0100
@@ -977,7 +977,7 @@
 	 * Not good, but alternative is to resegment the queue. */
 	if (sk->sk_route_caps & NETIF_F_TSO) {
 		sk->sk_route_caps &= ~NETIF_F_TSO;
-		sk->sk_no_largesend = 1;
+		sock_set_flag(sk, SOCK_NO_LARGESEND);
 		tp->mss_cache = tp->mss_cache_std;
 	}
 
@@ -4507,7 +4507,7 @@
 
 		TCP_ECN_rcv_synack(tp, th);
 		if (tp->ecn_flags&TCP_ECN_OK)
-			sk->sk_no_largesend = 1;
+			sock_set_flag(sk, SOCK_NO_LARGESEND);
 
 		tp->snd_wl1 = TCP_SKB_CB(skb)->seq;
 		tcp_ack(sk, skb, FLAG_SLOWPATH);
@@ -4645,7 +4645,7 @@
 
 		TCP_ECN_rcv_syn(tp, th);
 		if (tp->ecn_flags&TCP_ECN_OK)
-			sk->sk_no_largesend = 1;
+			sock_set_flag(sk, SOCK_NO_LARGESEND);
 
 		tcp_sync_mss(sk, tp->pmtu_cookie);
 		tcp_initialize_rcv_mss(sk);
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_minisocks.c linux-2.6.11-rc4/net/ipv4/tcp_minisocks.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_minisocks.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_minisocks.c	2005-03-09 01:07:30.000000000 +0100
@@ -841,7 +841,7 @@
 		newtp->rx_opt.mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
 		if (newtp->ecn_flags&TCP_ECN_OK)
-			newsk->sk_no_largesend = 1;
+			sock_set_flag(newsk, SOCK_NO_LARGESEND);
 
 		tcp_ca_init(newtp);
 
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_output.c linux-2.6.11-rc4/net/ipv4/tcp_output.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_output.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_output.c	2005-03-09 01:07:56.000000000 +0100
@@ -1040,7 +1040,7 @@
 
 		if (sk->sk_route_caps & NETIF_F_TSO) {
 			sk->sk_route_caps &= ~NETIF_F_TSO;
-			sk->sk_no_largesend = 1;
+			sock_set_flag(sk, SOCK_NO_LARGESEND);
 			tp->mss_cache = tp->mss_cache_std;
 		}
 
@@ -1669,7 +1669,7 @@
 				/* SWS override triggered forced fragmentation.
 				 * Disable TSO, the connection is too sick. */
 				if (sk->sk_route_caps & NETIF_F_TSO) {
-					sk->sk_no_largesend = 1;
+					sock_set_flag(sk, SOCK_NO_LARGESEND);
 					sk->sk_route_caps &= ~NETIF_F_TSO;
 					tp->mss_cache = tp->mss_cache_std;
 				}
