From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] fixing the cases where tcp_tw_bucket was accessed as a sock
Date: Sun, 12 Oct 2003 10:13:44 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031012131344.GH16182@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

	Please take a look and see if it is OK.

	The WARN_ON is just to be paranoid for a while, I should have done
that a loooong time ago :-\

Best regards,

- Arnaldo

===== include/linux/ip.h 1.10 vs edited =====
--- 1.10/include/linux/ip.h	Fri May 16 18:02:36 2003
+++ edited/include/linux/ip.h	Thu Oct  9 23:36:06 2003
@@ -157,7 +157,13 @@
 	struct inet_opt   inet;
 };
 
+#if 0
 #define inet_sk(__sk) (&((struct inet_sock *)__sk)->inet)
+#else
+#include <linux/tcp.h>
+#define inet_sk(__sk) ({ WARN_ON(__sk->sk_state == TCP_TIME_WAIT); \
+			 (&((struct inet_sock *)__sk)->inet); })
+#endif
 
 #endif
 
===== include/net/tcp.h 1.51 vs edited =====
--- 1.51/include/net/tcp.h	Wed Jul  9 23:18:02 2003
+++ edited/include/net/tcp.h	Sat Oct 11 22:38:24 2003
@@ -267,6 +267,12 @@
 
 #define tcptw_sk(__sk)	((struct tcp_tw_bucket *)(__sk))
 
+static inline const u32 inet_rcv_saddr(const struct sock *sk)
+{
+	return likely(sk->sk_state != TCP_TIME_WAIT) ?
+		inet_sk(sk)->rcv_saddr : tcptw_sk(sk)->tw_rcv_saddr;
+}
+
 extern kmem_cache_t *tcp_timewait_cachep;
 
 static inline void tcp_tw_put(struct tcp_tw_bucket *tw)
===== net/ipv4/tcp_ipv4.c 1.69 vs edited =====
--- 1.69/net/ipv4/tcp_ipv4.c	Wed Oct  8 12:27:40 2003
+++ edited/net/ipv4/tcp_ipv4.c	Fri Oct 10 13:16:57 2003
@@ -180,7 +180,7 @@
 
 static inline int tcp_bind_conflict(struct sock *sk, struct tcp_bind_bucket *tb)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	const u32 sk_rcv_saddr = inet_rcv_saddr(sk);
 	struct sock *sk2;
 	struct hlist_node *node;
 	int reuse = sk->sk_reuse;
@@ -193,9 +193,9 @@
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
 			if (!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state == TCP_LISTEN) {
-				struct inet_opt *inet2 = inet_sk(sk2);
-				if (!inet2->rcv_saddr || !inet->rcv_saddr ||
-				    inet2->rcv_saddr == inet->rcv_saddr)
+				const u32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
+				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
+				    sk2_rcv_saddr == sk_rcv_saddr)
 					break;
 			}
 		}
===== net/ipv6/addrconf.c 1.68 vs edited =====
--- 1.68/net/ipv6/addrconf.c	Fri Sep 12 21:25:13 2003
+++ edited/net/ipv6/addrconf.c	Sat Oct 11 23:50:31 2003
@@ -963,38 +963,41 @@
 	return ifp;
 }
 
+static inline const struct in6_addr *inet6_rcv_saddr(const struct sock *sk)
+{
+	return likely(sk->sk_state != TCP_TIME_WAIT) ?
+		&inet6_sk(sk)->rcv_saddr : &tcptw_sk(sk)->tw_v6_rcv_saddr;
+}
+
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	int addr_type = ipv6_addr_type(&np->rcv_saddr);
 
-	if (!inet_sk(sk2)->rcv_saddr && !ipv6_only_sock(sk))
+	if (!inet_rcv_saddr(sk2) && !ipv6_only_sock(sk))
 		return 1;
 
 	if (sk2->sk_family == AF_INET6 &&
-	    ipv6_addr_any(&inet6_sk(sk2)->rcv_saddr) &&
+	    ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
 	    !(ipv6_only_sock(sk2) && addr_type == IPV6_ADDR_MAPPED))
 		return 1;
 
 	if (addr_type == IPV6_ADDR_ANY &&
 	    (!ipv6_only_sock(sk) ||
 	     !(sk2->sk_family == AF_INET6 ?
-	       (ipv6_addr_type(&inet6_sk(sk2)->rcv_saddr) == IPV6_ADDR_MAPPED) :
-	        1)))
+	       (ipv6_addr_type(inet6_rcv_saddr(sk2)) == IPV6_ADDR_MAPPED) : 1)))
 		return 1;
 
 	if (sk2->sk_family == AF_INET6 &&
 	    !ipv6_addr_cmp(&np->rcv_saddr,
-			   (sk2->sk_state != TCP_TIME_WAIT ?
-			    &inet6_sk(sk2)->rcv_saddr :
-			    &tcptw_sk(sk)->tw_v6_rcv_saddr)))
+		    	   inet6_rcv_saddr(sk2)));
 		return 1;
 
 	if (addr_type == IPV6_ADDR_MAPPED &&
 	    !ipv6_only_sock(sk2) &&
-	    (!inet_sk(sk2)->rcv_saddr ||
+	    (!inet_rcv_saddr(sk2) ||
 	     !inet_sk(sk)->rcv_saddr ||
-	     inet_sk(sk)->rcv_saddr == inet_sk(sk2)->rcv_saddr))
+	     inet_sk(sk)->rcv_saddr == inet_rcv_saddr(sk2)))
 		return 1;
 
 	return 0;
