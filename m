From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [RFC PATCH 4/4] ipv6: Fix conflict resolutions during ipv6 binding
Date: Tue, 17 Mar 2009 17:06:02 -0400
Message-ID: <1237323962-18635-5-git-send-email-vladislav.yasevich@hp.com>
References: <20090317.123146.210941276.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:6440 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbZCQVGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:06:10 -0400
In-Reply-To: <20090317.123146.210941276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 version of bind_conflict code calls ipv6_rcv_saddr_equal()
which at times wrongly identified intersections between addresses.
It particularly broke down under a few instances and caused erroneouse
bind conflicts.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/addrconf.h |    4 ++--
 include/net/udp.h      |    2 ++
 net/ipv4/udp.c         |    3 ++-
 net/ipv6/addrconf.c    |   34 ----------------------------------
 net/ipv6/udp.c         |   30 ++++++++++++++++++++++++++++++
 5 files changed, 36 insertions(+), 37 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index c216de5..7b55ab2 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -88,8 +88,8 @@ extern int			ipv6_dev_get_saddr(struct net *net,
 extern int			ipv6_get_lladdr(struct net_device *dev,
 						struct in6_addr *addr,
 						unsigned char banned_flags);
-extern int			ipv6_rcv_saddr_equal(const struct sock *sk, 
-						      const struct sock *sk2);
+extern int 			ipv6_rcv_saddr_equal(const struct sock *sk,
+						    const struct sock *sk2);
 extern void			addrconf_join_solict(struct net_device *dev,
 					struct in6_addr *addr);
 extern void			addrconf_leave_solict(struct inet6_dev *idev,
diff --git a/include/net/udp.h b/include/net/udp.h
index 90e6ce5..93dbe29 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -124,6 +124,8 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
+extern int	ipv4_rcv_saddr_equal(const struct sock *sk1,
+				    const struct sock *sk2);
 extern int	udp_lib_get_port(struct sock *sk, unsigned short snum,
 		int (*)(const struct sock*,const struct sock*));
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4bd178a..ce64e4d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -222,7 +222,7 @@ fail:
 	return error;
 }
 
-static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
@@ -1819,6 +1819,7 @@ EXPORT_SYMBOL(udp_lib_getsockopt);
 EXPORT_SYMBOL(udp_lib_setsockopt);
 EXPORT_SYMBOL(udp_poll);
 EXPORT_SYMBOL(udp_lib_get_port);
+EXPORT_SYMBOL(ipv4_rcv_saddr_equal);
 
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e83852a..00a37c1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1367,40 +1367,6 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 	return ifp;
 }
 
-int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
-{
-	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
-	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
-	__be32 sk_rcv_saddr = inet_sk(sk)->rcv_saddr;
-	__be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
-	int sk_ipv6only = ipv6_only_sock(sk);
-	int sk2_ipv6only = inet_v6_ipv6only(sk2);
-	int addr_type = ipv6_addr_type(sk_rcv_saddr6);
-	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
-
-	if (!sk2_rcv_saddr && !sk_ipv6only)
-		return 1;
-
-	if (addr_type2 == IPV6_ADDR_ANY &&
-	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
-		return 1;
-
-	if (addr_type == IPV6_ADDR_ANY &&
-	    !(sk_ipv6only && addr_type2 == IPV6_ADDR_MAPPED))
-		return 1;
-
-	if (sk2_rcv_saddr6 &&
-	    ipv6_addr_equal(sk_rcv_saddr6, sk2_rcv_saddr6))
-		return 1;
-
-	if (addr_type == IPV6_ADDR_MAPPED &&
-	    !sk2_ipv6only &&
-	    (!sk2_rcv_saddr || !sk_rcv_saddr || sk_rcv_saddr == sk2_rcv_saddr))
-		return 1;
-
-	return 0;
-}
-
 /* Gets referenced address, destroys ifaddr */
 
 static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 84b1a29..7e45761 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -49,6 +49,36 @@
 #include <linux/seq_file.h>
 #include "udp_impl.h"
 
+int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
+{
+	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
+	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
+	__be32 sk_rcv_saddr = inet_sk(sk)->rcv_saddr;
+	__be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
+	int sk_ipv6only = ipv6_only_sock(sk);
+	int sk2_ipv6only = inet_v6_ipv6only(sk2);
+	int addr_type = ipv6_addr_type(sk_rcv_saddr6);
+	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
+
+	/* if both are mapped, treat as IPv4 */
+	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED)
+		return ipv4_rcv_saddr_equal(sk, sk2);
+
+	if (addr_type2 == IPV6_ADDR_ANY &&
+	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
+		return 1;
+
+	if (addr_type == IPV6_ADDR_ANY &&
+	    !(sk_ipv6only && addr_type2 == IPV6_ADDR_MAPPED))
+		return 1;
+
+	if (sk2_rcv_saddr6 &&
+	    ipv6_addr_equal(sk_rcv_saddr6, sk2_rcv_saddr6))
+		return 1;
+
+	return 0;
+}
+
 int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
 	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal);
-- 
1.5.4.3

