From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Wed, 12 Nov 2008 15:24:48 +0300
Message-ID: <20081112122448.GA12646@x200.localdomain>
References: <20081110.164424.167225199.davem@davemloft.net> <20081111110847.GC3665@x200.localdomain> <20081111111946.GD3665@x200.localdomain> <20081111.164554.143409564.davem@davemloft.net> <20081112104439.GA4292@x200.localdomain> <491AB4F5.2070206@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:14535 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbYKLMVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:21:22 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1024495ugf.37
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 04:21:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <491AB4F5.2070206@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 11:50:29AM +0100, Eric Dumazet wrote:
> I have no problem you take care of this.

OK, here is somethiing that hopefully satisfies everyone.
It depends on pnet stuff being dropped.



[PATCH v3] net: #ifdef inet_bind_bucket::ib_net

Save one pointer in every inet_bind_bucket in NET_NS=n case.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/inet_hashtables.h   |   18 ++++++++++++++++++
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/inet_hashtables.c      |    6 +++---
 3 files changed, 23 insertions(+), 5 deletions(-)

--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -77,13 +77,31 @@ struct inet_ehash_bucket {
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
+static inline void ib_net_set(struct inet_bind_bucket *ib, struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	ib->ib_net = net;
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
@@ -35,7 +35,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
-		tb->ib_net       = hold_net(net);
+		ib_net_set(tb, hold_net(net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		INIT_HLIST_HEAD(&tb->owners);
@@ -51,7 +51,7 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
 {
 	if (hlist_empty(&tb->owners)) {
 		__hlist_del(&tb->node);
-		release_net(tb->ib_net);
+		release_net(ib_net(tb));
 		kmem_cache_free(cachep, tb);
 	}
 }
@@ -449,7 +449,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			 * unique enough.
 			 */
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
-				if (tb->ib_net == net && tb->port == port) {
+				if (ib_net(tb) == net && tb->port == port) {
 					WARN_ON(hlist_empty(&tb->owners));
 					if (tb->fastreuse >= 0)
 						goto next_port;
