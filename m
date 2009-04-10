From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] ipv6: Fix NULL pointer dereference with time-wait sockets
Date: Thu,  9 Apr 2009 23:37:33 -0400
Message-ID: <1239334653-5412-1-git-send-email-vladislav.yasevich@hp.com>
References: <200904072206.29396.edt@aei.ca>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:41397 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779AbZDJDhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 23:37:38 -0400
In-Reply-To: <200904072206.29396.edt@aei.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b2f5e7cd3dee2ed721bf0675e1a1ddebb849aee6
(ipv6: Fix conflict resolutions during ipv6 binding)
introduced a regression where time-wait sockets were
not treated correctly.  This resulted in the following:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000062
IP: [<ffffffff805d7d61>] ipv4_rcv_saddr_equal+0x61/0x70
...
Call Trace:
[<ffffffffa033847b>] ipv6_rcv_saddr_equal+0x1bb/0x250 [ipv6]
[<ffffffffa03505a8>] inet6_csk_bind_conflict+0x88/0xd0 [ipv6]
[<ffffffff805bb18e>] inet_csk_get_port+0x1ee/0x400
[<ffffffffa0319b7f>] inet6_bind+0x1cf/0x3a0 [ipv6]
[<ffffffff8056d17c>] ? sockfd_lookup_light+0x3c/0xd0
[<ffffffff8056ed49>] sys_bind+0x89/0x100
[<ffffffff80613ea2>] ? trace_hardirqs_on_thunk+0x3a/0x3c
[<ffffffff8020bf9b>] system_call_fastpath+0x16/0x1b

Tested-by: Brian Haley <brian.haley@hp.com>
Tested-by: Ed Tomlinson <edt@aei.ca>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/udp.h |    2 --
 net/ipv4/udp.c    |    3 +--
 net/ipv6/udp.c    |    6 +++++-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 93dbe29..90e6ce5 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -124,8 +124,6 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
-extern int	ipv4_rcv_saddr_equal(const struct sock *sk1,
-				    const struct sock *sk2);
 extern int	udp_lib_get_port(struct sock *sk, unsigned short snum,
 		int (*)(const struct sock*,const struct sock*));
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index bda08a0..7a1d1ce 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -222,7 +222,7 @@ fail:
 	return error;
 }
 
-int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
@@ -1823,7 +1823,6 @@ EXPORT_SYMBOL(udp_lib_getsockopt);
 EXPORT_SYMBOL(udp_lib_setsockopt);
 EXPORT_SYMBOL(udp_poll);
 EXPORT_SYMBOL(udp_lib_get_port);
-EXPORT_SYMBOL(ipv4_rcv_saddr_equal);
 
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 6842dd2..5ed54af 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -53,6 +53,8 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
 	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
+	__be32 sk_rcv_saddr = inet_sk(sk)->rcv_saddr;
+	__be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
 	int sk_ipv6only = ipv6_only_sock(sk);
 	int sk2_ipv6only = inet_v6_ipv6only(sk2);
 	int addr_type = ipv6_addr_type(sk_rcv_saddr6);
@@ -60,7 +62,9 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 
 	/* if both are mapped, treat as IPv4 */
 	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED)
-		return ipv4_rcv_saddr_equal(sk, sk2);
+		return (!sk2_ipv6only && 
+			(!sk_rcv_saddr || !sk2_rcv_saddr ||
+			  sk_rcv_saddr == sk2_rcv_saddr));
 
 	if (addr_type2 == IPV6_ADDR_ANY &&
 	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
-- 
1.5.4.3

