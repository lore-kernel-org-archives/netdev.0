From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: inappropriate usage of inet{,6}_sk()
Date: Tue, 28 Oct 2003 20:08:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028.200855.55272006.yoshfuji@linux-ipv6.org>
References: <20031027.232700.97608602.yoshfuji@linux-ipv6.org>
	<20031028010418.6e8960a8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031028010418.6e8960a8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031028010418.6e8960a8.davem@redhat.com> (at Tue, 28 Oct 2003 01:04:18 -0800), "David S. Miller" <davem@redhat.com> says:

> Cannot reference inet6_sk() or tw->tw_v6_rcv_saddr outside of
> CONFIG_IPV6 || CONFIG_IPV6_MODULE since these things do not exist when
> those configs are both disabled.

Oh... Here's revised patch.

===== include/net/tcp.h 1.51 vs edited =====
--- 1.51/include/net/tcp.h	Thu Jul 10 11:18:02 2003
+++ edited/include/net/tcp.h	Tue Oct 28 20:05:11 2003
@@ -219,6 +219,7 @@
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct in6_addr		tw_v6_daddr;
 	struct in6_addr		tw_v6_rcv_saddr;
+	int			tw_v6_ipv6only;
 #endif
 };
 
@@ -266,6 +267,38 @@
 	hlist_for_each_entry_safe(tw, node, safe, jail, tw_death_node)
 
 #define tcptw_sk(__sk)	((struct tcp_tw_bucket *)(__sk))
+
+static inline const u32 tcp_v4_rcv_saddr(const struct sock *sk)
+{
+	return likely(sk->sk_state != TCP_TIME_WAIT) ?
+		inet_sk(sk)->rcv_saddr : tcptw_sk(sk)->tw_rcv_saddr;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline const struct in6_addr *__tcp_v6_rcv_saddr(const struct sock *sk)
+{
+	return likely(sk->sk_state != TCP_TIME_WAIT) ?
+		&inet6_sk(sk)->rcv_saddr : &tcptw_sk(sk)->tw_v6_rcv_saddr;
+}
+
+static inline const struct in6_addr *tcp_v6_rcv_saddr(const struct sock *sk)
+{
+	return sk->sk_family == AF_INET6 ? __tcp_v6_rcv_saddr(sk) : NULL;
+}
+
+#define tcptw_sk_ipv6only(__sk)	(tcptw_sk(__sk)->tw_v6_ipv6only)
+
+static inline int tcp_v6_ipv6only(const struct sock *sk)
+{
+	return likely(sk->sk_state != TCP_TIME_WAIT) ?
+		ipv6_only_sock(sk) : tcptw_sk_ipv6only(sk);
+}
+#else
+# define __tcp_v6_rcv_saddr(__sk)	NULL
+# define tcp_v6_rcv_saddr(__sk)		NULL
+# define tcptw_sk_ipv6only(__sk)	0
+# define tcp_v6_ipv6only(__sk)		0
+#endif
 
 extern kmem_cache_t *tcp_timewait_cachep;
 
===== net/ipv4/tcp_ipv4.c 1.74 vs edited =====
--- 1.74/net/ipv4/tcp_ipv4.c	Mon Oct 27 17:29:00 2003
+++ edited/net/ipv4/tcp_ipv4.c	Tue Oct 28 20:05:12 2003
@@ -178,12 +178,6 @@
 	tcp_sk(sk)->bind_hash = tb;
 }
 
-static inline const u32 tcp_v4_rcv_saddr(const struct sock *sk)
-{
-	return likely(sk->sk_state != TCP_TIME_WAIT) ?
-		inet_sk(sk)->rcv_saddr : tcptw_sk(sk)->tw_rcv_saddr;
-}
-
 static inline int tcp_bind_conflict(struct sock *sk, struct tcp_bind_bucket *tb)
 {
 	const u32 sk_rcv_saddr = tcp_v4_rcv_saddr(sk);
===== net/ipv4/tcp_minisocks.c 1.42 vs edited =====
--- 1.42/net/ipv4/tcp_minisocks.c	Mon Sep 29 06:37:15 2003
+++ edited/net/ipv4/tcp_minisocks.c	Tue Oct 28 20:05:12 2003
@@ -368,6 +368,11 @@
 
 			ipv6_addr_copy(&tw->tw_v6_daddr, &np->daddr);
 			ipv6_addr_copy(&tw->tw_v6_rcv_saddr, &np->rcv_saddr);
+			tw->tw_v6_ipv6only = np->ipv6only;
+		} else {
+			memset(&tw->tw_v6_daddr, 0, sizeof(tw->tw_v6_daddr));
+			memset(&tw->tw_v6_rcv_saddr, 0, sizeof(tw->tw_v6_rcv_saddr));
+			tw->tw_v6_ipv6only = 0;
 		}
 #endif
 		/* Linkage updates. */
===== net/ipv6/addrconf.c 1.73 vs edited =====
--- 1.73/net/ipv6/addrconf.c	Mon Oct 27 17:56:14 2003
+++ edited/net/ipv6/addrconf.c	Tue Oct 28 20:05:13 2003
@@ -970,36 +970,33 @@
 
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	int addr_type = ipv6_addr_type(&np->rcv_saddr);
+	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
+	const struct in6_addr *sk2_rcv_saddr6 = tcp_v6_rcv_saddr(sk2);
+	u32 sk_rcv_saddr = inet_sk(sk)->rcv_saddr;
+	u32 sk2_rcv_saddr = tcp_v4_rcv_saddr(sk2);
+	int sk_ipv6only = ipv6_only_sock(sk);
+	int sk2_ipv6only = tcp_v6_ipv6only(sk2);
+	int addr_type = ipv6_addr_type(sk_rcv_saddr6);
+	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
 
-	if (!inet_sk(sk2)->rcv_saddr && !ipv6_only_sock(sk))
+	if (!sk2_rcv_saddr && !sk_ipv6only)
 		return 1;
 
-	if (sk2->sk_family == AF_INET6 &&
-	    ipv6_addr_any(&inet6_sk(sk2)->rcv_saddr) &&
-	    !(ipv6_only_sock(sk2) && addr_type == IPV6_ADDR_MAPPED))
+	if (addr_type2 == IPV6_ADDR_ANY &&
+	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
 		return 1;
 
 	if (addr_type == IPV6_ADDR_ANY &&
-	    (!ipv6_only_sock(sk) ||
-	     !(sk2->sk_family == AF_INET6 ?
-	       (ipv6_addr_type(&inet6_sk(sk2)->rcv_saddr) == IPV6_ADDR_MAPPED) :
-	        1)))
+	    !(sk_ipv6only && addr_type2 == IPV6_ADDR_MAPPED))
 		return 1;
 
-	if (sk2->sk_family == AF_INET6 &&
-	    !ipv6_addr_cmp(&np->rcv_saddr,
-			   (sk2->sk_state != TCP_TIME_WAIT ?
-			    &inet6_sk(sk2)->rcv_saddr :
-			    &tcptw_sk(sk2)->tw_v6_rcv_saddr)))
+	if (sk2_rcv_saddr6 &&
+	    !ipv6_addr_cmp(sk_rcv_saddr6, sk2_rcv_saddr6))
 		return 1;
 
 	if (addr_type == IPV6_ADDR_MAPPED &&
-	    !ipv6_only_sock(sk2) &&
-	    (!inet_sk(sk2)->rcv_saddr ||
-	     !inet_sk(sk)->rcv_saddr ||
-	     inet_sk(sk)->rcv_saddr == inet_sk(sk2)->rcv_saddr))
+	    !sk2_ipv6only &&
+	    (!sk2_rcv_saddr || !sk_rcv_saddr || sk_rcv_saddr == sk2_rcv_saddr))
 		return 1;
 
 	return 0;


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
