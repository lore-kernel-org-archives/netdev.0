From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 07/29] net: Flip inet_bind_bucket to net_ctx
Date: Wed,  4 Feb 2015 18:34:08 -0700
Message-ID: <1423100070-31848-8-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:32783 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274AbbBEBf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:59 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so6738091iec.3
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:59 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/inet_hashtables.h | 21 +++++++++++++++++----
 net/ipv4/inet_hashtables.c    |  2 +-
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index dd1950a7e273..c9e8b7b7331a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -76,9 +76,7 @@ struct inet_ehash_bucket {
  * ports are created in O(1) time?  I thought so. ;-)	-DaveM
  */
 struct inet_bind_bucket {
-#ifdef CONFIG_NET_NS
-	struct net		*ib_net;
-#endif
+	struct net_ctx		ib_net_ctx;
 	unsigned short		port;
 	signed char		fastreuse;
 	signed char		fastreuseport;
@@ -90,7 +88,22 @@ struct inet_bind_bucket {
 
 static inline struct net *ib_net(struct inet_bind_bucket *ib)
 {
-	return read_pnet(&ib->ib_net);
+	return read_pnet(&ib->ib_net_ctx.net);
+}
+
+static inline
+void ib_net_ctx_set(struct inet_bind_bucket *ib, struct net_ctx *ctx)
+{
+	write_pnet(&ib->ib_net_ctx.net, hold_net(ctx->net));
+}
+
+static inline
+int ib_net_ctx_eq(struct inet_bind_bucket *ib, struct net_ctx *ctx)
+{
+	if (net_eq(ib_net(ib), ctx->net))
+		return 1;
+
+	return 0;
 }
 
 #define inet_bind_bucket_for_each(tb, head) \
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 9111a4e22155..1485dac0ead5 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -61,7 +61,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
-		write_pnet(&tb->ib_net, hold_net(net));
+		write_pnet(&tb->ib_net_ctx.net, hold_net(net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		tb->fastreuseport = 0;
-- 
1.9.3 (Apple Git-50)
