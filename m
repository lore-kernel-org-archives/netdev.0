From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: fix the race when initializing nf_ct_expect_hash_rnd
Date: Mon,  6 Dec 2010 00:26:37 +0800
Message-ID: <1291566397-24318-1-git-send-email-xiaosuo@gmail.com>
Cc: netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50538 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab0LEXcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 18:32:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since nf_ct_expect_dst_hash() may be called without nf_conntrack_lock
locked, nf_ct_expect_hash_rnd should be initialized in the atomic way.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nf_conntrack_expect.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 46e8966..e2bb3ef 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -34,7 +34,6 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);
 
 static unsigned int nf_ct_expect_hash_rnd __read_mostly;
 unsigned int nf_ct_expect_max __read_mostly;
-static int nf_ct_expect_hash_rnd_initted __read_mostly;
 
 static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
 
@@ -77,10 +76,13 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 {
 	unsigned int hash;
 
-	if (unlikely(!nf_ct_expect_hash_rnd_initted)) {
-		get_random_bytes(&nf_ct_expect_hash_rnd,
-				 sizeof(nf_ct_expect_hash_rnd));
-		nf_ct_expect_hash_rnd_initted = 1;
+	if (unlikely(!nf_ct_expect_hash_rnd)) {
+		unsigned int rand;
+
+		do {
+			get_random_bytes(&rand, sizeof(rand));
+		} while (!rand);
+		cmpxchg(&nf_ct_expect_hash_rnd, 0, rand);
 	}
 
 	hash = jhash2(tuple->dst.u3.all, ARRAY_SIZE(tuple->dst.u3.all),
