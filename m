From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [RFC PATCH 1/4] inet: add counter to inet_bind_hashbucket
Date: Wed, 30 May 2012 10:36:47 +0300
Message-ID: <1338363410-6562-2-git-send-email-alex.mihai.c@gmail.com>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Cc: gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60430 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab2E3Hiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:38:55 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so4725525wgb.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:38:54 -0700 (PDT)
In-Reply-To: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The counter will be used by the upcoming INET lookup algorithm to
choose the shortest chain after secondary hash is added.

Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/inet_hashtables.h    |    4 +++-
 include/net/inet_timewait_sock.h |    4 +++-
 net/dccp/proto.c                 |    1 +
 net/ipv4/inet_hashtables.c       |    9 ++++++---
 net/ipv4/inet_timewait_sock.c    |    7 ++++---
 net/ipv4/tcp.c                   |    1 +
 6 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 808fc5f..8c6addc 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -98,6 +98,7 @@ static inline struct net *ib_net(struct inet_bind_bucket *ib)
 struct inet_bind_hashbucket {
 	spinlock_t		lock;
 	struct hlist_head	chain;
+	unsigned int		count;
 };
 
 /*
@@ -222,7 +223,8 @@ extern struct inet_bind_bucket *
 					    struct inet_bind_hashbucket *head,
 					    const unsigned short snum);
 extern void inet_bind_bucket_destroy(struct kmem_cache *cachep,
-				     struct inet_bind_bucket *tb);
+				     struct inet_bind_bucket *tb,
+				     struct inet_bind_hashbucket *head);
 
 static inline int inet_bhashfn(struct net *net,
 		const __u16 lport, const int bhash_size)
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index ba52c83..725e903 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -30,6 +30,7 @@
 #include <linux/atomic.h>
 
 struct inet_hashinfo;
+struct inet_bind_hashbucket;
 
 #define INET_TWDR_RECYCLE_SLOTS_LOG	5
 #define INET_TWDR_RECYCLE_SLOTS		(1 << INET_TWDR_RECYCLE_SLOTS_LOG)
@@ -197,7 +198,8 @@ extern void inet_twsk_put(struct inet_timewait_sock *tw);
 extern int inet_twsk_unhash(struct inet_timewait_sock *tw);
 
 extern int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
-				 struct inet_hashinfo *hashinfo);
+				 struct inet_hashinfo *hashinfo,
+				 struct inet_bind_hashbucket *head);
 
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 						  const int state);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 6c7c78b..e777beb 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1184,6 +1184,7 @@ static int __init dccp_init(void)
 	}
 
 	for (i = 0; i < dccp_hashinfo.bhash_size; i++) {
+		dccp_hashinfo.bhash[i].count = 0;
 		spin_lock_init(&dccp_hashinfo.bhash[i].lock);
 		INIT_HLIST_HEAD(&dccp_hashinfo.bhash[i].chain);
 	}
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 7880af9..c1f6f28 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -42,6 +42,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		tb->num_owners = 0;
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
+		head->count++;
 	}
 	return tb;
 }
@@ -49,9 +50,11 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 /*
  * Caller must hold hashbucket lock for this tb with local BH disabled
  */
-void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket *tb)
+void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket *tb,
+			      struct inet_bind_hashbucket *head)
 {
 	if (hlist_empty(&tb->owners)) {
+		head->count--;
 		__hlist_del(&tb->node);
 		release_net(ib_net(tb));
 		kmem_cache_free(cachep, tb);
@@ -90,7 +93,7 @@ static void __inet_put_port(struct sock *sk)
 	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->inet_num = 0;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb, head);
 	spin_unlock(&head->lock);
 }
 
@@ -527,7 +530,7 @@ ok:
 			twrefcnt += hash(sk, tw);
 		}
 		if (tw)
-			twrefcnt += inet_twsk_bind_unhash(tw, hinfo);
+			twrefcnt += inet_twsk_bind_unhash(tw, hinfo, head);
 		spin_unlock(&head->lock);
 
 		if (tw) {
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 2784db3..5b7bcd0 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -49,7 +49,8 @@ int inet_twsk_unhash(struct inet_timewait_sock *tw)
  *	Returns 1 if caller should call inet_twsk_put() after lock release.
  */
 int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
-			  struct inet_hashinfo *hashinfo)
+			  struct inet_hashinfo *hashinfo,
+			  struct inet_bind_hashbucket *head)
 {
 	struct inet_bind_bucket *tb = tw->tw_tb;
 
@@ -58,7 +59,7 @@ int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 
 	__hlist_del(&tw->tw_bind_node);
 	tw->tw_tb = NULL;
-	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb, head);
 	/*
 	 * We cannot call inet_twsk_put() ourself under lock,
 	 * caller must call it for us.
@@ -84,7 +85,7 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 			hashinfo->bhash_size)];
 
 	spin_lock(&bhead->lock);
-	refcnt += inet_twsk_bind_unhash(tw, hashinfo);
+	refcnt += inet_twsk_bind_unhash(tw, hashinfo, bhead);
 	spin_unlock(&bhead->lock);
 
 #ifdef SOCK_REFCNT_DEBUG
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bb485fc..52cdf67 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3533,6 +3533,7 @@ void __init tcp_init(void)
 					64 * 1024);
 	tcp_hashinfo.bhash_size = 1U << tcp_hashinfo.bhash_size;
 	for (i = 0; i < tcp_hashinfo.bhash_size; i++) {
+		tcp_hashinfo.bhash[i].count = 0;
 		spin_lock_init(&tcp_hashinfo.bhash[i].lock);
 		INIT_HLIST_HEAD(&tcp_hashinfo.bhash[i].chain);
 	}
-- 
1.7.10.2
