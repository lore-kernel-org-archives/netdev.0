From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: ib_net pointer should depends on CONFIG_NET_NS
Date: Wed, 12 Nov 2008 07:21:21 +0100
Message-ID: <491A75E1.8010704@cosmosbay.com>
References: <20081110.164424.167225199.davem@davemloft.net>	<20081111110847.GC3665@x200.localdomain>	<20081111111946.GD3665@x200.localdomain> <20081111.164554.143409564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030601070802010708040400"
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44413 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbYKLGV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 01:21:29 -0500
In-Reply-To: <20081111.164554.143409564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030601070802010708040400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We can shrink size of "struct inet_bind_bucket" by 50%, using read_pnet() and write_pnet()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/inet_hashtables.h   |    7 +++++++
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/inet_hashtables.c      |    6 +++---
 3 files changed, 12 insertions(+), 5 deletions(-)

--------------030601070802010708040400
Content-Type: text/plain;
 name="ib.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ib.patch"

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5cc182f..cb31fbf 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -77,13 +77,20 @@ struct inet_ehash_bucket {
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
+	return read_pnet(&ib->ib_net);
+}
+
 #define inet_bind_bucket_for_each(tb, node, head) \
 	hlist_for_each_entry(tb, node, head, node)
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 36f4cbc..05af807 100644
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
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 4498190..be41ebb 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -35,7 +35,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
-		tb->ib_net       = hold_net(net);
+		write_pnet(&tb->ib_net, hold_net(net));
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

--------------030601070802010708040400--
