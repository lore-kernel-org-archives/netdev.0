From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: fix cloning issues in fib_trie_unmerge()
Date: Mon, 14 Nov 2016 13:34:34 -0800
Message-ID: <1479159274.8455.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35478 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938503AbcKNVef (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:34:35 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so9890955pga.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 13:34:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I had crashes in a DEBUG_PAGEALLOC kernels in fib_table_flush() or
fib_table_lookup() that I back tracked to a refcounting issue
happening when we clone struct fib_alias in fib_trie_unmerge()

While fixing this issue, I also noticed a mem leak happening
if fib_insert_alias() fails.

Fixes: 0ddcf43d5d4a0 ("ipv4: FIB Local/MAIN table collapse")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/fib_trie.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4cff74d4133f..ebf49ab889e8 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1737,14 +1737,19 @@ struct fib_table *fib_trie_unmerge(struct fib_table *oldtb)
 				goto out;
 
 			memcpy(new_fa, fa, sizeof(*fa));
+			if (fa->fa_info)
+				fa->fa_info->fib_treeref++;
 
 			/* insert clone into table */
 			if (!local_l)
 				local_l = fib_find_node(lt, &local_tp, l->key);
 
 			if (fib_insert_alias(lt, local_tp, local_l, new_fa,
-					     NULL, l->key))
+					     NULL, l->key)) {
+				kmem_cache_free(fn_alias_kmem, new_fa);
+				fib_release_info(fa->fa_info);
 				goto out;
+			}
 		}
 
 		/* stop loop if key wrapped back to 0 */
