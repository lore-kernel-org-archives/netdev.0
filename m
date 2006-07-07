From: akpm@osdl.org
Subject: [patch 2/2] lockdep: fix sk_dst_check() deadlock
Date: Thu, 06 Jul 2006 23:59:10 -0700
Message-ID: <200607070659.k676xAZ5030445@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, mingo@elte.hu,
	arjan@linux.intel.com, herbert@gondor.apana.org.au, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:38594 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751229AbWGGHAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 03:00:06 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>

Split off __icmpv6_socket's sk->sk_dst_lock class, because it gets used
from softirqs, which is safe for __icmpv6_sockets (because they never get
directly used via userspace syscalls), but unsafe for normal sockets.

Has no effect on non-lockdep kernels.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/ipv6/icmp.c |   13 +++++++++++++
 1 files changed, 13 insertions(+)

diff -puN net/ipv6/icmp.c~lockdep-fix-sk_dst_check-deadlock net/ipv6/icmp.c
--- a/net/ipv6/icmp.c~lockdep-fix-sk_dst_check-deadlock
+++ a/net/ipv6/icmp.c
@@ -712,6 +712,11 @@ discard_it:
 	return 0;
 }
 
+/*
+ * Special lock-class for __icmpv6_socket:
+ */
+static struct lock_class_key icmpv6_socket_sk_dst_lock_key;
+
 int __init icmpv6_init(struct net_proto_family *ops)
 {
 	struct sock *sk;
@@ -730,6 +735,14 @@ int __init icmpv6_init(struct net_proto_
 
 		sk = per_cpu(__icmpv6_socket, i)->sk;
 		sk->sk_allocation = GFP_ATOMIC;
+		/*
+		 * Split off their lock-class, because sk->sk_dst_lock
+		 * gets used from softirqs, which is safe for
+		 * __icmpv6_socket (because those never get directly used
+		 * via userspace syscalls), but unsafe for normal sockets.
+		 */
+		lockdep_set_class(&sk->sk_dst_lock,
+				  &icmpv6_socket_sk_dst_lock_key);
 
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff struct overhead.
_
