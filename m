From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Thu, 22 Mar 2007 21:09:58 +0300
Message-ID: <20070322180957.GA17793@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49343 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934169AbXCVSKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 14:10:03 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.8/8.13.8) with ESMTP id l2MI9wOk028943
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 21:10:00 +0300
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.8/8.12.1/Submit) id l2MI9wGI028941
	for netdev@vger.kernel.org; Thu, 22 Mar 2007 21:09:58 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I'm pleased to announce initial patch which replaces hash tables
for different sockets types with unified multidimensional trie.

Benefits:
* unified storage which can host any socket types.
  Currently supported (see below about completeness):
   o IP (AF_INET) sockets
	* TCP established sockets
	* TCP listen sockets
	* TCP timewait sockets
	* RAW sockets
	* UDP sockets
   o Unix domain sockets
   o Netlink sockets
* RCU protected traversal.
* Dynamic grow.
* Constant maximum access speed designed to be faster
  than median hash table lookup speed
  (see below for testing environment description).

As a drawback I can only say that it eats about 3 times more RAM on 
x86 (98mb vs. 32mb for 2^20 entries).

Lookup methods as long as insertion/deletion ones differ only in key
setup part, although insert/delete methods perform some additional
per-protocl steps (like cleaning private areas in netlink).

Patch is a bit ugly - it contains horrible ifdefs and known to have
problems (see below), but I will clean things up and proceed 
(and break a lot in socket processing code - for sure) if 
(and only if, kevent story is enough for me to not make the same mistakes 
and throw half a year again) network developers decide that this approach 
worth doing (my personal opinion that it worth).

So, details.

1. Design.
It is a trie implementation (I call it multidimensional) which uses
several bits to select a node, so each node is an array of pointers to
another level(s). It is also possible that each array entry points to
cached value to speed up access and reduce memory usage.
It is similar to judy tree implementation.

More design notes can be found in related blog entries [1].

2. Performance.
I created userspace implementation and ran tests only with it.
Tests were performed for MDT trie (working name of this algo) and hash
tables with different number of entries. Each test contained 2^20
elements inserted into storage, each element is 3 pseudo-random 
32 bit value without zeroes in any byte.

The fastest hash table is of course table with 2^20 elements,
its lookup speed is about 130 nanoseconds.
MDT speed is about 110 nanoseconds.
Getting into account that tests were performed on Intel Core Duo in
userspace with per-4kb-tlb miss, 18% win is a good result for system, 
which uses 3 times more ram.
More details and graphs can be found in related blog entries [2].

3. Testing.
I only completed patch to the stage where system boots with LVM (netlink
and unix sockets) and I can log into it over ssh (TCP sockets) and run 
tcpdump (RAW sockets). For example it crashes when connecting over
loopback.

4. Unsolved problems.
a. It does not support any kind of statistics. At all. Completely.
All code is commented.
Because existing stats only support blind hash table traversal, which I
do not like as is, so I did not implement full trie traversal.
Socket structure just does not contain hash pointers anymore (except
bind_node used for netlink broadcasting, which I plan to reuse to
collect all sockets for given type to be placed into single per-protocol
lists, which can be accessed from statistics code).
b. code was not extensively tested and contains bugs.
c. existing hashing interfaces were not designed to work with failing
conditions, so alot of them will be changed.

6. Improvements.
o Unified cache for any socket type.
o Simplified insert/delete/lookup methods.
o Faster access speed.
o Smaller socket structure.
o RCU lookup.
o Dynamic structures (no need to rehash).
o Place you favourite here.

Anyway, it was interesting project as is, but enough words for now.
Feel free to ask questions.

Thank you.

1. Trie implementation and design.
http://tservice.net.ru/~s0mbre/blog/devel/networking/index.html
http://tservice.net.ru/~s0mbre/blog/devel/other/index.html

2. Performance tests.
Non-optimized trie access compared to hash tables (with graphs):
http://tservice.net.ru/~s0mbre/blog/2007/03/15#2007_03_15

Optimized one:
http://tservice.net.ru/~s0mbre/blog/2007/03/16#2007_03_16

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

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
index c0398f5..e8e7266 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -16,7 +16,7 @@ extern struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 extern spinlock_t unix_table_lock;
 
 extern atomic_t unix_tot_inflight;
-
+#ifndef CONFIG_MDT_LOOKUP
 static inline struct sock *first_unix_socket(int *i)
 {
 	for (*i = 0; *i <= UNIX_HASH_SIZE; (*i)++) {
@@ -43,6 +43,8 @@ static inline struct sock *next_unix_socket(int *i, struct sock *s)
 #define forall_unix_sockets(i, s) \
 	for (s = first_unix_socket(&(i)); s; s = next_unix_socket(&(i),(s)))
 
+#endif
+
 struct unix_address {
 	atomic_t	refcnt;
 	int		len;
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 133cf30..5dbab2d 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -244,11 +244,14 @@ extern struct request_sock *inet_csk_search_req(const struct sock *sk,
 						const __be32 laddr);
 extern int inet_csk_bind_conflict(const struct sock *sk,
 				  const struct inet_bind_bucket *tb);
+#ifndef CONFIG_MDT_LOOKUP
 extern int inet_csk_get_port(struct inet_hashinfo *hashinfo,
 			     struct sock *sk, unsigned short snum,
 			     int (*bind_conflict)(const struct sock *sk,
 						  const struct inet_bind_bucket *tb));
-
+#else
+extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
+#endif
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
index 09a2532..50dbe1b 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -78,7 +78,9 @@ struct inet_timewait_death_row {
 	struct timer_list	tw_timer;
 	int			slot;
 	struct hlist_head	cells[INET_TWDR_TWKILL_SLOTS];
+#ifndef CONFIG_MDT_LOOKUP
 	struct inet_hashinfo 	*hashinfo;
+#endif
 	int			sysctl_tw_recycle;
 	int			sysctl_max_tw_buckets;
 };
@@ -131,10 +133,13 @@ struct inet_timewait_sock {
 	__u16			tw_ipv6_offset;
 	int			tw_timeout;
 	unsigned long		tw_ttd;
+#ifndef CONFIG_MDT_LOOKUP
 	struct inet_bind_bucket	*tw_tb;
+#endif
 	struct hlist_node	tw_death_node;
 };
 
+#ifndef CONFIG_MDT_LOOKUP
 static inline void inet_twsk_add_node(struct inet_timewait_sock *tw,
 				      struct hlist_head *list)
 {
@@ -146,6 +151,7 @@ static inline void inet_twsk_add_bind_node(struct inet_timewait_sock *tw,
 {
 	hlist_add_head(&tw->tw_bind_node, list);
 }
+#endif
 
 static inline int inet_twsk_dead_hashed(const struct inet_timewait_sock *tw)
 {
@@ -209,12 +215,18 @@ static inline void inet_twsk_put(struct inet_timewait_sock *tw)
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 						  const int state);
 
+#ifndef CONFIG_MDT_LOOKUP
 extern void __inet_twsk_kill(struct inet_timewait_sock *tw,
 			     struct inet_hashinfo *hashinfo);
 
 extern void __inet_twsk_hashdance(struct inet_timewait_sock *tw,
 				  struct sock *sk,
 				  struct inet_hashinfo *hashinfo);
+#else
+extern void __inet_twsk_kill(struct inet_timewait_sock *tw);
+extern void __inet_twsk_hashdance(struct inet_timewait_sock *tw,
+				  struct sock *sk);
+#endif
 
 extern void inet_twsk_schedule(struct inet_timewait_sock *tw,
 			       struct inet_timewait_death_row *twdr,
diff --git a/include/net/lookup.h b/include/net/lookup.h
new file mode 100644
index 0000000..fd8b6c0
--- /dev/null
+++ b/include/net/lookup.h
@@ -0,0 +1,120 @@
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
+static inline int inet_iif(const struct sk_buff *skb)
+{
+	return ((struct rtable *)skb->dst)->rt_iif;
+}
+
+#ifndef CONFIG_MDT_LOOKUP
+
+#include <net/sock.h>
+#include <net/inet_hashtables.h>
+
+extern struct inet_hashinfo tcp_hashinfo;
+
+static inline void proto_put_port(struct sock *sk)
+{
+	inet_put_port(&tcp_hashinfo, sk);
+}
+
+static inline struct sock *__sock_lookup(const __be32 saddr, const __be16 sport,
+	const __be32 daddr, const __be16 dport, const int dif)
+{
+	return __inet_lookup(&tcp_hashinfo, saddr, sport, daddr, dport, dif);
+}
+
+static inline struct sock *sock_lookup(const __be32 saddr, const __be16 sport,
+				       const __be32 daddr, const __be16 dport,
+				       const int dif)
+{
+	struct sock *sk;
+
+	local_bh_disable();
+	sk = __sock_lookup(saddr, sport, daddr, dport, dif);
+	local_bh_enable();
+
+	return sk;
+}
+#else
+#include <linux/in.h>
+#include <net/inet_timewait_sock.h>
+
+extern struct sock *mdt_lookup_proto(const __be32 saddr, const __be16 sport,
+	const __be32 daddr, const __be16 dport, const int dif, const __u8 proto,
+	int stages);
+
+extern int mdt_insert_sock(struct sock *sk);
+extern int mdt_remove_sock(struct sock *sk);
+
+static inline struct sock *__sock_lookup(const __be32 saddr, const __be16 sport,
+	const __be32 daddr, const __be16 dport, const int dif, const u8 proto,
+	int stages)
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
+static inline void mdt_insert_sock_void(struct sock *sk)
+{
+	mdt_insert_sock(sk);
+}
+
+static inline void mdt_remove_sock_void(struct sock *sk)
+{
+	mdt_remove_sock(sk);
+}
+
+#endif
+
+#endif /* __LOOKUP_H */
diff --git a/include/net/netlink.h b/include/net/netlink.h
index bcaf67b..37cf163 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1016,4 +1016,33 @@ static inline int nla_validate_nested(struct nlattr *start, int maxtype,
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
+	struct module		*module;
+};
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
index 2c7d60c..7f31dd6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -114,10 +114,12 @@ struct sock_common {
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
 	int			skc_bound_dev_if;
-	struct hlist_node	skc_node;
 	struct hlist_node	skc_bind_node;
 	atomic_t		skc_refcnt;
+#ifndef CONFIG_MDT_LOOKUP
+	struct hlist_node	skc_node;
 	unsigned int		skc_hash;
+#endif
 	struct proto		*skc_prot;
 };
 
@@ -261,6 +263,26 @@ struct sock {
 	void                    (*sk_destruct)(struct sock *sk);
 };
 
+/* Grab socket reference count. This operation is valid only
+   when sk is ALREADY grabbed f.e. it is found in hash table
+   or a list and the lookup is made under lock preventing hash table
+   modifications.
+ */
+
+static inline void sock_hold(struct sock *sk)
+{
+	atomic_inc(&sk->sk_refcnt);
+}
+
+/* Ungrab socket in the context, which assumes that socket refcnt
+   cannot hit zero, f.e. it is true in context of any socketcall.
+ */
+static inline void __sock_put(struct sock *sk)
+{
+	atomic_dec(&sk->sk_refcnt);
+}
+
+#ifndef CONFIG_MDT_LOOKUP
 /*
  * Hashed lists helper routines
  */
@@ -310,41 +332,51 @@ static __inline__ int __sk_del_node_init(struct sock *sk)
 	return 0;
 }
 
-/* Grab socket reference count. This operation is valid only
-   when sk is ALREADY grabbed f.e. it is found in hash table
-   or a list and the lookup is made under lock preventing hash table
-   modifications.
- */
-
-static inline void sock_hold(struct sock *sk)
+static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
 {
-	atomic_inc(&sk->sk_refcnt);
+	hlist_add_head(&sk->sk_node, list);
 }
 
-/* Ungrab socket in the context, which assumes that socket refcnt
-   cannot hit zero, f.e. it is true in context of any socketcall.
- */
-static inline void __sock_put(struct sock *sk)
+#define sk_for_each(__sk, node, list) \
+	hlist_for_each_entry(__sk, node, list, sk_node)
+#define sk_for_each_from(__sk, node) \
+	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
+		hlist_for_each_entry_from(__sk, node, sk_node)
+#define sk_for_each_continue(__sk, node) \
+	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
+		hlist_for_each_entry_continue(__sk, node, sk_node)
+#define sk_for_each_safe(__sk, node, tmp, list) \
+	hlist_for_each_entry_safe(__sk, node, tmp, list, sk_node)
+#else
+
+static __inline__ void __sk_del_bind_node(struct sock *sk)
 {
-	atomic_dec(&sk->sk_refcnt);
+	__hlist_del(&sk->sk_bind_node);
 }
 
-static __inline__ int sk_del_node_init(struct sock *sk)
+static __inline__ void sk_add_bind_node(struct sock *sk,
+					struct hlist_head *list)
 {
-	int rc = __sk_del_node_init(sk);
+	hlist_add_head(&sk->sk_bind_node, list);
+}
 
-	if (rc) {
-		/* paranoid for a while -acme */
-		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
-		__sock_put(sk);
-	}
-	return rc;
+#define sk_for_each_bound(__sk, node, list) \
+	hlist_for_each_entry(__sk, node, list, sk_bind_node)
+
+int mdt_insert_sock(struct sock *sk);
+int mdt_remove_sock(struct sock *sk);
+
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
+#endif
 
 static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
 {
@@ -352,30 +384,18 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
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
index 1b921fa..82f9f15 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -30,6 +30,7 @@
 #include <linux/ipv6.h>
 #include <linux/seq_file.h>
 #include <linux/poll.h>
+#include <net/lookup.h>
 
 /**
  *	struct udp_skb_cb  -  UDP(-Lite) private variables
@@ -108,12 +109,16 @@ static inline void udp_lib_hash(struct sock *sk)
 
 static inline void udp_lib_unhash(struct sock *sk)
 {
+#ifndef CONFIG_MDT_LOOKUP
 	write_lock_bh(&udp_hash_lock);
 	if (sk_del_node_init(sk)) {
 		inet_sk(sk)->num = 0;
 		sock_prot_dec_use(sk->sk_prot);
 	}
 	write_unlock_bh(&udp_hash_lock);
+#else
+	mdt_remove_sock_void(sk);
+#endif
 }
 
 static inline void udp_lib_close(struct sock *sk, long timeout)
diff --git a/net/core/sock.c b/net/core/sock.c
index 8d65d64..abe1632 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -901,7 +901,9 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sock_copy(newsk, sk);
 
 		/* SANITY */
+#ifndef CONFIG_MDT_LOOKUP
 		sk_node_init(&newsk->sk_node);
+#endif
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 9e8ef50..5bfb0dc 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -1,6 +1,14 @@
 #
 # IP configuration
 #
+
+config MDT_LOOKUP
+	bool "Multidimensional trie socket lookup"
+	depends on !INET_TCP_DIAG
+	help
+	  This option replaces traditional hash table lookup for TCP sockets
+	  with multidimensional trie algorithm (similar to judy trie).
+
 config IP_MULTICAST
 	bool "IP: multicasting"
 	help
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 7a06862..f1f1459 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -4,7 +4,7 @@
 
 obj-y     := route.o inetpeer.o protocol.o \
 	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
-	     ip_output.o ip_sockglue.o inet_hashtables.o \
+	     ip_output.o ip_sockglue.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o \
@@ -12,6 +12,11 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
 
+ifeq ($(CONFIG_MDT_LOOKUP),n)
+obj-y += inet_hashtables.o
+endif
+
+obj-$(CONFIG_MDT_LOOKUP) += mdt.o
 obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
 obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
 obj-$(CONFIG_PROC_FS) += proc.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cf358c8..8c32545 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1360,6 +1360,7 @@ fs_initcall(inet_init);
 /* ------------------------------------------------------------------------ */
 
 #ifdef CONFIG_PROC_FS
+#ifndef CONFIG_MDT_LOOKUP
 static int __init ipv4_proc_init(void)
 {
 	int rc = 0;
@@ -1388,7 +1389,12 @@ out_raw:
 	rc = -ENOMEM;
 	goto out;
 }
-
+#else
+static int __init ipv4_proc_init(void)
+{
+	return 0;
+}
+#endif
 #else /* CONFIG_PROC_FS */
 static int __init ipv4_proc_init(void)
 {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4b7a0d9..eaf445d 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -698,6 +698,7 @@ static void icmp_unreach(struct sk_buff *skb)
 
 	/* Note: See raw.c and net/raw.h, RAWV4_HTABLE_SIZE==MAX_INET_PROTOS */
 	hash = protocol & (MAX_INET_PROTOS - 1);
+#ifndef CONFIG_MDT_LOOKUP
 	read_lock(&raw_v4_lock);
 	if ((raw_sk = sk_head(&raw_v4_htable[hash])) != NULL) {
 		while ((raw_sk = __raw_v4_lookup(raw_sk, protocol, iph->daddr,
@@ -709,6 +710,15 @@ static void icmp_unreach(struct sk_buff *skb)
 		}
 	}
 	read_unlock(&raw_v4_lock);
+#else
+	raw_sk = __raw_v4_lookup(NULL, protocol, iph->daddr,
+					 iph->saddr,
+					 skb->dev->ifindex);
+	if (raw_sk) {
+		raw_err(raw_sk, skb, info);
+		iph = (struct iphdr *)skb->data;
+	}
+#endif
 
 	rcu_read_lock();
 	ipprot = rcu_dereference(inet_protos[hash]);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 43fb160..ec4ae71 100644
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
@@ -36,6 +36,7 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  */
 int sysctl_local_port_range[2] = { 1024, 4999 };
 
+#ifndef CONFIG_MDT_LOOKUP
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb)
 {
@@ -159,6 +160,7 @@ fail:
 }
 
 EXPORT_SYMBOL_GPL(inet_csk_get_port);
+#endif
 
 /*
  * Wait for an incoming connection, avoid race conditions. This must be called
@@ -529,8 +531,10 @@ void inet_csk_destroy_sock(struct sock *sk)
 	BUG_TRAP(sk->sk_state == TCP_CLOSE);
 	BUG_TRAP(sock_flag(sk, SOCK_DEAD));
 
+#ifndef CONFIG_MDT_LOOKUP
 	/* It cannot be in hash table! */
 	BUG_TRAP(sk_unhashed(sk));
+#endif
 
 	/* If it has not 0 inet_sk(sk)->num, it must be bound */
 	BUG_TRAP(!inet_sk(sk)->num || inet_csk(sk)->icsk_bind_hash);
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
index a73cf93..e5e0fff 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -9,10 +9,11 @@
  */
 
 
-#include <net/inet_hashtables.h>
+#include <net/lookup.h>
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
 
+#ifndef CONFIG_MDT_LOOKUP
 /* Must be called with locally disabled BHs. */
 void __inet_twsk_kill(struct inet_timewait_sock *tw, struct inet_hashinfo *hashinfo)
 {
@@ -86,6 +87,22 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 }
 
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
+#else
+void __inet_twsk_kill(struct inet_timewait_sock *tw)
+{
+	inet_twsk_put(tw);
+	mdt_remove_sock_tw(tw);
+}
+
+void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk)
+{
+	if (__sk_del_node_init(sk))
+		sock_prot_dec_use(sk->sk_prot);
+
+	mdt_insert_sock_tw(tw);
+	atomic_inc(&tw->tw_refcnt);
+}
+#endif
 
 struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int state)
 {
@@ -106,11 +123,15 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_dport	    = inet->dport;
 		tw->tw_family	    = sk->sk_family;
 		tw->tw_reuse	    = sk->sk_reuse;
+#ifndef CONFIG_MDT_LOOKUP
 		tw->tw_hash	    = sk->sk_hash;
+#endif
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
 		atomic_set(&tw->tw_refcnt, 1);
+#ifndef CONFIG_MDT_LOOKUP
 		inet_twsk_dead_node_init(tw);
+#endif
 		__module_get(tw->tw_prot->owner);
 	}
 
@@ -140,7 +161,11 @@ rescan:
 	inet_twsk_for_each_inmate(tw, node, &twdr->cells[slot]) {
 		__inet_twsk_del_dead_node(tw);
 		spin_unlock(&twdr->death_lock);
+#ifndef CONFIG_MDT_LOOKUP
 		__inet_twsk_kill(tw, twdr->hashinfo);
+#else
+		__inet_twsk_kill(tw);
+#endif
 		inet_twsk_put(tw);
 		killed++;
 		spin_lock(&twdr->death_lock);
@@ -242,7 +267,11 @@ void inet_twsk_deschedule(struct inet_timewait_sock *tw,
 			del_timer(&twdr->tw_timer);
 	}
 	spin_unlock(&twdr->death_lock);
+#ifndef CONFIG_MDT_LOOKUP
 	__inet_twsk_kill(tw, twdr->hashinfo);
+#else
+	__inet_twsk_kill(tw);
+#endif
 }
 
 EXPORT_SYMBOL(inet_twsk_deschedule);
@@ -354,7 +383,11 @@ void inet_twdr_twcal_tick(unsigned long data)
 			inet_twsk_for_each_inmate_safe(tw, node, safe,
 						       &twdr->twcal_row[slot]) {
 				__inet_twsk_del_dead_node(tw);
+#ifndef CONFIG_MDT_LOOKUP
 				__inet_twsk_kill(tw, twdr->hashinfo);
+#else
+				__inet_twsk_kill(tw);
+#endif
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
index 0000000..6c573a3
--- /dev/null
+++ b/net/ipv4/mdt.c
@@ -0,0 +1,598 @@
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
+			if (i >= bits) {
+				ulog("      last ret: %p\n", n);
+				return n;
+			}
+
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
+	new = kzalloc(sizeof(struct mdt_node), gfp_flags);
+	if (!new)
+		return NULL;
+	return new;
+}
+
+static inline struct mdt_storage *mdt_alloc_storage(gfp_t gfp_flags)
+{
+	struct mdt_storage *new;
+
+	new = kzalloc(sizeof(struct mdt_storage), gfp_flags);
+	if (!new)
+		return NULL;
+	return new;
+}
+
+static void mdt_free_rcu(struct rcu_head *rcu_head)
+{
+	struct mdt_storage *st = container_of(rcu_head, struct mdt_storage, rcu_head);
+
+	kfree(st);
+}
+
+static inline void mdt_free_storage(struct mdt_storage *st)
+{
+	INIT_RCU_HEAD(&st->rcu_head);
+	call_rcu(&st->rcu_head, mdt_free_rcu);
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
+			if (i >= bits) {
+				if (n) {
+					return -EEXIST;
+				}
+				MDT_SET_LEAF_PTR(prev->leaf[idx], priv);
+				return 0;
+			}
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
+					return 0;
+				}
+				new = mdt_alloc_node(gfp_flags);
+				if (!new)
+					return -ENOMEM;
+				MDT_SET_LEAF_LEVEL(prev->leaf[idx], new);
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
+			if (i >= bits) {
+				ulog("      last ret: %p", n);
+				MDT_SET_LEAF_PTR(prev->leaf[idx], NULL);
+				return 0;
+			}
+
+			if (MDT_LEAF_IS_STORAGE(n)) {
+				st = MDT_GET_STORAGE(n);
+				if ((st->val[0] != val) || 
+					!mdt_last_equal(&st->val[1], data, MDT_CACHED_NUM-1))
+					return -ENODEV;
+				MDT_SET_LEAF_PTR(prev->leaf[idx], NULL);
+				ulog("      storage ret: %p", st->priv);
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
+	if (proto == IPPROTO_TCP)
+		printk("%s: 1 %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, if: %d, proto: %d, sk: %p.\n", 
+			__func__, NIPQUAD(saddr), ntohs(sport),
+			NIPQUAD(daddr), ntohs(dport),
+			dif, proto, sk);
+	if (!sk && stages) {
+		key[0] = key[1] = 0;
+		key[2] = dport;
+		key[3] = (0 & 0x0000ffff) | (proto << 24) | (AF_INET << 16);
+
+		sk = mdt_lookup(&mdt_root, key, sizeof(key)<<3);
+		if (proto == IPPROTO_TCP)
+			printk("%s: 2 %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, if: %d, proto: %d, sk: %p.\n", 
+				__func__, NIPQUAD(key[0]), ntohs(0),
+				NIPQUAD(key[1]), ntohs(dport),
+				0, proto, sk);
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
+
+	printk("mdt: %s %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, if: %d, proto: %d.\n", 
+			str,
+			NIPQUAD(inet->rcv_saddr), inet->num,
+			NIPQUAD(inet->daddr), ntohs(inet->dport),
+			sk->sk_bound_dev_if, sk->sk_protocol);
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
+
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
+
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
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 87e9c16..fd83511 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -78,10 +78,22 @@
 #include <linux/seq_file.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
+#include <net/lookup.h>
 
+int raw_in_use = 0;
+#ifndef CONFIG_MDT_LOOKUP
 struct hlist_head raw_v4_htable[RAWV4_HTABLE_SIZE];
 DEFINE_RWLOCK(raw_v4_lock);
 
+#define sk_for_each(__sk, node, list) \
+	hlist_for_each_entry(__sk, node, list, sk_node)
+#define sk_for_each_from(__sk, node) \
+	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
+		hlist_for_each_entry_from(__sk, node, sk_node)
+#define sk_for_each_continue(__sk, node) \
+	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
+		hlist_for_each_entry_continue(__sk, node, sk_node)
+
 static void raw_v4_hash(struct sock *sk)
 {
 	struct hlist_head *head = &raw_v4_htable[inet_sk(sk)->num &
@@ -120,6 +132,14 @@ struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
 found:
 	return sk;
 }
+#endif
+
+struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
+			     __be32 raddr, __be32 laddr,
+			     int dif)
+{
+	return mdt_lookup_raw(num, raddr, laddr, dif);
+}
 
 /*
  *	0 - deliver
@@ -152,9 +172,9 @@ static __inline__ int icmp_filter(struct sock *sk, struct sk_buff *skb)
 int raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash)
 {
 	struct sock *sk;
-	struct hlist_head *head;
 	int delivered = 0;
-
+#ifndef CONFIG_MDT_LOOKUP
+	struct hlist_head *head;
 	read_lock(&raw_v4_lock);
 	head = &raw_v4_htable[hash];
 	if (hlist_empty(head))
@@ -178,6 +198,22 @@ int raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash)
 	}
 out:
 	read_unlock(&raw_v4_lock);
+#else
+	sk = __raw_v4_lookup(NULL, iph->protocol,
+			     iph->saddr, iph->daddr,
+			     skb->dev->ifindex);
+	if (sk) {
+		delivered = 1;
+		if (iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) {
+			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
+
+			/* Not releasing hash table! */
+			if (clone)
+				raw_rcv(sk, clone);
+		}
+		sock_put(sk);
+	}
+#endif
 	return delivered;
 }
 
@@ -768,8 +804,13 @@ struct proto raw_prot = {
 	.recvmsg	   = raw_recvmsg,
 	.bind		   = raw_bind,
 	.backlog_rcv	   = raw_rcv_skb,
+#ifndef CONFIG_MDT_LOOKUP
 	.hash		   = raw_v4_hash,
 	.unhash		   = raw_v4_unhash,
+#else
+	.hash		   = mdt_insert_sock_void,
+	.unhash		   = mdt_remove_sock_void,
+#endif
 	.obj_size	   = sizeof(struct raw_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_raw_setsockopt,
@@ -777,6 +818,7 @@ struct proto raw_prot = {
 #endif
 };
 
+#ifndef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 struct raw_iter_state {
 	int bucket;
@@ -936,3 +978,4 @@ void __init raw_proc_exit(void)
 	proc_net_remove("raw");
 }
 #endif /* CONFIG_PROC_FS */
+#endif
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 74c4d10..531eafb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2389,12 +2389,15 @@ void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
 	unsigned long limit;
-	int order, i, max_share;
+	int order, max_share;
+#ifndef CONFIG_MDT_LOOKUP
+	int i;
+#endif
 
 	if (sizeof(struct tcp_skb_cb) > sizeof(skb->cb))
 		__skb_cb_too_small_for_tcp(sizeof(struct tcp_skb_cb),
 					   sizeof(skb->cb));
-
+#ifndef CONFIG_MDT_LOOKUP
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
@@ -2445,6 +2448,10 @@ void __init tcp_init(void)
 			(tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket));
 			order++)
 		;
+#else
+	for (order = 0; ((1 << order) << PAGE_SHIFT) < (8*(1<<20)); order++);
+#endif
+
 	if (order >= 4) {
 		sysctl_local_port_range[0] = 32768;
 		sysctl_local_port_range[1] = 61000;
@@ -2457,9 +2464,8 @@ void __init tcp_init(void)
 		sysctl_tcp_max_orphans >>= (3 - order);
 		sysctl_max_syn_backlog = 128;
 	}
-
 	/* Allow no more than 3/4 kernel memory (usually less) allocated to TCP */
-	sysctl_tcp_mem[0] = (1536 / sizeof (struct inet_bind_hashbucket)) << order;
+	sysctl_tcp_mem[0] = (1536 / 8) << order;
 	sysctl_tcp_mem[1] = sysctl_tcp_mem[0] * 4 / 3;
 	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
 
@@ -2473,11 +2479,11 @@ void __init tcp_init(void)
 	sysctl_tcp_rmem[0] = SK_STREAM_MEM_QUANTUM;
 	sysctl_tcp_rmem[1] = 87380;
 	sysctl_tcp_rmem[2] = max(87380, max_share);
-
+#ifndef CONFIG_MDT_LOOKUP
 	printk(KERN_INFO "TCP: Hash tables configured "
 	       "(established %d bind %d)\n",
 	       tcp_hashinfo.ehash_size, tcp_hashinfo.bhash_size);
-
+#endif
 	tcp_register_congestion_control(&tcp_reno);
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ba74bb..243d382 100644
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
@@ -101,6 +102,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   int tcplen);
 #endif
 
+#ifndef CONFIG_MDT_LOOKUP
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_lock  = __RW_LOCK_UNLOCKED(tcp_hashinfo.lhash_lock),
 	.lhash_users = ATOMIC_INIT(0),
@@ -113,7 +115,7 @@ static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
 				 inet_csk_bind_conflict);
 }
 
-static void tcp_v4_hash(struct sock *sk)
+void tcp_v4_hash(struct sock *sk)
 {
 	inet_hash(&tcp_hashinfo, sk);
 }
@@ -123,6 +125,13 @@ void tcp_unhash(struct sock *sk)
 	inet_unhash(&tcp_hashinfo, sk);
 }
 
+#else
+static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
+{
+	return mdt_insert_sock_port(sk, snum);
+}
+#endif
+
 static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(skb->nh.iph->daddr,
@@ -245,7 +254,11 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	 * complete initialization after this.
 	 */
 	tcp_set_state(sk, TCP_SYN_SENT);
+#ifdef CONFIG_MDT_LOOKUP
+	err = mdt_insert_sock_port(sk, 0);
+#else
 	err = inet_hash_connect(&tcp_death_row, sk);
+#endif
 	if (err)
 		goto failure;
 
@@ -365,8 +378,8 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 		return;
 	}
 
-	sk = inet_lookup(&tcp_hashinfo, iph->daddr, th->dest, iph->saddr,
-			 th->source, inet_iif(skb));
+	sk = sock_lookup(iph->daddr, th->dest, iph->saddr,
+			 th->source, inet_iif(skb), IPPROTO_TCP, 0);
 	if (!sk) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;
@@ -1465,9 +1478,15 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 					  newkey, key->keylen);
 	}
 #endif
-
+#ifndef CONFIG_MDT_LOOKUP
 	__inet_hash(&tcp_hashinfo, newsk, 0);
 	__inet_inherit_port(&tcp_hashinfo, sk, newsk);
+#else
+	if (mdt_insert_sock(newsk)) {
+		inet_csk_destroy_sock(newsk);
+		goto exit_overflow;
+	}
+#endif
 
 	return newsk;
 
@@ -1490,11 +1509,14 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 						       iph->saddr, iph->daddr);
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
-
+#ifdef CONFIG_MDT_LOOKUP
+	nsk = __sock_lookup(skb->nh.iph->saddr, th->source, 
+			skb->nh.iph->daddr, th->dest, inet_iif(skb), IPPROTO_TCP, 0);
+#else
 	nsk = inet_lookup_established(&tcp_hashinfo, skb->nh.iph->saddr,
 				      th->source, skb->nh.iph->daddr,
 				      th->dest, inet_iif(skb));
-
+#endif
 	if (nsk) {
 		if (nsk->sk_state != TCP_TIME_WAIT) {
 			bh_lock_sock(nsk);
@@ -1647,9 +1669,9 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = skb->nh.iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(&tcp_hashinfo, skb->nh.iph->saddr, th->source,
+	sk = __sock_lookup(skb->nh.iph->saddr, th->source,
 			   skb->nh.iph->daddr, th->dest,
-			   inet_iif(skb));
+			   inet_iif(skb), IPPROTO_TCP, 1);
 
 	if (!sk)
 		goto no_tcp_socket;
@@ -1723,10 +1745,15 @@ do_time_wait:
 	}
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
+#ifndef CONFIG_MDT_LOOKUP
 		struct sock *sk2 = inet_lookup_listener(&tcp_hashinfo,
 							skb->nh.iph->daddr,
 							th->dest,
 							inet_iif(skb));
+#else
+		struct sock *sk2 = sock_lookup(0, 0, skb->nh.iph->daddr,
+				th->dest, inet_iif(skb), IPPROTO_TCP, 1);
+#endif
 		if (sk2) {
 			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
 			inet_twsk_put(inet_twsk(sk));
@@ -1914,7 +1941,7 @@ int tcp_v4_destroy_sock(struct sock *sk)
 
 	/* Clean up a referenced TCP bind bucket. */
 	if (inet_csk(sk)->icsk_bind_hash)
-		inet_put_port(&tcp_hashinfo, sk);
+		proto_put_port(sk);
 
 	/*
 	 * If sendmsg cached page exists, toss it.
@@ -1934,6 +1961,7 @@ EXPORT_SYMBOL(tcp_v4_destroy_sock);
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCP sock list dumping. */
 
+#ifndef CONFIG_MDT_LOOKUP
 static inline struct inet_timewait_sock *tw_head(struct hlist_head *head)
 {
 	return hlist_empty(head) ? NULL :
@@ -2267,6 +2295,15 @@ void tcp_proc_unregister(struct tcp_seq_afinfo *afinfo)
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
@@ -2430,8 +2467,13 @@ struct proto tcp_prot = {
 	.sendmsg		= tcp_sendmsg,
 	.recvmsg		= tcp_recvmsg,
 	.backlog_rcv		= tcp_v4_do_rcv,
+#ifdef CONFIG_MDT_LOOKUP
+	.hash			= mdt_insert_sock_void,
+	.unhash			= mdt_remove_sock_void,
+#else
 	.hash			= tcp_v4_hash,
 	.unhash			= tcp_unhash,
+#endif
 	.get_port		= tcp_v4_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
 	.sockets_allocated	= &tcp_sockets_allocated,
@@ -2459,9 +2501,11 @@ void __init tcp_v4_init(struct net_proto_family *ops)
 }
 
 EXPORT_SYMBOL(ipv4_specific);
+#ifndef CONFIG_MDT_LOOKUP
 EXPORT_SYMBOL(tcp_hashinfo);
-EXPORT_SYMBOL(tcp_prot);
 EXPORT_SYMBOL(tcp_unhash);
+#endif
+EXPORT_SYMBOL(tcp_prot);
 EXPORT_SYMBOL(tcp_v4_conn_request);
 EXPORT_SYMBOL(tcp_v4_connect);
 EXPORT_SYMBOL(tcp_v4_do_rcv);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6b5c64f..79485d4 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -41,7 +41,9 @@ struct inet_timewait_death_row tcp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
 	.period		= TCP_TIMEWAIT_LEN / INET_TWDR_TWKILL_SLOTS,
 	.death_lock	= __SPIN_LOCK_UNLOCKED(tcp_death_row.death_lock),
+#ifndef CONFIG_MDT_LOOKUP
 	.hashinfo	= &tcp_hashinfo,
+#endif
 	.tw_timer	= TIMER_INITIALIZER(inet_twdr_hangman, 0,
 					    (unsigned long)&tcp_death_row),
 	.twkill_work	= __WORK_INITIALIZER(tcp_death_row.twkill_work,
@@ -328,7 +330,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 #endif
 
 		/* Linkage updates. */
+#ifndef CONFIG_MDT_LOOKUP
 		__inet_twsk_hashdance(tw, sk, &tcp_hashinfo);
+#else
+		__inet_twsk_hashdance(tw, sk);
+#endif
 
 		/* Get the TIME_WAIT timeout firing. */
 		if (timeo < rto)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fc620a7..a824dbb 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -101,6 +101,7 @@
 #include <net/route.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <net/lookup.h>
 #include "udp_impl.h"
 
 /*
@@ -111,7 +112,7 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_statistics) __read_mostly;
 
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
-
+#ifndef CONFIG_MDT_LOOKUP
 static int udp_port_rover;
 
 static inline int __udp_lib_lport_inuse(__u16 num, struct hlist_head udptable[])
@@ -212,7 +213,7 @@ fail:
 	return error;
 }
 
-__inline__ int udp_get_port(struct sock *sk, unsigned short snum,
+int udp_get_port(struct sock *sk, unsigned short snum,
 			int (*scmp)(const struct sock *, const struct sock *))
 {
 	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
@@ -314,6 +315,67 @@ found:
 }
 
 /*
+ *	Multicasts and broadcasts go to each listener.
+ *
+ *	Note: called only from the BH handler context,
+ *	so we don't need to lock the hashes.
+ */
+static int __udp4_lib_mcast_deliver(struct sk_buff *skb,
+				    struct udphdr  *uh,
+				    __be32 saddr, __be32 daddr,
+				    struct hlist_head udptable[])
+{
+	struct sock *sk;
+	int dif;
+
+	read_lock(&udp_hash_lock);
+	sk = sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
+	dif = skb->dev->ifindex;
+	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
+	if (sk) {
+		struct sock *sknext = NULL;
+
+		do {
+			struct sk_buff *skb1 = skb;
+
+			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
+						   uh->source, saddr, dif);
+			if(sknext)
+				skb1 = skb_clone(skb, GFP_ATOMIC);
+
+			if(skb1) {
+				int ret = udp_queue_rcv_skb(sk, skb1);
+				if (ret > 0)
+					/* we should probably re-process instead
+					 * of dropping packets here. */
+					kfree_skb(skb1);
+			}
+			sk = sknext;
+		} while(sknext);
+	} else
+		kfree_skb(skb);
+	read_unlock(&udp_hash_lock);
+	return 0;
+}
+
+#else
+
+static inline int udp_v4_get_port(struct sock *sk, unsigned short snum)
+{
+	return  mdt_insert_sock_port(sk, snum);
+}
+
+static struct sock *__udp4_lib_lookup(__be32 saddr, __be16 sport,
+				      __be32 daddr, __be16 dport,
+				      int dif)
+{
+	return __sock_lookup(saddr, sport, daddr, dport, dif, IPPROTO_UDP, 1);
+}
+
+#endif
+
+
+/*
  * This routine is called by the ICMP module when it gets some
  * sort of error condition.  If err < 0 then the socket should
  * be closed and the error returned to the user.  If err > 0
@@ -335,8 +397,13 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 	int harderr;
 	int err;
 
+#ifndef CONFIG_MDT_LOOKUP
+	sk = __udp4_lib_lookup(iph->daddr, uh->dest, iph->saddr, uh->source,
+			       skb->dev->ifindex, udptable);
+#else
 	sk = __udp4_lib_lookup(iph->daddr, uh->dest, iph->saddr, uh->source,
-			       skb->dev->ifindex, udptable		    );
+			       skb->dev->ifindex);
+#endif
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
@@ -1117,50 +1184,6 @@ drop:
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
@@ -1197,7 +1220,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct sock *sk;
 	struct udphdr *uh = skb->h.uh;
 	unsigned short ulen;
+#ifndef CONFIG_MDT_LOOKUP
 	struct rtable *rt = (struct rtable*)skb->dst;
+#endif
 	__be32 saddr = skb->nh.iph->saddr;
 	__be32 daddr = skb->nh.iph->daddr;
 
@@ -1224,12 +1249,16 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 			goto csum_error;
 	}
 
+#ifndef CONFIG_MDT_LOOKUP
 	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
 	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
 			       skb->dev->ifindex, udptable        );
-
+#else
+	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
+			       skb->dev->ifindex);
+#endif
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
@@ -1531,6 +1560,7 @@ struct proto udp_prot = {
 #endif
 };
 
+#ifndef CONFIG_MDT_LOOKUP
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
 
@@ -1717,19 +1747,24 @@ void udp4_proc_exit(void)
 	udp_proc_unregister(&udp4_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
+#endif
 
 EXPORT_SYMBOL(udp_disconnect);
+EXPORT_SYMBOL(udp_ioctl);
+#ifndef CONFIG_MDT_LOOKUP
 EXPORT_SYMBOL(udp_hash);
 EXPORT_SYMBOL(udp_hash_lock);
-EXPORT_SYMBOL(udp_ioctl);
 EXPORT_SYMBOL(udp_get_port);
+#endif
 EXPORT_SYMBOL(udp_prot);
 EXPORT_SYMBOL(udp_sendmsg);
 EXPORT_SYMBOL(udp_lib_getsockopt);
 EXPORT_SYMBOL(udp_lib_setsockopt);
 EXPORT_SYMBOL(udp_poll);
 
+#ifndef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
 EXPORT_SYMBOL(udp_proc_unregister);
 #endif
+#endif
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index b28fe1e..e21c942 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -16,6 +16,7 @@
 DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics)	__read_mostly;
 
 struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
+#ifndef CONFIG_MDT_LOOKUP
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
 
+#ifndef CONFIG_MDT_LOOKUP
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
 
+#ifndef CONFIG_MDT_LOOKUP
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
+#ifndef CONFIG_MDT_LOOKUP
 EXPORT_SYMBOL(udplite_get_port);
+#endif
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e73d8f5..843e9f8 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -60,35 +60,14 @@
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
+#ifndef CONFIG_MDT_LOOKUP
 struct nl_pid_hash {
 	struct hlist_head *table;
 	unsigned long rehash_time;
@@ -101,9 +80,11 @@ struct nl_pid_hash {
 
 	u32 rnd;
 };
-
+#endif
 struct netlink_table {
+#ifndef CONFIG_MDT_LOOKUP
 	struct nl_pid_hash hash;
+#endif
 	struct hlist_head mc_list;
 	unsigned long *listeners;
 	unsigned int nl_nonroot;
@@ -114,11 +95,10 @@ struct netlink_table {
 
 static struct netlink_table *nl_table;
 
-static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
-
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
 
+static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 static DEFINE_RWLOCK(nl_table_lock);
 static atomic_t nl_table_users = ATOMIC_INIT(0);
 
@@ -129,11 +109,14 @@ static u32 netlink_group_mask(u32 group)
 	return group ? 1 << (group - 1) : 0;
 }
 
+#ifndef CONFIG_MDT_LOOKUP
 static struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
 {
 	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
 }
 
+#endif
+
 static void netlink_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_receive_queue);
@@ -199,6 +182,7 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
+#ifndef CONFIG_MDT_LOOKUP
 static __inline__ struct sock *netlink_lookup(int protocol, u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[protocol].hash;
@@ -294,26 +278,6 @@ static inline int nl_pid_hash_dilute(struct nl_pid_hash *hash, int len)
 	return 0;
 }
 
-static const struct proto_ops netlink_ops;
-
-static void
-netlink_update_listeners(struct sock *sk)
-{
-	struct netlink_table *tbl = &nl_table[sk->sk_protocol];
-	struct hlist_node *node;
-	unsigned long mask;
-	unsigned int i;
-
-	for (i = 0; i < NLGRPSZ(tbl->groups)/sizeof(unsigned long); i++) {
-		mask = 0;
-		sk_for_each_bound(sk, node, &tbl->mc_list)
-			mask |= nlk_sk(sk)->groups[i];
-		tbl->listeners[i] = mask;
-	}
-	/* this function is only called with the netlink table "grabbed", which
-	 * makes sure updates are visible before bind or setsockopt return. */
-}
-
 static int netlink_insert(struct sock *sk, u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
@@ -364,6 +328,117 @@ static void netlink_remove(struct sock *sk)
 	netlink_table_ungrab();
 }
 
+static int netlink_autobind(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
+	struct hlist_head *head;
+	struct sock *osk;
+	struct hlist_node *node;
+	s32 pid = current->tgid;
+	int err;
+	static s32 rover = -4097;
+
+retry:
+	cond_resched();
+	netlink_table_grab();
+	head = nl_pid_hashfn(hash, pid);
+	sk_for_each(osk, node, head) {
+		if (nlk_sk(osk)->pid == pid) {
+			/* Bind collision, search negative pid values. */
+			pid = rover--;
+			if (rover > -4097)
+				rover = -4097;
+			netlink_table_ungrab();
+			goto retry;
+		}
+	}
+	netlink_table_ungrab();
+
+	err = netlink_insert(sk, pid);
+	if (err == -EADDRINUSE)
+		goto retry;
+
+	/* If 2 threads race to autobind, that is fine.  */
+	if (err == -EBUSY)
+		err = 0;
+
+	return err;
+}
+
+#else
+extern int mdt_insert_netlink(struct sock *sk, u32 pid);
+extern int mdt_remove_netlink(struct sock *sk);
+extern struct sock *netlink_lookup(int protocol, u32 pid);
+
+static void
+netlink_update_listeners(struct sock *sk)
+{
+	struct netlink_table *tbl = &nl_table[sk->sk_protocol];
+	struct hlist_node *node;
+	unsigned long mask;
+	unsigned int i;
+
+	for (i = 0; i < NLGRPSZ(tbl->groups)/sizeof(unsigned long); i++) {
+		mask = 0;
+		sk_for_each_bound(sk, node, &tbl->mc_list)
+			mask |= nlk_sk(sk)->groups[i];
+		tbl->listeners[i] = mask;
+	}
+	/* this function is only called with the netlink table "grabbed", which
+	 * makes sure updates are visible before bind or setsockopt return. */
+}
+
+static void
+netlink_update_subscriptions(struct sock *sk, unsigned int subscriptions)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (nlk->subscriptions && !subscriptions)
+		__sk_del_bind_node(sk);
+	else if (!nlk->subscriptions && subscriptions)
+		sk_add_bind_node(sk, &nl_table[sk->sk_protocol].mc_list);
+	nlk->subscriptions = subscriptions;
+}
+
+static int netlink_insert(struct sock *sk, u32 pid)
+{
+	int err;
+	netlink_lock_table();
+	err = mdt_insert_netlink(sk, pid);
+	netlink_unlock_table();
+	return err;
+}
+
+static void netlink_remove(struct sock *sk)
+{
+	netlink_lock_table();
+	mdt_remove_netlink(sk);
+	if (nlk_sk(sk)->subscriptions)
+		__sk_del_bind_node(sk);
+	netlink_unlock_table();
+}
+
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
+#endif
+
+static const struct proto_ops netlink_ops;
+
 static struct proto netlink_proto = {
 	.name	  = "NETLINK",
 	.owner	  = THIS_MODULE,
@@ -490,62 +565,12 @@ static int netlink_release(struct socket *sock)
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
@@ -933,10 +958,8 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	/* While we sleep in clone, do not allow to change socket list */
 
 	netlink_lock_table();
-
 	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_broadcast(sk, &info);
-
 	kfree_skb(skb);
 
 	netlink_unlock_table();
@@ -978,7 +1001,6 @@ static inline int do_one_set_err(struct sock *sk,
 out:
 	return 0;
 }
-
 void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 {
 	struct netlink_set_err_data info;
@@ -1272,8 +1294,6 @@ netlink_kernel_create(int unit, unsigned int groups,
 	struct netlink_sock *nlk;
 	unsigned long *listeners = NULL;
 
-	BUG_ON(!nl_table);
-
 	if (unit<0 || unit>=MAX_LINKS)
 		return NULL;
 
@@ -1579,6 +1599,7 @@ int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 pid,
 	return err;
 }
 
+#ifndef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 struct nl_seq_iter {
 	int link;
@@ -1722,6 +1743,7 @@ static const struct file_operations netlink_seq_fops = {
 };
 
 #endif
+#endif
 
 int netlink_register_notifier(struct notifier_block *nb)
 {
@@ -1763,9 +1785,11 @@ static struct net_proto_family netlink_family_ops = {
 static int __init netlink_proto_init(void)
 {
 	struct sk_buff *dummy_skb;
+#ifndef CONFIG_MDT_LOOKUP
 	int i;
 	unsigned long max;
 	unsigned int order;
+#endif
 	int err = proto_register(&netlink_proto, 0);
 
 	if (err != 0)
@@ -1777,6 +1801,7 @@ static int __init netlink_proto_init(void)
 	if (!nl_table)
 		goto panic;
 
+#ifndef CONFIG_MDT_LOOKUP
 	if (num_physpages >= (128 * 1024))
 		max = num_physpages >> (21 - PAGE_SHIFT);
 	else
@@ -1803,11 +1828,14 @@ static int __init netlink_proto_init(void)
 		hash->mask = 0;
 		hash->rehash_time = jiffies;
 	}
+#endif
 
 	sock_register(&netlink_family_ops);
+#ifndef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("netlink", 0, &netlink_seq_fops);
 #endif
+#endif
 	/* The netlink device handler may be needed early. */
 	rtnetlink_init();
 out:
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 28d47e8..65dc869 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1465,7 +1465,7 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	return 0;
 }
 
-
+#ifndef CONFIG_MDT_LOOKUP
 static int packet_notifier(struct notifier_block *this, unsigned long msg, void *data)
 {
 	struct sock *sk;
@@ -1516,7 +1516,7 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 	read_unlock(&packet_sklist_lock);
 	return NOTIFY_DONE;
 }
-
+#endif
 
 static int packet_ioctl(struct socket *sock, unsigned int cmd,
 			unsigned long arg)
@@ -1875,7 +1875,7 @@ static struct net_proto_family packet_family_ops = {
 	.create =	packet_create,
 	.owner	=	THIS_MODULE,
 };
-
+#ifndef CONFIG_MDT_LOOKUP
 static struct notifier_block packet_netdev_notifier = {
 	.notifier_call =packet_notifier,
 };
@@ -1957,13 +1957,16 @@ static const struct file_operations packet_seq_fops = {
 };
 
 #endif
+#endif
 
 static void __exit packet_exit(void)
 {
 	proc_net_remove("packet");
+#ifndef CONFIG_MDT_LOOKUP
 	unregister_netdevice_notifier(&packet_netdev_notifier);
-	sock_unregister(PF_PACKET);
 	proto_unregister(&packet_proto);
+#endif
+	sock_unregister(PF_PACKET);
 }
 
 static int __init packet_init(void)
@@ -1974,8 +1977,10 @@ static int __init packet_init(void)
 		goto out;
 
 	sock_register(&packet_family_ops);
+#ifndef CONFIG_MDT_LOOKUP
 	register_netdevice_notifier(&packet_netdev_notifier);
 	proc_net_fops_create("packet", 0, &packet_seq_fops);
+#endif
 out:
 	return rc;
 }
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 6069716..cb04b67 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -219,6 +219,7 @@ static int unix_mkname(struct sockaddr_un * sunaddr, int len, unsigned *hashp)
 	return len;
 }
 
+#ifndef CONFIG_MDT_LOOKUP
 static void __unix_remove_socket(struct sock *sk)
 {
 	sk_del_node_init(sk);
@@ -297,6 +298,30 @@ found:
 	spin_unlock(&unix_table_lock);
 	return s;
 }
+#else
+extern void __unix_remove_socket(struct sock *sk);
+extern void __unix_insert_socket(struct hlist_head *list, struct sock *sk);
+
+static inline void unix_remove_socket(struct sock *sk)
+{
+	__unix_remove_socket(sk);
+}
+
+static inline void unix_insert_socket(struct hlist_head *list, struct sock *sk)
+{
+	__unix_insert_socket(list, sk);
+}
+
+extern struct sock *__unix_find_socket_byname(struct sockaddr_un *sunname,
+					      int len, int type, unsigned hash);
+
+static inline struct sock *unix_find_socket_byname(struct sockaddr_un *sunname,
+						   int len, int type,
+						   unsigned hash)
+{
+	return __unix_find_socket_byname(sunname, len, type, hash);
+}
+#endif
 
 static inline int unix_writable(struct sock *sk)
 {
@@ -342,7 +367,9 @@ static void unix_sock_destructor(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
+#ifndef CONFIG_MDT_LOOKUP
 	BUG_TRAP(sk_unhashed(sk));
+#endif
 	BUG_TRAP(!sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		printk("Attempt to release alive unix socket: %p\n", sk);
@@ -695,6 +722,7 @@ out:	mutex_unlock(&u->readlock);
 static struct sock *unix_find_other(struct sockaddr_un *sunname, int len,
 				    int type, unsigned hash, int *error)
 {
+#ifndef CONFIG_MDT_LOOKUP
 	struct sock *u;
 	struct nameidata nd;
 	int err = 0;
@@ -742,6 +770,22 @@ put_fail:
 fail:
 	*error=err;
 	return NULL;
+#else
+	struct sock *u;
+	struct dentry *dentry;
+
+	u=unix_find_socket_byname(sunname, len, type, hash);
+	if (!u) {
+		*error = -ECONNREFUSED;
+		return NULL;
+	}
+
+	dentry = unix_sk(u)->dentry;
+	if (dentry)
+		touch_atime(unix_sk(u)->mnt, dentry);
+
+	return u;
+#endif
 }
 
 
@@ -1929,7 +1973,7 @@ static unsigned int unix_poll(struct file * file, struct socket *sock, poll_tabl
 	return mask;
 }
 
-
+#ifndef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 static struct sock *unix_seq_idx(int *iter, loff_t pos)
 {
@@ -2049,6 +2093,7 @@ static const struct file_operations unix_seq_fops = {
 };
 
 #endif
+#endif
 
 static struct net_proto_family unix_family_ops = {
 	.family = PF_UNIX,
@@ -2071,9 +2116,11 @@ static int __init af_unix_init(void)
 	}
 
 	sock_register(&unix_family_ops);
+#ifndef CONFIG_MDT_LOOKUP
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("unix", 0, &unix_seq_fops);
 #endif
+#endif
 	unix_sysctl_register();
 out:
 	return rc;
@@ -2083,7 +2130,9 @@ static void __exit af_unix_exit(void)
 {
 	sock_unregister(PF_UNIX);
 	unix_sysctl_unregister();
+#ifndef CONFIG_MDT_LOOKUP
 	proc_net_remove("unix");
+#endif
 	proto_unregister(&unix_proto);
 }
 
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index f20b7ea..4546882 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -170,8 +170,10 @@ static void maybe_unmark_and_push(struct sock *x)
 void unix_gc(void)
 {
 	static DEFINE_MUTEX(unix_gc_sem);
+#ifndef CONFIG_MDT_LOOKUP
 	int i;
 	struct sock *s;
+#endif
 	struct sk_buff_head hitlist;
 	struct sk_buff *skb;
 
@@ -183,11 +185,12 @@ void unix_gc(void)
 		return;
 
 	spin_lock(&unix_table_lock);
-
+#ifndef CONFIG_MDT_LOOKUP
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
 
+#ifndef CONFIG_MDT_LOOKUP
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
 
+#ifndef CONFIG_MDT_LOOKUP
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
