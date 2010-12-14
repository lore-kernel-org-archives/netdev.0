From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH net-2.6 v2] net: fix nulls list corruptions in sk_prot_alloc
Date: Tue, 14 Dec 2010 19:19:47 +0200
Message-ID: <1292347187-24154-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Leonard Crestez <lcrestez@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13214 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759415Ab0LNRUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 12:20:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Special care is taken inside sk_port_alloc to avoid overwriting
skc_node/skc_nulls_node. We should also avoid overwriting
skc_bind_node/skc_portaddr_node.

The patch fixes the following crash:

 BUG: unable to handle kernel paging request at fffffffffffffff0
 IP: [<ffffffff812ec6dd>] udp4_lib_lookup2+0xad/0x370
 [<ffffffff812ecc22>] __udp4_lib_lookup+0x282/0x360
 [<ffffffff812ed63e>] __udp4_lib_rcv+0x31e/0x700
 [<ffffffff812bba45>] ? ip_local_deliver_finish+0x65/0x190
 [<ffffffff812bbbf8>] ? ip_local_deliver+0x88/0xa0
 [<ffffffff812eda35>] udp_rcv+0x15/0x20
 [<ffffffff812bba45>] ip_local_deliver_finish+0x65/0x190
 [<ffffffff812bbbf8>] ip_local_deliver+0x88/0xa0
 [<ffffffff812bb2cd>] ip_rcv_finish+0x32d/0x6f0
 [<ffffffff8128c14c>] ? netif_receive_skb+0x99c/0x11c0
 [<ffffffff812bb94b>] ip_rcv+0x2bb/0x350
 [<ffffffff8128c14c>] netif_receive_skb+0x99c/0x11c0

Signed-off-by: Leonard Crestez <lcrestez@ixiacom.com>
Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: stable@kernel.org
---
 include/net/sock.h |    3 +++
 net/core/sock.c    |   47 +++++++++++++++++++++++++++++++++++------------
 net/ipv4/udp.c     |    1 +
 net/ipv4/udplite.c |    1 +
 net/ipv6/udp.c     |    1 +
 net/ipv6/udplite.c |    1 +
 6 files changed, 42 insertions(+), 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 659d968..7d3f7ce 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -754,6 +754,7 @@ struct proto {
 	void			(*unhash)(struct sock *sk);
 	void			(*rehash)(struct sock *sk);
 	int			(*get_port)(struct sock *sk, unsigned short snum);
+	void			(*clear_sk)(struct sock *sk, int size);
 
 	/* Keeping track of sockets in use */
 #ifdef CONFIG_PROC_FS
@@ -852,6 +853,8 @@ static inline void __sk_prot_rehash(struct sock *sk)
 	sk->sk_prot->hash(sk);
 }
 
+void sk_prot_clear_portaddr_nulls(struct sock *sk, int size);
+
 /* About 10 seconds */
 #define SOCK_DESTROY_TIME (10*HZ)
 
diff --git a/net/core/sock.c b/net/core/sock.c
index fb60801..d931388 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1009,6 +1009,36 @@ static void sock_copy(struct sock *nsk, const struct sock *osk)
 #endif
 }
 
+/*
+ * caches using SLAB_DESTROY_BY_RCU should let .next pointer from nulls nodes
+ * un-modified. Special care is taken when initializing object to zero.
+ */
+static inline void sk_prot_clear_nulls(struct sock *sk, int size)
+{
+	if (offsetof(struct sock, sk_node.next) != 0)
+		memset(sk, 0, offsetof(struct sock, sk_node.next));
+	memset(&sk->sk_node.pprev, 0,
+	       size - offsetof(struct sock, sk_node.pprev));
+}
+
+void sk_prot_clear_portaddr_nulls(struct sock *sk, int size)
+{
+	unsigned long nulls1, nulls2;
+
+	nulls1 = offsetof(struct sock, __sk_common.skc_node.next);
+	nulls2 = offsetof(struct sock, __sk_common.skc_portaddr_node.next);
+	if (nulls1 > nulls2)
+		swap(nulls1, nulls2);
+
+	if (nulls1 != 0)
+		memset((char *)sk, 0, nulls1);
+	memset((char *)sk + nulls1 + sizeof(void *), 0,
+	       nulls2 - nulls1 - sizeof(void *));
+	memset((char *)sk + nulls2 + sizeof(void *), 0,
+	       size - nulls2 - sizeof(void *));
+}
+
+
 static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		int family)
 {
@@ -1021,19 +1051,12 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		if (!sk)
 			return sk;
 		if (priority & __GFP_ZERO) {
-			/*
-			 * caches using SLAB_DESTROY_BY_RCU should let
-			 * sk_node.next un-modified. Special care is taken
-			 * when initializing object to zero.
-			 */
-			if (offsetof(struct sock, sk_node.next) != 0)
-				memset(sk, 0, offsetof(struct sock, sk_node.next));
-			memset(&sk->sk_node.pprev, 0,
-			       prot->obj_size - offsetof(struct sock,
-							 sk_node.pprev));
+			if (prot->clear_sk)
+				prot->clear_sk(sk, prot->obj_size);
+			else
+				sk_prot_clear_nulls(sk, prot->obj_size);
 		}
-	}
-	else
+	} else
 		sk = kmalloc(prot->obj_size, priority);
 
 	if (sk != NULL) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5e0a3a5..2d3ded4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1899,6 +1899,7 @@ struct proto udp_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
+	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 EXPORT_SYMBOL(udp_prot);
 
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index ab76aa9..aee9963 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -57,6 +57,7 @@ struct proto 	udplite_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
+	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 EXPORT_SYMBOL(udplite_prot);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 91def93..cd6cb7c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1477,6 +1477,7 @@ struct proto udpv6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
+	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 
 static struct inet_protosw udpv6_protosw = {
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 5f48fad..986c4de 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -55,6 +55,7 @@ struct proto udplitev6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
+	.clear_sk	   = sk_prot_clear_portaddr_nulls,
 };
 
 static struct inet_protosw udplite6_protosw = {
-- 
1.7.1

