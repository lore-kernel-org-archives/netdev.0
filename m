From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/2] udp: UDP Fast Port
Date: Sat, 26 Jul 2014 15:29:23 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407261519050.27164@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:41398 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307AbaGZW3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 18:29:25 -0400
Received: by mail-oi0-f73.google.com with SMTP id u20so1352695oif.0
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2014 15:29:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements fast ports in UDP. The idea is that a kernel
module registers a port and associated receive function. In UDP receive,
the list of fast ports is scanned and the destinaton port is matched
against the registered port. If there is a match, then the receive
function is called to process the packet. When a UDP fast port is used,
we can receive encap'ed packets without performing or accessing a
socket. This is a performance gain, especially since we don't need to
take socket ref count on every packet.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/udp.h | 23 +++++++++++++++++++
 net/ipv4/udp.c    | 69 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 net/ipv6/udp.c    | 21 +++++++++++++++--
 3 files changed, 108 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 70f9413..1a88f4b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -300,6 +300,29 @@ void udp4_proc_exit(void);
 
 int udpv4_offload_init(void);
 
+/* Definitions for UDP fast port */
+
+#define UFP_HASH_SIZE (16)
+#define UFP_HASH_MASK (UFP_HASH_SIZE - 1)
+
+struct udp_fast_port {
+	__be16 port;
+	int (*encap_rcv)(struct udp_fast_port *ufp, struct sk_buff *skb);
+	void *priv_data;
+	struct list_head list;
+};
+
+extern struct list_head ufp_base[];
+
+static inline struct list_head *ufp_head(const __be16 port)
+{
+	return &ufp_base[ntohs(port) & UFP_HASH_MASK];
+}
+
+void udp_add_fast_port(struct udp_fast_port *ufp);
+void __udp_remove_fast_port(struct udp_fast_port *ufp);
+void udp_remove_fast_port(struct udp_fast_port *ufp);
+
 void udp_init(void);
 
 void udp_encap_enable(void);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f57c0e4..8cf359a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -131,6 +131,10 @@ EXPORT_SYMBOL(udp_memory_allocated);
 #define MAX_UDP_PORTS 65536
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
+struct list_head ufp_base[UFP_HASH_SIZE] __read_mostly;
+EXPORT_SYMBOL(ufp_base);
+static DEFINE_SPINLOCK(ufp_lock);
+
 static int udp_lib_lport_inuse(struct net *net, __u16 num,
 			       const struct udp_hslot *hslot,
 			       unsigned long *bitmap,
@@ -1735,6 +1739,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	struct rtable *rt = skb_rtable(skb);
 	__be32 saddr, daddr;
 	struct net *net = dev_net(skb->dev);
+	int ret;
 
 	/*
 	 *  Validate the packet.
@@ -1763,7 +1768,6 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	sk = skb_steal_sock(skb);
 	if (sk) {
 		struct dst_entry *dst = skb_dst(skb);
-		int ret;
 
 		if (unlikely(sk->sk_rx_dst != dst))
 			udp_sk_rx_dst_set(sk, dst);
@@ -1777,16 +1781,33 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 			return -ret;
 		return 0;
 	} else {
+		struct udp_fast_port *ufp;
+
 		if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 			return __udp4_lib_mcast_deliver(net, skb, uh,
 					saddr, daddr, udptable);
 
+		/* Check for a UDP fast port */
+		list_for_each_entry_rcu(ufp, ufp_head(uh->dest), list) {
+			if (uh->dest != ufp->port)
+				continue;
+
+			/* Verify checksum before giving to encap */
+			if (udp_lib_checksum_complete(skb))
+				goto csum_error;
+
+			ret = ufp->encap_rcv(ufp, skb);
+			if (ret <= 0) {
+				UDP_INC_STATS_BH(net, UDP_MIB_INDATAGRAMS,
+						 proto == IPPROTO_UDPLITE);
+				return -ret;
+			}
+		}
+
 		sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 	}
 
 	if (sk != NULL) {
-		int ret;
-
 		ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
@@ -1981,6 +2002,44 @@ int udp_rcv(struct sk_buff *skb)
 	return __udp4_lib_rcv(skb, &udp_table, IPPROTO_UDP);
 }
 
+void udp_add_fast_port(struct udp_fast_port *ufp)
+{
+	struct list_head *head = ufp_head(ufp->port);
+
+	spin_lock(&ufp_lock);
+	list_add_rcu(&ufp->list, head);
+	spin_unlock(&ufp_lock);
+}
+EXPORT_SYMBOL(udp_add_fast_port);
+
+void __udp_remove_fast_port(struct udp_fast_port *ufp)
+{
+	struct list_head *head = ufp_head(ufp->port);
+	struct udp_fast_port *ufp1;
+
+	spin_lock(&ufp_lock);
+
+	list_for_each_entry(ufp1, head, list) {
+		if (ufp == ufp1) {
+			list_del_rcu(&ufp->list);
+			goto out;
+		}
+	}
+
+	pr_warn("udp_remove_fast_port: %p not found\n", ufp);
+out:
+	spin_unlock(&ufp_lock);
+}
+EXPORT_SYMBOL(__udp_remove_fast_port);
+
+void udp_remove_fast_port(struct udp_fast_port *ufp)
+{
+	__udp_remove_fast_port(ufp);
+
+	synchronize_net();
+}
+EXPORT_SYMBOL(udp_remove_fast_port);
+
 void udp_destroy_sock(struct sock *sk)
 {
 	struct udp_sock *up = udp_sk(sk);
@@ -2505,6 +2564,7 @@ void __init udp_table_init(struct udp_table *table, const char *name)
 void __init udp_init(void)
 {
 	unsigned long limit;
+	int i;
 
 	udp_table_init(&udp_table, "UDP");
 	limit = nr_free_buffer_pages() / 8;
@@ -2515,4 +2575,7 @@ void __init udp_init(void)
 
 	sysctl_udp_rmem_min = SK_MEM_QUANTUM;
 	sysctl_udp_wmem_min = SK_MEM_QUANTUM;
+
+	for (i = 0; i < UFP_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&ufp_base[i]);
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5b6091d..e928182 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -830,6 +830,8 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	struct udphdr *uh;
 	const struct in6_addr *saddr, *daddr;
 	u32 ulen = 0;
+	struct udp_fast_port *ufp;
+	int ret;
 
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		goto discard;
@@ -873,14 +875,29 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 
 	/* Unicast */
 
+	/* Check for a UDP fast port */
+	list_for_each_entry_rcu(ufp, ufp_head(uh->dest), list) {
+		if (uh->dest != ufp->port)
+			continue;
+
+		/* Verify checksum before giving to encap */
+		if (udp_lib_checksum_complete(skb))
+			goto csum_error;
+
+		ret = ufp->encap_rcv(ufp, skb);
+		if (ret <= 0) {
+			UDP_INC_STATS_BH(net, UDP_MIB_INDATAGRAMS,
+					 proto == IPPROTO_UDPLITE);
+			return -ret;
+		}
+	}
+
 	/*
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
 	sk = __udp6_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 	if (sk != NULL) {
-		int ret;
-
 		if (!uh->check && !udp_sk(sk)->no_check6_rx) {
 			sock_put(sk);
 			udp6_csum_zero_error(skb);
-- 
2.0.0.526.g5318336
