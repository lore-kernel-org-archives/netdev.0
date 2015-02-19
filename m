From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] rhashtable: better high order allocation attempts
Date: Fri, 20 Feb 2015 00:53:38 +0100
Message-ID: <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, johunt@akamai.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59410 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbbBSXxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 18:53:53 -0500
In-Reply-To: <cover.1424389682.git.daniel@iogearbox.net>
In-Reply-To: <cover.1424389682.git.daniel@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to allocate future tables via bucket_table_alloc(), it seems
overkill on large table shifts that we probe for kzalloc() unconditionally
first, as it's likely to fail.

Only probe with kzalloc() for more reasonable table sizes and use vzalloc()
either as a fallback on failure or directly in case of large table sizes.

Fixes: 7e1e77636e36 ("lib: Resizable, Scalable, Concurrent Hash Table")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/rhashtable.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 38f7879..b41a5c0 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -217,15 +217,15 @@ static void bucket_table_free(const struct bucket_table *tbl)
 static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 					       size_t nbuckets)
 {
-	struct bucket_table *tbl;
+	struct bucket_table *tbl = NULL;
 	size_t size;
 	int i;
 
 	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
-	tbl = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
+		tbl = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
 	if (tbl == NULL)
 		tbl = vzalloc(size);
-
 	if (tbl == NULL)
 		return NULL;
 
-- 
1.9.3
