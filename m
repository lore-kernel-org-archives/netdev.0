From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : change layout of ehash table
Date: Wed, 7 Feb 2007 11:59:34 +0100
Message-ID: <200702071159.34935.dada1@cosmosbay.com>
References: <20061219085601.GL4049@APFDCB5C> <20061219224726.GC4274@sortiz.org> <20070207.001226.63510892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_WEbyFIFjW2QKezX"
Cc: linux@horizon.com, akepner@sgi.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:33431 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161153AbXBGK7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 05:59:43 -0500
In-Reply-To: <20070207.001226.63510892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_WEbyFIFjW2QKezX
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


ehash table layout is currently this one :

First half of this table is used by sockets not in TIME_WAIT state
Second half of it is used by sockets in TIME_WAIT state.

This is non optimal because of for a given hash or socket, the two chain heads 
are located in separate cache lines.
Moreover the locks of the second half are never used.

If instead of this halving, we use two list heads in inet_ehash_bucket instead 
of only one, we probably can avoid one cache miss, and reduce ram usage, 
particularly if sizeof(rwlock_t) is big (various CONFIG_DEBUG_SPINLOCK, 
CONFIG_DEBUG_LOCK_ALLOC settings). So we still halves the table but we keep 
together related chains to speedup lookups and socket state change.

In this patch I did not try to align struct inet_ehash_bucket, but a future 
patch could try to make this structure have a convenient size (a power of two 
or a multiple of L1_CACHE_SIZE).
I guess rwlock will just vanish as soon as RCU is plugged into ehash :) , so 
maybe we dont need to scratch our heads to align the bucket...

Note : In case struct inet_ehash_bucket is not a power of two, we could 
probably change alloc_large_system_hash() (in case it use __get_free_pages()) 
to free the unused space. It currently allocates a big zone, but the last 
quarter of it could be freed. Again, this should be a temporary 'problem'.

Patch tested on ipv4 tcp only, but should be OK for IPV6 and DCCP.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_WEbyFIFjW2QKezX
Content-Type: text/plain;
  charset="iso-8859-1";
  name="tcp_ehash_reorg.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="tcp_ehash_reorg.patch"

--- linux-2.6.20/include/net/inet_hashtables.h	2007-02-07 09:19:22.000000000 +0100
+++ linux-2.6.20-ed/include/net/inet_hashtables.h	2007-02-07 12:20:47.000000000 +0100
@@ -34,12 +34,13 @@
 #include <asm/byteorder.h>
 
 /* This is for all connections with a full identity, no wildcards.
- * New scheme, half the table is for TIME_WAIT, the other half is
- * for the rest.  I'll experiment with dynamic table growth later.
+ * One chain is dedicated to TIME_WAIT sockets.
+ * I'll experiment with dynamic table growth later.
  */
 struct inet_ehash_bucket {
 	rwlock_t	  lock;
 	struct hlist_head chain;
+	struct hlist_head twchain;
 };
 
 /* There are a few simple rules, which allow for local port reuse by
@@ -97,8 +98,7 @@ struct inet_hashinfo {
 	 *
 	 *          TCP_ESTABLISHED <= sk->sk_state < TCP_CLOSE
 	 *
-	 * First half of the table is for sockets not in TIME_WAIT, second half
-	 * is for TIME_WAIT sockets only.
+	 * TIME_WAIT sockets use a separate chain (twchain).
 	 */
 	struct inet_ehash_bucket	*ehash;
 
@@ -369,7 +369,7 @@ static inline struct sock *
 	}
 
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
-	sk_for_each(sk, node, &(head + hashinfo->ehash_size)->chain) {
+	sk_for_each(sk, node, &head->twchain) {
 		if (INET_TW_MATCH(sk, hash, acookie, saddr, daddr, ports, dif))
 			goto hit;
 	}
--- linux-2.6.20/net/ipv4/tcp_ipv4.c	2007-02-07 09:09:40.000000000 +0100
+++ linux-2.6.20-ed/net/ipv4/tcp_ipv4.c	2007-02-07 09:42:26.000000000 +0100
@@ -2051,7 +2051,7 @@ static void *established_get_first(struc
 		}
 		st->state = TCP_SEQ_STATE_TIME_WAIT;
 		inet_twsk_for_each(tw, node,
-				   &tcp_hashinfo.ehash[st->bucket + tcp_hashinfo.ehash_size].chain) {
+				   &tcp_hashinfo.ehash[st->bucket].twchain) {
 			if (tw->tw_family != st->family) {
 				continue;
 			}
@@ -2107,7 +2107,7 @@ get_tw:
 	}
 
 	st->state = TCP_SEQ_STATE_TIME_WAIT;
-	tw = tw_head(&tcp_hashinfo.ehash[st->bucket + tcp_hashinfo.ehash_size].chain);
+	tw = tw_head(&tcp_hashinfo.ehash[st->bucket].twchain);
 	goto get_tw;
 found:
 	cur = sk;
--- linux-2.6.20/net/ipv4/tcp.c	2007-02-07 09:09:40.000000000 +0100
+++ linux-2.6.20-ed/net/ipv4/tcp.c	2007-02-07 09:33:33.000000000 +0100
@@ -2415,10 +2415,11 @@ void __init tcp_init(void)
 					&tcp_hashinfo.ehash_size,
 					NULL,
 					0);
-	tcp_hashinfo.ehash_size = (1 << tcp_hashinfo.ehash_size) >> 1;
-	for (i = 0; i < (tcp_hashinfo.ehash_size << 1); i++) {
+	tcp_hashinfo.ehash_size = 1 << tcp_hashinfo.ehash_size;
+	for (i = 0; i < tcp_hashinfo.ehash_size; i++) {
 		rwlock_init(&tcp_hashinfo.ehash[i].lock);
 		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].chain);
+		INIT_HLIST_HEAD(&tcp_hashinfo.ehash[i].twchain);
 	}
 
 	tcp_hashinfo.bhash =
@@ -2475,7 +2476,7 @@ void __init tcp_init(void)
 
 	printk(KERN_INFO "TCP: Hash tables configured "
 	       "(established %d bind %d)\n",
-	       tcp_hashinfo.ehash_size << 1, tcp_hashinfo.bhash_size);
+	       tcp_hashinfo.ehash_size, tcp_hashinfo.bhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
 }
--- linux-2.6.20/net/ipv4/inet_timewait_sock.c	2007-02-07 09:09:40.000000000 +0100
+++ linux-2.6.20-ed/net/ipv4/inet_timewait_sock.c	2007-02-07 09:33:33.000000000 +0100
@@ -78,8 +78,8 @@ void __inet_twsk_hashdance(struct inet_t
 	if (__sk_del_node_init(sk))
 		sock_prot_dec_use(sk->sk_prot);
 
-	/* Step 3: Hash TW into TIMEWAIT half of established hash table. */
-	inet_twsk_add_node(tw, &(ehead + hashinfo->ehash_size)->chain);
+	/* Step 3: Hash TW into TIMEWAIT chain. */
+	inet_twsk_add_node(tw, &ehead->twchain);
 	atomic_inc(&tw->tw_refcnt);
 
 	write_unlock(&ehead->lock);
--- linux-2.6.20/net/ipv4/inet_hashtables.c	2007-02-07 09:09:40.000000000 +0100
+++ linux-2.6.20-ed/net/ipv4/inet_hashtables.c	2007-02-07 09:33:33.000000000 +0100
@@ -212,7 +212,7 @@ static int __inet_check_established(stru
 	write_lock(&head->lock);
 
 	/* Check TIME-WAIT sockets first. */
-	sk_for_each(sk2, node, &(head + hinfo->ehash_size)->chain) {
+	sk_for_each(sk2, node, &head->twchain) {
 		tw = inet_twsk(sk2);
 
 		if (INET_TW_MATCH(sk2, hash, acookie, saddr, daddr, ports, dif)) {
--- linux-2.6.20/net/ipv4/inet_diag.c	2007-02-07 09:09:40.000000000 +0100
+++ linux-2.6.20-ed/net/ipv4/inet_diag.c	2007-02-07 09:33:33.000000000 +0100
@@ -775,7 +775,7 @@ next_normal:
 			struct inet_timewait_sock *tw;
 
 			inet_twsk_for_each(tw, node,
-				    &hashinfo->ehash[i + hashinfo->ehash_size].chain) {
+				    &head->twchain) {
 
 				if (num < s_num)
 					goto next_dying;
--- linux-2.6.20/net/dccp/proto.c	2007-02-07 10:50:36.000000000 +0100
+++ linux-2.6.20-ed/net/dccp/proto.c	2007-02-07 10:55:10.000000000 +0100
@@ -1024,7 +1024,6 @@ static int __init dccp_init(void)
 	do {
 		dccp_hashinfo.ehash_size = (1UL << ehash_order) * PAGE_SIZE /
 					sizeof(struct inet_ehash_bucket);
-		dccp_hashinfo.ehash_size >>= 1;
 		while (dccp_hashinfo.ehash_size &
 		       (dccp_hashinfo.ehash_size - 1))
 			dccp_hashinfo.ehash_size--;
@@ -1037,9 +1036,10 @@ static int __init dccp_init(void)
 		goto out_free_bind_bucket_cachep;
 	}
 
-	for (i = 0; i < (dccp_hashinfo.ehash_size << 1); i++) {
+	for (i = 0; i < dccp_hashinfo.ehash_size; i++) {
 		rwlock_init(&dccp_hashinfo.ehash[i].lock);
 		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].chain);
+		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].twchain);
 	}
 
 	bhash_order = ehash_order;
--- linux-2.6.20/net/ipv6/inet6_hashtables.c	2007-02-07 10:53:33.000000000 +0100
+++ linux-2.6.20-ed/net/ipv6/inet6_hashtables.c	2007-02-07 10:55:10.000000000 +0100
@@ -79,7 +79,7 @@ struct sock *__inet6_lookup_established(
 			goto hit; /* You sunk my battleship! */
 	}
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
-	sk_for_each(sk, node, &(head + hashinfo->ehash_size)->chain) {
+	sk_for_each(sk, node, &head->twchain) {
 		const struct inet_timewait_sock *tw = inet_twsk(sk);
 
 		if(*((__portpair *)&(tw->tw_dport))	== ports	&&
@@ -183,7 +183,7 @@ static int __inet6_check_established(str
 	write_lock(&head->lock);
 
 	/* Check TIME-WAIT sockets first. */
-	sk_for_each(sk2, node, &(head + hinfo->ehash_size)->chain) {
+	sk_for_each(sk2, node, &head->twchain) {
 		const struct inet6_timewait_sock *tw6 = inet6_twsk(sk2);
 
 		tw = inet_twsk(sk2);

--Boundary-00=_WEbyFIFjW2QKezX--
