From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-nex-2.6] tcp: replace ehash_size by ehash_mask
Date: Fri, 09 Oct 2009 12:16:19 +0200
Message-ID: <4ACF0D73.9070809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53294 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760586AbZJIKQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 06:16:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Storing the mask (size - 1) instead of the size allows fast path to be a bit faster.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_hashtables.h |    4 ++--
 net/dccp/proto.c              |   13 +++++++------
 net/ipv4/inet_diag.c          |    2 +-
 net/ipv4/inet_hashtables.c    |    2 +-
 net/ipv4/inet_timewait_sock.c |    2 +-
 net/ipv4/tcp.c                |   11 +++++------
 net/ipv4/tcp_ipv4.c           |    6 +++---
 net/ipv6/inet6_hashtables.c   |    2 +-
 8 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index d522dcf..5f11c4a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -125,7 +125,7 @@ struct inet_hashinfo {
 	 */
 	struct inet_ehash_bucket	*ehash;
 	spinlock_t			*ehash_locks;
-	unsigned int			ehash_size;
+	unsigned int			ehash_mask;
 	unsigned int			ehash_locks_mask;
 
 	/* Ok, let's try this, I give up, we do need a local binding
@@ -158,7 +158,7 @@ static inline struct inet_ehash_bucket *inet_ehash_bucket(
 	struct inet_hashinfo *hashinfo,
 	unsigned int hash)
 {
-	return &hashinfo->ehash[hash & (hashinfo->ehash_size - 1)];
+	return &hashinfo->ehash[hash & hashinfo->ehash_mask];
 }
 
 static inline spinlock_t *inet_ehash_lockp(
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index a156319..ecb203f 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1060,11 +1060,12 @@ static int __init dccp_init(void)
 	for (ehash_order = 0; (1UL << ehash_order) < goal; ehash_order++)
 		;
 	do {
-		dccp_hashinfo.ehash_size = (1UL << ehash_order) * PAGE_SIZE /
+		unsigned long hash_size = (1UL << ehash_order) * PAGE_SIZE /
 					sizeof(struct inet_ehash_bucket);
-		while (dccp_hashinfo.ehash_size &
-		       (dccp_hashinfo.ehash_size - 1))
-			dccp_hashinfo.ehash_size--;
+
+		while (hash_size & (hash_size - 1))
+			hash_size--;
+		dccp_hashinfo.ehash_mask = hash_size - 1;
 		dccp_hashinfo.ehash = (struct inet_ehash_bucket *)
 			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, ehash_order);
 	} while (!dccp_hashinfo.ehash && --ehash_order > 0);
@@ -1074,7 +1075,7 @@ static int __init dccp_init(void)
 		goto out_free_bind_bucket_cachep;
 	}
 
-	for (i = 0; i < dccp_hashinfo.ehash_size; i++) {
+	for (i = 0; i <= dccp_hashinfo.ehash_mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&dccp_hashinfo.ehash[i].chain, i);
 		INIT_HLIST_NULLS_HEAD(&dccp_hashinfo.ehash[i].twchain, i);
 	}
@@ -1153,7 +1154,7 @@ static void __exit dccp_fini(void)
 		   get_order(dccp_hashinfo.bhash_size *
 			     sizeof(struct inet_bind_hashbucket)));
 	free_pages((unsigned long)dccp_hashinfo.ehash,
-		   get_order(dccp_hashinfo.ehash_size *
+		   get_order((dccp_hashinfo.ehash_mask + 1) *
 			     sizeof(struct inet_ehash_bucket)));
 	inet_ehash_locks_free(&dccp_hashinfo);
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index a706a47..cb73fde 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -774,7 +774,7 @@ skip_listen_ht:
 	if (!(r->idiag_states & ~(TCPF_LISTEN | TCPF_SYN_RECV)))
 		goto unlock;
 
-	for (i = s_i; i < hashinfo->ehash_size; i++) {
+	for (i = s_i; i <= hashinfo->ehash_mask; i++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
 		spinlock_t *lock = inet_ehash_lockp(hashinfo, i);
 		struct sock *sk;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 625cc5f..a45aaf3 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -209,7 +209,7 @@ struct sock * __inet_lookup_established(struct net *net,
 	 * have wildcards anyways.
 	 */
 	unsigned int hash = inet_ehashfn(net, daddr, hnum, saddr, sport);
-	unsigned int slot = hash & (hashinfo->ehash_size - 1);
+	unsigned int slot = hash & hashinfo->ehash_mask;
 	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
 	rcu_read_lock();
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 13f0781..2fe5711 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -430,7 +430,7 @@ void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
 	int h;
 
 	local_bh_disable();
-	for (h = 0; h < (hashinfo->ehash_size); h++) {
+	for (h = 0; h <= hashinfo->ehash_mask; h++) {
 		struct inet_ehash_bucket *head =
 			inet_ehash_bucket(hashinfo, h);
 		spinlock_t *lock = inet_ehash_lockp(hashinfo, h);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 64d0af6..cf13726 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2865,11 +2865,10 @@ void __init tcp_init(void)
 					(totalram_pages >= 128 * 1024) ?
 					13 : 15,
 					0,
-					&tcp_hashinfo.ehash_size,
 					NULL,
+					&tcp_hashinfo.ehash_mask,
 					thash_entries ? 0 : 512 * 1024);
-	tcp_hashinfo.ehash_size = 1 << tcp_hashinfo.ehash_size;
-	for (i = 0; i < tcp_hashinfo.ehash_size; i++) {
+	for (i = 0; i <= tcp_hashinfo.ehash_mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].chain, i);
 		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].twchain, i);
 	}
@@ -2878,7 +2877,7 @@ void __init tcp_init(void)
 	tcp_hashinfo.bhash =
 		alloc_large_system_hash("TCP bind",
 					sizeof(struct inet_bind_hashbucket),
-					tcp_hashinfo.ehash_size,
+					tcp_hashinfo.ehash_mask + 1,
 					(totalram_pages >= 128 * 1024) ?
 					13 : 15,
 					0,
@@ -2933,8 +2932,8 @@ void __init tcp_init(void)
 	sysctl_tcp_rmem[2] = max(87380, max_share);
 
 	printk(KERN_INFO "TCP: Hash tables configured "
-	       "(established %d bind %d)\n",
-	       tcp_hashinfo.ehash_size, tcp_hashinfo.bhash_size);
+	       "(established %u bind %u)\n",
+	       tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..9971870 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2000,7 +2000,7 @@ static void *established_get_first(struct seq_file *seq)
 	struct net *net = seq_file_net(seq);
 	void *rc = NULL;
 
-	for (st->bucket = 0; st->bucket < tcp_hashinfo.ehash_size; ++st->bucket) {
+	for (st->bucket = 0; st->bucket <= tcp_hashinfo.ehash_mask; ++st->bucket) {
 		struct sock *sk;
 		struct hlist_nulls_node *node;
 		struct inet_timewait_sock *tw;
@@ -2061,10 +2061,10 @@ get_tw:
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
 		/* Look for next non empty bucket */
-		while (++st->bucket < tcp_hashinfo.ehash_size &&
+		while (++st->bucket <= tcp_hashinfo.ehash_mask &&
 				empty_bucket(st))
 			;
-		if (st->bucket >= tcp_hashinfo.ehash_size)
+		if (st->bucket > tcp_hashinfo.ehash_mask)
 			return NULL;
 
 		spin_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 1bcc343..874aed8 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -73,7 +73,7 @@ struct sock *__inet6_lookup_established(struct net *net,
 	 * have wildcards anyways.
 	 */
 	unsigned int hash = inet6_ehashfn(net, daddr, hnum, saddr, sport);
-	unsigned int slot = hash & (hashinfo->ehash_size - 1);
+	unsigned int slot = hash & hashinfo->ehash_mask;
 	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
 
