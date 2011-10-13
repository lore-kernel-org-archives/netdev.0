From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 17:26:21 +0200
Message-ID: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55168 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab1JMP0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 11:26:07 -0400
Received: by bkbzt4 with SMTP id zt4so1591397bkb.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 08:26:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb truesize currently accounts for sk_buff struct and part of skb head.

Considering that skb_shared_info is larger than sk_buff, its time to
take it into account for better memory accounting.

This patch introduces SKB_TRUESIZE(X) macro to centralize various
assumptions into a single place.

At skb alloc phase, we put skb_shared_info struct at the exact end of
skb head, to allow a better use of memory (lowering number of
reallocations), since kmalloc() gives us power-of-two memory blocks.

Note: This patch might trigger performance regressions because of
misconfigured protocol stacks, hitting per socket or global memory
limits that were previously not reached. But its a necessary step for a
more accurate memory accounting.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Andi Kleen <ak@linux.intel.com>
---
 include/linux/skbuff.h |    5 +++++
 net/core/skbuff.c      |   13 +++++++++----
 net/core/sock.c        |    2 +-
 net/ipv4/icmp.c        |    5 ++---
 net/ipv4/tcp_input.c   |   14 +++++++-------
 net/ipv6/icmp.c        |    3 +--
 net/iucv/af_iucv.c     |    2 +-
 net/sctp/protocol.c    |    2 +-
 8 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac6b05a..64f8695 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -46,6 +46,11 @@
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
 #define SKB_MAX_ALLOC		(SKB_MAX_ORDER(0, 2))
 
+/* return minimum truesize of one skb containing X bytes of data */
+#define SKB_TRUESIZE(X) ((X) +						\
+			 SKB_DATA_ALIGN(sizeof(struct sk_buff)) +	\
+			 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+
 /* A. Checksumming of received packets by device.
  *
  *	NONE: device failed to checksum this packet.
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b2c5f1..be66154 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -184,11 +184,15 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		goto out;
 	prefetchw(skb);
 
-	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	data = kmalloc_node_track_caller(size, gfp_mask, node);
 	if (!data)
 		goto nodata;
+	/* kmalloc(size) might give us more room than asked.
+	 * Put skb_shared_info exactly at the end of allocated zone,
+	 * to allow max possible filling before reallocation.
+	 */
+	size = SKB_WITH_OVERHEAD(ksize(data));
 	prefetchw(data + size);
 
 	/*
@@ -197,7 +201,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->truesize = size + sizeof(struct sk_buff);
+	/* Account for allocated memory : skb + skb->head */
+	skb->truesize = SKB_TRUESIZE(size);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
 	skb->data = data;
diff --git a/net/core/sock.c b/net/core/sock.c
index 83c462d..5a08762 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -207,7 +207,7 @@ static struct lock_class_key af_callback_keys[AF_MAX];
  * not depend upon such differences.
  */
 #define _SK_MEM_PACKETS		256
-#define _SK_MEM_OVERHEAD	(sizeof(struct sk_buff) + 256)
+#define _SK_MEM_OVERHEAD	SKB_TRUESIZE(256)
 #define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
 #define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 23ef31b..ab188ae 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1152,10 +1152,9 @@ static int __net_init icmp_sk_init(struct net *net)
 		net->ipv4.icmp_sk[i] = sk;
 
 		/* Enough space for 2 64K ICMP packets, including
-		 * sk_buff struct overhead.
+		 * sk_buff/skb_shared_info struct overhead.
 		 */
-		sk->sk_sndbuf =
-			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
+		sk->sk_sndbuf =	2 * SKB_TRUESIZE(64 * 1024);
 
 		/*
 		 * Speedup sock_wfree()
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 81cae64..c1653fe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -265,8 +265,7 @@ static inline int TCP_ECN_rcv_ecn_echo(struct tcp_sock *tp, struct tcphdr *th)
 
 static void tcp_fixup_sndbuf(struct sock *sk)
 {
-	int sndmem = tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HEADER + 16 +
-		     sizeof(struct sk_buff);
+	int sndmem = SKB_TRUESIZE(tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HEADER);
 
 	if (sk->sk_sndbuf < 3 * sndmem) {
 		sk->sk_sndbuf = 3 * sndmem;
@@ -349,7 +348,7 @@ static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
 static void tcp_fixup_rcvbuf(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int rcvmem = tp->advmss + MAX_TCP_HEADER + 16 + sizeof(struct sk_buff);
+	int rcvmem = SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
 
 	/* Try to select rcvbuf so that 4 mss-sized segments
 	 * will fit to window and corresponding skbs will fit to our rcvbuf.
@@ -540,8 +539,7 @@ void tcp_rcv_space_adjust(struct sock *sk)
 			space /= tp->advmss;
 			if (!space)
 				space = 1;
-			rcvmem = (tp->advmss + MAX_TCP_HEADER +
-				  16 + sizeof(struct sk_buff));
+			rcvmem = SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
 			while (tcp_win_from_space(rcvmem) < tp->advmss)
 				rcvmem += 128;
 			space *= rcvmem;
@@ -4950,8 +4948,10 @@ static void tcp_new_space(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tcp_should_expand_sndbuf(sk)) {
-		int sndmem = max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
-			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff);
+		int sndmem = SKB_TRUESIZE(max_t(u32,
+						tp->rx_opt.mss_clamp,
+						tp->mss_cache) +
+					  MAX_TCP_HEADER);
 		int demanded = max_t(unsigned int, tp->snd_cwnd,
 				     tp->reordering + 1);
 		sndmem *= 2 * demanded;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 2b59154..90868fb 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -835,8 +835,7 @@ static int __net_init icmpv6_sk_init(struct net *net)
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff struct overhead.
 		 */
-		sk->sk_sndbuf =
-			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
+		sk->sk_sndbuf = 2 * SKB_TRUESIZE(64 * 1024);
 	}
 	return 0;
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index c39f3a4..274d150 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1819,7 +1819,7 @@ static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 		goto save_message;
 
 	len = atomic_read(&sk->sk_rmem_alloc);
-	len += iucv_msg_length(msg) + sizeof(struct sk_buff);
+	len += SKB_TRUESIZE(iucv_msg_length(msg));
 	if (len > sk->sk_rcvbuf)
 		goto save_message;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 91784f4..61b9fca 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1299,7 +1299,7 @@ SCTP_STATIC __init int sctp_init(void)
 	max_share = min(4UL*1024*1024, limit);
 
 	sysctl_sctp_rmem[0] = SK_MEM_QUANTUM; /* give each asoc 1 page min */
-	sysctl_sctp_rmem[1] = (1500 *(sizeof(struct sk_buff) + 1));
+	sysctl_sctp_rmem[1] = 1500 * SKB_TRUESIZE(1);
 	sysctl_sctp_rmem[2] = max(sysctl_sctp_rmem[1], max_share);
 
 	sysctl_sctp_wmem[0] = SK_MEM_QUANTUM;
