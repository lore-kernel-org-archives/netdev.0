From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: put ipv6_rcv_saddr_equal() common place
Date: Mon, 30 Jun 2003 16:35:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030630.163517.41915691.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Put ipv6_rcv_saddr_equal() common place as comment says.
Thanks.

Index: linux-2.5/include/net/addrconf.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/addrconf.h,v
retrieving revision 1.10
diff -u -r1.10 addrconf.h
--- linux-2.5/include/net/addrconf.h	17 Apr 2003 00:35:02 -0000	1.10
+++ linux-2.5/include/net/addrconf.h	30 Jun 2003 06:12:24 -0000
@@ -68,6 +68,8 @@
 					       struct in6_addr *saddr,
 					       int onlink);
 extern int			ipv6_get_lladdr(struct net_device *dev, struct in6_addr *);
+extern int			ipv6_rcv_saddr_equal(const struct sock *sk, 
+						      const struct sock *sk2);
 extern void			addrconf_join_solict(struct net_device *dev,
 					struct in6_addr *addr);
 extern void			addrconf_leave_solict(struct net_device *dev,
Index: linux-2.5/net/ipv6/addrconf.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/addrconf.c,v
retrieving revision 1.43
diff -u -r1.43 addrconf.c
--- linux-2.5/net/ipv6/addrconf.c	21 Jun 2003 16:16:59 -0000	1.43
+++ linux-2.5/net/ipv6/addrconf.c	30 Jun 2003 06:12:25 -0000
@@ -66,6 +66,7 @@
 #include <net/ndisc.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
+#include <net/tcp.h>
 #include <net/ip.h>
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
@@ -967,6 +968,43 @@
 	read_unlock_bh(&addrconf_hash_lock);
 
 	return ifp;
+}
+
+int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	int addr_type = ipv6_addr_type(&np->rcv_saddr);
+
+	if (!inet_sk(sk2)->rcv_saddr && !ipv6_only_sock(sk))
+		return 1;
+
+	if (sk2->sk_family == AF_INET6 &&
+	    ipv6_addr_any(&inet6_sk(sk2)->rcv_saddr) &&
+	    !(ipv6_only_sock(sk2) && addr_type == IPV6_ADDR_MAPPED))
+		return 1;
+
+	if (addr_type == IPV6_ADDR_ANY &&
+	    (!ipv6_only_sock(sk) ||
+	     !(sk2->sk_family == AF_INET6 ?
+	       (ipv6_addr_type(&inet6_sk(sk2)->rcv_saddr) == IPV6_ADDR_MAPPED) :
+	        1)))
+		return 1;
+
+	if (sk2->sk_family == AF_INET6 &&
+	    !ipv6_addr_cmp(&np->rcv_saddr,
+			   (sk2->sk_state != TCP_TIME_WAIT ?
+			    &inet6_sk(sk2)->rcv_saddr :
+			    &tcptw_sk(sk)->tw_v6_rcv_saddr)))
+		return 1;
+
+	if (addr_type == IPV6_ADDR_MAPPED &&
+	    !ipv6_only_sock(sk2) &&
+	    (!inet_sk(sk2)->rcv_saddr ||
+	     !inet_sk(sk)->rcv_saddr ||
+	     inet_sk(sk)->rcv_saddr == inet_sk(sk2)->rcv_saddr))
+		return 1;
+
+	return 0;
 }
 
 /* Gets referenced address, destroys ifaddr */
Index: linux-2.5/net/ipv6/tcp_ipv6.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/tcp_ipv6.c,v
retrieving revision 1.51
diff -u -r1.51 tcp_ipv6.c
--- linux-2.5/net/ipv6/tcp_ipv6.c	21 Jun 2003 16:18:47 -0000	1.51
+++ linux-2.5/net/ipv6/tcp_ipv6.c	30 Jun 2003 06:12:25 -0000
@@ -93,43 +93,6 @@
 	return tcp_v6_hashfn(laddr, lport, faddr, fport);
 }
 
-static inline int ipv6_rcv_saddr_equal(struct sock *sk, struct sock *sk2)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	int addr_type = ipv6_addr_type(&np->rcv_saddr);
-
-	if (!inet_sk(sk2)->rcv_saddr && !ipv6_only_sock(sk))
-		return 1;
-
-	if (sk2->sk_family == AF_INET6 &&
-	    ipv6_addr_any(&inet6_sk(sk2)->rcv_saddr) &&
-	    !(ipv6_only_sock(sk2) && addr_type == IPV6_ADDR_MAPPED))
-		return 1;
-
-	if (addr_type == IPV6_ADDR_ANY &&
-	    (!ipv6_only_sock(sk) ||
-	     !(sk2->sk_family == AF_INET6 ?
-	       (ipv6_addr_type(&inet6_sk(sk2)->rcv_saddr) == IPV6_ADDR_MAPPED) :
-	        1)))
-		return 1;
-
-	if (sk2->sk_family == AF_INET6 &&
-	    !ipv6_addr_cmp(&np->rcv_saddr,
-			   (sk2->sk_state != TCP_TIME_WAIT ?
-			    &inet6_sk(sk2)->rcv_saddr :
-			    &((struct tcp_tw_bucket *)sk)->tw_v6_rcv_saddr)))
-		return 1;
-
-	if (addr_type == IPV6_ADDR_MAPPED &&
-	    !ipv6_only_sock(sk2) &&
-	    (!inet_sk(sk2)->rcv_saddr ||
-	     !inet_sk(sk)->rcv_saddr ||
-	     inet_sk(sk)->rcv_saddr == inet_sk(sk2)->rcv_saddr))
-		return 1;
-
-	return 0;
-}
-
 static inline int tcp_v6_bind_conflict(struct sock *sk,
 				       struct tcp_bind_bucket *tb)
 {
Index: linux-2.5/net/ipv6/udp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/udp.c,v
retrieving revision 1.38
diff -u -r1.38 udp.c
--- linux-2.5/net/ipv6/udp.c	21 Jun 2003 16:20:28 -0000	1.38
+++ linux-2.5/net/ipv6/udp.c	30 Jun 2003 06:12:25 -0000
@@ -59,43 +59,6 @@
 
 DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 
-/* XXX This is identical to tcp_ipv6.c:ipv6_rcv_saddr_equal, put
- * XXX it somewhere common. -DaveM
- */
-static __inline__ int udv6_rcv_saddr_equal(struct sock *sk, struct sock *sk2)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	int addr_type = ipv6_addr_type(&np->rcv_saddr);
-
-	if (!inet_sk(sk2)->rcv_saddr && !ipv6_only_sock(sk))
-		return 1;
-
-	if (sk2->sk_family == AF_INET6 && 
-	    ipv6_addr_any(&inet6_sk(sk2)->rcv_saddr) &&
-	    !(ipv6_only_sock(sk2) && addr_type == IPV6_ADDR_MAPPED))
-		return 1;
-
-	if (addr_type == IPV6_ADDR_ANY && 
-	    (!ipv6_only_sock(sk) || 
-	     !(sk2->sk_family == AF_INET6 ?
-	       (ipv6_addr_type(&inet6_sk(sk2)->rcv_saddr) == IPV6_ADDR_MAPPED) : 1)))
-		return 1;
-
-	if (sk2->sk_family == AF_INET6 && 
-	    !ipv6_addr_cmp(&inet6_sk(sk)->rcv_saddr,
-			   &inet6_sk(sk2)->rcv_saddr))
-		return 1;
-
-	if (addr_type == IPV6_ADDR_MAPPED &&
-	    !ipv6_only_sock(sk2) &&
-	    (!inet_sk(sk2)->rcv_saddr || 
-	     !inet_sk(sk)->rcv_saddr ||
-	     inet_sk(sk)->rcv_saddr == inet_sk(sk2)->rcv_saddr))
-		return 1;
-
-	return 0;
-}
-
 /* Grrr, addr_type already calculated by caller, but I don't want
  * to add some silly "cookie" argument to this method just for that.
  */
@@ -151,7 +114,7 @@
 			    sk2 != sk &&
 			    sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
 			    (!sk2->sk_reuse || !sk->sk_reuse) &&
-			    udv6_rcv_saddr_equal(sk, sk2))
+			    ipv6_rcv_saddr_equal(sk, sk2))
 				goto fail;
 		}
 	}


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
