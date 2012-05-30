From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [RFC PATCH 2/4] inet: add a second bind hash
Date: Wed, 30 May 2012 10:36:48 +0300
Message-ID: <1338363410-6562-3-git-send-email-alex.mihai.c@gmail.com>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Cc: gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47208 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2E3Hi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:38:58 -0400
Received: by wibhj8 with SMTP id hj8so3534716wib.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:38:56 -0700 (PDT)
In-Reply-To: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a second bind hash table which hashes by bound port and address.

Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/inet_hashtables.h |   13 ++++++++++---
 net/dccp/proto.c              |   36 ++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp.c                |   16 ++++++++++++++++
 3 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 8c6addc..a6d0db2 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -84,6 +84,7 @@ struct inet_bind_bucket {
 	signed short		fastreuse;
 	int			num_owners;
 	struct hlist_node	node;
+	struct hlist_node	portaddr_node;
 	struct hlist_head	owners;
 };
 
@@ -94,6 +95,8 @@ static inline struct net *ib_net(struct inet_bind_bucket *ib)
 
 #define inet_bind_bucket_for_each(tb, pos, head) \
 	hlist_for_each_entry(tb, pos, head, node)
+#define inet_portaddr_bind_bucket_for_each(tb, pos, head) \
+	hlist_for_each_entry(tb, pos, head, portaddr_node)
 
 struct inet_bind_hashbucket {
 	spinlock_t		lock;
@@ -129,13 +132,17 @@ struct inet_hashinfo {
 	unsigned int			ehash_mask;
 	unsigned int			ehash_locks_mask;
 
-	/* Ok, let's try this, I give up, we do need a local binding
-	 * TCP hash as well as the others for fast bind/connect.
+	/*
+	 * bhash:		hashes the buckets by port.
+	 * portaddr_bhash:	hashes bind buckets by bound port and address.
+	 *			When bhash gets too large, we try to lookup on
+	 *			portaddr_bhash.
 	 */
 	struct inet_bind_hashbucket	*bhash;
+	struct inet_bind_hashbucket	*portaddr_bhash;
 
 	unsigned int			bhash_size;
-	/* 4 bytes hole on 64 bit */
+	unsigned int			portaddr_bhash_size;
 
 	struct kmem_cache		*bind_bucket_cachep;
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e777beb..298f5c1 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1109,7 +1109,7 @@ EXPORT_SYMBOL_GPL(dccp_debug);
 static int __init dccp_init(void)
 {
 	unsigned long goal;
-	int ehash_order, bhash_order, i;
+	int ehash_order, bhash_order, portaddr_bhash_order, i;
 	int rc;
 
 	BUILD_BUG_ON(sizeof(struct dccp_skb_cb) >
@@ -1189,9 +1189,34 @@ static int __init dccp_init(void)
 		INIT_HLIST_HEAD(&dccp_hashinfo.bhash[i].chain);
 	}
 
+	portaddr_bhash_order = bhash_order;
+
+	do {
+		dccp_hashinfo.portaddr_bhash_size =
+			(1UL << portaddr_bhash_order) *
+			PAGE_SIZE / sizeof(struct inet_bind_hashbucket);
+		if ((dccp_hashinfo.portaddr_bhash_size > (64 * 1024)) &&
+				portaddr_bhash_order > 0)
+			continue;
+		dccp_hashinfo.portaddr_bhash = (struct inet_bind_hashbucket *)
+			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN,
+					 portaddr_bhash_order);
+	} while (!dccp_hashinfo.portaddr_bhash && --portaddr_bhash_order >= 0);
+
+	if (!dccp_hashinfi.portaddr_bhash) {
+		DCCP_CRIT("Failed to allocate DCCP portaddr bind hash table");
+		goto out_free_dccp_hash;
+	}
+
+	for (i = 0; i < dccp_hashinfo.portaddr_bhash_size; i++) {
+		dccp_hashinfo.portaddr_bhash[i].count = 0;
+		spin_lock_init(&dccp_hashinfo.portaddr_bhash[i].lock);
+		INIT_HLIST_HEAD(&dccp_hashinfo.portaddr_bhash[i].chain);
+	}
+
 	rc = dccp_mib_init();
 	if (rc)
-		goto out_free_dccp_bhash;
+		goto out_free_dccp_portaddr_bhash;
 
 	rc = dccp_ackvec_init();
 	if (rc)
@@ -1215,6 +1240,10 @@ out_ackvec_exit:
 	dccp_ackvec_exit();
 out_free_dccp_mib:
 	dccp_mib_exit();
+out_free_dccp_portaddr_bhash:
+	free_pages((unsigned long)dccp_hashinfo.portaddr_bhash,
+		   portaddr_bhash_order);
+	dccp_hashinfo.portaddr_bhash = NULL;
 out_free_dccp_bhash:
 	free_pages((unsigned long)dccp_hashinfo.bhash, bhash_order);
 out_free_dccp_locks:
@@ -1239,6 +1268,9 @@ static void __exit dccp_fini(void)
 	free_pages((unsigned long)dccp_hashinfo.bhash,
 		   get_order(dccp_hashinfo.bhash_size *
 			     sizeof(struct inet_bind_hashbucket)));
+	free_pages((unsigned long)dccp_hashinfo.portaddr_bhash,
+		   get_order(dccp_hashinfo.portaddr_bhash_size *
+			     sizeof(struct inet_bind_hashbucket)));
 	free_pages((unsigned long)dccp_hashinfo.ehash,
 		   get_order((dccp_hashinfo.ehash_mask + 1) *
 			     sizeof(struct inet_ehash_bucket)));
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 52cdf67..7dd3e19 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3538,6 +3538,22 @@ void __init tcp_init(void)
 		INIT_HLIST_HEAD(&tcp_hashinfo.bhash[i].chain);
 	}
 
+	tcp_hashinfo.portaddr_bhash =
+		alloc_large_system_hash("TCP portaddr_bind",
+					sizeof(struct inet_bind_hashbucket),
+					tcp_hashinfo.bhash_size,
+					(totalram_pages >= 128 * 1024) ?
+					13 : 15,
+					0,
+					&tcp_hashinfo.portaddr_bhash_size,
+					NULL,
+					64 * 1024);
+	tcp_hashinfo.portaddr_bhash_size = 1U << tcp_hashinfo.portaddr_bhash_size;
+	for (i = 0; i < tcp_hashinfo.portaddr_bhash_size; i++) {
+		tcp_hashinfo.portaddr_bhash[i].count = 0;
+		spin_lock_init(&tcp_hashinfo.portaddr_bhash[i].lock);
+		INIT_HLIST_HEAD(&tcp_hashinfo.portaddr_bhash[i].chain);
+	}
 
 	cnt = tcp_hashinfo.ehash_mask + 1;
 
-- 
1.7.10.2
