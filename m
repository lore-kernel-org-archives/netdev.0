From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/11] [NET] Convert sk_localroute into SOCK_LOCALROUTE flag
Date: Wed, 9 Mar 2005 20:49:57 +0100
Message-ID: <20050309194957.GO31837@postel.suug.ch>
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

Also converts two manual routing TOS calculations to use the correct
macro.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc4.orig/include/net/route.h linux-2.6.11-rc4/include/net/route.h
--- linux-2.6.11-rc4.orig/include/net/route.h	2005-03-08 18:11:24.000000000 +0100
+++ linux-2.6.11-rc4/include/net/route.h	2005-03-09 01:24:35.000000000 +0100
@@ -44,7 +44,7 @@
 /* RTO_CONN is not used (being alias for 0), but preserved not to break
  * some modules referring to it. */
 
-#define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sk->sk_localroute)
+#define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
 
 struct inet_peer;
 struct rtable
diff -Nru linux-2.6.11-rc4.orig/include/net/sock.h linux-2.6.11-rc4/include/net/sock.h
--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-09 01:09:59.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-09 01:28:42.000000000 +0100
@@ -147,7 +147,6 @@
   *	@sk_max_ack_backlog - listen backlog set in listen()
   *	@sk_priority - %SO_PRIORITY setting
   *	@sk_type - socket type (%SOCK_STREAM, etc)
-  *	@sk_localroute - route locally only, %SO_DONTROUTE setting
   *	@sk_protocol - which protocol this socket belongs in this network family
   *	@sk_peercred - %SO_PEERCRED setting
   *	@sk_rcvlowat - %SO_RCVLOWAT setting
@@ -226,7 +225,6 @@
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
 	unsigned short		sk_type;
-	unsigned char		sk_localroute;
 	unsigned char		sk_protocol;
 	struct ucred		sk_peercred;
 	int			sk_rcvlowat;
@@ -386,6 +384,7 @@
 	SOCK_DBG, /* %SO_DEBUG setting */
 	SOCK_RCVTSTAMP, /* %SO_TIMESTAMP setting */
	SOCK_NO_LARGESEND, /* whether to sent large segments or not */
+	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
diff -Nru linux-2.6.11-rc4.orig/net/core/sock.c linux-2.6.11-rc4/net/core/sock.c
--- linux-2.6.11-rc4.orig/net/core/sock.c	2005-03-09 01:03:45.000000000 +0100
+++ linux-2.6.11-rc4/net/core/sock.c	2005-03-09 01:25:16.000000000 +0100
@@ -241,7 +241,10 @@
 			ret = -ENOPROTOOPT;
 		  	break;
 		case SO_DONTROUTE:
-			sk->sk_localroute = valbool;
+			if (valbool)
+				sock_set_flag(sk, SOCK_LOCALROUTE);
+			else
+				sock_reset_flag(sk, SOCK_LOCALROUTE);
 			break;
 		case SO_BROADCAST:
 			sock_valbool_flag(sk, SOCK_BROADCAST, valbool);
@@ -471,7 +474,7 @@
 			break;
 		
 		case SO_DONTROUTE:
-			v.val = sk->sk_localroute;
+			v.val = sock_flag(sk, SOCK_LOCALROUTE);
 			break;
 		
 		case SO_BROADCAST:
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/raw.c linux-2.6.11-rc4/net/ipv4/raw.c
--- linux-2.6.11-rc4.orig/net/ipv4/raw.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/raw.c	2005-03-09 01:26:29.000000000 +0100
@@ -457,7 +457,7 @@
 			daddr = ipc.opt->faddr;
 		}
 	}
-	tos = RT_TOS(inet->tos) | sk->sk_localroute;
+	tos = RT_CONN_FLAGS(sk);
 	if (msg->msg_flags & MSG_DONTROUTE)
 		tos |= RTO_ONLINK;
 
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/tcp_ipv4.c linux-2.6.11-rc4/net/ipv4/tcp_ipv4.c
--- linux-2.6.11-rc4.orig/net/ipv4/tcp_ipv4.c	2005-03-09 00:40:06.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/tcp_ipv4.c	2005-03-09 01:27:06.000000000 +0100
@@ -1866,7 +1866,7 @@
 
 	/* Query new route. */
 	err = ip_route_connect(&rt, daddr, 0,
-			       RT_TOS(inet->tos) | sk->sk_localroute,
+			       RT_CONN_FLAGS(sk),
 			       sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
 			       inet->sport, inet->dport, sk);
diff -Nru linux-2.6.11-rc4.orig/net/ipv4/udp.c linux-2.6.11-rc4/net/ipv4/udp.c
--- linux-2.6.11-rc4.orig/net/ipv4/udp.c	2005-03-08 18:11:28.000000000 +0100
+++ linux-2.6.11-rc4/net/ipv4/udp.c	2005-03-09 01:27:32.000000000 +0100
@@ -574,7 +574,8 @@
 		connected = 0;
 	}
 	tos = RT_TOS(inet->tos);
-	if (sk->sk_localroute || (msg->msg_flags & MSG_DONTROUTE) || 
+	if (sock_flag(sk, SOCK_LOCALROUTE) ||
+	    (msg->msg_flags & MSG_DONTROUTE) || 
 	    (ipc.opt && ipc.opt->is_strictroute)) {
 		tos |= RTO_ONLINK;
 		connected = 0;
