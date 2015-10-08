From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] net: align sk_refcnt on 128 bytes boundary
Date: Thu,  8 Oct 2015 08:37:05 -0700
Message-ID: <1444318627-27883-3-git-send-email-edumazet@google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33095 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809AbbJHPh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 11:37:26 -0400
Received: by pacex6 with SMTP id ex6so58251043pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 08:37:26 -0700 (PDT)
In-Reply-To: <1444318627-27883-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk->sk_refcnt is dirtied for every TCP/UDP incoming packet.
This is a performance issue if multiple cpus hit a common socket,
or multiple sockets are chained due to SO_REUSEPORT.

By moving sk_recnt 8 bytes further, first 128 bytes of sockets
are mostly read. As they contain the lookup keys, this has
a considerable performance impact, as cpus can cache them.

These 8 bytes are not wasted, we use them as a place holder
for various fields, depending on the socket type.

Tested:
 SYN flood hitting a 16 RX queues NIC.
 TCP listener using 16 sockets and SO_REUSEPORT
 and SO_INCOMING_CPU for proper siloing.

 Could process 6.0 Mpps SYN instead of 4.2 Mpps

 Kernel profile looked like :
    11.68%  [kernel]  [k] sha_transform
     6.51%  [kernel]  [k] __inet_lookup_listener
     5.07%  [kernel]  [k] __inet_lookup_established
     4.15%  [kernel]  [k] memcpy_erms
     3.46%  [kernel]  [k] ipt_do_table
     2.74%  [kernel]  [k] fib_table_lookup
     2.54%  [kernel]  [k] tcp_make_synack
     2.34%  [kernel]  [k] tcp_conn_request
     2.05%  [kernel]  [k] __netif_receive_skb_core
     2.03%  [kernel]  [k] kmem_cache_alloc

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_timewait_sock.h |  2 +-
 include/net/request_sock.h       |  2 +-
 include/net/sock.h               | 13 ++++++++++++-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 186f3a1e1b1f..e581fc69129d 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -70,6 +70,7 @@ struct inet_timewait_sock {
 #define tw_dport		__tw_common.skc_dport
 #define tw_num			__tw_common.skc_num
 #define tw_cookie		__tw_common.skc_cookie
+#define tw_dr			__tw_common.skc_tw_dr
 
 	int			tw_timeout;
 	volatile unsigned char	tw_substate;
@@ -88,7 +89,6 @@ struct inet_timewait_sock {
 	kmemcheck_bitfield_end(flags);
 	struct timer_list	tw_timer;
 	struct inet_bind_bucket	*tw_tb;
-	struct inet_timewait_death_row *tw_dr;
 };
 #define tw_tclass tw_tos
 
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 95ab5d7aab96..6b818b77d5e5 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -50,9 +50,9 @@ struct request_sock {
 	struct sock_common		__req_common;
 #define rsk_refcnt			__req_common.skc_refcnt
 #define rsk_hash			__req_common.skc_hash
+#define rsk_listener			__req_common.skc_listener
 
 	struct request_sock		*dl_next;
-	struct sock			*rsk_listener;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
 	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
diff --git a/include/net/sock.h b/include/net/sock.h
index 00f60bea983b..2ab099280979 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -150,6 +150,7 @@ typedef __u64 __bitwise __addrpair;
  *	@skc_node: main hash linkage for various protocol lookup tables
  *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
  *	@skc_tx_queue_mapping: tx queue number for this connection
+ *	@skc_flags: place holder for sk_flags
  *	@skc_incoming_cpu: record/match cpu processing incoming packets
  *	@skc_refcnt: reference count
  *
@@ -201,6 +202,16 @@ struct sock_common {
 
 	atomic64_t		skc_cookie;
 
+	/* following fields are padding to force
+	 * offset(struct sock, sk_refcnt) == 128 on 64bit arches
+	 * assuming IPV6 is enabled. We use this padding differently
+	 * for different kind of 'sockets'
+	 */
+	union {
+		unsigned long	skc_flags;
+		struct sock	*skc_listener; /* request_sock */
+		struct inet_timewait_death_row *skc_tw_dr; /* inet_timewait_sock */
+	};
 	/*
 	 * fields between dontcopy_begin/dontcopy_end
 	 * are not copied in sock_copy()
@@ -335,6 +346,7 @@ struct sock {
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
 #define sk_cookie		__sk_common.skc_cookie
 #define sk_incoming_cpu		__sk_common.skc_incoming_cpu
+#define sk_flags		__sk_common.skc_flags
 
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
@@ -372,7 +384,6 @@ struct sock {
 #ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
 #endif
-	unsigned long 		sk_flags;
 	struct dst_entry	*sk_rx_dst;
 	struct dst_entry __rcu	*sk_dst_cache;
 	spinlock_t		sk_dst_lock;
-- 
2.6.0.rc2.230.g3dd15c0
