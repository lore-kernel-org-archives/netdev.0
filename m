From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 2/2] ipv4: Fix memory leak in exception case for
 splitting tries
Date: Tue, 15 Nov 2016 05:46:12 -0500
Message-ID: <20161115104612.13711.44592.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44715 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752483AbcKOQrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 11:47:25 -0500
In-Reply-To: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a small memory leak that can occur where we leak a fib_alias in the
event of us not being able to insert it into the local table.

Fixes: 0ddcf43d5d4a0 ("ipv4: FIB Local/MAIN table collapse")
Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/fib_trie.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 735edc9..026f309 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1743,8 +1743,10 @@ struct fib_table *fib_trie_unmerge(struct fib_table *oldtb)
 				local_l = fib_find_node(lt, &local_tp, l->key);
 
 			if (fib_insert_alias(lt, local_tp, local_l, new_fa,
-					     NULL, l->key))
+					     NULL, l->key)) {
+				kmem_cache_free(fn_alias_kmem, new_fa);
 				goto out;
+			}
 		}
 
 		/* stop loop if key wrapped back to 0 */
