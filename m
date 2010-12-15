From: "Fenghua Yu" <fenghua.yu@intel.com>
Subject: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Wed, 15 Dec 2010 12:02:04 -0800
Message-ID: <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
Cc: "netdev" <netdev@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Xinan Tang <xinan.tang@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"John Fastabend" <john.r.fastabend@intel.com>,
	"Xinan Tang" <xinan.tang@intel.com>,
	"Junchang Wang"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:5800 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755063Ab0LOUOK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 15:14:10 -0500
In-Reply-To: <cover.1292405004.git.fenghua.yu@intel.com>
In-Reply-To: <cover.1292405004.git.fenghua.yu@intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fenghua Yu <fenghua.yu@intel.com>

Multiqueue and multicore provide packet parallel processing methodology.
Current kernel and network drivers place one queue on one core. But the higher
level socket doesn't know multiqueue. Current socket only can receive or send
packets through one network interfaces. In some cases e.g. multi bpf filter
tcpdump and snort, a lot of contentions come from socket operations like ring
buffer. Even if the application itself has been fully parallelized and run on
multi-core systems and NIC handlex tx/rx in multiqueue in parallel, network layer
and NIC device driver assemble packets to a single, serialized queue. Thus the
application cannot actually run in parallel in high speed.

To break the serialized packets assembling bottleneck in kernel, one way is to
allow socket to know multiqueue associated with a NIC interface. So each socket
can handle tx/rx in one queue in parallel.

Kernel provides several interfaces by which sockets can be bound to rx/tx queues.
User applications can configure socket by providing several sockets that each
bound to a single queue, applications can get data from kernel in parallel. After
that, competitions mentioned above can be removed.

With this patch, the user-space receiving speed on a Intel SR1690 server with
a single L5640 6-core processor and a single ixgbe-based NIC goes from 0.73Mpps
to 4.20Mpps, nearly a linear speedup. A Intel SR1625 server two E5530 4-core
processors and a single ixgbe-based NIC goes from 0.80Mpps to 4.6Mpps. We noticed
the performance penalty comes from NUMA memory allocation.

This patch set provides kernel ioctl interfaces for user space. User space can
either directly call the interfaces or libpcap interfaces can be further provided
on the top of the kernel ioctl interfaces.

The order of tx/rx packets is up to user application. In some cases, e.g. network
monitors, ordering is not a big problem because they more care how to receive and
analyze packets in highest performance in parallel.

This patch set only implements multiqueue interfaces for AF_PACKET and Intel
ixgbe NIC. Other protocols and NIC's can be handled on the top of this patch set.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Junchang Wang <junchangwang@gmail.com>
Signed-off-by: Xinan Tang <xinan.tang@intel.com>
---
 include/linux/sockios.h |    7 +++++++
 include/net/sock.h      |   18 ++++++++++++++++++
 net/core/sock.c         |    4 +++-
 3 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index 241f179..b121d9a 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -66,6 +66,13 @@
 #define	SIOCSIFHWBROADCAST	0x8937	/* set hardware broadcast addr	*/
 #define SIOCGIFCOUNT	0x8938		/* get number of devices */
 
+#define SIOGNUMRXQUEUE	0x8939	/* Get number of rx queues. */
+#define SIOGNUMTXQUEUE	0x893A	/* Get number of tx queues. */
+#define SIOSRXQUEUEMAPPING	0x893B	/* Set rx queue mapping. */
+#define SIOSTXQUEUEMAPPING	0x893C	/* Set tx queue mapping. */
+#define SIOGRXQUEUEMAPPING	0x893D	/* Get rx queue mapping. */
+#define SIOGTXQUEUEMAPPING	0x893E	/* Get tx queue mapping. */
+
 #define SIOCGIFBR	0x8940		/* Bridging support		*/
 #define SIOCSIFBR	0x8941		/* Set bridging options 	*/
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 659d968..d677bba 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -109,6 +109,7 @@ struct net;
  *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
  *	@skc_refcnt: reference count
  *	@skc_tx_queue_mapping: tx queue number for this connection
+ *	@skc_rx_queue_mapping: rx queue number for this connection
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_u16hashes: two u16 hash values used by UDP lookup tables
  *	@skc_family: network address family
@@ -133,6 +134,7 @@ struct sock_common {
 	};
 	atomic_t		skc_refcnt;
 	int			skc_tx_queue_mapping;
+	int			skc_rx_queue_mapping;
 
 	union  {
 		unsigned int	skc_hash;
@@ -231,6 +233,7 @@ struct sock {
 #define sk_nulls_node		__sk_common.skc_nulls_node
 #define sk_refcnt		__sk_common.skc_refcnt
 #define sk_tx_queue_mapping	__sk_common.skc_tx_queue_mapping
+#define sk_rx_queue_mapping	__sk_common.skc_rx_queue_mapping
 
 #define sk_copy_start		__sk_common.skc_hash
 #define sk_hash			__sk_common.skc_hash
@@ -1234,6 +1237,21 @@ static inline int sk_tx_queue_get(const struct sock *sk)
 	return sk ? sk->sk_tx_queue_mapping : -1;
 }
 
+static inline void sk_rx_queue_set(struct sock *sk, int rx_queue)
+{
+	sk->sk_rx_queue_mapping = rx_queue;
+}
+
+static inline int sk_rx_queue_get(const struct sock *sk)
+{
+	return sk ? sk->sk_rx_queue_mapping : -1;
+}
+
+static inline void sk_rx_queue_clear(struct sock *sk)
+{
+	sk->sk_rx_queue_mapping = -1;
+}
+
 static inline void sk_set_socket(struct sock *sk, struct socket *sock)
 {
 	sk_tx_queue_clear(sk);
diff --git a/net/core/sock.c b/net/core/sock.c
index fb60801..9ad92cb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1000,7 +1000,8 @@ static void sock_copy(struct sock *nsk, const struct sock *osk)
 #endif
 	BUILD_BUG_ON(offsetof(struct sock, sk_copy_start) !=
 		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt) +
-		     sizeof(osk->sk_tx_queue_mapping));
+		     sizeof(osk->sk_tx_queue_mapping) +
+		     sizeof(osk->sk_rx_queue_mapping));
 	memcpy(&nsk->sk_copy_start, &osk->sk_copy_start,
 	       osk->sk_prot->obj_size - offsetof(struct sock, sk_copy_start));
 #ifdef CONFIG_SECURITY_NETWORK
@@ -1045,6 +1046,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
 		sk_tx_queue_clear(sk);
+		sk_rx_queue_clear(sk);
 	}
 
 	return sk;
-- 
1.6.0.3

