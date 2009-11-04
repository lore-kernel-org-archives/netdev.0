From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Wed, 04 Nov 2009 23:03:20 +0200
Message-ID: <4AF1EC18.9090106@ixiacom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000905000207050801090805"
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:14036 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758106AbZKDVDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:03:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000905000207050801090805
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit

Hi,

Before you look at the patch attached: I know it's not the prettiest of patches sent here. It's a work-in-progress and is ugly and incomplete (for example IPv6 is not properly updated to benefit this patch and may even be as buggy as hell right now).
I'm sending it here to ask for an opinion on the approach.

The current approach uses one single hash to lookup UDP sockets.
The key to the hash is calculated based on the port only.
This works well if there aren't many sockets bound to the same port, but becomes a linear linked list search for a setup with many UPD packets bound to the same port, which does not scale much.

In this patch the hashtable lookup key takes into consideration the address the socket is bound to too.
This will lead to better distribution for setup where there are many UDP sockets bound to the same port but different IP addresses.

There's a subtle bug lurking here: because some sockets may be bound to INADDR_ANY when checking whether a given UPD port is already taken one must search two buckets:
* one with the key computed from the port and for the IP address of the socket
* one with the key computed from the port and INADDR_ANY

Now if the address by which we must do the lookup is INADDR_ANY there's another problem: we can't just search it's own bucket and the bucket for INADDR_ANY (the same bucket twice) like above because there might be a socket bound to a specific address and the port we're trying to bind to.

In this case we could search the whole hash (which would take forever) or use another hash that is computed based on the port only (which this patch does).

There are other things to look after: when modifying the hashes we must take spin_locks or spin_lock_bhs. Because we now have two hashtables and one hashtable might be searched twice locks must be taken in the proper order.

I ran the attached UDP tester: it's a program that binds to a lot of UDP sockets and if run as a sender it sends lots of datagrams to the receiver which will just count the number of packets recevied.



== Performance stats ==
I ran this on a 2.6.31 with and without the patch on two powerpc single core processors connected directly by 100Mbps ethernet.

* nsocks      = number of IPv4 bound sockets
* ndgrams     = number of datagrams sent by each socket
* payloadlen  = the lenght of the UPD message sent
* send_time   = how many second did the sending operation take?
* recv_dgrams = how many datagrams were successfully received?


1. nsocks=512 ndgrams=2000 payloadlen=1
- without patch:
	* send_time   = 27s to 31s
	* recv_dgrams = 550 to 850
- with patch:
	* send_time   = 35s to 36s
	* recv_dgrams = 507000 to 516000

2. nsocks=512 ndgrams=4000 payloadlen=1
- without patch:
	* send_time   = 53s to 60s
	* recv_dgrams = 650 to 1100
- with patch:
	* send_time   = ~70s
	* recv_dgrams = 1010000 to 1034000

3. nsocks=512 ndgrams=4000 payloadlen=1000
- without patch:
	* send_time   = ~74s
	* recv_dgrams = 650
- with patch:
	* send_time   = ~88s
	* recv_dgrams = 995000

4. nsocks=256 ndgrams=2000 payloadlen=1
- without patch:
	* send_time   = 13s
	* recv_dgrams = 370 to 720
- with patch:
	* send_time   = 17s
	* recv_dgrams = 267000


As you can see this has a hit on total send time, but the number of received packets increases by two orders of magnitude.

I'd like hear your opinion about this approach.
If you'd like to test this, I'll be happy to port it to net-next and provide the patch.


--
Lucian

--------------000905000207050801090805
Content-Type: text/x-patch;
 name="upd-two-sock-hashes-v1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="upd-two-sock-hashes-v1.patch"

--- arch/powerpc/configs/ixia_ppc750_defconfig
+++ arch/powerpc/configs/ixia_ppc750_defconfig
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.31-rc5
-# Thu Aug 13 17:15:17 2009
+# Linux kernel version: 2.6.31
+# Mon Nov  2 22:05:36 2009
 #
 # CONFIG_PPC64 is not set
 
@@ -287,6 +287,7 @@
 #
 # Networking options
 #
+CONFIG_NETDEV_HASHBITS=10
 # CONFIG_NET_SYSCTL_DEV is not set
 CONFIG_PACKET=y
 CONFIG_PACKET_MMAP=y
--- include/linux/udp.h
+++ include/linux/udp.h
@@ -45,7 +45,7 @@
 	return (struct udphdr *)skb_transport_header(skb);
 }
 
-#define UDP_HTABLE_SIZE		128
+#define UDP_HTABLE_SIZE		(1 << CONFIG_NETDEV_HASHBITS)
 
 static inline int udp_hashfn(struct net *net, const unsigned num)
 {
--- include/net/sock.h
+++ include/net/sock.h
@@ -173,6 +173,7 @@
  *	@skc_bound_rx_dev_if: bound rx device index if != 0
  *	@skc_bound_tx_dev_if: bound tx device index if != 0
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
+ *	@skc_nulls_bind_node: bind hash linkage for UDP/UDP-Lite protocol
  *	@skc_prot: protocol handlers inside a network family
  *	@skc_net: reference to the network namespace of this socket
  *
@@ -195,7 +196,10 @@
 	unsigned char		skc_reuse;
 	int			skc_bound_rx_dev_if;
 	int			skc_bound_tx_dev_if;
-	struct hlist_node	skc_bind_node;
+	union {
+		struct hlist_node	skc_bind_node;
+		struct hlist_nulls_node skc_nulls_bind_node;
+	};
 	struct proto		*skc_prot;
 #ifdef CONFIG_NET_NS
 	struct net	 	*skc_net;
@@ -287,6 +291,7 @@
 #define sk_bound_rx_dev_if	__sk_common.skc_bound_rx_dev_if
 #define sk_bound_tx_dev_if	__sk_common.skc_bound_tx_dev_if
 #define sk_bind_node		__sk_common.skc_bind_node
+#define sk_nulls_bind_node	__sk_common.skc_nulls_bind_node
 #define sk_prot			__sk_common.skc_prot
 #define sk_net			__sk_common.skc_net
 #define sk_vlanprio		__sk_common.skc_vlanprio
@@ -495,6 +500,11 @@
 	return 0;
 }
 
+static __inline__ void __sk_nulls_del_bind_node_init_rcu(struct sock *sk)
+{
+	hlist_nulls_del_init_rcu(&sk->sk_nulls_bind_node);
+}
+
 static __inline__ int sk_nulls_del_node_init_rcu(struct sock *sk)
 {
 	int rc = __sk_nulls_del_node_init_rcu(sk);
@@ -523,6 +533,11 @@
 	hlist_nulls_add_head_rcu(&sk->sk_nulls_node, list);
 }
 
+static __inline__ void __sk_nulls_add_bind_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
+{
+	hlist_nulls_add_head_rcu(&sk->sk_nulls_bind_node, list);
+}
+
 static __inline__ void sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
 {
 	sock_hold(sk);
@@ -559,6 +574,8 @@
 	hlist_for_each_entry_safe(__sk, node, tmp, list, sk_node)
 #define sk_for_each_bound(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_bind_node)
+#define sk_nulls_for_each_bound(__sk, node, list) \
+	hlist_nulls_for_each_entry(__sk, node, list, sk_nulls_bind_node)
 
 /* Sock flags */
 enum sock_flags {
--- include/net/udp.h
+++ include/net/udp.h
@@ -55,7 +55,8 @@
 	spinlock_t		lock;
 } __attribute__((aligned(2 * sizeof(long))));
 struct udp_table {
-	struct udp_hslot	hash[UDP_HTABLE_SIZE];
+	struct udp_hslot	hash[UDP_HTABLE_SIZE]; /* pair hash */
+	struct udp_hslot	port_hash[UDP_HTABLE_SIZE]; /* port hash */
 };
 extern struct udp_table udp_table;
 extern void udp_table_init(struct udp_table *);
@@ -117,7 +118,11 @@
 	BUG();
 }
 
+extern void __udp_lib_hash(struct sock *sk);
+extern void __udp_lib_unhash(struct sock *sk);
 extern void udp_lib_unhash(struct sock *sk);
+extern void udp_lock_hashes_bh(struct net *net, struct sock *sk, __u16 num);
+extern void udp_unlock_hashes_bh(struct net *net, struct sock *sk, __u16 num);
 
 static inline void udp_lib_close(struct sock *sk, long timeout)
 {
--- net/Kconfig
+++ net/Kconfig
@@ -25,6 +25,13 @@
 
 menu "Networking options"
 
+config NETDEV_HASHBITS
+	int "Network device hash size (10 => 1024, 14 => 16384)"
+	range 10 20
+	default 10
+	help
+	  Select network device hash size as a power of 2.
+
 config NET_SYSCTL_DEV
 	bool "Per device sysctl entries"
 	default y
--- net/ipv4/datagram.c
+++ net/ipv4/datagram.c
@@ -19,6 +19,7 @@
 #include <net/sock.h>
 #include <net/route.h>
 #include <net/tcp_states.h>
+#include <net/udp.h>
 
 int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
@@ -62,8 +63,13 @@
 	}
 	if (!inet->saddr)
 		inet->saddr = rt->rt_src;	/* Update source address */
-	if (!inet->rcv_saddr)
+	if (!inet->rcv_saddr) {
 		inet->rcv_saddr = rt->rt_src;
+		udp_lock_hashes_bh(sock_net(sk), sk, inet_sk(sk)->num);
+		__udp_lib_unhash(sk);
+		__udp_lib_hash(sk);
+		udp_unlock_hashes_bh(sock_net(sk), sk, inet_sk(sk)->num);
+	}
 	inet->daddr = rt->rt_dst;
 	inet->dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
--- net/ipv4/udp.c
+++ net/ipv4/udp.c
@@ -122,17 +122,84 @@
 
 #define PORTS_PER_CHAIN (65536 / UDP_HTABLE_SIZE)
 
-static int udp_lib_lport_inuse(struct net *net, __u16 num,
-			       const struct udp_hslot *hslot,
-			       unsigned long *bitmap,
-			       struct sock *sk,
-			       int (*saddr_comp)(const struct sock *sk1,
-						 const struct sock *sk2))
+
+static inline int is_rcv_saddr_any(const struct sock *sk)
+{
+	switch (sk->sk_family) {
+	case PF_INET:
+		return inet_sk(sk)->rcv_saddr == 0;
+	case PF_INET6:
+		return ipv6_addr_any(&inet6_sk(sk)->rcv_saddr);
+	}
+	WARN(1, "unrecognised sk->sk_family in is_rcv_saddr_any");
+	return 0;
+}
+
+static inline u32 udp_v4_addr_hashfn(struct net * net, const u32 laddr, u16 snum)
+{
+	u32 key;
+	snum += net_hash_mix(net);
+	if (laddr == 0)
+		key = snum;
+	else
+		key = jhash2(&laddr, 1, snum);
+
+	return key & (UDP_HTABLE_SIZE - 1);
+}
+
+static inline u32 udp_v6_addr_hashfn(struct net * net, const struct in6_addr *laddr, u16 snum)
+{
+	u32 key;
+	snum += net_hash_mix(net);
+	if (ipv6_addr_any(laddr))
+		key = snum;
+	else if (ipv6_addr_type(laddr) == IPV6_ADDR_MAPPED)
+		key = jhash2(&laddr->s6_addr32[3], 1, snum);
+	else
+		key = jhash2(laddr->s6_addr32, 4, snum);
+
+	return key & (UDP_HTABLE_SIZE - 1);
+}
+
+static int udp_saddr_hashfn(struct net * net, struct sock *sk, u16 snum)
+{
+	switch (sk->sk_family) {
+        case PF_INET:
+                return udp_v4_addr_hashfn(net, inet_sk(sk)->rcv_saddr, snum);
+        case PF_INET6:
+                return udp_v6_addr_hashfn(net, &inet6_sk(sk)->rcv_saddr, snum);
+        }
+	WARN(1, "unrecognised sk->sk_family in is_rcv_saddr_any");
+        return 0;
+}
+
+static int udp_addr_any_hashfn(struct net * net, struct sock *sk, u16 snum)
+{
+	switch (sk->sk_family) {
+        case PF_INET:
+                return udp_v4_addr_hashfn(net, INADDR_ANY, snum);
+        case PF_INET6:
+                return udp_v6_addr_hashfn(net, &in6addr_any, snum);
+        }
+	WARN(1, "unrecognised sk->sk_family in is_rcv_saddr_any");
+        return 0;
+}
+
+
+
+
+
+static int __udp_lib_lport_inuse_port(struct net *net, __u16 num,
+				    const struct udp_hslot *hslot,
+				    unsigned long *bitmap,
+				    struct sock *sk,
+				    int (*saddr_comp)(const struct sock *sk1,
+						      const struct sock *sk2))
 {
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
 
-	sk_nulls_for_each(sk2, node, &hslot->head)
+	sk_nulls_for_each_bound(sk2, node, &hslot->head)
 		if (net_eq(sock_net(sk2), net)			&&
 		    sk2 != sk					&&
 		    (bitmap || sk2->sk_hash == num)		&&
@@ -149,6 +216,215 @@
 	return 0;
 }
 
+static int __udp_lib_lport_inuse_pair(struct net *net, __u16 num,
+				    const struct udp_hslot *hslot,
+				    struct sock *sk,
+				    int (*saddr_comp)(const struct sock *sk1,
+						      const struct sock *sk2))
+{
+	struct sock *sk2;
+	struct hlist_nulls_node *node;
+
+	sk_nulls_for_each(sk2, node, &hslot->head)
+		if (net_eq(sock_net(sk2), net)			&&
+		    sk2 != sk					&&
+		    sk2->sk_hash == num				&&
+		    (!sk2->sk_reuse || !sk->sk_reuse)		&&
+		    (!sk2->sk_bound_rx_dev_if || !sk->sk_bound_rx_dev_if
+		     || sk2->sk_bound_rx_dev_if == sk->sk_bound_rx_dev_if) &&
+		    (*saddr_comp)(sk, sk2))
+			return 1;
+	return 0;
+}
+
+
+static inline void __udp_lock_pair_hashes(struct udp_table *udptable,
+					  int pair_key, int pair_addrany_key)
+{
+	/*
+	  - because pair_key might be equal to pair_addrany_key, make sure
+	  you never take the same lock twice!
+	  
+	  - between pair_hash(addr) and pair_hash(addrany) take first the
+	  one with the smallest key.
+	*/
+	if (pair_key == pair_addrany_key) {
+		spin_lock(&udptable->hash[pair_key].lock);
+	} else if (pair_key < pair_addrany_key) {
+		spin_lock(&udptable->hash[pair_key].lock);
+		spin_lock(&udptable->hash[pair_addrany_key].lock);
+	} else {
+		spin_lock(&udptable->hash[pair_addrany_key].lock);
+		spin_lock(&udptable->hash[pair_key].lock);
+	}
+}
+
+static inline void __udp_unlock_pair_hashes(struct udp_table *udptable,
+					    int pair_key, int pair_addrany_key)
+{
+	if (pair_key == pair_addrany_key) {
+		spin_unlock(&udptable->hash[pair_key].lock);
+	} else if (pair_key < pair_addrany_key) {
+		spin_unlock(&udptable->hash[pair_addrany_key].lock);
+		spin_unlock(&udptable->hash[pair_key].lock);
+	} else {
+		spin_unlock(&udptable->hash[pair_key].lock);
+		spin_unlock(&udptable->hash[pair_addrany_key].lock);
+	}
+}
+
+
+static inline void __udp_lock_pair_hashes_bh(struct udp_table *udptable,
+					     int pair_key, int pair_addrany_key)
+{
+	local_bh_disable();
+	__udp_lock_pair_hashes(udptable, pair_key, pair_addrany_key);
+}
+
+static inline void __udp_unlock_pair_hashes_bh(struct udp_table *udptable,
+					       int pair_key, int pair_addrany_key)
+{
+	__udp_unlock_pair_hashes(udptable, pair_key, pair_addrany_key);
+	local_bh_enable();
+}
+
+
+static inline void __udp_lock_hashes(struct udp_table *udptable, int port_key,
+				     int pair_key, int pair_addrany_key)
+{
+	/* To avoid deadlocks we need to always take the locks in order:
+	   - port_hash lock *before* the pair_hash locks.
+	     This is needed because searching in a port hash is done by setting 
+	     bits in a bitmap for each port found in the hash and then iterating
+	     over all possible ports that could be in that hash and searching
+	     for any that could be in it but isn't (which means it's free).
+	     After finding such a port we lock it's pair hashes too.
+	*/
+	spin_lock(&udptable->port_hash[port_key].lock);
+	__udp_lock_pair_hashes(udptable, pair_key, pair_addrany_key);
+}
+
+static inline void __udp_unlock_hashes(struct udp_table *udptable, int port_key,
+				       int pair_key, int pair_addrany_key)
+{
+	__udp_unlock_pair_hashes(udptable, pair_key, pair_addrany_key);
+	spin_unlock(&udptable->port_hash[port_key].lock);
+}
+
+
+static inline void __udp_lock_hashes_bh(struct udp_table *udptable, int port_key,
+					int pair_key, int pair_addrany_key)
+{
+	spin_lock_bh(&udptable->port_hash[port_key].lock);
+	__udp_lock_pair_hashes_bh(udptable, pair_key, pair_addrany_key);
+}
+static inline void __udp_unlock_hashes_bh(struct udp_table *udptable, int port_key,
+					  int pair_key, int pair_addrany_key)
+{
+	__udp_unlock_pair_hashes_bh(udptable, pair_key, pair_addrany_key);
+	spin_unlock_bh(&udptable->port_hash[port_key].lock);
+}
+
+
+static inline void udp_lock_hashes(struct net *net, struct sock *sk, __u16 num)
+{
+	int port_key, pair_key, pair_addrany_key;
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
+
+	port_key = udp_hashfn(net, num);
+	pair_key = udp_saddr_hashfn(net, sk, num);
+	pair_addrany_key = udp_addr_any_hashfn(net, sk, num);
+
+	__udp_lock_hashes(udptable, port_key, pair_key, pair_addrany_key);
+}
+
+
+static inline void udp_unlock_hashes(struct net *net, struct sock *sk, __u16 num)
+{
+	int port_key, pair_key, pair_addrany_key;
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
+
+	port_key = udp_hashfn(net, num);
+	pair_key = udp_saddr_hashfn(net, sk, num);
+	pair_addrany_key = udp_addr_any_hashfn(net, sk, num);
+
+	__udp_unlock_hashes(udptable, port_key, pair_key, pair_addrany_key);
+}
+
+
+void udp_lock_hashes_bh(struct net *net, struct sock *sk, __u16 num)
+{
+	int port_key, pair_key, pair_addrany_key;
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
+
+	port_key = udp_hashfn(net, num);
+	pair_key = udp_saddr_hashfn(net, sk, num);
+	pair_addrany_key = udp_addr_any_hashfn(net, sk, num);
+
+	__udp_lock_hashes_bh(udptable, port_key, pair_key, pair_addrany_key);
+}
+
+void udp_unlock_hashes_bh(struct net *net, struct sock *sk, __u16 num)
+{
+	int port_key, pair_key, pair_addrany_key;
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
+
+	port_key = udp_hashfn(net, num);
+	pair_key = udp_saddr_hashfn(net, sk, num);
+	pair_addrany_key = udp_addr_any_hashfn(net, sk, num);
+
+	__udp_unlock_hashes_bh(udptable, port_key, pair_key, pair_addrany_key);
+}
+
+/*
+ * Find out if a given local port is already used.
+ * 
+ * NOTE:
+ * - returns 0 with all hashes LOCKED if the port is not used as a local
+ *             port.  the caller can modify the hashes and is responsible
+ *             of unlocking them
+ * - returns 1 with all hashes UNLOCKED if the port is already used.
+ */
+static int udp_lib_lport_inuse(struct net *net, __u16 num,
+			       struct sock *sk,
+			       int (*saddr_comp)(const struct sock *sk1,
+						 const struct sock *sk2))
+{
+	int port_key, pair_key, pair_addrany_key;
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
+
+	port_key = udp_hashfn(net, num);
+	pair_key = udp_saddr_hashfn(net, sk, num);
+	pair_addrany_key = udp_addr_any_hashfn(net, sk, num);
+
+	__udp_lock_hashes_bh(udptable, port_key, pair_key, pair_addrany_key);
+
+	if (!is_rcv_saddr_any(sk)) {
+		/* We have a well-defined source address.  Verify that
+		 * there is no other socket which exactly matches this
+		 * one. */
+		if(!__udp_lib_lport_inuse_pair(net, num,
+					       &udptable->hash[pair_key],
+					       sk, saddr_comp))
+			return 0;
+
+		/* there was no exact match.  Verify there is no socket
+		 * bound to INADDR_ANY/in6addr_any on this port. */
+		if(!__udp_lib_lport_inuse_pair(net, num,
+					       &udptable->hash[pair_addrany_key],
+					       sk, saddr_comp))
+			return 0;
+	} else {
+		if(!__udp_lib_lport_inuse_port(net, num,
+					       &udptable->port_hash[port_key],
+					       NULL, sk, saddr_comp))
+			return 0;
+	}
+
+	__udp_unlock_hashes_bh(udptable, port_key, pair_key, pair_addrany_key);
+	return 1;
+}
+
 /* Defined in net/ipv4/ip_sockglue.c */
 int is_reserved_port(uint16_t port);
 
@@ -163,7 +439,7 @@
 		       int (*saddr_comp)(const struct sock *sk1,
 					 const struct sock *sk2 )    )
 {
-	struct udp_hslot *hslot;
+	struct udp_hslot *hslot_port;
 	struct udp_table *udptable = sk->sk_prot->h.udp_table;
 	int    error = 1;
 	struct net *net = sock_net(sk);
@@ -172,56 +448,79 @@
 		int low, high, remaining;
 		unsigned rand;
 		unsigned short first, last;
-		DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN);
 
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
 
 		rand = net_random();
 		first = (((u64)rand * remaining) >> 32) + low;
-		/*
-		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
-		 */
-		rand = (rand | 1) * UDP_HTABLE_SIZE;
-		for (last = first + UDP_HTABLE_SIZE; first != last; first++) {
-			hslot = &udptable->hash[udp_hashfn(net, first)];
-			bitmap_zero(bitmap, PORTS_PER_CHAIN);
-			spin_lock_bh(&hslot->lock);
-			udp_lib_lport_inuse(net, snum, hslot, bitmap, sk,
-					    saddr_comp);
 
+		if (!is_rcv_saddr_any(sk)) {
+			int i;
 			snum = first;
+			for (i = 0; i < remaining; i++, snum++) {
+				if (snum > high)
+					snum = low;
+				if (is_reserved_port(snum))
+					continue;
+				if (!udp_lib_lport_inuse(net, snum, sk, saddr_comp))
+					goto found;
+			}
+			goto fail;
+		} else {
+			DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN);
+
+			/* We're bound to INADDR_ANY/in6addr_any. Make sure this port
+			 * isn't being used by a conflicting socket. */
+
 			/*
-			 * Iterate on all possible values of snum for this hash.
-			 * Using steps of an odd multiple of UDP_HTABLE_SIZE
-			 * give us randomization and full range coverage.
+			 * force rand to be an odd multiple of UDP_HTABLE_SIZE
 			 */
-			do {
-				if (low <= snum && snum <= high &&
-				    !test_bit(snum / UDP_HTABLE_SIZE, bitmap) &&
-				    !is_reserved_port(snum))
-					goto found;
-				snum += rand;
-			} while (snum != first);
-			spin_unlock_bh(&hslot->lock);
+			rand = (rand | 1) * UDP_HTABLE_SIZE;
+			for (last = first + UDP_HTABLE_SIZE; first != last; first++) {
+				bitmap_zero(bitmap, PORTS_PER_CHAIN);
+
+				hslot_port = &udptable->port_hash[udp_hashfn(net, first)];
+				spin_lock_bh(&hslot_port->lock);
+
+				__udp_lib_lport_inuse_port(net, snum, hslot_port,
+							   bitmap, sk, saddr_comp);
+
+				snum = first;
+				/*
+				 * Iterate on all possible values of snum for this hash.
+				 * Using steps of an odd multiple of UDP_HTABLE_SIZE
+				 * give us randomization and full range coverage.
+				 */
+				do {
+					if (low <= snum && snum <= high &&
+					    !test_bit(snum / UDP_HTABLE_SIZE, bitmap) &&
+					    !is_reserved_port(snum)) {
+						/* we only have the port hash lock.
+						   Before updating the hashes we
+						   must take the pair locks too. */
+						__udp_lock_pair_hashes_bh(udptable,
+									  udp_saddr_hashfn(net, sk, snum),
+									  udp_addr_any_hashfn(net, sk, snum));
+						goto found;
+					}
+					snum += rand;
+				} while (snum != first);
+				spin_unlock_bh(&hslot_port->lock);
+			}
+			goto fail;
 		}
-		goto fail;
 	} else {
-		hslot = &udptable->hash[udp_hashfn(net, snum)];
-		spin_lock_bh(&hslot->lock);
-		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk, saddr_comp))
-			goto fail_unlock;
+		if (udp_lib_lport_inuse(net, snum, sk, saddr_comp))
+			goto fail;
 	}
 found:
 	inet_sk(sk)->num = snum;
 	sk->sk_hash = snum;
-	if (sk_unhashed(sk)) {
-		sk_nulls_add_node_rcu(sk, &hslot->head);
-		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
-	}
+	__udp_lib_unhash(sk);
+	__udp_lib_hash(sk);
+	udp_unlock_hashes_bh(net, sk, snum);
 	error = 0;
-fail_unlock:
-	spin_unlock_bh(&hslot->lock);
 fail:
 	return error;
 }
@@ -278,24 +577,42 @@
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+static struct sock *__udp4_lib_lookup_addr(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct udp_table *udptable)
+		int dif, struct udp_table *udptable, __be32 haddr)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(dport);
-	unsigned int hash = udp_hashfn(net, hnum);
-	struct udp_hslot *hslot = &udptable->hash[hash];
+	unsigned int hash;
+	struct udp_hslot *hslot;
 	int score, badness;
 
-	rcu_read_lock();
+	hash = udp_v4_addr_hashfn(net, haddr, hnum);
+	hslot = &udptable->hash[hash];
 begin:
 	result = NULL;
 	badness = -1;
 	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
 		score = compute_score(sk, net, saddr, hnum, sport,
 				      daddr, dport, dif);
+		
+		/* Computed score can't be greater than 9,
+		 * so we should just break upon reaching it.
+		 *
+		 * XXX: Test if this does indeed speed things up in our case:
+		 *      many udp slots bounded on the same port and on different
+		 *      addresses. If all sk are distributed evenly and the
+		 *      hashtable size is sufficiently large the lists should be
+		 *      small and this check should not have a visible
+		 *      performance impact. On the other hand, if this does
+		 *      improve things we should inspect the above suppositions.
+		 */
+		if (score == 9) {
+			result = sk;
+			badness = score;
+			goto out;
+		}
 		if (score > badness) {
 			result = sk;
 			badness = score;
@@ -306,9 +623,11 @@
 	 * not the expected one, we must restart lookup.
 	 * We probably met an item that was moved to another chain.
 	 */
-	if (get_nulls_value(node) != hash)
+	if (get_nulls_value(node) != hash) {
 		goto begin;
+	}
 
+out:
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
@@ -318,10 +637,26 @@
 			goto begin;
 		}
 	}
+	return result;
+}
+
+static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+		__be16 sport, __be32 daddr, __be16 dport,
+		int dif, struct udp_table *udptable)
+{
+	struct sock *result;
+	rcu_read_lock();
+	result = __udp4_lib_lookup_addr(net, saddr, sport, daddr, dport,
+					dif, udptable, daddr);
+	if (!result) {
+		result = __udp4_lib_lookup_addr(net, saddr, sport, daddr, dport,
+						dif, udptable, INADDR_ANY);
+	}
 	rcu_read_unlock();
 	return result;
 }
 
+
 static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
 						 struct udp_table *udptable)
@@ -1001,19 +1336,35 @@
 	return 0;
 }
 
+
+void __udp_lib_hash(struct sock *sk)
+{
+	int pair_key, port_key;
+	u16 snum = inet_sk(sk)->num;
+	struct udp_table *udptable = sk->sk_prot->h.udp_table;
+
+	port_key = udp_hashfn(sock_net(sk), snum);
+	pair_key = udp_saddr_hashfn(sock_net(sk), sk, snum);
+
+	sk_nulls_add_node_rcu(sk, &udptable->hash[pair_key].head);
+	__sk_nulls_add_bind_node_rcu(sk, &udptable->port_hash[port_key].head);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+}
+
+void __udp_lib_unhash(struct sock *sk)
+{
+	if (sk_nulls_del_node_init_rcu(sk)) {
+		inet_sk(sk)->num = 0;
+		__sk_nulls_del_bind_node_init_rcu(sk);
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	}
+}
 void udp_lib_unhash(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
-		struct udp_table *udptable = sk->sk_prot->h.udp_table;
-		unsigned int hash = udp_hashfn(sock_net(sk), sk->sk_hash);
-		struct udp_hslot *hslot = &udptable->hash[hash];
-
-		spin_lock_bh(&hslot->lock);
-		if (sk_nulls_del_node_init_rcu(sk)) {
-			inet_sk(sk)->num = 0;
-			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-		}
-		spin_unlock_bh(&hslot->lock);
+		udp_lock_hashes_bh(sock_net(sk), sk, sk->sk_hash);
+		__udp_lib_unhash(sk);
+		udp_unlock_hashes_bh(sock_net(sk), sk, sk->sk_hash);
 	}
 }
 EXPORT_SYMBOL(udp_lib_unhash);
@@ -1149,6 +1500,31 @@
 	return -1;
 }
 
+static void __udp4_lib_mcast_deliver_hslot(struct net *net, struct sk_buff *skb,
+					   struct udphdr  *uh, __be32 saddr,
+					   __be32 daddr, struct udp_hslot *hslot)
+{
+	struct sock *sk;
+	int dif;
+
+	sk = sk_nulls_head(&hslot->head);
+	dif = skb->dev->ifindex;
+	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
+	while (sk) {
+		struct sk_buff *skb1 = skb_clone(skb, GFP_ATOMIC);
+		if (skb1) {
+			int ret = udp_queue_rcv_skb(sk, skb1);
+			if (ret > 0)
+				/* we should probably re-process instead
+				 * of dropping packets here. */
+				kfree_skb(skb1);
+		}
+
+		sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
+				       daddr, uh->source, saddr, dif);
+	}
+}
+
 /*
  *	Multicasts and broadcasts go to each listener.
  *
@@ -1160,38 +1536,23 @@
 				    __be32 saddr, __be32 daddr,
 				    struct udp_table *udptable)
 {
-	struct sock *sk;
-	struct udp_hslot *hslot = &udptable->hash[udp_hashfn(net, ntohs(uh->dest))];
-	int dif;
+	int port_key, pair_key, pair_addrany_key;
+	u16 num = ntohs(uh->dest);
 
-	spin_lock(&hslot->lock);
-	sk = sk_nulls_head(&hslot->head);
-	dif = skb->dev->ifindex;
-	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
-	if (sk) {
-		struct sock *sknext = NULL;
+	port_key = udp_hashfn(net, num);
+	pair_key = udp_v4_addr_hashfn(net, daddr, num);
+	pair_addrany_key = udp_v4_addr_hashfn(net, INADDR_ANY, num);
 
-		do {
-			struct sk_buff *skb1 = skb;
+	__udp_lock_hashes(udptable, port_key, pair_key, pair_addrany_key);
+	
+	__udp4_lib_mcast_deliver_hslot(net, skb, uh, saddr, daddr,
+				       &udptable->hash[pair_key]);
+	if (pair_key != pair_addrany_key)
+		__udp4_lib_mcast_deliver_hslot(net, skb, uh, saddr, daddr,
+					       &udptable->hash[pair_addrany_key]);
 
-			sknext = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
-						   daddr, uh->source, saddr,
-						   dif);
-			if (sknext)
-				skb1 = skb_clone(skb, GFP_ATOMIC);
-
-			if (skb1) {
-				int ret = udp_queue_rcv_skb(sk, skb1);
-				if (ret > 0)
-					/* we should probably re-process instead
-					 * of dropping packets here. */
-					kfree_skb(skb1);
-			}
-			sk = sknext;
-		} while (sknext);
-	} else
-		consume_skb(skb);
-	spin_unlock(&hslot->lock);
+	__udp_unlock_hashes(udptable, port_key, pair_key, pair_addrany_key);
+	consume_skb(skb);
 	return 0;
 }
 
@@ -1797,6 +2158,9 @@
 	for (i = 0; i < UDP_HTABLE_SIZE; i++) {
 		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
 		spin_lock_init(&table->hash[i].lock);
+
+		INIT_HLIST_NULLS_HEAD(&table->port_hash[i].head, i);
+		spin_lock_init(&table->port_hash[i].lock);
 	}
 }
 

--------------000905000207050801090805
Content-Type: text/x-csrc;
 name="stressbind.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="stressbind.c"

/*
 * Creates a configurable number of UDP sockets with IPv4 and IPv6 addresses.
 *
 * If run as receiver: counts the number of UDP datagrams received.
 *    - binds on all addresses on a given port and connects the socket to the
 *      corresponding IP address and port.
 *    - Afterwars, if epolls and count the corectly received datagrams.
 *    - not knowing when to stop listening it must be killed with CTRL+C (or
 *      other killing signel). On the first CTRL+C received prints the number of
 *      received datagrams; on the second CTRL+C received it exit()s.
 *
 * If run as sender: sends a configurable number of UDP datagrams to the
 *                   receiver and prints the number of second passed.
 *    - binds on all addresses on a given port and connects the socket to the
 *      corresponding IP address and port.
 *    - epolls for a free sending slot and send a new datagram to the receiver.
 *    - at end prints the time it took to send all the datagrams.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/epoll.h>
#include <time.h>
#include <signal.h>

struct timespec tp;

struct epoll_data_t {
	int fd;
	int count;
	int disabled;
};



static void start_timer(struct timespec *tp)
{
	int rc = clock_gettime(CLOCK_REALTIME, tp);
	if (rc != 0) {
		perror("clock_realtime err in start_timer");
	}
}
static void end_timer(struct timespec *pold, const char * msg)
{
	int rc;
	long unsigned dsec, dnsec;
	struct timespec now;
	rc = clock_gettime(CLOCK_REALTIME, &now);
	if (rc != 0) {
		perror("clock_realtime err in end_timer");
	}

	if (now.tv_nsec < pold->tv_nsec) {
		dnsec = pold->tv_nsec - now.tv_nsec;
		dsec = now.tv_sec - pold->tv_sec - 1;
	} else {
		dnsec = now.tv_nsec - pold->tv_nsec;
		dsec = now.tv_sec - pold->tv_sec;
	}
	printf(">>> %s: %lu s  %lu ns \n", msg, dsec, dnsec);
}


static struct in_addr * make_ip4_addrs(int count, int suffix)
{
	int i = 0;
	char str[INET6_ADDRSTRLEN];
	struct in_addr * ret = malloc(sizeof(struct in_addr) * count);
	for(i = 0; i < count; i++) {
		snprintf(str, INET6_ADDRSTRLEN, "1.%d.%d.%d",
			 (i & 0xFF00) >> 8, i & 0xFF, suffix);
		int s = inet_pton(AF_INET, str, &ret[i]);
		if (s <= 0) {
			if (s == 0)
				fprintf(stderr, "ipv4 Not in presentation format");
			else
				perror("inet_pton");
			exit(EXIT_FAILURE);
		}
	}
	return ret;
}

static struct in6_addr * make_ip6_addrs(int count, int suffix)
{
	int i = 0;
	char str[INET6_ADDRSTRLEN];
	struct in6_addr * ret = malloc(sizeof(struct in6_addr) * count);
	for(i = 0; i < count; i++) {
		snprintf(str, INET6_ADDRSTRLEN, "1::%x:%x:%x",
			 (i / 0x10000), (i & 0xFFFF), suffix);
		int s = inet_pton(AF_INET6, str, &ret[i]);
		if (s <= 0) {
			if (s == 0)
				fprintf(stderr, "ipv6 Not in presentation format");
			else
				perror("inet_pton");
			exit(EXIT_FAILURE);
		}
	}
	return ret;
}



static int * make_sockets_(int count, int type)
{
	int i = 0;
	int * ret = malloc(sizeof(int)*count);
	for (i = 0; i < count; i++) {
		ret[i] = socket(type, SOCK_DGRAM, 0);
		if (ret[i] < 0) {
			perror("make_ipv4_sockets socket() failed");
			exit(EXIT_FAILURE);
		}
	}
	return ret;
}

static int * make_ip4_sockets(int count)
{
	return make_sockets_(count, AF_INET);
}

static int * make_ip6_sockets(int count)
{
	return make_sockets_(count, AF_INET6);
}

static void print_ip_err(void * in_addr, int addr_type)
{
	char str[INET6_ADDRSTRLEN];
	if (inet_ntop(addr_type, in_addr, str, INET6_ADDRSTRLEN) == NULL) {
		perror("inet_ntop");
		exit(EXIT_FAILURE);
	}
	fprintf(stderr, "failed for addr: %s\n", str);
}


static void for_all_set_sockopt(int * s, int count, int level, int optname, int val)
{
	int i = 0;
	int rc;
	for (i = 0; i < count; i++) {
		rc = setsockopt(s[i], level, optname, (int[]){val}, sizeof(int));
		if (rc != 0) {
			perror("setsockopt");
			exit(EXIT_FAILURE);
		}
	}
}

static void for_all_set_reuseaddr(int * s, int count)
{
	for_all_set_sockopt(s, count, SOL_SOCKET, SO_REUSEADDR, 1);
}

static void for_all_set_rcvbuf(int * s, int count, int size)
{
	for_all_set_sockopt(s, count, SOL_SOCKET, SO_RCVBUF, size);
}

static void for_all_set_sndbuf(int * s, int count, int size)
{
	for_all_set_sockopt(s, count, SOL_SOCKET, SO_SNDBUF, size);
}


static void for_all_set_nonblocking(int * s, int count)
{
	int rc, i;
	for (i = 0; i < count; i++) {
		rc = fcntl(s[i], F_SETFL, O_NONBLOCK);
		if (rc != 0) {
			fprintf(stderr, "i = %d\n", i);
			perror("fcntl O_NONBLOCK");
			exit(EXIT_FAILURE);
		}
	}

}

static void for_all_set_ipv6only(int * s, int count)
{
	for_all_set_sockopt(s, count, IPPROTO_IPV6, IPV6_V6ONLY, 1);
}





static void for_all_bind_or_connect_ip4(int * s, struct in_addr * ip4, int count, int port,
			     int (*f)(int sockfd, const struct sockaddr *addr,
				      socklen_t addrlen))
{
	int i, rc;
	struct sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(port);

	for (i = 0; i < count; i++) {
		sin.sin_addr = ip4[i];
		rc = f(s[i], (struct sockaddr*)&sin, sizeof(sin));
		if (rc != 0) {
			if (f == bind)
				perror("bind ipv4");
			else
				perror("connect ipv4");
			fprintf(stderr, "i = %d\n", i);
			print_ip_err(&ip4[i], AF_INET);
			exit(EXIT_FAILURE);
		}
	}
}

static void for_all_bind_or_connect_ip6(int * s, struct in6_addr * ip6, int count, int port,
			     int (*f)(int sockfd, const struct sockaddr *addr,
				      socklen_t addrlen))
{
	int i, rc;
	struct sockaddr_in6 sin6;
	sin6.sin6_family = AF_INET6;
	sin6.sin6_port = htons(port);

	for (i = 0; i < count; i++) {
		sin6.sin6_addr = ip6[i];
		rc = f(s[i], (struct sockaddr*)&sin6, sizeof(sin6));
		if (rc != 0) {
			if (f == bind)
				perror("bind ipv6");
			else
				perror("connect ipv6");
			fprintf(stderr, "i = %d\n", i);
			print_ip_err(&ip6[i], AF_INET6);
			exit(EXIT_FAILURE);
		}
	}
}

static void for_all_bind_ip4(int * s, struct in_addr * ip4, int count, int port)
{
	for_all_bind_or_connect_ip4(s, ip4, count, port, bind);
}
static void for_all_bind_ip6(int * s, struct in6_addr * ip6, int count, int port)
{
	for_all_bind_or_connect_ip6(s, ip6, count, port, bind);
}
static void for_all_connect_ip4(int * s, struct in_addr * ip4, int count, int port)
{
	for_all_bind_or_connect_ip4(s, ip4, count, port, connect);
}
static void for_all_connect_ip6(int * s, struct in6_addr * ip6, int count, int port)
{
	for_all_bind_or_connect_ip6(s, ip6, count, port, connect);
}



static struct epoll_data_t * for_all_add_to_epoll(int *s, int count, int epollfd, int is_sender)
{
	int rc;
	int i;
	struct epoll_event ev;
	struct epoll_data_t * data = calloc(count, sizeof(struct epoll_data_t));
	ev.events = EPOLLET;
	if (is_sender)
		ev.events |= EPOLLOUT;
	else
		ev.events |= EPOLLIN;
	for (i = 0; i < count; i++) {
		data[i].fd = s[i];
		ev.data.ptr = &data[i];
		rc = epoll_ctl(epollfd, EPOLL_CTL_ADD, s[i], &ev);
		if (rc == -1) {
			fprintf(stderr, "i = %d\n", i);
			perror("epoll_ctl: conn_sock");
			exit(EXIT_FAILURE);
		}
	}
	return data;
}

static void remove_from_epoll(int epollfd, int fd, struct epoll_event * ev)
{
	int rc;
	//printf("removing from epoll fd %d\n", fd);
	rc = epoll_ctl(epollfd, EPOLL_CTL_DEL, fd, ev);
	if (rc != 0)
		perror("epoll_ctl EPOLL_CTL_DEL");
}

static void disable_epoll_event_type(int epollfd, int fd, int event_type, struct epoll_event * ev)
{
	int rc;
	//printf("disabling event %d on fd=%d\n", event_type, fd);
	ev->events &= ~event_type;
	rc = epoll_ctl(epollfd, EPOLL_CTL_MOD, fd, ev);
	if (rc != 0)
		perror("epoll_ctl EPOLL_CTL_MOD");
}

static int handle_events(int epollfd, int fds_in_epoll, int is_sender, int max_packets, int datalen)
{
	char * databuf = malloc(datalen);
	struct epoll_event * events = malloc(sizeof(struct epoll_event) * fds_in_epoll);
	int todo = fds_in_epoll;
	int total = 0;

	for (;todo;) {
		int i, nfds;
		nfds = epoll_wait(epollfd, events, fds_in_epoll, -1);
		if (nfds == -1) {
			if (errno == EINTR) {
				printf("signal interrupted epoll_wait: total= %d\n", total);
				continue;
			}
			perror("epoll_wait");
			exit(EXIT_FAILURE);
		}
		for (i = 0; i < nfds; i++) {
			int fd, rc;
			struct epoll_event  *ev = &events[i];
			struct epoll_data_t *ed = ev->data.ptr;
			fd = ed->fd;
			if (ev->events & (EPOLLERR | EPOLLHUP)) {
				remove_from_epoll(epollfd, fd, ev);
				todo--;
				continue;
			}
			if (ev->events & EPOLLIN) {
				rc = recv(fd, databuf, datalen, 0);
				if (rc == -1) {
					//if (errno != ECONNREFUSED)
						perror("recv");
					continue;
				}
			}
			if (ev->events & EPOLLOUT) {
				rc = send(fd, databuf, datalen, 0);
				if (rc == -1) {
					//if (errno != ECONNREFUSED)
						perror("send");
					continue;
				}
			}
			if (total == 0)
				start_timer(&tp);
			total ++;
			ed->count ++;
			if (ed->count == max_packets) {
				remove_from_epoll(epollfd, fd, ev);
				todo--;
			}
		}
	}
	free(events);
	return total;
}

static int signal_was_delivered = 0;
static void handler(int unused)
{
	if (!signal_was_delivered)
		signal_was_delivered = 1;
	else
		exit(0);
}
static void add_signal()
{
	signal(SIGINT, handler);
}

#define stoi atoi
int main(int argc, char * argv[])
{
	int port = 1212;

	if (argc < 8) {
		printf("Usage: %s nr_interfaces4 nr_interfaces6 my_last_suffix their_last_suffix [s|r] max_packets datalen [recvsize]\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	int count4       = stoi(argv[1]);
	int count6       = stoi(argv[2]);
	int my_suffix    = stoi(argv[3]);
	int their_suffix = stoi(argv[4]);
	int is_sender    = argv[5][0] == 's';
	int max_packets  = stoi(argv[6]);
	int datalen      = stoi(argv[7]);
	int recvsize = -1;
	if (argc >= 8)
		recvsize = stoi(argv[8]);
	add_signal();
	printf("args = count4=%d count6=%d my_suffix=%d their_suffix=%d is_sender=%d max_packets=%d datalen=%d recvsize=%d\n",
	       count4, count6, my_suffix, their_suffix, is_sender, max_packets, datalen, recvsize);
	int epollfd;
	struct in_addr  * ip4_src = make_ip4_addrs(count4, my_suffix);
	struct in6_addr * ip6_src = make_ip6_addrs(count6, my_suffix);

	struct in_addr  * ip4_dst = make_ip4_addrs(count4, their_suffix);
	struct in6_addr * ip6_dst = make_ip6_addrs(count6, their_suffix);

	struct epoll_data_t *ep_data_ip4, *ep_data_ip6;

	int * s4 = make_ip4_sockets(count4);
	int * s6 = make_ip6_sockets(count6);
	int total = 0;

	for_all_set_reuseaddr(s4, count4);
	for_all_set_reuseaddr(s6, count6);

	if (recvsize != -1) {
		for_all_set_rcvbuf(s4, count4, recvsize);
		for_all_set_rcvbuf(s6, count6, recvsize);
	}
	//for_all_set_sndbuf(s4, count4, 1);
	//for_all_set_sndbuf(s6, count6, 1);

	start_timer(&tp);
	for_all_bind_ip6(s6, ip6_src, count6, port);
	for_all_bind_ip4(s4, ip4_src, count4, port);
	end_timer(&tp, "bound     IPv4 and IPv6");

	start_timer(&tp);
	for_all_connect_ip4(s4, ip4_dst, count4, port);
	for_all_connect_ip6(s6, ip6_dst, count6, port);
	end_timer(&tp, "connected IPv4 and IPv6");

	free(ip4_src); free(ip6_src);
	free(ip4_dst); free(ip6_dst);

	for_all_set_nonblocking(s4, count4);
	for_all_set_nonblocking(s6, count6);
	printf("done builing sockets.\n");


	epollfd = epoll_create(count4+count6);
	if (epollfd == -1) {
		perror("epoll_create");
		exit(EXIT_FAILURE);
	}
	ep_data_ip4 = for_all_add_to_epoll(s4, count4, epollfd, is_sender);
	ep_data_ip6 = for_all_add_to_epoll(s6, count6, epollfd, is_sender);
	printf("done builing epoll.\n");



	total = handle_events(epollfd, count4 + count6, is_sender, max_packets, datalen);
	end_timer(&tp, "handled all events");

	free(ep_data_ip4); free(ep_data_ip6);
	free(s4); free(s6);
	printf("done total= %d\n", total);
	return 0;
}


--------------000905000207050801090805--
