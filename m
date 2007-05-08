From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1 take 2] Unified socket storage. (with small bench).
Date: Tue, 8 May 2007 21:43:32 +0400
Message-ID: <20070508174331.GA13591@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50486 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966186AbXEHRnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 13:43:41 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.8/8.13.8) with ESMTP id l48HhWF0013489
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 21:43:33 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.8/8.12.1/Submit) id l48HhW3U013482
	for netdev@vger.kernel.org; Tue, 8 May 2007 21:43:32 +0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

This is second patch which implements unified cache of sockets for
network instead of old hash tables. It stores all types of sockets
(although I only implemented af_inet, unix, netlink and raw ones for now)
in single object structure called multidimensional trie (which is
similar to judy array in some way).

I performed simple performance test with handmade client and httperf.
The former is just epoll driven client which issues requested number of
requests one-by-one (or with some concurrency, which does not yet proven
to work correctly).
With mpm apache on test machine I got sustained 2k/s requests for mdt
and about 1200/s for (untuned) hash. With lighttpd and httperf 
(10k max, 1k rate) I got sustained 1k/s for mdt and 550-1000/s for
untuned hash. With tuned hash (thash_entries=1000000) I got both 1k/s,
with 30k max, 3k rate httperf I got 1650 for mdt and 1k for tuned hash.
Server was with lighttpd 1.4.13. (handmade server as long as 
'echo -en "GET / HTTP/1.0\n\n" | nc server 80' does not work due to
unknown reason, I did not investigate).
Results are quite small for that machine (amd athlon64 3500+ with 1gb of
ram and gigabit r8169 adapter), but I have all debug options turned on
(including heavy slab/vm).
Kernel is quite old 2.6.21-rc3.

Some design bits.
Unified storage is a trie which uses several bits to select a node
(compared to usual trie where only one bit is used). Current
implementation uses 160 bit keys, which include local/remote
address/port, protocol, network family and bound interface number.
The same tree thus can store all network protocols (including unix, in
this case name is hashed, and result node should have a list of entries
with the same hash, which is not completed yet).
Due to the nature of the trie, it does not require rebalancing, and thus
it is easily possible to implement rcu protection for socket lookup
(which was done).
Due to the fact, that several bits are used to select an entry on every
given level (8 in this setup), there is quite noticeble overhead
comapred to hash table, but socket structure itself does not have quite
a few entries too.

So, this is dynamic structure which can host any kind of network sockets
(actually any structure pointer which can be addressed with 160 bits).
Structure can be extended to support ipv6 (needs to increase key
length) with essentially any number of elements in it.

Code is in development stage, but I would like to rise a discussion
about needs to continue this development before next steps.

Attached patch against 2.6.21-rc3 tree, due to heavy reusage of
insert/remove/lookup methods number of insertions is smaller than number
of deleted lines (not counting needed to be removed
inet_hashtables.[ch] in future). Code does not support any kind of
statistics (yet).

Link to previous (more complete) description:
http://marc.info/?l=linux-netdev&m=117458697411808&w=2

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

 include/linux/netlink.h            |    1 -
 include/net/af_unix.h              |   26 --
 include/net/inet_connection_sock.h |    6 +-
 include/net/inet_hashtables.h      |    5 -
 include/net/inet_timewait_sock.h   |   24 +--
 include/net/lookup.h               |   79 +++++
 include/net/netlink.h              |   33 ++
 include/net/raw.h                  |    1 +
 include/net/sock.h                 |  116 +------
 include/net/tcp.h                  |    7 +-
 include/net/udp.h                  |   13 +-
 net/core/skbuff.c                  |    2 +
 net/core/sock.c                    |    1 -
 net/ipv4/Kconfig                   |    1 +
 net/ipv4/Makefile                  |    4 +-
 net/ipv4/af_inet.c                 |   20 +-
 net/ipv4/icmp.c                    |   16 +-
 net/ipv4/inet_connection_sock.c    |  134 +--------
 net/ipv4/inet_diag.c               |   11 +-
 net/ipv4/inet_timewait_sock.c      |   76 +----
 net/ipv4/ip_input.c                |   10 +-
 net/ipv4/mdt.c                     |  650 ++++++++++++++++++++++++++++++++++++
 net/ipv4/raw.c                     |   67 +---
 net/ipv4/tcp.c                     |   60 +----
 net/ipv4/tcp_ipv4.c                |   71 ++---
 net/ipv4/tcp_minisocks.c           |    3 +-
 net/ipv4/udp.c                     |  262 +--------------
 net/ipv4/udplite.c                 |   14 +-
 net/netlink/af_netlink.c           |  333 ++++---------------
 net/packet/af_packet.c             |   62 +---
 net/unix/af_unix.c                 |  126 ++------
 net/unix/garbage.c                 |   10 +-
 32 files changed, 1010 insertions(+), 1234 deletions(-)
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 2a20f48..f11b4e7 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -151,7 +151,6 @@ struct netlink_skb_parms
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
-
 extern struct sock *netlink_kernel_create(int unit, unsigned int groups, void (*input)(struct sock *sk, int len), struct module *module);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index c0398f5..7817c78 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -17,32 +17,6 @@ extern spinlock_t unix_table_lock;
 
 extern atomic_t unix_tot_inflight;
 
-static inline struct sock *first_unix_socket(int *i)
-{
-	for (*i = 0; *i <= UNIX_HASH_SIZE; (*i)++) {
-		if (!hlist_empty(&unix_socket_table[*i]))
-			return __sk_head(&unix_socket_table[*i]);
-	}
-	return NULL;
-}
-
-static inline struct sock *next_unix_socket(int *i, struct sock *s)
-{
-	struct sock *next = sk_next(s);
-	/* More in this chain? */
-	if (next)
-		return next;
-	/* Look for next non-empty chain. */
-	for ((*i)++; *i <= UNIX_HASH_SIZE; (*i)++) {
-		if (!hlist_empty(&unix_socket_table[*i]))
-			return __sk_head(&unix_socket_table[*i]);
-	}
-	return NULL;
-}
-
-#define forall_unix_sockets(i, s) \
-	for (s = first_unix_socket(&(i)); s; s = next_unix_socket(&(i),(s)))
-
 struct unix_address {
 	atomic_t	refcnt;
 	int		len;
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 133cf30..2a52734 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -244,11 +244,7 @@ extern struct request_sock *inet_csk_search_req(const struct sock *sk,
 						const __be32 laddr);
 extern int inet_csk_bind_conflict(const struct sock *sk,
 				  const struct inet_bind_bucket *tb);
-extern int inet_csk_get_port(struct inet_hashinfo *hashinfo,
-			     struct sock *sk, unsigned short snum,
-			     int (*bind_conflict)(const struct sock *sk,
-						  const struct inet_bind_bucket *tb));
-
+extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
 extern struct dst_entry* inet_csk_route_req(struct sock *sk,
 					    const struct request_sock *req);
 
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index d27ee8c..cd77aa4 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -266,11 +266,6 @@ out:
 		wake_up(&hashinfo->lhash_wait);
 }
 
-static inline int inet_iif(const struct sk_buff *skb)
-{
-	return ((struct rtable *)skb->dst)->rt_iif;
-}
-
 extern struct sock *__inet_lookup_listener(struct inet_hashinfo *hashinfo,
 					   const __be32 daddr,
 					   const unsigned short hnum,
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 09a2532..60d6999 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -78,7 +78,6 @@ struct inet_timewait_death_row {
 	struct timer_list	tw_timer;
 	int			slot;
 	struct hlist_head	cells[INET_TWDR_TWKILL_SLOTS];
-	struct inet_hashinfo 	*hashinfo;
 	int			sysctl_tw_recycle;
 	int			sysctl_max_tw_buckets;
 };
@@ -110,10 +109,7 @@ struct inet_timewait_sock {
 #define tw_state		__tw_common.skc_state
 #define tw_reuse		__tw_common.skc_reuse
 #define tw_bound_dev_if		__tw_common.skc_bound_dev_if
-#define tw_node			__tw_common.skc_node
-#define tw_bind_node		__tw_common.skc_bind_node
 #define tw_refcnt		__tw_common.skc_refcnt
-#define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
 	volatile unsigned char	tw_substate;
 	/* 3 bits hole, try to pack */
@@ -131,22 +127,9 @@ struct inet_timewait_sock {
 	__u16			tw_ipv6_offset;
 	int			tw_timeout;
 	unsigned long		tw_ttd;
-	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
 };
 
-static inline void inet_twsk_add_node(struct inet_timewait_sock *tw,
-				      struct hlist_head *list)
-{
-	hlist_add_head(&tw->tw_node, list);
-}
-
-static inline void inet_twsk_add_bind_node(struct inet_timewait_sock *tw,
-					   struct hlist_head *list)
-{
-	hlist_add_head(&tw->tw_bind_node, list);
-}
-
 static inline int inet_twsk_dead_hashed(const struct inet_timewait_sock *tw)
 {
 	return !hlist_unhashed(&tw->tw_death_node);
@@ -209,12 +192,9 @@ static inline void inet_twsk_put(struct inet_timewait_sock *tw)
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 						  const int state);
 
-extern void __inet_twsk_kill(struct inet_timewait_sock *tw,
-			     struct inet_hashinfo *hashinfo);
-
+extern void __inet_twsk_kill(struct inet_timewait_sock *tw);
 extern void __inet_twsk_hashdance(struct inet_timewait_sock *tw,
-				  struct sock *sk,
-				  struct inet_hashinfo *hashinfo);
+				  struct sock *sk);
 
 extern void inet_twsk_schedule(struct inet_timewait_sock *tw,
 			       struct inet_timewait_death_row *twdr,
diff --git a/include/net/lookup.h b/include/net/lookup.h
new file mode 100644
index 0000000..87a47a0
--- /dev/null
+++ b/include/net/lookup.h
@@ -0,0 +1,79 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef __LOOKUP_H
+#define __LOOKUP_H
+
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <net/route.h>
+
+#include <linux/in.h>
+#include <net/inet_timewait_sock.h>
+
+
+static inline int inet_iif(const struct sk_buff *skb)
+{
+	return ((struct rtable *)skb->dst)->rt_iif;
+}
+
+extern int __init mdt_sysinit(void);
+extern int mdt_insert_sock(struct sock *sk);
+extern int mdt_remove_sock(struct sock *sk);
+
+extern struct sock *mdt_lookup_proto(const __be32 saddr, const __be16 sport,
+	const __be32 daddr, const __be16 dport, const int dif, const __u8 proto,
+	int stages);
+
+static inline struct sock *__sock_lookup(const __be32 saddr, const __be16 sport,
+					 const __be32 daddr, const __be16 dport, 
+					 const int dif, const u8 proto, int stages)
+{
+	return mdt_lookup_proto(saddr, sport, daddr, dport, dif, proto, stages);
+}
+
+static inline struct sock *sock_lookup(const __be32 saddr, const __be16 sport,
+				       const __be32 daddr, const __be16 dport,
+				       const int dif, const __u8 proto, int stages)
+{
+	struct sock *sk;
+
+	local_bh_disable();
+	sk = __sock_lookup(saddr, sport, daddr, dport, dif, proto, stages);
+	local_bh_enable();
+	return sk;
+}
+
+static inline struct sock *mdt_lookup_raw(__u16 num, const __be32 daddr, 
+		const __be16 dport, const int dif)
+{
+	return sock_lookup(0, htons(num), daddr, dport, dif, IPPROTO_RAW, 1);
+}
+
+extern int mdt_insert_sock_port(struct sock *sk, unsigned short snum);
+
+static inline void proto_put_port(struct sock *sk)
+{
+	mdt_remove_sock(sk);
+}
+
+extern void mdt_remove_sock_tw(struct inet_timewait_sock *tw);
+extern void mdt_insert_sock_tw(struct inet_timewait_sock *tw);
+
+#endif /* __LOOKUP_H */
diff --git a/include/net/netlink.h b/include/net/netlink.h
index bcaf67b..05c2422 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1016,4 +1016,37 @@ static inline int nla_validate_nested(struct nlattr *start, int maxtype,
 #define nla_for_each_nested(pos, nla, rem) \
 	nla_for_each_attr(pos, nla_data(nla), nla_len(nla), rem)
 
+#ifdef __KERNEL__
+
+#include <net/sock.h>
+
+struct netlink_sock {
+	/* struct sock has to be the first member of netlink_sock */
+	struct sock		sk;
+	u32			pid;
+	u32			dst_pid;
+	u32			dst_group;
+	u32			flags;
+	u32			subscriptions;
+	u32			ngroups;
+	unsigned long		*groups;
+	unsigned long		state;
+	wait_queue_head_t	wait;
+	struct netlink_callback	*cb;
+	spinlock_t		cb_lock;
+	void			(*data_ready)(struct sock *sk, int bytes);
+	struct hlist_node	nlk_node;
+	struct module		*module;
+};
+
+#define sk_for_each_bound(sk, node, head) \
+	hlist_for_each_entry(sk, node, head, nlk_node)
+
+static inline struct netlink_sock *nlk_sk(struct sock *sk)
+{
+	return (struct netlink_sock *)sk;
+}
+
+#endif
+
 #endif
diff --git a/include/net/raw.h b/include/net/raw.h
index e4af597..bec7045 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -29,6 +29,7 @@ extern int 	raw_rcv(struct sock *, struct sk_buff *);
  *       hashing mechanism, make sure you update icmp.c as well.
  */
 #define RAWV4_HTABLE_SIZE	MAX_INET_PROTOS
+extern int raw_in_use;
 extern struct hlist_head raw_v4_htable[RAWV4_HTABLE_SIZE];
 
 extern rwlock_t raw_v4_lock;
diff --git a/include/net/sock.h b/include/net/sock.h
index 2c7d60c..5e3abb6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -100,10 +100,7 @@ struct proto;
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
  *	@skc_bound_dev_if: bound device index if != 0
- *	@skc_node: main hash linkage for various protocol lookup tables
- *	@skc_bind_node: bind hash linkage for various protocol lookup tables
  *	@skc_refcnt: reference count
- *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_prot: protocol handlers inside a network family
  *
  *	This is the minimal network layer representation of sockets, the header
@@ -114,10 +111,7 @@ struct sock_common {
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
 	int			skc_bound_dev_if;
-	struct hlist_node	skc_node;
-	struct hlist_node	skc_bind_node;
 	atomic_t		skc_refcnt;
-	unsigned int		skc_hash;
 	struct proto		*skc_prot;
 };
 
@@ -190,10 +184,7 @@ struct sock {
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
-#define sk_node			__sk_common.skc_node
-#define sk_bind_node		__sk_common.skc_bind_node
 #define sk_refcnt		__sk_common.skc_refcnt
-#define sk_hash			__sk_common.skc_hash
 #define sk_prot			__sk_common.skc_prot
 	unsigned char		sk_shutdown : 2,
 				sk_no_check : 2,
@@ -261,55 +252,6 @@ struct sock {
 	void                    (*sk_destruct)(struct sock *sk);
 };
 
-/*
- * Hashed lists helper routines
- */
-static inline struct sock *__sk_head(const struct hlist_head *head)
-{
-	return hlist_entry(head->first, struct sock, sk_node);
-}
-
-static inline struct sock *sk_head(const struct hlist_head *head)
-{
-	return hlist_empty(head) ? NULL : __sk_head(head);
-}
-
-static inline struct sock *sk_next(const struct sock *sk)
-{
-	return sk->sk_node.next ?
-		hlist_entry(sk->sk_node.next, struct sock, sk_node) : NULL;
-}
-
-static inline int sk_unhashed(const struct sock *sk)
-{
-	return hlist_unhashed(&sk->sk_node);
-}
-
-static inline int sk_hashed(const struct sock *sk)
-{
-	return !sk_unhashed(sk);
-}
-
-static __inline__ void sk_node_init(struct hlist_node *node)
-{
-	node->pprev = NULL;
-}
-
-static __inline__ void __sk_del_node(struct sock *sk)
-{
-	__hlist_del(&sk->sk_node);
-}
-
-static __inline__ int __sk_del_node_init(struct sock *sk)
-{
-	if (sk_hashed(sk)) {
-		__sk_del_node(sk);
-		sk_node_init(&sk->sk_node);
-		return 1;
-	}
-	return 0;
-}
-
 /* Grab socket reference count. This operation is valid only
    when sk is ALREADY grabbed f.e. it is found in hash table
    or a list and the lookup is made under lock preventing hash table
@@ -329,21 +271,18 @@ static inline void __sock_put(struct sock *sk)
 	atomic_dec(&sk->sk_refcnt);
 }
 
-static __inline__ int sk_del_node_init(struct sock *sk)
-{
-	int rc = __sk_del_node_init(sk);
+int mdt_insert_sock(struct sock *sk);
+int mdt_remove_sock(struct sock *sk);
 
-	if (rc) {
-		/* paranoid for a while -acme */
-		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
-		__sock_put(sk);
-	}
-	return rc;
+static __inline__ int __sk_del_node_init(struct sock *sk)
+{
+	if (mdt_remove_sock(sk))
+		return 0;
+	return 1;
 }
 
 static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
 {
-	hlist_add_head(&sk->sk_node, list);
 }
 
 static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
@@ -352,30 +291,18 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
 	__sk_add_node(sk, list);
 }
 
-static __inline__ void __sk_del_bind_node(struct sock *sk)
+static __inline__ int sk_del_node_init(struct sock *sk)
 {
-	__hlist_del(&sk->sk_bind_node);
-}
+	int rc = __sk_del_node_init(sk);
 
-static __inline__ void sk_add_bind_node(struct sock *sk,
-					struct hlist_head *list)
-{
-	hlist_add_head(&sk->sk_bind_node, list);
+	if (rc) {
+		/* paranoid for a while -acme */
+		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
+		__sock_put(sk);
+	}
+	return rc;
 }
 
-#define sk_for_each(__sk, node, list) \
-	hlist_for_each_entry(__sk, node, list, sk_node)
-#define sk_for_each_from(__sk, node) \
-	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
-		hlist_for_each_entry_from(__sk, node, sk_node)
-#define sk_for_each_continue(__sk, node) \
-	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
-		hlist_for_each_entry_continue(__sk, node, sk_node)
-#define sk_for_each_safe(__sk, node, tmp, list) \
-	hlist_for_each_entry_safe(__sk, node, tmp, list, sk_node)
-#define sk_for_each_bound(__sk, node, list) \
-	hlist_for_each_entry(__sk, node, list, sk_bind_node)
-
 /* Sock flags */
 enum sock_flags {
 	SOCK_DEAD,
@@ -551,8 +478,8 @@ struct proto {
 						struct sk_buff *skb);
 
 	/* Keeping track of sk's, looking them up, and port selection methods. */
-	void			(*hash)(struct sock *sk);
-	void			(*unhash)(struct sock *sk);
+	int __must_check	(*hash)(struct sock *sk);
+	int			(*unhash)(struct sock *sk);
 	int			(*get_port)(struct sock *sk, unsigned short snum);
 
 	/* Memory pressure */
@@ -632,15 +559,6 @@ static __inline__ void sock_prot_dec_use(struct proto *prot)
 	prot->stats[smp_processor_id()].inuse--;
 }
 
-/* With per-bucket locks this operation is not-atomic, so that
- * this version is not worse.
- */
-static inline void __sk_prot_rehash(struct sock *sk)
-{
-	sk->sk_prot->unhash(sk);
-	sk->sk_prot->hash(sk);
-}
-
 /* About 10 seconds */
 #define SOCK_DESTROY_TIME (10*HZ)
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5c472f2..8301bb8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -32,7 +32,7 @@
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
-#include <net/inet_hashtables.h>
+#include <net/lookup.h>
 #include <net/checksum.h>
 #include <net/request_sock.h>
 #include <net/sock.h>
@@ -42,8 +42,6 @@
 
 #include <linux/seq_file.h>
 
-extern struct inet_hashinfo tcp_hashinfo;
-
 extern atomic_t tcp_orphan_count;
 extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 
@@ -408,6 +406,7 @@ extern struct sk_buff *		tcp_make_synack(struct sock *sk,
 extern int			tcp_disconnect(struct sock *sk, int flags);
 
 extern void			tcp_unhash(struct sock *sk);
+extern void 			tcp_v4_hash(struct sock *sk);
 
 /* From syncookies.c */
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
@@ -901,7 +900,7 @@ static inline void tcp_set_state(struct sock *sk, int state)
 		sk->sk_prot->unhash(sk);
 		if (inet_csk(sk)->icsk_bind_hash &&
 		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
-			inet_put_port(&tcp_hashinfo, sk);
+			proto_put_port(sk);
 		/* fall through */
 	default:
 		if (oldstate==TCP_ESTABLISHED)
diff --git a/include/net/udp.h b/include/net/udp.h
index 1b921fa..d80265a 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -30,6 +30,7 @@
 #include <linux/ipv6.h>
 #include <linux/seq_file.h>
 #include <linux/poll.h>
+#include <net/lookup.h>
 
 /**
  *	struct udp_skb_cb  -  UDP(-Lite) private variables
@@ -101,19 +102,15 @@ static inline __wsum udp_csum_outgoing(struct sock *sk, struct sk_buff *skb)
 }
 
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
-static inline void udp_lib_hash(struct sock *sk)
+static inline int udp_lib_hash(struct sock *sk)
 {
 	BUG();
+	return 0;
 }
 
-static inline void udp_lib_unhash(struct sock *sk)
+static inline int udp_lib_unhash(struct sock *sk)
 {
-	write_lock_bh(&udp_hash_lock);
-	if (sk_del_node_init(sk)) {
-		inet_sk(sk)->num = 0;
-		sock_prot_dec_use(sk->sk_prot);
-	}
-	write_unlock_bh(&udp_hash_lock);
+	return mdt_remove_sock(sk);
 }
 
 static inline void udp_lib_close(struct sock *sk, long timeout)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 820761f..97a8a6f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -61,6 +61,7 @@
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <net/lookup.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -2057,6 +2058,7 @@ void __init skb_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL, NULL);
+	mdt_sysinit();
 }
 
 EXPORT_SYMBOL(___pskb_trim);
diff --git a/net/core/sock.c b/net/core/sock.c
index 8d65d64..7fa3d89 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -901,7 +901,6 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sock_copy(newsk, sk);
 
 		/* SANITY */
-		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 9e8ef50..9ecd4fa 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -1,6 +1,7 @@
 #
 # IP configuration
 #
+
 config IP_MULTICAST
 	bool "IP: multicasting"
 	help
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 7a06862..a3f91ca 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -4,13 +4,13 @@
 
 obj-y     := route.o inetpeer.o protocol.o \
 	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
-	     ip_output.o ip_sockglue.o inet_hashtables.o \
+	     ip_output.o ip_sockglue.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
-	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
+	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o mdt.o
 
 obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
 obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cf358c8..3912eb3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -343,7 +343,12 @@ lookup_protocol:
 		 */
 		inet->sport = htons(inet->num);
 		/* Add to protocol hash chains. */
-		sk->sk_prot->hash(sk);
+		err = sk->sk_prot->hash(sk);
+		printk("%s: sk: %p, err: %d.\n", __func__, sk, err);
+		if (err) {
+			sock_put(sk);
+			goto out;
+		}
 	}
 
 	if (sk->sk_prot->init) {
@@ -1036,8 +1041,13 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	 * Besides that, it does not check for connection
 	 * uniqueness. Wait for troubles.
 	 */
-	__sk_prot_rehash(sk);
-	return 0;
+
+	err = mdt_remove_sock(sk);
+	err = mdt_insert_sock(sk);
+
+	printk("%s: sk: %p, err: %d.\n", __func__, sk, err);
+
+	return err;
 }
 
 int inet_sk_rebuild_header(struct sock *sk)
@@ -1359,7 +1369,8 @@ fs_initcall(inet_init);
 
 /* ------------------------------------------------------------------------ */
 
-#ifdef CONFIG_PROC_FS
+//#ifdef CONFIG_PROC_FS
+#if 0 
 static int __init ipv4_proc_init(void)
 {
 	int rc = 0;
@@ -1388,7 +1399,6 @@ out_raw:
 	rc = -ENOMEM;
 	goto out;
 }
-
 #else /* CONFIG_PROC_FS */
 static int __init ipv4_proc_init(void)
 {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4b7a0d9..99c2297 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -698,17 +698,13 @@ static void icmp_unreach(struct sk_buff *skb)
 
 	/* Note: See raw.c and net/raw.h, RAWV4_HTABLE_SIZE==MAX_INET_PROTOS */
 	hash = protocol & (MAX_INET_PROTOS - 1);
-	read_lock(&raw_v4_lock);
-	if ((raw_sk = sk_head(&raw_v4_htable[hash])) != NULL) {
-		while ((raw_sk = __raw_v4_lookup(raw_sk, protocol, iph->daddr,
-						 iph->saddr,
-						 skb->dev->ifindex)) != NULL) {
-			raw_err(raw_sk, skb, info);
-			raw_sk = sk_next(raw_sk);
-			iph = (struct iphdr *)skb->data;
-		}
+	raw_sk = __raw_v4_lookup(NULL, protocol, iph->daddr,
+					 iph->saddr,
+					 skb->dev->ifindex);
+	if (raw_sk) {
+		raw_err(raw_sk, skb, info);
+		iph = (struct iphdr *)skb->data;
 	}
-	read_unlock(&raw_v4_lock);
 
 	rcu_read_lock();
 	ipprot = rcu_dereference(inet_protos[hash]);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 43fb160..8f0dd60 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -17,7 +17,7 @@
 #include <linux/jhash.h>
 
 #include <net/inet_connection_sock.h>
-#include <net/inet_hashtables.h>
+#include <net/lookup.h>
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
 #include <net/route.h>
@@ -36,130 +36,6 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  */
 int sysctl_local_port_range[2] = { 1024, 4999 };
 
-int inet_csk_bind_conflict(const struct sock *sk,
-			   const struct inet_bind_bucket *tb)
-{
-	const __be32 sk_rcv_saddr = inet_rcv_saddr(sk);
-	struct sock *sk2;
-	struct hlist_node *node;
-	int reuse = sk->sk_reuse;
-
-	sk_for_each_bound(sk2, node, &tb->owners) {
-		if (sk != sk2 &&
-		    !inet_v6_ipv6only(sk2) &&
-		    (!sk->sk_bound_dev_if ||
-		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
-			if (!reuse || !sk2->sk_reuse ||
-			    sk2->sk_state == TCP_LISTEN) {
-				const __be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
-				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
-				    sk2_rcv_saddr == sk_rcv_saddr)
-					break;
-			}
-		}
-	}
-	return node != NULL;
-}
-
-EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
-
-/* Obtain a reference to a local port for the given sock,
- * if snum is zero it means select any available local port.
- */
-int inet_csk_get_port(struct inet_hashinfo *hashinfo,
-		      struct sock *sk, unsigned short snum,
-		      int (*bind_conflict)(const struct sock *sk,
-					   const struct inet_bind_bucket *tb))
-{
-	struct inet_bind_hashbucket *head;
-	struct hlist_node *node;
-	struct inet_bind_bucket *tb;
-	int ret;
-
-	local_bh_disable();
-	if (!snum) {
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
-		int remaining = (high - low) + 1;
-		int rover = net_random() % (high - low) + low;
-
-		do {
-			head = &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];
-			spin_lock(&head->lock);
-			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (tb->port == rover)
-					goto next;
-			break;
-		next:
-			spin_unlock(&head->lock);
-			if (++rover > high)
-				rover = low;
-		} while (--remaining > 0);
-
-		/* Exhausted local port range during search?  It is not
-		 * possible for us to be holding one of the bind hash
-		 * locks if this test triggers, because if 'remaining'
-		 * drops to zero, we broke out of the do/while loop at
-		 * the top level, not from the 'break;' statement.
-		 */
-		ret = 1;
-		if (remaining <= 0)
-			goto fail;
-
-		/* OK, here is the one we will use.  HEAD is
-		 * non-NULL and we hold it's mutex.
-		 */
-		snum = rover;
-	} else {
-		head = &hashinfo->bhash[inet_bhashfn(snum, hashinfo->bhash_size)];
-		spin_lock(&head->lock);
-		inet_bind_bucket_for_each(tb, node, &head->chain)
-			if (tb->port == snum)
-				goto tb_found;
-	}
-	tb = NULL;
-	goto tb_not_found;
-tb_found:
-	if (!hlist_empty(&tb->owners)) {
-		if (sk->sk_reuse > 1)
-			goto success;
-		if (tb->fastreuse > 0 &&
-		    sk->sk_reuse && sk->sk_state != TCP_LISTEN) {
-			goto success;
-		} else {
-			ret = 1;
-			if (bind_conflict(sk, tb))
-				goto fail_unlock;
-		}
-	}
-tb_not_found:
-	ret = 1;
-	if (!tb && (tb = inet_bind_bucket_create(hashinfo->bind_bucket_cachep, head, snum)) == NULL)
-		goto fail_unlock;
-	if (hlist_empty(&tb->owners)) {
-		if (sk->sk_reuse && sk->sk_state != TCP_LISTEN)
-			tb->fastreuse = 1;
-		else
-			tb->fastreuse = 0;
-	} else if (tb->fastreuse &&
-		   (!sk->sk_reuse || sk->sk_state == TCP_LISTEN))
-		tb->fastreuse = 0;
-success:
-	if (!inet_csk(sk)->icsk_bind_hash)
-		inet_bind_hash(sk, tb, snum);
-	BUG_TRAP(inet_csk(sk)->icsk_bind_hash == tb);
-	ret = 0;
-
-fail_unlock:
-	spin_unlock(&head->lock);
-fail:
-	local_bh_enable();
-	return ret;
-}
-
-EXPORT_SYMBOL_GPL(inet_csk_get_port);
-
 /*
  * Wait for an incoming connection, avoid race conditions. This must be called
  * with the socket locked.
@@ -529,12 +405,6 @@ void inet_csk_destroy_sock(struct sock *sk)
 	BUG_TRAP(sk->sk_state == TCP_CLOSE);
 	BUG_TRAP(sock_flag(sk, SOCK_DEAD));
 
-	/* It cannot be in hash table! */
-	BUG_TRAP(sk_unhashed(sk));
-
-	/* If it has not 0 inet_sk(sk)->num, it must be bound */
-	BUG_TRAP(!inet_sk(sk)->num || inet_csk(sk)->icsk_bind_hash);
-
 	sk->sk_prot->destroy(sk);
 
 	sk_stream_kill_queues(sk);
@@ -572,8 +442,6 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 		inet->sport = htons(inet->num);
 
 		sk_dst_reset(sk);
-		sk->sk_prot->hash(sk);
-
 		return 0;
 	}
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 5df71cd..e4f9a86 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -24,7 +24,7 @@
 #include <net/ipv6.h>
 #include <net/inet_common.h>
 #include <net/inet_connection_sock.h>
-#include <net/inet_hashtables.h>
+#include <net/lookup.h>
 #include <net/inet_timewait_sock.h>
 #include <net/inet6_hashtables.h>
 
@@ -238,9 +238,10 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	hashinfo = handler->idiag_hashinfo;
 
 	if (req->idiag_family == AF_INET) {
-		sk = inet_lookup(hashinfo, req->id.idiag_dst[0],
+		sk = sock_lookup(req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
-				 req->id.idiag_sport, req->id.idiag_if);
+				 req->id.idiag_sport, req->id.idiag_if,
+				 IPPROTO_TCP);
 	}
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 	else if (req->idiag_family == AF_INET6) {
@@ -670,6 +671,9 @@ out:
 
 static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+#ifdef CONFIG_MDT_LOOKUP
+	return -1;
+#else
 	int i, num;
 	int s_i, s_num;
 	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
@@ -803,6 +807,7 @@ done:
 	cb->args[1] = i;
 	cb->args[2] = num;
 	return skb->len;
+#endif
 }
 
 static inline int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a73cf93..8fb1d1b 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -9,84 +9,25 @@
  */
 
 
-#include <net/inet_hashtables.h>
+#include <net/lookup.h>
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
 
-/* Must be called with locally disabled BHs. */
-void __inet_twsk_kill(struct inet_timewait_sock *tw, struct inet_hashinfo *hashinfo)
+void __inet_twsk_kill(struct inet_timewait_sock *tw)
 {
-	struct inet_bind_hashbucket *bhead;
-	struct inet_bind_bucket *tb;
-	/* Unlink from established hashes. */
-	struct inet_ehash_bucket *ehead = inet_ehash_bucket(hashinfo, tw->tw_hash);
-
-	write_lock(&ehead->lock);
-	if (hlist_unhashed(&tw->tw_node)) {
-		write_unlock(&ehead->lock);
-		return;
-	}
-	__hlist_del(&tw->tw_node);
-	sk_node_init(&tw->tw_node);
-	write_unlock(&ehead->lock);
-
-	/* Disassociate with bind bucket. */
-	bhead = &hashinfo->bhash[inet_bhashfn(tw->tw_num, hashinfo->bhash_size)];
-	spin_lock(&bhead->lock);
-	tb = tw->tw_tb;
-	__hlist_del(&tw->tw_bind_node);
-	tw->tw_tb = NULL;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
-	spin_unlock(&bhead->lock);
-#ifdef SOCK_REFCNT_DEBUG
-	if (atomic_read(&tw->tw_refcnt) != 1) {
-		printk(KERN_DEBUG "%s timewait_sock %p refcnt=%d\n",
-		       tw->tw_prot->name, tw, atomic_read(&tw->tw_refcnt));
-	}
-#endif
 	inet_twsk_put(tw);
+	mdt_remove_sock_tw(tw);
 }
 
-EXPORT_SYMBOL_GPL(__inet_twsk_kill);
-
-/*
- * Enter the time wait state. This is called with locally disabled BH.
- * Essentially we whip up a timewait bucket, copy the relevant info into it
- * from the SK, and mess with hash chains and list linkage.
- */
-void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
-			   struct inet_hashinfo *hashinfo)
+void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk)
 {
-	const struct inet_sock *inet = inet_sk(sk);
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct inet_ehash_bucket *ehead = inet_ehash_bucket(hashinfo, sk->sk_hash);
-	struct inet_bind_hashbucket *bhead;
-	/* Step 1: Put TW into bind hash. Original socket stays there too.
-	   Note, that any socket with inet->num != 0 MUST be bound in
-	   binding cache, even if it is closed.
-	 */
-	bhead = &hashinfo->bhash[inet_bhashfn(inet->num, hashinfo->bhash_size)];
-	spin_lock(&bhead->lock);
-	tw->tw_tb = icsk->icsk_bind_hash;
-	BUG_TRAP(icsk->icsk_bind_hash);
-	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
-	spin_unlock(&bhead->lock);
-
-	write_lock(&ehead->lock);
-
-	/* Step 2: Remove SK from established hash. */
 	if (__sk_del_node_init(sk))
 		sock_prot_dec_use(sk->sk_prot);
 
-	/* Step 3: Hash TW into TIMEWAIT chain. */
-	inet_twsk_add_node(tw, &ehead->twchain);
+	mdt_insert_sock_tw(tw);
 	atomic_inc(&tw->tw_refcnt);
-
-	write_unlock(&ehead->lock);
 }
 
-EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
-
 struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int state)
 {
 	struct inet_timewait_sock *tw =
@@ -106,7 +47,6 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_dport	    = inet->dport;
 		tw->tw_family	    = sk->sk_family;
 		tw->tw_reuse	    = sk->sk_reuse;
-		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
 		atomic_set(&tw->tw_refcnt, 1);
@@ -140,7 +80,7 @@ rescan:
 	inet_twsk_for_each_inmate(tw, node, &twdr->cells[slot]) {
 		__inet_twsk_del_dead_node(tw);
 		spin_unlock(&twdr->death_lock);
-		__inet_twsk_kill(tw, twdr->hashinfo);
+		__inet_twsk_kill(tw);
 		inet_twsk_put(tw);
 		killed++;
 		spin_lock(&twdr->death_lock);
@@ -242,7 +182,7 @@ void inet_twsk_deschedule(struct inet_timewait_sock *tw,
 			del_timer(&twdr->tw_timer);
 	}
 	spin_unlock(&twdr->death_lock);
-	__inet_twsk_kill(tw, twdr->hashinfo);
+	__inet_twsk_kill(tw);
 }
 
 EXPORT_SYMBOL(inet_twsk_deschedule);
@@ -354,7 +294,7 @@ void inet_twdr_twcal_tick(unsigned long data)
 			inet_twsk_for_each_inmate_safe(tw, node, safe,
 						       &twdr->twcal_row[slot]) {
 				__inet_twsk_del_dead_node(tw);
-				__inet_twsk_kill(tw, twdr->hashinfo);
+				__inet_twsk_kill(tw);
 				inet_twsk_put(tw);
 				killed++;
 			}
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f38e976..be3e683 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -209,19 +209,17 @@ static inline int ip_local_deliver_finish(struct sk_buff *skb)
 	{
 		/* Note: See raw.c and net/raw.h, RAWV4_HTABLE_SIZE==MAX_INET_PROTOS */
 		int protocol = skb->nh.iph->protocol;
-		int hash;
-		struct sock *raw_sk;
+		int hash, raw = raw_in_use;
 		struct net_protocol *ipprot;
 
 	resubmit:
 		hash = protocol & (MAX_INET_PROTOS - 1);
-		raw_sk = sk_head(&raw_v4_htable[hash]);
 
 		/* If there maybe a raw socket we must check - if not we
 		 * don't care less
 		 */
-		if (raw_sk && !raw_v4_input(skb, skb->nh.iph, hash))
-			raw_sk = NULL;
+		if (raw_in_use && !raw_v4_input(skb, skb->nh.iph, hash))
+			raw = 0;
 
 		if ((ipprot = rcu_dereference(inet_protos[hash])) != NULL) {
 			int ret;
@@ -240,7 +238,7 @@ static inline int ip_local_deliver_finish(struct sk_buff *skb)
 			}
 			IP_INC_STATS_BH(IPSTATS_MIB_INDELIVERS);
 		} else {
-			if (!raw_sk) {
+			if (!raw) {
 				if (xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 					IP_INC_STATS_BH(IPSTATS_MIB_INUNKNOWNPROTOS);
 					icmp_send(skb, ICMP_DEST_UNREACH,
diff --git a/net/ipv4/mdt.c b/net/ipv4/mdt.c
new file mode 100644
index 0000000..7556c57
--- /dev/null
+++ b/net/ipv4/mdt.c
@@ -0,0 +1,650 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/in.h>
+#include <linux/spinlock.h>
+#include <linux/rcupdate.h>
+#include <linux/jhash.h>
+#include <linux/un.h>
+#include <net/af_unix.h>
+
+#include <net/tcp_states.h>
+#include <net/tcp.h>
+#include <net/inet_sock.h>
+#include <net/lookup.h>
+#include <net/netlink.h>
+
+#define MDT_BITS_PER_NODE		8
+#define MDT_NODE_MASK			((1<<MDT_BITS_PER_NODE)-1)
+#define MDT_DIMS			(1<<MDT_BITS_PER_NODE)
+
+#define MDT_NODES_PER_LONG		(BITS_PER_LONG/MDT_BITS_PER_NODE)
+
+#define	MDT_LEAF_STRUCT_BIT	0x00000001
+
+#define MDT_SET_LEAF_STORAGE(leaf, ptr) do { \
+	rcu_assign_pointer((leaf), (struct mdt_node *)(((unsigned long)(ptr)) | MDT_LEAF_STRUCT_BIT)); \
+} while (0)
+
+#define MDT_SET_LEAF_PTR(leaf, ptr) do { \
+	rcu_assign_pointer((leaf), (ptr)); \
+} while (0)
+
+#define MDT_SET_LEAF_LEVEL(leaf, ptr) MDT_SET_LEAF_PTR(leaf, ptr)
+
+#define MDT_LEAF_IS_STORAGE(leaf)	(((unsigned long)leaf) & MDT_LEAF_STRUCT_BIT)
+#define MDT_GET_STORAGE(leaf)		((struct mdt_storage *)(((unsigned long)leaf) & ~MDT_LEAF_STRUCT_BIT))
+
+/* Cached number of longs must be equal to key size - BITS_PER_LONG */
+#if BITS_PER_LONG == 64
+#define MDT_CACHED_NUM			2
+#else
+#define MDT_CACHED_NUM			4
+#endif
+
+#if 0
+#define ulog(f, a...) printk(KERN_INFO f, ##a)
+#else
+#define ulog(f, a...)
+#endif
+
+struct mdt_node
+{
+	struct rcu_head		rcu_head;
+	atomic_t		refcnt;
+	DECLARE_BITMAP(map, MDT_DIMS);
+	struct mdt_node		*leaf[MDT_DIMS];
+};
+
+struct mdt_storage
+{
+	struct rcu_head		rcu_head;
+	unsigned long		val[MDT_CACHED_NUM];
+	void			*priv;
+};
+
+static struct kmem_cache *mdt_node_cache, *mdt_storage_cache;
+
+static struct mdt_node mdt_root;
+static DEFINE_SPINLOCK(mdt_root_lock);
+
+static inline int mdt_last_equal(unsigned long *st_val, unsigned long *val, int longs)
+{
+	int i;
+	for (i=0; i<longs; ++i) {
+		if (st_val[i] != val[i])
+			return 0;
+	}
+	return 1;	
+}
+
+static void *mdt_lookup(struct mdt_node *n, void *key, unsigned int bits)
+{
+	unsigned long *data = key;
+	unsigned long val, idx;
+	unsigned int i, j;
+	struct mdt_storage *st;
+
+	i = 0;
+	while (1) {
+		val = *data++;
+		for (j=0; j<MDT_NODES_PER_LONG; ++j) {
+			idx = val & MDT_NODE_MASK;
+			n = rcu_dereference(n->leaf[idx]);
+
+			ulog("   %2u/%2u: S n: %p, idx: %lu, is_storage: %lu, val: %lx.\n",
+				i, bits, n, idx, (n)?MDT_LEAF_IS_STORAGE(n):0, val);
+
+			if (!n)
+				return NULL;
+
+			i += MDT_BITS_PER_NODE;
+			if (MDT_LEAF_IS_STORAGE(n)) {
+				st = MDT_GET_STORAGE(n);
+				if (st->val[0] != val || 
+					!mdt_last_equal(&st->val[1], data, (bits-i)/BITS_PER_LONG-1))
+					return NULL;
+
+				ulog("      storage ret: %p\n", st->priv);
+				return st->priv;
+			}
+
+			val >>= MDT_BITS_PER_NODE;
+		}
+	}
+
+	return NULL;
+}
+
+static inline struct mdt_node *mdt_alloc_node(gfp_t gfp_flags)
+{
+	struct mdt_node *new;
+
+	new = kmem_cache_zalloc(mdt_node_cache, gfp_flags);
+	if (!new)
+		return NULL;
+	memset(new, 0, sizeof(struct mdt_node));
+	atomic_set(&new->refcnt, 1);
+
+	ulog("%s: node: %p.\n", __func__, new);
+	return new;
+}
+
+static inline struct mdt_storage *mdt_alloc_storage(gfp_t gfp_flags)
+{
+	struct mdt_storage *new;
+
+	new = kmem_cache_zalloc(mdt_storage_cache, gfp_flags);
+	if (!new)
+		return NULL;
+	memset(new, 0, sizeof(struct mdt_storage));
+	ulog("%s: storage: %p.\n", __func__, new);
+	return new;
+}
+
+static inline void mdt_free_storage_rcu(struct rcu_head *rcu_head)
+{
+	struct mdt_storage *st = container_of(rcu_head, struct mdt_storage, rcu_head);
+	ulog("%s: storage: %p.\n", __func__, st);
+	kmem_cache_free(mdt_storage_cache, st);
+}
+
+static inline void mdt_free_storage(struct mdt_storage *st)
+{
+	ulog("%s: storage: %p.\n", __func__, st);
+	call_rcu(&st->rcu_head, mdt_free_storage_rcu);
+}
+
+static inline void mdt_free_node_rcu(struct rcu_head *rcu_head)
+{
+	struct mdt_node *node = container_of(rcu_head, struct mdt_node, rcu_head);
+	ulog("%s: node: %p.\n", __func__, node);
+	kmem_cache_free(mdt_node_cache, node);
+}
+
+static inline void mdt_free_node(struct mdt_node *node)
+{
+	ulog("%s: node: %p.\n", __func__, node);
+	call_rcu(&node->rcu_head, mdt_free_node_rcu);
+}
+
+static inline void mdt_node_put(struct mdt_node *node, unsigned long index)
+{
+	int idx, off;
+
+	idx = index / BITS_PER_LONG;
+	off = index % BITS_PER_LONG;
+
+	node->map[idx] &= ~(1<<off);
+
+	if (atomic_dec_and_test(&node->refcnt))
+		mdt_free_node(node);
+}
+
+static inline void mdt_node_get(struct mdt_node *node, unsigned long index)
+{
+	int idx, off;
+
+	idx = index / BITS_PER_LONG;
+	off = index % BITS_PER_LONG;
+
+	node->map[idx] |= (1<<off);
+
+	atomic_inc(&node->refcnt);
+}
+
+static int mdt_insert(struct mdt_node *n, void *key, unsigned int bits, void *priv, gfp_t gfp_flags)
+{
+	struct mdt_node *prev, *new;
+	unsigned long *data = key;
+	unsigned long val, idx;
+	unsigned int i, j;
+
+	ulog("Insert: root: %p, bits: %u, priv: %p.\n", n, bits, priv);
+
+	i = 0;
+	prev = n;
+	while (1) {
+		val = *data++;
+		for (j=0; j<MDT_NODES_PER_LONG; ++j) {
+			idx = val & MDT_NODE_MASK;
+			n = rcu_dereference(prev->leaf[idx]);
+
+			ulog("   %2u/%2u/%u: I n: %p, idx: %lu, is_storage: %lu, val: %lx.\n",
+				i, bits, j, n, idx, (n)?MDT_LEAF_IS_STORAGE(n):0, val);
+
+			i += MDT_BITS_PER_NODE;
+			if (i >= bits && n)
+				return -EEXIST;
+
+			if (!n) {
+				if (bits - i <= BITS_PER_LONG*MDT_CACHED_NUM + MDT_BITS_PER_NODE) {
+					struct mdt_storage *st = mdt_alloc_storage(gfp_flags);
+					if (!st)
+						return -ENOMEM;
+					st->val[0] = val;
+					for (j=1; j<MDT_CACHED_NUM; ++j) {
+						i += MDT_BITS_PER_NODE;
+						if (i < bits)
+							st->val[j] = data[j-1];
+						else
+							st->val[j] = 0;
+						ulog("    j: %d, i: %d, bits: %d, st_val: %lx\n", j, i, bits, st->val[j]);
+					}
+					st->priv = priv;
+					MDT_SET_LEAF_STORAGE(prev->leaf[idx], st);
+					mdt_node_get(prev, idx);
+					return 0;
+				}
+				new = mdt_alloc_node(gfp_flags);
+				if (!new)
+					return -ENOMEM;
+				MDT_SET_LEAF_LEVEL(prev->leaf[idx], new);
+				mdt_node_get(prev, idx);
+				prev = new;
+			} else {
+				struct mdt_storage *st;
+
+				if (!MDT_LEAF_IS_STORAGE(n)) {
+					prev = n;
+					val >>= MDT_BITS_PER_NODE;
+					continue;
+				}
+
+				st = MDT_GET_STORAGE(n);
+				if ((st->val[0] == val) && 
+					mdt_last_equal(&st->val[1], data, 
+						MDT_CACHED_NUM-1))
+					return -EEXIST;
+
+				new = mdt_alloc_node(gfp_flags);
+				if (!new)
+					return -ENOMEM;
+				MDT_SET_LEAF_LEVEL(prev->leaf[idx], new);
+				mdt_node_get(prev, idx);
+				prev = new;
+
+				if (j<MDT_NODES_PER_LONG-1) {
+					st->val[0] >>= MDT_BITS_PER_NODE;
+				} else {
+					unsigned int k;
+
+					for (k=0; k<MDT_CACHED_NUM-1; ++k)
+						st->val[k] = st->val[k+1];
+					st->val[MDT_CACHED_NUM-1] = 0;
+				}
+				idx = st->val[0] & MDT_NODE_MASK;
+
+				MDT_SET_LEAF_STORAGE(prev->leaf[idx], st);
+				ulog("   setting old storage %p into idx %lu.\n", st, idx);
+			}
+
+			val >>= MDT_BITS_PER_NODE;
+		}
+	}
+
+	return -EINVAL;
+}
+
+static int mdt_remove(struct mdt_node *n, void *key, unsigned int bits)
+{
+	unsigned long *data = key;
+	unsigned long val, idx;
+	unsigned int i, j;
+	struct mdt_node *prev = n;
+	struct mdt_storage *st;
+
+	i = 0;
+	while (1) {
+		val = *data++;
+		for (j=0; j<MDT_NODES_PER_LONG; ++j) {
+			idx = val & MDT_NODE_MASK;
+			n = rcu_dereference(prev->leaf[idx]);
+
+			ulog("   %2u/%2u: R n: %p, idx: %lu, is_storage: %lu, val: %lx.\n",
+				i, bits, n, idx, (n)?MDT_LEAF_IS_STORAGE(n):0, val);
+
+			if (!n)
+				return -ENODEV;
+
+			i += MDT_BITS_PER_NODE;
+			if (MDT_LEAF_IS_STORAGE(n)) {
+				st = MDT_GET_STORAGE(n);
+				if ((st->val[0] != val) || 
+					!mdt_last_equal(&st->val[1], data, MDT_CACHED_NUM-1))
+					return -ENODEV;
+				MDT_SET_LEAF_PTR(prev->leaf[idx], NULL);
+				ulog("      storage ret: %p.\n", st->priv);
+				mdt_free_storage(st);
+				return 0;
+			}
+
+			val >>= MDT_BITS_PER_NODE;
+			prev = n;
+		}
+	}
+
+	return -EINVAL;
+}
+
+struct sock *mdt_lookup_proto(const __be32 saddr, const __be16 sport,
+	const __be32 daddr, const __be16 dport, const int dif, const __u8 proto, int stages)
+{
+	struct sock *sk;
+	u32 key[5] = {saddr, daddr, (sport<<16)|dport, (proto << 24) | (AF_INET << 16), 0};
+
+	rcu_read_lock();
+	sk = mdt_lookup(&mdt_root, key, sizeof(key)<<3);
+	if (proto == IPPROTO_TCP && 0) {
+		printk("%s: 1 %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, if: %d, proto: %d, sk: %p.\n", 
+			__func__, NIPQUAD(saddr), ntohs(sport),
+			NIPQUAD(daddr), ntohs(dport),
+			dif, proto, sk);
+		printk("%s: key: %x %x %x %x %x.\n", __func__, key[0], key[1], key[2], key[3], key[4]);
+	}
+
+	if (!sk && stages) {
+		key[0] = key[1] = 0;
+		key[2] = dport;
+		key[3] = (0 & 0x0000ffff) | (proto << 24) | (AF_INET << 16);
+
+		sk = mdt_lookup(&mdt_root, key, sizeof(key)<<3);
+		if (proto == IPPROTO_TCP && 0) {
+			printk("%s: 2 %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, if: %d, proto: %d, sk: %p.\n", 
+				__func__, NIPQUAD(key[0]), ntohs(0),
+				NIPQUAD(key[1]), ntohs(dport),
+				0, proto, sk);
+			printk("%s: key: %x %x %x %x %x.\n", __func__, key[0], key[1], key[2], key[3], key[4]);
+		}
+	}
+
+	if (sk)
+		sock_hold(sk);
+	rcu_read_unlock();
+	return sk;
+}
+
+static void mdt_prepare_key_inet(struct sock *sk, u32 *key, char *str)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	if (sk->sk_state == TCP_LISTEN || 1) {
+		key[0] = inet->daddr;
+		key[1] = inet->rcv_saddr;
+		key[2] = (inet->dport<<16)|htons(inet->num);
+	} else {
+		key[0] = inet->rcv_saddr;
+		key[1] = inet->daddr;
+		key[2] = (htons(inet->num)<<16)|inet->dport;
+	}
+	key[3] = (sk->sk_bound_dev_if & 0x0000ffff) | (sk->sk_protocol << 24) | (AF_INET << 16);
+	key[4] = 0;
+#if 0
+	printk("mdt: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, if: %d, proto: %d.\n", 
+			str,
+			NIPQUAD(inet->rcv_saddr), inet->num,
+			NIPQUAD(inet->daddr), ntohs(inet->dport),
+			sk->sk_bound_dev_if, sk->sk_protocol);
+	printk("%s: key: %x %x %x %x %x.\n", __func__, key[0], key[1], key[2], key[3], key[4]);
+#endif
+}
+
+int mdt_insert_sock(struct sock *sk)
+{
+	u32 key[5];
+	int err;
+
+	if (sk->sk_state == TCP_CLOSE)
+		return 0;
+
+	mdt_prepare_key_inet(sk, key, "insert");
+
+	spin_lock_bh(&mdt_root_lock);
+	err = mdt_insert(&mdt_root, key, sizeof(key)<<3, sk, GFP_ATOMIC);
+	if (!err) {
+		sock_prot_inc_use(sk->sk_prot);
+	}
+	spin_unlock_bh(&mdt_root_lock);
+	return err;
+}
+
+int mdt_remove_sock(struct sock *sk)
+{
+	u32 key[5];
+	int err;
+
+	if (sk->sk_state == TCP_CLOSE)
+		return 0;
+
+	mdt_prepare_key_inet(sk, key, "remove");
+
+	spin_lock_bh(&mdt_root_lock);
+	err = mdt_remove(&mdt_root, key, sizeof(key)<<3);
+	if (!err) {
+		local_bh_disable();
+		sock_prot_dec_use(sk->sk_prot);
+		local_bh_enable();
+	}
+	spin_unlock_bh(&mdt_root_lock);
+	return err;
+}
+
+static inline u32 inet_sk_port_offset(const struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	return secure_ipv4_port_ephemeral(inet->rcv_saddr, inet->daddr,
+					  inet->dport);
+}
+
+int mdt_insert_sock_port(struct sock *sk, unsigned short snum)
+{
+	int low = sysctl_local_port_range[0];
+	int high = sysctl_local_port_range[1];
+	int range = high - low;
+	int i, err = 1;
+	int port = snum;
+	static u32 hint;
+	u32 offset = hint + inet_sk_port_offset(sk);
+	
+	if (snum == 0) {
+		for (i = 1; i <= range; i++) {
+			port = low + (i + offset) % range;
+
+			inet_sk(sk)->num = port;
+			if (!mdt_insert_sock(sk)) {
+				inet_sk(sk)->sport = htons(port);
+				err = 0;
+				break;
+			}
+		}
+	} else {
+		inet_sk(sk)->num = port;
+		if (!mdt_insert_sock(sk)) {
+			inet_sk(sk)->sport = htons(port);
+			err = 0;
+		}
+	}
+
+	return err;
+}
+
+int mdt_insert_netlink(struct sock *sk, u32 pid)
+{
+	u32 key[5] = {0, pid, 0, (sk->sk_protocol << 24)|(AF_NETLINK<<16), 0};
+	int err;
+
+	spin_lock_bh(&mdt_root_lock);
+	err = mdt_insert(&mdt_root, key, sizeof(key)<<3, sk, GFP_ATOMIC);
+	spin_unlock_bh(&mdt_root_lock);
+	nlk_sk(sk)->pid = pid;
+
+	return err;
+}
+
+int mdt_remove_netlink(struct sock *sk)
+{
+	u32 key[5] = {0, nlk_sk(sk)->pid, 0, (sk->sk_protocol << 24)|(AF_NETLINK<<16), 0};
+	int err;
+
+	spin_lock_bh(&mdt_root_lock);
+	err = mdt_remove(&mdt_root, key, sizeof(key)<<3);
+	spin_unlock_bh(&mdt_root_lock);
+	printk("%s: proto: %d, pid: %u, sk: %p, key: %x %x %x %x %x\n",
+			__func__, sk->sk_protocol, nlk_sk(sk)->pid, sk, key[0],  key[1], key[2], key[3], key[4]);
+
+	return err;
+}
+
+struct sock *netlink_lookup(int protocol, u32 pid)
+{
+	u32 key[5] = {0, pid, 0, (protocol << 24)|(AF_NETLINK<<16), 0};
+	struct sock *sk;
+
+	rcu_read_lock();
+	sk = mdt_lookup(&mdt_root, key, sizeof(key)<<3);
+	if (sk)
+		sock_hold(sk);
+	rcu_read_unlock();
+	return sk;
+}
+
+void mdt_insert_sock_tw(struct inet_timewait_sock *tw)
+{
+	u32 key[5] = {tw->tw_rcv_saddr, tw->tw_daddr, (tw->tw_sport<<16)|tw->tw_dport, 
+		(tw->tw_bound_dev_if & 0x0000ffff) | (IPPROTO_TCP << 24) | (AF_INET << 16), 0};
+
+	spin_lock_bh(&mdt_root_lock);
+	mdt_insert(&mdt_root, key, sizeof(key)<<3, tw, GFP_ATOMIC);
+	spin_unlock_bh(&mdt_root_lock);
+}
+
+void mdt_remove_sock_tw(struct inet_timewait_sock *tw)
+{
+	u32 key[5] = {tw->tw_rcv_saddr, tw->tw_daddr, (tw->tw_sport<<16)|tw->tw_dport, 
+		(tw->tw_bound_dev_if & 0x0000ffff) | (IPPROTO_TCP << 24) | (AF_INET << 16), 0};
+
+	spin_lock_bh(&mdt_root_lock);
+	mdt_remove(&mdt_root, key, sizeof(key)<<3);
+	spin_unlock_bh(&mdt_root_lock);
+}
+
+static void mdt_prepare_key_unix(struct sockaddr_un *sunname, int len, int type, u32 *key)
+{
+	int i, sz;
+	unsigned char *ptr = sunname->sun_path;
+
+	sz = min(3, len);
+
+	memcpy(key, ptr, sz);
+	len -= sz;
+	ptr += sz;
+
+	while (len) {
+		for (i=0; i<3 && len; i++) {
+			key[i] = jhash_1word(key[i], *ptr);
+			ptr++;
+			len--;
+		}
+	}
+
+	key[3] = (AF_UNIX << 16) | (type & 0xffff);
+	key[4] = 0;
+
+}
+
+struct sock *__unix_find_socket_byname(struct sockaddr_un *sunname,
+					      int len, int type, unsigned hash)
+{
+	struct sock *sk;
+	u32 key[5];
+
+	mdt_prepare_key_unix(sunname, len, type, key);
+
+	rcu_read_lock();
+	sk = mdt_lookup(&mdt_root, key, sizeof(key)<<3);
+	if (sk)
+		sock_hold(sk);
+	rcu_read_unlock();
+#if 0
+	printk("lookup unix socket %p, key: %x %x %x %x %x\n", 
+			sk, key[0],  key[1], key[2], key[3], key[4]);
+#endif
+	return sk;
+}
+
+void __unix_insert_socket(struct hlist_head *list, struct sock *sk)
+{
+	struct unix_sock *u = unix_sk(sk);
+	u32 key[5];
+	int type = 0;
+
+	if (sk->sk_socket)
+		type = sk->sk_socket->type;
+
+	if (!u->addr) {
+		key[0] = key[1] = key[2] = key[3] = key[4] = 0;
+		memcpy(key, &sk, sizeof(void *));
+	} else {
+		mdt_prepare_key_unix(u->addr->name, u->addr->len, 0, key);
+	}
+#if 0
+	printk("added unix socket %p, key: %x %x %x %x %x\n", 
+			sk, key[0],  key[1], key[2], key[3], key[4]);
+#endif
+	spin_lock_bh(&mdt_root_lock);
+	mdt_insert(&mdt_root, key, sizeof(key)<<3, sk, GFP_ATOMIC);
+	spin_unlock_bh(&mdt_root_lock);
+}
+
+void __unix_remove_socket(struct sock *sk)
+{
+	struct unix_sock *u = unix_sk(sk);
+	u32 key[5];
+	int type = 0;
+
+	if (sk->sk_socket)
+		type = sk->sk_socket->type;
+
+	if (!u->addr) {
+		key[0] = key[1] = key[2] = key[3] = key[4] = 0;
+		memcpy(key, &sk, sizeof(void *));
+	} else {
+		mdt_prepare_key_unix(u->addr->name, u->addr->len, 0, key);
+	}
+#if 0
+	printk("removed unix socket %p, key: %x %x %x %x %x\n", 
+			sk, key[0],  key[1], key[2], key[3], key[4]);
+#endif	
+	spin_lock_bh(&mdt_root_lock);
+	mdt_remove(&mdt_root, key, sizeof(key)<<3);
+	spin_unlock_bh(&mdt_root_lock);
+}
+
+int __init mdt_sysinit(void)
+{
+	mdt_storage_cache = kmem_cache_create("mdt_storage", sizeof(struct mdt_storage), 
+			0, SLAB_PANIC, NULL, NULL);
+	
+	mdt_node_cache = kmem_cache_create("mdt_node", sizeof(struct mdt_node), 
+			0, SLAB_PANIC, NULL, NULL);
+
+	return 0;
+}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 87e9c16..8bd3b2d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -78,47 +78,15 @@
 #include <linux/seq_file.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
+#include <net/lookup.h>
 
-struct hlist_head raw_v4_htable[RAWV4_HTABLE_SIZE];
-DEFINE_RWLOCK(raw_v4_lock);
-
-static void raw_v4_hash(struct sock *sk)
-{
-	struct hlist_head *head = &raw_v4_htable[inet_sk(sk)->num &
-						 (RAWV4_HTABLE_SIZE - 1)];
-
-	write_lock_bh(&raw_v4_lock);
-	sk_add_node(sk, head);
-	sock_prot_inc_use(sk->sk_prot);
-	write_unlock_bh(&raw_v4_lock);
-}
-
-static void raw_v4_unhash(struct sock *sk)
-{
-	write_lock_bh(&raw_v4_lock);
-	if (sk_del_node_init(sk))
-		sock_prot_dec_use(sk->sk_prot);
-	write_unlock_bh(&raw_v4_lock);
-}
+int raw_in_use = 0;
 
 struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
 			     __be32 raddr, __be32 laddr,
 			     int dif)
 {
-	struct hlist_node *node;
-
-	sk_for_each_from(sk, node) {
-		struct inet_sock *inet = inet_sk(sk);
-
-		if (inet->num == num 					&&
-		    !(inet->daddr && inet->daddr != raddr) 		&&
-		    !(inet->rcv_saddr && inet->rcv_saddr != laddr)	&&
-		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
-			goto found; /* gotcha */
-	}
-	sk = NULL;
-found:
-	return sk;
+	return mdt_lookup_raw(num, raddr, laddr, dif);
 }
 
 /*
@@ -152,18 +120,11 @@ static __inline__ int icmp_filter(struct sock *sk, struct sk_buff *skb)
 int raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash)
 {
 	struct sock *sk;
-	struct hlist_head *head;
 	int delivered = 0;
-
-	read_lock(&raw_v4_lock);
-	head = &raw_v4_htable[hash];
-	if (hlist_empty(head))
-		goto out;
-	sk = __raw_v4_lookup(__sk_head(head), iph->protocol,
+	sk = __raw_v4_lookup(NULL, iph->protocol,
 			     iph->saddr, iph->daddr,
 			     skb->dev->ifindex);
-
-	while (sk) {
+	if (sk) {
 		delivered = 1;
 		if (iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) {
 			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
@@ -172,16 +133,12 @@ int raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash)
 			if (clone)
 				raw_rcv(sk, clone);
 		}
-		sk = __raw_v4_lookup(sk_next(sk), iph->protocol,
-				     iph->saddr, iph->daddr,
-				     skb->dev->ifindex);
+		sock_put(sk);
 	}
-out:
-	read_unlock(&raw_v4_lock);
 	return delivered;
 }
 
-void raw_err (struct sock *sk, struct sk_buff *skb, u32 info)
+void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	int type = skb->h.icmph->type;
@@ -544,6 +501,8 @@ static void raw_close(struct sock *sk, long timeout)
 	ip_ra_control(sk, 0, NULL);
 
 	sk_common_release(sk);
+
+	raw_in_use--;
 }
 
 /* This gets rid of all the nasties in af_inet. -DaveM */
@@ -633,6 +592,8 @@ static int raw_init(struct sock *sk)
 {
 	struct raw_sock *rp = raw_sk(sk);
 
+	raw_in_use++;
+
 	if (inet_sk(sk)->num == IPPROTO_ICMP)
 		memset(&rp->filter, 0, sizeof(rp->filter));
 	return 0;
@@ -768,8 +729,8 @@ struct proto raw_prot = {
 	.recvmsg	   = raw_recvmsg,
 	.bind		   = raw_bind,
 	.backlog_rcv	   = raw_rcv_skb,
-	.hash		   = raw_v4_hash,
-	.unhash		   = raw_v4_unhash,
+	.hash		   = mdt_insert_sock,
+	.unhash		   = mdt_remove_sock,
 	.obj_size	   = sizeof(struct raw_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_raw_setsockopt,
@@ -777,6 +738,7 @@ struct proto raw_prot = {
 #endif
 };
 
+#if 0
 #ifdef CONFIG_PROC_FS
 struct raw_iter_state {
 	int bucket;
@@ -936,3 +898,4 @@ void __init raw_proc_exit(void)
 	proc_net_remove("raw");
 }
 #endif /* CONFIG_PROC_FS */
+#endif
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 74c4d10..02ff35f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2389,62 +2389,14 @@ void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
 	unsigned long limit;
-	int order, i, max_share;
+	int order, max_share;
 
 	if (sizeof(struct tcp_skb_cb) > sizeof(skb->cb))
 		__skb_cb_too_small_for_tcp(sizeof(struct tcp_skb_cb),
 					   sizeof(skb->cb));
 
-	tcp_hashinfo.bind_bucket_cachep =
-		kmem_cache_create("tcp_bind_bucket",
-				  sizeof(struct inet_bind_bucket), 0,
-				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+	for (order = 0; ((1 << order) << PAGE_SHIFT) < (8*(1<<20)); order++);
 
-	/* Size and allocate the main established and bind bucket
-	 * hash tables.
-	 *
-	 * The methodology is similar to that of the buffer cache.
-	 */
-	tcp_hashinfo.ehash =
-		alloc_large_system_hash("TCP established",
-					sizeof(struct inet_ehash_bucket),
-					thash_entries,
-					(num_physpages >= 128 * 1024) ?
-					13 : 15,
-					0,
-					&tcp_hashinfo.ehash_size,
-					NULL,
-					0);
-	tcp_hashinfo.ehash_size = 1 << tcp_hashinfo.ehash_size;
-	for (i = 0; i < tcp_hashinfo.ehash_size; i++) {
-		rwlock_init(&tcp_hashinfo.ehash[i].lock);
-		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].chain);
-		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].twchain);
-	}
-
-	tcp_hashinfo.bhash =
-		alloc_large_system_hash("TCP bind",
-					sizeof(struct inet_bind_hashbucket),
-					tcp_hashinfo.ehash_size,
-					(num_physpages >= 128 * 1024) ?
-					13 : 15,
-					0,
-					&tcp_hashinfo.bhash_size,
-					NULL,
-					64 * 1024);
-	tcp_hashinfo.bhash_size = 1 << tcp_hashinfo.bhash_size;
-	for (i = 0; i < tcp_hashinfo.bhash_size; i++) {
-		spin_lock_init(&tcp_hashinfo.bhash[i].lock);
-		INIT_HLIST_HEAD(&tcp_hashinfo.bhash[i].chain);
-	}
-
-	/* Try to be a bit smarter and adjust defaults depending
-	 * on available memory.
-	 */
-	for (order = 0; ((1 << order) << PAGE_SHIFT) <
-			(tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket));
-			order++)
-		;
 	if (order >= 4) {
 		sysctl_local_port_range[0] = 32768;
 		sysctl_local_port_range[1] = 61000;
@@ -2457,9 +2409,8 @@ void __init tcp_init(void)
 		sysctl_tcp_max_orphans >>= (3 - order);
 		sysctl_max_syn_backlog = 128;
 	}
-
 	/* Allow no more than 3/4 kernel memory (usually less) allocated to TCP */
-	sysctl_tcp_mem[0] = (1536 / sizeof (struct inet_bind_hashbucket)) << order;
+	sysctl_tcp_mem[0] = (1536 / 8) << order;
 	sysctl_tcp_mem[1] = sysctl_tcp_mem[0] * 4 / 3;
 	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
 
@@ -2473,11 +2424,6 @@ void __init tcp_init(void)
 	sysctl_tcp_rmem[0] = SK_STREAM_MEM_QUANTUM;
 	sysctl_tcp_rmem[1] = 87380;
 	sysctl_tcp_rmem[2] = max(87380, max_share);
-
-	printk(KERN_INFO "TCP: Hash tables configured "
-	       "(established %d bind %d)\n",
-	       tcp_hashinfo.ehash_size, tcp_hashinfo.bhash_size);
-
 	tcp_register_congestion_control(&tcp_reno);
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ba74bb..87a6fac 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -63,7 +63,7 @@
 #include <linux/times.h>
 
 #include <net/icmp.h>
-#include <net/inet_hashtables.h>
+#include <net/lookup.h>
 #include <net/tcp.h>
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
@@ -71,6 +71,7 @@
 #include <net/timewait_sock.h>
 #include <net/xfrm.h>
 #include <net/netdma.h>
+#include <net/lookup.h>
 
 #include <linux/inet.h>
 #include <linux/ipv6.h>
@@ -101,26 +102,9 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   int tcplen);
 #endif
 
-struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
-	.lhash_lock  = __RW_LOCK_UNLOCKED(tcp_hashinfo.lhash_lock),
-	.lhash_users = ATOMIC_INIT(0),
-	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
-};
-
 static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return inet_csk_get_port(&tcp_hashinfo, sk, snum,
-				 inet_csk_bind_conflict);
-}
-
-static void tcp_v4_hash(struct sock *sk)
-{
-	inet_hash(&tcp_hashinfo, sk);
-}
-
-void tcp_unhash(struct sock *sk)
-{
-	inet_unhash(&tcp_hashinfo, sk);
+	return mdt_insert_sock_port(sk, snum);
 }
 
 static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
@@ -245,7 +229,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	 * complete initialization after this.
 	 */
 	tcp_set_state(sk, TCP_SYN_SENT);
-	err = inet_hash_connect(&tcp_death_row, sk);
+	err = mdt_insert_sock_port(sk, 0);
 	if (err)
 		goto failure;
 
@@ -365,8 +349,8 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 		return;
 	}
 
-	sk = inet_lookup(&tcp_hashinfo, iph->daddr, th->dest, iph->saddr,
-			 th->source, inet_iif(skb));
+	sk = sock_lookup(iph->daddr, th->dest, iph->saddr,
+			 th->source, inet_iif(skb), IPPROTO_TCP, 0);
 	if (!sk) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;
@@ -1465,9 +1449,10 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 					  newkey, key->keylen);
 	}
 #endif
-
-	__inet_hash(&tcp_hashinfo, newsk, 0);
-	__inet_inherit_port(&tcp_hashinfo, sk, newsk);
+	if (mdt_insert_sock(newsk)) {
+		inet_csk_destroy_sock(newsk);
+		goto exit_overflow;
+	}
 
 	return newsk;
 
@@ -1490,11 +1475,9 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 						       iph->saddr, iph->daddr);
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
-
-	nsk = inet_lookup_established(&tcp_hashinfo, skb->nh.iph->saddr,
-				      th->source, skb->nh.iph->daddr,
-				      th->dest, inet_iif(skb));
-
+	nsk = __sock_lookup(skb->nh.iph->saddr, th->source, 
+			    skb->nh.iph->daddr, th->dest, 
+			    inet_iif(skb), IPPROTO_TCP, 0);
 	if (nsk) {
 		if (nsk->sk_state != TCP_TIME_WAIT) {
 			bh_lock_sock(nsk);
@@ -1647,9 +1630,9 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = skb->nh.iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(&tcp_hashinfo, skb->nh.iph->saddr, th->source,
+	sk = __sock_lookup(skb->nh.iph->saddr, th->source,
 			   skb->nh.iph->daddr, th->dest,
-			   inet_iif(skb));
+			   inet_iif(skb), IPPROTO_TCP, 1);
 
 	if (!sk)
 		goto no_tcp_socket;
@@ -1723,10 +1706,8 @@ do_time_wait:
 	}
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
-		struct sock *sk2 = inet_lookup_listener(&tcp_hashinfo,
-							skb->nh.iph->daddr,
-							th->dest,
-							inet_iif(skb));
+		struct sock *sk2 = sock_lookup(0, 0, skb->nh.iph->daddr,
+				th->dest, inet_iif(skb), IPPROTO_TCP, 1);
 		if (sk2) {
 			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
 			inet_twsk_put(inet_twsk(sk));
@@ -1914,7 +1895,7 @@ int tcp_v4_destroy_sock(struct sock *sk)
 
 	/* Clean up a referenced TCP bind bucket. */
 	if (inet_csk(sk)->icsk_bind_hash)
-		inet_put_port(&tcp_hashinfo, sk);
+		proto_put_port(sk);
 
 	/*
 	 * If sendmsg cached page exists, toss it.
@@ -1934,6 +1915,7 @@ EXPORT_SYMBOL(tcp_v4_destroy_sock);
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCP sock list dumping. */
 
+#if 0
 static inline struct inet_timewait_sock *tw_head(struct hlist_head *head)
 {
 	return hlist_empty(head) ? NULL :
@@ -2267,6 +2249,15 @@ void tcp_proc_unregister(struct tcp_seq_afinfo *afinfo)
 	proc_net_remove(afinfo->name);
 	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
+#else
+int tcp_proc_register(struct tcp_seq_afinfo *afinfo)
+{
+	return 0;
+}
+void tcp_proc_unregister(struct tcp_seq_afinfo *afinfo)
+{
+}
+#endif
 
 static void get_openreq4(struct sock *sk, struct request_sock *req,
 			 char *tmpbuf, int i, int uid)
@@ -2430,8 +2421,8 @@ struct proto tcp_prot = {
 	.sendmsg		= tcp_sendmsg,
 	.recvmsg		= tcp_recvmsg,
 	.backlog_rcv		= tcp_v4_do_rcv,
-	.hash			= tcp_v4_hash,
-	.unhash			= tcp_unhash,
+	.hash			= mdt_insert_sock,
+	.unhash			= mdt_remove_sock,
 	.get_port		= tcp_v4_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
 	.sockets_allocated	= &tcp_sockets_allocated,
@@ -2459,9 +2450,7 @@ void __init tcp_v4_init(struct net_proto_family *ops)
 }
 
 EXPORT_SYMBOL(ipv4_specific);
-EXPORT_SYMBOL(tcp_hashinfo);
 EXPORT_SYMBOL(tcp_prot);
-EXPORT_SYMBOL(tcp_unhash);
 EXPORT_SYMBOL(tcp_v4_conn_request);
 EXPORT_SYMBOL(tcp_v4_connect);
 EXPORT_SYMBOL(tcp_v4_do_rcv);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6b5c64f..96b72f1 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -41,7 +41,6 @@ struct inet_timewait_death_row tcp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
 	.period		= TCP_TIMEWAIT_LEN / INET_TWDR_TWKILL_SLOTS,
 	.death_lock	= __SPIN_LOCK_UNLOCKED(tcp_death_row.death_lock),
-	.hashinfo	= &tcp_hashinfo,
 	.tw_timer	= TIMER_INITIALIZER(inet_twdr_hangman, 0,
 					    (unsigned long)&tcp_death_row),
 	.twkill_work	= __WORK_INITIALIZER(tcp_death_row.twkill_work,
@@ -328,7 +327,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 #endif
 
 		/* Linkage updates. */
-		__inet_twsk_hashdance(tw, sk, &tcp_hashinfo);
+		__inet_twsk_hashdance(tw, sk);
 
 		/* Get the TIME_WAIT timeout firing. */
 		if (timeo < rto)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fc620a7..5d2313d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -101,6 +101,7 @@
 #include <net/route.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <net/lookup.h>
 #include "udp_impl.h"
 
 /*
@@ -112,205 +113,16 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_statistics) __read_mostly;
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
 
-static int udp_port_rover;
-
-static inline int __udp_lib_lport_inuse(__u16 num, struct hlist_head udptable[])
-{
-	struct sock *sk;
-	struct hlist_node *node;
-
-	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
-		if (sk->sk_hash == num)
-			return 1;
-	return 0;
-}
-
-/**
- *  __udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
- *
- *  @sk:          socket struct in question
- *  @snum:        port number to look up
- *  @udptable:    hash list table, must be of UDP_HTABLE_SIZE
- *  @port_rover:  pointer to record of last unallocated port
- *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
- */
-int __udp_lib_get_port(struct sock *sk, unsigned short snum,
-		       struct hlist_head udptable[], int *port_rover,
-		       int (*saddr_comp)(const struct sock *sk1,
-					 const struct sock *sk2 )    )
-{
-	struct hlist_node *node;
-	struct hlist_head *head;
-	struct sock *sk2;
-	int    error = 1;
-
-	write_lock_bh(&udp_hash_lock);
-	if (snum == 0) {
-		int best_size_so_far, best, result, i;
-
-		if (*port_rover > sysctl_local_port_range[1] ||
-		    *port_rover < sysctl_local_port_range[0])
-			*port_rover = sysctl_local_port_range[0];
-		best_size_so_far = 32767;
-		best = result = *port_rover;
-		for (i = 0; i < UDP_HTABLE_SIZE; i++, result++) {
-			int size;
-
-			head = &udptable[result & (UDP_HTABLE_SIZE - 1)];
-			if (hlist_empty(head)) {
-				if (result > sysctl_local_port_range[1])
-					result = sysctl_local_port_range[0] +
-						((result - sysctl_local_port_range[0]) &
-						 (UDP_HTABLE_SIZE - 1));
-				goto gotit;
-			}
-			size = 0;
-			sk_for_each(sk2, node, head) {
-				if (++size >= best_size_so_far)
-					goto next;
-			}
-			best_size_so_far = size;
-			best = result;
-		next:
-			;
-		}
-		result = best;
-		for(i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++, result += UDP_HTABLE_SIZE) {
-			if (result > sysctl_local_port_range[1])
-				result = sysctl_local_port_range[0]
-					+ ((result - sysctl_local_port_range[0]) &
-					   (UDP_HTABLE_SIZE - 1));
-			if (! __udp_lib_lport_inuse(result, udptable))
-				break;
-		}
-		if (i >= (1 << 16) / UDP_HTABLE_SIZE)
-			goto fail;
-gotit:
-		*port_rover = snum = result;
-	} else {
-		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
-
-		sk_for_each(sk2, node, head)
-			if (sk2->sk_hash == snum                             &&
-			    sk2 != sk                                        &&
-			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
-			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
-			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
-			    (*saddr_comp)(sk, sk2)                             )
-				goto fail;
-	}
-	inet_sk(sk)->num = snum;
-	sk->sk_hash = snum;
-	if (sk_unhashed(sk)) {
-		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
-		sk_add_node(sk, head);
-		sock_prot_inc_use(sk->sk_prot);
-	}
-	error = 0;
-fail:
-	write_unlock_bh(&udp_hash_lock);
-	return error;
-}
-
-__inline__ int udp_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *))
-{
-	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
-}
-
-inline int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
-{
-	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
-
-	return 	( !ipv6_only_sock(sk2)  &&
-		  (!inet1->rcv_saddr || !inet2->rcv_saddr ||
-		   inet1->rcv_saddr == inet2->rcv_saddr      ));
-}
-
 static inline int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal);
+	return  mdt_insert_sock_port(sk, snum);
 }
 
-/* UDP is nearly always wildcards out the wazoo, it makes no sense to try
- * harder than this. -DaveM
- */
 static struct sock *__udp4_lib_lookup(__be32 saddr, __be16 sport,
 				      __be32 daddr, __be16 dport,
-				      int dif, struct hlist_head udptable[])
+				      int dif)
 {
-	struct sock *sk, *result = NULL;
-	struct hlist_node *node;
-	unsigned short hnum = ntohs(dport);
-	int badness = -1;
-
-	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
-		struct inet_sock *inet = inet_sk(sk);
-
-		if (sk->sk_hash == hnum && !ipv6_only_sock(sk)) {
-			int score = (sk->sk_family == PF_INET ? 1 : 0);
-			if (inet->rcv_saddr) {
-				if (inet->rcv_saddr != daddr)
-					continue;
-				score+=2;
-			}
-			if (inet->daddr) {
-				if (inet->daddr != saddr)
-					continue;
-				score+=2;
-			}
-			if (inet->dport) {
-				if (inet->dport != sport)
-					continue;
-				score+=2;
-			}
-			if (sk->sk_bound_dev_if) {
-				if (sk->sk_bound_dev_if != dif)
-					continue;
-				score+=2;
-			}
-			if(score == 9) {
-				result = sk;
-				break;
-			} else if(score > badness) {
-				result = sk;
-				badness = score;
-			}
-		}
-	}
-	if (result)
-		sock_hold(result);
-	read_unlock(&udp_hash_lock);
-	return result;
-}
-
-static inline struct sock *udp_v4_mcast_next(struct sock *sk,
-					     __be16 loc_port, __be32 loc_addr,
-					     __be16 rmt_port, __be32 rmt_addr,
-					     int dif)
-{
-	struct hlist_node *node;
-	struct sock *s = sk;
-	unsigned short hnum = ntohs(loc_port);
-
-	sk_for_each_from(s, node) {
-		struct inet_sock *inet = inet_sk(s);
-
-		if (s->sk_hash != hnum					||
-		    (inet->daddr && inet->daddr != rmt_addr)		||
-		    (inet->dport != rmt_port && inet->dport)		||
-		    (inet->rcv_saddr && inet->rcv_saddr != loc_addr)	||
-		    ipv6_only_sock(s)					||
-		    (s->sk_bound_dev_if && s->sk_bound_dev_if != dif))
-			continue;
-		if (!ip_mc_sf_allow(s, loc_addr, rmt_addr, dif))
-			continue;
-		goto found;
-	}
-	s = NULL;
-found:
-	return s;
+	return __sock_lookup(saddr, sport, daddr, dport, dif, IPPROTO_UDP, 1);
 }
 
 /*
@@ -336,7 +148,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 	int err;
 
 	sk = __udp4_lib_lookup(iph->daddr, uh->dest, iph->saddr, uh->source,
-			       skb->dev->ifindex, udptable		    );
+			       skb->dev->ifindex);
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
@@ -1117,50 +929,6 @@ drop:
 	return -1;
 }
 
-/*
- *	Multicasts and broadcasts go to each listener.
- *
- *	Note: called only from the BH handler context,
- *	so we don't need to lock the hashes.
- */
-static int __udp4_lib_mcast_deliver(struct sk_buff *skb,
-				    struct udphdr  *uh,
-				    __be32 saddr, __be32 daddr,
-				    struct hlist_head udptable[])
-{
-	struct sock *sk;
-	int dif;
-
-	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
-	dif = skb->dev->ifindex;
-	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
-	if (sk) {
-		struct sock *sknext = NULL;
-
-		do {
-			struct sk_buff *skb1 = skb;
-
-			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
-						   uh->source, saddr, dif);
-			if(sknext)
-				skb1 = skb_clone(skb, GFP_ATOMIC);
-
-			if(skb1) {
-				int ret = udp_queue_rcv_skb(sk, skb1);
-				if (ret > 0)
-					/* we should probably re-process instead
-					 * of dropping packets here. */
-					kfree_skb(skb1);
-			}
-			sk = sknext;
-		} while(sknext);
-	} else
-		kfree_skb(skb);
-	read_unlock(&udp_hash_lock);
-	return 0;
-}
-
 /* Initialize UDP checksum. If exited with zero value (success),
  * CHECKSUM_UNNECESSARY means, that no more checks are required.
  * Otherwise, csum completion requires chacksumming packet body,
@@ -1197,7 +965,6 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct sock *sk;
 	struct udphdr *uh = skb->h.uh;
 	unsigned short ulen;
-	struct rtable *rt = (struct rtable*)skb->dst;
 	__be32 saddr = skb->nh.iph->saddr;
 	__be32 daddr = skb->nh.iph->daddr;
 
@@ -1224,12 +991,8 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 			goto csum_error;
 	}
 
-	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
-
 	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
-			       skb->dev->ifindex, udptable        );
-
+			       skb->dev->ifindex);
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
@@ -1531,6 +1294,7 @@ struct proto udp_prot = {
 #endif
 };
 
+#if 0
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
 
@@ -1716,20 +1480,16 @@ void udp4_proc_exit(void)
 {
 	udp_proc_unregister(&udp4_seq_afinfo);
 }
+
+EXPORT_SYMBOL(udp_proc_register);
+EXPORT_SYMBOL(udp_proc_unregister);
 #endif /* CONFIG_PROC_FS */
+#endif
 
 EXPORT_SYMBOL(udp_disconnect);
-EXPORT_SYMBOL(udp_hash);
-EXPORT_SYMBOL(udp_hash_lock);
 EXPORT_SYMBOL(udp_ioctl);
-EXPORT_SYMBOL(udp_get_port);
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
 EXPORT_SYMBOL(udp_lib_getsockopt);
 EXPORT_SYMBOL(udp_lib_setsockopt);
 EXPORT_SYMBOL(udp_poll);
-
-#ifdef CONFIG_PROC_FS
-EXPORT_SYMBOL(udp_proc_register);
-EXPORT_SYMBOL(udp_proc_unregister);
-#endif
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index b28fe1e..e839061 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -16,6 +16,7 @@
 DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics)	__read_mostly;
 
 struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
+#ifdef CONFIG_MDT_LOOKUP
 static int		udplite_port_rover;
 
 int udplite_get_port(struct sock *sk, unsigned short p,
@@ -28,7 +29,12 @@ static int udplite_v4_get_port(struct sock *sk, unsigned short snum)
 {
 	return udplite_get_port(sk, snum, ipv4_rcv_saddr_equal);
 }
-
+#else
+static int udplite_v4_get_port(struct sock *sk, unsigned short snum)
+{
+	return  mdt_insert_sock_port(sk, snum);
+}
+#endif
 static int udplite_rcv(struct sk_buff *skb)
 {
 	return __udp4_lib_rcv(skb, udplite_hash, 1);
@@ -80,6 +86,7 @@ static struct inet_protosw udplite4_protosw = {
 	.flags		=  INET_PROTOSW_PERMANENT,
 };
 
+#ifdef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 static struct file_operations udplite4_seq_fops;
 static struct udp_seq_afinfo udplite4_seq_afinfo = {
@@ -91,6 +98,7 @@ static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	.seq_fops	= &udplite4_seq_fops,
 };
 #endif
+#endif
 
 void __init udplite4_register(void)
 {
@@ -102,10 +110,12 @@ void __init udplite4_register(void)
 
 	inet_register_protosw(&udplite4_protosw);
 
+#ifdef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 	if (udp_proc_register(&udplite4_seq_afinfo)) /* udplite4_proc_init() */
 		printk(KERN_ERR "%s: Cannot register /proc!\n", __FUNCTION__);
 #endif
+#endif
 	return;
 
 out_unregister_proto:
@@ -116,4 +126,6 @@ out_register_err:
 
 EXPORT_SYMBOL(udplite_hash);
 EXPORT_SYMBOL(udplite_prot);
+#ifdef CONFIG_MDT_LOOKUP
 EXPORT_SYMBOL(udplite_get_port);
+#endif
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e73d8f5..c4ac8b9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -60,50 +60,14 @@
 #include <net/sock.h>
 #include <net/scm.h>
 #include <net/netlink.h>
+#include <net/lookup.h>
 
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 
-struct netlink_sock {
-	/* struct sock has to be the first member of netlink_sock */
-	struct sock		sk;
-	u32			pid;
-	u32			dst_pid;
-	u32			dst_group;
-	u32			flags;
-	u32			subscriptions;
-	u32			ngroups;
-	unsigned long		*groups;
-	unsigned long		state;
-	wait_queue_head_t	wait;
-	struct netlink_callback	*cb;
-	spinlock_t		cb_lock;
-	void			(*data_ready)(struct sock *sk, int bytes);
-	struct module		*module;
-};
-
 #define NETLINK_KERNEL_SOCKET	0x1
 #define NETLINK_RECV_PKTINFO	0x2
 
-static inline struct netlink_sock *nlk_sk(struct sock *sk)
-{
-	return (struct netlink_sock *)sk;
-}
-
-struct nl_pid_hash {
-	struct hlist_head *table;
-	unsigned long rehash_time;
-
-	unsigned int mask;
-	unsigned int shift;
-
-	unsigned int entries;
-	unsigned int max_shift;
-
-	u32 rnd;
-};
-
 struct netlink_table {
-	struct nl_pid_hash hash;
 	struct hlist_head mc_list;
 	unsigned long *listeners;
 	unsigned int nl_nonroot;
@@ -114,11 +78,10 @@ struct netlink_table {
 
 static struct netlink_table *nl_table;
 
-static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
-
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
 
+static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 static DEFINE_RWLOCK(nl_table_lock);
 static atomic_t nl_table_users = ATOMIC_INIT(0);
 
@@ -129,11 +92,6 @@ static u32 netlink_group_mask(u32 group)
 	return group ? 1 << (group - 1) : 0;
 }
 
-static struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
-{
-	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
-}
-
 static void netlink_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_receive_queue);
@@ -199,171 +157,89 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
-static __inline__ struct sock *netlink_lookup(int protocol, u32 pid)
-{
-	struct nl_pid_hash *hash = &nl_table[protocol].hash;
-	struct hlist_head *head;
-	struct sock *sk;
-	struct hlist_node *node;
-
-	read_lock(&nl_table_lock);
-	head = nl_pid_hashfn(hash, pid);
-	sk_for_each(sk, node, head) {
-		if (nlk_sk(sk)->pid == pid) {
-			sock_hold(sk);
-			goto found;
-		}
-	}
-	sk = NULL;
-found:
-	read_unlock(&nl_table_lock);
-	return sk;
-}
-
-static inline struct hlist_head *nl_pid_hash_alloc(size_t size)
-{
-	if (size <= PAGE_SIZE)
-		return kmalloc(size, GFP_ATOMIC);
-	else
-		return (struct hlist_head *)
-			__get_free_pages(GFP_ATOMIC, get_order(size));
-}
-
-static inline void nl_pid_hash_free(struct hlist_head *table, size_t size)
-{
-	if (size <= PAGE_SIZE)
-		kfree(table);
-	else
-		free_pages((unsigned long)table, get_order(size));
-}
-
-static int nl_pid_hash_rehash(struct nl_pid_hash *hash, int grow)
-{
-	unsigned int omask, mask, shift;
-	size_t osize, size;
-	struct hlist_head *otable, *table;
-	int i;
-
-	omask = mask = hash->mask;
-	osize = size = (mask + 1) * sizeof(*table);
-	shift = hash->shift;
-
-	if (grow) {
-		if (++shift > hash->max_shift)
-			return 0;
-		mask = mask * 2 + 1;
-		size *= 2;
-	}
-
-	table = nl_pid_hash_alloc(size);
-	if (!table)
-		return 0;
-
-	memset(table, 0, size);
-	otable = hash->table;
-	hash->table = table;
-	hash->mask = mask;
-	hash->shift = shift;
-	get_random_bytes(&hash->rnd, sizeof(hash->rnd));
-
-	for (i = 0; i <= omask; i++) {
-		struct sock *sk;
-		struct hlist_node *node, *tmp;
-
-		sk_for_each_safe(sk, node, tmp, &otable[i])
-			__sk_add_node(sk, nl_pid_hashfn(hash, nlk_sk(sk)->pid));
-	}
-
-	nl_pid_hash_free(otable, osize);
-	hash->rehash_time = jiffies + 10 * 60 * HZ;
-	return 1;
-}
-
-static inline int nl_pid_hash_dilute(struct nl_pid_hash *hash, int len)
-{
-	int avg = hash->entries >> hash->shift;
-
-	if (unlikely(avg > 1) && nl_pid_hash_rehash(hash, 1))
-		return 1;
-
-	if (unlikely(len > avg) && time_after(jiffies, hash->rehash_time)) {
-		nl_pid_hash_rehash(hash, 0);
-		return 1;
-	}
-
-	return 0;
-}
-
-static const struct proto_ops netlink_ops;
+extern int mdt_insert_netlink(struct sock *sk, u32 pid);
+extern int mdt_remove_netlink(struct sock *sk);
+extern struct sock *netlink_lookup(int protocol, u32 pid);
 
 static void
 netlink_update_listeners(struct sock *sk)
 {
 	struct netlink_table *tbl = &nl_table[sk->sk_protocol];
+	struct netlink_sock *nlk;
 	struct hlist_node *node;
 	unsigned long mask;
 	unsigned int i;
 
 	for (i = 0; i < NLGRPSZ(tbl->groups)/sizeof(unsigned long); i++) {
 		mask = 0;
-		sk_for_each_bound(sk, node, &tbl->mc_list)
-			mask |= nlk_sk(sk)->groups[i];
+		sk_for_each_bound(nlk, node, &tbl->mc_list)
+			mask |= nlk->groups[i];
 		tbl->listeners[i] = mask;
 	}
 	/* this function is only called with the netlink table "grabbed", which
 	 * makes sure updates are visible before bind or setsockopt return. */
 }
 
-static int netlink_insert(struct sock *sk, u32 pid)
+static inline void __sk_del_bind_node(struct sock *sk)
 {
-	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
-	struct hlist_head *head;
-	int err = -EADDRINUSE;
-	struct sock *osk;
-	struct hlist_node *node;
-	int len;
-
-	netlink_table_grab();
-	head = nl_pid_hashfn(hash, pid);
-	len = 0;
-	sk_for_each(osk, node, head) {
-		if (nlk_sk(osk)->pid == pid)
-			break;
-		len++;
-	}
-	if (node)
-		goto err;
+	struct netlink_sock *nlk = nlk_sk(sk);
+	hlist_del(&nlk->nlk_node);
+}
 
-	err = -EBUSY;
-	if (nlk_sk(sk)->pid)
-		goto err;
+static inline void sk_add_bind_node(struct sock *sk, struct hlist_head *head)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+	hlist_add_head(&nlk->nlk_node, head);
+}
 
-	err = -ENOMEM;
-	if (BITS_PER_LONG > 32 && unlikely(hash->entries >= UINT_MAX))
-		goto err;
+static void
+netlink_update_subscriptions(struct sock *sk, unsigned int subscriptions)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
 
-	if (len && nl_pid_hash_dilute(hash, len))
-		head = nl_pid_hashfn(hash, pid);
-	hash->entries++;
-	nlk_sk(sk)->pid = pid;
-	sk_add_node(sk, head);
-	err = 0;
+	if (nlk->subscriptions && !subscriptions)
+		__sk_del_bind_node(sk);
+	else if (!nlk->subscriptions && subscriptions)
+		sk_add_bind_node(sk, &nl_table[sk->sk_protocol].mc_list);
+	nlk->subscriptions = subscriptions;
+}
 
-err:
-	netlink_table_ungrab();
+static int netlink_insert(struct sock *sk, u32 pid)
+{
+	int err;
+	netlink_lock_table();
+	err = mdt_insert_netlink(sk, pid);
+	netlink_unlock_table();
 	return err;
 }
 
 static void netlink_remove(struct sock *sk)
 {
-	netlink_table_grab();
-	if (sk_del_node_init(sk))
-		nl_table[sk->sk_protocol].hash.entries--;
+	netlink_lock_table();
+	mdt_remove_netlink(sk);
 	if (nlk_sk(sk)->subscriptions)
 		__sk_del_bind_node(sk);
-	netlink_table_ungrab();
+	netlink_unlock_table();
 }
 
+static int netlink_autobind(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	s32 pid = current->tgid;
+	static s32 rover = -4097;
+
+	while (netlink_insert(sk, pid)) {
+		/* Bind collision, search negative pid values. */
+		pid = rover--;
+		if (rover > -4097)
+			rover = -4097;
+	}
+
+	return 0;
+}
+
+static const struct proto_ops netlink_ops;
+
 static struct proto netlink_proto = {
 	.name	  = "NETLINK",
 	.owner	  = THIS_MODULE,
@@ -490,62 +366,12 @@ static int netlink_release(struct socket *sock)
 	return 0;
 }
 
-static int netlink_autobind(struct socket *sock)
-{
-	struct sock *sk = sock->sk;
-	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
-	struct hlist_head *head;
-	struct sock *osk;
-	struct hlist_node *node;
-	s32 pid = current->tgid;
-	int err;
-	static s32 rover = -4097;
-
-retry:
-	cond_resched();
-	netlink_table_grab();
-	head = nl_pid_hashfn(hash, pid);
-	sk_for_each(osk, node, head) {
-		if (nlk_sk(osk)->pid == pid) {
-			/* Bind collision, search negative pid values. */
-			pid = rover--;
-			if (rover > -4097)
-				rover = -4097;
-			netlink_table_ungrab();
-			goto retry;
-		}
-	}
-	netlink_table_ungrab();
-
-	err = netlink_insert(sk, pid);
-	if (err == -EADDRINUSE)
-		goto retry;
-
-	/* If 2 threads race to autobind, that is fine.  */
-	if (err == -EBUSY)
-		err = 0;
-
-	return err;
-}
-
 static inline int netlink_capable(struct socket *sock, unsigned int flag)
 {
 	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
 	       capable(CAP_NET_ADMIN);
 }
 
-static void
-netlink_update_subscriptions(struct sock *sk, unsigned int subscriptions)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-
-	if (nlk->subscriptions && !subscriptions)
-		__sk_del_bind_node(sk);
-	else if (!nlk->subscriptions && subscriptions)
-		sk_add_bind_node(sk, &nl_table[sk->sk_protocol].mc_list);
-	nlk->subscriptions = subscriptions;
-}
-
 static int netlink_alloc_groups(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -916,7 +742,7 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 {
 	struct netlink_broadcast_data info;
 	struct hlist_node *node;
-	struct sock *sk;
+	struct netlink_sock *nlk;
 
 	skb = netlink_trim(skb, allocation);
 
@@ -933,10 +759,8 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	/* While we sleep in clone, do not allow to change socket list */
 
 	netlink_lock_table();
-
-	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
-		do_one_broadcast(sk, &info);
-
+	sk_for_each_bound(nlk, node, &nl_table[ssk->sk_protocol].mc_list)
+		do_one_broadcast(&nlk->sk, &info);
 	kfree_skb(skb);
 
 	netlink_unlock_table();
@@ -978,12 +802,11 @@ static inline int do_one_set_err(struct sock *sk,
 out:
 	return 0;
 }
-
 void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 {
 	struct netlink_set_err_data info;
 	struct hlist_node *node;
-	struct sock *sk;
+	struct netlink_sock *nlk;
 
 	info.exclude_sk = ssk;
 	info.pid = pid;
@@ -992,8 +815,8 @@ void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 
 	read_lock(&nl_table_lock);
 
-	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
-		do_one_set_err(sk, &info);
+	sk_for_each_bound(nlk, node, &nl_table[ssk->sk_protocol].mc_list)
+		do_one_set_err(&nlk->sk, &info);
 
 	read_unlock(&nl_table_lock);
 }
@@ -1272,8 +1095,6 @@ netlink_kernel_create(int unit, unsigned int groups,
 	struct netlink_sock *nlk;
 	unsigned long *listeners = NULL;
 
-	BUG_ON(!nl_table);
-
 	if (unit<0 || unit>=MAX_LINKS)
 		return NULL;
 
@@ -1579,6 +1400,7 @@ int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 pid,
 	return err;
 }
 
+#if 0
 #ifdef CONFIG_PROC_FS
 struct nl_seq_iter {
 	int link;
@@ -1722,6 +1544,7 @@ static const struct file_operations netlink_seq_fops = {
 };
 
 #endif
+#endif
 
 int netlink_register_notifier(struct notifier_block *nb)
 {
@@ -1763,9 +1586,6 @@ static struct net_proto_family netlink_family_ops = {
 static int __init netlink_proto_init(void)
 {
 	struct sk_buff *dummy_skb;
-	int i;
-	unsigned long max;
-	unsigned int order;
 	int err = proto_register(&netlink_proto, 0);
 
 	if (err != 0)
@@ -1777,37 +1597,12 @@ static int __init netlink_proto_init(void)
 	if (!nl_table)
 		goto panic;
 
-	if (num_physpages >= (128 * 1024))
-		max = num_physpages >> (21 - PAGE_SHIFT);
-	else
-		max = num_physpages >> (23 - PAGE_SHIFT);
-
-	order = get_bitmask_order(max) - 1 + PAGE_SHIFT;
-	max = (1UL << order) / sizeof(struct hlist_head);
-	order = get_bitmask_order(max > UINT_MAX ? UINT_MAX : max) - 1;
-
-	for (i = 0; i < MAX_LINKS; i++) {
-		struct nl_pid_hash *hash = &nl_table[i].hash;
-
-		hash->table = nl_pid_hash_alloc(1 * sizeof(*hash->table));
-		if (!hash->table) {
-			while (i-- > 0)
-				nl_pid_hash_free(nl_table[i].hash.table,
-						 1 * sizeof(*hash->table));
-			kfree(nl_table);
-			goto panic;
-		}
-		memset(hash->table, 0, 1 * sizeof(*hash->table));
-		hash->max_shift = order;
-		hash->shift = 0;
-		hash->mask = 0;
-		hash->rehash_time = jiffies;
-	}
-
 	sock_register(&netlink_family_ops);
+#if 0
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("netlink", 0, &netlink_seq_fops);
 #endif
+#endif
 	/* The netlink device handler may be needed early. */
 	rtnetlink_init();
 out:
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 28d47e8..f14ea2e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1465,59 +1465,6 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	return 0;
 }
 
-
-static int packet_notifier(struct notifier_block *this, unsigned long msg, void *data)
-{
-	struct sock *sk;
-	struct hlist_node *node;
-	struct net_device *dev = data;
-
-	read_lock(&packet_sklist_lock);
-	sk_for_each(sk, node, &packet_sklist) {
-		struct packet_sock *po = pkt_sk(sk);
-
-		switch (msg) {
-		case NETDEV_UNREGISTER:
-#ifdef CONFIG_PACKET_MULTICAST
-			if (po->mclist)
-				packet_dev_mclist(dev, po->mclist, -1);
-			// fallthrough
-#endif
-		case NETDEV_DOWN:
-			if (dev->ifindex == po->ifindex) {
-				spin_lock(&po->bind_lock);
-				if (po->running) {
-					__dev_remove_pack(&po->prot_hook);
-					__sock_put(sk);
-					po->running = 0;
-					sk->sk_err = ENETDOWN;
-					if (!sock_flag(sk, SOCK_DEAD))
-						sk->sk_error_report(sk);
-				}
-				if (msg == NETDEV_UNREGISTER) {
-					po->ifindex = -1;
-					po->prot_hook.dev = NULL;
-				}
-				spin_unlock(&po->bind_lock);
-			}
-			break;
-		case NETDEV_UP:
-			spin_lock(&po->bind_lock);
-			if (dev->ifindex == po->ifindex && po->num &&
-			    !po->running) {
-				dev_add_pack(&po->prot_hook);
-				sock_hold(sk);
-				po->running = 1;
-			}
-			spin_unlock(&po->bind_lock);
-			break;
-		}
-	}
-	read_unlock(&packet_sklist_lock);
-	return NOTIFY_DONE;
-}
-
-
 static int packet_ioctl(struct socket *sock, unsigned int cmd,
 			unsigned long arg)
 {
@@ -1875,7 +1822,7 @@ static struct net_proto_family packet_family_ops = {
 	.create =	packet_create,
 	.owner	=	THIS_MODULE,
 };
-
+#if 0
 static struct notifier_block packet_netdev_notifier = {
 	.notifier_call =packet_notifier,
 };
@@ -1957,13 +1904,16 @@ static const struct file_operations packet_seq_fops = {
 };
 
 #endif
+#endif
 
 static void __exit packet_exit(void)
 {
 	proc_net_remove("packet");
+#if 0
 	unregister_netdevice_notifier(&packet_netdev_notifier);
-	sock_unregister(PF_PACKET);
 	proto_unregister(&packet_proto);
+#endif
+	sock_unregister(PF_PACKET);
 }
 
 static int __init packet_init(void)
@@ -1974,8 +1924,10 @@ static int __init packet_init(void)
 		goto out;
 
 	sock_register(&packet_family_ops);
+#if 0
 	register_netdevice_notifier(&packet_netdev_notifier);
 	proc_net_fops_create("packet", 0, &packet_seq_fops);
+#endif
 out:
 	return rc;
 }
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 6069716..13981ef 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -219,83 +219,27 @@ static int unix_mkname(struct sockaddr_un * sunaddr, int len, unsigned *hashp)
 	return len;
 }
 
-static void __unix_remove_socket(struct sock *sk)
-{
-	sk_del_node_init(sk);
-}
-
-static void __unix_insert_socket(struct hlist_head *list, struct sock *sk)
-{
-	BUG_TRAP(sk_unhashed(sk));
-	sk_add_node(sk, list);
-}
+extern void __unix_remove_socket(struct sock *sk);
+extern void __unix_insert_socket(struct hlist_head *list, struct sock *sk);
 
 static inline void unix_remove_socket(struct sock *sk)
 {
-	spin_lock(&unix_table_lock);
 	__unix_remove_socket(sk);
-	spin_unlock(&unix_table_lock);
 }
 
 static inline void unix_insert_socket(struct hlist_head *list, struct sock *sk)
 {
-	spin_lock(&unix_table_lock);
 	__unix_insert_socket(list, sk);
-	spin_unlock(&unix_table_lock);
 }
 
-static struct sock *__unix_find_socket_byname(struct sockaddr_un *sunname,
-					      int len, int type, unsigned hash)
-{
-	struct sock *s;
-	struct hlist_node *node;
-
-	sk_for_each(s, node, &unix_socket_table[hash ^ type]) {
-		struct unix_sock *u = unix_sk(s);
-
-		if (u->addr->len == len &&
-		    !memcmp(u->addr->name, sunname, len))
-			goto found;
-	}
-	s = NULL;
-found:
-	return s;
-}
+extern struct sock *__unix_find_socket_byname(struct sockaddr_un *sunname,
+					      int len, int type, unsigned hash);
 
 static inline struct sock *unix_find_socket_byname(struct sockaddr_un *sunname,
 						   int len, int type,
 						   unsigned hash)
 {
-	struct sock *s;
-
-	spin_lock(&unix_table_lock);
-	s = __unix_find_socket_byname(sunname, len, type, hash);
-	if (s)
-		sock_hold(s);
-	spin_unlock(&unix_table_lock);
-	return s;
-}
-
-static struct sock *unix_find_socket_byinode(struct inode *i)
-{
-	struct sock *s;
-	struct hlist_node *node;
-
-	spin_lock(&unix_table_lock);
-	sk_for_each(s, node,
-		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
-		struct dentry *dentry = unix_sk(s)->dentry;
-
-		if(dentry && dentry->d_inode == i)
-		{
-			sock_hold(s);
-			goto found;
-		}
-	}
-	s = NULL;
-found:
-	spin_unlock(&unix_table_lock);
-	return s;
+	return __unix_find_socket_byname(sunname, len, type, hash);
 }
 
 static inline int unix_writable(struct sock *sk)
@@ -342,7 +286,6 @@ static void unix_sock_destructor(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
-	BUG_TRAP(sk_unhashed(sk));
 	BUG_TRAP(!sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		printk("Attempt to release alive unix socket: %p\n", sk);
@@ -696,55 +639,21 @@ static struct sock *unix_find_other(struct sockaddr_un *sunname, int len,
 				    int type, unsigned hash, int *error)
 {
 	struct sock *u;
-	struct nameidata nd;
-	int err = 0;
-
-	if (sunname->sun_path[0]) {
-		err = path_lookup(sunname->sun_path, LOOKUP_FOLLOW, &nd);
-		if (err)
-			goto fail;
-		err = vfs_permission(&nd, MAY_WRITE);
-		if (err)
-			goto put_fail;
-
-		err = -ECONNREFUSED;
-		if (!S_ISSOCK(nd.dentry->d_inode->i_mode))
-			goto put_fail;
-		u=unix_find_socket_byinode(nd.dentry->d_inode);
-		if (!u)
-			goto put_fail;
+	struct dentry *dentry;
 
-		if (u->sk_type == type)
-			touch_atime(nd.mnt, nd.dentry);
+	u=unix_find_socket_byname(sunname, len, type, hash);
+	if (!u) {
+		*error = -ECONNREFUSED;
+		return NULL;
+	}
 
-		path_release(&nd);
+	dentry = unix_sk(u)->dentry;
+	if (dentry)
+		touch_atime(unix_sk(u)->mnt, dentry);
 
-		err=-EPROTOTYPE;
-		if (u->sk_type != type) {
-			sock_put(u);
-			goto fail;
-		}
-	} else {
-		err = -ECONNREFUSED;
-		u=unix_find_socket_byname(sunname, len, type, hash);
-		if (u) {
-			struct dentry *dentry;
-			dentry = unix_sk(u)->dentry;
-			if (dentry)
-				touch_atime(unix_sk(u)->mnt, dentry);
-		} else
-			goto fail;
-	}
 	return u;
-
-put_fail:
-	path_release(&nd);
-fail:
-	*error=err;
-	return NULL;
 }
 
-
 static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
@@ -1929,7 +1838,7 @@ static unsigned int unix_poll(struct file * file, struct socket *sock, poll_tabl
 	return mask;
 }
 
-
+#if 0
 #ifdef CONFIG_PROC_FS
 static struct sock *unix_seq_idx(int *iter, loff_t pos)
 {
@@ -2049,6 +1958,7 @@ static const struct file_operations unix_seq_fops = {
 };
 
 #endif
+#endif
 
 static struct net_proto_family unix_family_ops = {
 	.family = PF_UNIX,
@@ -2071,9 +1981,11 @@ static int __init af_unix_init(void)
 	}
 
 	sock_register(&unix_family_ops);
+#if 0
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("unix", 0, &unix_seq_fops);
 #endif
+#endif
 	unix_sysctl_register();
 out:
 	return rc;
@@ -2083,7 +1995,9 @@ static void __exit af_unix_exit(void)
 {
 	sock_unregister(PF_UNIX);
 	unix_sysctl_unregister();
+#if 0
 	proc_net_remove("unix");
+#endif
 	proto_unregister(&unix_proto);
 }
 
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index f20b7ea..bd52ee8 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -170,8 +170,10 @@ static void maybe_unmark_and_push(struct sock *x)
 void unix_gc(void)
 {
 	static DEFINE_MUTEX(unix_gc_sem);
+#ifdef CONFIG_MDT_LOOKUP
 	int i;
 	struct sock *s;
+#endif
 	struct sk_buff_head hitlist;
 	struct sk_buff *skb;
 
@@ -183,11 +185,12 @@ void unix_gc(void)
 		return;
 
 	spin_lock(&unix_table_lock);
-
+#ifdef CONFIG_MDT_LOOKUP
 	forall_unix_sockets(i, s)
 	{
 		unix_sk(s)->gc_tree = GC_ORPHAN;
 	}
+#endif
 	/*
 	 *	Everything is now marked
 	 */
@@ -205,6 +208,7 @@ void unix_gc(void)
 	 *	Push root set
 	 */
 
+#ifdef CONFIG_MDT_LOOKUP
 	forall_unix_sockets(i, s)
 	{
 		int open_count = 0;
@@ -224,7 +228,7 @@ void unix_gc(void)
 		if (open_count > atomic_read(&unix_sk(s)->inflight))
 			maybe_unmark_and_push(s);
 	}
-
+#endif
 	/*
 	 *	Mark phase
 	 */
@@ -275,6 +279,7 @@ void unix_gc(void)
 
 	skb_queue_head_init(&hitlist);
 
+#ifdef CONFIG_MDT_LOOKUP
 	forall_unix_sockets(i, s)
 	{
 		struct unix_sock *u = unix_sk(s);
@@ -301,6 +306,7 @@ void unix_gc(void)
 		}
 		u->gc_tree = GC_ORPHAN;
 	}
+#endif
 	spin_unlock(&unix_table_lock);
 
 	/*

-- 
	Evgeniy Polyakov
