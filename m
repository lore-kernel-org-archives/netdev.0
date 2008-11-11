From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2] net: #ifdef inet_bind_bucket::ib_net
Date: Tue, 11 Nov 2008 14:19:46 +0300
Message-ID: <20081111111946.GD3665@x200.localdomain>
References: <20081107174100.GA3469@x200.localdomain> <49147FAC.8070306@cosmosbay.com> <20081107180738.GA3657@x200.localdomain> <20081110.164424.167225199.davem@davemloft.net> <20081111110847.GC3665@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:47522 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852AbYKKLQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 06:16:23 -0500
Received: by ug-out-1314.google.com with SMTP id 39so697353ugf.37
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 03:16:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081111110847.GC3665@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/inet_hashtables.h   |   11 +++++++++++
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/inet_hashtables.c      |    6 ++++--
 3 files changed, 17 insertions(+), 4 deletions(-)

--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -77,13 +77,24 @@ struct inet_ehash_bucket {
  * ports are created in O(1) time?  I thought so. ;-)	-DaveM
  */
 struct inet_bind_bucket {
+#ifdef CONFIG_NET_NS
 	struct net		*ib_net;
+#endif
 	unsigned short		port;
 	signed short		fastreuse;
 	struct hlist_node	node;
 	struct hlist_head	owners;
 };
 
+static inline struct net *ib_net(struct inet_bind_bucket *ib)
+{
+#ifdef CONFIG_NET_NS
+	return ib->ib_net;
+#else
+	return &init_net;
+#endif
+}
+
 #define inet_bind_bucket_for_each(tb, node, head) \
 	hlist_for_each_entry(tb, node, head, node)
 
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -109,7 +109,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (tb->ib_net == net && tb->port == rover)
+				if (ib_net(tb) == net && tb->port == rover)
 					goto next;
 			break;
 		next:
@@ -137,7 +137,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 				hashinfo->bhash_size)];
 		spin_lock(&head->lock);
 		inet_bind_bucket_for_each(tb, node, &head->chain)
-			if (tb->ib_net == net && tb->port == snum)
+			if (ib_net(tb) == net && tb->port == snum)
 				goto tb_found;
 	}
 	tb = NULL;
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -35,7 +35,9 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
+#ifdef CONFIG_NET_NS
 		tb->ib_net       = hold_net(net);
+#endif
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		INIT_HLIST_HEAD(&tb->owners);
@@ -51,7 +53,7 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
 {
 	if (hlist_empty(&tb->owners)) {
 		__hlist_del(&tb->node);
-		release_net(tb->ib_net);
+		release_net(ib_net(tb));
 		kmem_cache_free(cachep, tb);
 	}
 }
@@ -449,7 +451,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			 * unique enough.
 			 */
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
-				if (tb->ib_net == net && tb->port == port) {
+				if (ib_net(tb) == net && tb->port == port) {
 					WARN_ON(hlist_empty(&tb->owners));
 					if (tb->fastreuse >= 0)
 						goto next_port;
